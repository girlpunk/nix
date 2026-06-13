_: {
  imports = [
    ../../../programs/postgresql.nix
  ];

  services.postgresql = {
    enableTCPIP = true;

    ensureDatabases = ["mediafeeder"];

    ensureUsers = [
      {
        name = "mediafeeder";
        ensureDBOwnership = true;
      }
    ];
  };
}
