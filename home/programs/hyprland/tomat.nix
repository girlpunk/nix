{
  pkgs,
  lib,
  ...
}: let
  package = pkgs.unstable.tomat;
  tomat-info = pkgs.writeShellScript "tomat-info.sh" ''
    while true; do
      ${lib.getExe package} status | ${lib.getExe pkgs.jq} -c ". | {text: .text, alt: .tooltip, class: .class, tooltip: .tooltip, percentage: .percentage}"

      sleep 1
    done
  '';
in {
  services = {
    tomat = {
      enable = true;
      inherit package;
      settings = {
        # Timer durations and behaviour
        timer = {
          # Work session duration in minutes
          work = 25.0;

          # Break duration in minutes
          break = 5.0;

          # Long break duration in minutes
          long_break = 15.0;

          # Number of work sessions before long break
          sessions = 4;

          # Auto-advance mode: "none", "all", "to-break", "to-work"
          auto_advance = "none";
        };

        # Sound notifications
        sound = {
          enabled = true; # Enable sound notifications
          system_beep = false; # Use system beep instead of sound files
          use_embedded = true; # Use embedded sound files
          volume = 0.5; # Volume level (0.0 to 1.0)
          # Optional: Custom sound files (will override embedded sounds)
          # work_to_break = "/path/to/custom/work-to-break.wav"
          # break_to_work = "/path/to/custom/break-to-work.wav"
          # work_to_long_break = "/path/to/custom/work-to-long-break.wav"
        };

        # Desktop notifications
        notification = {
          enabled = true; # Enable desktop notifications
          icon = "auto"; # Icon mode: "auto" (embedded), "theme" (system), or "/path/to/icon.png"
          timeout = 5000; # Notification timeout in milliseconds
          urgency = "normal"; # Urgency level: "low", "normal", "critical"
          # Optional: Custom notification messages
          # work_message = "Break time! Take a short rest ☕"
          # break_message = "Back to work! Let's focus 🍅"
          # long_break_message = "Long break time! Take a well-deserved rest 🏖️"
        };

        # Display formatting
        display = {
          text_format = "{icon} {time} {state}"; # Text display template
        };
      };
    };

    mako.settings."app-name=Tomat" = {
      background-color = "#2d3748";
      text-color = "#ffffff";
      border-color = "#4a5568";
      default-timeout = 5000;
    };
  };

  programs.ashell = {
    settings = {
      modules = {
        center = ["Tomat"];
      };

      CustomModule = [
        {
          name = "Tomat";
          icon = "";
          listen_cmd = "${tomat-info}";
          command = "${lib.getExe package} toggle";
        }
      ];
    };
  };
}
