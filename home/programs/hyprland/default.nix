{pkgs, ...}: {
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./hyprpaper.nix
    ./hyprlock.nix
    ./waybar.nix
    ./kitty.nix
    ./gconf.nix
    ./fonts.nix
    ./cursor.nix
    ./rofi.nix
    ./wluma.nix
  ];

  home.packages = with pkgs; [
    rofi
    networkmanagerapplet
  ];

  xdg = {
    enable = true;
    portal.enable = true;

    mime.enable = true;
    mimeApps.enable = true;
    mimeApps.defaultApplications = {
      "x-scheme-handler/jetbrains-gateway" = "jetbrains-gateway.desktop";
    };
  };

  services = {
    arrpc.enable = true;
    activitywatch.enable = true;
    blueman-applet.enable = true;
    clipman.enable = true;

    darkman.enable = true;
    darkman.settings = {
      lat = 51.48;
      lng = -0.22;
      usegeoclue = true;
    };

    gammastep = {
      enable = true;
      latitude = 51.48;
      longitude = -0.22;
      provider = "geoclue2";
      tray = true;
    };

    hyprpolkitagent.enable = true;
    network-manager-applet.enable = true;
    poweralertd.enable = true;
    mako.enable = true;
    mako.settings = {
      font = "Fira Code Nerd Font 10";
      border-size = 2;
      icon-location = "top";
      margin = "25,10,10";

      "app-name=.cinny-wrapped" = {
        default-timeout = 15000;
      };
    };
    ssh-agent.enable = false;

    wob = {
      enable = true;
      #config.systemd.user.sockets.wob.Socket.ListenFIFO = "${config.xdg.dataHome}/wob.sock";
    };

    hyprsunset = {
      enable = true;
    };
  };

  #config.systemd.user.sockets.wob.Socket.ListenFIFO = "${config.xdg.dataHome}/wob.sock";

  programs = {
    firefox = {
      languagePacks = ["en-GB"];
      profiles.default = {
        # extensions.packages = pkgs.nur.repos.rycee.firefox-addons; [ ];
      };
      policies = {
        FirefoxHome = {
          SponsoredTopSites = false;
          SponsoredPocket = false;
          Highlights = false;
        };
        ExtensionSettings = {
          # 1Password – Password Manager
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
          };
          # Augmented Steam
          "{1be309c5-3e4f-4b99-927d-bb500eb4fa88}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/augmented-steam/latest.xpi";
          };
          # Auto Tab Discard
          "{c2c003ee-bd69-42a2-b0e9-6f34222cb046}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/auto-tab-discard/latest.xpi";
          };
          # Facebook Container
          "@contain-facebook" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/facebook-container/latest.xpi";
          };
          # Panorama Tab Groups
          "panorama-tab-groups@example.com" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/panorama-tab-groups/latest.xpi";
          };
          # Reddit Enhancement Suite
          "jid1-xUfzOsOFlzSOXg@jetpack" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
          };
          # ShareX
          "firefox@getsharex.com" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sharex/latest.xpi";
          };
          # SponsorBlock for YouTube - Skip Sponsorships
          "sponsorBlocker@ajay.app" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          };
          # SteamDB
          "firefox-extension@steamdb.info" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/steam-database/latest.xpi";
          };
          # Tab Counter
          "tab-counter@daawesomep.addons.mozilla.org" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tab-counter-webext/latest.xpi";
          };
          # Tampermonkey
          "firefox@tampermonkey.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tampermonkey/latest.xpi";
          };
          # The Camelizer
          "izer@camelcamelcamel.com" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/the-camelizer-price-history-ch/latest.xpi";
          };
          # uBlacklist
          "@ublacklist" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublacklist/latest.xpi";
          };
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          # Wappalyzer - Technology profiler
          "wappalyzer@crunchlabz.com" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/wappalyzer/latest.xpi";
          };
          # New Tab Override
          "newtaboverride@agenedia.com" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/new-tab-override/latest.xpi";
          };
        };
      };
    };
    ssh.matchBlocks."*".identityAgent = "~/.1password/agent.sock";
    git.settings.gpg.ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
  };
}
