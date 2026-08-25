{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./build-user.nix
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ../../modules/mounts.nix
    ../../programs/android
    ../../programs/ollama.nix
    ../../programs/rider
    ../../programs/sshd.nix
    ../../programs/steam.nix
    ../../programs/sunshine.nix
  ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.qemuGuest.enable = true;

  networking = {
    hostName = "minos";

    domain = "home.foxocube.xyz";
    search = [
      "home.foxocube.xyz"
      "home.jacobmansfield.co.uk"
    ];

    useNetworkd = true;
    useDHCP = false;
  };

  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [
      "192.168.42.254"
    ];
  };

  systemd.network = {
    enable = true;
    networks."ens18" = {
      matchConfig.Name = "ens18";

      address = ["192.168.42.24/24"];
      gateway = ["192.168.42.254"];
      dns = [
        "192.168.42.254"
      ];

      networkConfig = {
        IPv6AcceptRA = true;
        DHCP = "no";
      };

      linkConfig.RequiredForOnline = "routable";
      ipv6AcceptRAConfig.UseDNS = true;
      domains = config.networking.search;
    };
  };

  networking.firewall.allowedTCPPorts = [
    5107
    8000
  ];

  environment.systemPackages = [
    inputs.faedupes.packages.x86_64-linux.faedupes
    pkgs.unstable.immich-go
  ];

  # Binary cache for the NFS cold tier, served statically (see systemd units below).
  # Cold paths are signed during build with `secret-key-files` above, so consumers
  # that trust the minos public key can pull them straight from this cache.
  fileSystems."nix-cold" = {
    device = "192.168.42.4:/Storage/NixCold";
    fsType = "nfs";
    mountPoint = "/var/lib/nix-cold";
    options = [
      "_netdev"
      "nofail"
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."nix-cold-cache" = {
      listen = [
        {
          port = 8000;
          addr = "0.0.0.0";
        }
      ];
      root = "/var/lib/nix-cold";
    };
  };

  nix = {
    extraOptions = ''
      secret-key-files = /etc/nix/cache-priv-key.pem
    '';

    # Appended to the global substituters (the NixOS nix module merges the
    # lists). Lets minos re-pull paths it has offloaded to the cold cache
    # (e.g. rollbacks past the 4d/3-generation window).
    settings.substituters = ["http://127.0.0.1:8000/"];
  };

  programs.nh.clean.extraArgs = lib.mkForce "--keep-since 4d --keep 3 --no-gc";

  systemd = {
    # Offloads unreachable store paths older than 14 days to the NFS cold
    # cache (binary cache layout via `nix copy --to file://`), then deletes
    # them from the local store. A path is only deleted if it was offloaded
    # (already present or freshly copied), so local space is never lost if
    # the NAS is down or full — the run simply retries the next day.
    services."nix-store-ageout" = {
      description = "Offload unreachable store paths older than 14 days to the NFS cold cache, then delete them";
      path = [
        config.nix.package
        pkgs.findutils
        pkgs.gnugrep
        pkgs.coreutils
        pkgs.bash
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
      };
      script = ''
        set -eu
        COLD=/var/lib/nix-cold
        mountpoint -q "$COLD" || { echo "cold cache not mounted, skipping"; exit 0; }
        find /nix/store -maxdepth 1 -type d -mtime +14 \
          | grep -E '^/nix/store/[0-9a-z]{32}-' \
          | while IFS= read -r p; do
            base="$(basename "$p")"
            # narinfo files are named by hash-part only (<hash>.narinfo),
            # i.e. the store path base without its "-name" suffix.
            hp="$(echo "$base" | cut -d- -f1)"
            if [ ! -e "$COLD/$hp.narinfo" ]; then
              nix copy --to "file://$COLD" "$p" || continue
            fi
            nix store delete "$p" 2>/dev/null || true
          done
      '';
    };

    timers."nix-store-ageout" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "30min";
        Persistent = true;
      };
    };

    # Cold-cache retention: removes entries from the NFS binary cache that
    # were offloaded more than 90 days ago (narinfo + its .nar.xz, whose URL
    # is read from the narinfo).
    services."nix-cold-cache-ageout" = {
      description = "Delete NFS cold-cache entries older than 90 days";
      path = [
        pkgs.findutils
        pkgs.gnugrep
        pkgs.coreutils
        pkgs.bash
      ];
      serviceConfig = {
        Type = "oneshot";
        Nice = 19;
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
      };
      script = ''
        set -eu
        COLD=/var/lib/nix-cold
        [ -d "$COLD" ] || exit 0
        find "$COLD" -maxdepth 1 -name '*.narinfo' -mtime +90 \
          | while IFS= read -r ni; do
            url="$(grep '^URL: ' "$ni" | cut -d' ' -f2)"
            rm -f -- "$ni"
            if [ -n "$url" ]; then rm -f -- "$COLD/$url"; fi
          done
      '';
    };

    timers."nix-cold-cache-ageout" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
