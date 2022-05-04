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
    ];
    
    extraConfig = ''
      set nu rnu
      set ruler
      set colorcolumn=80
      map <C-a> <Home>
      map <C-e> <End>
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

