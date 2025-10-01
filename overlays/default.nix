#{ inputs, system }:
#final: prev:
_: {
  #inherit (import inputs.nixpkgs-unstable { inherit system; config.allowUnfree = true; }).packages.jetbrains.rider unstable-rider;
}
