owsf_VDP:	EQUR a5
owsf_PalOff:	EQUR d7
owsf_Timer:	EQUR d6
owsf_Fades:	EQUR d4

owsf_TimerDef:	EQU 2-1
owsf_FadeDef:	EQU 2-1

; Misc stuff - Might come useful later
; VDP addressses
VDP_Data_Port		equ $C00000
VDP_Control_Port	equ $C00004
VDP_Counter		equ $C00008

owsf_dma68kToVDP macro source,dest,length,type
	move.l	#(($9400|((((length)>>1)&$FF00)>>8))<<16)|($9300|(((length)>>1)&$FF)),(owsf_VDP)
	move.l	#(($9600|((((source)>>1)&$FF00)>>8))<<16)|($9500|(((source)>>1)&$FF)),(owsf_VDP)
	move.w	#$9700|(((((source)>>1)&$FF0000)>>16)&$7F),(owsf_VDP)
	move.w	#((dest)&$3FFF)|((type&1)<<15)|$4000,(owsf_VDP)
	move.w	#$80|(((dest)&$C000)>>14)|((type&2)<<3),(owsf_VDP)
    endm

; values for the type argument
VRAM =	$0
CRAM =	$1
VSRAM =	$2
