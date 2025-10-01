{
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    history = {
      append = true;
      extended = true;
      ignoreDups = true;
      share = false;
    };

    historySubstringSearch.enable = true;

    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        # Uncomment the following line to enable command auto-correction.
        ENABLE_CORRECTION="true"

        # Uncomment the following line to display red dots whilst waiting for completion.
        # Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
        # See https://github.com/ohmyzsh/ohmyzsh/issues/5765
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
        #git
        "gitfast"
        "helm"
        "kitty"
        "lol"
        "pip"
        "pyenv"
        "safe-paste"
        "screen"
        "zbell"
        "zsh-syntax-highlighting"
        "tailscale"
        "z"
        "web-search"
        "terraform"
      ];
    };

    syntaxHighlighting.enable = true;

    completionInit = ''
      # compinit location
      zstyle :compinstall filename '$HOME/.zshrc'

      # Enable completion
      autoload -Uz compinit bashcompinit
      compinit
      bashcompinit

      # Do menu-driven completion.
      zstyle ':completion:*' menu select

      # Color completion for some things.
      # http://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # formatting and messages
      # http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
      zstyle ':completion:*' verbose yes
      zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
      zstyle ':completion:*:messages' format '%d'
      zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
      zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
      zstyle ':completion:*' group-name ""

      # If kubectl is installed, setup completion
      if command -v -- kubectl > /dev/null 2>&1; then
        source <(kubectl completion zsh)
      fi

      # If Terraform is installed, setup completion
      #if command -v -- terraform > /dev/null 2>&1; then
      #    complete -o nospace -C terraform terraform
      #fi

      # Add dotnet tools to path
      if [[ -d "$HOME/.dotnet/tools" ]]; then
        export PATH="$PATH:$HOME/.dotnet/tools"
      fi

      # If pipx is installed, register it
      if command -v -- pipx > /dev/null 2>&1; then
        eval "$(register-python-argcomplete pipx)"
      fi

      # If Azure CLI is installed, setup completion
      if [ -f "/mnt/c/Program Files/Microsoft SDKs/Azure/CLI2/Scripts/az.completion.sh" ]; then
        eval "$(register-python-argcomplete az)"
      fi

    '';

    enableCompletion = true;
    enableVteIntegration = true;

    initContent = let
      zshConfigEarlyInit = lib.mkOrder 1000 ''
        # Save history immidiately
        setopt incappendhistory
      '';
      zshConfig = lib.mkOrder 1500 ''
        eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ~/.config/oh-my-posh/config.json)"

        if command -v -- hyfetch > /dev/null 2>&1; then
          hyfetch
        else
          echo "No Hyfetch, no pretty logo :("
          fastfetch
        fi
      '';
    in
      lib.mkMerge [
        zshConfigEarlyInit
        zshConfig
      ];

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.1";
          hash = "sha256-vpTyYq9ZgfgdDsWzjxVAE7FZH4MALMNZIFyEOBLm5Qo=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          hash = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
      {
        name = "windows-terminal-zsh-integration";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "windows-terminal-zsh-integration";
          rev = "master";
          hash = "sha256-wTGiJFnj3fN4a9Vsc5PPl5vBgvVLJbak0AN3t7RE4B8=";
        };
      }
    ];
  };
}
