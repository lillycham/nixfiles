{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    
    plugins = with pkgs.vimPlugins; [ 
      ale
      vim-go
      vim-nix
      swift-vim
      vim-gitgutter
      vim-airline
      YouCompleteMe
      vim-css-color
      rainbow
    ];
    
    extraConfig = ''
      " Set relative line numbers
      set nu rnu
      " Set 80 col ruler
      set ruler
      set colorcolumn=80

      " C-a C-e to home and end, as it should be
      map <C-a> <Home>
      map <C-e> <End>
      
      syntax on
    '';
  };

  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      hidden = true;
    };
  };
}

