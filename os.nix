{
  inputs,
  system,
  overlays,
  self,
  ...
}: let
  inherit (inputs.nixpkgs.lib) nixosSystem;

  pkgs = import inputs.nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  # Comprehensive flake metadata — shared by all builders so every host
  # (including WSL) can use modules/core/system-identification.nix.
  mkFlakeMeta = {
    hostname,
    system,
  }: {
    inherit hostname system;
    # Build information (reproducible)
    buildTime = 0; # Static to ensure reproducibility
    buildDate = "reproducible-build";
    flakeRev = self.rev or "dirty";
    flakeShortRev =
      if (self.rev or null) != null
      then builtins.substring 0 7 self.rev
      else "unknown";
    # Nixpkgs information
    nixpkgsRev = inputs.nixpkgs.rev or "unknown";
    nixpkgsShortRev =
      if (inputs.nixpkgs.rev or null) != null
      then builtins.substring 0 7 inputs.nixpkgs.rev
      else "unknown";
    # System identification
    configPath = toString ../.;
    hostPath = toString (../. + "/hosts/${hostname}");
  };

  hosts = [
    "argon"
    "minos"
    "mnemosyne"
    "work"
  ];

  modules = [
    inputs.disko.nixosModules.disko
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nix-index-database.nixosModules.nix-index
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    {nix.registry.nixpkgs.flake = inputs.nixpkgs;}
    ./system
  ];

  make = hostname: {
    ${hostname} = nixosSystem {
      inherit pkgs system;
      inherit (pkgs) lib;
      specialArgs = {
        inherit inputs;
        flakeMeta = mkFlakeMeta {inherit hostname system;};
      };
      modules =
        modules
        ++ [
          ./system/machine/${hostname}
          {
            networking.hostName = pkgs.lib.mkDefault "${hostname}";
          }
          ({flakeMeta, ...}: {
            # Make flake metadata available system-wide
            environment.etc."nixos/flake-metadata.json".text = builtins.toJSON flakeMeta;

            # Add metadata to system info
            environment.variables = {
              NIXOS_FLAKE_REV = flakeMeta.flakeShortRev;
              NIXOS_BUILD_DATE = flakeMeta.buildDate;
              NIXOS_HOSTNAME = flakeMeta.hostname;
            };

            # Add to system description
            system.nixos.tags = [
              flakeMeta.flakeShortRev
            ];
          })
        ];
    };
  };
in
  pkgs.lib.mergeAttrsList (map make hosts)
