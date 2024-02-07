{
  # This has to be changed to the actual package description
  description = "Test for rust docs to github actions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustVersion = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          rustc = rustVersion;
          cargo = rustVersion;

        };
        myRustBuild = rustPlatform.buildRustPackage {
          # This has to be changed to the actual package name
          pname = "rust_docs_pages_test";
          version = "0.1.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
        };
      in {
        packages = { default = myRustBuild; };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (rustVersion.override {
              extensions = [ "rust-src" "rust-analyzer" "rustfmt" ];
            })
          ];
        };
      });
}
