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

    extensions = with pkgs.postgresql18Packages; [vectorchord pgvector];
    settings.shared_preload_libraries = [
      #"vectors.so"
      "vchord"
    ];

    ensureDatabases = ["immich"];

    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
  };
}
