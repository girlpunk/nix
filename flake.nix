{
  description = "Foxocube's NixOS configuration";

  inputs = {
    # Main repo for most packages
    nixpkgs.url = "nixpkgs/nixos-24.11";

    # We want the newest version for some stuff, so that comes from here
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    # WSL Compatability
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = github:nix-community/nix-index-database;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index = {
      url = github:gvolpe/nix-index;
      inputs.nix-index-database.follows = "nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fast nix search client
    nix-search = {
      url = github:diamondburned/nix-search;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix linter
    fenix = {
      url = github:nix-community/fenix;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    statix = {
      url = github:nerdypepper/statix;
      inputs.fenix.follows = "fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    system = "x86_64-linux";

    overlays = import ./lib/overlays.nix { inherit inputs system; };

    pkgs = import nixpkgs {
      inherit overlays system;
      config.allowUnfree = true;
    };
  in {
    homeConfigurations = pkgs.builders.mkHome {};
    nixosConfigurations = pkgs.builders.mkNixos {};

    out = { inherit pkgs overlays; };

    

    #nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
    #  pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; };};
    #  system = "x86_64-linux";
    #  modules = [
    #    ./configuration.nix
    #    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
    #  ];
    #};
  };
}
