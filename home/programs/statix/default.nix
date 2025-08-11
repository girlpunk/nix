{pkgs, ...}: let
  nix-linter = pkgs.writeShellScriptBin "nix-linter" ''
    #nixfmt $1
    ${pkgs.statix}/bin/statix check -c ${./config.toml} $1
  '';
in {
  home.packages = [
    nix-linter
    pkgs.statix
  ];
}
