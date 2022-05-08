{config, pkgs, lib, ...}:
{
  home.file."lib/plumber".text = ''
    # open pdf with `open`
    type is text
    data matches '[a-zA-Z¡-￿0-9_\-./]+'
    data matches '([a-zA-Z¡-￿0-9_\-./]+)\.(ps|PS|eps|EPS|pdf|PDF|dvi|DVI)'
    arg isfile	$0
    plumb to postscript
    plumb start open $file

    # show git log
    type is text
    data matches 'commit ([a-z0-9]*)'
    arg isdir .
    data set $dir
    plumb start bash -c 'cd '$dir'; git show '$1' | 9p write acme/new/body'

    # show git log
    type is text
    data matches 'commit ([a-z0-9]*)'
    arg isdir .
    data set $dir
    plumb start bash -c 'cd '$dir'; git show '$1' | 9p write acme/new/body'
  '';
}
