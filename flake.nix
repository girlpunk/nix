{
  description = "Foxocube's NixOS configuration";

  inputs = {
    # Main repo for most packages
    nixpkgs.url = "nixpkgs/nixos-25.05";

    # We want the newest version for some stuff, so that comes from here
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    #nixpkgs.url = "/home/sam/programs/nixpkgs";

    # WSL Compatability
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      #url = "/home/sam/programs/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index = {
      url = "github:gvolpe/nix-index";
      inputs.nix-index-database.follows = "nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fast nix search client
    nix-search = {
      url = "github:diamondburned/nix-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix linter
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    statix = {
      url = "github:nerdypepper/statix";
      inputs.fenix.follows = "fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
    opnix.url = "github:brizzbuzz/opnix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = import ./lib/overlays.nix {inherit inputs system;};

    pkgs = import nixpkgs {
      inherit overlays system;
      config.allowUnfree = true;
    };
  in {
    homeConfigurations = pkgs.builders.mkHome {};
    nixosConfigurations = pkgs.builders.mkNixos {};

    out = {inherit pkgs overlays;};

    formatter.${system} = pkgs.alejandra;

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
