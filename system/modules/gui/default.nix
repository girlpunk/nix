{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kitty
    nerd-fonts.fira-code
    geoclue2
    brightnessctl
    ddcutil
    corefonts
    discord
  ];

  programs.hyprland.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.firefox.enable = true;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "breeze";

  services.geoclue2.enable = true;
}
