{
  extraHomeConfig ? {},
  inputs,
  system,
  pkgs,
  ...
}: let
  modules' = [
    ./home/shared
    inputs.nix-index.homeManagerModules.${system}.default
    #inputs.opnix.homeManagerModules.default
    inputs._1password-shell-plugins.hmModules.default
    inputs.nix-index-database.homeModules.nix-index
    {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
    extraHomeConfig
  ];

  mkHome = {
    mods ? [],
    host ? "",
  }: (inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    #extraSpecialArgs = pkgs.xargs;
    extraSpecialArgs = {inherit inputs;};
    modules =
      modules'
      ++ mods
      ++ (pkgs.lib.optional (builtins.pathExists ./home/machine/${host}) ./home/machine/${host});
  });

  mkHyprlandHome = _:
    mkHome {
      mods = [
        ./home/programs/hyprland
      ];
    };
in {
  cli = mkHome {};
  hyprland = mkHyprlandHome {};

  "sam@argon" = mkHyprlandHome {
    host = "argon";
  };

  "sam@minos" = mkHome {host = "minos";};
  "sam@mnemosyne" = mkHome {host = "mnemosyne";};
  "sam@home-assistant" = mkHome {host = "home-assistant";};
  "sam@work" = mkHome {host = "work";};
}
