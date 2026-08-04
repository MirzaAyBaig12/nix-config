{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, wayland
, libxkbcommon
, fontconfig
, freetype
, expat
, libGL
, vulkan-loader
, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname = "cosmic-ext-control-center";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "Pyxyll";
    repo = "cosmic-ext-control-center";
    rev = "v${version}";
    # Replace with the real hash after first build attempt fails and
    # nix tells you the correct one (or run:
    #   nix-prefetch-github Pyxyll cosmic-ext-control-center --rev v0.1.4
    # ahead of time to get it).
    hash = lib.fakeHash;
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [
    wayland
    libxkbcommon
    fontconfig
    freetype
    expat
    libGL
    vulkan-loader
  ];

  # libcosmic/iced-based GUI apps need these on the dynamic library
  # search path at runtime, not just build time.
  postFixup = ''
    for bin in $out/bin/*; do
      wrapProgram "$bin" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath buildInputs}
    done
  '';

  meta = with lib; {
    description = "A modular, pluggable control center for the COSMIC desktop (editor + panel applet)";
    homepage = "https://github.com/Pyxyll/cosmic-ext-control-center";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "cosmic-ext-control-center";
  };
}
