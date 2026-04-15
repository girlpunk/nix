{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = ["FiraCode Nerd Font"]; # Mono Reg
  };
}
