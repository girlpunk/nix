_: let
  gitConfig = {
    init.defaultBranch = "main";
    pull.rebase = false;
    push.autoSetupRemote = true;
    push.default = "tracking";
    color.ui = true;
    core.askPass = ""; # needs to be empty to use terminal for ask pass
    credential.helper = "store"; # want to make this more secure
    pager.branch = false;
    commit.gpgsign = true;

    credential = {
      "https://dev.azure.com" = {
        useHttpPath = true;
      };
    };

    gpg = {
      format = "ssh";
    };
  };
in {
  programs = {
    git = {
      enable = true;

      #TODO: Work config
      userName = "Foxocube";
      userEmail = "git@foxocube.xyz";
      signing = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFygf49qzrMruoAeB/Y0RcpkTFGpTVpRr+bwRhDQIZzI";
        signByDefault = true;
      };
      extraConfig = gitConfig;
      lfs.enable = true;
      #delta.enable = true;
      #diff-highlight.enable = true;
      #diff-so-fancy.enable = true;
      #difftastic.enable = true;
    };
    gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
      };
      settings.git_protocol = "ssh";
    };
  };
}
