{ ... }:
{
  users.users.root.packages = [  
    (pkgs.writeTextFile {  
      name = "/root/.ssh/config";
      text = ''
        Host minos
                # Prevent using ssh-agent or another keyfile, useful for testing
                IdentitiesOnly yes
                IdentityFile /root/.ssh/nixremote
                # The weakly privileged user on the remote builder – if not set, 'root' is used – which will hopefully fail
                User nixremote
      '';
    })
  ];

  nix = {
    buildMachines = [{
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
    }];
    distributedBuilds = true;
    nix.settings = {
      builders-use-substitutes = true;
    };
  };
}
