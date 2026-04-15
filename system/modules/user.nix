{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.sam = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "docker"
        "i2c"
        "wireshark"
      ];
      openssh = {
        authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFygf49qzrMruoAeB/Y0RcpkTFGpTVpRr+bwRhDQIZzI sam@argon"
        ];
      };
      shell = pkgs.zsh;
    };

    groups.i2c = {};
  };

  programs = {
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
    };

    _1password.enable = true;

    git = {
      enable = true;
    };
  };

  nix.settings.trusted-users = [
    "root"
    "sam"
  ];

  # Build a home-manager config for me
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.sam.imports = (pkgs.callPackage ../../home.nix {
      inherit inputs pkgs;
      inherit (pkgs) system;
    }).modules ++ [ (../../home/machine + "/sam@${config.networking.hostName}") ];
  };
}
