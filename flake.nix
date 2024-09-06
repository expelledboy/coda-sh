{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            just
            curl
            parallel
            (bats.withLibraries (libexec: with libexec; [
              bats-support
              bats-assert
            ]))
          ];

          shellHook = ''
            git config --local core.hooksPath .github/hooks
          '';
        };
      });
}
