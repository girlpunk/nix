{...}: {
  imports = [
    ./zsh.nix
    ./oh-my-posh.nix
  ];

  programs.nix-your-shell = {
    enable = true;
    enableZshIntegration = true;
  };
}
