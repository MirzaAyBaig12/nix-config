{ pkgs, ... }:

{
  home.packages = with pkgs; [
    #vscode
    gtk2
    nixd
    nixfmt
  ];
}