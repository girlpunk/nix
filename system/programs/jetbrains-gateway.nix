{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.jetbrains.gateway
  ];
}
