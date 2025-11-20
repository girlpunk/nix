{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    unstable.terraform
  ];
}
