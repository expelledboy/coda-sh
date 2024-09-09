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
          version = "0.1.0";
          src = ./src;
          buildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/{bin,libexec}
            install -m755 ./libexec/* $out/libexec
            install -m755 ./bin/coda.sh $out/bin/coda
            chmod +x $out/bin/coda
          '';
          postInstall = ''
            wrapProgram $out/bin/coda \
              --set LIBEXEC_PATH $out/libexec
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
            coda-cli
          ];

          shellHook = ''
            git config --local core.hooksPath .github/hooks
          '';
        };

        packages.${system} = {
          inherit coda-cli;
        };
      });
}
