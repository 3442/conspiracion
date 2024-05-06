{ buildPythonPackage
, fetchPypi
, lib
, setuptools
, setuptools-scm
}:
let
  pname = "peakrdl";
  version = "1.1.0";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-ZiqdXOaovFnOymvUQvT76OSwHlP+FLm/fuj5H/bY10w=";
  };

  propagatedNativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  meta = {
    description = "PeakRDL is a free and open-source control & status register (CSR) toolchain";
    changelog = "https://github.com/SystemRDL/${pname}/releases/tag/v${version}";
    homepage = "https://github.com/SystemRDL/${pname}";
    license = lib.licenses.gpl3;
  };
}
