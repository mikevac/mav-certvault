@ECHO OFF

rem parameter 1 is the certificate name
rem parameter 2 is the root ca
rem parameter 3 is the intermediate ca (optional - replace with . for root cert revocation)

SET CERT=%1
SET ROOT_NAME=%2
SET INTERMEDIATE_NAME=%3

IF %CERT%name == name (
    ECHO Please enter a cert name
    GOTO :usage
)

IF %ROOT_NAME%name == name (
    ECHO Please enter the root ca name
    GOTO :usage
)

IF NOT EXIST %ROOT_NAME% (
    ECHO Root ca %ROOT_NAME% does not exist.
    GOTO :end
)

IF %INTERMEDIATE_NAME%name == name (
    SET CA_PATH=%ROOT_NAME%
) ELSE (
    SET CA_PATH=%ROOT_NAME%\%INTERMEDIATE_NAME%
    IF NOT EXIST %CA_PATH% (
        ECHO Intermediate ca %INTERMEDIATE_NAME% does not exist.
        GOTO :end
    )
)

IF NOT EXIST %CA_PATH%\certs\%CERT%.cert.pem (
    ECHO Certificate %CERT%.cert.pem does not exist.
    GOTO :end
)

find "%CERT%" %CA_PATH%\index.txt
IF %errorlevel% == 1 (
    ECHO certificate %CERT% not found.  Please try again.
    GOTO :end
)
CHOICE /C yn /M "Is this the correct certificate?"

IF %errorlevel% == 2 (
    ECHO ok, please rerun the command with the correct certificate number.
    GOTO :end
)

ECHO Revokine %CERT%.cert.pem
openssl ca -config %CA_PATH%/openssl.cnf -revoke %CA_PATH%/certs/%CERT%.cert.pem
ECHO You may want to run create-crl.bat to generate the new certificate revocation list

GOTO :end
:usage
ECHO revoke-certificate cert-name rootca intermediateca
ECHO    where
ECHO        cert-name is the name of the cert (e.g. GLADS.MANAGER.1234567890)
ECHO        rootca is the name of the root ca directory name
ECHO        intermediateca is the name of the directory below the rootca where the intermediate ca is located.
ECHO            The intermediateca is optional.
:end
