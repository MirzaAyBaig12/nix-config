{ ... }:

{
  programs.vscode = {
    profiles.default.userSettings = {
      "nix.serverSettings" = {
        "nixd" = {
          "options" = {
            "home-manager" = {
              "expr" =
                "(builtins.getFlake (builtins.toString ./. )).nixosConfigurations.Axiom.options.home-manager.users.type.getSubOptions []";
            };
          };
        };
      };
    };
  };
}