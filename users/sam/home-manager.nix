{ isWSL, inputs, ... }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  sources = import ../../nix/sources.nix;

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  #manpager = (pkgs.writeShellScriptBin "manpager" ''cat "$1" | col -bx | bat --language man --style plain'');
in
{
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "24.05";

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;
    mouse = true;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      bind -n C-k send-keys "clear"\; send-keys "Enter"

      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      run-shell ${sources.tmux-dracula}/dracula.tmux
    '';
  };

  #programs.kitty = {
  #  enable = !isWSL;
  #  extraConfig = builtins.readFile ./kitty;
  #};

  gtk = {
    enable = true;
    cursorTheme.name = "";
    cursorTheme.size = 16;
    #theme = "";
  };

}
