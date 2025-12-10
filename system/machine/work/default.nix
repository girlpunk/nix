{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../programs/terraform
    ../../programs/dotnet.nix
  ];

  system.stateVersion = "25.05";
  wsl = {
    enable = true;
    defaultUser = "sam";
    docker-desktop.enable = true;
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
