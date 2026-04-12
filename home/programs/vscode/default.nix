{
  pkgs,
  lib,
  ...
}: {
  programs.vscode = {
    enable = true;
    profiles.default = {
      userSettings = {
        # Updates
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "update.mode" = "none";

        # Colours and Interface
        "editor.fontFamily" = "'FiraCode Nerd Font', 'Fira Code', monospace";
        "terminal.integrated.fontLigatures.enabled" = true;
        "editor.fontLigatures" = true;

        # Terminals
        "terminal.integrated.profiles.linux" = {
          "zsh" = {
            "path" = "zsh";
          };
          "pwsh" = {
            "path" = "pwsh";
            "icon" = "terminal-powershell";
          };
        };
        "terminal.integrated.defaultProfile.linux" = "zsh";

        # Kubernetes
        "vscode-kubernetes.kubectl-path" = lib.getExe pkgs.kubectl;
        "vs-kubernetes" = {
          "vs-kubernetes.crd-code-completion" = "enabled";
        };

        # Nix
        "nix.formatterPath" = lib.getExe pkgs.nixpkgs-fmt;
        "nix.serverPath" = lib.getExe pkgs.nil;
        "nix.enableLanguageServer" = false;

        # Python
        "python.analysis.autoImportCompletions" = true;
        "python.analysis.inlayHints.callArgumentNames" = "partial";
        "python.analysis.inlayHints.functionReturnTypes" = true;
        "python.analysis.inlayHints.variableTypes" = true;
        "python.analysis.typeCheckingMode" = "basic";
        "python.defaultInterpreterPath" = lib.getExe pkgs.python3;
        "python.languageServer" = "Pylance";

        # Debloat
        "chat.disableAIFeatures" = true;
        "chat.agent.enabled" = false;
        "chat.commandCenter.enabled" = false;
        "telemetry.feedback.enabled" = false;
        "geminicodeassist.enableTelemetry" = false;
      };
      extensions = with pkgs.vscode-extensions;
        [
          ms-vscode-remote.remote-containers
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-ssh-edit
          ms-vsliveshare.vsliveshare
          kamadorueda.alejandra

          #asciidoctor.asciidoctor-vscode
          pkgs.vscode-extensions."4ops".terraform
          mechatroner.rainbow-csv
          #redhat.vscode-xml

          ms-kubernetes-tools.vscode-kubernetes-tools
          redhat.vscode-yaml
          ms-azuretools.vscode-docker

          jnoortheen.nix-ide
          arrterian.nix-env-selector
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "aw-watcher-vscode";
            publisher = "activitywatch";
            version = "0.5.0";
            hash = "sha256-OrdIhgNXpEbLXYVJAx/jpt2c6Qa5jf8FNxqrbu5FfFs=";
          }
        ];
    };
  };
}
