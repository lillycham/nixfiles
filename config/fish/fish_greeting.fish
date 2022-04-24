function fish_greeting
    echo Welcome to fish, the friendly interactive shell
    echo -n It\'s (set_color yellow;date ; set_color normal)
    echo on $hostname
    echo For instructions on how to use fish type (set_color green; echo help; set_color normal)
end
