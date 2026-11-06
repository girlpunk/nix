{
  inputs,
  system,
  overlays,
  ...
}: let
  inherit (inputs.home-manager.lib) homeManagerConfiguration;

  pkgs = import inputs.nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  modules = [
    ./home
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
      inherit pkgs;
      inherit (pkgs) lib;
      extraSpecialArgs = {inherit inputs;};
      modules = modules ++ [./home/machine/${host}];
    };
  };
in {
  inherit modules;
  configs = pkgs.lib.mergeAttrsList (map make hosts);
}
