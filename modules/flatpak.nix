{ config, pkgs, lib, ... }:

let
  pkgList = import ./flatpak.packages.nix;

  cfg = {
    options.custom.flatpakSyncScript = lib.mkOption {
      type = lib.types.package;
      internal = true;
      readOnly = true;
      default = syncFlatpakAppsScript;
      description = "Script that syncs Flatpaks into flatpak.packages.nix and auto-commits.";
    };

    config = {
      environment.systemPackages = [ syncFlatpakAppsScript ];

      services.flatpak = {
        remotes = lib.mkOptionDefault [
          {
            name = "cosmic";
            location = "https://apt.pop-os.org/cosmic/";
          }
        ];

        packages = pkgList.flathub ++ pkgList.cosmic;

        update.onActivation = false;
        uninstallUnmanaged = true;
      };
    };
  };

  syncFlatpakAppsScript = pkgs.writers.writePython3Bin "sync-flatpak-apps" {
    flakeIgnore = [ "E501" "W503" "W504" "E302" "E305" "W293" ];
  } ''
    import subprocess
    import re
    import os

    CONFIG_DIR = "/home/ayaan_mirza/nix-config"
    PACKAGES_NIX = os.path.join(CONFIG_DIR, "modules/flatpak.packages.nix")
    GIT_BIN = "${pkgs.git}/bin/git"

    def get_installed():
        out = subprocess.check_output(
            [
                "/run/current-system/sw/bin/flatpak",
                "list",
                "--app",
                "--columns=application,origin",
            ],
            text=True,
        )
        apps = {}
        for line in out.strip().splitlines():
            if not line.strip():
                continue
            app_id, origin = line.split("\t")
            apps[app_id.strip()] = origin.strip()
        return apps

    def parse_existing_packages(content):
        existing_flathub = set(re.findall(r'"([^"]+)"', content.split("flathub = [")[1].split("];")[0]))
        existing_cosmic = set(re.findall(r'appId\s*=\s*"([^"]+)";', content.split("cosmic = [")[1]))
        return existing_flathub, existing_cosmic

    def git_commit_and_push(added_apps, removed_apps):
        try:
            # Stage ONLY the flatpak.packages.nix file using absolute git path
            subprocess.run([GIT_BIN, "-C", CONFIG_DIR, "add", "modules/flatpak.packages.nix"], check=True)
            
            if len(added_apps) == 1 and len(removed_apps) == 0:
                msg = f"Add {list(added_apps)[0]}"
            elif len(removed_apps) == 1 and len(added_apps) == 0:
                msg = f"Remove {list(removed_apps)[0]}"
            else:
                msg = "Update Flatpak packages sync"

            subprocess.run([GIT_BIN, "-C", CONFIG_DIR, "commit", "-m", msg], check=True)
            
            # Push ONLY the specific file tracking the flatpak packages
            subprocess.run([GIT_BIN, "-C", CONFIG_DIR, "push", "origin", "HEAD:main"], check=True)
            print(f"sync-flatpak-apps: Successfully committed and pushed: {msg}")
        except subprocess.CalledProcessError as e:
            print(f"sync-flatpak-apps: Git operation failed: {e}")

    def main():
        with open(PACKAGES_NIX, "r") as f:
            content = f.read()

        installed = get_installed()
        actual_flathub = {app for app, origin in installed.items() if origin != "cosmic"}
        actual_cosmic = {app for app, origin in installed.items() if origin == "cosmic"}

        existing_flathub, existing_cosmic = parse_existing_packages(content)

        if actual_flathub == existing_flathub and actual_cosmic == existing_cosmic:
            return

        all_actual = actual_flathub.union(actual_cosmic)
        all_existing = existing_flathub.union(existing_cosmic)
        
        added_apps = all_actual - all_existing
        removed_apps = all_existing - all_actual

        flathub_lines = [f'    "{app}"' for app in sorted(actual_flathub)]
        cosmic_lines = [f'    {{ appId = "{app}"; origin = "cosmic"; }}' for app in sorted(actual_cosmic)]

        new_content = (
            "{\n  flathub = [\n" +
            "\n".join(flathub_lines) +
            "\n  ];\n\n  cosmic = [\n" +
            "\n".join(cosmic_lines) +
            "\n  ];\n}\n"
        )

        with open(PACKAGES_NIX, "w") as f:
            f.write(new_content)

        print(f"sync-flatpak-apps: successfully synced {len(installed)} total app(s).")
        git_commit_and_push(added_apps, removed_apps)

    if __name__ == "__main__":
        main()
  '';
in
cfg