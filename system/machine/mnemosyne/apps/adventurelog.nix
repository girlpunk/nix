{pkgs, ...}: {
  imports = [
    ../../../programs/postgresql.nix
  ];

  services.postgresql = {
    enableTCPIP = true;

    # host  all all ::1/128      md5
    authentication = ''
      host  all all 10.0.5.0/24 md5
    '';

    extensions = with pkgs.postgresql18Packages; [postgis];

    ensureDatabases = ["adventurelog"];

    ensureUsers = [
      {
        name = "adventurelog";
        ensureDBOwnership = true;
      }
    ];
  };
}
