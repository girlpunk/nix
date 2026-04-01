{pkgs, lib, ...}: let
  nix-linter = pkgs.writeShellScriptBin "nix-linter" ''
    #nixfmt $1
    ${lib.getExe pkgs.statix} check -c ${./config.toml} $1
  '';
in {
  home.packages = [
    nix-linter
    #pkgs.statix
  ];
}
