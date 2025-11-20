{
  pkgs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./build-user.nix
    ../../programs/rider
    ../../programs/sshd.nix
    ../../programs/steam.nix
    ../../programs/sunshine.nix

    flake-inputs.nixos-hardware.nixosModules.common-pc-ssd
    flake-inputs.nixos-hardware.nixosModules.common-cpu-intel
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
    fallbackDns = [
      "192.168.42.200"
      "192.168.42.201"
    ];
  };

  systemd.network = {
    enable = true;
    networks."ens18" = {
      matchConfig.Name = "ens18";

      address = ["192.168.42.24/24"];
      gateway = ["192.168.42.254"];
      dns = [
        "192.168.42.200"
        "192.168.42.201"
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

  nix = {
    extraOptions = ''
      secret-key-files = /etc/nix/cache-priv-key.pem
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
