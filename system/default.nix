{pkgs, ...}: {
  imports = [
    ./modules/language.nix
    ./modules/user.nix
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes
      keep-derivations = true
      keep-outputs = true
    '';
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://channable-public.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "minos:wcHt079XZRopdL7wy1aeBjkgE82Vmz1K9n8WpsOgZsY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Virtualization settings
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      fira-code
      nerd-fonts.fira-code
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cifs-utils
    comma
    home-manager
    killall
    lm_sensors
    nano
    pciutils
    wget
  ];

  services = {
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    speechd.enable = false;
  };

  programs = {
    nh = {
      enable = true;

      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";

      flake = "/home/sam/programs/nix";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      icu
      ncurses6
    ];
  };
}
