{config, ...}: {
  hardware.i2c.enable = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [ddcci-driver];
  boot.kernelModules = ["ddcci-backlight"];

  services.udev.extraRules = let
    bash = "${pkgs.bash}/bin/bash";
    ddcciDev = "i915 gmbus dpc";
    ddcciNode = "/sys/bus/i2c/devices/i2c-0/new_device";
  in ''
    SUBSYSTEM=="i2c", ACTION=="add", ATTR{name}=="${ddcciDev}", RUN+="${bash} -c 'sleep 30; printf ddcci\ 0x37 > ${ddcciNode}'"
  '';
}
