{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Dotnet
    (
      with dotnetCorePackages;
        combinePackages [
          dotnet_9.sdk
          pkgs.unstable.dotnetCorePackages.dotnet_10.sdk
        ]
    )
    unstable.jetbrains.rider
  ];

  programs.nix-ld.enable = true;   
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    icu
    # ncurses6
  ];
}
