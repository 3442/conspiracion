{ buildPythonPackage
, callPackage
, fetchPypi
, jinja2
, lib
, setuptools
, setuptools-scm
}:
let
  pname = "peakrdl-regblock";
  version = "0.22.0";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-N+YZSuHdSSMCmgko5YZpa7wDj3vMy2J7prPdfjj53GA=";
  };

  patches = [
    ./0001-Add-verilator-MULTIDRIVEN-hack.patch
  ];

  propagatedBuildInputs = [
    jinja2
    (callPackage ./systemrdl-compiler.nix { })
  ];

  propagatedNativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  meta = {
    description = "Compile SystemRDL into a SystemVerilog control/status register (CSR) block";
    changelog = "https://github.com/SystemRDL/${pname}/releases/tag/v${version}";
    homepage = "https://github.com/SystemRDL/${pname}";
    license = lib.licenses.gpl3;
  };
}
