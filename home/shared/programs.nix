let
  more = { pkgs, ... }: {
    programs = {
      gpg.enable = true;

      jq.enable = true;

      # generate index with: nix-index --filter-prefix '/bin/'
      nix-index-fork = {
        enable = true;
        enableFishIntegration = true;
        enableNixCommand = true;
        database = pkgs.nix-index-small-database;
      };

      # command-not-found only works with channels
      command-not-found.enable = false;

      ssh = {
        enable = true;
        controlMaster = "auto";
        controlPersist = "5m";
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ ];
      };

      #nano.enable = true;

      #_1password-cli = {
      #  enable = true;
      #};

      _1password-shell-plugins = {
        # enable 1Password shell plugins for bash, zsh, and fish shell
        enable = true;
        # the specified packages as well as 1Password CLI will be
        # automatically installed and configured to use shell plugins
        plugins = with pkgs; [
          gh
          glab
          #terraform
        ];
      };

      #nix-ld.enable = true;
      #nix-ld.libraries = with pkgs; [
      #  # Add any missing dynamic libraries for unpackaged programs
      #  # here, NOT in environment.systemPackages
      #  icu
      #  ncurses6
      #];
    };
  };
in
[
  #../programs/dconf
  ../programs/git
  #../programs/firefox
  #../programs/fish
  #../programs/khal
  #../programs/md-toc
  #../programs/mimeo
  #../programs/mpv
  ../programs/neofetch
  #../programs/neovim-ide
  #../programs/ngrok
  #../programs/signal
  #../programs/yubikey
  #../programs/zathura
  more
]
