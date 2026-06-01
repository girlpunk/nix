{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.authentik.agent;

  version = "0.43.1";
  hash = "sha256-zR2tnKJ4I+UtAJjnGQk67Xa9xEtiN+wHHPHRJ0gR2dg=";
  src = pkgs.fetchzip {
    name = "authentik-platform-${version}";
    url = "https://github.com/goauthentik/platform/archive/refs/tags/v${version}.zip";
    inherit hash;
  };

  authentik-platform = pkgs.buildGo126Module {
    pname = "authentik-platform";
    inherit version src;

    vendorHash = "sha256-oFjyzMfPlavUfqvJ1kLzP9GEhwgqD5qUbUuB5wANjK8=";
    nativeBuildInputs = [pkgs.installShellFiles];
    ldflags = ["-X goauthentik.io/platform/pkg/meta.Version=${version} -X goauthentik.io/platform/pkg/meta.BuildHash=${hash} -X goauthentik.io/platform/pkg/meta.Tag=v${version}"];

    subPackages =
      [
        "./cmd/cli"
        "./cmd/agent_local"
        "./cmd/agent_system"
      ]
      ++ lib.optionals (cfg.browser.chrome.enable || cfg.browser.firefox.enable) ["./cmd/browser_support"];

    postBuild = ''
      mkdir "completions"

      $GOPATH/bin/cli completion "bash" > "completions/cli.bash"
      $GOPATH/bin/cli completion "fish" > "completions/cli.fish"
      $GOPATH/bin/cli completion "zsh" > "completions/cli.zsh"

      $GOPATH/bin/agent_system completion "bash" > "completions/agent_system.bash"
      $GOPATH/bin/agent_system completion "fish" > "completions/agent_system.fish"
      $GOPATH/bin/agent_system completion "zsh" > "completions/agent_system.zsh"
    '';

    postInstall =
      ''
        mv $out/bin/cli $out/bin/ak
        ln -s $out/bin/ak $out/bin/ak-vault
        installShellCompletion --cmd ak --bash ./completions/cli.bash --fish ./completions/cli.fish --zsh ./completions/cli.zsh

        mv $out/bin/agent_local $out/bin/ak-agent
        installShellCompletion --cmd ak-agent --bash ./completions/agent_system.bash --fish ./completions/agent_system.fish --zsh ./completions/agent_system.zsh

        mv $out/bin/agent_system $out/bin/ak-sysd
        mkdir -p $out/share/polkit-1/actions
        cp ./cmd/agent_local/package/linux/usr/share/polkit-1/actions/io.goauthentik.platform.policy $out/share/polkit-1/actions/io.goauthentik.platform.policy
      ''
      + (lib.optionalString (cfg.browser.chrome.enable || cfg.browser.firefox.enable) ''
        mv $out/bin/browser_support $out/bin/ak-browser-support
      '');

    meta = {
      description = "Authentik Platform authentication, Agent, CLI and other components";
      homepage = "https://goauthentik.io/";
      changelog = "https://github.com/goauthentik/platform/releases/tag/v${version}";
      license = [lib.licenses.mit];
      # TODO: When darwin
      #++ {
      #  fullName = "authentik Enterprise Edition (EE) license";
      #  url = "https://github.com/goauthentik/platform/blob/main/ee/LICENSE";
      #  free = false;
      #  redistributable = false;
      #};
      maintainers = ["foxocube"];
      mainProgram = "ak";
    };
  };

  authentik-browser = pkgs.buildNpmPackage {
    pname = "authentik-browser-ext";
    inherit src version;

    npmDepsHash = "";
    sourceRoot = "browser-ext";
    nativeBuildInputs = [pkgs.zip];

    postBuild = ''
      mkdir -p $out/chrome $out/firefox

      cp -r "browser-ext/images" "browser-ext/dist" "browser-ext/html" "$out/chrome"
      cp "browser-ext/manifest-chrome.json" "$out/chrome/manifest.json"
      pushd "$out/chrome"
        zip "$out/authentik_chrome.zip" -r *
      popd

      cp -r "browser-ext/images" "browser-ext/dist" "browser-ext/html" "$out/firefox"
      cp "browser-ext/manifest-firefox.json" "$out/firefox/manifest.json"
      pushd "$out/firefox"
        zip "$out/authentik_firefox.zip" -r *
      popd
    '';

    postCheck = ''
      npm run build-test
    '';
  };
in {
  options = {
    services.authentik = {
      agent = {
        enable = lib.mkEnableOption "Authentik agent";

        #login.enable = lib.mkEnableOption "Local authentication via Authentik";
        ssh.enable = lib.mkEnableOption "SSH authentication via Authentik";

        browser.chrome.enable = lib.mkEnableOption "Chrome browser plugin";
        browser.firefox.enable = lib.mkEnableOption "Firefox browser plugin";
      };
    };
  };

  # TODO: NSS and PAM, then nsswitch

  config = lib.mkMerge [
    {
      services.authentik.agent = {
        enable = true;
        #login.enable = true;
        ssh.enable = true;

        browser.firefox.enable = true;
      };
    }
    (lib.mkIf cfg.enable {
      environment.systemPackages = [authentik-platform];

      systemd = {
        services.ak-sysd = {
          description = "authentik sysd";
          after = ["network.target"];
          script = "${lib.getExe' authentik-platform "ak-sysd"} agent";
          serviceConfig = {
            Restart = "always";
            RuntimeDirectory = "authentik";
            RuntimeDirectoryMode = "0777";
          };
          wantedBy = ["multi-user.target"];
        };

        user.services.ak-agent = {
          description = "authentik Agent";
          after = ["network.target"];
          serviceConfig.Restart = "always";
          script = lib.getExe' authentik-platform "ak-agent";
          wantedBy = ["default.target"];
        };
      };

      environment.etc."authentik/config.json" = {
        text = ''
          {
            "debug": false,
            "domains": "/etc/authentik/domains",
            "runtime": "/var/run/authentik"
          }
        '';
      };

      system.activationScripts.authentik = ''
        mkdir -p /etc/authentik/domains
        mkdir -p /var/lib/authentik
      '';

      services.openssh.authorizedKeysCommand = lib.mkIf cfg.ssh.enable "${lib.getExe' authentik-platform "ak-sysd"} ssh-verify %u %k %f";

      programs.chromium.extensions = lib.mkIf cfg.browser.chrome.enable ["${authentik-browser}/authentik_chrome.zip"];
      programs.firefox.policies = lib.mkIf cfg.browser.firefox.enable {
        ExtensionSettings = {
          "platform-browser-extension@goauthentik.io" = {
            force_installed = true;
            install_url = "${authentik-browser}/authentik_firefox.zip";
          };
        };
      };
    })
  ];
}
