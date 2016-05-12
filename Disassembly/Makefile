all:
	@wine bin/asm68k /m /p sonic1.asm, need4speedtemp.bin, sonic.sym, sonic.lst
	@wine bin/convsym sonic.sym sonic.symcmp
	@cat need4speedtemp.bin sonic.symcmp > need4speed.gen
	@rm need4speedtemp.bin > /dev/null
	@rm sonic.symcmp > /dev/null
	@rm sonic.sym > /dev/null
	@wine bin/fixheadr.exe need4speed.gen