@ECHO OFF
REM parameter 1 is the name of the keystore.
REM parameter 2 is the verbose flag. any non empty string will make the listing verbose, blank will give a short list.
REM parameter 3 is the optional alias name. if specified param 2 must be true

SET KEYSTORE_NAME=%1
IF %KEYSTORE_NAME%name == name (
    GOTO :usage
)

SET VERBOSE=%2
IF %VERBOSE%false == false (
   SET VFLAG=
) ELSE (
   SET VFLAG=-v
)

SET ALIAS=%3
IF %ALIAS%name == name (
   SET ALIAS_NAME=
) ELSE (
   SET ALIAS_NAME=-alias %ALIAS%
)

IF EXIST .\keystore\%KEYSTORE_NAME%-keystore.p12 (
   SET DIRECTORY_NAME=keystore
) ELSE (
   IF EXIST .\truststore\%KEYSTORE_NAME%-truststore.p12 (
   SET DIRECTORY_NAME=truststore
   ) ELSE (
     ECHO %KEYSTORE_NAME%.p12 does not exist in the keystore or truststore directories.
     GOTO :exit
   )
)

call keytool -list %VFLAG% -keystore .\%DIRECTORY_NAME%\%KEYSTORE_NAME%-%DIRECTORY_NAME%.p12 -storepass redrover -storetype JKS %ALIAS_NAME%

GOTO :exit

:usage
ECHO .
ECHO usage: list-certs.bat keystoreName verboseFlag aliasName
ECHO     where keystoreName is the name of the keystore you wish to create or update
ECHO           verboseFlag (optional) when not blank, causes the listing to be verbose
ECHO           aliasName (optional) specifies the certificate with that alias.
ECHO    when aliasName is specified, verboseFlag must also be non null.
ECHO .

:exit
