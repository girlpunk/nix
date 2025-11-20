{
  config,
  lib,
  ...
}: let
  gitExtraConfig =
    {
      # Shared config
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      push.default = "tracking";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      pager.branch = false;

      credential = {
        helper = "store"; # want to make this more secure

        "https://dev.azure.com" = {
          useHttpPath = true;
        };
      };
    }
    // (
      if !config.defaultGit.work
      then {
        # Home-specific config
        gpg = {
          format = "ssh";
        };

        commit.gpgsign = true;
      }
      else {}
    );

  gitConfig =
    {
      # Shared config
      enable = true;
      lfs.enable = true;
      extraConfig = gitExtraConfig;
    }
    // (
      if !config.defaultGit.work
      then {
        # Home config
        userName = "Foxocube";
        userEmail = "git@foxocube.xyz";
        signing = {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFygf49qzrMruoAeB/Y0RcpkTFGpTVpRr+bwRhDQIZzI";
          signByDefault = true;
        };
      }
      else {}
    );
in {
  options = {
    defaultGit = {
      work = lib.mkEnableOption "Work Git configuration";
    };
  };

  config = {
    imports =
      if config.defaultGit.work
      then [./work.nix]
      else [];
    programs = {
      git = gitConfig;
      gh = {
        enable = true;
        gitCredentialHelper = {
          enable = true;
        };
        settings.git_protocol = "ssh";
      };
    };
  };
}
