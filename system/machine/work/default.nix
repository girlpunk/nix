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
    docker-desktop.enable = true;
    startMenuLaunchers = true;
  };

  programs = {
    # nh = {
    #   osFlake = lib.mkForce "/mnt/d/nix#nixosConfigurations.work";
    #   homeFlake = lib.mkForce "/mnt/d/nix#homeConfigurations.sam@work.activationPackage";
    # };
  };

  services.openssh = {
    enable = lib.mkForce false;
  };

  environment.systemPackages = with pkgs; [
    git-filter-repo
    awscli2
  ];

  virtualisation.docker = {
    enable = lib.mkForce false;
  };
}
