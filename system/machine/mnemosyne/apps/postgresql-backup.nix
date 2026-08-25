{
  config,
  pkgs,
  ...
}: let
  retentionDays = 14;
in {
  systemd = {
    tmpfiles.rules = [
      "d /var/backup/postgresql 0750 postgres postgres -"
    ];

    services.postgresql-backup = {
      description = "Back up each Postgres database, keep ${toString retentionDays} days";

      requires = ["postgresql.service"];
      after = ["postgresql.service"];

      path = [
        pkgs.coreutils
        pkgs.findutils
        config.services.postgresql.package
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Nice = 10;
      };

      script = ''
        set -euo pipefail

        DEST=/var/backup/postgresql
        TODAY=$(date +%F)

        umask 0077

        # Remove leftovers from the old all-databases-in-one-file setup
        rm -f "$DEST"/all.sql*

        # Dump each database individually, two at a time
        psql -At -c "SELECT datname FROM pg_database WHERE datistemplate = false" \
          | xargs -r -d '\n' -P 2 -I {} pg_dump -Fc -Z 7 -f "$DEST/{}.$TODAY.dump" "{}"

        find "$DEST" -name '*.dump' -mtime +${toString retentionDays} -delete
      '';
    };

    timers.postgresql-backup = {
      wantedBy = ["timers.target"];

      timerConfig = {
        OnCalendar = "01:15";
        Persistent = true;
      };
    };
  };
}
