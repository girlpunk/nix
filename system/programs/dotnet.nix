{
  pkgs,
  lib,
  ...
}: let
  dotnet = with pkgs.dotnetCorePackages;
    combinePackages [
      dotnet_10.sdk
      # pkgs.unstable.dotnetCorePackages.dotnet_10.sdk
      # dotnet_11.sdk
    ];
in {
  options.programs.dotnet.enable = lib.mkEnableOption "If dotnet is to be enabled";

  config = {
    environment = {
      sessionVariables = {
        DOTNET_ROOT = "${dotnet}/share/dotnet";
      };

      systemPackages = [dotnet];
    };

    programs.dotnet.enable = true;
  };
}
