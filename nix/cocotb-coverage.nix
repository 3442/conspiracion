{ buildPythonPackage
, cocotb
, fetchPypi
, lib
, python-constraint
, pyyaml
}:
let
  pname = "cocotb-coverage";
  version = "1.2.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CsCvWb6XrKSOuFKBdEKxXWQvDrSQX7qPvZ7j2mpANlw=";
  };

  propagatedNativeBuildInputs = [
    cocotb
    python-constraint
    pyyaml
  ];

  meta = {
    description = "Functional Coverage and Constrained Randomization Extensions for Cocotb";
    homepage = "https://github.com/mciepluc/${pname}";
    license = lib.licenses.bsd2;
  };
}
