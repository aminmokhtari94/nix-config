{ lib, fetchFromGitHub, stdenv, pkgconfig, nodejs }:

stdenv.mkDerivation {
  pname = "oblivion-desktop";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "bepass-org";
    repo = "oblivion-desktop";
    rev = "v${version}";
    sha256 = "06wb8d6pvl70aqyz9dal4b4acc50lvgigcywi0p7swnmzayjd5il";
  };

  buildInputs = [ nodejs pkgconfig ];

  # Define the build phase
  buildPhase = ''
    echo "Building ${pname} version ${version}"
    cd ${src}/app
    npm install
    npm run build
  '';

  # Define the install phase
  installPhase = ''
    echo "Installing ${pname} version ${version}"
    mkdir -p $out/bin
    cp -r ${src}/dist/* $out/bin/
  '';
}
