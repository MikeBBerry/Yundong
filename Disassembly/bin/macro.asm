; ===========================================================================
	opt op+
	opt os+
	opt ow+
	opt oz+
	opt oaq+
	opt osq+
	opt omq+
	opt ae-
; ===========================================================================
align macro
	cnop 0,\1
	endm
; ===========================================================================
stopZ80		macro
		move.w    #$100,($A11100).l
		nop
		nop
		nop

@wait\@:    btst    #0,($A11100).l
		bne.s    @wait\@
		endm
; ===========================================================================
startZ80    macro
		move.w    #0,($A11100).l    ; start the Z80
		endm
; ===========================================================================
waitYM macro
		nop
		nop
		nop
@wait\@:
		tst.b	(a0)
		bmi.s	@wait\@
		endm
; ===========================================================================
VBlankJump	equ $FFFFFFC4
HBlankJump	equ VBlankJump+6
; ===========================================================================
vdpComm		macro ins,addr,type,rwd,end,end2
	if narg=5
		\ins #(((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14), \end

	elseif narg=6
		\ins #(((((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14))\end, \end2

	else
		\ins (((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14)
	endif
    endm
; ===========================================================================
; values for the type argument
VRAM =  %100001
CRAM =  %101011
VSRAM = %100101

; values for the rwd argument
READ =  %001100
WRITE = %000111
DMA =   %100111
; ===========================================================================
; tells the VDP to copy a region of 68k memory to VRAM or CRAM or VSRAM
dma68kToVDP macro source,dest,length,type
	vdpComm	move.l,\dest,\type,WRITE,(a6)
		move.w	#source,a4
@len =	length&$FFFE
	while @len>=$200
@len	= @len-$200
		jsr	WriteToVDP200.w
	endw
	jsr	(WriteToVDP200+$100-(@len/2)).w
@a =	$100-(@len/2)
	if (length&2)=2
		move.w	(a4)+,(a5)
	endif
    endm
; ===========================================================================
