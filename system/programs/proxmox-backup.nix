{
  pkgs,
  lib,
  ...
}: {
  systemd = {
    timers.proxmox-backup = {
      wantedBy = ["timers.target"];

      timerConfig = {
        OnBootSec = 540;
        OnCalendar = "hourly";
        Unit = "proxmox-backup.service";
      };
    };
    services.proxmox-backup = {
      after = ["network-online.target"];
      requires = ["network-online.target"];
      serviceConfig.Type = "exec";

      script = ''
        export PBS_REPOSITORY=$(cat /run/secrets/PBS_REPOSITORY)
        # export PBS_NAMESPACE=$PBS_NAMESPACE
        export PBS_PASSWORD=$(cat /run/secrets/PBS_PASSWORD)
        export PBS_FINGERPRINT=$(cat /run/secrets/PBS_FINGERPRINT)

        ${lib.getExe pkgs.proxmox-backup-client} \
          backup argon.pxar:/ \
          --change-detection-mode=metadata \
          --keyfile=/run/secrets/PBS_KEY \
          --exclude="/home/*/.cache" \
          --exclude="/home/*/.dotnet" \
          --exclude="/home/*/.gem" \
          --exclude="/home/*/.gradle" \
          --exclude="/home/*/.gvfs" \
          --exclude="/home/*/.local/share/Trash" \
          --exclude="/home/*/.m2" \
          --exclude="/home/*/.node-gyp" \
          --exclude="/home/*/.npm" \
          --exclude="/home/*/.nuget" \
          --exclude="/home/*/.p2" \
          --exclude="/home/*/.platformio" \
          --exclude="/home/*/.rvm" \
          --exclude="**/node_modules" \
          --exclude=/tmp \
          --exclude=/var/cache \
          --exclude=/var/log \
          --include-dev=/home \
          --include-dev=/boot \
          --exclude=/media/juggernaut
      '';

      serviceConfig = {
        ExecStopPost = pkgs.writeShellScript "proxmox-notify.sh" ''
          msg="Backup: $SERVICE_RESULT"
          time="3000"
          if [ "$SERVICE_RESULT" != "success" ] ; then
            msg+=" $EXIT_CODE $EXIT_STATUS"
            time="20000"
          fi

          ${lib.getExe pkgs.sudo} -u sam env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${lib.getExe pkgs.notify-desktop} -t "$time" "$msg"
        '';

        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
  };
}
