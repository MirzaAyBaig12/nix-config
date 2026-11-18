{ config, lib, pkgs, inputs, ... }:

{
  # Detect the already-installed llm-agents tools for the Nix FCC launchers.
  fcc-nix = {
    claude.enable = true;
    codex.enable = true;
    pi.enable = true;
    opencode.enable = true;

    optimizations = {
      rtk.enable = true;
      headroom.enable = true;
    };

    fcc-server.service = {
      enable = true;
      user = "ayaan_mirza";
    };
  };
}
