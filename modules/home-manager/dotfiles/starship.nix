{ lib, ... }:

let
  # nerd font glyph from a codepoint (so nothing gets eaten when copying)
  g = code: builtins.fromJSON ''"\u${code}"'';

  capR   = g "e0b4";
  nixos  = g "f313";
  branch = g "f418";
  clock  = g "f017";
  dl     = g "f019";
  docs   = g "f15c";
  music  = g "f001";
  pics   = g "f03e";
  node   = g "e718";
  rust   = g "e7a8";
  golang = g "e626";
  php    = g "e608";
in
{
  # Tokyo Night preset layout, recoloured with the full Catppuccin Mocha palette
  # (mauve accent) and a NixOS snowflake instead of the apple.
  # The catppuccin module's own starship theme would fight this palette.
  catppuccin.starship.enable = false;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo  = "#f2cdcd";
        pink      = "#f5c2e7";
        mauve     = "#cba6f7";
        red       = "#f38ba8";
        maroon    = "#eba0ac";
        peach     = "#fab387";
        yellow    = "#f9e2af";
        green     = "#a6e3a1";
        teal      = "#94e2d5";
        sky       = "#89dceb";
        sapphire  = "#74c7ec";
        blue      = "#89b4fa";
        lavender  = "#b4befe";
        text      = "#cdd6f4";
        subtext1  = "#bac2de";
        subtext0  = "#a6adc8";
        overlay2  = "#9399b2";
        overlay1  = "#7f849c";
        overlay0  = "#6c7086";
        surface2  = "#585b70";
        surface1  = "#45475a";
        surface0  = "#313244";
        base      = "#1e1e2e";
        mantle    = "#181825";
        crust     = "#11111b";
      };

      add_newline = true;

      format = lib.concatStrings [
        "[░▒▓](mauve)"
        "$os"
        "$username"
        "[${capR}](bg:mauve fg:mauve)"
        "$directory"
        "[${capR}](fg:mauve bg:surface1)"
        "$git_branch"
        "$git_status"
        "[${capR}](fg:surface1 bg:surface0)"
        "$nix_shell"
        "$nodejs"
        "$rust"
        "$golang"
        "$php"
        "$custom"
        "[${capR}](fg:surface0 bg:mantle)"
        "$time"
        "[${capR} ](fg:mantle)"
        "\n$character"
      ];

      os = {
        disabled = false;
        style = "bg:mauve fg:crust";
        format = "[ $symbol ]($style)";
        symbols.NixOS = "${nixos} ";
      };

      username = {
        show_always = true;
        style_user = "bg:mauve fg:crust";
        style_root = "bg:mauve fg:red";
        format = "[$user ]($style)";
      };

      directory = {
        style = "fg:crust bg:mauve";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "${docs} ";
          "Downloads" = "${dl} ";
          "Music"     = "${music} ";
          "Pictures"  = "${pics} ";
        };
      };

      git_branch = {
        symbol = branch;
        style = "bg:surface1";
        format = "[[ $symbol $branch ](fg:mauve bg:surface1)]($style)";
      };

      git_status = {
        style = "bg:surface1";
        format = "[[($all_status$ahead_behind )](fg:mauve bg:surface1)]($style)";
      };

      # enabled by default, shows for nix-shell / nix develop (IN_NIX_SHELL).
      # heuristic is off: on NixOS it false-positives since PATH always has store paths.
      nix_shell = {
        disabled = false;
        heuristic = false;
        symbol = "${nixos} ";
        impure_msg = "nix-shell";
        pure_msg = "pure nix-shell";
        style = "bg:surface0";
        format = "[[ $symbol$state ](fg:mauve bg:surface0)]($style)";
      };

      nodejs = { symbol = node;   detect_folders = [ ]; style = "bg:surface0"; format = "[[ $symbol ($version) ](fg:mauve bg:surface0)]($style)"; };
      rust   = { symbol = rust;   style = "bg:surface0"; format = "[[ $symbol ($version) ](fg:mauve bg:surface0)]($style)"; };
      golang = { symbol = golang; style = "bg:surface0"; format = "[[ $symbol ($version) ](fg:mauve bg:surface0)]($style)"; };
      php    = { symbol = php;    style = "bg:surface0"; format = "[[ $symbol ($version) ](fg:mauve bg:surface0)]($style)"; };

      # starship has no built-in nix language module, so these are custom ones.
      # Lix version is read from the store path of nix-store (instant, no spawn).
      custom.nix_lang = {
        detect_extensions = [ "nix" ];
        detect_files = [ "flake.nix" "flake.lock" ];
        command = ''readlink -f /run/current-system/sw/bin/nix-store | sed -E 's/.*-lix-([0-9.]+).*/\1/' '';
        symbol = "${nixos} ";
        style = "bg:surface0";
        format = "[[ $symbol($output) ](fg:mauve bg:surface0)]($style)";
      };

      # fallback: NixOS + Lix version when the dir has no code (hidden in any language dir)
      custom.nixver = {
        when = ''[ -z "$(find . -maxdepth 1 \( -name package.json -o -name Cargo.toml -o -name pyproject.toml -o -name requirements.txt -o -name go.mod -o -name flake.nix -o -name '*.nix' -o -name '*.py' -o -name '*.rs' -o -name '*.go' -o -name '*.js' -o -name '*.ts' -o -name '*.c' -o -name '*.cpp' -o -name '*.java' \) -print -quit)" ]'';
        command = ''. /etc/os-release; echo "$VERSION_ID · Lix $(readlink -f /run/current-system/sw/bin/nix-store | sed -E 's/.*-lix-([0-9.]+).*/\1/')"'';
        symbol = "${nixos} ";
        style = "bg:surface0";
        format = "[[ $symbol$output ](fg:mauve bg:surface0)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:mantle";
        format = "[[ ${clock} $time ](fg:subtext0 bg:mantle)]($style)";
      };

      character = {
        success_symbol = "[❯](green)";
        error_symbol   = "[❯](red)";
      };
    };
  };

  # makes nix-shell and nix develop spawn zsh instead of bash
  programs.nix-your-shell = {
    enable = true;
    enableZshIntegration = true;
  };
}
