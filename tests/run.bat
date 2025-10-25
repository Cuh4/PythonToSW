@ECHO OFF

set PYTHONPATH=..\src

if "%1"=="" (
    set target=
) else (
    set target= %1
)

echo "%2"
if "%2"=="--no-silent" (
    set silent_arg=
) else (
    set silent_arg= -s
)

pytest%target% --timeout 140 --asyncio-mode=auto%silent_arg%