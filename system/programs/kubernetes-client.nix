{pkgs, ...}:
let
  cnpgCompletions = pkgs.writeShellScriptBin "kubectl_complete-cnpg" ''
    # Call the __complete command passing it all arguments
    kubectl cnpg __complete "\$@"
  '';

in
{
  environment.systemPackages = with pkgs; [
    kubectl
    kubectl-cnpg
    cnpgCompletions
  ];
}
