{ buildPythonPackage
, cocotb
, fetchPypi
, lib
, pylint
, pytest
, sphinx
}: let
  pname = "pyuvm";
  version = "2.9.1";
in buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2Td+rRsgygwZ7iHY7LzfQRlJ0oxJ49URn4A+EgaeKuo=";
  };

  propagatedBuildInputs = [
    cocotb
    pytest
  ];

  propagatedNativeBuildInputs = [
    pylint
    sphinx
  ];

  meta = {
    description = "pyuvm is the Universal Verification Methodology implemented in Python instead of SystemVerilog";
    changelog = "https://github.com/pyuvm/pyuvm/releases/tag/${version}";
    homepage = "https://github.com/pyuvm/pyuvm";
    license = lib.licenses.asl20;
  };
}
