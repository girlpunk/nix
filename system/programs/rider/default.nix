{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Dotnet
    (with dotnetCorePackages; combinePackages [
      dotnet_9.sdk
    ])
    unstable.jetbrains.rider
  ];
}
