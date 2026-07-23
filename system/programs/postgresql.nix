{pkgs, ...}: {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
    };

    postgresqlBackup = {
      enable = true;
    };
  };
}
