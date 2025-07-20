{ extraSystemConfig, inputs, system, pkgs, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (pkgs) lib;

  hosts = [ "argon" "minos" ];

  modules' = [
    ./system/configuration.nix
    #./system/virtualisation.nix
    extraSystemConfig
    inputs.opnix.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
  ];

  make = host: {
    ${host} = nixosSystem {
      inherit lib pkgs system;
      specialArgs = { inherit inputs; };
      modules = modules' ++ [ ./system/machine/${host} ];
    };
  };
in
lib.mergeAttrsList (map make hosts)
