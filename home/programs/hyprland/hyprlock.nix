_: let
  text_color = "rgba(FFFFFFFF)";
  entry_background_color = "rgba(33333311)";
  entry_border_color = "rgba(3B3B3B55)";
  entry_color = "rgba(FFFFFFFF)";
  font_family = "Rubik Light";
  font_family_clock = "Rubik Light";
  font_material_symbols = "Material Symbols Rounded";
in {
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
        color = "rgba(000000FF)";
      };

      input-field = {
        #monitor =
        size = "250, 50";
        outline_thickness = 3;

        dots_size = 0.26; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.64; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        #dots_rouding = -1

        #rounding = 22;
        outer_color = entry_border_color;
        inner_color = entry_background_color;
        font_color = entry_color;
        fade_on_empty = true;
        placeholder_text = ''<i>Password...</i>''; # Text rendered in the input box when it's empty.

        position = "0, 20";
        halign = "center";
        valign = "center";
      };

      label = [
        {
          # Clock
          #monitor =
          text = "$TIME";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = text_color;
          font_size = 65;
          font_family = font_family_clock;

          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        {
          # Date
          #monitor =
          text = ''cmd[update:18000000] echo "$(date +'%A %d %b')"'';
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = text_color;
          font_size = 20;
          inherit font_family;

          position = "0, 240";
          halign = "center";
          valign = "center";
        }

        {
          # lock icon
          #monitor =
          text = "  ";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = text_color;
          font_size = 21;
          font_family = font_material_symbols;

          position = "0, 65";
          halign = "center";
          valign = "bottom";
        }

        {
          # "locked" text
          #monitor =
          text = "locked";
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = text_color;
          font_size = 14;
          inherit font_family;

          position = "0, 45";
          halign = "center";
          valign = "bottom";
        }

        {
          # Status
          #monitor =
          text = ''cmd[update:5000] ${./hyprlock-status.sh}'';
          shadow_passes = 1;
          shadow_boost = 0.5;
          color = text_color;
          font_size = 14;
          inherit font_family;

          position = "30, -30";
          halign = "left";
          valign = "top";
        }
      ];
    };
  };
}
