{...}: {
  imports = [
    ../../programs/activitywatch
    ../../programs/android
    ../../programs/kubernetes-client
    ../../programs/opencode
    ../../programs/vscode
  ];

  programs.opencode = {
    settings = {
      model = "ollama/qwen3:30b";
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options = {
            baseURL = "http://127.0.0.1:11434/v1";
          };
          models = {
            "qwen3:30b" = {
              name = "Qwen 3 30B MoE (coding)";
            };
            "qwen3:8b" = {
              name = "Qwen 3 8B (fast)";
            };
          };
        };
      };
    };
  };

  # Serves the opencode web UI for browser access from other machines.
  # The password lives in ~/.config/opencode-web.env (0600) on minos, outside
  # the repo. The service stays down until that file exists.
  #systemd.user.services."opencode-web" = {
  #  description = "OpenCode web UI";
  #  after = ["network.target"];
  #  wantedBy = ["default.target"];

  #  serviceConfig = {
  #    ExecStart = "${pkgs.opencode}/bin/opencode web --hostname 0.0.0.0 --port 4096";
  #    WorkingDirectory = "${config.home.homeDirectory}";
  #    EnvironmentFile = "${config.home.homeDirectory}/.config/opencode-web.env";
  #    Restart = "always";
  #    RestartSec = 5;
  #  };
  #};
}
