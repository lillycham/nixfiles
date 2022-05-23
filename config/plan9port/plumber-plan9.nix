{config, pkgs, lib, ...}:
{
  home.file."lib/plumbing".text = ''
    plan9=/usr/local/plan9
    editor=acme
    addrelem='((#?[0-9]+)|(/[A-Za-z0-9_\^]+/?)|[.$])'
    addr=:($addrelem([,;+\-]$addrelem)*)
    twocolonaddr=([0-9]+)[:.]([0-9]+)

    plumb to seemail
    plumb to showmail
    plumb to web
    plumb to msword
    plumb to image
    plumb to postscript
    plumb to openoffice
    plumb to edit
    plumb to sendmail

    type    is      text
    data    matches 'file:([.a-zA-Z¡-￿0-9_\-]([.a-zA-Z¡-￿0-9_/\-]*[a-zA-Z¡-￿0-9_/\-]))?'
    arg     isfile  $1
    data    set     file://$file
    plumb   to      web
    plumb   start   web $data

    type    is      text
    data    matches '(https?|ftp|file|gopher|mailto|news|nntp|telnet|wais|prospero)://[a-zA-Z0-9_@\-]+([.:][a-zA-Z0-9_@\-]+)  */?[a-zA-Z0-9_?,%#~&/\-+=]+([:.][a-zA-Z0-9_?,%#~&/\-+=]+)*'
    plumb   to      web
    plumb   start   web $0

    type    is      text
    data    matches '[a-zA-Z¡-￿0-9_\-./]+'
    data    matches '([a-zA-Z¡-￿0-9_\-./]+)\.(doc|rtf)'
    arg     isfile  $0
    plumb   to      msword
    plumb   start   wdoc2txt $file

    type    is      text
    dst     is      msword
    plumb   to      msword
    plumb   start   wdoc2txt $file

    data    matches '[a-zA-Z¡-￿0-9_\-./@]+'
    data    matches '([a-zA-Z¡-￿0-9_\-./@]+)\.([Ss][XxTt][CcDdIiGgMmWw]|[Dd][Oo][Cc]|[Xx][Ll][Ss]|[Pp][Pp][Tt])'
    arg     isfile  $0
    plumb   to      openoffice
    plumb   start   openoffice $file

    type    is      text
    data    matches '([.a-zA-Z¡-￿0-9_/\-@]*[a-zA-Z¡-￿0-9_/\-])':$twocolonaddr,$twocolonaddr
    arg     isfile  $1
    data    set     $file
    attr    add     addr=$2-#0+#$3-#1,$4-#0+#$5-#1
    plumb   to      edit
    plumb   client  $editor

    type    is      text
    data    matches '([.a-zA-Z¡-￿0-9_/\-@]*[a-zA-Z¡-￿0-9_/\-])':$twocolonaddr
    arg     isfile  $1
    data    set     $file
    attr    add     addr=$2-#0+#$3-#1
    plumb   to      edit
    plumb   client  $editor

    type    is      text
    data    matches '([.a-zA-Z¡-￿0-9_/\-@]*[a-zA-Z¡-￿0-9_/\-])('$addr')?'
    arg     isfile  $1
    data    set     $file
    attr    add     addr=$3
    plumb   to      edit
    plumb   client  $editor

    type    is      text
    data    matches '([a-zA-Z¡-￿0-9/_\-]+\.h)('$addr')?'
    arg     isfile  /usr/include/$1
    data    set     $file
    attr    add     addr=$3
    plumb   to      edit
    plumb   client  $editor

    type    is      text
    data    matches '([a-zA-Z¡-￿0-9/_\-]+\.h)('$addr')?'
    arg     isfile  /usr/local/include/$1
    data    set     $file
    attr    add     addr=$3
    plumb   to      edit
    plumb   client  $editor

    type    is      text
    data    matches '([a-zA-Z¡-￿0-9/_\-]+\.h)('$addr')?'
    arg     isfile  $plan9/include/$1
    data    set     $file
    attr    add     addr=$3
    plumb   to      edit
    plumb   client  $editor

    type    is      text
    data    matches '([a-zA-Z¡-￿0-9/_\-]+\.m)('$addr')?'
    arg     isfile  /usr/inferno/module/$1
    data    set     $file
    attr    add     addr=$3
    plumb   to      edit
    plumb   client  window $editor

    type    is      text
    data    matches '[a-zA-Z¡-￿0-9_\-./]+'
    data    matches '/mail/fs/[a-zA-Z¡-￿0-9/]+/[0-9]+'
    plumb   to      showmail
    plumb   start   window -r 4 120 750 600 upas/nedmail -s $0

    type    is      text
    data    matches '[a-zA-Z0-9_+.\-]+@[a-zA-Z0-9_+.\-]*'
    plumb   to      sendmail
    plumb   start   wmail $0

    type    is      text
    data    matches '([a-zA-Z¡-￿0-9_\-./]+)\(([1-8])\)'
    plumb   start   rc -c 'man '$2' '$1' >[2=1] | nobs | plumb -i -d edit -a ''action=showdata filename=/man/'$1'('$2')'''

    dst     is      image
    arg     isfile  $data
    plumb   to      image
    plumb   start   cat $data | open -a preview -f

    dst     is      postscript
    arg     isfile  $data
    plumb   start   cat $data | open -a preview -f

    type    is      text
    data    matches '[a-zA-Z¡-￿0-9_\-./@]+'
    data    matches '([a-zA-Z¡-￿0-9_\-./@]+)\.(jpe?g|JPE?G|gif|GIF|tiff?|TIFF?|ppm|bit|png|PNG)'
    arg     isfile  $0
    plumb   to      image
    plumb   start   9 page $file

    type    is      text
    data    matches '[a-zA-Z¡-￿0-9_\-./@]+'
    data    matches '([a-zA-Z¡-￿0-9_\-./@]+)\.(ps|PS|eps|EPS|pdf|PDF|dvi|DVI)'
    arg     isfile  $0
    plumb   to      postscript
    plumb   start   9 page $file

    # show git log
    type is text
    data matches 'commit ([a-z0-9]*)'
    arg isdir .
    data set $dir
    plumb start bash -c 'cd '$dir'; git show '$1' | 9p write acme/new/body'
    
  '';
}
