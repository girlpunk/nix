{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    brightnessctl
    corefonts
    ddcutil
    geoclue2
    #greetd.tuigreet
    kitty
    nerd-fonts.fira-code
    vlc
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  #services.greetd = {
  #  enable = true;
  #  settings.default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  #};

  programs = {
    hyprland.enable = true;

    regreet = {
      enable = true;
    };

    firefox.enable = true;

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        kamadorueda.alejandra
        ms-vscode-remote.remote-ssh
        (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "aw-watcher-vscode";
            publisher = "activitywatch";
            version = "0.5.0";
            hash = "sha256-OrdIhgNXpEbLXYVJAx/jpt2c6Qa5jf8FNxqrbu5FfFs=";
          };

          meta = {
            description = "This extension allows ActivityWatch, the free and open-source time tracker, to keep track of the projects and programming languages you use in VS Code.";
            homepage = "https://github.com/ActivityWatch/aw-watcher-vscode";
            downloadPage = "https://marketplace.visualstudio.com/items?itemName=activitywatch.aw-watcher-vscode";
            #license = lib.licenses.unfree;
            #sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
            #maintainers = with lib.maintainers; [ xiaoxiangmoe ];
          };
        })
      ];
    };
  };

  boot.plymouth = {
    enable = true;
    font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFont-Regular.ttf";
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/128x128/apps/nix-snowflake.png";
  };

  services.geoclue2.enable = true;
}
