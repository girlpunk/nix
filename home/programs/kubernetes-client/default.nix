{
  lib,
  pkgs,
  ...
}: let
  kubectl-zsh-completion =
    pkgs.runCommand "kubectl-zsh-completion" {
      nativeBuildInputs = [pkgs.kubectl];
    } ''
      mkdir -p $out
      kubectl completion zsh > $out/kubectl.zsh
    '';

  cnpgCompletions = pkgs.writeShellScriptBin "kubectl_complete-cnpg" ''
    # Call the __complete command passing it all arguments
    kubectl cnpg __complete "\$@"
  '';
in {
  home.packages = [
    pkgs.kubectl
    pkgs.kubectl-cnpg
    cnpgCompletions
  ];

  # Sourced after oh-my-zsh's compinit (which runs at mkOrder 800), so
  # the `compdef` call in the generated script works
  programs.zsh.initContent = lib.mkOrder 850 ''
    source ${kubectl-zsh-completion}/kubectl.zsh
  '';
}
