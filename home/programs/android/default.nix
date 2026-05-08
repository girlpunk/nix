{pkgs, ...}:
let
  androidEnv = pkgs.androidenv.override {licenseAccepted = true;};

  # Versions are from these two
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/mobile/androidenv/compose-android-packages.nix
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/mobile/androidenv/repo.json
  # Remember to check vresions from the right branch
  androidComposition = androidEnv.composeAndroidPackages {
    cmdLineToolsVersion = "19.0";
    toolsVersion = "26.1.1";
    platformToolsVersion = "36.0.0";
    buildToolsVersions = [
      "36.0.0"
      "35.0.0"
      "34.0.0"
    ];
    platformVersions = ["36" "34"];
    includeSources = true;

    useGoogleAPIs = true;

    #includeExtras = ["extras;google;gcm"];
  };
in
{
  home.packages = with pkgs; [
    (android-studio.withSdk androidComposition.androidsdk)
    androidComposition.androidsdk
    androidComposition.platform-tools
  ];
}
