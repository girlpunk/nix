{pkgs, ...}: {
  imports = [
    ../dotnet.nix
  ];

  environment.systemPackages = with pkgs; [
    unstable.jetbrains.rider
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    icu
    # ncurses6
  ];
}
