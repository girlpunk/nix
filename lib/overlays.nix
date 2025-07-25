{ inputs, system }:

let
  # nixos-version needs this to work with flakes
  libVersionOverlay = import "${inputs.nixpkgs}/lib/flake-version-info.nix" inputs.nixpkgs;

  libOverlay = f: p: rec {
    libx = import ./. { inherit (p) lib; };
    lib =
      (p.lib.extend (
        _: _: {
          inherit (libx) exe removeNewline secretManager;
        }
      )).extend
        libVersionOverlay;
  };

  overlays = f: p: {
    #inherit (inputs.nix-index-database.packages.${system}) nix-index-database nix-index-small-database;

    #inherit (inputs.nixpkgs-unstable.packages.${system}) jetbrains.resharper;

    builders = {
      mkHome =
        {
          pkgs ? f,
          extraHomeConfig ? { },
        }:
        import ../home.nix {
          inherit
            extraHomeConfig
            inputs
            pkgs
            system
            ;
        };

      mkNixos =
        {
          pkgs ? f,
          extraSystemConfig ? { },
        }:
        import ../os.nix {
          inherit
            extraSystemConfig
            inputs
            pkgs
            system
            ;
        };
    };

    nix-search = inputs.nix-search.packages.${system}.default;

    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    treesitterGrammars =
      ts:
      ts.withPlugins (p: [
        p.tree-sitter-scala
        p.tree-sitter-c
        p.tree-sitter-nix
        p.tree-sitter-elm
        p.tree-sitter-haskell
        p.tree-sitter-python
        p.tree-sitter-rust
        p.tree-sitter-markdown
        p.tree-sitter-markdown-inline
        p.tree-sitter-comment
        p.tree-sitter-toml
        p.tree-sitter-make
        p.tree-sitter-tsx
        p.tree-sitter-typescript
        p.tree-sitter-html
        p.tree-sitter-javascript
        p.tree-sitter-css
        p.tree-sitter-graphql
        p.tree-sitter-json
        p.tree-sitter-smithy
      ]);

    xargs = {
      inherit (inputs) gh-md-toc penguin-fox;
      addons = f.nur.repos.rycee.firefox-addons;
    };

    package = inputs.hyprland.packages.${inputs.pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${inputs.pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  };
in
[
  libOverlay
  overlays
  #inputs.nix-index.overlays.${system}.default
  #inputs.nurpkgs.overlays.default
  #inputs.neovim-flake.overlays.${system}.default
  inputs.statix.overlays.default
  #(import ../home/overlays/bat-lvl)
  #(import ../home/overlays/bazecor)
  #(import ../home/overlays/hypr-monitor-attached)
  #(import ../home/overlays/juno-theme)
  #(import ../home/overlays/pyprland)
  #(import ../home/overlays/ranger)
  #(import ../home/overlays/zoom)
]
