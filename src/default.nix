let
  inherit (builtins) pathExists typeOf;
  inherit (import <nixpkgs> {}) lib;
  inherit (lib.strings) hasPrefix removePrefix;

  mkImp = root: dir: impSpec:
    assert typeOf root == "path";
    assert typeOf dir == "path";
    assert typeOf impSpec == "string";

    if hasPrefix "/" impSpec
    then impFrom root root (removePrefix "/" impSpec)
    else impFrom root dir impSpec;

  impFrom = root: base: impSpec:
    let
      subp = base + "/${impSpec}";
      fileCandidate = subp + ".nix";
      dirCandidate = subp + "/default.nix";
    in if pathExists fileCandidate
    then imp root (dirOf fileCandidate) fileCandidate
    else imp root dirCandidate dirCandidate;

  imp = root: dir: impPath:
    assert typeOf root == "path";
    assert typeOf dir == "path";
    assert typeOf impPath == "path";
    import impPath (mkImp root dir);

in
  projDir: mkImp projDir projDir
