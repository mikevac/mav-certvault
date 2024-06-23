@ECHO OFF
rem
rem common routine to convert a file to unix line endings
rem
SET FILE_NAME=%1
IF %FILE_NAME%var == var (
    ECHO Called without a file name.
    EXIT /B
)
IF NOT EXIST %FILE_NAME% (
    ECHO File %FILE_NAME% does not exist.
    EXIT /B
)
CALL \depot\certvault\bin\dos2unix\bin\dos2unix.exe %FILE_NAME%
