{pkgs, ...}: {
  users.users.nixremote = {
    group = "nixremote";
    extraGroups = [
    ];
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFOudaU90iN3Gw5oZn7F+B61TwngX1L1rMiKfJHzv3ik root@argon"
      ];
    };
    isSystemUser = true;
    homeMode = "555";
  };

  users.groups.nixremote = {};

  nix.settings.trusted-users = [
  ];
}
