{ pkgs, ... }:

{
  home.packages = with pkgs; [
    #vscode
    gtk2
  ];
}