{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kitty
    nerd-fonts.fira-code
    geoclue2
    brightnessctl
    ddcutil
    corefonts
    discord
    greetd.tuigreet
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #services.greetd = {
  #  enable = true;
  #  settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  #};

  programs = {
    hyprland.enable = true;

    regreet = {
      enable = true;
    };

    firefox.enable = true;
  };

  boot.plymouth = {
    enable = true;
    font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf";
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
    #  boot.plymouth.theme = "breeze";
  };

  services.geoclue2.enable = true;
}
