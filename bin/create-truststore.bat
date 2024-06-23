@ECHO OFF
REM parameter 1 is the name of the truststore.
REM parameter 2 is the name of root ca directory ex NGFRootCA
REM parameter 3 is the name of the intermediate ca directory eg GLADSIntermediateCA

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

IF NOT EXIST .\truststore (
    mkdir truststore
)

ECHO ====================================================================
ECHO Importing root CA into truststore
ECHO ====================================================================
CALL keytool -importcert -trustcacerts -file .\%ROOT_CA%\certs\%ROOT_CA%.cert.pem -alias RootCA ^
    -keystore .\truststore\%KEYSTORE_NAME%-truststore.p12 -storepass redrover -storetype PKCS12 -noprompt

ECHO ====================================================================
ECHO Importing intermediate CA into truststore
ECHO ====================================================================
CALL keytool -importcert -file .\%ROOT_CA%\%INTERMEDIATE_CA%\certs\%INTERMEDIATE_CA%.cert.pem  ^
    -alias IntermediateCA -keystore .\truststore\%KEYSTORE_NAME%-truststore.p12 -storepass redrover -storetype PKCS12

ECHO ====================================================================
ECHO Process complete
ECHO ====================================================================
CALL keytool -list -keystore truststore\%KEYSTORE_NAME%-truststore.p12 -storepass redrover
GOTO :exit

:usage
ECHO .
ECHO usage: create-truststore.bat truststoreName rootCa intermediateCa 
ECHO     where truststoreName is the name of the truststore you wish to create or update
ECHO           rootCa is the directory name of the rootC
ECHO           intermediateCa is the directory of the intermediate under the rootCa
ECHO .

:exit
