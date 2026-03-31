{
  description = "OOFCanvas: A replacement for libgnomecanvas built for OOF2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "i686-linux"];
    eachSupportedSystem = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = eachSupportedSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pythonEnv = pkgs.python3.withPackages (ps:
        with ps; [
          numpy
          scikit-image
          matplotlib
          pygobject3
        ]);
    in {
      default = self.packages.${system}.oof-canvas;
      oof-canvas = pkgs.stdenv.mkDerivation {
        pname = "oof-canvas";
        version = "1.2.1";

        src = ./.;

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
          python3Packages.pygobject3 # pkgconf needs to see this (not just python)
        ];
        buildInputs = with pkgs; [
          gtk3
          swig
          cairomm
          pango
          pythonEnv
        ];

        meta = with pkgs.lib; {
          description = "OOFCanvas: A replacement for libgnomecanvas built for OOF2";
          license = licenses.nistSoftware;
          platforms = platforms.linux;
        };
      };
    });
    devShells = eachSupportedSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      pkgs.mkShell {
        inputsFrom = [ self.packages.${system}.default ];
      });
  };
}
