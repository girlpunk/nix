{
  config,
  pkgs,
  ...
}: {
  boot.extraModulePackages = with config.boot.kernelPackages; [
    usbip
  ];

  environment.systemPackages = with pkgs; [
    linuxPackages.usbip
  ];

  networking.firewall.allowedTCPPorts = [3240];
}
