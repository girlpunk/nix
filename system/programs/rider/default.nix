{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../dotnet.nix
  ];

  environment.systemPackages = with pkgs; [
    unstable.jetbrains.rider
  ];
}
