{pkgs, ...}: let
  dotnet = with pkgs.dotnetCorePackages;
    combinePackages [
      dotnet_10.sdk
      # pkgs.unstable.dotnetCorePackages.dotnet_10.sdk
      # dotnet_11.sdk
    ];
in {
  environment = {
    sessionVariables = {
      DOTNET_ROOT = "${dotnet}/share/dotnet";
    };

    systemPackages = [dotnet];
  };
}
