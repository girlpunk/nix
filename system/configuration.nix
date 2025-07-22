{
  config,
  pkgs,
  lib,
  currentSystem,
  currentSystemName,
  ...
}:

{
  imports = [
    ./language.nix
    ./user.nix
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://channable-public.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Virtualization settings
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  #users.mutableUsers = false;

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      fira-code
      nerd-fonts.fira-code
      #pkgs.jetbrains-mono
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano
    pciutils
    wget
    cifs-utils
    killall
    home-manager
    comma
  ];

  environment = {
    sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/sam/programs/nix";
    };

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      icu
      ncurses6
    ];
  };

  #system.autoUpgrade = {
  #  enable = true;
  #};

  #nix.gc = {
  #  automatic = true;
  #  options = "--delete-older-than 14d";
  #};
}
