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
  programs.git = {
    enable = true;
    userName = "Foxocube";
    userEmail = "git@foxocube.xyz";
    #signing = {
    #  key = "523D5DC389D273BC";
    #  signByDefault = true;
    #};
    extraConfig = gitConfig;
  };
}
