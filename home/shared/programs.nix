let
  more =
    { inputs, pkgs, ... }:
    {
      programs = {
        #gpg.enable = true;

        jq.enable = true;

        # generate index with: nix-index --filter-prefix '/bin/'
        #nix-index-fork = {
        #  enable = true;
        #  #enableFishIntegration = true;
        #  enableNixCommand = true;
        #  database = pkgs.nix-index-database;
        #};

        # command-not-found only works with channels
        command-not-found.enable = false;
        nix-index.enable = true;

        ssh = {
          enable = true;
          controlMaster = "auto";
          controlPersist = "5m";
          addKeysToAgent = "yes";
          forwardAgent = true;

          matchBlocks = {
            "minos" = {
              hostname = "192.168.42.24";
              forwardAgent = true;
            };
            "10.101.15.2" = {
              forwardAgent = true;
            };
          };
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

        nh = {
          enable = true;
          # homeFlake = "~/programs/nix";
        };
      };

      services.ssh-agent.enable = false;
    };
in
[
  #../programs/dconf
  ../programs/git
  ../programs/statix
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
  ../programs/statix
  #nix-index-database.hmModules.nix-index
  more
]
