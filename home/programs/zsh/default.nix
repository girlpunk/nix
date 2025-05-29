{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  programs.zsh = {
    enable = true;

    ohMyZsh = {
      enable = true;
      preLoaded = [
        # Do menu-driven completion.
        "zstyle ':completion:*' menu select"

        # Color completion for some things.
        # http://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
        "zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}"

        # formatting and messages
        # http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
        "zstyle ':completion:*' verbose yes"
        "zstyle ':completion:*:descriptions' format '$fg[yellow]%B--- %d%b'"
        "zstyle ':completion:*:messages' format '%d'"
        "zstyle ':completion:*:warnings' format '$fg[red]No matches for:$reset_color %d'"
        "zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'"
        "zstyle ':completion:*' group-name ''"

        # compinit location
        "zstyle :compinstall filename '$HOME/.zshrc'"
      ];
    };

    setOptions = [
      "INC_APPEND_HISTORY"

      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
    ];

    shellAliases = {
      config = "/usr/bin/git --git-dir ~/.cfg/ --work-tree ~";
    };

    enableBashCompletion = true;

    #TODO: Kubectl completion

  };

  programs.ssh.startAgent = true;

  initExtra = {
    fpath = ''
      (${config.xdg.configHome}/zsh/plugins/zsh-completions/src \
       ${config.xdg.configHome}/zsh/plugins/nix-zsh-completions \
       ${config.xdg.configHome}/zsh/vendor-completions \
       $fpath)
    '';
  };

  xdg.configFile."zsh/vendor-completions".source = with pkgs;
   runCommandNoCC "vendored-zsh-completions" {} ''
    mkdir -p $out
    ${fd}/bin/fd -t f '^_[^.]+$' \
      ${lib.escapeShellArgs home.packages} \
      --exec ${ripgrep}/bin/rg -0l '^#compdef' {} \
      | xargs -0 cp -t $out/
   '';

  programs.oh-my-zsh = {
    enable = true;
    plugins  = [];
    extraConfig = ''
      # Uncomment the following line to enable command auto-correction.
      ENABLE_CORRECTION="true";
      # Uncomment the following line to display red dots whilst waiting for completion.
      COMPLETION_WAITING_DOTS="true"
      zbell_ignore=($EDITOR $PAGER dotnet nano)
    '';
    plugins = [
      "1password"
      "colored-man-pages"
      "command-not-found"
      "docker"
      "docker-compose"
      "dotnet"
      "eza"
      #"git"
      "gitfast"
      "helm"
      "kitty"
      "lol"
      "pip"
      "pyenv"
      "safe-paste"
      "screen"
      "zbell"
      "history-substring-search"
      "zsh-autosuggestions"
      "zsh-syntax-highlighting"
      "tailscale"
      "z"
      "web-search"
      "terraform"
    ];

    #TODO: Disable sharehistory after omz has started
    #unsetopt sharehistory
  };

  programs.fastfetch = {
    enable = true;
    settings = lib.trivial.importJSON ./fastfetch.jsonc;
  };

  programs.hyfetch = {
    enable = true;
    settings = { };
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.trivial.importJSON ./oh-my-posh.json;
  };
}
