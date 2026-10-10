{
  description = "Nix package and flake for PdfCraft — an open-source PDF workbench built in pure Rust";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        pdfcraft = pkgs.callPackage ./pkgs/pdfcraft { };
        default = pdfcraft;
      });

      apps = forAllSystems (pkgs: rec {
        pdfcraft = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.pdfcraft}/bin/pdfcraft";
        };
        pdfcraft-cli = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.pdfcraft}/bin/pdfcraft-cli";
        };
        default = pdfcraft;
      });

      overlays.default = final: prev: {
        pdfcraft = final.callPackage ./pkgs/pdfcraft { };
      };

      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.pdfcraft;
        in
        {
          options.programs.pdfcraft = {
            enable = lib.mkEnableOption "PdfCraft PDF workbench";
            package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} "pdfcraft" { };
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [ cfg.package ];
          };
        };

      homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.pdfcraft;
        in
        {
          options.programs.pdfcraft = {
            enable = lib.mkEnableOption "PdfCraft PDF workbench";
            package = lib.mkPackageOption self.packages.${pkgs.stdenv.hostPlatform.system} "pdfcraft" { };
          };

          config = lib.mkIf cfg.enable {
            home.packages = [ cfg.package ];
          };
        };
    };
}
