@ECHO OFF
cls

REM parameter 1 is the name of the root ca
REM Parameter 2 is the name of the intermediate ca (optional)

SET ROOT_NAME=%1
SET INTERMEDIATE_NAME=%2

IF %ROOT_NAME%name == name (
  GOTO :usage
)

IF NOT EXIST %ROOT_NAME%\ (
  ECHO Please create the root ca %ROOT_NAME% first
  GOTO :end
)

SET CA_PATH=%ROOT_NAME%
SET PEM_NAME=%ROOT_NAME%

IF NOT %INTERMEDIATE_NAME%name == name (
   SET CA_PATH=%ROOT_NAME%\%INTERMEDIATE_NAME%
   SET PEM_NAME=%INTERMEDIATE_NAME%
)

IF NOT EXIST %CA_PATH%\ (
    ECHO Please create the intermediate ca %INTERMEDIATE_NAME%
    GOTO :end
)

IF NOT EXIST %CA_PATH%\crl\ (
    MKDIR %CA_PATH%\crl
)

ECHO ===========================================================================
ECHO Creating the certificate revokation list
ECHO ===========================================================================
CALL openssl ca -config %CA_PATH%/openssl.cnf -gencrl -out %CA_PATH%/crl/%PEM_NAME%.crl.pem

ECHO ===========================================================================
ECHO Changinge line endings to unix
ECHO ===========================================================================
CALL bin\dos2unix-cmd %CA_PATH%\crl\%PEM_NAME%.crl.pem

openssl crl -in %CA_PATH%/crl/%PEM_NAME%.crl.pem -noout -text

GOTO :end
:usage
ECHO create-crl rootca intermediateca
ECHO    where rootca is the name of the root ca directory name
ECHO          intermediateca is the name of the directory below the rootca where the intermediate ca is located.
ECHO             The intermediateca is optional.
:end
