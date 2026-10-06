{
  lib,
  pkgs,
  ...
}: {
  home.activation.changesReport = lib.hm.dag.entryAnywhere ''
    if [[ -v oldGenPath ]] ; then
      ${lib.getExe pkgs.dix} $oldGenPath $newGenPath
    fi
  '';
}
