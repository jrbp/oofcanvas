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
      default = self.packages.${system}.oofCanvas;
      oofCanvas = pkgs.stdenv.mkDerivation {
        pname = "oofCanvas";
        version = "1.2.0";

        src = ./.;

        nativeBuildInputs = with pkgs; [
          cmake
          pkg-config
        ];
        buildInputs = with pkgs; [
          openblas
          gtk3
          swig
          cairomm
          pango
          pythonEnv
          python3Packages.pygobject3 # needed by pkgconf (not just python) so we expose here
        ];

        meta = with pkgs.lib; {
          description = "OOFCanvas: A replacement for libgnomecanvas built for OOF2";
          license = licenses.nistSoftware;
          platforms = platforms.linux;
        };
      };
      oofCanvasPython = let
        oofcnv = self.packages.${system}.oofCanvas;
      in
        pkgs.python3.pkgs.buildPythonPackage {
          pname = "oofCanvasPython";
          inherit (oofcnv) version;
          dontUnpack = true;
          format = "other";
          installPhase = ''
            mkdir -p $out/${pkgs.python3.sitePackages}
            for f in ${oofcnv}/${pkgs.python3.sitePackages}/*; do
              ln -s "$f" $out/${pkgs.python3.sitePackages}/
            done
          '';
          propagatedBuildInputs = [oofcnv];
        };
    });
    devShells = eachSupportedSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      pkgs.mkShell {
        inputsFrom = [self.packages.${system}.default];
      });
  };
}
