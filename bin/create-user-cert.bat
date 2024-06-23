@ECHO OFF
REM parameter 1 is the root ca name
REM parameter 2 is the intermediate ca name
REM parameter 3 is the user name

SET ROOT_NAME=%1
SET INTERMEDIATE_NAME=%2
SET USER_NAME=%3
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

IF %USER_NAME%name == name (
  GOTO :usage
)

ECHO ===========================================================================
ECHO create the user cert key
ECHO ===========================================================================
CALL openssl genrsa -aes256 -passout pass:redrover -out %INTERMEDIATE_DIR%/private/%USER_NAME%.key.pem 2048
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\private\%USER_NAME%.key.pem

ECHO ===========================================================================
ECHO create the no passphrase user key
ECHO ===========================================================================
CALL openssl rsa -passin pass:redrover -in %INTERMEDIATE_DIR%/private/%USER_NAME%.key.pem ^
    -out %INTERMEDIATE_DIR%/private/%USER_NAME%.keyNP.pem
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\private\%USER_NAME%.keyNP.pem

ECHO ===========================================================================
ECHO create the user certificate sign request
ECHO ===========================================================================
CALL openssl req -config %INTERMEDIATE_DIR%/openssl.cnf ^
    -passin pass:redrover -passout pass:redrover ^
    -key %INTERMEDIATE_DIR%/private/%USER_NAME%.key.pem ^
    -new -sha256 -out %INTERMEDIATE_DIR%/csr/%USER_NAME%.csr.pem
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\csr\%USER_NAME%.csr.pem

ECHO ===========================================================================
ECHO create the sign the user certificate
ECHO ===========================================================================
CALL openssl ca -config %INTERMEDIATE_DIR%/openssl.cnf -extensions usr_cert -days 1000 ^
    -passin pass:redrover -notext -md sha256 -in %INTERMEDIATE_DIR%/csr/%USER_NAME%.csr.pem ^
    -out %INTERMEDIATE_DIR%/certs/%USER_NAME%.cert.pem
CALL %VAULT_DIR%\bin\dos2unix-cmd %INTERMEDIATE_DIR%\certs\%USER_NAME%.cert.pem

ECHO ===========================================================================
ECHO create the user certificate pfx
ECHO ===========================================================================
CALL openssl pkcs12 -inkey %INTERMEDIATE_DIR%/private/%USER_NAME%.key.pem ^
    -passin pass:redrover -passout pass:redrover -password pass:redrover ^
    -in %INTERMEDIATE_DIR%/certs/%USER_NAME%.cert.pem -export ^
    -out %INTERMEDIATE_DIR%/certs/%USER_NAME%.pfx

ECHO ===========================================================================
ECHO display the certificate and verify
ECHO ===========================================================================
CALL openssl x509 -noout -text -in %INTERMEDIATE_DIR%/certs/%USER_NAME%.cert.pem
CALL openssl verify -CAfile %INTERMEDIATE_DIR%/certs/%INTERMEDIATE_NAME%-ca-chain.cert.pem %INTERMEDIATE_DIR%/certs/%USER_NAME%.cert.pem

GOTO :end

:usage
ECHO Usage: create-user-cert rootCa intermediateCa userName
ECHO   where rootCa is the name of the root certificate authority - a directory by the same name must exist in the certvault.
ECHO         intermediateCa is the name of the intermediate certificate authority - a directory by the same name must exist below the rootCa.
ECHO         userName is the name of the user (10 digit number for AMC CAC) and will be used as the CN (common name)

:end
SET ROOT_NAME=
SET INTERMEDIATE_NAME=
SET INTERMEDIATE_DIR=
SET USER_NAME=
SET VAULT_DIR=
