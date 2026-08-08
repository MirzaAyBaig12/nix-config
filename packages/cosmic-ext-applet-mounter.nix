# Builds cosmic-ext-applet-mounter from a pinned amd64 .deb release
# (https://github.com/uutzinger/cosmic-ext-applet-mounter). To bump to a
# new release: update `version` and `debName` below, run `nix-rebuild`,
# let it fail with the real hash ("got: sha256-..."), then paste that
# into `hash`. Same workflow as cosmic-ext-control-center.nix.
{ lib
, stdenv
, fetchurl
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
  version = "0.4.3";
  debName = "cosmic-ext-applet-mounter_${version}_amd64.deb";

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
  inherit version;

  src = fetchurl {
    url = "https://github.com/uutzinger/cosmic-ext-applet-mounter/releases/download/v${version}/${debName}";
    hash = "sha256-acibGw2RtfnhCk9usYFv8pTPDoeMfDndGvSMzDgpzis=";
  };

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
