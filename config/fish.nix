{

	programs.fish = {
		enable = true;
	  	shellAbbrs = {
			hms = "home-manager switch";
			m = "make";
			n = "nvim";
			a = "acme";
			o = "open";
			nix-install = "nix-env -iA nixpkgs.";
		};
		shellInit = ''
		starship init fish | source
		set -U NIX_SSL_CERT_FILE /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
		'';
		functions = {
			fish_greeting = {
				description = "Greeting to show when starting a fish shell";
				body = ''
					echo Welcome to fish, the friendly interactive shell
					echo -n It\'s (set_color yellow;date ; set_color normal)
					echo on $hostname
					echo For instructions on how to use fish type (set_color green; echo help; set_color normal)
				'';
			};
			mkdcd = {
				description = "Make a directory tree and enter it";
				body = "mkdir -p $argv[1]; and cd $argv[1]";
			};
		};
	};
}
