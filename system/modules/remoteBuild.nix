{pkgs, ...}: let
  ### N.B. STEPS REQUIRED TO MAKE THIS WORK
  # 1. sudo ssh-keygen -f /root/.ssh/nixremote -t ed25519
  # 2. sudo cat /root/.ssh/nixremote.pub
  # 3. Take key and put it in system/machine/minos/build-user.nix
  # 4. Commit and push, then rebuild minos
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
        maxJobs = 8;
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
