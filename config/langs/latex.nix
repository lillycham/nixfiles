{ pkgs, ... }:
let
  latex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-basic
      alphalph
      amsmath
      biblatex
      biblatex-mla
      booktabs
      capt-of
      charter
      dvipng
      dvisvgm
      ebgaramond
      ebgaramond-maths
      etoolbox
      fontspec
      forloop
      hyperref
      lazylist
      listings
      ly1
      makecell
      mathdesign
      mathtools
      metafont
      newtx
      pgf
      polytable
      sectsty
      soul
      stmaryrd
      tikz-cd
      txfonts
      ulem
      wrapfig
      xkeyval;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  });
in
{
  home.packages = with pkgs; [ biber latex lhs2tex ltex-ls ];
}
