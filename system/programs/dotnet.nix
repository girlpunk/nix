{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Dotnet
    (
      with dotnetCorePackages;
        combinePackages [
          dotnet_9.sdk
          dotnet_10.sdk
        ]
    )
  ];
}
