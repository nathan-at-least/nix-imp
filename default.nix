let
  inherit (import <nixpkgs> {}) stdenv writeScript;
in
  stdenv.mkDerivation rec {
    pname = "nix-imp";
    version = "0.1.0";
    src = ./src;
    builder = writeScript "${pname}-${version}-builder.sh" ''
      source "$stdenv/setup"
      cp -r "$src" "$out"
      chmod -R u+w "$out" # Workaround for https://github.com/NixOS/nix/pull/3321
    '';
  }
