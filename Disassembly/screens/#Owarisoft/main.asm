; ===========================================================================
owsf_txPal:	EQUR a6
owsf_VDP:	EQUR a5

owsf_PalOff:	EQUR d7
owsf_Timer:	EQUR d6
owsf_Fades:	EQUR d4

owsf_TimerDef:	EQU 2-1
owsf_FadeDef:	EQU 2-1
owsf_url:	EQU 1	; if set to 0, Owarisoft url will not be shown
; ===========================================================================
VDP_Data_Port		equ $C00000
VDP_Control_Port	equ $C00004
VDP_Counter		equ $C00008

; ===========================================================================
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

; ===========================================================================
Owarisoft:
		jsr	Pal_FadeFrom		; fadeout palette
		jsr	ClearScreen		; clear screen data

		lea	VDP_control_port,owsf_VDP
		move.w	#$8004,(owsf_VDP)	; $8004 - Disable HInt, HV Counter
		move.w	#$8230,(owsf_VDP)	; $8230 - Nametable A at $C000
		move.w	#$8407,(owsf_VDP)	; $8407 - Nametable B at $E000
		move.w	#$9001,(owsf_VDP)	; $9001 - 64x32 cell nametable area
		move.w	#$9200,(owsf_VDP)	; $9200 - Window V position at default
		move.w	#$8B03,(owsf_VDP)	; $8B02 - Vscroll full, HScroll 8px
		move.w	#$8700,(owsf_VDP)	; $8700 - BG color is Pal 0 Color 0

	; load FG mappings
		lea	General_Buffer,a1
		lea	Owari_mapFG,a0
		move.w	#1,d0
		jsr	EniDec
		lea	General_Buffer,a1
		move.l	#$46040003,d0
		moveq	#35-1,d1
		moveq	#5-1,d2
		jsr	LoadPlaneMap

	; load BG mappings
		lea	General_Buffer,a1
		lea	Owari_mapBG,a0
		move.w	#$5B,d0
		jsr	EniDec
		lea	General_Buffer,a1
		move.l	#$659A0003,d0
		moveq	#16-1,d1
		moveq	#8-1,d2
		jsr	LoadPlaneMap

	; decompress art
		lea	Owari_tiles,a0
		lea	General_Buffer+$200,a1
		jsr	KosDec

	; load tiles, HScroll and initial palette
	owsf_dma68kToVDP General_Buffer+$200, $20, $14E0, VRAM
	owsf_dma68kToVDP Owari_HScroll,$FD5C,$100,VRAM
	owsf_dma68kToVDP Owari_Blank, 0, $80, CRAM

	; clear url palette
	if owsf_url=0
		move.l	#$C0620000,(owsf_VDP)
		move.w	#0,-4(owsf_VDP)
	endif

		move.b	#MusID_Owarisoft,d0 ; play music 94
		jsr	PlaySound			; play music

		move.l	#OwariVBlank,VBlankJump+2
		moveq	#0,owsf_PalOff			; clear palette offset
		moveq	#owsf_FadeDef,owsf_Fades	; set the fades count
		lea	Owari_txPalette,owsf_txPal

; ===========================================================================
.mainloop	STOP	#$2300				; stop CPU
		move.b	Ctrl_1_Held.w,d0			; get player 1's held buttons
		or.b	Ctrl_2_Held.w,d0			; get player 2's held buttons
		bpl.s	.mainloop			; if start is not pressed, branch

		bsr	OwariOutFade
		moveq	#0,owsf_PalOff			; clear palette offset

		move.l	#OwariVBlank2,VBlankJump+2
		sf	Ctrl_1_Held.w			; force start button press
		lea	Owari_txPalette_end,owsf_txPal

.mainloop2	STOP	#$2300				; stop CPU
		tst.b	Ctrl_1_Held.w			; get player 1's held buttons
		bpl.s	.mainloop2			; if start is not pressed, branch

		move.l	#V_Int,VBlankJump+2
		rts

; ===========================================================================
OwariOutFade:
		lea	General_Buffer,a1		; get fadeout pal
		lea	Owari_Palette,a0	; get palette
		add.w	owsf_PalOff,a0		;
		add.w	owsf_PalOff,a0		; add palette offset twice
		moveq	#($2D/2)-1,d0		; get repeat times

