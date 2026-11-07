{pkgs, ...}:
{
  programs.obsidian = {
    enable = true;

    vaults."Documents/Obsidian" = {
      enable = true;
    };

    defaultSettings = {
      communityPlugins = with pkgs.obsidianPlugins; [
        #meld-encrypt
        #obsidian-kanban
        #obsidian-latex-suite
        obsidian-livesync
      ];

      # corePlugins.sync.enable = false;
    };
  };
}
