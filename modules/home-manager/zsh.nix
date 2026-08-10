{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  inherit (lib)
    concatStringsSep
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    mkOrder
    optionalString
    types
    ;

  cfg = config.programs.zsh;
  bindkeyCommands = {
    emacs = "bindkey -e";
    viins = "bindkey -v";
    vicmd = "bindkey -a";
  };
in
{
  # Placeholder — see chat for why this can't hold the full upstream
  # module source (duplicate option declarations vs. the imported HM
  # flake module). Restore from git history if this breaks the build.
}
