{ pkgs, ... }:
let
  latex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-basic
      dvisvgm
      dvipng
      wrapfig
      amsmath
      ulem
      hyperref
      capt-of
      pgf
      tikz-cd
      listings
      mathtools
      forloop
      alphalph
      soul
      mathdesign
      xkeyval
      ly1
      ebgaramond
      ebgaramond-maths
      newtx
      etoolbox
      fontspec
      txfonts
      metafont
      charter
      biblatex
      booktabs
      makecell
      biblatex-mla
      stmaryrd
      polytable
      lazylist;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  });
in
{
  home.packages = with pkgs; [ biber latex lhs2tex ltex-ls ];
}
