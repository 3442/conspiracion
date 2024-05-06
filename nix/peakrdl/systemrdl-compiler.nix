{ antlr4-python3-runtime
, buildPythonPackage
, colorama
, fetchPypi
, lib
, markdown
}:
let
  pname = "systemrdl-compiler";
  version = "1.27.3";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-22g1S/8ZTMcjbtaLrGTFu4GpoXtbp7bzezAHilClOj4=";
  };

  propagatedBuildInputs = [
    antlr4-python3-runtime
    colorama
    markdown
  ];

  meta = {
    description = "Parse and elaborate front-end for SystemRDL 2.0";
    changelog = "https://github.com/SystemRDL/${pname}/releases/tag/v${version}";
    homepage = "https://github.com/SystemRDL/${pname}";
    license = lib.licenses.mit;
  };
}
