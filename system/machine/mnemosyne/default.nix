{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ./apps/adventurelog.nix
    ./apps/authentik.nix
    ./apps/dawarich.nix
    ./apps/emf.nix
    ./apps/immich.nix
    ./apps/inventory-sharp.nix
    ./apps/kavita.nix
    ./apps/mastodon.nix
    ./apps/matrix.nix
    ./apps/mediafeeder.nix
    ./apps/openproject.nix
    ./apps/outline.nix
    ./apps/paperless.nix
    ./apps/tandoor.nix

    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd

    # ../../modules/remoteBuild.nix
    ../../programs/sshd.nix
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
    hostName = "mnemosyne";

    domain = "home.foxocube.xyz";
    search = [
      "home.foxocube.xyz"
    ];

    useNetworkd = true;
    useDHCP = false;

    firewall.allowedTCPPorts = [5432];
  };

  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [
      "10.0.5.1"
      "2001:678:b04:105::1"
    ];
  };

  systemd.network = {
    enable = true;
    networks."40-ens18" = {
      matchConfig.Name = "ens18";

      address = [
        "10.0.5.201/24"
        "2001:678:b07:105::201/64"
      ];
      gateway = [
        "10.0.5.1"
        "2001:678:b04:105::1"
      ];
      dns = [
        "10.0.5.1"
        "2001:678:b04:105::1"
      ];

      networkConfig = {
        IPv6AcceptRA = true;
        DHCP = lib.mkForce "no";
      };

      linkConfig.RequiredForOnline = "routable";
      ipv6AcceptRAConfig.UseDNS = true;
      domains = config.networking.search;
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
