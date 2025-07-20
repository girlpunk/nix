{ pkgs, inputs, ... }:

{
  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "i2c"
    ];
    openssh = {
      authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFygf49qzrMruoAeB/Y0RcpkTFGpTVpRr+bwRhDQIZzI sam@argon"];
    };
    shell = pkgs.zsh;
  };

  programs = {
    zsh = {
      enable = true;
      ohMyZsh.enable = true;
    };

    _1password.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    git = {
      enable = true;
    };
  };

  services.autofs = {
    autoMaster = let
      share = pkgs.writeScript "auto-share" ''
        #!/bin/bash

        # This file must be executable to work! chmod 755!

        # Automagically mount CIFS shares in the network, similar to
        # what autofs -hosts does for NFS.

        # Put a line like the following in /etc/auto.master:
        # /cifs  /etc/auto.smb --timeout=300
        # You'll be able to access Windows and Samba shares in your network
        # under /cifs/host.domain/share

        # "smbclient -L" is used to obtain a list of shares from the given host.
        # In some environments, this requires valid credentials.

        # This script knows 2 methods to obtain credentials:
        # 1) if a credentials file (see mount.cifs(8)) is present
        #    under /etc/creds/$key, use it.
        # 2) Otherwise, try to find a usable kerberos credentials cache
        #    for the uid of the user that was first to trigger the mount
        #    and use that.
        # If both methods fail, the script will try to obtain the list
        # of shares anonymously.

        key="$1"
        opts="-fstype=cifs"

        creds=/etc/nixos/smb-secret/$key
        if [ -f "$creds" ]; then
            opts="$opts"',uid=$UID,gid=$GID,credentials='"$creds"
            smbopts="-A $creds"
        fi

        smbclient $smbopts -gL "$key" 2>/dev/null| awk -v "key=$key" -v "opts=$opts" -F '|' -- '
                BEGIN   { ORS=""; first=1 }
                /Disk/  {
                          if (first)
                                print opts; first=0
                          dir = $2
                          loc = $2
                          # Enclose mount dir and location in quotes
                          print " \\\n\t \"/" dir "\"", "\"://" key "/" loc "\""
                        }
                END     { if (!first) print "\n"; else exit 1 }
                '

      '';
      top = "/media/juggernaut ${share} juggernaut --timeout 300 browse --ghost";
    in top;
    enable = false;
  };

  fileSystems."/media/juggernaut/TV" = {
    device = "//juggernaut.home.foxocube.xyz/Storage_Media_TV";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-secret/juggernaut"
      "x-systemd.automount"
      "noauto"
      "uid=1000" #${toString config.users.users.sam.uid}"
      "gid=100"
      "x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s"];
  };

  #nixpkgs.overlays = import ../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}
