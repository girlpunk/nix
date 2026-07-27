{
  description = "Foxocube's NixOS configuration";

  inputs = {
    # Main repo for most packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # We want the newest version for some stuff, so that comes from here
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # WSL Compatibility
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";

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

      inputs = {
        nix-index-database.follows = "nix-index-database";
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    # Nix linter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";

      inputs.systems.follows = "nix-systems";
    };

    #hyprland = {
    #  url = "github:hyprwm/Hyprland/v0.52.2";

    #  inputs = {
    #    nixpkgs.follows = "nixpkgs";
    #    systems.follows = "nix-systems";
    #    pre-commit-hooks.follows = "git-hooks";
    #  };
    #};

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "nix-systems";
      };
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit.follows = "git-hooks";
      };
    };

    disko = {
      url = "github:nix-community/disko";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";

      inputs = {
        flake-compat.follows = "flake-compat";
        gitignore.inputs.nixpkgs.follows = "nixpkgs";
        nixpkgs.follows = "nixpkgs";
      };
    };

    mediafeeder = {
      url = "github:girlpunk/MediaFeeder";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
        git-hooks-nix.follows = "git-hooks";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
        make-shell.follows = "make-shell";
      };
    };

    faedupes = {
      url = "/home/sam/programs/faedupes";

      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        git-hooks-nix.follows = "git-hooks";
        treefmt-nix.follows = "treefmt-nix";
        flake-parts.follows = "flake-parts";
        make-shell.follows = "make-shell";
      };
    };

    # Common dependencies
    nix-systems.url = "github:nix-systems/default";
    flake-compat.url = "github:NixOS/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs = {
        flake-compat.follows = "flake-compat";
      };
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
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "docker-28.5.2"
        ];
      };
    };

    treefmt = inputs.treefmt-nix.lib.evalModule pkgs (
      _: {
        # Used to find the project root
        projectRootFile = "flake.nix";

        programs = {
          # Github Actions
          actionlint.enable = true;
          pinact.enable = true;
          zizmor.enable = true;

          # Bash/shell scripts
          beautysh.enable = true;
          #shellcheck.enable = true;
          shfmt.enable = true;

          biome.enable = true;

          deno.enable = true;

          jsonfmt.enable = true;

          keep-sorted.enable = true;

          # Enable the Nix formatter
          alejandra.enable = true;
          deadnix.enable = true;
          #nixf-diagnose.enable = true;
          #nixfmt.enable = true;
          #nixpkgs-fmt.enable = true;
          statix.enable = true;

          # YAML
          yamlfmt.enable = true;
          yamllint = {
            enable = true;
            settings = {
              extends = "default";
              ignore = [
                "secrets/*.yaml"
              ];

              rules = {
                line-length = {
                  max = 180;
                };
              };
            };
          };
        };
      }
    );
  in
    {
      homeConfigurations = (pkgs.builders.mkHome {}).configs;
      nixosConfigurations = pkgs.builders.mkNixos {};
    }
    // inputs.flake-utils.lib.eachDefaultSystem (_: {
      #out = {inherit pkgs overlays;};

      formatter = treefmt.config.build.wrapper;
      checks = {
        formatting = treefmt.config.build.check self;
        pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            #nixfmt.enable = true;
          };
        };
      };
    });
}
