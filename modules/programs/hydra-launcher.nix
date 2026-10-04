{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "hydra-launcher";
  version = "4.1.5";

  src = fetchurl {
    url = "https://github.com/hydralauncher/hydra/releases/download/v${version}/hydralauncher-${version}.AppImage";
    hash = lib.fakeHash;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 \
      ${appimageContents}/hydralauncher.desktop \
      $out/share/applications/Hydra-Launcher.desktop

    substituteInPlace $out/share/applications/Hydra-Launcher.desktop \
      --replace-fail 'Exec=hydralauncher' 'Exec=Hydra-Launcher'
  '';

  postInstall = ''
    ln -s $out/bin/hydralauncher $out/bin/Hydra-Launcher
  '';

  meta = {
    name = "Hydra Launcher";
    description = "Game launcher";
    homepage = "https://github.com/hydralauncher/hydra";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Hydra-Launcher";
  };
}