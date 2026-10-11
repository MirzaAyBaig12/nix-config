
{ pkgs, inputs, ... }:

let
  base46 = pkgs.vimUtils.buildVimPlugin {
    pname = "base46";
    version = "3.0";
    src = inputs.base46;
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = [ base46 ];

    extraLuaConfig = ''
      require("base46").setup({})
      vim.cmd.colorscheme("dms")
    '';
  };
}
