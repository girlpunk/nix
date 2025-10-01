{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    resumeDevice = "/dev/dm-3";
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usb_storage"
        "uas"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "ideapad_laptop"
      ];
      kernelModules = [
        "dm-snapshot"
        "cryptd"
        "coretemp"
      ];

      verbose = false;
      systemd.enable = true;

      luks.devices = {
        cryptroot.device = "/dev/disk/by-uuid/57e38957-ca5a-45af-ad90-755bf814b0b7";
        #storage = {
        #  allowDiscards = true;
        #  device = "/dev/disk/by-uuid/dd17e735-fac4-467f-b1ee-8bb214bc2b08";
        #};
      };
    };

    kernelModules = ["i2c-dev"];
    extraModulePackages = [config.boot.kernelPackages.ddcci-driver];

    consoleLogLevel = 3;
    kernelParams = [
      "mem_sleep_default=deep"
      "pcie_aspm.policy=powersupersave"
      "i915.enable_guc=2"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    loader.timeout = 0;
  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  fileSystems = {
    "/" = {
      device = "/dev/main/root";
      fsType = "ext4";
    };

    "/nix" = {
      device = "/dev/main/nix-store";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/main/home";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/572C-8AA3";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/main/swap";}
  ];

  hardware = {
    bluetooth = {
      enable = lib.mkDefault true;
      powerOnBoot = true;
      settings = {
        General = {
          # Shows battery charge of connected devices on supported
          # Bluetooth adapters. Defaults to 'false'.
          Experimental = true;
          # When enabled other devices can connect faster to us, however
          # the tradeoff is increased power consumption. Defaults to
          # 'false'.
          FastConnectable = true;
        };
        Policy = {
          # Enable all controllers when they are found. This includes
          # adapters present on start as well as adapters that are plugged
          # in later on. Defaults to 'true'.
          AutoEnable = true;
        };
      };
    };
    sensor.iio.enable = true;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # your Open GL, Vulkan and VAAPI drivers
      #vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
      # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
      intel-media-sdk # for older GPUs
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };
  users.users.sam.extraGroups = ["tss"]; # tss group has access to TPM devices

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Force intel-media-driver

  powerManagement.enable = true;

  services = {
    thermald.enable = true;
    tlp.enable = true;

    logind = {
      lidSwitch = "hibernate";
      lidSwitchExternalPower = "hybrid-sleep";
      lidSwitchDocked = "hybrid-sleep";
    };

    upower = {
      enable = true;
    };

    blueman.enable = true;

    udev.extraRules = ''
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';
  };

  # VP9 decoding not supported when using intel-media-driver
  # https://github.com/intel/media-driver/issues/1024
  # NixOS Wiki recommends using the legacy intel-vaapi-driver with the hybrid codec over that one for Skylake.
  # https://wiki.nixos.org/wiki/Accelerated_Video_Playback
  #  hardware.intelgpu = {
  #    vaapiDriver = "intel-vaapi-driver";
  #    enableHybridCodec = true;
  #
  #    driver = "i915";
  #  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp4s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wwp0s20f0u2i12.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
