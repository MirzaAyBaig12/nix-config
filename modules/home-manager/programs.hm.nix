{ pkgs, ... }:

{
  home.packages = with pkgs; [
    #vscode
    gtk2
    nixd
    nixfmt
  ];

  services.flameshot = {
    # Also installs/enables flameshot
    enable = true;
    settings = {
      General = {
        useGrimAdapter = true;
        # Stops warnings for using Grim
        disabledGrimWarning = true;
    };
  };
};

  # DankSearch — file search plugin powering DMS's launcher results
  programs.dsearch.enable = true;
}