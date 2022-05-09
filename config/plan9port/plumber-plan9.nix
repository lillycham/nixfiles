{config, pkgs, lib, ...}:
{
  home.file."lib/plumbing".text = ''
    plan9=/usr/local/plan9
    editor=acme
    addrelem='((#?[0-9]+)|(/[A-Za-z0-9_\^]+/?)|[.$])'
    addr=:($addrelem([,;+\-]$addrelem)*)
    twocolonaddr=([0-9]+)[:.]([0-9]+)

    # image files go to open
    type is text
    data matches '[a−zA−Z0−9_\−./]+'
    data matches '([a−zA−Z0−9_\−./]+).(jpe?g|gif|bit)'
    arg isfile $0
    plumb to image
    plumb start open $file

    # show git log
    type is text
    data matches 'commit ([a-z0-9]*)'
    arg isdir .
    data set $dir
    plumb start bash -c 'cd '$dir'; git show '$1' | 9p write acme/new/body'

  '';
}
