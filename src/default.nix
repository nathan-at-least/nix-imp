let
  inherit (builtins) pathExists readDir typeOf;
  inherit (import <nixpkgs> {}) lib;
  inherit (lib.strings) hasPrefix removePrefix;

  mkImp = root: dir: impSpec:
    assert fsKind root == "directory";
    assert fsKind dir == "directory";
    assert typeOf impSpec == "string";

    if hasPrefix "/" impSpec
    then impFrom root root (removePrefix "/" impSpec)
    else impFrom root dir impSpec;

  impFrom = root: base: impSpec:
    assert fsKind root == "directory";
    assert fsKind base == "directory";
    assert typeOf impSpec == "string";

    let
      subp = base + "/${impSpec}";
      fileCandidate = subp + ".nix";
      defCandidate = subp + "/default.nix";
    in if pathExists fileCandidate
    then imp root (dirOf fileCandidate) fileCandidate
    else if pathExists defCandidate
    then imp root subp defCandidate
    else impDirSet root subp;

  imp = root: dir: impPath:
    assert fsKind root == "directory";
    assert fsKind dir == "directory";
    assert typeOf impPath == "path";
    import impPath (mkImp root dir);

  impDirSet = root: dir:
    assert fsKind root == "directory";
    assert fsKind dir == "directory";
    let
      inherit (lib.attrsets) filterAttrs mapAttrs';
      inherit (lib.strings) hasSuffix removeSuffix;

      impEntry = n: kind:
        if kind == "directory" || kind == "regular" && hasSuffix ".nix" n
        then rec {
          name = removeSuffix ".nix" n;
          value = mkImp root dir name;
        }
        else {
          name = n;
          value = {};
        };

      unfiltered = mapAttrs' impEntry (readDir dir);
    in
      filterAttrs (_: v: v != {}) unfiltered;

  fsKind = p:
    assert typeOf p == "path";
    assert pathExists p;
    let
      entries = readDir (dirOf p);
      fname = baseNameOf p;
    in
      entries."${fname}";

in
  projDir: mkImp projDir projDir
