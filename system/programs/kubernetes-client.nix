{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    kubectl
    kubectl-cnpg
  ];
}
