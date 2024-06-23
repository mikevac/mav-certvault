@ECHO OFF
CLS
REM parameter 1 is the name of the keystore.
REM parameter 2 is the name of root ca directory ex NGFRootCA
REM parameter 3 is the name of the intermediate ca directory eg GLADSIntermediateCA
REM parameter 4 is the name of the certificate to add to the keystore
REM parameter 5 is the alias you want to give to the certificate

SET KEYSTORE_NAME=%1
IF %KEYSTORE_NAME%name == name (
    GOTO :usage
)

SET ROOT_CA=%2
IF %ROOT_CA%name == name (
    GOTO :usage
)

IF NOT EXIST .\%ROOT_CA%\ (
    ECHO Root %ROOT_CA% does not exist.
    ECHO Exiting.
    GOTO :exit
)

SET INTERMEDIATE_CA=%3
IF %INTERMEDIATE_CA%name == name (
    GOTO :usage
)

IF NOT EXIST .\%ROOT_CA%\%INTERMEDIATE_CA%\ (
    ECHO Intermediate directory %INTERMEDIATE_CA% does not exist.
    ECHO Exiting.
    GOTO :exit
)

SET CERT=%4
IF %CERT%name == name (
    GOTO :usage
)

IF NOT EXIST .\%ROOT_CA%\%INTERMEDIATE_CA%\private\%CERT%.keyNP.pem (
    ECHO Certificate key %CERT%.keyNP.pem does not exist in directory %ROOT_CA%\%INTERMEDIATE_CA%\private.
    ECHO Exiting.
    GOTO :exit
)

SET ALIAS=%5
IF %ALIAS%name == name (
    GOTO :usage
)

IF NOT EXIST .\temp (
    mkdir .\temp
)

IF NOT EXIST .\keystore (
    mkdir .\keystore
)

ECHO ====================================================================
ECHO Create Private Key and certificate entry
ECHO ====================================================================
COPY .\%ROOT_CA%\%INTERMEDIATE_CA%\certs\%CERT%.cert.pem+.\%ROOT_CA%\%INTERMEDIATE_CA%\private\%CERT%.keyNP.pem+.\%ROOT_CA%\%INTERMEDIATE_CA%\certs\%INTERMEDIATE_CA%-ca-chain.cert.pem .\temp\server.pem

ECHO ====================================================================
ECHO Creating the PKCS12 keystore contents
ECHO ====================================================================
call openssl pkcs12 -export -in .\temp\server.pem ^
     -name %ALIAS% -passin pass:redrover -passout pass:redrover -out .\temp\server.p12

IF EXIST .\keystore\%KEYSTORE_NAME%-keystore.p12 (
    del /q .\keystore\%KEYSTORE_NAME%-keystore.p12
)

ECHO ====================================================================
ECHO Importing the PKCS12 contents into keystore %KEYSTORE_NAME%-keystore.p12
ECHO ====================================================================
call keytool -importkeystore -srckeystore .\temp\server.p12 -srcstorepass redrover ^
    -destkeystore .\keystore\%KEYSTORE_NAME%-keystore.p12 ^
    -deststoretype PKCS12 -deststorepass redrover -srcalias %ALIAS% -destalias %ALIAS%

ECHO ====================================================================
ECHO Removing temporary files
ECHO ====================================================================
del /q .\temp\*

ECHO ====================================================================
ECHO keystore contents
ECHO ====================================================================
CALL keytool -list -keystore keystore\%KEYSTORE_NAME%-keystore.p12 -storepass redrover

GOTO :exit

:usage
ECHO .
ECHO usage: make-key-store.bat keystoreName rootCa intermediateCa certificate alias
ECHO     where keystoreName is the name of the keystore you wish to create or update
ECHO           rootCa is the directory name of the rootC
ECHO           intermediateCa is the directory of the intermediate under the rootCa
ECHO           certificate is the name of the cert to place in the keystore
ECHO           alias is the alias name for the certificate.  must be unique in the keystore.
ECHO .

:exit
