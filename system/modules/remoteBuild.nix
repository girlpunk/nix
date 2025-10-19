{pkgs, ...}: let
  sshConfig = pkgs.writeTextFile {
    name = "config";
    text = ''
      Host minos
              HostName 192.168.42.24
              # Prevent using ssh-agent or another keyfile, useful for testing
              IdentitiesOnly yes
              IdentityFile /root/.ssh/nixremote
              # The weakly privileged user on the remote builder – if not set, 'root' is used – which will hopefully fail
              User nixremote
    '';
  };
in {
  system.activationScripts.rootSshConfig = {
    text = ''
      ln -fs ${sshConfig} /root/.ssh/config
    '';
  };

  nix = {
    buildMachines = [
      {
        hostName = "minos";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [];
      }
    ];
    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
      substituters = [
        "ssh-ng://minos"
      ];
    };
  };
}
