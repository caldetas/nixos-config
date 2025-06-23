{
  description = "Python dev env with forced future support for Python 3.13";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      #overlay to get future with python313, required by seahub
      overlay = final: prev: {
        python313Packages = prev.python313Packages.overrideScope' (pyFinal: pyPrev: {
          future = pyPrev.future.overridePythonAttrs (old: {
            meta = old.meta // {
              broken = false;
              unsupportedInterpreters = [ ]; # force allow all interpreters
            };
          });
        });
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };

      mkPyEnv = python: python.withPackages (ps: with ps; [
        pip
        future
      ]);
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = [ (mkPyEnv pkgs.python310) ];
        };

        py311 = pkgs.mkShell {
          buildInputs = [ (mkPyEnv pkgs.python311) ];
        };

        py313 = pkgs.mkShell {
          buildInputs = [ (mkPyEnv pkgs.python313) ];
        };
      };
    };
}
