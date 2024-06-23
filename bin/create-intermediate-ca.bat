@ECHO OFF

REM parameter 1 is the name of the root ca
REM Parameter 2 is the name of the intermediate ca being created.

SET ROOT_NAME=%1
SET INTERMEDIATE_NAME=%2

IF %ROOT_NAME%name == name (
  GOTO :usage
)

IF NOT EXIST %ROOT_NAME%\ (
  ECHO Please create the root ca %ROOT_NAME% first
  GOTO :end
)

IF %INTERMEDIATE_NAME%name == name (
  GOTO :usage
)
SET INTERMEDIATE_DIR=%ROOT_NAME%\%INTERMEDIATE_NAME%
SET INTERMEDIATE_DIR_LINUX=/depot/certvault/%ROOT_NAME%/%INTERMEDIATE_NAME%
IF EXIST  %INTERMEDIATE_DIR%\ (
  ECHO An intermediate ca by the name of %INTERMEDIATE_NAME% already exists for %ROOT_NAME%
  GOTO :end
)

REM set up the directories
MKDIR %INTERMEDIATE_DIR%\newcerts %INTERMEDIATE_DIR%\certs %INTERMEDIATE_DIR%\crl %INTERMEDIATE_DIR%\private %INTERMEDIATE_DIR%\csr

COPY .\conf\openssl-intermediate.cnf %INTERMEDIATE_DIR%\openssl.cnf

powershell -command "& { . bin\changeText.ps1; Change-Text %INTERMEDIATE_DIR%\openssl.cnf UDOP_INTERMEDIATE_DIR %INTERMEDIATE_DIR_LINUX% }"
powershell -command "& { . bin\changeText.ps1; Change-Text %INTERMEDIATE_DIR%\openssl.cnf INTERMEDIATE_NAME %INTERMEDIATE_NAME% }"

REM Create the "database"
powershell -command "& { . bin\emptyFile.ps1; Create-Empty %INTERMEDIATE_DIR%\index.txt }"
echo 1000 > %INTERMEDIATE_DIR%\serial
echo 1000 > %INTERMEDIATE_DIR%\crlnumber

CD %INTERMEDIATE_DIR%

ECHO ===========================================================================
ECHO create the intermediate key
ECHO ===========================================================================
CALL openssl genrsa -aes256 -passout pass:redrover -out private/%INTERMEDIATE_NAME%.key.pem 4096
CALL \depot\certvault\bin\dos2unix-cmd private\%INTERMEDIATE_NAME%.key.pem

ECHO ===========================================================================
ECHO create the intermediate certificate request
ECHO ===========================================================================
CALL openssl req -config ./openssl.cnf -new -passin pass:redrover -passout pass:redrover ^
   -sha256 -key private/%INTERMEDIATE_NAME%.key.pem -out csr/%INTERMEDIATE_NAME%.csr.pem
CALL  \depot\certvault\bin\dos2unix-cmd csr\%INTERMEDIATE_NAME%.csr.pem

IF NOT EXIST ..\index.txt.attr (
    CALL fsutil file createnew  ..\index.txt.attr 0
)
ECHO ===========================================================================
ECHO sign the certificate request with the root cert
ECHO ===========================================================================
CALL openssl ca -config ../openssl.cnf -extensions v3_intermediate_ca -passin pass:redrover ^
    -days 3650 -notext -md sha256 -in csr/%INTERMEDIATE_NAME%.csr.pem -out certs/%INTERMEDIATE_NAME%.cert.pem
CALL  \depot\certvault\bin\dos2unix-cmd certs\%INTERMEDIATE_NAME%.cert.pem
REM verify the intermediate certificate
ECHO ===========================================================================
ECHO verify the intermeidate certificate
ECHO ===========================================================================
CALL openssl x509 -noout -text -in certs/%INTERMEDIATE_NAME%.cert.pem

ECHO ===========================================================================
ECHO verify the intermedate certificate against the root.
ECHO ===========================================================================
CALL openssl verify -CAfile ../certs/%ROOT_NAME%.cert.pem certs/%INTERMEDIATE_NAME%.cert.pem

ECHO ===========================================================================
ECHO create the ca cert chain
ECHO ===========================================================================
TYPE certs\%INTERMEDIATE_NAME%.cert.pem >>certs\%INTERMEDIATE_NAME%-ca-chain.cert.pem
TYPE ..\certs\%ROOT_NAME%.cert.pem  >>certs\%INTERMEDIATE_NAME%-ca-chain.cert.pem

ECHO ===========================================================================
ECHO create the crl
ECHO ===========================================================================
ECHO unique_subject = yes > index.txt.attr
CALL openssl ca -config openssl.cnf -gencrl -passin pass:redrover -out crl/%INTERMEDIATE_NAME%.crl.pem
CALL  \depot\certvault\bin\dos2unix-cmd crl\%INTERMEDIATE_NAME%.crl.pem

ECHO ===========================================================================
ECHO process complete
ECHO ===========================================================================

CD  \depot\certvault
GOTO :end

:usage
ECHO .
ECHO usage: bin\make-intermediate-ca.bat root-ca-name intermediate-ca-name
ECHO    where root-ca-name is the name of the root ca and already exists
ECHO    and intermediate-ca-name is the name of the new intermediate ca to be created.
ECHO .
:end
