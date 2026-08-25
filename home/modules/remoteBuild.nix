{
  pkgs,
  lib,
  ...
}: {
  nix = {
    package = lib.mkDefault pkgs.nix;
    buildMachines = [
      {
        hostName = "minos";
        protocol = "ssh-ng";
        maxJobs = 8;
        speedFactor = 2;
        #supportedFeatures = [
        #  "nixos-test"
        #  "benchmark"
        #  "big-parallel"
        #  "kvm"
        #];
        mandatoryFeatures = [];
      }
    ];
    distributedBuilds = true;

    # Home Manager writes these verbatim to the user-level nix.conf, which
    # *replaces* the system-level list, so the full substituter set (public
    # caches + minos hot + NFS cold) and trust settings must be given here.
    settings = {
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://channable-public.cachix.org"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
        "ssh-ng://minos"
        "http://192.168.42.24:8000/"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
        "ssh-ng://minos"
        "http://192.168.42.24:8000/"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "minos:wcHt079XZRopdL7wy1aeBjkgE82Vmz1K9n8WpsOgZsY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
