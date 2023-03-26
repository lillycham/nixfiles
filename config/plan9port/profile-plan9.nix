{
  # This file is the ~/lib/profile file, which is similar to .bashrc for the Plan 9 'rc' shell.
  home.file."lib/profile".text = ''
    path=($home/go/bin $home/.nix-profile/bin /usr/local/plan9/bin /usr/local/bin /opt/local/bin /usr/bin /bin /usr/sbin /sbin .)
	  prompttext=`{ whoami }
    prompt=(`{ whoami }' @ `{ hostname }' % ' '    ')
    NIX_SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
  '';
}
