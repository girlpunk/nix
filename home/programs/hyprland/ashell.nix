{
  pkgs,
  lib,
  ...
}: let
  marvin-info = pkgs.writeShellScript "marvin-info.sh" ''
    TOKEN=$(cat /run/secrets/MARVIN)

    #echo -n "󰚩 "
    ${lib.getExe pkgs.curl} -s \
        -H "X-API-Token: $TOKEN" \
        http://localhost:12082/api/todayItems \
      | ${lib.getExe pkgs.jq} -c ".[0] | { text: .title, alt: .title }"
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
in {
  programs.ashell = {
    enable = true;
    systemd.enable = true;

    settings = {
      modules = {
        left = ["Workspaces" "Marvin"]; # "Marvin"
        center = ["WindowTitle"];
        right = ["SystemInfo" ["Clock" "Privacy" "Settings"] "Tray"]; # "Tray"
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
          #backlight

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
      ];

      appearance = {
        font_name = "FiraCode Nerd Font";
      };
    };
  };
}
