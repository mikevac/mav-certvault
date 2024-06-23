@ECHO OFF
rem updates a trust store with foreign certificates

SET TRUSTSTORE=%1
SET VAULT_DIR=%CD%
IF %TRUSTSTORE%store == store (
    ECHO You must specify a truststore name
    GOTO :usage
)

IF NOT EXIST %VAULT_DIR%\truststore\%TRUSTSTORE%-truststore.p12 (
    ECHO The truststore %TRUSTSTORE%-truststore.p12 does not exist in %VAULT_DIR%\truststore
    GOTO :end
)

SET CERT_NAME=%2
IF %CERT_NAME%cert == cert (
    ECHO You must specify a certificate file name.
    GOTO :usage
)

IF NOT EXIST %CERT_NAME% (
    ECHO The certificate %CERT_NAME% not found.
    GOTO :end
)

SET ALIAS=%3
IF %ALIAS%alias == alias (
    ECHO You must specify an alias for this certificate.  The alias name must be unique within the truststore.
    GOTO :usage
)

ECHO ====================================================================
ECHO Importing certificate %CERT_NAME% into truststore
ECHO ====================================================================
CALL keytool -importcert -trustcacerts -file %CERT_NAME% -alias %ALIAS% ^
    -keystore .\truststore\%TRUSTSTORE%-truststore.p12 -storepass redrover -storetype PKCS12 -noprompt

ECHO ====================================================================
ECHO Process complete
ECHO ====================================================================
CALL keytool -list -keystore truststore\%TRUSTSTORE%-truststore.p12 -storepass redrover
GOTO :end

:usage
ECHO update-truststore.bat truststorename certfilename alias
ECHO     where
ECHO        truststorename is the name of a truststore located in %VAULT_DIR%\truststore
ECHO        certfilename is the name of a certificate file including the path and extension.  For example: \myCerts\temp\certfile.crt
ECHO        alias is a string that is unique within the truststore.

:end
