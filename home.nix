{ extraHomeConfig, inputs, system, pkgs, ... }:

let
  modules' = [
    ./home/shared
    inputs.nix-index.homeManagerModules.${system}.default
    inputs.opnix.homeManagerModules.default
    inputs._1password-shell-plugins.hmModules.default
    inputs.nix-index-database.hmModules.nix-index
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
    extraHomeConfig
  ];

  mkHome = { mut ? false, mods ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      #extraSpecialArgs = pkgs.xargs;
      modules = modules' ++ mods ++ [
        { dotfiles.mutable = mut; }
      ];
    };

  mkHyprlandHome = { hidpi, mut ? false }: mkHome {
    inherit hidpi mut;
    mods = [
      inputs.hypr-binds-flake.homeManagerModules.${system}.default
      ../home/wm/hyprland/home.nix
    ];
  };
in
{
  cli  = mkHome {};
  hyprland-edp = mkHyprlandHome { hidpi = false; };
  hyprland-hdmi = mkHyprlandHome { hidpi = true; };
  hyprland-hdmi-mutable = mkHyprlandHome { hidpi = true; mut = true; };
}
