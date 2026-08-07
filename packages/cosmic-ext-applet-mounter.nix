# Builds cosmic-ext-applet-mounter from the *latest* GitHub release's amd64
# .deb (https://github.com/uutzinger/cosmic-ext-applet-mounter). No hash
# pinning — this hits the GitHub API at eval time, so every
# `nixos-rebuild switch` grabs whatever the newest release is. That means
# this derivation is NOT fully reproducible (rebuilds can pull a different
# build over time), which is the tradeoff for true auto-update. Needs impure
# eval, which is the default for a non-flake-pure `nixos-rebuild switch`.
{ lib
, stdenv
, dpkg
, autoPatchelfHook
, wayland
, libxkbcommon
, fontconfig
, freetype
, libGL
, dbus
, systemd
}:

let
  latestRelease = builtins.fromJSON (builtins.readFile (builtins.fetchurl {
    url = "https://api.github.com/repos/uutzinger/cosmic-ext-applet-mounter/releases/latest";
  }));

  debAsset = builtins.head (builtins.filter
    (a: lib.hasSuffix "_amd64.deb" a.name)
    latestRelease.assets);

  debSrc = builtins.fetchurl { url = debAsset.browser_download_url; };

  runtimeLibs = [
    stdenv.cc.cc.lib
    wayland
    libxkbcommon
    fontconfig
    freetype
    libGL
    dbus
    systemd
  ];
in
stdenv.mkDerivation {
  pname = "cosmic-ext-applet-mounter";
  version = lib.removePrefix "v" latestRelease.tag_name;
  src = debSrc;

  nativeBuildInputs = [ dpkg autoPatchelfHook ];
  buildInputs = runtimeLibs;

  dontBuild = true;

  # The .deb just contains the built binary + desktop entry + metainfo +
  # icon under usr/ — dpkg-deb -x pulls that out flat, no dpkg install
  # step needed. autoPatchelfHook (nativeBuildInputs above) then patches
  # the binary's interpreter/rpath so it can find glibc + friends on
  # NixOS, same as it would for any foreign dynamically-linked binary.
  unpackPhase = ''
    mkdir -p extracted
    dpkg-deb -x $src extracted
  '';

  installPhase = ''
    mkdir -p $out
    cp -r extracted/usr/* $out/
  '';

  meta = {
    description = "COSMIC Desktop Cloud Storage Mounting Applet";
    homepage = "https://github.com/uutzinger/cosmic-ext-applet-mounter";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
