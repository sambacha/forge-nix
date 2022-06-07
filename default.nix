{pkgs ? (import ./pkgs.nix).pkgs}:
with pkgs; let
  version = "0.1.0";

  meta = with stdenv.lib; {
    description = "Generate a nix expressions for foundry repos";
    homepage = "https://github.com/sambacha/forge2nix";
    license = licenses.unlicense;
    maintainers = [
      {
        email = "sam@manifoldfinance.com";
        github = "manifoldfinance";
        name = "Janitor";
      }
    ];
  };

  forge2nix = stdenv.mkDerivation {
    name = "forge2nix-${version}";
    src = ./src;

    nativeBuildInputs = [makeWrapper shellcheck];

    phases = ["unpackPhase" "installPhase" "fixupPhase" "checkPhase"];

    installPhase = ''
      mkdir -p $out/{bin,lib}
      cp forge2.nix $out/lib/forge2.nix
      cp forge2nix $out/bin
      wrapProgram $out/bin/forge2nix \
        --set-default NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
        --set FOUNDRY2NIX_VERSION "${version}" \
        --set FOUNDRY2NIX_FORMAT_VERSION 1 \
        --set FOUNDRY2NIX_EXPR "$out/lib/forge2.nix" \
        --set PATH ${lib.makeBinPath [coreutils utillinux gnused git jq]}
    '';

    doCheck = false;
    checkPhase = ''
      shellcheck -x forge2nix
    '';

    passthru = {inherit forge2nix;};

    inherit meta;
  };
in
  forge2nix
