{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    proxmox-backup-client
  ];

  #services.onepassword-secrets.secrets.backup = {
  #  reference = "op://Homelab/Backups/${config.networking.hostName}";
  #  owner = "root";
  #};

  #sops.secrets."backup-script-env" = {
  #  sopsFile = "${inputs.secrets}/secrets/${config.networking.hostName}.enc.yaml";
  #};

  systemd = {
    timers.proxmox-backup = {
      name = "proxmox-backup.timer";
      wantedBy = ["timers.target"];

      timerConfig = {
        OnBootSec = 540;
        OnCalendar = "hourly";
        Unit = "proxmox-backup.service";
      };

      # RefuseManualStart=no
      # RefuseManualStop=no
    };
    services.proxmox-backup = {
      name = "proxmox-backup.service";
      after = ["network-online.target"];
      requires = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";

      script = ''
        export PBS_REPOSITORY=$(cat /run/secrets/PBS_REPOSITORY)
        # export PBS_NAMESPACE=$PBS_NAMESPACE
        export PBS_PASSWORD=$(cat /run/secrets/PBS_PASSWORD)
        export PBS_FINGERPRINT=$(cat /run/secrets/PBS_FINGERPRINT)

        ${pkgs.util-linux}/bin/prlimit --nofile=1024:1024 \
          ${pkgs.proxmox-backup-client}/bin/proxmox-backup-client \
            backup argon.pxar:/ \
            --change-detection-mode=metadata \
            --exclude="/home/*/.cache" \
            --exclude=/var/cache \
            --exclude=/tmp \
            --exclude=/var/log \
            --exclude="/home/*/.local/share/Trash" \
            --exclude="/home/*/.gvfs" \
            --include-dev=/home \
            --include-dev=/boot \
            --exclude=/media/juggernaut
      '';
    };
  };
}
