let
  config = ''
    # See this wiki page for more info:
    # https://github.com/dylanaraps/neofetch/wiki/Customizing-Info
    print_info() {
      info title
      info underline
      info "OS" distro
      info "Host" model
      info "Kernel" kernel
      info "Uptime" uptime
      info "Battery" battery
      info "Packages" packages
      info "Shell" shell
      info "Resolution" resolution
      info "DE" de
      info "Terminal" term
      info "Terminal Font" term_font
      info "CPU" cpu
      info "Memory" memory
      #info "Song" song
      # info "GPU Driver" gpu_driver  # Linux/macOS only
      # info "CPU Usage" cpu_usage
      # info "Disk" disk
      # info "Font" font
      [[ "$player" ]] && prin "Music Player" "$player"
      # info "Local IP" local_ip
      # info "Public IP" public_ip
      # info "Users" users
      # info "Locale" locale  # This only works on glibc systems.
      info cols
    }

    # Title
    title_fqdn="off"

    # Kernel
    # Shorten the output of the kernel function.
    kernel_shorthand="on"

    # Distro
    distro_shorthand="on"
    os_arch="on"

    # Uptime
    # Shorten the output of the uptime function
    uptime_shorthand="tiny"

    # Memory
    # Show memory pecentage in output.
    memory_percent="off"
    # Change memory output unit.
    memory_unit="gib"

    # Packages
    # Show/Hide Package Manager names.
    package_managers="tiny"

    # Shell
    shell_version="on"

    # CPU
    # CPU speed type
    speed_type="bios_limit"

    # CPU speed shorthand
    speed_shorthand="off"

    # Enable/Disable CPU brand in output.
    cpu_brand="on"

    # CPU Speed
    cpu_speed="on"

    # CPU Cores
    cpu_cores="logical"

    # CPU Temperature
    cpu_temp="off"


    # GPU
    # Enable/Disable GPU Brand
    gpu_brand="on"

    # Which GPU to display
    gpu_type="all"


    # Resolution
    # Display refresh rate next to each monitor
    refresh_rate="off"


    # Gtk Theme / Icons / Font
    # Shorten output of GTK Theme / Icons / Font
    gtk_shorthand="off"


    # Enable/Disable gtk2 Theme / Icons / Font
    gtk2="off"

    # Enable/Disable gtk3 Theme / Icons / Font
    gtk3="off"


    # IP Address
    # Website to ping for the public IP
    public_ip_host="http://ident.me"

    # Public IP timeout.
    public_ip_timeout=2


    # Desktop Environment
    # Show Desktop Environment version
    de_version="off"


    # Disk
    # Which disks to display.
    disk_show=('/')

    # Disk subtitle.
    disk_subtitle="mount"

    # Disk percent.
    # Show/Hide disk percent.
    disk_percent="off"


    # Song
    music_player="iTunes"

    # Format to display song information.
    song_format="%artist% - %album% - %title%"

    # Print the Artist, Album and Title on separate lines
    song_shorthand="off"

    # 'mpc' arguments (specify a host, password etc).
    mpc_args=()


    # Text Colors
    colors=(distro)


    # Text Options
    # Toggle bold text
    bold="on"

    # Enable/Disable Underline
    underline_enabled="on"

    # Underline character
    underline_char="-"


    # Info Separator
    separator=":"


    # Color Blocks
    # Color block range
    block_range=(0 15)

    # Toggle color blocks
    color_blocks="on"

    # Color block width in spaces
    block_width=3

    # Color block height in lines
    block_height=1

    # Color Alignment
    col_offset="auto"

    # Progress Bars
    # Bar characters
    bar_char_elapsed="-"
    bar_char_total="="

    # Toggle Bar border
    bar_border="on"

    # Progress bar length in spaces
    bar_length=15

    # Progress bar colors
    bar_color_elapsed="distro"
    bar_color_total="distro"


    # Info display
    cpu_display="off"
    memory_display="on"
    battery_display="on"
    disk_display="off"


    # Backend Settings
    # Image backend.
    image_backend="ascii"

    # Image Source
    image_source="/Users/lillycham/Untitled.png"


    # Ascii Options
    # Ascii distro
    ascii_distro="auto"

    # Ascii Colors
    ascii_colors=(distro)

    # Bold ascii logo
    ascii_bold="on"

    # Image Options
    # Image loop
    image_loop="off"

    # Thumbnail directory
    thumbnail_dir="\$\{XDG_CACHE_HOME:-\$\{HOME}/.cache}/thumbnails/neofetch"

    # Crop mode
    crop_mode="normal"

    # Crop offset
    crop_offset="center"

    # Image size
    image_size="none"

    # Gap between image and text
    gap=3

    # Image offsets
    yoffset=0
    xoffset=0

    # misc options
    stdout="off"
  '';
in {
  home.file.neofetch = {
    target = ".config/neofetch/config.conf";
    text = config;
  };
}
