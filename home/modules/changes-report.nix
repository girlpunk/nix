{
  lib,
  pkgs,
  ...
}: {
  home.activation.changesReport = lib.hm.dag.entryAnywhere ''
    if [[ -v oldGenPath ]] ; then
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    fi
  '';
}
