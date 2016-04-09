@echo off
bin\asm68k /q /o op+ /o os+ /o ow+ /o oz+ /o oaq+ /o osq+ /o omq+ /p /o ae- sonic1.asm, need4speedtemp.bin >errors.txt, sonic.sym
bin\convsym sonic.sym sonic.symcmp
copy /B need4speedtemp.bin+sonic.symcmp need4speed.bin /Y
del need4speedtemp.bin > nul
del sonic.symcmp > nul
del sonic.sym > nul
rem bin\rompad.exe need4speed.bin 255 0
bin\fixheadr.exe need4speed.bin
type errors.txt
pause
