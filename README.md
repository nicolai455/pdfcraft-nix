# pdfcraft-nix

Nix package, flake, and modules for [PdfCraft](https://github.com/storytold/pdfcraft) — a native, open-source PDF workbench reimplementation of Adobe Acrobat built in pure Rust.

## Features

- Complete desktop package including GUI (`pdfcraft`), CLI (`pdfcraft-cli`), desktop file, icons, MIME types, and offline Scan & OCR models.
- Pre-configured runtime library dependencies (Wayland, X11, OpenGL, Vulkan, fontconfig, DBus).
- Native Nix flake supporting `x86_64-linux` and `aarch64-linux`.
- NixOS and Home Manager modules included.

## Quick Run

Run without installing:

```bash
nix run github:nicolai455/pdfcraft-nix
```

Run the headless CLI / MCP server:

```bash
nix run github:nicolai455/pdfcraft-nix#pdfcraft-cli -- --help
```

## Using in a Flake

### Flake Input

```nix
inputs = {
  pdfcraft = {
    url = "github:nicolai455/pdfcraft-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### NixOS Module

```nix
{ inputs, ... }: {
  imports = [
    inputs.pdfcraft.nixosModules.default
  ];

  programs.pdfcraft.enable = true;
}
```

### Home Manager Module

```nix
{ inputs, ... }: {
  imports = [
    inputs.pdfcraft.homeManagerModules.default
  ];

  programs.pdfcraft.enable = true;
}
```

### As an Overlay

```nix
{
  nixpkgs.overlays = [
    inputs.pdfcraft.overlays.default
  ];
}
```

## Building Locally

```bash
nix build
./result/bin/pdfcraft --version
./result/bin/pdfcraft-cli --version
```
