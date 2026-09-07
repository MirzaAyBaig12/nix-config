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

      # Runs the real flatpak command with your args first, then syncs
      # flatpak.packages.nix only if that command succeeded
      flatpak() {
        command flatpak "$@" && sync-flatpak-apps
      }

      # dms shell completion — generated live so it never goes stale
      # against whatever dms version is actually installed (oh-my-zsh's
      # compinit has already run by this point in initContent)
      if command -v dms >/dev/null 2>&1; then
        eval "$(dms completion zsh)"
      fi
    '';
    oh-my-zsh = {
      enable = true;
      theme = "xiong-chiamiov-plus";
      plugins = [ "git" "npm" "history" "node" "rust" "deno" "snap" ];
    };
  };
}
