{
  config,
  pkgs,
  lib,
  ...
}: let
  gitSettings =
    {
      branch.autoSetupRebase = "always";
      checkout.defaultRemote = "origin";
      color.ui = true;

      core = {
        askPass = ""; # needs to be empty to use terminal for ask pass
        conflictStyle = "diff3";
      };

      credential = {
        helper = "store"; # want to make this more secure

        "https://dev.azure.com" = {
          useHttpPath = true;
        };
      };

      init.defaultBranch = "main";

      merge = {
        conflictStyle = "diff3";
        mergiraf = {
          name = "mergiraf";
          driver = "${lib.getExe pkgs.mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
        };
      };

      pager.branch = false;

      pull = {
        rebase = true;
        ff = "only";
      };

      push = {
        autoSetupRemote = true;
        default = "tracking";
      };

      submodule.recurse = "true";
    }
    // (
      if !config.defaultGit.work
      then {
        # Home-specific config
        commit.gpgsign = true;
      }
      else {}
    );

  gitConfig =
    {
      # Shared config
      enable = true;
      package = pkgs.gitFull;
      settings = gitSettings;

      attributes = [
        "* merge=mergiraf"
      ];

      lfs.enable = true;

      maintenance = {
        enable = true;
      };
    }
    // (
      if !config.defaultGit.work
      then {
        # Home config
        settings.user = {
          name = "Foxocube";
          email = "git@foxocube.xyz";
        };

        signing = {
          format = "ssh";
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFygf49qzrMruoAeB/Y0RcpkTFGpTVpRr+bwRhDQIZzI";
          signByDefault = true;
        };

        maintenance.repositories = ["~/programs/*"];
      }
      else {}
    );
in {
  options = {
    defaultGit = {
      work = lib.mkEnableOption "Work Git configuration";
    };
  };

  imports = lib.optional (builtins.pathExists ./work.nix) ./work.nix;

  config = {
    programs = {
      git = gitConfig;

      gh = {
        enable = true;
        gitCredentialHelper = {
          enable = true;
        };
        settings.git_protocol = "ssh";
      };

      mergiraf.enable = true;

      difftastic = {
        enable = true;
        git.enable = true;
        git.diffToolMode = true;
      };
    };
  };
}
