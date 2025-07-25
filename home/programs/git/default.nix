{ pkgs, ... }:

let
  gitConfig = {
    init.defaultBranch = "main";
    pull.rebase = false;
    push.autoSetupRemote = true;
    push.default = "tracking";
    color.ui = true;
    core.askPass = ""; # needs to be empty to use terminal for ask pass
    credential.helper = "store"; # want to make this more secure
  };
in
{
  programs = {
    git = {
      enable = true;
      userName = "Foxocube";
      userEmail = "git@foxocube.xyz";
      #signing = {
      #  key = "523D5DC389D273BC";
      #  signByDefault = true;
      #};
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
    ssh = {
      matchBlocks."*".identityAgent = "~/.1password/agent.sock";
    };
  };
}
