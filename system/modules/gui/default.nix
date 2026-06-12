{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    corefonts
    kitty
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
    };

    regreet = {
      enable = true;
    };

    uwsm = {
      enable = true;
      waylandCompositors.hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
    };

    #firefox = {
    #  enable = true;
    #  wrapperConfig = {
    #    speechSynthesisSupport = false;
    #    #pipewireSupport = true;
    #  };
    #};

    iio-hyprland.enable = true;
  };

  boot.plymouth = {
    enable = true;
    font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf";
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
  };

  services.geoclue2.enable = true;
}
