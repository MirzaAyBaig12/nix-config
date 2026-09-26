{
  description = "Natsumi: pick a browser, get fx-autoconfig + Natsumi installed automatically (NixOS + home-manager module)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # "flake = false" -> plain source trees. Bump with
    # `nix flake update fx-autoconfig natsumi` to grab the newest commit on
    # each repo's default branch -- as close to "auto-install latest" as
    # pure Nix gets, since a real build has to pin to a fixed rev to stay
    # reproducible.
    fx-autoconfig = {
      url = "github:MrOtherGuy/fx-autoconfig";
      flake = false;
    };
    natsumi = {
      url = "github:greeeen-dev/natsumi-browser";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, fx-autoconfig, natsumi }:
    let
      mkNatsumiModule = { isHomeManager }:
        { config, lib, pkgs, ... }:
        with lib;
        let
          cfg = config.programs.natsumi;

          homeDir = if isHomeManager then config.home.homeDirectory else cfg.homeDirectory;

          fxAutoconfigConfigJs = cfg.fxAutoconfigSource + "/program/config.js";

          # ---- per-browser presets -------------------------------------
          # Natsumi itself supports Firefox and "all popular forks except
          # Zen Browser" -- Zen is deliberately left out of this list.
          #
          # method = "wrapFirefox": the *real*, universal fix. nixpkgs'
          #   own wrapFirefox already has first-class support for dropping
          #   extra AutoConfig JS in via `extraPrefsFiles` -- it gets
          #   concatenated into the same generated mozilla.cfg the wrapper
          #   builds, so it loads with full chrome privileges the same way
          #   fx-autoconfig's config.js would if placed by hand. This is
          #   used for anything nixpkgs builds from source (has a
          #   `*-unwrapped` package): Firefox and LibreWolf, confirmed.
          #   For LibreWolf specifically, its own `extraPrefsFiles`
          #   (its privacy hardening) is inherited and ours appended
          #   *after* -- same effect as the old "override file loads after
          #   mozilla.cfg" trick, just via the standard mechanism instead
          #   of a special case.
          #
          # method = "directPatch": fallback for browsers nixpkgs ships as
          #   a prebuilt binary with no `*-unwrapped`/wrapper split to hook
          #   into (Floorp, Waterfox, as packaged today). Clones the
          #   package with `cp -rs` (cheap -- symlinks, not real copies)
          #   and swaps in fx-autoconfig's program-side files directly,
          #   locating the app dir generically via the shallowest
          #   `omni.ja` in the tree (every Gecko app ships one next to its
          #   binary) so it isn't tied to any particular directory-naming
          #   convention.
          # nixpkgs marks removed/renamed packages with `throw "..."` rather
          # than just omitting the attribute -- `a.b or c` only catches a
          # genuinely *missing* attribute, not one that exists but throws
          # when evaluated (confirmed: floorp-unwrapped and floorp are both
          # throw-aliases on current nixpkgs, not missing keys). tryEval
          # actually catches the throw, so this is the only safe way to do
          # a "prefer X, fall back to Y" package lookup here.
          tryPkg = attr: fallback:
            let t = builtins.tryEval pkgs.${attr}; in
            if t.success then t.value else fallback;

          browserPresets = {
            firefox = {
              method = "wrapFirefox";
              unwrapped = pkgs.firefox-unwrapped;
              wrapper = pkgs.wrapFirefox;
              displayName = "Firefox";
              profilesDirectory = "${homeDir}/.mozilla/firefox";
            };
            librewolf = {
              method = "wrapFirefox";
              unwrapped = pkgs.librewolf-unwrapped;
              wrapper = pkgs.wrapFirefox;
              displayName = "LibreWolf";
              profilesDirectory = "${homeDir}/.librewolf";
            };
            floorp = {
              # floorp/floorp-unwrapped are both throw-aliases pointing at
              # floorp-bin/floorp-bin-unwrapped as of nixpkgs' floorp 12.x
              # switch to prebuilt-only (source builds no longer feasible
              # upstream) -- confirmed directly against nixos-unstable.
              # floorp-bin's own .override isn't a wrapFirefox-style
              # function either, so this always goes through directPatch.
              method = "directPatch";
              # NOTE: must clone the fully-wrapped floorp-bin, not
              # floorp-bin-unwrapped -- the unwrapped one's bin/ only has a
              # private .floorp-wrapped binary, no actual `floorp` launcher
              # script or .desktop entry (confirmed directly on Axiom: an
              # earlier version of this preset pointed at -unwrapped and
              # silently produced an unlaunchable package).
              package = tryPkg "floorp" pkgs.floorp-bin;
              displayName = "Floorp";
              profilesDirectory = "${homeDir}/.floorp";
            };
            waterfox = {
              method = "directPatch";
              package = tryPkg "waterfox-unwrapped" pkgs.waterfox;
              displayName = "Waterfox";
              profilesDirectory = "${homeDir}/.waterfox";
            };
          };

          hasPreset = cfg.browser != "";
          preset = if hasPreset then browserPresets.${cfg.browser} else null;
          presetMethod = if hasPreset then preset.method else cfg.method;

          # ---- method 1: wrapFirefox + extraPrefsFiles -------------------
          wrapFirefoxBuilt =
            let
              baseUnwrapped = cfg.unwrappedPackage;
              inheritedExtraPrefsFiles = baseUnwrapped.extraPrefsFiles or [ ];
            in
            cfg.wrapper baseUnwrapped (cfg.wrapperArgs // {
              extraPrefsFiles = inheritedExtraPrefsFiles ++ [ fxAutoconfigConfigJs ]
                ++ (cfg.wrapperArgs.extraPrefsFiles or [ ]);
            });

          # ---- method 2: direct patch of a prebuilt package --------------
          directPatched = pkgs.runCommand "${cfg.unwrappedPackage.pname or "browser"}-fx-autoconfig"
            {
              preferLocalBuild = true;
            } ''
            mkdir -p "$out"
            cp -rs --no-preserve=mode,ownership ${cfg.unwrappedPackage}/. "$out/"
            chmod -R u+w "$out"

            appdir=$(find "$out" -mindepth 1 -name omni.ja -printf '%d %h\n' \
              | sort -n | head -n1 | cut -d' ' -f2-)
            if [ -z "$appdir" ]; then
              echo "natsumi: couldn't locate the app dir (no omni.ja found under $out)" >&2
              exit 1
            fi

            # fx-autoconfig has no mozilla.cfg -- just config.js next to
            # the binary, plus defaults/pref/config-prefs.js pointing
            # general.config.filename straight at it (confirmed against
            # the actual repo contents, not assumed).
            rm -f "$appdir/config.js"
            install -m644 ${cfg.fxAutoconfigSource}/program/config.js "$appdir/config.js"

            mkdir -p "$appdir/defaults/pref"
            rm -f "$appdir/defaults/pref/config-prefs.js"
            install -m644 ${cfg.fxAutoconfigSource}/program/defaults/pref/config-prefs.js \
              "$appdir/defaults/pref/config-prefs.js"
          '';

          builtPackage =
            if presetMethod == "wrapFirefox" then wrapFirefoxBuilt else directPatched;

          # ---- rename the desktop entry so it's distinguishable from a
          # ---- separately-installed stock copy of the same browser -----
          renamedPackage =
            if cfg.desktopNameSuffix == "" then builtPackage
            else builtPackage.overrideAttrs (old: {
              postFixup = (old.postFixup or "") + ''
                for f in "$out"/share/applications/*.desktop; do
                  [ -f "$f" ] || continue
                  sed -i "s/^Name=.*/&${cfg.desktopNameSuffix}/" "$f" 2>/dev/null || true
                done
              '';
            });

          resolvedPackage = renamedPackage;

          # ---- profile-side install, identical for every browser --------
          # Uses rsync so re-running on a newer flake.lock (new natsumi/
          # fx-autoconfig commit) actually syncs -- updates changed files
          # *and* removes ones the new commit dropped -- rather than just
          # overlaying on top and leaving orphaned files behind.
          installProfileScript = pkgs.writeShellScript "install-natsumi-profile" ''
            set -eu
            profiles_ini="$1"
            profiles_root="$2"
            requested="${cfg.profile}"
            rsync="${pkgs.rsync}/bin/rsync"

            resolve_profile() {
              if [ "$requested" != "default" ]; then
                printf '%s\n' "$requested"
                return
              fi
              awk -F= '
                /^\[/ { path="" ; isdef=0 }
                /^Path=/ { path=$2 }
                /^Default=1/ { isdef=1 }
                isdef==1 && path!="" { print path; exit }
              ' "$profiles_ini"
            }

            rel="$(resolve_profile)"
            if [ -z "''${rel:-}" ]; then
              echo "natsumi: could not resolve profile '$requested' via $profiles_ini" >&2
              exit 1
            fi

            profile_dir="$profiles_root/$rel"
            chrome_dir="$profile_dir/chrome"
            mkdir -p "$chrome_dir/utils" "$chrome_dir/natsumi"
            chmod -R u+w "$chrome_dir"

            # fx-autoconfig profile-side loader (includes module_loader.mjs,
            # which the upstream install guide forgets to mention but is
            # required for Natsumi's modules to actually load), plus its
            # own CSS/ and resources/ scaffold folders -- Natsumi's chrome.
            # manifest loads through these, not through files of its own.
            # Synced, not overlaid: a file removed upstream gets removed
            # here too.
            "$rsync" -a --delete ${cfg.fxAutoconfigSource}/profile/chrome/utils/. "$chrome_dir/utils/"
            "$rsync" -a --delete ${cfg.fxAutoconfigSource}/profile/chrome/CSS/. "$chrome_dir/CSS/"
            "$rsync" -a --delete ${cfg.fxAutoconfigSource}/profile/chrome/resources/. "$chrome_dir/resources/"

            # Natsumi itself goes into chrome/natsumi/ (its own subfolder,
            # not flattened into chrome/ root) -- synced at exactly the
            # commit this flake is pinned to.
            "$rsync" -a --delete ${cfg.natsumiSource}/. "$chrome_dir/natsumi/"
            chmod -R u+w "$chrome_dir"

            # Marker: fingerprint of the currently-synced natsumi source
            # (its Nix store path, which changes whenever flake.lock points
            # at a different commit), so it's obvious at a glance whether a
            # rebuild actually picked up a newer pin.
            echo "${builtins.baseNameOf (toString natsumi)}" > "$chrome_dir/.natsumi-commit"

            cat > "$chrome_dir/utils/chrome.manifest" <<'EOF'
            content userchromejs ./
            content userscripts ../natsumi/scripts/
            skin userstyles classic/1.0 ../CSS/
            content userchrome ../resources/
            content natsumi ../natsumi/
            content natsumi-icons ../natsumi/icons/
            EOF

            # userChrome.css/userContent.css are ignored by default on
            # every Firefox-family browser (not just LibreWolf) until this
            # is flipped on -- do it once per profile, don't duplicate it
            # on repeat activation.
            user_js="$profile_dir/user.js"
            touch "$user_js"
            if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$user_js" 2>/dev/null; then
              echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$user_js"
            fi

            rm -rf "$profile_dir/startupCache" 2>/dev/null || true
          '';
        in
        {
          options.programs.natsumi = {
            enable = mkEnableOption "fx-autoconfig + Natsumi theme for a Firefox-based browser";

            browser = mkOption {
              type = types.enum ([ "" ] ++ builtins.attrNames browserPresets);
              default = "";
              example = "librewolf";
              description = ''
                Pick a Natsumi-supported browser and everything else (nixpkgs
                package, install method, profiles directory) is filled in
                automatically. Supported: ${concatStringsSep ", " (builtins.attrNames browserPresets)}.
                Zen Browser is intentionally not listed -- Natsumi doesn't
                support it upstream. Leave as `""` for manual mode.
              '';
            };

            homeDirectory = mkOption {
              type = types.str;
              default = "/root";
              description = ''
                NixOS-module mode only: which user's $HOME to install into
                (profiles live under $HOME, not anywhere the NixOS module
                can infer on its own). Ignored by the home-manager module,
                which always uses the current user's home.home.homeDirectory.
              '';
            };

            profile = mkOption {
              type = types.str;
              default = "default";
              description = ''
                Which profile to install into. Use "default" to auto-resolve
                the profile marked `Default=1` in profiles.ini, or give an
                explicit profile directory name.
              '';
            };

            profilesDirectory = mkOption {
              type = types.str;
              default = "${homeDir}/.mozilla/firefox";
              description = "Path to the profiles root (contains profiles.ini). Auto-set when `browser` is used.";
            };

            fxAutoconfigSource = mkOption {
              type = types.path;
              default = fx-autoconfig;
              description = "Source tree for fx-autoconfig (defaults to this flake's pinned input).";
            };

            natsumiSource = mkOption {
              type = types.path;
              default = natsumi;
              description = "Source tree for Natsumi Browser (defaults to this flake's pinned input).";
            };

            desktopNameSuffix = mkOption {
              type = types.str;
              default = " (Natsumi)";
              description = ''
                Appended to the .desktop entry's `Name=` line so this build
                is distinguishable in an app launcher from a separately
                installed stock copy of the same browser -- e.g. "Firefox"
                becomes "Firefox (Natsumi)". There's no reliable way for a
                pure Nix build to detect whether a stock copy already
                happens to be installed elsewhere on the system, so this
                defaults to on; set to `""` to keep the plain name.
              '';
            };

            method = mkOption {
              type = types.enum [ "wrapFirefox" "directPatch" ];
              default = "wrapFirefox";
              description = ''
                Manual mode only (`browser = ""`): "wrapFirefox" uses
                nixpkgs' `wrapFirefox`'s `extraPrefsFiles` (works for any
                browser built with an `*-unwrapped`/wrapper split).
                "directPatch" clones and patches the package directly
                (works even for a prebuilt binary package).
              '';
            };

            unwrappedPackage = mkOption {
              type = types.package;
              default = pkgs.firefox-unwrapped;
              example = literalExpression "pkgs.librewolf-unwrapped";
              description = ''
                Manual mode only: the browser derivation to install into --
                unwrapped if `method = "wrapFirefox"`, or the package to
                clone-and-patch directly if `method = "directPatch"`.
              '';
            };

            wrapper = mkOption {
              type = types.functionTo (types.functionTo types.package);
              default = pkgs.wrapFirefox;
              defaultText = literalExpression "pkgs.wrapFirefox";
              description = "Manual mode only, `method = \"wrapFirefox\"`: the wrap function, called as `wrapper unwrappedPkg wrapperArgs`.";
            };

            wrapperArgs = mkOption {
              type = types.attrs;
              default = { };
              description = "Manual mode only: extra attrset passed to `wrapper` (e.g. `extraPolicies`, more `extraPrefsFiles`).";
            };

            package = mkOption {
              type = types.package;
              default = resolvedPackage;
              readOnly = true;
              description = "The resulting browser package, ready to run with fx-autoconfig + Natsumi installed.";
            };
          };

          config = mkIf cfg.enable (mkMerge [
            (mkIf hasPreset {
              programs.natsumi.profilesDirectory = mkDefault preset.profilesDirectory;
              programs.natsumi.method = mkDefault preset.method;
              programs.natsumi.unwrappedPackage = mkDefault (
                if preset.method == "wrapFirefox" then preset.unwrapped else preset.package
              );
              programs.natsumi.wrapper = mkIf (preset.method == "wrapFirefox") (mkDefault preset.wrapper);
            })

            (if isHomeManager
              then { home.packages = [ cfg.package ]; }
              else { environment.systemPackages = [ cfg.package ]; })

            (let
              script = ''
                ${installProfileScript} \
                  "${cfg.profilesDirectory}/profiles.ini" "${cfg.profilesDirectory}"
              '';
            in
              if isHomeManager
              then {
                home.activation.installNatsumiProfile =
                  config.lib.dag.entryAfter [ "writeBoundary" ] ''
                    $DRY_RUN_CMD ${script}
                  '';
              }
              else {
                system.activationScripts.installNatsumiProfile = {
                  text = script;
                };
              })
          ]);
        };
    in
    {
      nixosModules.default = mkNatsumiModule { isHomeManager = false; };
      homeManagerModules.default = mkNatsumiModule { isHomeManager = true; };
    };
}
