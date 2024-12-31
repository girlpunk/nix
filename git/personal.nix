{ lib, config, pkgs, ... }:

{
  imports = [ ./default.nix ];
  #description = "Personal Git setup";
  programs.git.userName = "Foxocube";
  programs.git.userEmail = "git@foxocube.xyz";
}
