_:
{
  services = {
    kavita.enable = true;
    kavita.tokenKeyFile = "/var/lib/kavita/key";

    calibre-server = {
      enable = true;
      openFirewall = true;
      libraries = ["/mnt/ebooks/Calibre/"];
    };

    calibre-web = {
      enable = true;
      openFirewall = true;
      listen.ip = "0.0.0.0";
      options.calibreLibrary = "/mnt/ebooks/Calibre/";
    };
  };

  networking.firewall.allowedTCPPorts = [5000];

  fileSystems.ebooks = {
    device = "192.168.42.4:/Storage/Media/eBooks";
    fsType = "nfs";
    mountPoint = "/mnt/ebooks";
  };
}
