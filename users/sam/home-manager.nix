{ isWSL, inputs, ... }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  sources = import ../../nix/sources.nix;
x
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  #manpager = (pkgs.writeShellScriptBin "manpager" ''cat "$1" | col -bx | bat --language man --style plain'');
in
{
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
}
