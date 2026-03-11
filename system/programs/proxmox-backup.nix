{pkgs, config, ...}: {
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

        ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client \
          backup argon.pxar:/ \
          --change-detection-mode=metadata \
          --keyfile=/run/secrets/PBS_KEY \
          --exclude="/home/*/.cache" \
          --exclude=/var/cache \
          --exclude=/tmp \
          --exclude=/var/log \
          --exclude="/home/*/.local/share/Trash" \
          --exclude="/home/*/.gvfs" \
          --exclude="**/node_modules" \
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

          ${pkgs.sudo}/bin/sudo -u sam env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${pkgs.notify-desktop}/bin/notify-desktop -t "$time" "$msg"
        '';

        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
  };
}
