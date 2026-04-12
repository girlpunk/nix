{
  pkgs,
  lib,
  ...
}: let
  marvin-info = pkgs.writeShellScript "marvin-info.sh" ''
    TOKEN=$(cat /run/secrets/MARVIN)

    while true; do
      ${lib.getExe pkgs.curl} -s \
          -H "X-API-Token: $TOKEN" \
          http://localhost:12082/api/todayItems \
        | ${lib.getExe pkgs.jq} -c ".[0] | { text: .title, alt: .title }"
      ${lib.getExe' pkgs.coreutils "sleep"} 60
    done
  '';

  marvin-open = pkgs.writeShellScript "marvin-open.sh" ''
    TOKEN=$(cat /run/secrets/MARVIN)

    ${lib.getExe' pkgs.xdg-utils "xdg-open"} \
      $(
        ${lib.getExe pkgs.curl} -s \
          -H "X-API-Token: $TOKEN" \
          http://localhost:12082/api/todayItems | \
        ${lib.getExe pkgs.jq} -c "\"https://app.amazingmarvin.com/#t=\"+.[0]._id" -r
      )
  '';

  brightness-get = pkgs.writeShellScript "brightness.sh" ''
    while true; do
      ${lib.getExe pkgs.brightnessctl} -m | ${lib.getExe' pkgs.coreutils "head"} -n 1 | ${lib.getExe pkgs.gawk} -F',' '{print $4}' | ${lib.getExe pkgs.jq} -R -c "{ text: ., alt: . }"

      ${lib.getExe' pkgs.coreutils "sleep"} 1
    done
  '';
in {
  programs.ashell = {
    enable = true;
    systemd.enable = true;

    settings = {
      modules = {
        left = ["Workspaces" "Marvin"]; # "Marvin"
        center = ["WindowTitle"];
        right = ["SystemInfo" "Backlight" ["Clock" "Privacy" "Settings"] "Tray"]; # "Tray"
      };

      workspaces = {
        enable_workspace_filling = true;
        workspace_names = ["" "" "" "" ""];
      };

      system_info = {
        indicators = [
          # idle
          "DownloadSpeed"
          "UploadSpeed"
          "Temperature"

          #battery
          {Disk = "/home";}
          {Disk = "/nix";}
          "Cpu"
          "Memory"
          "MemorySwap"

          #wireplumber
        ];
      };

      clock = {
        format = "%e %H:%M";
      };

      CustomModule = [
        {
          name = "Marvin";
          icon = "󰚩 ";

          listen_cmd = "${marvin-info}";
          command = "${marvin-open}";
        }
        {
          name = "Backlight";
          type = "Text";
          command = "${brightness-get}";
          listen_cmd = "${brightness-get}";

          icons = {
            "^(\d|10|11)%$" = ""; #  0-11
            "^(1[2-9]|2[0-2])%$" = ""; # 12-22
            "^(2[3-9]|3[0-3])%$" = ""; # 23-33
            "^(3[4-9]|4[0-4])%$" = ""; # 34-44
            "^(4[5-9]|5[0-5])%$" = ""; # 45-55
            "^(5[6-9]|6[0-6])%$" = ""; # 56-66
            "^(6[7-9]|7[0-7])%$" = ""; # 67-77
            "^(7[8-9]|8[0-8])%$" = ""; # 78-88
            "^(89|9\d|100)%$" = ""; # 89-100
          };
        }
      ];

      appearance = {
        font_name = "FiraCode Nerd Font";
      };
    };
  };
}
