{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, makeWrapper
, wayland
, wayland-protocols
, libxkbcommon
, vulkan-loader
, libGL
, fontconfig
, freetype
, expat
, dbus
}:

let
  runtimeLibs = [
    wayland
    wayland-protocols
    libxkbcommon
    vulkan-loader
    libGL
    fontconfig
    freetype
    expat
    dbus
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "cosmic-ext-control-center";
  # Cargo.toml on main is already at 0.1.5 but that hasn't been tagged as a
  # release yet (latest tag is v0.1.4) — tracking `main` until it is.
  version = "0.1.5-unstable";

  src = fetchFromGitHub {
    owner = "Pyxyll";
    repo = "cosmic-ext-control-center";
    rev = "main";
    # Placeholder — `nixos-rebuild` will fail on the first build with the
    # real hash ("got: sha256-...") once you save this file. Paste it here
    # and rebuild again. Do this again any time you bump `rev`.
    hash = "sha256-Wc1av079Y4ZNcGp6uf7KAGPeBd/joDeS0ppwe+zR3bo=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    # libcosmic + cosmic-config are git deps (pop-os's repo), not on
    # crates.io, so the lockfile has no checksum for them — let Nix fetch
    # and hash those git revs itself instead of hand-pinning outputHashes.
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = runtimeLibs;

  # Mirrors `just install`: ship the two binaries plus the desktop entries
  # and AppStream metainfo so the applet shows up in COSMIC's "Add applet"
  # picker and the app launcher.
  postInstall = ''
    install -Dm0644 resources/com.pyxyll.CosmicExtControlCenter.desktop \
      $out/share/applications/com.pyxyll.CosmicExtControlCenter.desktop
    install -Dm0644 resources/com.pyxyll.CosmicExtControlCenterApplet.desktop \
      $out/share/applications/com.pyxyll.CosmicExtControlCenterApplet.desktop
    install -Dm0644 resources/com.pyxyll.CosmicExtControlCenter.metainfo.xml \
      $out/share/metainfo/com.pyxyll.CosmicExtControlCenter.metainfo.xml

    wrapProgram $out/bin/cosmic-ext-control-center \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
    wrapProgram $out/bin/cosmic-ext-control-center-applet \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}
  '';

  meta = {
    description = "A modular, pluggable control center for the COSMIC desktop";
    homepage = "https://github.com/Pyxyll/cosmic-ext-control-center";
    license = lib.licenses.mit;
    mainProgram = "cosmic-ext-control-center";
    platforms = lib.platforms.linux;
  };
}
