# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/gui
    ../../modules/remoteBuild.nix
    ../../programs/1password-gui.nix
    ../../programs/bambu-studio.nix
    ../../programs/dotnet.nix
    ../../programs/jetbrains-gateway.nix
    ../../programs/proxmox-backup.nix
    ../../programs/sshd.nix
    #../../programs/steam.nix
    ../../programs/terraform

    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #networking.hostName = "argon"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking = {
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    wireguard.enable = true;

    hostName = "argon";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    cryptsetup
    kubectl
    kubectl-cnpg
    usbutils
    #cinny-desktop
    element-desktop
    #wireshark
    wine
    sbctl

    (pkgs.callPackage ../../programs/amazing-marvin {})
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services = {
    lvm.enable = true;

    # Enable sound.
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    resolved.enable = true;

    avahi.enable = true;
  };

  programs.wireshark = {
    enable = false;
    usbmon.enable = true;
  };

  # Make apps using sound get higher priority automatically
  security.rtkit.enable = true;

  sops.defaultSopsFile = ../../../secrets/argon.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # This is the actual specification of the secrets.
  sops.secrets.PBS_REPOSITORY = {};
  sops.secrets.PBS_PASSWORD = {};
  sops.secrets.PBS_FINGERPRINT = {};


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
