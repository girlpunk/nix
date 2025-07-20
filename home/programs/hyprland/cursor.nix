{ pkgs, ... }:
{
  home.pointerCursor = {
    hyprcursor.enable = true;
    enable = true;

    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    # Breeze5 24
  };
}
