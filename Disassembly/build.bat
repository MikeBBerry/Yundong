@echo off
bin\asm68k /m /p sonic1.asm, need4speedtemp.bin, sonic.sym, .lst >errors.txt
type errors.txt

REM check if built file does not exist. If does not, show error and pause. Else continue and exit.
IF NOT EXIST need4speedtemp.bin goto LABLERR

bin\convsym sonic.sym sonic.symcmp
copy /B need4speedtemp.bin+sonic.symcmp need4speed.bin /Y
del need4speedtemp.bin > nul
del sonic.symcmp > nul
del sonic.sym > nul
REM bin\rompad.exe need4speed.bin 255 0 <- no nonono, bad rompad
bin\fixheadr.exe need4speed.bin
goto EOF

:LABLERR
pause
