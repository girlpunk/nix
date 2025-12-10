{
  description = "Foxocube's NixOS configuration";

  inputs = {
    # Main repo for most packages
    nixpkgs.url = "nixpkgs/nixos-25.11";

    # We want the newest version for some stuff, so that comes from here
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";

    # WSL Compatability
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      #url = "/home/sam/programs/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
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
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-utils.url = "github:numtide/flake-utils";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    overlays = import ./lib/overlays.nix {inherit inputs system;};

    pkgs = import nixpkgs {
      inherit overlays system;
      config.allowUnfree = true;
    };

    treefmt = inputs.treefmt-nix.lib.evalModule pkgs (
      {pkgs, ...}: {
        # Used to find the project root
        projectRootFile = "flake.nix";

        # Enable the Nix formatter
        programs.alejandra.enable = true;
        programs.statix.enable = true;
      }
    );
  in
    {
      homeConfigurations = pkgs.builders.mkHome {};
      nixosConfigurations = pkgs.builders.mkNixos {};
    }
    // inputs.flake-utils.lib.eachDefaultSystem (_: {
      out = {inherit pkgs overlays;};

      formatter = treefmt.config.build.wrapper;
      checks = {
        formatting = treefmt.config.build.check self;
      };
    });

  #{

  #nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
  #  pkgs = import nixpkgs { inherit system; config = { allowUnfree = true; };};
  #  system = "x86_64-linux";
  #  modules = [
  #    ./configuration.nix
  #    ({ config, pkgs, options, ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
  #  ];
  #};
  #  };
}
