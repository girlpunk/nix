{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default

    ../../programs/dotnet.nix
    ../../programs/svglint.nix
    ../../programs/terraform
  ];

  system.stateVersion = "25.05";
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "sam";
    startMenuLaunchers = true;
  };

  services.openssh = {
    enable = lib.mkForce false;
  };

  environment.systemPackages = with pkgs; [
    git-filter-repo
    awscli2
    xdg-utils
    fontconfig
  ];

  virtualisation.docker.daemon.settings.iptables = false;

  systemd.units."wsl-mnt-guard.service".enable = false;
  # = {
  #  serviceConfig.ExecStart = lib.getExe' pkgs.coreutils "true";
  #};
}
