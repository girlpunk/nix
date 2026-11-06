{inputs}: let
  # nixos-version needs this to work with flakes
  libVersionOverlay = import "${inputs.nixpkgs}/lib/flake-version-info.nix" inputs.nixpkgs;

  libOverlay = _f: p: rec {
    libx = import ./. {inherit (p) lib;};
    lib =
      (p.lib.extend (
        _: _: {
          inherit (libx) exe removeNewline secretManager;
        }
      )).extend
      libVersionOverlay;
  };

  overlays = f: p: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (p) system;
      config.allowUnfree = true;
    };

    treesitterGrammars = ts:
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
  };
in [
  libOverlay
  overlays
  #inputs.nurpkgs.overlays.default
  #inputs.statix.overlays.default
  #(import ../home/overlays/bat-lvl)
  #(import ../home/overlays/bazecor)
  #(import ../home/overlays/hypr-monitor-attached)
  #(import ../home/overlays/juno-theme)
  #(import ../home/overlays/pyprland)
  #(import ../home/overlays/ranger)
  #(import ../home/overlays/zoom)
]
