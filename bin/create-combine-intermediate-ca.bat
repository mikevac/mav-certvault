@ECHO OFF

REM parameter 1 is the name of the root ca
REM parameter 2 is the name of the intermediate ca

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
SET COMBINED_CA_FILE=.\combined-ca\GLADS-Intermediate-combined-ca-chain.cert.pem
SET CA_FILE=%INTERMEDIATE_DIR%\certs\GLADS-Intermediate-ca-chain.cert.pem

IF EXIST %COMBINED_CA_FILE% (
  DEL %COMBINED_CA_FILE%
)

TYPE %INTERMEDIATE_DIR%\certs\GLADS-Intermediate-ca-chain.cert.pem >>%COMBINED_CA_FILE%

for %%f in (.\additional-certificates\combined-cas\*) do (
  TYPE %%~f>>%COMBINED_CA_FILE%
)
CALL %CURR_DIR%\bin\dos2unix-cmd %COMBINED_CA_FILE%

ECHO ===========================================================================
ECHO process complete
ECHO ===========================================================================

CD \depot\certvault
GOTO :end

:usage
ECHO .
ECHO usage: bin\creatte-combined-intermediate-ca.bat root-ca-name intermediate-ca-name
ECHO    where root-ca-name is the name of the root ca and already exists
ECHO    and intermediate-ca-name is the name of the new intermediate ca to be created.
ECHO .
:end
