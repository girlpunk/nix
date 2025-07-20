{ ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        grace = 10;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = {
        #monitor =
        #path = /usr/share/backgrounds/archlinux/split.png
        color = "rgba(25, 20, 20, 1.0)";

        # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
        blur_passes = 2; # 0 disables blurring
        blur_size = 5;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };

      input-field = {
        #monitor =
        size = "250, 50";
        outline_thickness = 3;

        dots_size = 0.26; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.64; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        #dots_rouding = -1

        rounding = 22;
        outer_color = "rgb(ffffff)";
        inner_color = "rgb(000000)";
        font_color = "rgb(170, 170, 170)";
        fade_on_empty = true;
        placeholder_text = ''<i>Password...</i>''; # Text rendered in the input box when it's empty.

        position = "0, 120";
        halign = "center";
        valign = "bottom";
      };

      # Hours
      label = [
        {
          #monitor =
          text = ''cmd[update:1000] echo "<b><big> $(date +"%H") </big></b>"'';
          #color = $color6
          font_size = 112;
          font_family = "Geist Mono 10";
          shadow_passes = 3;
          shadow_size = 4;

          position = "0, 220";
          halign = "center";
          valign = "center";
        }

        # Minutes
        {
          #monitor =
          text = ''cmd[update:1000] echo "<b><big> $(date +"%M") </big></b>"'';
          #color = $color6
          font_size = 112;
          font_family = "Geist Mono 10";
          shadow_passes = 3;
          shadow_size = 4;

          position = "0, 80";
          halign = "center";
          valign = "center";
        }

        # Today
        {
          #monitor =
          text = ''cmd[update:18000000] echo "<b><big> $(date +'%A') </big></b>"'';
          #color = $color7
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font 10";

          position = "0, -160";
          halign = "center";
          valign = "center";
        }

        # Week
        {
          #monitor =
          text = ''cmd[update:18000000] echo "<b> $(date +'%d %b') </b>"'';
          #color = $color7
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font 10";

          position = "0, -200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
