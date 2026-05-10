{pkgs, ...}: {
  home = {
    packages = [pkgs.nano];

    file.".nanorc" = {
      text = ''
        ## Interpret digits given on the command line after a colon after a filename
        ## as the line number to go to in that file.
        set colonparsing

        ## Remember the used search/replace strings for the next session.
        set historylog

        ## Enable vim-style lock-files.  This is just to let a vim user know you
        ## are editing a file [s]he is trying to edit and vice versa.  There are
        ## no plans to implement vim-style undo state in these files.
        set locking

        ## Use the end of the title bar for some state flags: I = auto-indenting,
        ## M = mark, L = hard-wrapping long lines, R = recording, S = soft-wrapping.
        set stateflags
      '';
    };
  };
}
