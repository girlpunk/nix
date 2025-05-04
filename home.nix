{ extraHomeConfig, inputs, system, pkgs, ... }:

let
  modules' = [
    ./home/shared
    inputs.nix-index.homeManagerModules.${system}.default
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