.loadPal	move.l	(a0)+,(a1)+		; load 2 palettes
		dbf	d0,.loadPal		; loop

		move.w	-2(a1),d0		; get last color
		move.b	d0,d1			;
		move.b	d0,d2			; copy it over

		and.w	#$F00,d0		; get bleu
		and.w	#$F0,d1			; get green
		and.w	#$F,d2			; get red
		moveq	#8-1,d3			; 8 different shades

; d0 = blue, d1 = green, d2 = red
.loadfade	tst.w	d0			;
		beq.s	.notBleu		; bleu is 0, dont decrement
		sub.w	#$200,d0		; decrement to next shade

.notBleu	tst.b	d1			;
		beq.s	.notGreen		; green is 0, dont decrement
		sub.b	#$20,d1			; decrement to next shade

.notGreen	tst.b	d2			;
		beq.s	.notRed			; red is 0, dont decrement
		subq.b	#2,d2			; decrement to next shade

.notRed		move.w	d0,d4			; get bleu to d4
		add.w	d1,d4			; add green to d4
		add.w	d2,d4			; add red to d4

		move.w	d4,(a1)+		; transfer color to mem
		move.w	d4,(a1)+		; transfer color to mem
		move.w	d4,(a1)+		; transfer color to mem
		dbf	d3,.loadfade		; load next fade

		moveq	#(10*3/2)-1,d0		; repeat times
		moveq	#0,d1			; black

.loadBlack	move.l	d1,(a1)+		; transfer color
		dbf	d0,.loadBlack		; loopdeloop
		rts

; ===========================================================================
OwariVBlank2:
		movem.l	owsf_Fades-owsf_PalOff/owsf_txPal,-(sp)	; store vars
		jsr	UpdateMusic			; sound driver code
		lea	VDP_control_port,owsf_VDP	; get vdp port
		movem.l	(sp)+,owsf_Fades-owsf_PalOff/owsf_txPal	; pop variables

		subq.b	#1,owsf_Timer			; sub 1 from timer
		bpl.s	.end2				; if positive, skip
		moveq	#owsf_TimerDef,owsf_Timer	; set timer
		add.w	#3,owsf_PalOff			; add 3 to advance to next row

		cmp.w	#Owari_po_3,owsf_PalOff		; is the limit reached,
		sgt	Ctrl_1_Held.w			; force start button press

		move.l	#$C0620000,(owsf_VDP)		; set CRAM write
		move.w	-(owsf_txPal),-4(owsf_VDP)	; write next palette

		move.w	#$9500|(((General_Buffer)>>1)&$FF),d0; get DMA offset
		add.b	owsf_PalOff,d0			; add low byte of palette offset
		move.w	d0,(owsf_VDP)			; move to VDP

		move.w	#$9600|((((General_Buffer)>>1)&$FF00)>>8),d0
		move.w	owsf_PalOff,d1			; get palette offset
		lsr.w	#8,d1				; get high byte
		add.b	d1,d0				; add to VDP command
		move.w	d0,(owsf_VDP)			; move to vDP

		move.w	#$9700|(((((General_Buffer)>>1)&$FF0000)>>16)&$7F),(owsf_VDP); set DMA source to RAM
		move.l	#(($9400|((((15*2)>>1)&$FF00)>>8))<<16)|($9300|(((15*2)>>1)&$FF)),d0; set DMA lenght
		move.l	d0,(owsf_VDP)		; line 0
		move.l	#$C0020080,(owsf_VDP)	; DMA!
		move.l	d0,(owsf_VDP)		; line 1
		move.l	#$C0220080,(owsf_VDP)	; DMA!
		move.l	d0,(owsf_VDP)		; line 2
		move.l	#$C0420080,(owsf_VDP)	; DMA!
.end2		rte
; ===========================================================================
OwariVBlank:
		movem.l	owsf_Fades-owsf_PalOff/owsf_txPal,-(sp)	; store vars
		jsr	ReadJoypads			; get button presses
		jsr	UpdateMusic			; sound driver code
		lea	VDP_control_port,owsf_VDP	; get vdp port
		movem.l	(sp)+,owsf_Fades-owsf_PalOff/owsf_txPal	; pop variables

		cmp.w	#Owari_po_0,owsf_PalOff		; is the limit reached
		bge	.st				; if not, skip
		sf	Ctrl_2_Held.w			; force start button press
		sf	Ctrl_1_Held.w			; force start button press

