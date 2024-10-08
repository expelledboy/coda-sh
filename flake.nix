{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs { inherit system; };

        coda-cli = pkgs.stdenv.mkDerivation {
          pname = "coda";
          version = "0.1.1";
          src = ./src;
          buildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/{bin,libexec}
            install -m755 ./libexec/* $out/libexec
            install -m755 ./bin/coda.sh $out/bin/coda
            chmod +x $out/bin/coda
          '';
          postFixup = ''
            wrapProgram $out/bin/coda \
              --set LIBEXEC_PATH $out/libexec \
              --set SCRIPT coda
          '';
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = (with pkgs; [
            bashInteractive
            editorconfig-checker
            just
            curl
            parallel
            (bats.withLibraries (libexec: with libexec; [
              bats-support
              bats-assert
            ]))
          ]) ++ [
            self.packages.${system}.coda-cli
          ];

          shellHook = ''
            git config --local core.hooksPath .github/hooks
          '';
        };

        packages = {
          inherit coda-cli;
        };
      }) // {
        overlay = final: prev: {
          coda-cli = self.packages.${final.system}.coda-cli;
        };
      };
}
