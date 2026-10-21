{ 
  inputs, 
  pkgs,
  ... 
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # Must be a real script: home-manager runs this *unquoted*
    # (`run $HOME_MANAGER_BACKUP_COMMAND "$target"`), so an inline shell string
    # gets word-split into args for `rm` instead of being interpreted.
    # Works on files and directories; replaces any previous .bak.
    backupCommand = "${pkgs.writeShellScript "hm-backup" ''rm -rf -- "$1.bak" && mv -- "$1" "$1.bak"''}";

    users.ayaan_mirza = {
      imports = [
        # Repository modules
        ./home-manager/programs.hm.nix
        ./home-manager/stylix.hm.nix
        ./home-manager/services.hm.nix
        ./home-manager/niri.config.nix
        ./home-manager/dotfiles/fastfetch.nix
        ./home-manager/dotfiles/nixcord.nix
        ./home-manager/dotfiles/nixd.nix
        ./home-manager/dotfiles/superfile.nix
        ./home-manager/dotfiles/vscode.nix
        ./home-manager/dotfiles/web-apps.nix
        ./home-manager/dotfiles/zsh.nix

        # Upstream Home Manager modules
        inputs.dux-search.homeModules.dsearch
        inputs.nixcord.homeModules.nixcord
        inputs.catppuccin.homeModules.catppuccin
      ];

      # Qt 5 and Qt 6 use qtct for palette/font settings and Kvantum for
      # rounded widget rendering.
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };

      # Home profile identity and compatibility version
      home.stateVersion = "26.05";
      home.username = "ayaan_mirza";
      home.homeDirectory = "/home/ayaan_mirza";
    };
  };
}
