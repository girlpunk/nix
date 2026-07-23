_: {
  imports = [
    ../../../programs/postgresql.nix
  ];

  services.postgresql = {
    enableTCPIP = true;

    # host  all all ::1/128      md5
    authentication = ''
      host  all all 10.0.5.0/24 md5
    '';

    ensureDatabases = ["outline"];

    ensureUsers = [
      {
        name = "outline";
        ensureDBOwnership = true;
      }
    ];
  };

  #services.outline = {
  #  enable = true;
  #};

  #firewall.allowedTCPPorts = [3000];
}
