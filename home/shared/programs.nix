let
  more = {pkgs, ...}: {
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

      nix-index.enable = true;

      ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            controlPersist = "5m";
            controlMaster = "auto";
            addKeysToAgent = "yes";
            forwardAgent = true;

            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlPath = "~/.ssh/master-%r@%n:%p";
          };
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
        options = [];
      };

      #nano.enable = true;

      #_1password-cli = {
      #  enable = true;
      #};

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
in [
  more
  #nix-index-database.hmModules.nix-index
  #../programs/dconf
  #../programs/firefox
  #../programs/fish
  ../programs/git
  #../programs/khal
  #../programs/md-toc
  #../programs/mimeo
  #../programs/mpv
  ../programs/neofetch
  #../programs/neovim-ide
  #../programs/ngrok
  #../programs/signal
  ../programs/statix
  #../programs/yubikey
  #../programs/zathura
]
