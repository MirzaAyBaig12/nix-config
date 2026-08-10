{ ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      fastfetch -c ~/.config/fastfetch/compact-config.jsonc
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="/var/lib/snapd/snap/bin:$PATH"
      export PATH="/home/ayaan_mirza/.local/share/pi-node/node-v22.23.2-linux-x64/bin:$PATH"
      mkdir -p "$HOME/.cache/zsh"
      export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
    '';
    oh-my-zsh = {
      enable = true;
      theme = "xiong-chiamiov-plus";
      plugins = [ "git" "npm" "history" "node" "rust" "deno" "snap" ];
    };
  };
}
