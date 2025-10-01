{pkgs, ...}: {
  ## Gnome themes
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    cursorTheme.name = "Adwaita";
    cursorTheme.size = 16;
    #iconTheme.name = "Breeze";
    iconTheme = {
      package = pkgs.hicolor-icon-theme;
      name = "hicolor";
    };
  };
}
