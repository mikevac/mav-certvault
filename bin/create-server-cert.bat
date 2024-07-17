@ECHO OFF
REM parameter 1 is the root ca name
REM parameter 2 is the intermediate ca name
REM parameter 3 is the server host name

SET ROOT_NAME=%1
SET INTERMEDIATE_NAME=%2
SET SERVER_NAME=%3
SET VAULT_DIR=%CD%

IF %ROOT_NAME%name == name (
  GOTO :usage
)

IF NOT EXIST %ROOT_NAME% (
  ECHO The root ca %ROOT_NAME% does not exist.
  GOTO :end
)

IF %INTERMEDIATE_NAME%name == name (
  GOTO :usage
)

SET INTERMEDIATE_DIR=%ROOT_NAME%\%INTERMEDIATE_NAME%

IF NOT EXIST %INTERMEDIATE_DIR% (
  ECHO The intermediate ca %INTERMEDIATE_NAME% does not exist under %ROOT_NAME%
  GOTO :end
)

IF %SERVER_NAME%name == name (
  GOTO :usage
)
ECHO ===========================================================================
ECHO create the server certificate key
ECHO ===========================================================================
CALL openssl genrsa -aes256 -passout pass:redrover -out %INTERMEDIATE_DIR%/private/%SERVER_NAME%.key.pem 2048
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\private\%SERVER_NAME%.key.pem

ECHO ===========================================================================
ECHO create the no passphrase server certificate key
ECHO ===========================================================================
CALL openssl rsa -passin pass:redrover -in %INTERMEDIATE_DIR%/private/%SERVER_NAME%.key.pem ^
    -out %INTERMEDIATE_DIR%/private/%SERVER_NAME%.keyNP.pem
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\private\%SERVER_NAME%.keyNP.pem

ECHO ===========================================================================
ECHO create the server certificate sign request
ECHO ===========================================================================
CALL openssl req -config %INTERMEDIATE_DIR%/openssl.cnf ^
    -addext "subjectAltName = DNS:localhost" ^
    -passin pass:redrover -passout pass:redrover ^
    -key %INTERMEDIATE_DIR%/private/%SERVER_NAME%.key.pem -new -sha256 ^
    -out %INTERMEDIATE_DIR%/csr/%SERVER_NAME%.csr.pem
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\csr\%SERVER_NAME%.csr.pem
ECHO ===========================================================================
ECHO create the intermediate key
ECHO ===========================================================================
CALL openssl ca -config %INTERMEDIATE_DIR%/openssl.cnf -extensions dual_cert ^
    -passin pass:redrover -days 3650 -notext -md sha256 -in %INTERMEDIATE_DIR%/csr/%SERVER_NAME%.csr.pem ^
    -out %INTERMEDIATE_DIR%/certs/%SERVER_NAME%.cert.pem
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\certs\%SERVER_NAME%.cert.pem

ECHO ===========================================================================
ECHO create the intermediate key
ECHO ===========================================================================
CALL openssl pkcs12 -inkey %INTERMEDIATE_DIR%/private/%SERVER_NAME%.key.pem ^
     -passin pass:redrover -passout pass:redrover -password pass:redrover ^
     -in %INTERMEDIATE_DIR%/certs/%SERVER_NAME%.cert.pem -export ^
     -out %INTERMEDIATE_DIR%/certs/%SERVER_NAME%.pfx

GOTO :end

:usage
ECHO Usage: create-server-cert rootCa intermediateCa hostName
ECHO   where rootCa is the name of the root certificate authority - a directory by the same name must exist in the certvault.
ECHO         intermediateCa is the name of the intermediate certificate authority - a directory by the same name must exist below the rootCa.
ECHO         hostName is the name of the host and will be used as the CN (common name)

:end
SET ROOT_NAME=
SET INTERMEDIATE_NAME=
SET INTERMEDIATE_DIR=
SET SERVER_NAME=
SET VAULT_DIR=
