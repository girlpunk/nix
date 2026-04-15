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
        maxJobs = 4;
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
  };
}
