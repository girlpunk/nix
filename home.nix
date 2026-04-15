{
  inputs,
  system,
  pkgs,
  ...
}: let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (pkgs) lib;

  modules = [
    ./home
    inputs.nix-index.homeManagerModules.${system}.default
    inputs._1password-shell-plugins.hmModules.default
    inputs.nix-index-database.homeModules.nix-index
    {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
  ];

  hosts = [
    "sam@argon"
    "sam@minos"
    "sam@mnemosyne"
    "sam@home-assistant"
    "sam@work"
  ];

  make = host: {
    ${host} = homeManagerConfiguration {
      inherit lib pkgs;
      extraSpecialArgs = {inherit inputs;};
      modules = modules ++ [./system/machine/${host}];
    };
  };
in {
  modules = modules;
  configs = lib.mergeAttrsList (map make hosts);
}
