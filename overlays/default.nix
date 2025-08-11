#{ inputs, system }:
final: prev: {
  #inherit (import inputs.nixpkgs-unstable { inherit system; config.allowUnfree = true; }).packages.jetbrains.rider unstable-rider;
}
