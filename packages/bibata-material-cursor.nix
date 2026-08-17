{ lib, stdenv, fetchurl }:

# Ayaan's fork of Bibata cursors using Material Design 3's tonal system:
# https://github.com/SakibShahariar/material-bibata-cursor
#
# This is NOT the nixpkgs `bibata-cursors` package (upstream ful1e5's repo) —
# that project has no Material/Slate/Apricot/etc variants. Packaged from the
# prebuilt release tarball since the fork ships precompiled XCursor +
# hyprcursor binaries; no build step needed here.
#
# GitHub release assets are immutable per-tag, so "latest" isn't something
# Nix can track automatically while staying reproducible — bump `version`
# and `hash` below when a new release drops. To get the new hash:
#   nix-prefetch-url --type sha256 <asset-url>
# then convert to SRI with:
#   nix hash convert --hash-algo sha256 <hash>

stdenv.mkDerivation rec {
  pname = "bibata-material-cursor";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/SakibShahariar/material-bibata-cursor/releases/download/v${version}/bibata-material-v${version}.tar.gz";
    hash = "sha256-/B/l+F3CVmJkwPJv/meabvkVpZbXa8Tt7O2MyANheXk=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -r Bibata-Material-* $out/share/icons/
    runHook postInstall
  '';

  meta = with lib; {
    description = "28 Bibata cursor themes using Material Design 3's tonal system (Ayaan's fork)";
    homepage = "https://github.com/SakibShahariar/material-bibata-cursor";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
