{ ... }:

{
  # Interactive shell, startup helpers, and plugins
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases.reload = "exec zsh";
    initContent = ''
      fastfetch -c ~/.config/fastfetch/compact-config.jsonc
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="/home/ayaan_mirza/.local/share/pi-node/node-v22.23.2-linux-x64/bin:$PATH"
      export NIX_CONFIG="access-tokens = github.com=$(gh auth token)"
      # agenix-decrypted secrets -> env vars (read at shell start, never in the nix store)
      [ -r /run/agenix/cloudflare-api-token ] && export CLOUDFLARE_API_TOKEN="$(cat /run/agenix/cloudflare-api-token)"
      mkdir -p "$HOME/.cache/zsh"
      export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"

      # dms shell completion, generated live so it never goes stale vs whatever dms
      # version is actually installed (compinit already ran by this point
      # in initContent)
      if command -v dms >/dev/null 2>&1; then
        eval "$(dms completion zsh)"
      fi
    '';
  };
}
