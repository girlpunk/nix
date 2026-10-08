{
  lib,
  pkgs,
  ...
}: let
  jsonFormat = pkgs.formats.json {};

  # oh-my-openagent (OMO) Ultimate edition for opencode. Statically
  # replicates `bunx oh-my-openagent install --platform=opencode`:
  # plugin entries in opencode.json/tui.json plus the
  # oh-my-openagent.jsonc model routing generated here.
  omo = {
    version = "4.19.4";
    model = "litellm/qwen3.8-27b";
    agents = [
      "sisyphus"
      "hephaestus"
      "prometheus"
      "oracle"
      "librarian"
      "explore"
      "multimodal-looker"
      "metis"
      "momus"
      "atlas"
      "sisyphus-junior"
    ];
    categories = [
      "visual-engineering"
      "artistry"
      "ultrabrain"
      "deep"
      "quick"
      "unspecified-high"
      "unspecified-low"
      "writing"
    ];
  };

  # Cache the shell-strategy instructions in the Nix store: opencode reads
  # the store path at runtime instead of fetching GitHub (offline, pinned,
  # hash-verified — a silent upstream change breaks the build instead of
  # silently changing your prompt).
  shellStrategy = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/JRedeker/opencode-shell-strategy/trunk/shell_strategy.md";
    hash = "sha256-RmQUsa5DuhcVn+oSzRFC8rrdAPEqFjqqP1x8dOvpdzw=";
  };
in {
  programs.opencode = {
    enable = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";

      # opencode auto-installs the npm plugins listed here at startup.
      plugin = [
        "oh-my-openagent@${omo.version}"
        "@mohak34/opencode-notifier@latest"

        "@tarquinen/opencode-dcp@3.2.0" # context pruning"
        [
          "@plannotator/opencode@0.27.17" # visual plan review
          {
            workflow = "plan-agent";
            planningAgents = omo.agents;
          }
        ]
        "opencode-vibeguard@0.1.0" # secret redaction
      ];

      instructions = ["${shellStrategy}"];

      lsp = true;

      compaction = {
        auto = true;
        reserved = 170000;
      };

      permission = {
        bash = {
          "*" = "ask";
          "awk *" = "allow";
          "diff *" = "allow";
          "echo *" = "allow";
          "find *" = "allow";
          "file *" = "allow";
          "git grep *" = "allow";
          "git show *" = "allow";
          "git status *" = "allow";
          "grep *" = "allow";
          "head *" = "allow";
          "jq *" = "allow";
          "ls *" = "allow";
          "sed *" = "allow";
          "which *" = "allow";
        };
        webfetch = "ask";
        websearch = "ask";
      };
    };

    tui = {
      attention = {
        enabled = true;
      };

      # The OMO installer mirrors the plugin entry into tui.json too.
      plugin = ["oh-my-openagent@${omo.version}"];
    };
  };

  home.packages = with pkgs; [
    bintools
    xxd
    pkgs.unstable.codegraph
  ];

  xdg.configFile = {
    # OMO model routing (the oh-my-openagent.jsonc the installer would
    # generate). No paid provider subscriptions, so every agent and
    # category runs on the local LiteLLM model.
    "opencode/oh-my-openagent.jsonc".source = jsonFormat.generate "oh-my-openagent.jsonc" (
      {
        "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
        # Keep the Nix pin authoritative: no runtime self-update.
        auto_update = false;
        telemetry = false;
      }
      // {
        agents = lib.listToAttrs (lib.map (name: {
            inherit name;
            value =
              if name == "hephaestus"
              then {
                inherit (omo) model;
                # GPT-native agent: explicitly allow non-GPT models.
                allow_non_gpt_model = true;
              }
              else {
                inherit (omo) model;
              };
          })
          omo.agents);

        categories = lib.listToAttrs (lib.map (name: {
            inherit name;
            value = {inherit (omo) model;};
          })
          omo.categories);
      }
    );


    "opencode/opencode-notifier.json".source = jsonFormat.generate "opencode.json" {
      bell = true;
    };

    # Vibeguard redacts secrets before LLM calls; it is a no-op without this
    # file (global lookup path is ~/.config/opencode/vibeguard.config.json).
    "opencode/vibeguard.config.json".source = jsonFormat.generate "vibeguard.config.json" {
      enabled = true;
      debug = false;
      placeholder_prefix = "__VG_";
      session = {
        ttl = "1h";
        max_mappings = 100000;
      };
      patterns = {
        # Add literal sensitive values here (e.g. Qualys password, connection
        # strings from local.settings.json).
        keywords = [
          {
            value = "REPLACE-ME-WITH-SECRET-VALUE";
            category = "QUALYS_SECRET";
          }
        ];
        regex = [
          {
            pattern = "(?i)\\bServer=.*?;.*?Password=.*?\\b";
            category = "CONN_STRING";
          }
          {
            pattern = "sk-[A-Za-z0-9]{48}";
            category = "OPENAI_KEY";
          }
          {
            pattern = "(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]+";
            category = "GITHUB_TOKEN";
          }
          {
            pattern = "AKIA[0-9A-Z]{16}";
            category = "AWS_ACCESS_KEY";
          }
        ];
        builtin = ["email" "uuid" "ipv4" "mac"];
        exclude = ["example.com" "localhost" "127.0.0.1" "0.0.0.0"];
      };
    };

    # DCP accepts .json (or .jsonc) here; unset keys keep upstream defaults
    # (dedup + error purging on).
    "opencode/dcp.json".source = jsonFormat.generate "dcp.json" {
      enabled = true;
      pruneNotification = "minimal";
      compress = {
        permission = "allow";
        minContextLimit = 50000;
        maxContextLimit = 100000;
      };
    };

  };
}

