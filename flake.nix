{
  description = "Foxocube's NixOS configuration";

  inputs = {
    # Main repo for most packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # We want the newest version for some stuff, so that comes from here
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # WSL Compatibility
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

    # Nix linter
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules";
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
      _: let
        typos_config = (pkgs.formats.toml {}).generate "typos.toml" {
          files = {
            extend-exclude = ["secrets/*.yaml"];
          };

          default.extend-identifiers = {
            als = "als";
            authorizedKeys = "authorizedKeys";
            LS_COLORS = "LS_COLORS";
          };

          default.extend-words = {
            center = "center";
            color = "color";
            colored = "colored";
            colors = "colors";
            facter = "facter";
            maximize = "maximize";
          };
        };
      in {
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
          typos = {
            enable = true;
            locale = "en-gb";
            configFile = "${typos_config}";
          };

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
}
