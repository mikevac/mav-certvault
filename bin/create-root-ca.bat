@ECHO OFF

REM parameter 1 is the root-ca name (will be used for the directory name, the root certficate name and key files

SET ROOT_NAME=%1

IF %ROOT_NAME%name == name (
  GOTO :usage
)

IF EXIST .\%ROOT_NAME%\ (
  ECHO Root %ROOT_NAME% already exists
  GOTO :end
)

REM need an absolute path to the root ca (in linux fashion for change in openssl.cnf file.
SET ROOT_DIR=/depot/certvault/%ROOT_NAME%

REM prepare the directories
MKDIR %ROOT_NAME%\newcerts %ROOT_NAME%\certs %ROOT_NAME%\crl %ROOT_NAME%\private

REM copy the default root CA OpenSSL configuration file and change UDOP_ROOT_DIR token to %ROOT_NAME%
COPY conf\openssl-root.cnf %ROOT_NAME%\openssl.cnf
powershell -command "& { . bin\changeText.ps1; Change-Text %ROOT_NAME%\openssl.cnf UDOP_ROOT_DIR %ROOT_DIR% }"
powershell -command "& { . bin\changeText.ps1; Change-Text %ROOT_NAME%\openssl.cnf UDOP_ROOT_NAME %ROOT_NAME% }"

REM create the "database"
powershell -command "& { . bin\emptyFile.ps1; Create-Empty %ROOT_NAME%\index.txt }"
echo 1000 > %ROOT_NAME%\serial
echo 1000 > %ROOT_NAME%\crlnumber

CD .\%ROOT_NAME%

ECHO ===========================================================================
ECHO generate root key
ECHO ===========================================================================
CALL openssl genrsa -aes256 -passout pass:redrover -out private/%ROOT_NAME%.key.pem 4096
CALL \depot\certvault\bin\dos2unix-cmd.bat private\%ROOT_NAME%.key.pem
ECHO ===========================================================================
ECHO create the root certificate
ECHO ===========================================================================
CALL openssl req -config openssl.cnf -passin pass:redrover -passout pass:redrover ^
    -key private/%ROOT_NAME%.key.pem -new -x509 ^
    -days 3650 -sha256 -extensions v3_ca -out certs/%ROOT_NAME%.cert.pem
CALL  .\bin\dos2unix-cmd certs/%ROOT_NAME%.cert.pem

ECHO ===========================================================================
ECHO verify the root certificate
ECHO ===========================================================================
CALL openssl x509 -noout -text -in certs/%ROOT_NAME%.cert.pem

ECHO ===========================================================================
ECHO process complete
ECHO ===========================================================================

CD ..

GOTO :end

:usage

ECHO .
ECHO Usage: make-root-ca rootName
ECHO     where rootName is the name of the root ca.
ECHO .

:end
