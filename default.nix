let
  inherit (import <nixpkgs> {}) stdenv writeScript;
in
  stdenv.mkDerivation rec {
    pname = "nix-imp";
    version = "0.1.0";
    src = ./src;
    builder = writeScript "${pname}-${version}-builder.sh" ''
      cp -r "$src" "$out"
    '';
  }
