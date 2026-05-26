{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellScriptBin "treesize" ''
  ${lib.getExe' pkgs.coreutils "du"} -k --max-depth=1 | ${lib.getExe' pkgs.coreutils "sort"} -nr | ${lib.getExe' pkgs.gawk "awk"} '
      BEGIN {
          split("KB,MB,GB,TB", Units, ",");
      }
      {
          u = 1;
          while ($1 >= 1024) {
              $1 = $1 / 1024;
              u += 1
          }
          $1 = sprintf("%.1f %s", $1, Units[u]);
          print $0;
      }
  '
''
