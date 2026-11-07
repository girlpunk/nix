{
  description = "Foxocube's NixOS configuration";

  inputs = {
    # Main repo for most packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # We want the newest version for some stuff, so that comes from here
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # WSL Compatibility
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-26.05";

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
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";

      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:nix-community/lanzaboote/v1.2.0";

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

    obsidian-extensions = {
      url = "github:karaolidis/nix-obsidian-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
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
    systems = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    treefmt = forAllSystems (
      system:
        inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system}
        {
          # Used to find the project root
          projectRootFile = "flake.nix";

          programs = {
            # Github Actions
            actionlint.enable = true;
            pinact.enable = true;
            zizmor.enable = true;

            # Bash/shell scripts
            beautysh.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;

            biome.enable = true;

            deno.enable = true;

            jsonfmt.enable = true;

            keep-sorted.enable = true;

            # Enable the Nix formatter
            alejandra.enable = true;
            deadnix.enable = true;
            nixf-diagnose.enable = true;
            #nixfmt.enable = true;
            #nixpkgs-fmt.enable = true;
            statix.enable = true;

            mdformat.enable = true;
            prettier.enable = true;

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

    # Pre-commit hooks configuration (simplified for now)
    pre-commit-check = forAllSystems (
      system:
        inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            #nixfmt-rfc-style = {
            #  enable = true;
            #};
            statix.enable = true;
            shellcheck.enable = true;
          };
        }
    );

    overlays = import ./lib/overlays.nix {inherit inputs;};
  in {
    #homeConfigurations  = (pkgs.builders.mkHome  {}).configs;
    #nixosConfigurations =  pkgs.builders.mkNixos {};

    homeConfigurations =
      (import ./home.nix {
        inherit inputs overlays;
        system = "x86_64-linux";
      }).configs;
    nixosConfigurations = import ./os.nix {
      inherit inputs overlays self;
      system = "x86_64-linux";
    };

    formatter = forAllSystems (system: treefmt.${system}.config.build.wrapper);

    #inherit overlays;

    # Development shell for working on the template
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Nix development tools
            alejandra
            nixd # Nix language server: option completion + docs in your editor
            statix
            deadnix
            nh

            # Code quality tools
            pkgs.treefmt
            pre-commit

            # Shell scripting tools
            shellcheck
            shfmt

            # Documentation tools
            markdownlint-cli

            # Development utilities
            git
            fzf
            jq

            # Hardware detection
            pciutils
            usbutils
            lshw
          ];

          # Combined shell hook
          shellHook = ''
            echo "🚀 NixOS Template Development Environment"
            echo ""
            echo "📋 Available commands:"
            echo "  nix fmt           - Format Nix code"
            echo "  nh --help         - Better NixOS system management"
            echo ""
            echo "🔧 Development tools loaded:"
            echo "  alejandra, statix, deadnix, shellcheck, pre-commit"
            echo ""

            # Hooks are installed by git-hooks.nix below. There is deliberately
            # no `pre-commit install` here: it read a separate
            # .pre-commit-config.yaml and raced this shellHook for
            # .git/hooks/pre-commit, so the repository had two competing hook
            # sets and the one CI does not check usually won.
            ${pre-commit-check.${system}.shellHook or ""}
          '';
        };
      }
    );

    checks = forAllSystems (system: {
      # Pre-commit hooks check
      pre-commit-check = pre-commit-check.${system};

      # Treefmt formatting check
      treefmt = treefmt.${system}.config.build.check self;

      # Statix linting
      statix-check = nixpkgs.legacyPackages.${system}.runCommand "statix-check" {} ''
        cd ${self}
        ${nixpkgs.legacyPackages.${system}.statix}/bin/statix check .
        touch $out
      '';

      # Deadnix check
      deadnix-check = nixpkgs.legacyPackages.${system}.runCommand "deadnix-check" {} ''
        cd ${self}
        ${nixpkgs.legacyPackages.${system}.deadnix}/bin/deadnix --fail .
        touch $out
      '';

      # Shell script validation. `-S warning` keeps real problems failing the
      # build while ignoring info-level notes such as SC2016, which fires on
      # help text that deliberately prints a literal `$USER`.
      #shellcheck-check = nixpkgs.legacyPackages.${system}.runCommand "shellcheck-check" { } ''
      #  cd ${self}
      #  ${nixpkgs.legacyPackages.${system}.shellcheck}/bin/shellcheck **/*.sh
      #  touch $out
      #'';
    });
  };
}
