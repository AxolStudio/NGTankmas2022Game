@ECHO OFF
TITLE "Build for Web"

FOR /F "tokens=1 delims= " %%i IN ('getPID') DO (
    set PID=%%i
)

"C:\Program Files\PowerToys\modules\Awake\PowerToys.Awake.exe" --pid %PID%

ECHO "Building..."
lime build HolidayCCG\Project.xml html5 -clean -final -Dfinal
IF %ERRORLEVEL% == 0 GOTO SUCCESS
ECHO "Build failed, exiting..."
PAUSE
EXIT /B %ERRORLEVEL%

:SUCCESS
ECHO "Success!"
PAUSE
