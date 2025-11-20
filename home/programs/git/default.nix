{
  config,
  pkgs,
  lib,
  ...
}: let
  gitExtraConfig = let
    mergiraf-attributes =
      pkgs.runCommandLocal "gitattributes" {nativeBuildInputs = [pkgs.mergiraf];}
      ''
        mergiraf languages --gitattributes >> $out
      '';
  in
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

        gpg = {
          format = "ssh";
        };
      }
      else {}
    );

  gitConfig =
    {
      # Shared config
      enable = true;
      package = pkgs.gitFull;
      extraConfig = gitExtraConfig;

      attributes = [
        "* merge=mergiraf"
      ];

      difftastic = {
        enable = true;
        enableAsDifftool = true;
      };

      lfs.enable = true;

      maintenance = {
        enable = true;
      };
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
    };
  };
}
