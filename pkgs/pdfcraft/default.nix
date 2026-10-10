{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  # Runtime libraries dynamically loaded by wgpu / egui / Wayland / X11 / fontconfig / dbus
  libGL,
  libxkbcommon,
  wayland,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxrender,
  libxcb,
  vulkan-loader,
  fontconfig,
  dbus,
}:
let
  version = "0.5.0";
  sources = {
    x86_64-linux = {
      url = "https://github.com/storytold/pdfcraft/releases/download/v${version}/pdfcraft-${version}-linux-x86_64.tar.gz";
      hash = "sha256-ILNbP9CZwO8Cpye/m6267rZjnFZ0K00ERMwpdNv/X98=";
    };
    aarch64-linux = {
      url = "https://github.com/storytold/pdfcraft/releases/download/v${version}/pdfcraft-${version}-linux-aarch64.tar.gz";
      hash = "sha256-J+WLjrrOvKbE5LMRCr0HelysAXCYcinT7Gncs1/LT4Q=";
    };
  };

  srcInfo = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  runtimeLibs = [
    libGL
    libxkbcommon
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    libxrender
    libxcb
    vulkan-loader
    fontconfig
    dbus
  ];
in
stdenv.mkDerivation {
  pname = "pdfcraft";
  inherit version;

  src = fetchurl {
    inherit (srcInfo) url hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ] ++ runtimeLibs;

  appendRunpaths = map (pkg: "${lib.getLib pkg}/lib") runtimeLibs;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r bin share $out/

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/pdfcraft \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
  '';

  meta = with lib; {
    description = "Open-source PDF workbench reimplementation of Adobe Acrobat in pure Rust";
    homepage = "https://github.com/storytold/pdfcraft";
    license = with licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "pdfcraft";
  };
}
