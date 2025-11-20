{
  extraHomeConfig,
  inputs,
  system,
  pkgs,
  ...
}: let
  modules' = [
    ./home/shared
    inputs.nix-index.homeManagerModules.${system}.default
    inputs.opnix.homeManagerModules.default
    inputs._1password-shell-plugins.hmModules.default
    inputs.nix-index-database.homeModules.nix-index
    {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
    extraHomeConfig
  ];

  mkHome = {
    mut ? false,
    work ? false,
    mods ? [],
  }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      #extraSpecialArgs = pkgs.xargs;
      extraSpecialArgs = {inherit inputs;};
      modules =
        modules'
        ++ mods
        ++ [
          {
            dotfiles.mutable = mut;
            defaultGit.work = work;
          }
        ];
    };

  mkHyprlandHome = {
    hidpi,
    monitors,
    mut ? false,
  }:
    mkHome {
      inherit mut;
      mods =
        [
          #inputs.hypr-binds-flake.homeManagerModules.${system}.default
          ./home/programs/hyprland
        ]
        ++ [
          {hyprland.monitors = monitors;}
        ];
    };
in {
  cli = mkHome {};
  hyprland-edp = mkHyprlandHome {hidpi = false;};
  hyprland-hdmi = mkHyprlandHome {hidpi = true;};
  hyprland-hdmi-mutable = mkHyprlandHome {
    hidpi = true;
    mut = true;
  };

  "sam@argon" = mkHyprlandHome {
    hidpi = true;

    monitors = [
      # See https://wiki.hyprland.org/Configuring/Monitors/
      "eDP-1,preferred,auto,1"
      "HDMI-A-2,preferred,auto-left,1"
    ];
  };

  "sam@minos" = mkHome {};
  "sam@home-assistant" = mkHome {};
  "sam@work" = mkHome {
    work = true;
  };
}
