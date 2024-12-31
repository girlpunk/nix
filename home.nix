{ lib, config, pkgs, ... }:

{
  home = {
    #packages = with pkgs; [
    #  hello
    #];

    # This needs to actually be set to your username
    username = "sam";
    homeDirectory = "/home/sam";

    # You do not need to change this if you're reading this in the future.
    # Don't ever change this after the first build.  Don't ask questions.
    stateVersion = "24.05"; # Please read the comment before changing.
  };
}

#  home.language.base = "en_GB";

#  editorconfig = {
#    enable = true;
#    settings = {};
#  };

#  fonts.fontconfig = {
#    enable = true;
#    defaultFonts.monospace = [ "FiraCode NerdFont" ]
#  };

#  gtk = {
#    enable = true;
#    cursorTheme.name = "";
#    cursorTheme.size = 16;
#    theme = "";
#  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sam/etc/profile.d/hm-session-vars.sh
  #
#  home.sessionVariables = {
    # EDITOR = "emacs";
#  };

  # Let Home Manager install and manage itself.
#  programs.home-manager.enable = true;
#}
