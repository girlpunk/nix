{ pkgs, lib, ...}: let
  gitConfig = let
    mergiraf-attributes =
      pkgs.runCommandLocal "gitattributes" {nativeBuildInputs = [pkgs.mergiraf];}
      ''
        mergiraf languages --gitattributes >> $out
      '';
  in {
    branch.autoSetupRebase = "always";
    checkout.defaultRemote = "origin";
    color.ui = true;
    commit.gpgsign = true;

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

    gpg = {
      format = "ssh";
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
  };
in {
  programs = {
    git = {
      enable = true;
      package = pkgs.gitFull;
      lfs.enable = true;

      #TODO: Work config
      userName = "Foxocube";
      userEmail = "git@foxocube.xyz";
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFygf49qzrMruoAeB/Y0RcpkTFGpTVpRr+bwRhDQIZzI";
        signByDefault = true;
      };

      maintenance = {
        enable = true;
      };

      difftastic.enable = true;
      attributes = [
        "* merge=mergiraf"
      ];

      extraConfig = gitConfig;
    };
    gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
      };
      settings.git_protocol = "ssh";
    };
    mergiraf.enable = true;
  };
}