.st		subq.b	#1,owsf_Timer			; sub 1 from timer
		bpl.s	.end				; if positive, skip
		moveq	#owsf_TimerDef,owsf_Timer	; set timer
		add.w	#3,owsf_PalOff			; add 3 to advance to next row

		cmp.w	#Owari_po_2,owsf_PalOff		; is the limit reached
		ble	.skp				; if not, skip
		move.w	#Owari_po_1,owsf_PalOff		; reset to start of the fade

		subq.b	#1,owsf_Fades			; sub 1 from the fade times counter
		bpl.s	.skp				; if negative, branch
		st	Ctrl_2_Held.w			; force start button press

.skp	if owsf_url=1
		cmpa.l	#Owari_txPalette_end-2,owsf_txPal; is text fadein done?
		bge.s	.noin				; if is, branch
		move.l	#$C0620000,(owsf_VDP)		; set CRAM write
		move.w	(owsf_txPal)+,-4(owsf_VDP)	; write next palette
	endif

.noin		move.w	#$9500|(((Owari_Palette)>>1)&$FF),d0; get DMA offset
		add.b	owsf_PalOff,d0			; add low byte of palette offset
		move.w	d0,(owsf_VDP)			; move to VDP

		move.w	#$9600|((((Owari_Palette)>>1)&$FF00)>>8),d0
		move.w	owsf_PalOff,d1			; get palette offset
		lsr.w	#8,d1				; get high byte
		add.b	d1,d0				; add to VDP command
		move.w	d0,(owsf_VDP)			; move to vDP

		move.w	#$9700|(((((Owari_Palette)>>1)&$FF0000)>>16)&$7F),(owsf_VDP); set DMA source to RAM
		move.l	#(($9400|((((15*2)>>1)&$FF00)>>8))<<16)|($9300|(((15*2)>>1)&$FF)),d0; set DMA lenght
		move.l	d0,(owsf_VDP)		; line 0
		move.l	#$C0020080,(owsf_VDP)	; DMA!
		move.l	d0,(owsf_VDP)		; line 1
		move.l	#$C0220080,(owsf_VDP)	; DMA!
		move.l	d0,(owsf_VDP)		; line 2
		move.l	#$C0420080,(owsf_VDP)	; DMA!

.end		rte
; ===========================================================================
Owari_tiles:	incbin "screens/#Owarisoft/art.kos"		; Kosinski compressed tiles
		even
Owari_mapFG:	incbin "screens/#Owarisoft/fgmap.eni"		; Enigma compressed foreground mappings
		even
Owari_mapBG:	incbin "screens/#Owarisoft/bgmap.eni"		; Enigma compressed background mappings
		even
; ===========================================================================

Owari_HScroll:	dcb.l 8,$FFACFFAC
		dcb.l 6,0
; ===========================================================================
Owari_Blank:	dcb.w $80/2,0

; ===========================================================================
Owari_txPalette: equ *-$30
		dc.w $0222, $0222, $0444, $0444, $0666, $0666, $0888
		dc.w $0888, $0AAA, $0AAA, $0CCC, $0CCC, $0EEE, $0EEE
Owari_txPalette_end:
; ===========================================================================
Owari_po_3	equ $70/2

Owari_PadStart
	align $200
Owari_Palette:
	rept (16*2*3)
		dc.w 0		; black before fade to white
	endr

	dc.w $0444, $0222, $0000
	dc.w $0666, $0444, $0222
	dc.w $0888, $0666, $0444
	dc.w $0AAA, $0888, $0444
	dc.w $0CCC, $0888, $0666
	dc.w $0EEE, $0AAA, $0666		; fade from black

Owari_po_0	equ (*-Owari_Palette)/2
	rept 4
		rept 15/3
			dc.w $EEE, $AAA, $666	; white frame
		endr
	endr

    	dc.w $0CCC, $0AAA, $0888
    	dc.w $0AAC, $088A, $0668
    	dc.w $088C, $066A, $0448
    	dc.w $066C, $044A, $0228
    	dc.w $044C, $022A, $0008
    	dc.w $022C, $000A, $0008		; fade to red

Owari_po_1	equ (*-Owari_Palette)/2
    	incbin	"screens/#Owarisoft/rainbow.bin"	; rainbow effect

Owari_po_2	equ (*-Owari_Palette)/2
    	incbin	"screens/#Owarisoft/rainbow.bin"	; more rainbow effect for reset counter

Owari_pad	equ Owari_Palette-Owari_PadStart
	inform 0,"OwariSoft Splash: Padded $\$Owari_pad bytes"
; ===========================================================================
