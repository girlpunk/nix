_: {
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
      console_title_template = "{{ if .SSHSession }}󰌘 {{ .UserName }}@{{ .HostName }}: {{ .Folder }}{{ elseif .Root }}{{ .Folder }}{{ else }}{{ .UserName }}: {{ .Folder }}{{ end }}";
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          segments = [
            {
              properties = {
                cache_duration = "none";
              };
              leading_diamond = "";
              template = " {{ if .SSHSession }}󰌘 {{ end }}{{ if .Root }}{{else}}{{ .UserName }}@{{ end }}{{ .HostName }} ";
              foreground = "#ffffff";
              background = "#c386f1";
              type = "session";
              style = "diamond";
            }
            {
              properties = {
                cache_duration = "none";
              };
              trailing_diamond = "";
              template = "<parentBackground></>  ";
              foreground = "#111111";
              background = "#ffff66";
              type = "root";
              style = "diamond";
            }
            {
              properties = {
                cache_duration = "none";
                folder_separator_icon = "  ";
                home_icon = " ";
                mapped_locations = {
                  "/mnt/c/Users/Jacob" = "󰠦";
                  "/mnt/c/Users/Jacob/Programs" = "";
                  "/mnt/c/Users/SamM" = "󰠦";
                  "/mnt/c/Users/SamM/source/repos" = "";
                };
                style = "mixed";
              };
              template = "  {{ .Path }} ";
              foreground = "#ffffff";
              powerline_symbol = "";
              background = "#ff479c";
              type = "path";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                display_mode = "files";
              };
              template = " {{ if .Unsupported }}  {{ .Full }}{{ end }}";
              foreground = "#000000";
              powerline_symbol = "";
              background = "#00ffff";
              type = "dotnet";
              style = "powerline";
            }
            {
              properties = {
                branch_max_length = 25;
                cache_duration = "none";
                fetch_stash_count = true;
                fetch_status = true;
                fetch_upstream_icon = true;
              };
              leading_diamond = "";
              trailing_diamond = "";
              template = " {{ .UpstreamIcon }}{{ .HEAD }}{{ .BranchStatus }}{{ if .Working.Changed }} {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }}  {{ .StashCount }}{{ end }} ";
              foreground = "#193549";
              powerline_symbol = "";
              background = "#fffb38";
              type = "git";
              style = "powerline";
              background_templates = [
                "{{ if or (.Working.Changed) (.Staging.Changed) }}#FF9248{{ end }}"
                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#ff4500{{ end }}"
                "{{ if gt .Ahead 0 }}#B388FF{{ end }}"
                "{{ if gt .Behind 0 }}#B388FF{{ end }}"
              ];
            }
            {
              properties = {
                cache_duration = "none";
                fetch_version = true;
              };
              template = "  {{ if .PackageManagerIcon }}{{ .PackageManagerIcon }} {{ end }}{{ .Full }} ";
              foreground = "#ffffff";
              powerline_symbol = "";
              background = "#6CA35E";
              type = "node";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                fetch_version = true;
              };
              template = "  {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              foreground = "#111111";
              powerline_symbol = "";
              background = "#8ED1F7";
              type = "go";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                fetch_version = true;
              };
              template = "  {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              foreground = "#111111";
              powerline_symbol = "";
              background = "#4063D8";
              type = "julia";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                display_mode = "files";
                fetch_virtual_env = false;
              };
              template = "  {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              foreground = "#111111";
              powerline_symbol = "";
              background = "#FFDE57";
              type = "python";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                display_mode = "files";
                fetch_version = true;
              };
              template = "  {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              foreground = "#ffffff";
              powerline_symbol = "";
              background = "#AE1401";
              type = "ruby";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                display_mode = "files";
                fetch_version = false;
              };
              template = "{{ if not .IsDefault }}  {{.Name}} {{ end }}";
              foreground = "#ffffff";
              powerline_symbol = "";
              background = "#FEAC19";
              type = "az";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                display_mode = "files";
                fetch_version = false;
              };
              template = " {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ";
              foreground = "#ffffff";
              powerline_symbol = "";
              background = "#FEAC19";
              type = "azfunc";
              style = "powerline";
            }
            {
              properties = {
                cache_duration = "none";
                display_default = false;
              };
              template = "  {{ .Profile }}{{ if .Region }}@{{ .Region }}{{ end }} ";
              foreground = "#ffffff";
              powerline_symbol = "";
              type = "aws";
              style = "powerline";
              background_templates = [
                "{{if contains \"default\" .Profile}}#FFA400{{end}}"
                "{{if contains \"jan\" .Profile}}#f1184c{{end}}"
              ];
            }
            {
              properties = {
                always_enabled = true;
                cache_duration = "none";
                style = "round";
              };
              template = "<transparent></>  {{ .FormattedMs }} ";
              foreground = "#ffffff";
              background = "#83769c";
              type = "executiontime";
              style = "plain";
            }
            {
              properties = {
                always_enabled = true;
                cache_duration = "none";
              };
              trailing_diamond = "";
              template = "<parentBackground></> {{ if gt .Code 0 }}{{ else }}{{ end }} ";
              foreground = "#ffffff";
              background = "#00897b";
              type = "exit";
              style = "diamond";
              background_templates = [
                "{{ if ne .Code 0 }}#e91e63{{ end }}"
              ];
            }
          ];
        }
        {
          type = "rprompt";
          segments = [
            {
              properties = {
                cache_duration = "none";
              };
              template = "<#546E7A,transparent></> {{.Icon}}{{ if .WSL }} on {{ end }} <transparent,#546E7A></>";
              foreground = "#26C6DA";
              background = "#546E7A";
              type = "os";
              style = "plain";
            }
            {
              properties = {
                cache_duration = "none";
                paused_icon = " ";
                playing_icon = " ";
              };
              template = "  {{ .Icon }}{{ if ne .Status \"stopped\" }}{{ .Artist }} - {{ .Track }}{{ end }} ";
              foreground = "#111111";
              powerline_symbol = "";
              background = "#1BD760";
              type = "ytm";
              style = "powerline";
              invert_powerline = true;
            }
            {
              properties = {
                cache_duration = "none";
                charged_icon = " ";
                charging_icon = " ";
                discharging_icon = " ";
                display_error = true;
              };
              template = " {{ if not .Error }}{{ .Icon }}{{ .Percentage }}{{ end }}{{ .Error }} ";
              foreground = "#ffffff";
              powerline_symbol = "";
              background = "#f36943";
              type = "battery";
              style = "powerline";
              background_templates = [
                "{{if eq \"Charging\" .State.String}}#40c4ff{{end}}"
                "{{if eq \"Discharging\" .State.String}}#ff5722{{end}}"
                "{{if eq \"Full\" .State.String}}#4caf50{{end}}"
              ];
              invert_powerline = true;
            }
            {
              properties = {
                cache_duration = "none";
                template = "{{ if .Error }}{{ .Error }}{{ else }} {{ .SSID }} {{ .Signal }}% {{ .ReceiveRate }}Mbps{{ end }}";
              };
              foreground = "#222222";
              powerline_symbol = "";
              background = "#8822ee";
              type = "wifi";
              style = "powerline";
              background_templates = [
                "{{ if (lt .Signal 60) }}#DDDD11{{ else if (lt .Signal 90) }}#DD6611{{ else }}#11CC11{{ end }}"
              ];
            }
            {
              properties = {
                cache_duration = "none";
              };
              leading_diamond = "";
              trailing_diamond = "";
              template = " {{ .CurrentDate | date .Format }} ";
              foreground = "#111111";
              background = "#2e9599";
              type = "time";
              style = "diamond";
              invert_powerline = true;
            }
          ];
        }
      ];
      version = 3;
      final_space = true;
    };
  };
}
