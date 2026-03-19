{
  extraSystemConfig,
  inputs,
  system,
  pkgs,
  ...
}: let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (pkgs) lib;

  hosts = [
    "argon"
    "minos"
    "mnemosyne"
    "work"
  ];

  modules' = [
    ./system/configuration.nix
    #./system/virtualisation.nix
    extraSystemConfig
    inputs.sops-nix.nixosModules.sops
    inputs.nix-index-database.nixosModules.nix-index
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
    {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
  ];

  make = host: {
    ${host} = nixosSystem {
      inherit lib pkgs system;
      specialArgs = {inherit inputs;};
      modules = modules' ++ [./system/machine/${host}];
    };
  };
in
  lib.mergeAttrsList (map make hosts)
