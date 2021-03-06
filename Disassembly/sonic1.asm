; ===========================================================================
; YUNDONG
; ===========================================================================
; lets clean up a little and put all macros and commandline options here!
	include "bin/macro.asm"
	include "bin/defines.asm"
; ===========================================================================
StartOfRom:
Vectors:	dc.l Stack_Base&$FFFFFF, EntryPoint
ErrorTrap:	bra.w	*

		dc.l AddressError, IllegalInstr, ZeroDivide, ChkInstr, TrapvInstr
		dc.l PrivilegeViol, Trace, Line1010Emu,	Line1111Emu
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorExcept, ErrorExcept, ErrorExcept
		dc.l ErrorExcept, ErrorTrap, ErrorTrap,	ErrorTrap
		dc.l HBlankJump, ErrorTrap, VBlankJump, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap
		dc.l ErrorTrap,	ErrorTrap, ErrorTrap, ErrorTrap, ErrorTrap
; ===========================================================================
		align $100
; ===========================================================================
Console:	dc.b 'SEGA IS TERRIBLE' 	; Hardware system ID
Date:		dc.b 'OWARI   2016.NOV' 	; Release date
Title_Local:	dc.b 'Yundong Zixingche                               ' ; Domestic name
Title_Int:	dc.b 'Yundong Zixingche                               ' ; International name
Serial:		dc.b 'GM 13131313-13'   	; Serial/version number
Checksum:	dc.w 0
		dc.b 'J               ' 	; I/O support
RomStartLoc:	dc.l StartOfRom			; ROM start
RomEndLoc:	dc.l EndOfRom-1			; ROM end
RamStartLoc:	dc.l RAM_Start&$FFFFFF		; RAM start
RamEndLoc:	dc.l RAM_End&$FFFFFF		; RAM end
SRAMSupport:	dc.l $20202020			; change to $5241E020 to create	SRAM
		dc.l $20202020			; SRAM start
		dc.l $20202020			; SRAM end
Notes:		dc.b '                                                    '
Region:		dc.b 'JUE             ' 	; Region
; ===========================================================================

EntryPoint:
		tst.l	($A10008).l	; test port A control
		bne.s	PortA_Ok
		tst.w	($A1000C).l	; test port C control

PortA_Ok:
		bne.s	PortC_Ok
		lea	SetupValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	-$10FF(a1),d0	; get hardware version
		andi.b	#$F,d0
		beq.s	SkipSecurity
		move.l	#'SEGA',$2F00(a1)

SkipSecurity:
		move.w	(a4),d0		; check	if VDP works
		moveq	#0,d0
		movea.l	d0,a6
		move.l	a6,usp		; set usp to $
		moveq	#$17,d1

VDPInitLoop:
		move.b	(a5)+,d5	; add $8000 to value
		move.w	d5,(a4)		; move value to	VDP register
		add.w	d7,d5		; next register
		dbf	d1,VDPInitLoop
		move.l	(a5)+,(a4)
		move.w	d0,(a3)		; clear	the screen
		move.w	d7,(a1)		; stop the Z80
		move.w	d7,(a2)		; reset	the Z80

WaitForZ80:
		btst	d0,(a1)		; has the Z80 stopped?
		bne.s	WaitForZ80	; if not, branch
		moveq	#$25,d2

Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbf	d2,Z80InitLoop
		move.w	d0,(a2)
		move.w	d0,(a1)		; start	the Z80
		move.w	d7,(a2)		; reset	the Z80

ClrRAMLoop:
		move.l	d0,-(a6)
		dbf	d6,ClrRAMLoop	; clear	the entire RAM
		move.l	(a5)+,(a4)	; set VDP display mode and increment
		move.l	(a5)+,(a4)	; set VDP to CRAM write
		moveq	#$1F,d3

ClrCRAMLoop:
		move.l	d0,(a3)
		dbf	d3,ClrCRAMLoop	; clear	the CRAM
		move.l	(a5)+,(a4)
		moveq	#$13,d4

ClrVDPStuff:
		move.l	d0,(a3)
		dbf	d4,ClrVDPStuff
		moveq	#3,d5

PSGInitLoop:
		move.b	(a5)+,$11(a3)	; reset	the PSG
		dbf	d5,PSGInitLoop
		move.w	d0,(a2)
		movem.l	(a6),d0-a6	; clear	all registers
		move	#$2700,sr	; set the sr

PortC_Ok:
		bra.s	GameProgram
; ===========================================================================
SetupValues:	dc.w $8000		; XREF: PortA_Ok
		dc.w $3FFF
		dc.w $100

		dc.l $A00000		; start	of Z80 RAM
		dc.l $A11100		; Z80 bus request
		dc.l $A11200		; Z80 reset
		dc.l $C00000
		dc.l $C00004		; address for VDP registers

		dc.b 4,	$14, $30, $3C	; values for VDP registers
		dc.b 7,	$6C, 0,	0
		dc.b 0,	0, $FF,	0
		dc.b $81, $37, 0, 1
		dc.b 1,	0, 0, $FF
		dc.b $FF, 0, 0,	$80

		dc.l $40000080

		dc.b $AF, 1, $D9, $1F, $11, $27, 0, $21, $26, 0, $F9, $77 ; Z80	instructions
		dc.b $ED, $B0, $DD, $E1, $FD, $E1, $ED,	$47, $ED, $4F
		dc.b $D1, $E1, $F1, 8, $D9, $C1, $D1, $E1, $F1,	$F9, $F3
		dc.b $ED, $56, $36, $E9, $E9

		dc.w $8104		; value	for VDP	display	mode
		dc.w $8F02		; value	for VDP	increment
		dc.l $C0000000		; value	for CRAM write mode
		dc.l $40000010

		dc.b $9F, $BF, $DF, $FF	; values for PSG channel volumes
; ===========================================================================

GameProgram:
		tst.w	($C00004).l
		lea	(RAM_Start).l,a6
		moveq	#0,d7
		move.w	#$3FFF,d6

GameClrRAM:
		move.l	d7,(a6)+
		dbf	d6,GameClrRAM	; fill RAM ($000-$FDFF) with $

		move.b	($A10001).l,d0
		andi.b	#$C0,d0
		move.b	d0,(Console_Version).w

		move.w	#$4EF9,d0
		move.w	d0,HBlankJump.w
		move.w	d0,VBlankJump.w
		move.l	#V_Int,(VBlankJump+2).w
		move.l	#H_Int,(HBlankJump+2).w

		bsr.w	VDPSetupGame
		bsr.w	InitMegaPCM
		bsr.w	JoypadInit
		move.b	#0,(Game_Mode).w ; set Game Mode to Notice Screen

MainGameLoop:
		move.b	(Game_Mode).w,d0
		andi.w	#$7C,d0
		movea.l	GameModeArray(pc,d0.w),a0
		jsr	(a0)
		bra.s	MainGameLoop
; ===========================================================================
; ---------------------------------------------------------------------------
; Main game mode array
; ---------------------------------------------------------------------------

GameModeArray:
		dc.l	NoticeScreen		; Notice Screen ($0)
		dc.l	TitleScreen		; Title	Screen ($4)
		dc.l	Level			; Demo Mode ($8)
		dc.l	Level			; Normal Level ($C)
		dc.l	FlickySS		; Special Stage	($10)
		dc.l	ContinueScreen		; Continue Screen ($14)
		dc.l	EndingSequence		; End of game sequence ($18)
		dc.l	Credits			; Credits ($1C)
		dc.l	SegaScreen		; Sega Screen ($20)
; ===========================================================================

Art_Text:	incbin	art/uncompressed/menutext.bin	; text used in level select and debug mode
		even

; ===========================================================================

V_Int_ResetEffects:
		cmpi.l	#H_Int_SegaScreen,HBlankJump+2
		bne.w	@NotSega
		cmpi.w	#$200,(Sega_H_Int_Sine_Index).w
		blt.s	@NoReset
		move.w	#0,(Sega_H_Int_Sine_Index).w
		
@NoReset:
		lea	(Sine_Data).l,a2
		adda.w	(Sega_H_Int_Sine_Index).w,a2
		move.l	a2,(Sega_H_Int_Sine_Address).w
		move.w	#$20,d2
		move.w	(Sega_Effect_Modifier).w,d1
		add.w	d1,d1
		sub.w	d1,d2
		add.w	d2,(Sega_H_Int_Sine_Index).w
		
		move.l	(V_Int_Counter).w,d0
		andi.b	#3,d0
		bne.s	@Skip
		
		cmpi.l	#$EEE0EEE,(Sega_H_Int_Color_Modifier).w
		beq.s	@Skip
		moveq	#0,d0
		move.w	(Sega_H_Int_Color_Modifier).w,d0
		lsl.w	#1,d0
		ori.w	#$222,d0
		andi.w	#$EEE,d0
		move.w	d0,(Sega_H_Int_Color_Modifier).w
		move.w	(Sega_H_Int_Color_Modifier).w,(Sega_H_Int_Color_Modifier+2).w

@Skip:
		move.l	(V_Int_Counter).w,d0
		andi.w	#3,d0
		bne.s	@Skip2
		addq.w	#2,(Sega_H_Int_First_Color_Index).w
		cmpi.w	#$E0*2,(Sega_H_Int_First_Color_Index).w
		blt.s	@Skip2
		move.w	#0,(Sega_H_Int_First_Color_Index).w
		
@Skip2:
		move.w	(Sega_H_Int_First_Color_Index).w,(Sega_H_Int_Curr_Color_Index).w
		
@NotSega:
		rts
; ===========================================================================

V_Int:				; XREF: Vectors
		movem.l	d0-a6,-(sp)
		lea	$C00004,a6		; control port
		lea	-4(a6),a5		; data port

		tst.b	(V_Int_Routine).w
		beq.w	loc_B88
		move.w	(a6),d0
		
		cmpi.l	#H_Int_SegaScreen,HBlankJump+2
		beq.s	@Sega
		move.l	#$40000010,($C00004).l
		move.l	(V_Scroll_Value).w,($C00000).l
		
@Sega:
		btst	#6,(Console_Version).w
		beq.s	loc_B42
		move.w	#$700,d0

loc_B3E:
		dbf	d0,loc_B3E

loc_B42:
		move.b	(V_Int_Routine).w,d0
		move.b	#0,(V_Int_Routine).w
		move.w	#1,(H_Int_Flag).w
		andi.w	#$3E,d0
		move.w	off_B6E(pc,d0.w),d0
		jsr	off_B6E(pc,d0.w)

loc_B5E:				; XREF: loc_B88
		jsr	UpdateMusic

loc_B64:				; XREF: loc_D50
		bsr.w	V_Int_ResetEffects
		addq.l	#1,(V_Int_Counter).w
		movem.l	(sp)+,d0-a6
		rte
; ===========================================================================
off_B6E:	dc.w loc_B88-off_B6E, loc_C32-off_B6E
		dc.w loc_C44-off_B6E, loc_C5E-off_B6E
		dc.w loc_C6E-off_B6E, loc_DA6-off_B6E
		dc.w loc_E72-off_B6E, loc_F8A-off_B6E
		dc.w loc_C64-off_B6E, loc_F9A-off_B6E
		dc.w loc_C36-off_B6E, loc_FA6-off_B6E
		dc.w loc_E72-off_B6E
; ===========================================================================

loc_B88:				; XREF: V_Int; off_B6E
		cmpi.b	#$8C,(Game_Mode).w
		beq.s	loc_B9A
		cmpi.b	#$C,(Game_Mode).w
		bne.w	loc_B5E

loc_B9A:
		cmpi.b	#1,(Current_Zone).w ; is level LZ ?
		bne.w	loc_B5E		; if not, branch
		move.w	(a6),d0
		btst	#6,(Console_Version).w
		beq.s	loc_BBA
		move.w	#$700,d0

loc_BB6:
		dbf	d0,loc_BB6

loc_BBA:
		move.w	#1,(H_Int_Flag).w
		tst.b	(Water_Fullscreen_Flag).w
		bne.s	loc_BFE
	dma68kToVDP Normal_Palette,0,$80,CRAM
		bra.s	loc_C22
; ===========================================================================

loc_BFE:
	dma68kToVDP Underwater_Palette,0,$80,CRAM

loc_C22:				; XREF: loc_BC8
		move.w	(H_Int_Counter).w,(a6)
		bra.w	loc_B5E
; ===========================================================================

loc_C32:				; XREF: off_B6E
		bsr.w	sub_106E

loc_C36:				; XREF: off_B6E
		tst.w	(Universal_Timer).w
		beq.w	locret_C42
		subq.w	#1,(Universal_Timer).w

locret_C42:
		rts
; ===========================================================================

loc_C44:				; XREF: off_B6E
		bsr.w	sub_106E
		bsr.w	sub_6886
		bsr.w	sub_1642
		tst.w	(Universal_Timer).w
		beq.w	locret_C5C
		subq.w	#1,(Universal_Timer).w

locret_C5C:
		rts
; ===========================================================================

loc_C5E:				; XREF: off_B6E
		bsr.w	sub_106E
		rts
; ===========================================================================

loc_C64:				; XREF: off_B6E
		cmpi.b	#$10,(Game_Mode).w ; is	game mode = $10	(special stage)	?
		beq.w	loc_DA6		; if yes, branch

loc_C6E:				; XREF: off_B6E
		bsr.w	ReadJoypads
		tst.b	(Water_Fullscreen_Flag).w
		bne.s	loc_CB0
	dma68kToVDP Normal_Palette,0,$80,CRAM	; normal pal
		bra.s	loc_CD4
; ===========================================================================

loc_CB0:
	dma68kToVDP Underwater_Palette,0,$80,CRAM	; underwater pal

loc_CD4:
		move.w	(H_Int_Counter).w,(a6)
	dma68kToVDP Sprite_Table,$F800,$280,VRAM	; sprite table
	dma68kToVDP Horiz_Scroll_Buf,$FC00,$380,VRAM	; horiz buffer
		jsr	ProcessDMAQueue
		bsr.w	WrapBGPos
		bsr.w	DoHWrap
		bsr.w	HandleScreenLockBound
		movem.l	(Camera_RAM).w,d0-d7
		movem.l	d0-d7,(Camera_RAM_Copy).w
		movem.l	(Scroll_Flags).w,d0-d1
		movem.l	d0-d1,(Scroll_Flags_Copy).w
		cmpi.b	#$60,(H_Int_Counter+1).w
		bcc.s	Demo_Time
		move.b	#1,(Do_Updates_In_H_Int).w
		addq.l	#4,sp
		bra.w	loc_B64

; ---------------------------------------------------------------------------
; Subroutine to	run a demo for an amount of time
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Demo_Time:				; XREF: loc_D50; H_Int
		bsr.w	LoadTilesAsYouMove
		jsr	AniArt_Load
		jsr	HudUpdate
		bsr.w	sub_165E
		tst.w	(Universal_Timer).w	; is there time	left on	the demo?
		beq.w	Demo_TimeEnd	; if not, branch
		subq.w	#1,(Universal_Timer).w ; subtract 1 from time	left

Demo_TimeEnd:
		rts
; End of function Demo_Time

; ===========================================================================

loc_DA6:				; XREF: off_B6E
		bsr.w	ReadJoypads
	dma68kToVDP Normal_Palette,0,$80,CRAM	; normal pal
	dma68kToVDP Sprite_Table,$F800,$280,VRAM	; sprite table
	dma68kToVDP Horiz_Scroll_Buf,$FC00,$380,VRAM	; horiz buffer
		jsr	ProcessDMAQueue

loc_E64:
		tst.w	(Universal_Timer).w
		beq.w	locret_E70
		subq.w	#1,(Universal_Timer).w

locret_E70:
		rts
; ===========================================================================

loc_E72:				; XREF: off_B6E
		bsr.w	ReadJoypads
		tst.b	(Water_Fullscreen_Flag).w
		bne.s	loc_EB4
	dma68kToVDP Normal_Palette,0,$80,CRAM	; normal pal
		bra.s	loc_ED8
; ===========================================================================

loc_EB4:				; XREF: loc_E7A
	dma68kToVDP Underwater_Palette,0,$80,CRAM	; underwater pal

loc_ED8:
	dma68kToVDP Sprite_Table,$F800,$280,VRAM	; sprite table
	dma68kToVDP Horiz_Scroll_Buf,$FC00,$380,VRAM	; horiz buffer
		jsr	ProcessDMAQueue
		bsr.w	WrapBGPos
		bsr.w	DoHWrap
		bsr.w	HandleScreenLockBound
		movem.l	(Camera_RAM).w,d0-d7
		movem.l	d0-d7,(Camera_RAM_Copy).w
		movem.l	(Scroll_Flags).w,d0-d1
		movem.l	d0-d1,(Scroll_Flags_Copy).w
		bsr.w	LoadTilesAsYouMove
		jsr	AniArt_Load
		jsr	HudUpdate
		bsr.w	sub_1642
		rts
; ===========================================================================

loc_F8A:				; XREF: off_B6E
		bsr.w	sub_106E
		addq.b	#1,(V_Int_E_Run_Count).w
		move.b	#$E,(V_Int_Routine).w
		rts
; ===========================================================================

loc_F9A:				; XREF: off_B6E
		bsr.w	sub_106E
		move.w	(H_Int_Counter).w,(a6)
		bra.w	sub_1642
; ===========================================================================

loc_FA6:				; XREF: off_B6E
		bsr.w	ReadJoypads
	dma68kToVDP Normal_Palette,0,$80,CRAM	; normal pal
	dma68kToVDP Sprite_Table,$F800,$280,VRAM	; sprite table
	dma68kToVDP Horiz_Scroll_Buf,$FC00,$380,VRAM	; horiz buffer
		jsr	ProcessDMAQueue

loc_1060:
		tst.w	(Universal_Timer).w
		beq.w	locret_106C
		subq.w	#1,(Universal_Timer).w

locret_106C:
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_106E:				; XREF: loc_C32; et al
		bsr.w	ReadJoypads
		tst.b	(Water_Fullscreen_Flag).w
		bne.s	loc_10B0
	dma68kToVDP Normal_Palette,0,$80,CRAM	; normal pal
		bra.s	loc_10D4
; ===========================================================================

loc_10B0:
	dma68kToVDP Underwater_Palette,0,$80,CRAM	; underwater pal

loc_10D4:
	dma68kToVDP Sprite_Table,$F800,$280,VRAM	; sprite table
	dma68kToVDP Horiz_Scroll_Buf,$FC00,$380,VRAM	; horiz buffer
		rts
; End of function sub_106E

WriteToVDP200:
	rept $200/4
		move.l	(a4)+,(a5)
	endr
		rts
; ---------------------------------------------------------------------------
; Subroutine to wrap the background's X positions
; ---------------------------------------------------------------------------

WrapBGPos:
		moveq	#0,d0				; Get the x position in which the background wraps at
		move.w	(Current_Zone_And_Act).w,d0	; According to the current level
		ror.b	#2,d0
		lsr.w	#6,d0
		add.w	d0,d0
		move.w	CameraBGXWrapValues(pc,d0.w),d0
		tst.w	(Camera_X_Pos_Diff).w		; Check what direction the camera is going
		bmi.s	@Left				; If left, branch
		bpl.s	@Right				; If right, branch
		rts					; If not moving, return
; ---------------------------------------------------------------------------
@Left:
		cmpi.w	#$60,(Camera_BG_X_Pos).w	; Check if each BG x position has passed $60
		bgt.s	@NoWrap				; And if they did, apply the value to wrap to the maximum boundary
		add.w	d0,(Camera_BG_X_Pos).w
		
@NoWrap:
		cmpi.w	#$60,(Camera_BG2_X_Pos).w
		bgt.s	@NoWrap2
		add.w	d0,(Camera_BG2_X_Pos).w
		
@NoWrap2:
		cmpi.w	#$60,(Camera_BG3_X_Pos).w
		bgt.s	@NoWrap3
		add.w	d0,(Camera_BG3_X_Pos).w
		
@NoWrap3:
		rts
; ---------------------------------------------------------------------------
@Right:
		cmp.w	(Camera_BG_X_Pos).w,d0		; Check if each BG x position has passed the value
		bge.s	@Skip				; And if they did, apply the value to wrap to the minimum boundary
		sub.w	d0,(Camera_BG_X_Pos).w
		
@Skip:
		cmp.w	(Camera_BG2_X_Pos).w,d0
		bge.s	@Skip2
		sub.w	d0,(Camera_BG2_X_Pos).w
		
@Skip2:
		cmp.w	(Camera_BG3_X_Pos).w,d0
		bge.s	@Skip3
		sub.w	d0,(Camera_BG3_X_Pos).w
		
@Skip3:
		rts
; ---------------------------------------------------------------------------
CameraBGXWrapValues:
		dc.w $2000, $2000, $2000, $2000		; GHZ
		dc.w $1800, $1800, $1800, $1800		; LZ
		dc.w $1400, $1800, $1400, $1400		; MZ
		dc.w $1800, $1800, $1800, $1800		; SLZ
		dc.w $1C00, $1C00, $1C00, $1C00		; SYZ
		dc.w $1E00, $3C00, $3C00, $1E00		; SBZ
		dc.w $2000, $2000, $2000, $2000		; Ending
; ---------------------------------------------------------------------------
; Wrap the camera if horizontal wrapping is enabled
; ---------------------------------------------------------------------------

DoHWrap:
		tst.b	(H_Wrap_Flag).w			; Is the horizontal wrap flag enabled?
		beq.s	@End				; If not, return
		move.w	(Camera_X_Pos).w,d0		; Get the camera's current X position
		move.w	(H_Wrap_Max).w,d1		; Get value to apply to camera's x position and Sonic's x position
		sub.w	(H_Wrap_Min).w,d1		; (Maximum wrap boundary - Minimum wrap boundary)
		tst.w	(Camera_X_Pos_Diff).w		; Check what direction it's going
		bmi.s	@Left				; If it's left, branch
		bpl.s	@Right				; If it's right, branch
		bra.s	@End				; If not at all, return
; ---------------------------------------------------------------------------
@Left:
		cmp.w	(H_Wrap_Min).w,d0		; Has the camera passed the minimum x boundary for wrapping?
		bge.s	@End				; If not, return
		add.w	d1,(Camera_X_Pos).w		; Apply value to camera' x position
		add.w	d1,(Object_Space_1+8).w		; Apply value to Sonic's x position
		bra.s	@Redraw				; Redraw the screen
; ---------------------------------------------------------------------------
@Right:
		cmp.w	(H_Wrap_Max).w,d0		; Has the camera passed the maximum x boundary for wrapping?
		blt.s	@End				; If not, return
		sub.w	d1,(Camera_X_Pos).w		; Apply value to camera' x position
		sub.w	d1,(Object_Space_1+8).w		; Apply value to Sonic's x position
; ---------------------------------------------------------------------------
@Redraw:
		move.b	#1,(Screen_Redraw_Flag).w	; Set the screen redraw flag (a dirty fix)

@End:
		rts
; ---------------------------------------------------------------------------
; Set boundaries for when the screen is locked
; ---------------------------------------------------------------------------	
HandleScreenLockBound:
		tst.b	(Screen_Lock).w
		beq.s	@End
		move.w	(Camera_X_Pos).w,d0
		move.w	d0,(Camera_Max_X_Pos).w
		move.w	d0,(Camera_Min_X_Pos).w

@End:
		rts
; ---------------------------------------------------------------------------
; Lock the screen (V-INT via HandleScreenLockBound handles boundaries)
; ---------------------------------------------------------------------------
LockScreen:
		move.w	(Camera_Min_X_Pos).w,(Saved_Camera_Min_X_Pos).w
		move.w	(Camera_Max_X_Pos).w,(Saved_Camera_Max_X_Pos).w
		move.b	#1,(Screen_Lock).w
		rts
; ---------------------------------------------------------------------------
; Unlock the screen
; ---------------------------------------------------------------------------
UnlockScreen:
		move.w	(Saved_Camera_Min_X_Pos).w,(Camera_Min_X_Pos).w
		move.w	(Saved_Camera_Max_X_Pos).w,(Camera_Max_X_Pos).w
		move.b	#0,(Screen_Lock).w
		rts
; ---------------------------------------------------------------------------
; Subroutine to	move Palettes from the RAM to CRAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


H_Int:
		move	#$2700,sr
		tst.w	(H_Int_Flag).w
		beq.s	locret_119C
		move.w	#0,(H_Int_Flag).w
		movem.l	a0-a1,-(sp)
		lea	($C00000).l,a1
		lea	(Underwater_Palette).w,a0 	; load palette from RAM
		move.l	#$C0000000,4(a1) 		; set VDP to CRAM write
		move.l	(a0)+,(a1)			; move palette to CRAM
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.l	(a0)+,(a1)
		move.w	#$8ADF,4(a1)
		movem.l	(sp)+,a0-a1
		tst.b	(Do_Updates_In_H_Int).w
		bne.s	loc_119E

locret_119C:
		rte	
; ===========================================================================

loc_119E:				; XREF: H_Int
		clr.b	(Do_Updates_In_H_Int).w
		movem.l	d0-a6,-(sp)
		bsr.w	Demo_Time
		jsr	UpdateMusic
		movem.l	(sp)+,d0-a6
		rte	
; End of function H_Int
; ===========================================================================

H_Int_SegaScreen:
		move	#$2700,sr
		movem.l	d0/a0,-(sp)
		
		move.l #$C0000000,($C00004).l
		lea	(H_Int_Sega_Colors).l,a0
		adda.w	(Sega_H_Int_Curr_Color_Index).w,a0
		move.l	(a0),d0
		and.l	(Sega_H_Int_Color_Modifier).w,d0
		move.l	d0,($C00000).l
		addq.w	#2,(Sega_H_Int_Curr_Color_Index).w
		
		movea.l	(Sega_H_Int_Sine_Address).w,a0
		move.w	(a0)+,d0
		lsr.w	#2,d0
		move.l	a0,(Sega_H_Int_Sine_Address).w
		
		move.l	#$40000010,($C00004).l
		move.w	d0,($C00000).l
		
		move.w	#$8ADF,(H_Int_Counter).w
		
		movem.l	(sp)+,d0/a0
		rte
		
H_Int_Sega_Colors:
		rept $C
		include "data/colors.asm"
		endr
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


JoypadInit:				; XREF: GameClrRAM
		move.w	#$100,($A11100).l ; stop the Z80

Joypad_WaitZ80:
		btst	#0,($A11100).l	; has the Z80 stopped?
		bne.s	Joypad_WaitZ80	; if not, branch
		moveq	#$40,d0
		move.b	d0,($A10009).l	; init port 1 (joypad 1)
		move.b	d0,($A1000B).l	; init port 2 (joypad 2)
		move.b	d0,($A1000D).l	; init port 3 (extra)
		move.w	#0,($A11100).l	; start	the Z80
		rts	
; End of function JoypadInit

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ReadJoypads:
		lea	(Ctrl_1).w,a0	; address where joypad	states are written
		lea	($A10003).l,a1	; first	joypad port
		bsr.s	Joypad_Read	; do the first joypad
		addq.w	#2,a1		; do the second	joypad

Joypad_Read:
		move.b	#0,(a1)
		nop	
		nop	
		move.b	(a1),d0
		lsl.b	#2,d0
		andi.b	#$C0,d0
		move.b	#$40,(a1)
		nop	
		nop	
		move.b	(a1),d1
		andi.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts	
; End of function ReadJoypads


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


VDPSetupGame:				; XREF: GameClrRAM; ChecksumError
		lea	($C00004).l,a0
		lea	($C00000).l,a1
		lea	(VDPSetupArray).l,a2
		moveq	#$12,d7

VDP_Loop:
		move.w	(a2)+,(a0)
		dbf	d7,VDP_Loop	; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(VDP_Reg_1_Value).w
		move.w	#$8ADF,(H_Int_Counter).w
		moveq	#0,d0
		move.l	#$C0000000,($C00004).l ; set VDP to CRAM write
		move.w	#$3F,d7

VDP_ClrCRAM:
		move.w	d0,(a1)
		dbf	d7,VDP_ClrCRAM	; clear	the CRAM

		clr.l	(V_Scroll_Value).w
		clr.l	(H_Scroll_Value).w
		move.l	d1,-(sp)
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$94FF93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080,(a5)
		move.w	#0,($C00000).l	; clear	the screen

loc_128E:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_128E

		move.w	#$8F02,(a5)
		move.l	(sp)+,d1
		rts	
; End of function VDPSetupGame

; ===========================================================================
VDPSetupArray:	dc.w $8004, $8134, $8230, $8328	; XREF: VDPSetupGame
		dc.w $8407, $857C, $8600, $8700
		dc.w $8800, $8900, $8A00, $8B00
		dc.w $8C81, $8D3F, $8E00, $8F02
		dc.w $9001, $9100, $9200

; ---------------------------------------------------------------------------
; Subroutine to	clear the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearScreen:
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,($C00000).l

loc_12E6:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_12E6

		move.w	#$8F02,(a5)
		lea	($C00004).l,a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000083,(a5)
		move.w	#0,($C00000).l

loc_1314:
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_1314

		move.w	#$8F02,(a5)
		move.l	#0,(V_Scroll_Value).w
		move.l	#0,(H_Scroll_Value).w
		lea	(Sprite_Table).w,a1
		moveq	#0,d0
		move.w	#(Sprite_Table_End-Sprite_Table)>>2-1,d1

loc_133A:
		move.l	d0,(a1)+
		dbf	d1,loc_133A

		lea	(Horiz_Scroll_Buf).w,a1
		moveq	#0,d0
		move.w	#((Horiz_Scroll_Buf_End+$80)-Horiz_Scroll_Buf)>>2-1,d1

loc_134A:
		move.l	d0,(a1)+
		dbf	d1,loc_134A
		rts	
; End of function ClearScreen

; ---------------------------------------------------------------------------
; Subroutine to	load the sound driver
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


InitMegaPCM:			; XREF: GameClrRAM; TitleScreen
		nop
		move.w	#$100,d0
		move.w	d0,($A11100).l
		move.w	d0,($A11200).l
		lea	(MegaPCM).l,a0
		lea	($A00000).l,a1
		move.w	#(MegaPCM_End-MegaPCM)-1,d1

	@Load:	move.b	(a0)+,(a1)+
		dbf	d1,@Load
		moveq	#0,d1
		move.w	d1,($A11200).l
		nop
		nop
		nop
		nop
		move.w	d0,($A11200).l
		move.w	d1,($A11100).l
		rts
; End of function InitMegaPCM

; ---------------------------------------------------------------------------
; Subroutine to	play a DAC sample
; ---------------------------------------------------------------------------
; To use this: 
;		moveq	#$FFFFFFXX,d0
;		jsr	PlaySample
; XX = Sample Number
; ---------------------------------------------------------------------------

PlaySample:
		move.w	#$100,($A11100).l	; stop the Z80
@Wait:
		btst	#0,($A11100).l
		bne.s	@Wait
		move.b	d0,($A01FFF).l
		move.w	#0,($A11100).l
		rts
; ===========================================================================

PlayMusic:
		cmpi.b	#MusID_1UP,d0
		beq.s	PlaySound
		cmpi.b	#SFXID_Start,d0
		bcc.s	PlaySound
		
@Set:
		move.b	d0,(Current_Music_ID).w
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlaySound:
		bsr.s	Snd_ChkStop
		move.b	d0,(Sound_Driver_RAM+$A).w
		rts	
; End of function PlaySound

; ---------------------------------------------------------------------------
; Subroutine to	play a special sound/music (E0-E4)
;
; E0 - Fade out
; E1 - Sega
; E2 - Speed up
; E3 - Normal speed
; E4 - Stop
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlaySound_Special:
		bsr.s	Snd_ChkStop
		move.b	d0,(Sound_Driver_RAM+$B).w
		rts	
; End of function PlaySound_Special
; ===========================================================================

Snd_ChkStop:
		cmpi.b	#CmdID_FadeOut,d0
		beq.s	@clr
		cmpi.b	#CmdID_Stop,d0
		beq.s	@clr
		rts
		
@clr:
		move.b	#0,(Current_Music_ID).w
		rts
; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PauseGame:				; XREF: Level_MainLoop; et al
		nop	
		tst.b	(Life_Count).w	; do you have any lives	left?
		beq.s	Unpause		; if not, branch
		tst.w	(Pause_Flag).w	; is game already paused?
		bne.s	loc_13BE	; if yes, branch
		btst	#7,(Ctrl_1_Press).w ; is Start button pressed?
		beq.s	Pause_DoNothing	; if not, branch

loc_13BE:
		move.w	#1,(Pause_Flag).w ; freeze time
		move.b	#1,(Sound_Driver_RAM+3).w ; pause music

loc_13CA:
		move.b	#$10,(V_Int_Routine).w
		bsr.w	DelayProgram
		tst.b	(Debug_Cheat_Flag).w	; is slow-motion cheat on?
		beq.s	Pause_ChkStart	; if not, branch
		btst	#6,(Ctrl_1_Press).w ; is button A pressed?
		beq.s	Pause_ChkBC	; if not, branch
		move.b	#4,(Game_Mode).w ; set game mode to 4 (title screen)
		nop	
		bra.s	loc_1404
; ===========================================================================

Pause_ChkBC:				; XREF: PauseGame
		btst	#4,(Ctrl_1_Held).w ; is button B pressed?
		bne.s	Pause_SlowMo	; if yes, branch
		btst	#5,(Ctrl_1_Press).w ; is button C pressed?
		bne.s	Pause_SlowMo	; if yes, branch

Pause_ChkStart:				; XREF: PauseGame
		btst	#7,(Ctrl_1_Press).w ; is Start button pressed?
		beq.s	loc_13CA	; if not, branch

loc_1404:				; XREF: PauseGame
		move.b	#$80,(Sound_Driver_RAM+3).w

Unpause:				; XREF: PauseGame
		move.w	#0,(Pause_Flag).w ; unpause the game

Pause_DoNothing:			; XREF: PauseGame
		rts	
; ===========================================================================

Pause_SlowMo:				; XREF: PauseGame
		move.w	#1,(Pause_Flag).w
		move.b	#$80,(Sound_Driver_RAM+3).w
		rts	
; End of function PauseGame

; ---------------------------------------------------------------------------
; Subroutine to	display	patterns via the VDP
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadPlaneMap:			; XREF: SegaScreen; TitleScreen; SS_BGLoad
		lea	($C00000).l,a6
		move.l	#$800000,d4

loc_142C:
		move.l	d0,4(a6)
		move.w	d1,d3

loc_1432:
		move.w	(a1)+,(a6)
		dbf	d3,loc_1432
		add.l	d4,d0
		dbf	d2,loc_142C
		rts	
; End of function LoadPlaneMap

; ---------------------------------------------------------------------------
; Subroutine to	display	patterns via the VDP (with modifier)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadPlaneMap2:			; XREF: SegaScreen; TitleScreen; SS_BGLoad
		lea	($C00000).l,a6
		move.l	#$800000,d4

loc2_142C:
		move.l	d0,4(a6)
		move.w	d1,d3

loc2_1432:
		move.w	(a1)+,d6
		add.w	d5,d6
		move.w	d6,(a6)
		dbf	d3,loc2_1432
		add.l	d4,d0
		dbf	d2,loc2_142C
		rts	
; End of function LoadPlaneMap

; ---------------------------------------------------------------------------
; Subroutine for queueing VDP commands (seems to only queue transfers to VRAM),
; to be issued the next time ProcessDMAQueue is called.
; Can be called a maximum of 18 times before the buffer needs to be cleared
; by issuing the commands (this subroutine DOES check for overflow)
; ---------------------------------------------------------------------------
; In case you wish to use this queue system outside of the spin dash, this is the
; registers in which it expects data in:
; d1.l: Address to data (In 68k address space)
; d2.w: Destination in VRAM
; d3.w: Length of data
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
 
; sub_144E: DMA_68KtoVRAM: QueueCopyToVRAM: QueueVDPCommand: Add_To_DMA_Queue:

; VDP addressses
vdp_data_port:		equ $C00000
vdp_control_port:	equ $C00004
vdp_counter:		equ $C00008

; sub_14AC: CopyToVRAM: IssueVDPCommands: Process_DMA: Process_DMA_Queue:
ProcessDMAQueue:
		lea	(DMA_Queue).w,a1
; loc_14B6:
ProcessDMAQueue_Loop:
		move.w	(a1)+,d0
		beq.s	ProcessDMAQueue_Done ; branch if we reached a stop token
		; issue a set of VDP commands...
		move.w	d0,(a6)		; transfer length
		move.w	(a1)+,(a6)	; transfer length
		move.w	(a1)+,(a6)	; source address
		move.w	(a1)+,(a6)	; source address
		move.w	(a1)+,(a6)	; source address
		move.w	(a1)+,(a6)	; destination
		move.w	(a1)+,(a6)	; destination
		cmpa.w	#DMA_Queue_Slot,a1
		bne.s	ProcessDMAQueue_Loop ; loop if we haven't reached the end of the buffer
; loc_14CE:
ProcessDMAQueue_Done:
		move.w	#0,(DMA_Queue).w
		move.l	#DMA_Queue,(DMA_Queue_Slot).w
		rts
		
QueueDMATransfer:
		movea.l	(DMA_Queue_Slot).w,a1
		cmpa.w	#DMA_Queue_Slot,a1
		beq.s	QueueDMATransfer_Done ; return if there's no more room in the buffer
 
		; piece together some VDP commands and store them for later...
		move.w	#$9300,d0 ; command to specify DMA transfer length & $0FF
		move.b	d3,d0
		move.w	d0,(a1)+ ; store command
 
		move.w	#$9400,d0 ; command to specify DMA transfer length & $FF00
		lsr.w	#8,d3
		move.b	d3,d0
		move.w	d0,(a1)+ ; store command
 
		move.w	#$9500,d0 ; command to specify source address & $001FE
		lsr.l	#1,d1
		move.b	d1,d0
		move.w	d0,(a1)+ ; store command
 
		move.w	#$9600,d0 ; command to specify source address & $1FE00
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+ ; store command
 
		move.w	#$9700,d0 ; command to specify source address & $1FE0000
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+ ; store command
 
		andi.l	#$FFFF,d2 ; command to specify destination address and begin DMA
		lsl.l	#2,d2
		lsr.w	#2,d2
		swap	d2
		or.l	#$40000080,d2 ; set bits to specify VRAM transfer
		move.l	d2,(a1)+ ; store command
 
		move.l	a1,(DMA_Queue_Slot).w ; set the next free slot address
		cmpa.w	#DMA_Queue_Slot,a1
		beq.s	QueueDMATransfer_Done ; return if there's no more room in the buffer
		move.w	#0,(a1) ; put a stop token at the end of the used part of the buffer
; return_14AA:
QueueDMATransfer_Done:
		rts
		

		clr.w	(DMA_Queue).w			; clear start of the DMA queue
		move.l	#DMA_Queue,DMA_Queue_Slot	; reset address pointer of DMA queue
; End of function ProcessDMAQueue

; ===========================================================================
; ---------------------------------------------------------------
; COMPER Decompressor
; ---------------------------------------------------------------
; INPUT:
;       a0      - Source Offset
;       a1      - Destination Offset
; ---------------------------------------------------------------
 
CompDec
 
@newblock
        move.w  (a0)+,d0                ; fetch description field
        moveq   #15,d3                  ; set bits counter to 16
 
@mainloop
        add.w   d0,d0                   ; roll description field
        bcs.s   @flag                   ; if a flag issued, branch
        move.w  (a0)+,(a1)+             ; otherwise, do uncompressed data
        dbf     d3,@mainloop            ; if bits counter remains, parse the next word
        bra.s   @newblock               ; start a new block
 
; ---------------------------------------------------------------
@flag   moveq   #-1,d1                  ; init displacement
        move.b  (a0)+,d1                ; load displacement
        add.w   d1,d1
        moveq   #0,d2                   ; init copy count
        move.b  (a0)+,d2                ; load copy length
        beq.s   @end                    ; if zero, branch
        lea     (a1,d1),a2              ; load start copy address
 
@loop   move.w  (a2)+,(a1)+             ; copy given sequence
        dbf     d2,@loop                ; repeat
        dbf     d3,@mainloop            ; if bits counter remains, parse the next word
        bra.s   @newblock               ; start a new block
 
@end    rts

; ==============================================================================
; ------------------------------------------------------------------------------
; Nemesis decompression routine
; ------------------------------------------------------------------------------
; Optimized by vladikcomper
; ------------------------------------------------------------------------------
 
NemDec_RAM:
        movem.l d0-a1/a3-a6,-(sp)
        lea     NemDec_WriteRowToRAM(pc),a3
        bra.s   NemDec_Main
 
; ------------------------------------------------------------------------------
NemDec:
        movem.l d0-a1/a3-a6,-(sp)
        lea     $C00000,a4              ; load VDP Data Port    
        lea     NemDec_WriteRowToVDP(pc),a3
 
NemDec_Main:
        lea     Nem_Decomp_Buffer,a1            ; load Nemesis decompression buffer
        move.w  (a0)+,d2                ; get number of patterns
        bpl.s   @0                      ; are we in Mode 0?
        lea     $A(a3),a3               ; if not, use Mode 1
@0      lsl.w   #3,d2
        movea.w d2,a5
        moveq   #7,d3
        moveq   #0,d2
        moveq   #0,d4
        bsr.w   NemDec4
        move.b  (a0)+,d5                ; get first byte of compressed data
        asl.w   #8,d5                   ; shift up by a byte
        move.b  (a0)+,d5                ; get second byte of compressed data
        move.w  #$10,d6                 ; set initial shift value
        bsr.s   NemDec2
        movem.l (sp)+,d0-a1/a3-a6
        rts
 
; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, processes the actual compressed data
; ---------------------------------------------------------------------------
 
NemDec2:
        move.w  d6,d7
        subq.w  #8,d7                   ; get shift value
        move.w  d5,d1
        lsr.w   d7,d1                   ; shift so that high bit of the code is in bit position 7
        cmpi.b  #%11111100,d1           ; are the high 6 bits set?
        bcc.s   NemDec_InlineData       ; if they are, it signifies inline data
        andi.w  #$FF,d1
        add.w   d1,d1
        sub.b   (a1,d1.w),d6            ; ~~ subtract from shift value so that the next code is read next time around
        cmpi.w  #9,d6                   ; does a new byte need to be read?
        bcc.s   @0                      ; if not, branch
        addq.w  #8,d6
        asl.w   #8,d5
        move.b  (a0)+,d5                ; read next byte
@0      move.b  1(a1,d1.w),d1
        move.w  d1,d0
        andi.w  #$F,d1                  ; get palette index for pixel
        andi.w  #$F0,d0
 
NemDec_GetRepeatCount:
        lsr.w   #4,d0                   ; get repeat count
 
NemDec_WritePixel:
        lsl.l   #4,d4                   ; shift up by a nybble
        or.b    d1,d4                   ; write pixel
        dbf     d3,NemDec_WritePixelLoop; ~~
        jmp     (a3)                    ; otherwise, write the row to its destination
; ---------------------------------------------------------------------------
 
NemDec3:
        moveq   #0,d4                   ; reset row
        moveq   #7,d3                   ; reset nybble counter
 
NemDec_WritePixelLoop:
        dbf     d0,NemDec_WritePixel
        bra.s   NemDec2
; ---------------------------------------------------------------------------
 
NemDec_InlineData:
        subq.w  #6,d6                   ; 6 bits needed to signal inline data
        cmpi.w  #9,d6
        bcc.s   @0
        addq.w  #8,d6
        asl.w   #8,d5
        move.b  (a0)+,d5
@0      subq.w  #7,d6                   ; and 7 bits needed for the inline data itself
        move.w  d5,d1
        lsr.w   d6,d1                   ; shift so that low bit of the code is in bit position 0
        move.w  d1,d0
        andi.w  #$F,d1                  ; get palette index for pixel
        andi.w  #$70,d0                 ; high nybble is repeat count for pixel
        cmpi.w  #9,d6
        bcc.s   NemDec_GetRepeatCount
        addq.w  #8,d6
        asl.w   #8,d5
        move.b  (a0)+,d5
        bra.s   NemDec_GetRepeatCount
 
; ---------------------------------------------------------------------------
; Subroutines to output decompressed entry
; Selected depending on current decompression mode
; ---------------------------------------------------------------------------
 
NemDec_WriteRowToVDP:
loc_1502:
        move.l  d4,(a4)                 ; write 8-pixel row
        subq.w  #1,a5
        move.w  a5,d4                   ; have all the 8-pixel rows been written?
        bne.s   NemDec3                 ; if not, branch
        rts
; ---------------------------------------------------------------------------
 
NemDec_WriteRowToVDP_XOR:
        eor.l   d4,d2                   ; XOR the previous row by the current row
        move.l  d2,(a4)                 ; and write the result
        subq.w  #1,a5
        move.w  a5,d4
        bne.s   NemDec3
        rts
; ---------------------------------------------------------------------------
 
NemDec_WriteRowToRAM:
        move.l  d4,(a4)+                ; write 8-pixel row
        subq.w  #1,a5
        move.w  a5,d4                   ; have all the 8-pixel rows been written?
        bne.s   NemDec3                 ; if not, branch
        rts
; ---------------------------------------------------------------------------
 
NemDec_WriteRowToRAM_XOR:
        eor.l   d4,d2                   ; XOR the previous row by the current row
        move.l  d2,(a4)+                ; and write the result
        subq.w  #1,a5
        move.w  a5,d4
        bne.s   NemDec3
        rts
 
; ---------------------------------------------------------------------------
; Part of the Nemesis decompressor, builds the code table (in RAM)
; ---------------------------------------------------------------------------
 
NemDec4:
        move.b  (a0)+,d0                ; read first byte
 
@ChkEnd:
        cmpi.b  #$FF,d0                 ; has the end of the code table description been reached?
        bne.s   @NewPalIndex            ; if not, branch
        rts
; ---------------------------------------------------------------------------
 
@NewPalIndex:
        move.w  d0,d7
 
@ItemLoop:
        move.b  (a0)+,d0                ; read next byte
        bmi.s   @ChkEnd                 ; ~~
        move.b  d0,d1
        andi.w  #$F,d7                  ; get palette index
        andi.w  #$70,d1                 ; get repeat count for palette index
        or.w    d1,d7                   ; combine the two
        andi.w  #$F,d0                  ; get the length of the code in bits
        move.b  d0,d1
        lsl.w   #8,d1
        or.w    d1,d7                   ; combine with palette index and repeat count to form code table entry
        moveq   #8,d1
        sub.w   d0,d1                   ; is the code 8 bits long?
        bne.s   @ItemShortCode          ; if not, a bit of extra processing is needed
        move.b  (a0)+,d0                ; get code
        add.w   d0,d0                   ; each code gets a word-sized entry in the table
        move.w  d7,(a1,d0.w)            ; store the entry for the code
        bra.s   @ItemLoop               ; repeat
; ---------------------------------------------------------------------------
 
@ItemShortCode:
        move.b  (a0)+,d0                ; get code
        lsl.w   d1,d0                   ; shift so that high bit is in bit position 7
        add.w   d0,d0                   ; get index into code table
        moveq   #1,d5
        lsl.w   d1,d5
        subq.w  #1,d5                   ; d5 = 2^d1 - 1
        lea     (a1,d0.w),a6            ; ~~
 
@ItemShortCodeLoop:
        move.w  d7,(a6)+                ; ~~ store entry
        dbf     d5,@ItemShortCodeLoop   ; repeat for required number of entries
        bra.s   @ItemLoop

; ---------------------------------------------------------------------------
; Subroutine to	load pattern load cues
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadPLC:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		lea	(PLC_Buffer).w,a2

loc_1598:
		tst.l	(a2)
		beq.s	loc_15A0
		addq.w	#6,a2
		bra.s	loc_1598
; ===========================================================================

loc_15A0:				; XREF: LoadPLC
		move.w	(a1)+,d0
		bmi.s	loc_15AC

loc_15A4:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_15A4

loc_15AC:
		movem.l	(sp)+,a1-a2
		rts	
; End of function LoadPLC


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadPLC2:
		movem.l	a1-a2,-(sp)
		lea	(ArtLoadCues).l,a1
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		bsr.s	ClearPLC
		lea	(PLC_Buffer).w,a2
		move.w	(a1)+,d0
		bmi.s	loc_15D8

loc_15D0:
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbf	d0,loc_15D0

loc_15D8:
		movem.l	(sp)+,a1-a2
		rts	
; End of function LoadPLC2

; ---------------------------------------------------------------------------
; Subroutine to	clear the pattern load cues
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ClearPLC:				; XREF: LoadPLC2
		lea	(PLC_Buffer).w,a2
		moveq	#$1F,d0

ClearPLC_Loop:
		clr.l	(a2)+
		dbf	d0,ClearPLC_Loop
		rts	
; End of function ClearPLC

; ---------------------------------------------------------------------------
; Subroutine to	use graphics listed in a pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC_RAM:				; XREF: Pal_FadeTo
		tst.l	(PLC_Buffer).w
		beq.s	locret_1640
		tst.w	(PLC_Buffer_Reg_18).w
		bne.s	locret_1640
		movea.l	(PLC_Buffer).w,a0
		lea	(loc_1502).l,a3
		lea	(Nem_Decomp_Buffer).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_160E
		adda.w	#$A,a3

loc_160E:
		andi.w	#$7FFF,d2
		bsr.w	NemDec4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(PLC_Buffer).w
		move.l	a3,(PLC_Buffer_Reg_0).w
		move.l	d0,(PLC_Buffer_Reg_4).w
		move.l	d0,(PLC_Buffer_Reg_8).w
		move.l	d0,(PLC_Buffer_Reg_C).w
		move.l	d5,(PLC_Buffer_Reg_10).w
		move.l	d6,(PLC_Buffer_Reg_14).w
		move.w	d2,(PLC_Buffer_Reg_18).w

locret_1640:
		rts	
; End of function RunPLC_RAM


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_1642:				; XREF: loc_C44; loc_F54; loc_F9A
		tst.w	(PLC_Buffer_Reg_18).w
		beq.w	locret_16DA
		move.w	#9,(PLC_Buffer_Reg_1A).w
		moveq	#0,d0
		move.w	(PLC_Buffer+4).w,d0
		addi.w	#$120,(PLC_Buffer+4).w
		bra.s	loc_1676
; End of function sub_1642


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_165E:				; XREF: Demo_Time
		tst.w	(PLC_Buffer_Reg_18).w
		beq.s	locret_16DA
		move.w	#3,(PLC_Buffer_Reg_1A).w
		moveq	#0,d0
		move.w	(PLC_Buffer+4).w,d0
		addi.w	#$60,(PLC_Buffer+4).w

loc_1676:				; XREF: sub_1642
		lea	($C00004).l,a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		movea.l	(PLC_Buffer).w,a0
		movea.l	(PLC_Buffer_Reg_0).w,a3
		move.l	(PLC_Buffer_Reg_4).w,d0
		move.l	(PLC_Buffer_Reg_8).w,d1
		move.l	(PLC_Buffer_Reg_C).w,d2
		move.l	(PLC_Buffer_Reg_10).w,d5
		move.l	(PLC_Buffer_Reg_14).w,d6
		lea	(Nem_Decomp_Buffer).w,a1

loc_16AA:				; XREF: sub_165E
		movea.w	#8,a5
		bsr.w	NemDec3
		subq.w	#1,(PLC_Buffer_Reg_18).w
		beq.s	loc_16DC
		subq.w	#1,(PLC_Buffer_Reg_1A).w
		bne.s	loc_16AA
		move.l	a0,(PLC_Buffer).w
		move.l	a3,(PLC_Buffer_Reg_0).w
		move.l	d0,(PLC_Buffer_Reg_4).w
		move.l	d1,(PLC_Buffer_Reg_8).w
		move.l	d2,(PLC_Buffer_Reg_C).w
		move.l	d5,(PLC_Buffer_Reg_10).w
		move.l	d6,(PLC_Buffer_Reg_14).w

locret_16DA:				; XREF: sub_1642
		rts	
; ===========================================================================

loc_16DC:				; XREF: sub_165E
		lea	(PLC_Buffer).w,a0
		moveq	#$15,d0

loc_16E2:				; XREF: sub_165E
		move.l	6(a0),(a0)+
		dbf	d0,loc_16E2
		rts	
; End of function sub_165E

; ---------------------------------------------------------------------------
; Subroutine to	execute	the pattern load cue
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RunPLC_ROM:
		lea	(ArtLoadCues).l,a1 ; load the PLC index
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d1	; load number of entries in the	PLC

RunPLC_Loop:
		movea.l	(a1)+,a0	; get art pointer
		moveq	#0,d0
		move.w	(a1)+,d0	; get VRAM address
		lsl.l	#2,d0		; divide address by $20
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,($C00004).l	; put the VRAM address into VDP
		bsr.w	NemDec		; decompress
		dbf	d1,RunPLC_Loop	; loop for number of entries
		rts	
; End of function RunPLC_ROM

; ---------------------------------------------------------------------------
; Enigma decompression algorithm
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


EniDec:
		movem.l	d0-d7/a1-a5,-(sp)
		movea.w	d0,a3
		move.b	(a0)+,d0
		ext.w	d0
		movea.w	d0,a5
		move.b	(a0)+,d4
		lsl.b	#3,d4
		movea.w	(a0)+,a2
		adda.w	a3,a2
		movea.w	(a0)+,a4
		adda.w	a3,a4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6

loc_173E:				; XREF: loc_1768
		moveq	#7,d0
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1
		andi.w	#$7F,d1
		move.w	d1,d2
		cmpi.w	#$40,d1
		bcc.s	loc_1758
		moveq	#6,d0
		lsr.w	#1,d2

loc_1758:
		bsr.w	sub_188C
		andi.w	#$F,d2
		lsr.w	#4,d1
		add.w	d1,d1
		jmp	loc_17B4(pc,d1.w)
; End of function EniDec

; ===========================================================================

loc_1768:				; XREF: loc_17B4
		move.w	a2,(a1)+
		addq.w	#1,a2
		dbf	d2,loc_1768
		bra.s	loc_173E
; ===========================================================================

loc_1772:				; XREF: loc_17B4
		move.w	a4,(a1)+
		dbf	d2,loc_1772
		bra.s	loc_173E
; ===========================================================================

loc_177A:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_177E:
		move.w	d1,(a1)+
		dbf	d2,loc_177E
		bra.s	loc_173E
; ===========================================================================

loc_1786:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_178A:
		move.w	d1,(a1)+
		addq.w	#1,d1
		dbf	d2,loc_178A
		bra.s	loc_173E
; ===========================================================================

loc_1794:				; XREF: loc_17B4
		bsr.w	loc_17DC

loc_1798:
		move.w	d1,(a1)+
		subq.w	#1,d1
		dbf	d2,loc_1798
		bra.s	loc_173E
; ===========================================================================

loc_17A2:				; XREF: loc_17B4
		cmpi.w	#$F,d2
		beq.s	loc_17C4

loc_17A8:
		bsr.w	loc_17DC
		move.w	d1,(a1)+
		dbf	d2,loc_17A8
		bra.s	loc_173E
; ===========================================================================

loc_17B4:				; XREF: EniDec
		bra.s	loc_1768
; ===========================================================================
		bra.s	loc_1768
; ===========================================================================
		bra.s	loc_1772
; ===========================================================================
		bra.s	loc_1772
; ===========================================================================
		bra.s	loc_177A
; ===========================================================================
		bra.s	loc_1786
; ===========================================================================
		bra.s	loc_1794
; ===========================================================================
		bra.s	loc_17A2
; ===========================================================================

loc_17C4:				; XREF: loc_17A2
		subq.w	#1,a0
		cmpi.w	#$10,d6
		bne.s	loc_17CE
		subq.w	#1,a0

loc_17CE:
		move.w	a0,d0
		lsr.w	#1,d0
		bcc.s	loc_17D6
		addq.w	#1,a0

loc_17D6:
		movem.l	(sp)+,d0-d7/a1-a5
		rts	
; ===========================================================================

loc_17DC:				; XREF: loc_17A2
		move.w	a3,d3
		move.b	d4,d1
		add.b	d1,d1
		bcc.s	loc_17EE
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17EE
		ori.w	#$8000,d3

loc_17EE:
		add.b	d1,d1
		bcc.s	loc_17FC
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_17FC
		addi.w	#$4000,d3

loc_17FC:
		add.b	d1,d1
		bcc.s	loc_180A
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_180A
		addi.w	#$2000,d3

loc_180A:
		add.b	d1,d1
		bcc.s	loc_1818
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1818
		ori.w	#$1000,d3

loc_1818:
		add.b	d1,d1
		bcc.s	loc_1826
		subq.w	#1,d6
		btst	d6,d5
		beq.s	loc_1826
		ori.w	#$800,d3

loc_1826:
		move.w	d5,d1
		move.w	d6,d7
		sub.w	a5,d7
		bcc.s	loc_1856
		move.w	d7,d6
		addi.w	#$10,d6
		neg.w	d7
		lsl.w	d7,d1
		move.b	(a0),d5
		rol.b	d7,d5
		add.w	d7,d7
		and.w	word_186C-2(pc,d7.w),d5
		add.w	d5,d1

loc_1844:				; XREF: loc_1868
		move.w	a5,d0
		add.w	d0,d0
		and.w	word_186C-2(pc,d0.w),d1
		add.w	d3,d1
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		rts	
; ===========================================================================

loc_1856:				; XREF: loc_1826
		beq.s	loc_1868
		lsr.w	d7,d1
		move.w	a5,d0
		add.w	d0,d0
		and.w	word_186C-2(pc,d0.w),d1
		add.w	d3,d1
		move.w	a5,d0
		bra.s	sub_188C
; ===========================================================================

loc_1868:				; XREF: loc_1856
		moveq	#$10,d6

loc_186A:
		bra.s	loc_1844
; ===========================================================================
word_186C:	dc.w 1,	3, 7, $F, $1F, $3F, $7F, $FF, $1FF, $3FF, $7FF
		dc.w $FFF, $1FFF, $3FFF, $7FFF,	$FFFF	; XREF: loc_1856

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_188C:				; XREF: EniDec
		sub.w	d0,d6
		cmpi.w	#9,d6
		bcc.s	locret_189A
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5

locret_189A:
		rts	
; End of function sub_188C

; ===========================================================================
; ---------------------------------------------------------------------------
; Kosinski decompression routine
;
; Created by vladikcomper
; Special thanks to flamewing and MarkeyJester
; ---------------------------------------------------------------------------
 
_Kos_RunBitStream macro
        dbf     d2,@skip\@
        moveq   #7,d2
        move.b  d1,d0
        swap    d3
        bpl.s   @skip\@
        move.b  (a0)+,d0                        ; get desc. bitfield
        move.b  (a0)+,d1                        ;
        move.b  (a4,d0.w),d0                    ; reload converted desc. bitfield from a LUT
        move.b  (a4,d1.w),d1                    ;
@skip\@
        endm
; ---------------------------------------------------------------------------
 
KosDec:
        moveq   #7,d7
        moveq   #0,d0
        moveq   #0,d1
        lea     KosDec_ByteMap(pc),a4
        move.b  (a0)+,d0                        ; get desc field low-byte
        move.b  (a0)+,d1                        ; get desc field hi-byte
        move.b  (a4,d0.w),d0                    ; reload converted desc. bitfield from a LUT
        move.b  (a4,d1.w),d1                    ;
        moveq   #7,d2                           ; set repeat count to 8
        moveq   #-1,d3                          ; d3 will be desc field switcher
        clr.w   d3                              ;
        bra.s   KosDec_FetchNewCode
 
KosDec_FetchCodeLoop:
        ; code 1 (Uncompressed byte)
        _Kos_RunBitStream
        move.b  (a0)+,(a1)+
 
KosDec_FetchNewCode:
        add.b   d0,d0                           ; get a bit from the bitstream
        bcs.s   KosDec_FetchCodeLoop            ; if code = 0, branch
 
        ; codes 00 and 01
        _Kos_RunBitStream
        moveq   #0,d4                           ; d4 will contain copy count
        add.b   d0,d0                           ; get a bit from the bitstream
        bcs.s   KosDec_Code_01
 
        ; code 00 (Dictionary ref. short)
        _Kos_RunBitStream
        add.b   d0,d0                           ; get a bit from the bitstream
        addx.w  d4,d4
        _Kos_RunBitStream
        add.b   d0,d0                           ; get a bit from the bitstream
        addx.w  d4,d4
        _Kos_RunBitStream
        moveq   #-1,d5
        move.b  (a0)+,d5                        ; d5 = displacement
 
KosDec_StreamCopy:
        lea     (a1,d5),a3
        move.b  (a3)+,(a1)+                     ; do 1 extra copy (to compensate for +1 to copy counter)
 
KosDec_copy:
        move.b  (a3)+,(a1)+
        dbf     d4,KosDec_copy
        bra.w   KosDec_FetchNewCode
; ---------------------------------------------------------------------------
KosDec_Code_01:
        ; code 01 (Dictionary ref. long / special)
        _Kos_RunBitStream
        move.b  (a0)+,d6                        ; d6 = %LLLLLLLL
        move.b  (a0)+,d4                        ; d4 = %HHHHHCCC
        moveq   #-1,d5
        move.b  d4,d5                           ; d5 = %11111111 HHHHHCCC
        lsl.w   #5,d5                           ; d5 = %111HHHHH CCC00000
        move.b  d6,d5                           ; d5 = %111HHHHH LLLLLLLL
        and.w   d7,d4                           ; d4 = %00000CCC
        bne.s   KosDec_StreamCopy               ; if CCC=0, branch
 
        ; special mode (extended counter)
        move.b  (a0)+,d4                        ; read cnt
        beq.s   KosDec_Quit                     ; if cnt=0, quit decompression
        subq.b  #1,d4
        beq.w   KosDec_FetchNewCode             ; if cnt=1, fetch a new code
 
        lea     (a1,d5),a3
        move.b  (a3)+,(a1)+                     ; do 1 extra copy (to compensate for +1 to copy counter)
        move.w  d4,d6
        not.w   d6
        and.w   d7,d6
        add.w   d6,d6
        lsr.w   #3,d4
        jmp     KosDec_largecopy(pc,d6.w)
 
KosDec_largecopy:
        rept 8
        move.b  (a3)+,(a1)+
        endr
        dbf     d4,KosDec_largecopy
        bra.w   KosDec_FetchNewCode
 
KosDec_Quit:
        rts
 
; ---------------------------------------------------------------------------
; A look-up table to invert bits order in desc. field bytes
; ---------------------------------------------------------------------------
 
KosDec_ByteMap:
        dc.b    $0,$80,$40,$C0,$20,$A0,$60,$E0,$10,$90,$50,$D0,$30,$B0,$70,$F0
        dc.b    $8,$88,$48,$C8,$28,$A8,$68,$E8,$18,$98,$58,$D8,$38,$B8,$78,$F8
        dc.b    $4,$84,$44,$C4,$24,$A4,$64,$E4,$14,$94,$54,$D4,$34,$B4,$74,$F4
        dc.b    $C,$8C,$4C,$CC,$2C,$AC,$6C,$EC,$1C,$9C,$5C,$DC,$3C,$BC,$7C,$FC
        dc.b    $2,$82,$42,$C2,$22,$A2,$62,$E2,$12,$92,$52,$D2,$32,$B2,$72,$F2
        dc.b    $A,$8A,$4A,$CA,$2A,$AA,$6A,$EA,$1A,$9A,$5A,$DA,$3A,$BA,$7A,$FA
        dc.b    $6,$86,$46,$C6,$26,$A6,$66,$E6,$16,$96,$56,$D6,$36,$B6,$76,$F6
        dc.b    $E,$8E,$4E,$CE,$2E,$AE,$6E,$EE,$1E,$9E,$5E,$DE,$3E,$BE,$7E,$FE
        dc.b    $1,$81,$41,$C1,$21,$A1,$61,$E1,$11,$91,$51,$D1,$31,$B1,$71,$F1
        dc.b    $9,$89,$49,$C9,$29,$A9,$69,$E9,$19,$99,$59,$D9,$39,$B9,$79,$F9
        dc.b    $5,$85,$45,$C5,$25,$A5,$65,$E5,$15,$95,$55,$D5,$35,$B5,$75,$F5
        dc.b    $D,$8D,$4D,$CD,$2D,$AD,$6D,$ED,$1D,$9D,$5D,$DD,$3D,$BD,$7D,$FD
        dc.b    $3,$83,$43,$C3,$23,$A3,$63,$E3,$13,$93,$53,$D3,$33,$B3,$73,$F3
        dc.b    $B,$8B,$4B,$CB,$2B,$AB,$6B,$EB,$1B,$9B,$5B,$DB,$3B,$BB,$7B,$FB
        dc.b    $7,$87,$47,$C7,$27,$A7,$67,$E7,$17,$97,$57,$D7,$37,$B7,$77,$F7
        dc.b    $F,$8F,$4F,$CF,$2F,$AF,$6F,$EF,$1F,$9F,$5F,$DF,$3F,$BF,$7F,$FF
 
; ===========================================================================

; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Load:				; XREF: Demo; Level_MainLoop; End_MainLoop
		moveq	#0,d2
		moveq	#0,d0
		move.b	(Current_Zone).w,d0 ; get level number
		add.w	d0,d0		; multiply by 2
		move.w	PalCycle(pc,d0.w),d0 ; load animated Palettes offset index into d0
		jmp	PalCycle(pc,d0.w) ; jump to PalCycle + offset index
; End of function PalCycle_Load

; ===========================================================================
; ---------------------------------------------------------------------------
; Palette cycling routines
; ---------------------------------------------------------------------------
PalCycle:	dc.w PalCycle_GHZ-PalCycle
		dc.w PalCycle_LZ-PalCycle
		dc.w PalCycle_MZ-PalCycle
		dc.w PalCycle_SLZ-PalCycle
		dc.w PalCycle_SYZ-PalCycle
		dc.w PalCycle_SBZ-PalCycle
		dc.w PalCycle_GHZ-PalCycle

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Title:				; XREF: TitleScreen
		lea	(Pal_TitleCyc).l,a0
		bra.s	loc_196A
; ===========================================================================

PalCycle_GHZ:				; XREF: PalCycle
		lea	(Pal_GHZCyc).l,a0

loc_196A:				; XREF: PalCycle_Title
		subq.w	#1,(Pal_Cycle_Timer).w
		bpl.s	locret_1990
		move.w	#5,(Pal_Cycle_Timer).w
		move.w	(Pal_Cycle_Frame).w,d0
		addq.w	#1,(Pal_Cycle_Frame).w
		andi.w	#3,d0
		lsl.w	#3,d0
		lea	(Normal_Palette+$50).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)

locret_1990:
		rts	
; End of function PalCycle_Title


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_LZ:				; XREF: PalCycle
		subq.w	#1,(Pal_Cycle_Timer).w
		bpl.s	PalCycle_3LZ
		move.w	#7,(Pal_Cycle_Timer).w
		move.w	(Pal_Cycle_Frame).w,d0
		addq.w	#1,d0
		cmpi.w	#6,d0
		bcs.s	PalCycle_2LZ
		moveq	#0,d0

PalCycle_2LZ:
		move.w	d0,(Pal_Cycle_Frame).w
		move.w	d0,d1
		add.w	d1,d1
		add.w	d1,d0
		add.w	d0,d0
		lea	(Pal_LZCyc).l,a0
		lea	(Normal_Palette+$56).w,a1
		move.w	(a0,d0.w),(a1)
		move.l	2(a0,d0.w),4(a1)

PalCycle_3LZ:
		rts	
; End of function PalCycle_SLZ

; ===========================================================================
byte_1A3C:	dc.b 1,	0, 0, 1, 0, 0, 1, 0
; ===========================================================================

PalCycle_MZ:				; XREF: PalCycle
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SLZ:				; XREF: PalCycle
		subq.w	#1,(Pal_Cycle_Timer).w
		bpl.s	locret_1A80
		move.w	#7,(Pal_Cycle_Timer).w
		move.w	(Pal_Cycle_Frame).w,d0
		addq.w	#1,d0
		cmpi.w	#6,d0
		bcs.s	loc_1A60
		moveq	#0,d0

loc_1A60:
		move.w	d0,(Pal_Cycle_Frame).w
		move.w	d0,d1
		add.w	d1,d1
		add.w	d1,d0
		add.w	d0,d0
		lea	(Pal_SLZCyc).l,a0
		lea	(Normal_Palette+$56).w,a1
		move.w	(a0,d0.w),(a1)
		move.l	2(a0,d0.w),4(a1)

locret_1A80:
		rts	
; End of function PalCycle_SLZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SYZ:				; XREF: PalCycle
		subq.w	#1,(Pal_Cycle_Timer).w
		bpl.s	locret_1AC6
		move.w	#5,(Pal_Cycle_Timer).w
		move.w	(Pal_Cycle_Frame).w,d0
		addq.w	#1,(Pal_Cycle_Frame).w
		andi.w	#3,d0
		lsl.w	#2,d0
		move.w	d0,d1
		add.w	d0,d0
		lea	(Pal_SYZCyc1).l,a0
		lea	(Normal_Palette+$6E).w,a1
		move.l	(a0,d0.w),(a1)+
		move.l	4(a0,d0.w),(a1)
		lea	(Pal_SYZCyc2).l,a0
		lea	(Normal_Palette+$76).w,a1
		move.w	(a0,d1.w),(a1)
		move.w	2(a0,d1.w),4(a1)

locret_1AC6:
		rts	
; End of function PalCycle_SYZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_SBZ:				; XREF: PalCycle
		lea	(Pal_SBZCycList2).l,a2
		lea	(Pal_Cycle_Buffer).w,a1
		move.w	(a2)+,d1

loc_1AE0:
		subq.b	#1,(a1)
		bmi.s	loc_1AEA
		addq.l	#2,a1
		addq.l	#6,a2
		bra.s	loc_1B06
; ===========================================================================

loc_1AEA:				; XREF: PalCycle_SBZ
		move.b	(a2)+,(a1)+
		move.b	(a1),d0
		addq.b	#1,d0
		cmp.b	(a2)+,d0
		bcs.s	loc_1AF6
		moveq	#0,d0

loc_1AF6:
		move.b	d0,(a1)+
		andi.w	#$F,d0
		add.w	d0,d0
		movea.w	(a2)+,a0
		movea.w	(a2)+,a3
		move.w	(a0,d0.w),(a3)

loc_1B06:				; XREF: PalCycle_SBZ
		dbf	d1,loc_1AE0
		subq.w	#1,(Pal_Cycle_Timer).w
		bpl.s	locret_1B64
		lea	(Pal_SBZCyc4).l,a0
		move.w	#1,(Pal_Cycle_Timer).w
		lea	(Pal_SBZCyc10).l,a0
		move.w	#0,(Pal_Cycle_Timer).w
		moveq	#-1,d1
		tst.b	(Reverse_Converyor_Flag).w
		beq.s	loc_1B38
		neg.w	d1

loc_1B38:
		move.w	(Pal_Cycle_Frame).w,d0
		andi.w	#3,d0
		add.w	d1,d0
		cmpi.w	#3,d0
		bcs.s	loc_1B52
		move.w	d0,d1
		moveq	#0,d0
		tst.w	d1
		bpl.s	loc_1B52
		moveq	#2,d0

loc_1B52:
		move.w	d0,(Pal_Cycle_Frame).w
		add.w	d0,d0
		lea	(Normal_Palette+$58).w,a1
		move.l	(a0,d0.w),(a1)+
		move.w	4(a0,d0.w),(a1)

locret_1B64:
		rts	
; End of function PalCycle_SBZ

; ===========================================================================
Pal_TitleCyc:	incbin	Palette\c_title.bin
Pal_GHZCyc:	incbin	Palette\c_ghz.bin
Pal_LZCyc:	incbin	Palette\c_lz.bin
Pal_LZCyc1:	incbin	Palette\c_lz_wat.bin	; waterfalls Palette
Pal_LZCyc2:	incbin	Palette\c_lz_bel.bin	; conveyor belt Palette
Pal_LZCyc3:	incbin	Palette\c_lz_buw.bin	; conveyor belt (underwater) Palette
Pal_SBZ3Cyc1:	incbin	Palette\c_sbz3_w.bin	; waterfalls Palette
Pal_SLZCyc:	incbin	Palette\c_slz.bin
Pal_SYZCyc1:	incbin	Palette\c_syz_1.bin
Pal_SYZCyc2:	incbin	Palette\c_syz_2.bin
; ===========================================================================
Pal_SBZCycList2:
	dc.w 6
	dc.b 7,	8
	dc.w Pal_SBZCyc1
	dc.w $FB50
	dc.b $D, 8
	dc.w Pal_SBZCyc2
	dc.w $FB52
	dc.b 9,	8
	dc.w Pal_SBZCyc9
	dc.w $FB70
	dc.b 7,	8
	dc.w Pal_SBZCyc6
	dc.w $FB72
	dc.b 3,	3
	dc.w Pal_SBZCyc8
	dc.w $FB78
	dc.b 3,	3
	dc.w Pal_SBZCyc8+2
	dc.w $FB7A
	dc.b 3,	3
	dc.w Pal_SBZCyc8+4
	dc.w $FB7C
	even
; ===========================================================================
Pal_SBZCyc1:	incbin	Palette\c_sbz_1.bin
Pal_SBZCyc2:	incbin	Palette\c_sbz_2.bin
Pal_SBZCyc3:	incbin	Palette\c_sbz_3.bin
Pal_SBZCyc4:	incbin	Palette\c_sbz_4.bin
Pal_SBZCyc5:	incbin	Palette\c_sbz_5.bin
Pal_SBZCyc6:	incbin	Palette\c_sbz_6.bin
Pal_SBZCyc7:	incbin	Palette\c_sbz_7.bin
Pal_SBZCyc8:	incbin	Palette\c_sbz_8.bin
Pal_SBZCyc9:	incbin	Palette\c_sbz_9.bin
Pal_SBZCyc10:	incbin	Palette\c_sbz_10.bin
; ---------------------------------------------------------------------------
; Subroutine to	fade out and fade in
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeTo:
		move.w	#$3F,(Palette_Fade_Range).w

Pal_FadeTo2:
		moveq	#0,d0
		lea	(Normal_Palette).w,a0
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		moveq	#0,d1
		move.b	(Palette_Fade_Length).w,d0

Pal_ToBlack:
		move.w	d1,(a0)+
		dbf	d0,Pal_ToBlack	; fill Palette with $00	(black)
		moveq	#$E,d4					; MJ: prepare maximum colour check
		moveq	#$0,d6					; MJ: clear d6

loc_1DCE:
		bsr.w	RunPLC_RAM
		move.b	#$12,(V_Int_Routine).w
		bsr.w	DelayProgram
		bchg	#$0,d6					; MJ: change delay counter
		beq	loc_1DCE				; MJ: if null, delay a frame
		bsr.s	Pal_FadeIn
		subq.b	#$2,d4					; MJ: decrease colour check
		bne	loc_1DCE				; MJ: if it has not reached null, branch
		move.b	#$12,(V_Int_Routine).w			; MJ: wait for V-blank again (so colours transfer)
		bra	DelayProgram				; MJ: ''

; End of function Pal_FadeTo

; ---------------------------------------------------------------------------
; Palette fade-in subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeIn:				; XREF: Pal_FadeTo
		moveq	#0,d0
		lea	(Normal_Palette).w,a0
		lea	(Target_Palette).w,a1
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_Fade_Length).w,d0

loc_1DFA:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1DFA
		cmpi.b	#1,(Current_Zone).w
		bne.s	locret_1E24
		moveq	#0,d0
		lea	(Underwater_Palette).w,a0
		lea	(Target_Underwater_Palette).w,a1
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_Fade_Length).w,d0

loc_1E1E:
		bsr.s	Pal_AddColor
		dbf	d0,loc_1E1E

locret_1E24:
		rts	
; End of function Pal_FadeIn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor:				; XREF: Pal_FadeIn
		move.b	(a1),d5					; MJ: load blue
		move.w	(a1)+,d1				; MJ: load green and red
		move.b	d1,d2					; MJ: load red
		lsr.b	#$4,d1					; MJ: get only green
		andi.b	#$E,d2					; MJ: get only red
		move.w	(a0),d3					; MJ: load current colour in buffer
		cmp.b	d5,d4					; MJ: is it time for blue to fade?
		bhi	FCI_NoBlue				; MJ: if not, branch
		addi.w	#$200,d3				; MJ: increase blue

FCI_NoBlue:
		cmp.b	d1,d4					; MJ: is it time for green to fade?
		bhi	FCI_NoGreen				; MJ: if not, branch
		addi.b	#$20,d3					; MJ: increase green

FCI_NoGreen:
		cmp.b	d2,d4					; MJ: is it time for red to fade?
		bhi	FCI_NoRed				; MJ: if not, branch
		addq.b	#$2,d3					; MJ: increase red

FCI_NoRed:
		move.w	d3,(a0)+				; MJ: save colour
		rts						; MJ: return

; End of function Pal_AddColor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeFrom:
		move.w	#$3F,(Palette_Fade_Range).w
		moveq	#$7,d4					; MJ: set repeat times
		moveq	#$0,d6					; MJ: clear d6

loc_1E5C:
		bsr.w	RunPLC_RAM
		move.b	#$12,(V_Int_Routine).w
		bsr.w	DelayProgram
		bchg	#$0,d6					; MJ: change delay counter
		beq	loc_1E5C				; MJ: if null, delay a frame
		bsr.s	Pal_FadeOut
		dbf	d4,loc_1E5C
		rts	
; End of function Pal_FadeFrom

; ---------------------------------------------------------------------------
; Palette fade-out subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_FadeOut:				; XREF: Pal_FadeFrom
		moveq	#0,d0
		lea	(Normal_Palette).w,a0
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		move.b	(Palette_Fade_Length).w,d0

loc_1E82:
		bsr.s	Pal_DecColor
		dbf	d0,loc_1E82

		moveq	#0,d0
		lea	(Underwater_Palette).w,a0
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		move.b	(Palette_Fade_Length).w,d0

loc_1E98:
		bsr.s	Pal_DecColor
		dbf	d0,loc_1E98
		rts	
; End of function Pal_FadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor:				; XREF: Pal_FadeOut
		move.w	(a0),d5					; MJ: load colour
		move.w	d5,d1					; MJ: copy to d1
		move.b	d1,d2					; MJ: load green and red
		move.b	d1,d3					; MJ: load red
		andi.w	#$E00,d1				; MJ: get only blue
		beq	FCO_NoBlue				; MJ: if blue is finished, branch
		subi.w	#$200,d5				; MJ: decrease blue

FCO_NoBlue:
		andi.w	#$0E0,d2				; MJ: get only green (needs to be word)
		beq	FCO_NoGreen				; MJ: if green is finished, branch
		subi.b	#$20,d5					; MJ: decrease green

FCO_NoGreen:
		andi.b	#$E,d3					; MJ: get only red
		beq	FCO_NoRed				; MJ: if red is finished, branch
		subq.b	#$2,d5					; MJ: decrease red

FCO_NoRed:
		move.w	d5,(a0)+				; MJ: save new colour
		rts						; MJ: return

; End of function Pal_DecColor

; ---------------------------------------------------------------------------
; Subroutine to	fill the Palette	with white (special stage)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_MakeWhite:				; XREF: SpecialStage
		move.w	#$3F,(Palette_Fade_Range).w
		moveq	#0,d0
		lea	(Normal_Palette).w,a0
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		move.w	#$EEE,d1
		move.b	(Palette_Fade_Length).w,d0

PalWhite_Loop:
		move.w	d1,(a0)+
		dbf	d0,PalWhite_Loop
		move.w	#$15,d4

loc_1EF4:
		move.b	#$12,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.s	Pal_WhiteToBlack
		bsr.w	RunPLC_RAM
		dbf	d4,loc_1EF4
		rts	
; End of function Pal_MakeWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_WhiteToBlack:			; XREF: Pal_MakeWhite
		moveq	#0,d0
		lea	(Normal_Palette).w,a0
		lea	(Target_Palette).w,a1
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_Fade_Length).w,d0

loc_1F20:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_1F20

		cmpi.b	#1,(Current_Zone).w
		bne.s	locret_1F4A
		moveq	#0,d0
		lea	(Underwater_Palette).w,a0
		lea	(Target_Underwater_Palette).w,a1
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		adda.w	d0,a1
		move.b	(Palette_Fade_Length).w,d0

loc_1F44:
		bsr.s	Pal_DecColor2
		dbf	d0,loc_1F44

locret_1F4A:
		rts	
; End of function Pal_WhiteToBlack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_DecColor2:				; XREF: Pal_WhiteToBlack
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_1F78
		move.w	d3,d1
		subi.w	#$200,d1	; decrease blue	value
		bcs.s	loc_1F64
		cmp.w	d2,d1
		bcs.s	loc_1F64
		move.w	d1,(a0)+
		rts	
; ===========================================================================

loc_1F64:				; XREF: Pal_DecColor2
		move.w	d3,d1
		subi.w	#$20,d1		; decrease green value
		bcs.s	loc_1F74
		cmp.w	d2,d1
		bcs.s	loc_1F74
		move.w	d1,(a0)+
		rts	
; ===========================================================================

loc_1F74:				; XREF: loc_1F64
		subq.w	#2,(a0)+	; decrease red value
		rts	
; ===========================================================================

loc_1F78:				; XREF: Pal_DecColor2
		addq.w	#2,a0
		rts	
; End of function Pal_DecColor2

; ---------------------------------------------------------------------------
; Subroutine to	make a white flash when	you enter a special stage
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_MakeFlash:				; XREF: SpecialStage
		move.w	#$3F,(Palette_Fade_Range).w
		move.w	#$15,d4

loc_1F86:
		move.b	#$12,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.s	Pal_ToWhite
		bsr.w	RunPLC_RAM
		dbf	d4,loc_1F86
		rts	
; End of function Pal_MakeFlash


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_ToWhite:				; XREF: Pal_MakeFlash
		moveq	#0,d0
		lea	(Normal_Palette).w,a0
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		move.b	(Palette_Fade_Length).w,d0

loc_1FAC:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_1FAC
		moveq	#0,d0
		lea	(Underwater_Palette).w,a0
		move.b	(Palette_Fade_Start).w,d0
		adda.w	d0,a0
		move.b	(Palette_Fade_Length).w,d0

loc_1FC2:
		bsr.s	Pal_AddColor2
		dbf	d0,loc_1FC2
		rts	
; End of function Pal_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Pal_AddColor2:				; XREF: Pal_ToWhite
		move.w	(a0),d2
		cmpi.w	#$EEE,d2
		beq.s	loc_2006
		move.w	d2,d1
		andi.w	#$E,d1
		cmpi.w	#$E,d1
		beq.s	loc_1FE2
		addq.w	#2,(a0)+	; increase red value
		rts	
; ===========================================================================

loc_1FE2:				; XREF: Pal_AddColor2
		move.w	d2,d1
		andi.w	#$E0,d1
		cmpi.w	#$E0,d1
		beq.s	loc_1FF4
		addi.w	#$20,(a0)+	; increase green value
		rts	
; ===========================================================================

loc_1FF4:				; XREF: loc_1FE2
		move.w	d2,d1
		andi.w	#$E00,d1
		cmpi.w	#$E00,d1
		beq.s	loc_2006
		addi.w	#$200,(a0)+	; increase blue	value
		rts	
; ===========================================================================

loc_2006:				; XREF: Pal_AddColor2
		addq.w	#2,a0
		rts	
; End of function Pal_AddColor2

; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalCycle_Sega:				; XREF: SegaScreen
		tst.b	(Pal_Cycle_Timer+1).w
		bne.s	loc_206A
		lea	(Normal_Palette+$20).w,a1
		lea	(Pal_Sega1).l,a0
		moveq	#5,d1
		move.w	(Pal_Cycle_Frame).w,d0

loc_2020:
		bpl.s	loc_202A
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_2020
; ===========================================================================

loc_202A:				; XREF: PalCycle_Sega
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2034
		addq.w	#2,d0

loc_2034:
		cmpi.w	#$60,d0
		bcc.s	loc_203E
		move.w	(a0)+,(a1,d0.w)

loc_203E:
		addq.w	#2,d0
		dbf	d1,loc_202A
		move.w	(Pal_Cycle_Frame).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_2054
		addq.w	#2,d0

loc_2054:
		cmpi.w	#$64,d0
		blt.s	loc_2062
		move.w	#$401,(Pal_Cycle_Timer).w
		moveq	#-$C,d0

loc_2062:
		move.w	d0,(Pal_Cycle_Frame).w
		moveq	#1,d0
		rts	
; ===========================================================================

loc_206A:				; XREF: loc_202A
		subq.b	#1,(Pal_Cycle_Timer).w
		bpl.s	loc_20BC
		move.b	#4,(Pal_Cycle_Timer).w
		move.w	(Pal_Cycle_Frame).w,d0
		addi.w	#$C,d0
		cmpi.w	#$30,d0
		bcs.s	loc_2088
		moveq	#0,d0
		rts	
; ===========================================================================

loc_2088:				; XREF: loc_206A
		move.w	d0,(Pal_Cycle_Frame).w
		lea	(Pal_Sega2).l,a0
		lea	(a0,d0.w),a0
		lea	(Normal_Palette+$4).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(Normal_Palette+$20).w,a1
		moveq	#0,d0
		moveq	#$2C,d1

loc_20A8:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	loc_20B2
		addq.w	#2,d0

loc_20B2:
		move.w	(a0),(a1,d0.w)
		addq.w	#2,d0
		dbf	d1,loc_20A8

loc_20BC:
		moveq	#1,d0
		rts	
; End of function PalCycle_Sega

; ===========================================================================

Pal_Sega1:	incbin	Palette\sega1.bin
Pal_Sega2:	incbin	Palette\sega2.bin

; ---------------------------------------------------------------------------
; Subroutines to load Palettes
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad1:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		adda.w	#$80,a3
		move.w	(a1)+,d7

loc_2110:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2110
		rts	
; End of function PalLoad1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad2:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		move.w	(a1)+,d7

loc_2128:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2128
		rts	
; End of function PalLoad2

; ---------------------------------------------------------------------------
; Underwater Palette loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad3_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#$80,a3
		move.w	(a1)+,d7

loc_2144:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2144
		rts	
; End of function PalLoad3_Water


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PalLoad4_Water:
		lea	(PalPointers).l,a1
		lsl.w	#3,d0
		adda.w	d0,a1
		movea.l	(a1)+,a2
		movea.w	(a1)+,a3
		suba.w	#$100,a3
		move.w	(a1)+,d7

loc_2160:
		move.l	(a2)+,(a3)+
		dbf	d7,loc_2160
		rts	
; End of function PalLoad4_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------
PalPointers:
	dc.l Pal_SegaBG		; pallet address
	dc.w $FB00		; RAM address
	dc.w $1F		; (pallet length / 2) - 1
	dc.l Pal_Title
	dc.w $FB00
	dc.w $1F
	dc.l Pal_LevelSel
	dc.w $FB00
	dc.w $1F
	dc.l Pal_Sonic
	dc.w $FB00
	dc.w 7
	dc.l Pal_GHZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_MZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_SLZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_SYZ
	dc.w $FB20
	dc.w $17
	dc.l Pal_SBZ2
	dc.w $FB20
	dc.w $17
	dc.l Pal_Special
	dc.w $FB00
	dc.w $1F
	dc.l Pal_LZWater
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SBZ2
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZWater
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SBZ2
	dc.w $FB20
	dc.w $17
	dc.l Pal_LZSonWater
	dc.w $FB00
	dc.w 7
	dc.l Pal_LZSonWater
	dc.w $FB00
	dc.w 7
	dc.l Pal_SpeResult
	dc.w $FB00
	dc.w $1F
	dc.l Pal_SpeContinue
	dc.w $FB00
	dc.w $F
	dc.l Pal_Ending
	dc.w $FB00
	dc.w $1F
	dc.l Pal_Notice
	dc.w $FB20
	dc.w $17
	dc.l Pal_SndTest
	dc.w $FB00
	dc.w $17
; ---------------------------------------------------------------------------
; Palette data
; ---------------------------------------------------------------------------
Pal_SegaBG:	incbin	Palette\sega_bg.bin
Pal_Title:	incbin	Palette\title.bin
			even
Pal_LevelSel:	incbin	Palette\levelsel.bin
Pal_Sonic:	incbin	Palette\sonic.bin
Pal_GHZ:	incbin	Palette\ghz.bin
Pal_LZ:		incbin	Palette\lz.bin
Pal_LZWater:	incbin	Palette\lz_uw.bin	; LZ underwater Palettes
Pal_MZ:		incbin	Palette\mz.bin
Pal_SLZ:	incbin	Palette\slz.bin
Pal_SYZ:	incbin	Palette\syz.bin
Pal_SBZ2:	incbin	Palette\sbz_act2.bin	; SBZ act 2 & Final Zone Palettes
Pal_Special:	incbin	Palette\special.bin	; special stage Palettes
Pal_LZSonWater:	incbin	Palette\son_lzuw.bin	; Sonic (underwater in LZ) Palette
Pal_SpeResult:	incbin	Palette\ssresult.bin	; special stage results screen Palettes
Pal_SpeContinue:incbin	Palette\sscontin.bin	; special stage results screen continue Palette
Pal_Ending:	incbin	Palette\ending.bin	; ending sequence Palettes

; ---------------------------------------------------------------------------
; Subroutine to	delay the program by (V_Int_Routine) frames
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DelayProgram:				; XREF: PauseGame
		move	#$2300,sr

loc_29AC:
		tst.b	(V_Int_Routine).w
		bne.s	loc_29AC
		rts	
; End of function DelayProgram

; ---------------------------------------------------------------------------
; Subroutine to	generate a pseudo-random number	in d0
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


RandomNumber:
		move.l	(Random_Seed).w,d1
		bne.s	loc_29C0
		move.l	#$2A6D365A,d1

loc_29C0:
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1
		move.l	d1,(Random_Seed).w
		rts	
; End of function RandomNumber


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:				; XREF: SS_BGAnimate; et al
		andi.w	#$FF,d0
		add.w	d0,d0
		addi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d1
		subi.w	#$80,d0
		move.w	Sine_Data(pc,d0.w),d0
		rts	
; End of function CalcSine

; ===========================================================================

Sine_Data:	incbin	data/trig/sinewave.bin	; values for a 360\BA sine wave

; ===========================================================================
		movem.l	d1-d2,-(sp)
		move.w	d0,d1
		swap	d1
		moveq	#0,d0
		move.w	d0,d1
		moveq	#7,d2

loc_2C80:
		rol.l	#2,d1
		add.w	d0,d0
		addq.w	#1,d0
		sub.w	d0,d1
		bcc.s	loc_2C9A
		add.w	d0,d1
		subq.w	#1,d0
		dbf	d2,loc_2C80
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts	
; ===========================================================================

loc_2C9A:
		addq.w	#1,d0
		dbf	d2,loc_2C80
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcAngle:
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	loc_2D04
		move.w	d2,d4
		tst.w	d3
		bpl.w	loc_2CC2
		neg.w	d3

loc_2CC2:
		tst.w	d4
		bpl.w	loc_2CCA
		neg.w	d4

loc_2CCA:
		cmp.w	d3,d4
		bcc.w	loc_2CDC
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	Angle_Data(pc,d4.w),d0
		bra.s	loc_2CE6
; ===========================================================================

loc_2CDC:				; XREF: CalcAngle
		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	Angle_Data(pc,d3.w),d0

loc_2CE6:
		tst.w	d1
		bpl.w	loc_2CF2
		neg.w	d0
		addi.w	#$80,d0

loc_2CF2:
		tst.w	d2
		bpl.w	loc_2CFE
		neg.w	d0
		addi.w	#$100,d0

loc_2CFE:
		movem.l	(sp)+,d3-d4
		rts	
; ===========================================================================

loc_2D04:				; XREF: CalcAngle
		move.w	#$40,d0
		movem.l	(sp)+,d3-d4
		rts	
; End of function CalcAngle

; ===========================================================================

Angle_Data:	incbin	data/trig/angles.bin

NoticeScreen: include	"screens/notice/code.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

SegaScreen:				; XREF: GameModeArray
		move.b	#CmdID_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	(Water_Fullscreen_Flag).w
		move	#$2700,sr
		move.w	(VDP_Reg_1_Value).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		move.l	#$40000000,($C00004).l
		lea	(Nem_SegaLogo).l,a0 ; load Sega	logo patterns
		bsr.w	NemDec
		lea	(General_Buffer).l,a1
		lea	(Eni_SegaLogo).l,a0 ; load Sega	logo mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	(General_Buffer).l,a1
		move.l	#$65100003,d0
		moveq	#$17,d1
		moveq	#7,d2
		bsr.w	LoadPlaneMap
		lea	(General_Buffer+$180).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	LoadPlaneMap
		moveq	#0,d0
		bsr.w	PalLoad2	; load Sega logo Palette
		move.w	#-$A,(Pal_Cycle_Frame).w
		move.w	#0,(Pal_Cycle_Timer).w
		
		move.l	#0,(Sega_H_Int_First_Color_Index).w
		move.l	#0,(Sega_H_Int_Sine_Address).w
		move.l	#0,(Sega_Deform_Sine_Index).w
		move.l	#0,(Sega_H_Int_Color_Modifier).w
		move.w	#0,(Sega_H_Int_Curr_Color_Index).w
		
		move.w	(VDP_Reg_1_Value).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

Sega_WaitPalette:
		move.b	#2,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.w	PalCycle_Sega
		bne.s	Sega_WaitPalette

		moveq	#$FFFFFF8C,d0
		jsr	PlaySample
		move.w	#$40,(Universal_Timer).w

Sega_WaitEnd:
		move.b	#2,(V_Int_Routine).w
		bsr.w	DelayProgram
		tst.w	(Universal_Timer).w
		beq.s	Sega_DoTrickery
		andi.b	#$80,(Ctrl_1_Press).w ; is	Start button pressed?
		beq.s	Sega_WaitEnd	; if not, branch
		bra.s	Sega_GotoTitle

Sega_DoTrickery:
		move.l	#H_Int_SegaScreen,HBlankJump+2
		lea	($C00004).l,a6
		move.w	#$8A00,(H_Int_Counter).w
		move.w	(H_Int_Counter).w,(a6)
		move.w	#$8014,(a6)
		
		lea	(Pal_Sega2+$24).l,a0
		lea	(Normal_Palette+$4).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)+
		moveq	#0,d0
		moveq	#$80-$E,d1

@LoadPal:
		move.w	(a0),(a1)+
		dbf	d1,@LoadPal
		
		move.w	#8,(Sega_Effect_Modifier).w
		move.w	#$A0,(Universal_Timer).w
		
Sega_WaitEnd2:
		move.b	#2,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.w	Deform_Sega
		move.w	(Universal_Timer).w,d0
		andi.w	#3,d0
		bne.s	@Finished
		cmpi.w	#2,(Sega_Effect_Modifier).w
		beq.s	@Finished
		subq.w	#1,(Sega_Effect_Modifier).w
		
@Finished:
		tst.w	(Universal_Timer).w
		beq.s	Sega_GotoTitle
		andi.b	#$80,(Ctrl_1_Press).w ; is	Start button pressed?
		beq.s	Sega_WaitEnd2	; if not, branch

Sega_GotoTitle:
		move.l	#H_Int,HBlankJump+2
		lea	($C00004).l,a6
		move.w	#$8ADF,(H_Int_Counter).w
		move.w	(H_Int_Counter).w,(a6)
		move.w	#$8004,(a6)
		
		lea	(Horiz_Scroll_Buf).l,a1
		move.w	#$DF,d1
		
@Clear:
		move.l	#0,(a1)+
		dbf	d1,@Clear
		
		move.l	#$40000010,($C00004).l
		move.l	#0,($C00000).l
		
		move.l	#0,(Sega_H_Int_First_Color_Index).w
		move.l	#0,(Sega_H_Int_Sine_Address).w
		move.l	#0,(Sega_Deform_Sine_Index).w
		move.l	#0,(Sega_H_Int_Color_Modifier).w
		move.w	#0,(Sega_H_Int_Curr_Color_Index).w

		stopZ80					; Stop PCM
		move.b	#$80,($A01FFF).l
		startZ80
		nop
		nop
		nop
		move.b	#4,(Game_Mode).w ; go to title screen
		jmp	Owarisoft
; ===========================================================================

Deform_Sega:
		lea	(Sine_Data).l,a0
		lea	(Horiz_Scroll_Buf).l,a1
		move.w	(Sega_Deform_Sine_Index).w,d0
		move.w	#$DF,d1
		cmpi.w	#$200,d0
		blt.s	@Cont
		moveq	#0,d0
		move.w	d0,(Sega_Deform_Sine_Index).w
		
@Cont:
		adda.w	d0,a0
		
@Deform:
		move.w	(a0)+,d0
		move.w	(Sega_Effect_Modifier).w,d2
		lsr.w	d2,d0
		andi.l	#$FFFF,d0
		move.w	d0,(a1)+
		move.w	#0,(a1)+
		addq.w	#2,(Sega_Deform_Sine_Index).w
		cmpa.w	#(Sine_Data+$200),a0
		blt.s	@Cont2
		move.w	#0,(Sega_Deform_Sine_Index).w
		lea	(Sine_Data).l,a0
		
@Cont2:
		dbf	d1,@Deform
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

TitleScreen:				; XREF: GameModeArray
		move.b	#CmdID_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		move	#$2700,sr
		bsr.w	InitMegaPCM
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B00,(a6)
		move.w	#$8720,(a6)
		clr.b	(Water_Fullscreen_Flag).w
		bsr.w	ClearScreen
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1

Title_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrObjRam ; fill object RAM ($D000-$EFFF) with	0

		move.l	#$40000000,($C00004).l
		lea	(Nem_JapNames).l,a0 ; load Japanese credits
		bsr.w	NemDec
		move.l	#$54C00000,($C00004).l
		lea	(Nem_CreditText).l,a0 ;	load alphabet
		bsr.w	NemDec
		lea	(General_Buffer).l,a1
		lea	(Eni_JapNames).l,a0 ; load mappings for	Japanese credits
		move.w	#0,d0
		bsr.w	EniDec
		lea	(General_Buffer).l,a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	LoadPlaneMap
		lea	(Target_Palette).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

Title_ClrPalette:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrPalette ; fill Palette with 0	(black)

		moveq	#3,d0		; load Sonic's Palette
		bsr.w	PalLoad1
		move.b	#$8A,(Object_Space_3).w ; load "SONIC TEAM PRESENTS"	object
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	Pal_FadeTo
		move	#$2700,sr
		move.l	#$40000001,($C00004).l
		lea	(Nem_TitleFg).l,a0 ; load title	screen patterns
		bsr.w	NemDec
		move.l	#$7A200001,($C00004).l
		lea	(Nem_TitleSonic).l,a0 ;	load Sonic title screen	patterns
		bsr.w	NemDec
		lea	($C00000).l,a6
		move.l	#$50000003,4(a6)
		lea	(Art_Text).l,a5
		move.w	#$28F,d1

Title_LoadText:
		move.w	(a5)+,(a6)
		dbf	d1,Title_LoadText ; load uncompressed text patterns
		
		move.b	#0,(Last_Checkpoint_Hit).w ; clear lamppost counter
		move.w	#0,(Debug_Placement_Mode).w ; disable debug item placement	mode
		move.w	#0,(Demo_Mode).w ; disable debug mode
		move.w	#0,(Current_Zone_And_Act).w ; set level to	GHZ (00)
		move.w	#0,(Pal_Cycle_Timer).w ; disable Palette cycling
		bsr.w	Pal_FadeFrom
		move	#$2700,sr
		bsr.w	ClearScreen
		
		lea	(Map_TitleBG).l,a1
		move.l	#$60000003,d0
		moveq	#$3F,d1
		moveq	#$1B,d2
		move.w	#$4001,d5
		bsr.w	LoadPlaneMap2
		
		move.l	#$40200000,($C00004).l
		lea	(Nem_TitleBG).l,a0
		bsr.w	NemDec
		
		lea	(General_Buffer).l,a1
		lea	(Eni_Title).l,a0 ; load	title screen mappings
		move.w	#0,d0
		bsr.w	EniDec
		lea	(General_Buffer).l,a1
		move.l	#$42060003,d0
		moveq	#$21,d1
		moveq	#$15,d2
		bsr.w	LoadPlaneMap
		moveq	#1,d0		; load title screen Palette
		bsr.w	PalLoad1
		move.b	#MusID_Title,d0		; play title screen music
		bsr.w	PlaySound_Special
		move.b	#0,(Debug_Cheat_On).w ; disable debug mode
		move.w	#$654,(Universal_Timer).w ; run title	screen for $178	frames
		lea	(Object_Space_3).w,a1
		moveq	#0,d0
		move.w	#$F,d1	; ($40 / 4) - 1

Title_ClrObjRam2:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrObjRam2

		move.b	#$E,(Object_Space_2).w ; load big Sonic object
		move.b	#$F,(Object_Space_3).w
		move.b	#$F,(Object_Space_5).w
		move.b	#2,(Object_Space_5+$1A).w
		jsr	ObjectsLoad
		jsr	BuildSprites
		move.w	#0,(Cheat_Btn_Press_Count).w
		move.w	#0,(C_Press_Counter).w
		move.w	(VDP_Reg_1_Value).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	Pal_FadeTo

loc_317C:
		move.b	#2,(V_Int_Routine).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	PalCycle_Title
		bsr.w	RunPLC_RAM
		move.w	(Object_Space_1+8).w,d0
		addq.w	#2,d0
		move.w	d0,(Object_Space_1+8).w ; move	Sonic to the right
		
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	#0,(a1)+
		move.w	(Object_Space_1+8).w,d2
		lsl.w	#1,d2
		neg.w	d2
		move.w	d2,(a1)
		
		cmpi.w	#$1C00,d0	; has Sonic object passed x-position $1C00?
		bcs.s	Title_ChkRegion	; if not, branch
		move.b	#$20,(Game_Mode).w ; go to Sega screen
		rts	
; ===========================================================================

Title_ChkRegion:
		lea	(LevelSelectCode).l,a0
		move.w	(Cheat_Btn_Press_Count).w,d0
		adda.w	d0,a0
		move.b	(Ctrl_1_Press).w,d0 ; get button press
		andi.b	#$F,d0		; read only up/down/left/right buttons
		cmp.b	(a0),d0		; does button press match the cheat code?
		bne.s	loc_3210	; if not, branch
		addq.w	#1,(Cheat_Btn_Press_Count).w ; next	button press
		tst.b	d0
		bne.s	Title_CountC
		lea	(Cheat_Flags).w,a0
		move.w	(C_Press_Counter).w,d1
		lsr.w	#1,d1
		andi.w	#3,d1
		beq.s	Title_PlayRing
		tst.b	(Console_Version).w
		bpl.s	Title_PlayRing
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)

Title_PlayRing:
		move.b	#1,(a0,d1.w)				; activate cheat
		move.l	#$1010101,(Cheat_Flags).w	; activate all cheats
		move.b	#SndID_GetContinue,d0		; play continue sound when code is entered
		bsr.w	PlaySound_Special
		bra.s	Title_CountC
; ===========================================================================

loc_3210:				; XREF: Title_EnterCheat
		tst.b	d0
		beq.s	Title_CountC
		cmpi.w	#9,(Cheat_Btn_Press_Count).w
		beq.s	Title_CountC
		move.w	#0,(Cheat_Btn_Press_Count).w

Title_CountC:
		move.b	(Ctrl_1_Press).w,d0
		andi.b	#$20,d0		; is C button pressed?
		beq.s	loc_3230	; if not, branch
		addq.w	#1,(C_Press_Counter).w ; increment C button counter

loc_3230:
		tst.w	(Universal_Timer).w
		beq.w	Demo
		andi.b	#$80,(Ctrl_1_Press).w ; check if Start is pressed
		beq.w	loc_317C	; if not, branch

Title_ChkLevSel:
		tst.b	(Level_Sel_Cheat_Flag).w	; check	if level select	code is	on
		beq.w	PlayLevel	; if not, play level
		btst	#6,(Ctrl_1_Held).w ; check if A is pressed
		beq.w	PlayLevel	; if not, play level
		moveq	#$0,d0				; clear d0
		move.b	d0,(Scroll_Flags_BG_Copy).w		; clear background strip 1 draw flags
		move.b	d0,(Scroll_Flags_BG2_Copy).w		; clear background strip 2 draw flags
		move.b	d0,(Scroll_Flags_Copy).w		; clear foreground strip draw flag
		moveq	#2,d0
		bsr.w	PalLoad2	; load level select Palette
		lea	(Horiz_Scroll_Buf).w,a1
		moveq	#0,d0
		move.w	#(Horiz_Scroll_Buf_End-Horiz_Scroll_Buf)>>2-1,d1

Title_ClrScroll:
		move.l	d0,(a1)+
		dbf	d1,Title_ClrScroll ; fill scroll data with 0

		move.l	d0,(V_Scroll_Value).w
		move	#$2700,sr
		lea	($C00000).l,a6
		move.l	#$60000003,($C00004).l
		move.w	#$3FF,d1

Title_ClrVram:
		move.l	d0,(a6)
		dbf	d1,Title_ClrVram ; fill	VRAM with 0

		;jmp	SoundTest

StartLvlSelect:
		move.b	#CmdID_Stop,d0
		bsr.w	PlaySound_Special
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		move	#$2700,sr
		bsr.w	ClearScreen
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)
		moveq	#$15,d0
		jsr	PalLoad1
		move.w	#MusID_Options,d0
		jsr	PlaySound
		bsr.w	LevSelTextLoad
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; Level	Select
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#4,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.w	LevSelControls
		bsr.w	RunPLC_RAM
		tst.l	(PLC_Buffer).w
		bne.s	LevelSelect
		andi.b	#$F0,(Ctrl_1_Press).w ; is	A, B, C, or Start pressed?
		beq.s	LevelSelect	; if not, branch
		move.w	(Level_Sel_Selection).w,d0
		cmpi.w	#$14,d0		; have you selected item $14 (sound test)?
		bne.s	LevSel_Level	; if not, go to	Level/SS subroutine
		jmp	SoundTest

LevSel_PlaySnd:
		bsr.w	PlaySound_Special
		bra.s	LevelSelect
; ===========================================================================

LevSel_Ending:				; XREF: LevelSelect
		move.b	#$18,(Game_Mode).w 		; set screen mode to	$18 (Ending)
		move.w	#$600,(Current_Zone_And_Act).w 	; set level to 0600	(Ending)
		rts	
; ===========================================================================

LevSel_Credits:				; XREF: LevelSelect
		move.b	#$1C,(Game_Mode).w ; set screen	mode to	$1C (Credits)
		moveq	#0,d0
		move.b	(Bad_Ending_Flag).w,d0
		lea	(MusicList_Credits).l,a1	; load Music Playlist for credits
		move.b	(a1,d0.w),d0	; get d0-th entry from the playlist
		bsr.w	PlaySound_Special ; play credits music
		move.w	#0,(Credits_Index).w
		rts	
; ===========================================================================

LevSel_Level:			; XREF: LevelSelect
		add.w	d0,d0
		move.w	LSelectPointers(pc,d0.w),d0 ; load level number
		bmi.w	LevelSelect
		andi.w	#$3FFF,d0
		move.w	d0,(Current_Zone_And_Act).w ; set level number

PlayLevel:				; XREF: ROM:00003246j ...
		move.b	#$C,(Game_Mode).w ; set	screen mode to $C (level)
		move.b	#4,(Life_Count).w ; set lives to	3
		moveq	#0,d0
		move.b	d0,(Boss_Flag).w	; clear Boss flag
		move.w	d0,(Ring_Count).w ; clear rings
		move.l	d0,(Timer).w ; clear time
		move.l	d0,(Score).w ; clear score
		move.b	d0,(Current_Special_Stage).w ; clear special stage number
		move.b	d0,(Emerald_Count).w ; clear emeralds
		move.l	d0,(Got_Emeralds_Array).w ; clear emeralds
		move.l	d0,(Got_Emeralds_Array+4).w ; clear emeralds
		move.b	d0,(Continue_Count).w ; clear continues
		move.b	#CmdID_FadeOut,d0
		bra.w	PlaySound_Special ; fade out music
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select - level pointers
; ---------------------------------------------------------------------------
LSelectPointers:
		dc.w $0000
		dc.w $8000
		dc.w $8000
		dc.w $0200
		dc.w $0201
		dc.w $8000
		dc.w $0400
		dc.w $0401
		dc.w $8000
		dc.w $0100
		dc.w $0101
		dc.w $8000
		dc.w $0300
		dc.w $0301
		dc.w $8000
		dc.w $8000
		dc.w $8000
		dc.w $0502
		dc.w $8000
		dc.w $8000
		dc.w $8000
		even
; ---------------------------------------------------------------------------
; Level	select codes
; ---------------------------------------------------------------------------
LevelSelectCode:
		dc.b 1, 2, 4, 8, 0, $FF
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

Demo:					; XREF: TitleScreen
		move.w	#$1E,(Universal_Timer).w

loc_33B6:				; XREF: loc_33E4
		move.b	#2,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.w	PalCycle_Load
		bsr.w	RunPLC_RAM
		move.w	(Object_Space_1+8).w,d0
		addq.w	#2,d0
		move.w	d0,(Object_Space_1+8).w
		cmpi.w	#$1C00,d0
		bcs.s	loc_33E4
		move.b	#0,(Game_Mode).w ; set screen mode to 00 (level)
		rts	
; ===========================================================================

loc_33E4:				; XREF: Demo
		andi.b	#$80,(Ctrl_1_Press).w ; is	Start button pressed?
		bne.w	Title_ChkLevSel	; if yes, branch
		tst.w	(Universal_Timer).w
		bne.w	loc_33B6
		move.b	#CmdID_FadeOut,d0
		bsr.w	PlaySound_Special ; fade out music
		move.w	(Demo_Number).w,d0 ; load	demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Demo_Levels(pc,d0.w),d0	; load level number for	demo
		move.w	d0,(Current_Zone_And_Act).w
		addq.w	#1,(Demo_Number).w ; add 1 to demo number
		cmpi.w	#3,(Demo_Number).w ; is demo number less than 4?
		bcs.s	loc_3422	; if yes, branch
		move.w	#0,(Demo_Number).w ; reset demo number to	0

loc_3422:
		move.w	#1,(Demo_Mode).w ; turn	demo mode on
		move.b	#8,(Game_Mode).w ; set screen mode to 08 (demo)
		move.b	#4,(Life_Count).w ; set lives to 3
		moveq	#0,d0
		move.b	d0,Boss_Flag.w	; clear Boss flag
		move.w	d0,(Ring_Count).w ; clear rings
		move.l	d0,(Timer).w ; clear time
		move.l	d0,(Score).w ; clear score
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Levels used in demos
; ---------------------------------------------------------------------------
Demo_Levels:
		dc.w $00
		dc.w $200
		dc.w $400
		even

; ---------------------------------------------------------------------------
; Subroutine to	change what you're selecting in the level select
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSelControls:				; XREF: LevelSelect
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#3,d1		; is up/down pressed and held?
		bne.s	LevSel_UpDown	; if yes, branch
		subq.w	#1,(Level_Sel_Move_Timer).w ; subtract 1 from time	to next	move
		bpl.s	LevSel_SndTest	; if time remains, branch

LevSel_UpDown:
		move.w	#$B,(Level_Sel_Move_Timer).w ; reset time delay
		move.b	(Ctrl_1_Held).w,d1
		andi.b	#3,d1		; is up/down pressed?
		beq.s	LevSel_SndTest	; if not, branch
		move.w	(Level_Sel_Selection).w,d0
		btst	#0,d1		; is up	pressed?
		beq.s	LevSel_Down	; if not, branch
		subq.w	#1,d0		; move up 1 selection
		bcc.s	LevSel_Down
		moveq	#$14,d0		; if selection moves below 0, jump to selection	$14

LevSel_Down:
		btst	#1,d1		; is down pressed?
		beq.s	LevSel_Refresh	; if not, branch
		addq.w	#1,d0		; move down 1 selection
		cmpi.w	#$15,d0
		bcs.s	LevSel_Refresh
		moveq	#0,d0		; if selection moves above $14,	jump to	selection 0

LevSel_Refresh:
		move.w	d0,(Level_Sel_Selection).w ; set new selection
		bsr.w	LevSelTextLoad	; refresh text
		rts	
; ===========================================================================

LevSel_SndTest:				; XREF: LevSelControls
		cmpi.w	#$14,(Level_Sel_Selection).w ; is	item $14 selected?
		bne.s	LevSel_NoMove	; if not, branch
		move.b	(Ctrl_1_Press).w,d1
		andi.b	#$C,d1		; is left/right	pressed?
		beq.s	LevSel_NoMove	; if not, branch
		move.w	(Level_Sel_Sound_ID).w,d0
		btst	#2,d1		; is left pressed?
		beq.s	LevSel_Right	; if not, branch
		subq.w	#1,d0		; subtract 1 from sound	test
		bcc.s	LevSel_Right
		moveq	#$4F,d0		; if sound test	moves below 0, set to $4F

LevSel_Right:
		btst	#3,d1		; is right pressed?
		beq.s	LevSel_Refresh2	; if not, branch
		addq.w	#1,d0		; add 1	to sound test
		cmpi.w	#$50,d0
		bcs.s	LevSel_Refresh2
		moveq	#0,d0		; if sound test	moves above $4F, set to	0

LevSel_Refresh2:
		move.w	d0,(Level_Sel_Sound_ID).w ; set sound test number
		bsr.w	LevSelTextLoad	; refresh text

LevSel_NoMove:
		rts	
; End of function LevSelControls

; ---------------------------------------------------------------------------
; Subroutine to load level select text
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevSelTextLoad:				; XREF: TitleScreen
		lea	(LevelMenuText).l,a1
		lea	($C00000).l,a6
		move.l	#$62100003,d4	; screen position (text)
		move.w	#$A650,d3	; VRAM setting
		moveq	#$14,d1		; number of lines of text

loc_34FE:				; XREF: LevSelTextLoad+26j
		move.l	d4,4(a6)
		bsr.w	LevSel_ChgLine
		addi.l	#$800000,d4
		dbf	d1,loc_34FE
		moveq	#0,d0
		move.w	(Level_Sel_Selection).w,d0
		move.w	d0,d1
		move.l	#$62100003,d4
		lsl.w	#7,d0
		swap	d0
		add.l	d0,d4
		lea	(LevelMenuText).l,a1
		lsl.w	#3,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		adda.w	d1,a1
		move.w	#$C650,d3
		move.l	d4,4(a6)

LevSel_ChgLine:				; XREF: LevSelTextLoad
		moveq	#$17,d2		; number of characters per line

loc_3588:
		moveq	#0,d0
		move.b	(a1)+,d0
		cmpi.b	#$20,d0
		bne.s	loc_3598
		move.w	#0,(a6)
		dbf	d2,loc_3588
		rts	
; ===========================================================================

loc_3598:				; XREF: LevSel_ChgLine
		add.w	d3,d0
		move.w	d0,(a6)
		dbf	d2,loc_3588
		rts	
; End of function LevSel_ChgLine

; ===========================================================================
; ---------------------------------------------------------------------------
; Level	select menu text
; ---------------------------------------------------------------------------
LevelMenuText:
		dc.b "ITS A TUTORIAL   STAGE 1"
		dc.b "               NOT USED "
		dc.b ";;;;;;;;;;;;;;;;;;;;;;;;"
		dc.b "D@IEN DOBR?      STAGE 1"
		dc.b "                STAGE 2 "
		dc.b ";;;;;;;;;;;;;;;;;;;;;;;;"
		dc.b "M? TEETH FEEL    STAGE 1"
		dc.b "FUNN?           STAGE 2 "
		dc.b ";;;;;;;;;;;;;;;;;;;;;;;;"
		dc.b "OH SHIT SON ?OU  STAGE 1"
		dc.b "FUCKED UP NOW   STAGE 2 "
		dc.b ";;;;;;;;;;;;;;;;;;;;;;;;"
		dc.b "I THINK I HAVE   STAGE 1"
		dc.b "APPENDICITIS    STAGE 2 "
		dc.b ";;;;;;;;;;;;;;;;;;;;;;;;"
		dc.b "  O HAIL THE ALMIGHT?   "
		dc.b "     TRENT ARTMEIER     "
		dc.b "  OUR LORD AND SAVIOR   "
		dc.b ";;;;;;;;;;;;;;;;;;;;;;;;"
		dc.b "NOTHING HERE            "
		dc.b "SOUND TEST              "
		even
; ---------------------------------------------------------------------------
; Music	playlist
; ---------------------------------------------------------------------------
MusicList_Levels:
		dc.b MusID_Tutorial, MusID_Tutorial, MusID_Tutorial, MusID_Tutorial
		dc.b MusID_FuckedUp, MusID_FuckedUp, MusID_FuckedUp, MusID_Dendy
		dc.b MusID_DzienDobry, MusID_DzienDobry, MusID_DzienDobry, MusID_DzienDobry2
		dc.b MusID_Appendicitis, MusID_Appendicitis, MusID_Unused, MusID_Unused
		dc.b MusID_TeethFunny, MusID_TeethFunny, MusID_TeethFunny, MusID_TeethFunny
		dc.b MusID_Dendy, MusID_Dendy, MusID_FinalBoss, MusID_Dendy
		even
MusicList_Credits:
		dc.b MusID_Credits, MusID_Credits
		even
MusicList_Endings:
		dc.b MusID_Options, MusID_Options
		even
MusicList_Bosses:
		dc.b MusID_Boss, MusID_Boss, MusID_Boss, MusID_Boss
		dc.b MusID_Boss, MusID_Boss, MusID_Boss, MusID_Boss
		dc.b MusID_Dendy, MusID_Boss, MusID_Boss, MusID_Boss
		dc.b MusID_Boss, MusID_Boss, MusID_Boss, MusID_Boss
		dc.b MusID_Boss, MusID_Boss, MusID_Boss, MusID_Boss
		dc.b MusID_Boss, MusID_Boss, MusID_Boss, MusID_Boss
		even
; ===========================================================================

TitleCard_ArtArray:
		dc.l Nem_TitleCard_Tutorial
		dc.l Nem_TitleCard_FuckedUp
		dc.l Nem_TitleCard_Dzien
		dc.l Nem_TitleCard_Appendicitis
		dc.l Nem_TitleCard_Teeth
		dc.l Nem_TitleCard_Final

; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

Level:					; XREF: GameModeArray
		bset	#7,(Game_Mode).w ; add $80 to screen mode (for pre level sequence)
		tst.w	(Demo_Mode).w
		bmi.s	loc_37B6
		move.b	#CmdID_FadeOut,d0
		bsr.w	PlaySound_Special ; fade out music

loc_37B6:
		bsr.w	Pal_FadeFrom
		bsr.w	ClearPLC
		tst.w	(Demo_Mode).w
		bmi.w	Level_ClrRam
		move	#$2700,sr
		
		moveq	#0,d0
		bsr.w	RunPLC_ROM
		
		move.l	#$70000002,($C00004).l
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		
		move.l	#$75A00002,($C00004).l
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(TitleCard_ArtArray).l,a1
		movea.l	(a1,d0.w),a0
		bsr.w	NemDec
		move	#$2300,sr
		
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#4,d0
		lea	(MainLoadBlocks).l,a2
		lea	(a2,d0.w),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_37FC
		bsr.w	LoadPLC		; load level patterns

loc_37FC:
		moveq	#1,d0
		bsr.w	LoadPLC		; load standard	patterns

Level_ClrRam:
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1

Level_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrObjRam ; clear object RAM

		lea	(Misc_Variables).w,a1
		moveq	#0,d0
		move.w	#(Misc_Variables_End-Misc_Variables)>>2-1,d1

Level_ClrVars:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars ; clear misc variables

		lea	(Camera_And_Misc_RAM).w,a1
		moveq	#0,d0
		move.w	#(Camera_And_Misc_RAM_End-Camera_And_Misc_RAM)>>2-1,d1

Level_ClrVars2:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars2 ; clear misc variables

		lea	(Osc_And_Misc_RAM).w,a1
		moveq	#0,d0
		move.w	#(Osc_And_Misc_RAM_End-Osc_And_Misc_RAM)>>-1,d1

Level_ClrVars3:
		move.l	d0,(a1)+
		dbf	d1,Level_ClrVars3 ; clear object variables

		move	#$2700,sr
		bsr.w	ClearScreen
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$857C,(a6)
		move.w	#$9001,(a6)
		move.w	#$8004,(a6)
		move.w	#$8720,(a6)
		move.w	#$8ADF,(H_Int_Counter).w
		move.w	(H_Int_Counter).w,(a6)
		
		move.w	#0,(Tutorial_Boss_Flags).w
		move.b	#0,(Boss_Flag).w
		
		clr.w	(DMA_Queue).w
		move.l	#DMA_Queue,(DMA_Queue_Slot).w
		
		move.b	#0,(No_Music_Ctrl).w
		move.b	#$1E,(Object_Space_1+$28).w

		cmpi.b	#1,(Current_Zone).w ; is level LZ?
		bne.s	Level_LoadPal	; if not, branch
		move.w	#$8014,(a6)
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		lea	(WaterHeight).l,a1 ; load water	height array
		move.w	(a1,d0.w),d0
		move.w	d0,(Water_Height).w ; set water heights
		move.w	d0,(Water_Height_No_Sway).w
		move.w	d0,(Water_Height_Target).w
		clr.b	(Water_Routine).w	; clear	water routine counter
		clr.b	(Water_Fullscreen_Flag).w	; clear	water movement
		move.b	#1,(Water_On).w ; enable water

Level_LoadPal:
		move	#$2300,sr
		moveq	#3,d0
		bsr.w	PalLoad2	; load Sonic's Palette line
		cmpi.b	#1,(Current_Zone).w ; is level LZ?
		bne.s	Level_GetBgm	; if not, branch
		moveq	#$F,d0		; Palette number $F (LZ)
		bsr.w	PalLoad3_Water	; load underwater Palette (see d0)
		tst.b	(Last_Checkpoint_Hit).w
		beq.s	Level_GetBgm
		move.b	(Saved_Water_Fullscreen_Flag).w,(Water_Fullscreen_Flag).w

Level_GetBgm:
		tst.w	(Demo_Mode).w
		bmi.w	loc_3946
		
		moveq	#0,d0
		move.w	(Current_Zone_And_Act).w,d1
		ror.b	#2,d1
		lsr.w	#6,d1
		lea	(MusicList_Levels).l,a1
		move.b	(a1,d1.w),d0		; get d0-th entry from the playlist
		move.b	d0,(Level_Music_ID).w	; put music number in RAM for later use
		jsr	CtrlLevelMusic
		
		move.b	#$34,(Object_Space_3).w 	; load title	card object

Level_TtlCard:
		move.b	#$C,(V_Int_Routine).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		bsr.w	RunPLC_RAM
		move.w	(Object_Space_5+8).w,d0
		cmp.w	(Object_Space_5+$30).w,d0 ; has title card sequence finished?
		bne.s	Level_TtlCard	; if not, branch
		tst.l	(PLC_Buffer).w	; are there any	items in the pattern load cue?
		bne.s	Level_TtlCard	; if yes, branch
		jsr	Hud_Base

loc_3946:
		moveq	#3,d0
		bsr.w	PalLoad1	; load Sonic's Palette line
		bsr.w	LevelSizeLoad
		bsr.w	DeformBgLayer
		bset	#2,(Scroll_Flags).w
		bsr.w	MainLoadBlockLoad ; load block mappings	and Palettes
		bsr.w	LoadTilesFromStart
		jsr	FloorLog_Unk
		bsr.w	ColIndexLoad
		bsr.w	LZWaterEffects
		move.b	#1,(Object_RAM).w ; load	Sonic object
		tst.w	(Demo_Mode).w
		bmi.s	Level_ChkDebug
		move.b	#$21,(Object_Space_2).w ; load HUD object

Level_ChkDebug:
		tst.b	(Debug_Cheat_Flag).w	; has debug cheat been entered?
		beq.s	Level_ChkWater	; if not, branch
		btst	#6,(Ctrl_1_Held).w ; is A	button pressed?
		beq.s	Level_ChkWater	; if not, branch
		move.b	#1,(Debug_Cheat_On).w ; enable debug	mode

Level_ChkWater:
		move.w	#0,(Sonic_Ctrl_Held).w
		move.w	#0,(Ctrl_1_Held).w
		cmpi.b	#1,(Current_Zone).w ; is level LZ?
		bne.s	Level_LoadObj	; if not, branch
		move.b	#$1B,(Object_Space_31).w ; load water	surface	object
		move.w	#$60,(Object_Space_31+8).w
		move.b	#$1B,(Object_Space_32).w
		move.w	#$120,(Object_Space_32+8).w

Level_LoadObj:
		jsr	ObjectsManager
		jsr	ObjectsLoad
		jsr	BuildSprites
		moveq	#0,d0
		tst.b	(Last_Checkpoint_Hit).w	; are you starting from	a lamppost?
		bne.s	loc_39E8	; if yes, branch
		move.b	d0,Boss_Flag	; clear Boss flag
		move.w	d0,(Ring_Count).w ; clear rings
		move.l	d0,(Timer).w ; clear time
		move.b	d0,(Extra_Life_Flags).w ; clear lives counter

loc_39E8:
		move.b	d0,(Time_Over_Flag).w
		move.b	d0,(Shield_Flag).w ; clear shield
		move.b	d0,(Invincibility_Flag).w ; clear invincibility
		move.b	d0,(Speed_Shoes_Flag).w ; clear speed shoes
		move.w	d0,(Debug_Placement_Mode).w
		move.w	d0,(Level_Inactive_Flag).w
		move.w	d0,(Level_Timer).w
		bsr.w	OscillateNumInit
		move.b	#1,(Update_HUD_Score).w ; update score	counter
		move.b	#1,(Update_HUD_Rings).w ; update rings	counter
		move.b	#1,(Update_HUD_Timer).w ; update time counter
		move.w	#0,(Demo_Button_Index).w
		lea	(Demo_Index).l,a1 ; load demo data
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	(a1,d0.w),a1
		move.b	1(a1),(Demo_Press_Counter).w ; load key press duration
		subq.b	#1,(Demo_Press_Counter).w ; subtract 1 from duration
		move.w	#1800,(Universal_Timer).w
		move.w	#3,d1

Level_DelayLoop:
		move.b	#8,(V_Int_Routine).w
		bsr.w	DelayProgram
		dbf	d1,Level_DelayLoop

		move.w	#$202F,(Palette_Fade_Range).w
		bsr.w	Pal_FadeTo2
		tst.w	(Demo_Mode).w
		bmi.s	Level_ClrCardArt
		addq.b	#2,(Object_Space_3+$24).w ; make title card move
		addq.b	#4,(Object_Space_4+$24).w
		addq.b	#4,(Object_Space_5+$24).w
		addq.b	#4,(Object_Space_6+$24).w
		bra.s	Level_StartGame
; ===========================================================================

Level_ClrCardArt:
		moveq	#2,d0
		jsr	(LoadPLC).l	; load explosion patterns
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		addi.w	#$15,d0
		jsr	(LoadPLC).l	; load animal patterns (level no. + $15)

Level_StartGame:
		bclr	#7,(Game_Mode).w ; subtract 80 from screen mode

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame
		move.b	#8,(V_Int_Routine).w
		bsr.w	DelayProgram
		addq.w	#1,(Level_Timer).w ; add 1 to level timer
		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterEffects
		jsr	ObjectsLoad
		tst.w	(Debug_Placement_Mode).w
		bne.s	loc_3B10
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	loc_3B14

loc_3B10:
		bsr.w	DeformBgLayer

loc_3B14:
		jsr	BuildSprites
		jsr	ObjectsManager
		bsr.w	PalCycle_Load
		bsr.w	RunPLC_RAM
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		bsr.w	SignpostArtLoad
		jsr	CtrlLevelMusic
		cmpi.b	#8,(Game_Mode).w
		beq.s	Level_ChkDemo	; if screen mode is 08 (demo), branch
		tst.w	(Level_Inactive_Flag).w	; is the level set to restart?
		bne.w	Level		; if yes, branch
		cmpi.b	#$C,(Game_Mode).w
		beq.w	Level_MainLoop	; if screen mode is $C	(level), branch
		rts	
; ===========================================================================

Level_ChkDemo:				; XREF: Level_MainLoop
		tst.w	(Level_Inactive_Flag).w	; is level set to restart?
		bne.s	Level_EndDemo	; if yes, branch
		tst.w	(Universal_Timer).w	; is there time	left on	the demo?
		beq.s	Level_EndDemo	; if not, branch
		cmpi.b	#8,(Game_Mode).w
		beq.w	Level_MainLoop	; if screen mode is 08 (demo), branch
		move.b	#$20,(Game_Mode).w ; go to Sega screen
		rts	
; ===========================================================================

Level_EndDemo:				; XREF: Level_ChkDemo
		cmpi.b	#8,(Game_Mode).w ; is screen mode 08 (demo)?
		bne.s	loc_3B88	; if not, branch
		move.b	#$20,(Game_Mode).w ; go to Sega screen
		tst.w	(Demo_Mode).w	; is demo mode on?
		bpl.s	loc_3B88	; if yes, branch
		move.b	#$1C,(Game_Mode).w ; go	to credits

loc_3B88:
		move.w	#$3C,(Universal_Timer).w
		move.w	#$3F,(Palette_Fade_Range).w
		clr.w	(Demo_Pal_Fade_Delay).w

loc_3B98:
		move.b	#8,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.w	MoveSonicInDemo
		jsr	ObjectsLoad
		jsr	BuildSprites
		jsr	ObjectsManager
		subq.w	#1,(Demo_Pal_Fade_Delay).w
		bpl.s	loc_3BC8
		move.w	#2,(Demo_Pal_Fade_Delay).w
		bsr.w	Pal_FadeOut

loc_3BC8:
		tst.w	(Universal_Timer).w
		bne.s	loc_3B98
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	do special water effects in Labyrinth Zone
; ---------------------------------------------------------------------------

LZWaterEffects:				; XREF: Level
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		bne.s	locret_3C28	; if not, branch
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	LZMoveWater
	;	bsr.w	LZWindTunnels
	;	bsr.w	LZWaterSlides
		bsr.w	LZDynamicWater

LZMoveWater:
		clr.b	(Water_Fullscreen_Flag).w
		moveq	#0,d0
		move.b	(Oscillation_Data).w,d0
		lsr.w	#1,d0
		add.w	(Water_Height_No_Sway).w,d0
		move.w	d0,(Water_Height).w
		move.w	(Water_Height).w,d0
		sub.w	(Camera_Y_Pos).w,d0
		bcc.s	loc_3C1A
		tst.w	d0
		bpl.s	loc_3C1A
		move.b	#-$21,(H_Int_Counter+1).w
		move.b	#1,(Water_Fullscreen_Flag).w

loc_3C1A:
		cmpi.w	#$DF,d0
		bcs.s	loc_3C24
		move.w	#$DF,d0

loc_3C24:
		move.b	d0,(H_Int_Counter+1).w

locret_3C28:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Labyrinth default water heights
; ---------------------------------------------------------------------------
WaterHeight:
		dc.w $0B8
		dc.w $328
		dc.w $900
		dc.w $228
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Labyrinth dynamic water routines
; ---------------------------------------------------------------------------

LZDynamicWater:				; XREF: LZWaterEffects
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	DynWater_Index(pc,d0.w),d0
		jsr	DynWater_Index(pc,d0.w)
		moveq	#0,d1
		move.b	(Water_On).w,d1
		move.w	(Water_Height_Target).w,d0
		sub.w	(Water_Height_No_Sway).w,d0
		beq.s	locret_3C5A
		bcc.s	loc_3C56
		neg.w	d1

loc_3C56:
		add.w	d1,(Water_Height_No_Sway).w

locret_3C5A:
		rts	
; ===========================================================================
DynWater_Index:	dc.w DynWater_LZ1-DynWater_Index
		dc.w DynWater_LZ2-DynWater_Index
		dc.w DynWater_LZ1-DynWater_Index
		dc.w DynWater_LZ1-DynWater_Index
; ===========================================================================

DynWater_LZ1:				; XREF: DynWater_Index
		move.w	(Camera_X_Pos).w,d0
		move.b	(Water_Routine).w,d2
		bne.s	loc_3CD0
		move.w	#$B8,d1
		cmpi.w	#$600,d0
		bcs.s	loc_3CB4
		move.w	#$108,d1
		cmpi.w	#$200,(Object_Space_1+$C).w
		bcs.s	loc_3CBA
		cmpi.w	#$C00,d0
		bcs.s	loc_3CB4
		move.w	#$318,d1
		cmpi.w	#$1080,d0
		bcs.s	loc_3CB4
		move.b	#-$80,(Switch_Statuses+5).w
		move.w	#$5C8,d1
		cmpi.w	#$1380,d0
		bcs.s	loc_3CB4
		move.w	#$3A8,d1
		cmp.w	(Water_Height_No_Sway).w,d1
		bne.s	loc_3CB4
		move.b	#1,(Water_Routine).w

loc_3CB4:
		move.w	d1,(Water_Height_Target).w
		rts	
; ===========================================================================

loc_3CBA:				; XREF: DynWater_LZ1
		cmpi.w	#$C80,d0
		bcs.s	loc_3CB4
		move.w	#$E8,d1
		cmpi.w	#$1500,d0
		bcs.s	loc_3CB4
		move.w	#$108,d1
		bra.s	loc_3CB4
; ===========================================================================

loc_3CD0:				; XREF: DynWater_LZ1
		subq.b	#1,d2
		bne.s	locret_3CF4
		cmpi.w	#$2E0,(Object_Space_1+$C).w
		bcc.s	locret_3CF4
		move.w	#$3A8,d1
		cmpi.w	#$1300,d0
		bcs.s	loc_3CF0
		move.w	#$108,d1
		move.b	#2,(Water_Routine).w

loc_3CF0:
		move.w	d1,(Water_Height_Target).w

locret_3CF4:
		rts	
; ===========================================================================

DynWater_LZ2:				; XREF: DynWater_Index
		move.w	(Camera_X_Pos).w,d0
		move.w	#$328,d1
		cmpi.w	#$500,d0
		bcs.s	loc_3D12
		move.w	#$3C8,d1
		cmpi.w	#$B00,d0
		bcs.s	loc_3D12
		move.w	#$428,d1

loc_3D12:
		move.w	d1,(Water_Height_Target).w
		rts	

; ---------------------------------------------------------------------------
; Labyrinth Zone "wind tunnels"	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LZWindTunnels:				; XREF: LZWaterEffects
		tst.w	(Debug_Placement_Mode).w	; is debug mode	being used?
		bne.w	locret_3F0A	; if yes, branch
		lea	(LZWind_Data).l,a2
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		lsl.w	#3,d0
		adda.w	d0,a2
		moveq	#0,d1
		tst.b	(Current_Act).w
		bne.s	loc_3E56
		moveq	#1,d1
		subq.w	#8,a2

loc_3E56:
		lea	(Object_RAM).w,a1

LZWind_Loop:
		move.w	8(a1),d0
		cmp.w	(a2),d0
		bcs.w	loc_3EF4
		cmp.w	4(a2),d0
		bcc.w	loc_3EF4
		move.w	$C(a1),d2
		cmp.w	2(a2),d2
		bcs.s	loc_3EF4
		cmp.w	6(a2),d2
		bcc.s	loc_3EF4
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$3F,d0
		bne.s	loc_3E90
		move.w	#SndID_Waterfall,d0
		jsr	(PlaySound_Special).l ;	play rushing water sound

loc_3E90:
		tst.b	(Wind_Tunnel_Flag).w
		bne.w	locret_3F0A
		cmpi.b	#4,$24(a1)
		bcc.s	loc_3F06
		move.b	#1,(Wind_Tunnel_Mode).w
		subi.w	#$80,d0
		cmp.w	(a2),d0
		bcc.s	LZWind_Move
		moveq	#2,d0
		cmpi.b	#1,(Current_Act).w
		bne.s	loc_3EBA
		neg.w	d0

loc_3EBA:
		add.w	d0,$C(a1)

LZWind_Move:
		addq.w	#4,8(a1)
		move.w	#$400,$10(a1)	; move Sonic horizontally
		move.w	#0,$12(a1)
		move.b	#$F,$1C(a1)	; use floating animation
		bset	#1,$22(a1)
		btst	#0,(Sonic_Ctrl_Held).w ; is up pressed?
		beq.s	LZWind_MoveDown	; if not, branch
		subq.w	#1,$C(a1)	; move Sonic up

LZWind_MoveDown:
		btst	#1,(Sonic_Ctrl_Held).w ; is down being pressed?
		beq.s	locret_3EF2	; if not, branch
		addq.w	#1,$C(a1)	; move Sonic down

locret_3EF2:
		rts	
; ===========================================================================

loc_3EF4:				; XREF: LZWindTunnels
		addq.w	#8,a2
		dbf	d1,LZWind_Loop
		tst.b	(Wind_Tunnel_Mode).w
		beq.s	locret_3F0A
		move.b	#0,$1C(a1)

loc_3F06:
		clr.b	(Wind_Tunnel_Mode).w

locret_3F0A:
		rts	
; End of function LZWindTunnels

; ===========================================================================
		dc.w $A80, $300, $C10, $380
LZWind_Data:	dc.w $F80, $100, $1410,	$180, $460, $400, $710,	$480, $A20
		dc.w $600, $1610, $6E0,	$C80, $600, $13D0, $680
					; XREF: LZWindTunnels
		even

; ---------------------------------------------------------------------------
; Labyrinth Zone water slide subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LZWaterSlides:				; XREF: LZWaterEffects
		lea	(Object_RAM).w,a1
		btst	#1,$22(a1)
		bne.s	loc_3F6A
		move.w	$C(a1),d0				; MJ: Load Y position
		move.w	$8(a1),d1				; MJ: Load X position
		and.w	#$780,d0				; MJ: keep Y position within 800 pixels (in multiples of 80)
		lsl.w	#$1,d0					; MJ: multiply by 2 (Because every 80 bytes switch from FG to BG..)
		lsr.w	#$7,d1					; MJ: divide X position by 80 (00 = 0, 80 = 1, etc)
		and.b	#$7F,d1					; MJ: keep within 4000 pixels (4000 / 80 = 80)
		add.w	d1,d0					; MJ: add together
		movea.l	(Level_Layout_FG).w,a2			; MJ: Load address of layout
		move.b	(a2,d0.w),d0				; MJ: collect correct chunk ID based on the position of Sonic
		lea	Slide_Chunks(pc),a2
		moveq	#$0,d1					; MJ: clear d2
		bra	LZLoadChunk				; MJ: continue

LZFindChunk:
		cmp.b	d2,d0					; MJ: does the chunk match?
		beq	LZSlide_Move				; MJ: if so, branch
		addq.w	#$1,d1					; MJ: increase counter

LZLoadChunk:
		move.b	(a2)+,d2				; MJ: load chunk ID
		bne	LZFindChunk				; MJ: if it's not null, branch

loc_3F6A:
		tst.b	(Jump_Only_Flag).w
		beq.s	locret_3F7A
		move.w	#5,$3E(a1)
		clr.b	(Jump_Only_Flag).w

locret_3F7A:
		rts	
; ===========================================================================

LZSlide_Move:				; XREF: LZWaterSlides
		cmpi.w	#3,d1
		bcc.s	loc_3F84
		nop	

loc_3F84:
		bclr	#0,$22(a1)
		move.b	Slide_Speeds(pc,d1.w),d0
		move.b	d0,$14(a1)
		bpl.s	loc_3F9A
		bset	#0,$22(a1)

loc_3F9A:
		clr.b	$15(a1)
		move.b	#$1B,$1C(a1)	; use Sonic's "sliding" animation
		move.b	#1,(Jump_Only_Flag).w ; lock	controls (except jumping)
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$1F,d0
		bne.s	locret_3FBE
		move.w	#SndID_Waterfall,d0
		jsr	(PlaySound_Special).l ;	play water sound

locret_3FBE:
		rts	
; End of function LZWaterSlides

; ===========================================================================
; ---------------------------------------------------------------------------
Slide_Chunks:	dc.b	$5,$6,$9,$A				; MJ: Chunks to read (128x128 ID's)
		dc.b	$FA,$FB,$FC,$FD
		dc.b	$B,$C,$D,$E
		dc.b	$15,$16,$F8,$F9
		dc.b	$19,$1A,$1B,$1C
		dc.b	$17
		dc.b	$0					; MJ: End marker
		even
; ---------------------------------------------------------------------------
Slide_Speeds:	dc.b	$A,$A,$A,$A				; MJ: Values for speed, format XX00 = Speed in $14(a-)
		dc.b	$F6,$F6,$F6,$F6
		dc.b	$B,$B,$B,$B
		dc.b	$F5,$F5,$F5,$F5
		dc.b	$F4,$F4,$F4,$F4
		dc.b	$F5
		even
; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	move Sonic in demo mode
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MoveSonicInDemo:			; XREF: Level_MainLoop; et al
		tst.w	(Demo_Mode).w	; is demo mode on?
		bne.s	MoveDemo_On	; if yes, branch
		rts	
; ===========================================================================

; This is an unused subroutine for recording a demo

MoveDemo_Record:
		lea	($80000).l,a1
		move.w	(Demo_Button_Index).w,d0
		adda.w	d0,a1
		move.b	(Ctrl_1_Held).w,d0
		cmp.b	(a1),d0
		bne.s	loc_3FFA
		addq.b	#1,1(a1)
		cmpi.b	#$FF,1(a1)
		beq.s	loc_3FFA
		rts	
; ===========================================================================

loc_3FFA:				; XREF: MoveDemo_Record
		move.b	d0,2(a1)
		move.b	#0,3(a1)
		addq.w	#2,(Demo_Button_Index).w
		andi.w	#$3FF,(Demo_Button_Index).w
		rts	
; ===========================================================================

MoveDemo_On:				; XREF: MoveSonicInDemo
		tst.b	(Ctrl_1_Held).w
		bpl.s	loc_4022
		tst.w	(Demo_Mode).w
		bmi.s	loc_4022
		move.b	#4,(Game_Mode).w

loc_4022:
		lea	(Demo_Index).l,a1
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	(a1,d0.w),a1
		move.w	(Demo_Button_Index).w,d0
		adda.w	d0,a1
		move.b	(a1),d0
		lea	(Ctrl_1_Held).w,a0
		move.b	d0,d1
		move.b	-2(a0),d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,(Demo_Press_Counter).w
		bcc.s	locret_407E
		move.b	3(a1),(Demo_Press_Counter).w
		addq.w	#2,(Demo_Button_Index).w

locret_407E:
		rts	
; End of function MoveSonicInDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo sequence	pointers
; ---------------------------------------------------------------------------
Demo_Index:
	dc.l Demo_GHZ
	dc.l Demo_GHZ
	dc.l Demo_MZ
	dc.l Demo_MZ
	dc.l Demo_SYZ
	dc.l Demo_SYZ
; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColIndexLoad:				; XREF: Level
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#$3,d0					; MJ: multiply by 8 not 4
		move.l	ColPointers(pc,d0.w),(First_Collision_Addr).w	; MJ: get first collision set
		add.w	#$4,d0					; MJ: increase to next location
		move.l	ColPointers(pc,d0.w),(Second_Collision_Addr).w	; MJ: get second collision set
		rts	
; End of function ColIndexLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision index pointers
; ---------------------------------------------------------------------------
ColPointers:
		dc.l Col_GHZ_1
		dc.l Col_GHZ_2
		dc.l Col_LZ_1
		dc.l Col_LZ_2
		dc.l Col_MZ_1
		dc.l Col_MZ_2
		dc.l Col_SLZ_1
		dc.l Col_SLZ_2
		dc.l Col_SYZ_1
		dc.l Col_SYZ_2
		dc.l Col_SBZ_1
		dc.l Col_SBZ_2

; ---------------------------------------------------------------------------
; Oscillating number subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


OscillateNumInit:			; XREF: Level
		lea	(Oscillation_Control).w,a1
		lea	(Osc_Data).l,a2
		moveq	#$20,d1

Osc_Loop:
		move.w	(a2)+,(a1)+
		dbf	d1,Osc_Loop
		rts	
; End of function OscillateNumInit

; ===========================================================================
Osc_Data:	dc.w $7C, $80		; baseline values
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$80
		dc.w 0,	$50F0
		dc.w $11E, $2080
		dc.w $B4, $3080
		dc.w $10E, $5080
		dc.w $1C2, $7080
		dc.w $276, $80
		dc.w 0,	$80
		dc.w 0
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


OscillateNumDo:				; XREF: Level
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	locret_41C4
		lea	(Oscillation_Control).w,a1
		lea	(Osc_Data2).l,a2
		move.w	(a1)+,d3
		moveq	#$F,d1

loc_4184:
		move.w	(a2)+,d2
		move.w	(a2)+,d4
		btst	d1,d3
		bne.s	loc_41A4
		move.w	2(a1),d0
		add.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,0(a1)
		cmp.b	0(a1),d4
		bhi.s	loc_41BA
		bset	d1,d3
		bra.s	loc_41BA
; ===========================================================================

loc_41A4:				; XREF: OscillateNumDo
		move.w	2(a1),d0
		sub.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,0(a1)
		cmp.b	0(a1),d4
		bls.s	loc_41BA
		bclr	d1,d3

loc_41BA:
		addq.w	#4,a1
		dbf	d1,loc_4184
		move.w	d3,(Oscillation_Control).w

locret_41C4:
		rts	
; End of function OscillateNumDo

; ===========================================================================
Osc_Data2:	dc.w 2,	$10		; XREF: OscillateNumDo
		dc.w 2,	$18
		dc.w 2,	$20
		dc.w 2,	$30
		dc.w 4,	$20
		dc.w 8,	8
		dc.w 8,	$40
		dc.w 4,	$40
		dc.w 2,	$50
		dc.w 2,	$50
		dc.w 2,	$20
		dc.w 3,	$30
		dc.w 5,	$50
		dc.w 7,	$70
		dc.w 2,	$10
		dc.w 2,	$10
		even

; ---------------------------------------------------------------------------
; Subroutine to	change object animation	variables (rings, giant	rings)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChangeRingFrame:			; XREF: Level
		subq.b	#1,(Logspike_Anim_Counter).w
		bpl.s	loc_421C
		move.b	#$B,(Logspike_Anim_Counter).w
		subq.b	#1,(Logspike_Anim_Frame).w
		andi.b	#7,(Logspike_Anim_Frame).w

loc_421C:
		subq.b	#1,(Rings_Anim_Counter).w
		bpl.s	loc_4232
		move.b	#7,(Rings_Anim_Counter).w
		addq.b	#1,(Rings_Anim_Frame).w
		andi.b	#3,(Rings_Anim_Frame).w

loc_4232:
		subq.b	#1,(Unknown_Anim_Counter).w
		bpl.s	loc_4250
		move.b	#7,(Unknown_Anim_Counter).w
		addq.b	#1,(Unknown_Anim_Frame).w
		cmpi.b	#6,(Unknown_Anim_Frame).w
		bcs.s	loc_4250
		move.b	#0,(Unknown_Anim_Frame).w

loc_4250:
		tst.b	(Ring_Spill_Anim_Counter).w
		beq.s	locret_4272
		moveq	#0,d0
		move.b	(Ring_Spill_Anim_Counter).w,d0
		add.w	(Ring_Spill_Anim_Accum).w,d0
		move.w	d0,(Ring_Spill_Anim_Accum).w
		rol.w	#7,d0
		andi.w	#3,d0
		move.b	d0,(Ring_Spill_Anim_Frame).w
		subq.b	#1,(Ring_Spill_Anim_Counter).w

locret_4272:
		rts	
; End of function ChangeRingFrame

; ---------------------------------------------------------------------------
; End-of-act signpost pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SignpostArtLoad:			; XREF: Level
		tst.w	(Debug_Placement_Mode).w	; is debug mode	being used?
		bne.w	Signpost_Exit	; if yes, branch
		cmpi.b	#2,(Current_Act).w ; is act number 02 (act 3)?
		beq.s	Signpost_Exit	; if yes, branch
		move.w	(Camera_X_Pos).w,d0
		move.w	(Camera_Max_X_Pos).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0		; has Sonic reached the	edge of	the level?
		blt.s	Signpost_Exit	; if not, branch
		tst.b	(Update_HUD_Timer).w
		beq.s	Signpost_Exit
		cmp.w	(Camera_Min_X_Pos).w,d1
		beq.s	Signpost_Exit
		move.w	d1,(Camera_Min_X_Pos).w ; move	left boundary to current screen	position
		moveq	#$12,d0
		bra.w	LoadPLC2	; load signpost	patterns
; ===========================================================================

Signpost_Exit:
		rts	
; End of function SignpostArtLoad

; ===========================================================================
Demo_GHZ:	incbin	data/demo/i_ghz.bin
Demo_MZ:	incbin	data/demo/i_mz.bin
Demo_SYZ:	incbin	data/demo/i_syz.bin
; ===========================================================================

; ---------------------------------------------------------------------------
; Special Stage
; ---------------------------------------------------------------------------

SpecialStage:				; XREF: GameModeArray
		move.b	#$C,(Game_Mode).w
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

ContinueScreen:				; XREF: GameModeArray
		bsr.w	Pal_FadeFrom
		move	#$2700,sr
		move.w	(VDP_Reg_1_Value).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8700,(a6)
		bsr.w	ClearScreen
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1

Cont_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cont_ClrObjRam ; clear object RAM

		move.l	#$70000002,($C00004).l
		lea	(Nem_TitleCard).l,a0 ; load title card patterns
		bsr.w	NemDec
		move.l	#$60000002,($C00004).l
		lea	(Nem_ContSonic).l,a0 ; load Sonic patterns
		bsr.w	NemDec
		move.l	#$6A200002,($C00004).l
		lea	(Nem_MiniSonic).l,a0 ; load continue screen patterns
		bsr.w	NemDec
		moveq	#10,d1
		jsr	ContScrCounter	; run countdown	(start from 10)
		moveq	#$12,d0
		bsr.w	PalLoad1	; load continue	screen Palette
		move.b	#MusID_Continue,d0
		bsr.w	PlaySound	; play continue	music
		move.w	#659,(Universal_Timer).w ; set time delay to 11 seconds
		clr.l	(Camera_X_Pos).w
		move.l	#$1000000,(Camera_Y_Pos).w
		move.b	#$81,(Object_RAM).w ; load Sonic	object
		move.b	#$80,(Object_Space_2).w ; load continue screen objects
		move.b	#$80,(Object_Space_3).w
		move.b	#3,(Object_Space_3+$18).w
		move.b	#4,(Object_Space_3+$1A).w
		move.b	#$80,(Object_Space_4).w
		move.b	#4,(Object_Space_4+$24).w
		jsr	ObjectsLoad
		jsr	BuildSprites
		move.w	(VDP_Reg_1_Value).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#$16,(V_Int_Routine).w
		bsr.w	DelayProgram
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	loc_4DF2
		move	#$2700,sr
		move.w	(Universal_Timer).w,d1
		divu.w	#$3C,d1
		andi.l	#$F,d1
		jsr	ContScrCounter
		move	#$2300,sr

loc_4DF2:
		jsr	ObjectsLoad
		jsr	BuildSprites
		cmpi.w	#$180,(Object_Space_1+8).w ; has Sonic	run off	screen?
		bcc.s	Cont_GotoLevel	; if yes, branch
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	Cont_MainLoop
		tst.w	(Universal_Timer).w
		bne.w	Cont_MainLoop
		move.b	#$20,(Game_Mode).w ; go to Sega screen
		rts	
; ===========================================================================

Cont_GotoLevel:				; XREF: Cont_MainLoop
		move.b	#$C,(Game_Mode).w ; set	screen mode to $C (level)
		move.b	#4,(Life_Count).w ; set lives to	3
		moveq	#0,d0
		move.b	d0,Boss_Flag	; clear Boss flag
		move.w	d0,(Ring_Count).w ; clear rings
		move.l	d0,(Timer).w ; clear time
		move.l	d0,(Score).w ; clear score
		move.b	d0,(Last_Checkpoint_Hit).w ; clear lamppost count
		subq.b	#1,(Continue_Count).w ; subtract 1 from continues
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 80 - Continue screen elements
; ---------------------------------------------------------------------------

Obj80:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj80_Index(pc,d0.w),d1
		jmp	Obj80_Index(pc,d1.w)
; ===========================================================================
Obj80_Index:	dc.w Obj80_Main-Obj80_Index
		dc.w Obj80_Display-Obj80_Index
		dc.w Obj80_MakeMiniSonic-Obj80_Index
		dc.w Obj80_ChkType-Obj80_Index
; ===========================================================================

Obj80_Main:				; XREF: Obj80_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj80,4(a0)
		move.w	#$8500,2(a0)
		move.b	#0,1(a0)
		move.b	#$3C,$19(a0)
		move.w	#$120,8(a0)
		move.w	#$C0,$A(a0)
		move.b	d0,Boss_Flag	; clear Boss flag
		move.w	#0,(Ring_Count).w ; clear rings

Obj80_Display:				; XREF: Obj80_Index
		jmp	DisplaySprite
; ===========================================================================
Obj80_MiniSonicPos:
		dc.w $116, $12A, $102, $13E, $EE, $152, $DA, $166, $C6
		dc.w $17A, $B2,	$18E, $9E, $1A2, $8A
; ===========================================================================

Obj80_MakeMiniSonic:			; XREF: Obj80_Index
		movea.l	a0,a1
		lea	(Obj80_MiniSonicPos).l,a2
		moveq	#0,d1
		move.b	(Continue_Count).w,d1
		subq.b	#2,d1
		bcc.s	loc_4EC4
		jmp	DeleteObject
; ===========================================================================

loc_4EC4:				; XREF: Obj80_MakeMiniSonic
		moveq	#1,d3
		cmpi.b	#$E,d1
		bcs.s	loc_4ED0
		moveq	#0,d3
		moveq	#$E,d1

loc_4ED0:
		move.b	d1,d2
		andi.b	#1,d2

Obj80_MiniSonLoop:
		move.b	#$80,0(a1)	; load mini Sonic object
		move.w	(a2)+,8(a1)
		tst.b	d2
		beq.s	loc_4EEA
		subi.w	#$A,8(a1)

loc_4EEA:
		move.w	#$D0,$A(a1)
		move.b	#6,$1A(a1)
		move.b	#6,$24(a1)
		move.l	#Map_obj80,4(a1)
		move.w	#$8551,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1
		dbf	d1,Obj80_MiniSonLoop ; repeat for number of continues
		lea	-$40(a1),a1
		move.b	d3,$28(a1)

Obj80_ChkType:				; XREF: Obj80_Index
		tst.b	$28(a0)
		beq.s	loc_4F40
		cmpi.b	#6,(Object_Space_1+$24).w
		bcs.s	loc_4F40
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#1,d0
		bne.s	loc_4F40
		tst.w	(Object_Space_1+$10).w
		bne.s	Obj80_Delete
		rts	
; ===========================================================================

loc_4F40:				; XREF: Obj80_ChkType
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$F,d0
		bne.s	Obj80_Display2
		bchg	#0,$1A(a0)

Obj80_Display2:
		jmp	DisplaySprite
; ===========================================================================

Obj80_Delete:				; XREF: Obj80_ChkType
		jmp	DeleteObject
; ===========================================================================

; ---------------------------------------------------------------------------
; Object 81 - Sonic on the continue screen
; ---------------------------------------------------------------------------

Obj81:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj81_Index(pc,d0.w),d1
		jsr	Obj81_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj81_Index:	dc.w Obj81_Main-Obj81_Index
		dc.w Obj81_ChkLand-Obj81_Index
		dc.w Obj81_Animate-Obj81_Index
		dc.w Obj81_Run-Obj81_Index
; ===========================================================================

Obj81_Main:				; XREF: Obj81_Index
		addq.b	#2,$24(a0)
		move.w	#$A0,8(a0)
		move.w	#$C0,$C(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#4,1(a0)
		move.b	#2,$18(a0)
		move.b	#$1D,$1C(a0)	; use "floating" animation
		move.w	#$400,$12(a0)	; make Sonic fall from above

Obj81_ChkLand:				; XREF: Obj81_Index
		cmpi.w	#$1A0,$C(a0)	; has Sonic landed yet?
		bne.s	Obj81_ShowFall	; if not, branch
		addq.b	#2,$24(a0)
		clr.w	$12(a0)		; stop Sonic falling
		move.l	#Map_obj80,4(a0)
		move.w	#$8500,2(a0)
		move.b	#0,$1C(a0)
		bra.s	Obj81_Animate
; ===========================================================================

Obj81_ShowFall:				; XREF: Obj81_ChkLand
		jsr	ObjectMove
		jsr	Sonic_Animate
		jmp	LoadSonicDynPLC
; ===========================================================================

Obj81_Animate:				; XREF: Obj81_Index
		tst.b	(Ctrl_1_Press).w	; is any button	pressed?
		bmi.s	Obj81_GetUp	; if yes, branch
		lea	(Ani_obj81).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj81_GetUp:				; XREF: Obj81_Animate
		addq.b	#2,$24(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#$1E,$1C(a0)	; use "getting up" animation
		clr.w	$14(a0)
		subq.w	#8,$C(a0)
		move.b	#CmdID_FadeOut,d0
		bsr.w	PlaySound_Special ; fade out music

Obj81_Run:				; XREF: Obj81_Index
		cmpi.w	#$800,$14(a0)	; check	Sonic's "run speed" (not moving)
		bne.s	Obj81_AddSpeed	; if too low, branch
		move.w	#$1000,$10(a0)	; move Sonic to	the right
		bra.s	Obj81_ShowRun
; ===========================================================================

Obj81_AddSpeed:				; XREF: Obj81_Run
		addi.w	#$20,$14(a0)	; increase "run	speed"

Obj81_ShowRun:				; XREF: Obj81_Run
		jsr	ObjectMove
		jsr	Sonic_Animate
		jmp	LoadSonicDynPLC
; ===========================================================================
Ani_obj81:
	include "objects/animation/obj81.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Continue screen
; ---------------------------------------------------------------------------
Map_obj80:
	include "mappings/sprite/obj80.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence in Green Hill	Zone
; ---------------------------------------------------------------------------

EndingSequence:				; XREF: GameModeArray
		move.b	#CmdID_Stop,d0
		bsr.w	PlaySound_Special ; stop music
		bsr.w	Pal_FadeFrom
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1

End_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,End_ClrObjRam ; clear object	RAM

		lea	(Misc_Variables).w,a1
		moveq	#0,d0
		move.w	#(Misc_Variables_End-Misc_Variables)>>2-1,d1

End_ClrRam:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam	; clear	variables

		lea	(Camera_And_Misc_RAM).w,a1
		moveq	#0,d0
		move.w	#(Camera_And_Misc_RAM_End-Camera_And_Misc_RAM)>>2-1,d1

End_ClrRam2:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam2	; clear	variables

		lea	(Osc_And_Misc_RAM).w,a1
		moveq	#0,d0
		move.w	#(Osc_And_Misc_RAM_End-Osc_And_Misc_RAM)>>2-1,d1

End_ClrRam3:
		move.l	d0,(a1)+
		dbf	d1,End_ClrRam3	; clear	variables

		move	#$2700,sr
		move.w	(VDP_Reg_1_Value).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		bsr.w	ClearScreen
		lea	($C00004).l,a6
		move.w	#$8B03,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$857C,(a6)
		move.w	#$9001,(a6)
		move.w	#$8004,(a6)
		move.w	#$8720,(a6)
		move.w	#$8ADF,(H_Int_Counter).w
		move.w	(H_Int_Counter).w,(a6)
		move.w	#$600,(Current_Zone_And_Act).w ; set level	number to 0600 (extra flowers)
		move.b	#0,(Bad_Ending_Flag).w	; puts a 0 in this flag
		cmpi.b	#6,(Emerald_Count).w ; do you have all 6 emeralds?
		beq.s	End_LoadData	; if yes, branch
		move.w	#$601,(Current_Zone_And_Act).w ; set level	number to 0601 (no flowers)
		move.b	#1,(Bad_Ending_Flag).w	; puts a 1 in this flag

End_LoadData:
		moveq	#$1C,d0
		bsr.w	RunPLC_ROM	; load ending sequence patterns
		jsr	Hud_Base
		bsr.w	LevelSizeLoad
		bsr.w	DeformBgLayer
		bset	#2,(Scroll_Flags).w
		bsr.w	MainLoadBlockLoad
		bsr.w	LoadTilesFromStart
	;	move.l	#Col_GHZ,(Collision_Addr).w ; load collision	index
		move.l	#Col_GHZ_1,(First_Collision_Addr).w			; MJ: Set first collision for ending
		move.l	#Col_GHZ_2,(Second_Collision_Addr).w			; MJ: Set second collision for ending
		move	#$2300,sr
		lea	(Kos_EndFlowers).l,a0 ;	load extra flower patterns
		lea	(General_Buffer+$9400).w,a1 ; RAM address to buffer the patterns
		bsr.w	KosDec
		moveq	#3,d0
		bsr.w	PalLoad1	; load Sonic's Palette
		move.b	(Bad_Ending_Flag).w,d0
		lea	(MusicList_Endings).l,a1 ; load Music Playlist for Endings
		move.b	(a1,d0.w),d0 ; get d0-th entry from the playlist
		bsr.w	PlaySound
		btst	#6,(Ctrl_1_Held).w ; is button A pressed?
		beq.s	End_LoadSonic	; if not, branch
		move.b	#1,(Debug_Cheat_On).w ; enable debug	mode

End_LoadSonic:
		move.b	#1,(Object_RAM).w ; load	Sonic object
		bset	#0,(Object_Space_1+$22).w ; make	Sonic face left
		move.b	#1,(Lock_Controls_Flag).w ; lock	controls
		move.w	#$400,(Sonic_Ctrl_Held).w ; move Sonic to the	left
		move.w	#$F800,(Object_Space_1+$14).w ; set Sonic's speed
	;	move.b	#$21,(Object_Space_2).w ; load HUD object
		jsr	ObjectsManager
		jsr	ObjectsLoad
		jsr	BuildSprites
		moveq	#0,d0
		move.w	d0,(Ring_Count).w
		move.l	d0,(Timer).w
		move.b	d0,(Extra_Life_Flags).w
		move.b	d0,(Shield_Flag).w
		move.b	d0,(Invincibility_Flag).w
		move.b	d0,(Speed_Shoes_Flag).w
		move.w	d0,(Debug_Placement_Mode).w
		move.w	d0,(Level_Inactive_Flag).w
		move.w	d0,(Level_Timer).w
		bsr.w	OscillateNumInit
		move.b	#1,(Update_HUD_Score).w
		move.b	#1,(Update_HUD_Rings).w
		move.b	#0,(Update_HUD_Timer).w
		move.w	#1800,(Universal_Timer).w
		move.b	#$18,(V_Int_Routine).w
		bsr.w	DelayProgram
		move.w	(VDP_Reg_1_Value).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		move.w	#$3F,(Palette_Fade_Range).w
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; Main ending sequence loop
; ---------------------------------------------------------------------------

End_MainLoop:
		bsr.w	PauseGame
		move.b	#$18,(V_Int_Routine).w
		bsr.w	DelayProgram
		addq.w	#1,(Level_Timer).w
		bsr.w	End_MoveSonic
		jsr	ObjectsLoad
		bsr.w	DeformBgLayer
		jsr	BuildSprites
		jsr	ObjectsManager
		bsr.w	PalCycle_Load
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		cmpi.b	#$18,(Game_Mode).w ; is	scene number $18 (ending)?
		beq.s	loc_52DA	; if yes, branch
		move.b	#$1C,(Game_Mode).w ; set scene to $1C (credits)
		moveq	#0,d0
		move.b	(Bad_Ending_Flag).w,d0	; get kind of ending (0 = good, 1 = bad)
		lea	(MusicList_Credits).l,a1	; load Music Playlist for credits
		move.b	(a1,d0.w),d0	; get d0-th entry from the playlist
		bsr.w	PlaySound	 ; play credits music
		move.w	#0,(Credits_Index).w ; set credits index number to 0
		rts
; ===========================================================================

loc_52DA:
		tst.w	(Level_Inactive_Flag).w	; is level set to restart?
		beq.w	End_MainLoop	; if not, branch

		clr.w	(Level_Inactive_Flag).w
		move.w	#$3F,(Palette_Fade_Range).w
		clr.w	(Demo_Pal_Fade_Delay).w

End_AllEmlds:				; XREF: loc_5334
		bsr.w	PauseGame
		move.b	#$18,(V_Int_Routine).w
		bsr.w	DelayProgram
		addq.w	#1,(Level_Timer).w
		bsr.w	End_MoveSonic
		jsr	ObjectsLoad
		bsr.w	DeformBgLayer
		jsr	BuildSprites
		jsr	ObjectsManager
		bsr.w	OscillateNumDo
		bsr.w	ChangeRingFrame
		subq.w	#1,(Demo_Pal_Fade_Delay).w
		bpl.s	loc_5334
		move.w	#2,(Demo_Pal_Fade_Delay).w
		bsr.w	Pal_ToWhite

loc_5334:
		tst.w	(Level_Inactive_Flag).w
		beq.w	End_AllEmlds
		clr.w	(Level_Inactive_Flag).w
		move.w	#$2E2F,(Level_Layout+$80).w ; modify level layout
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(Camera_RAM).w,a3
		movea.l	(Level_Layout_FG).w,a4			; MJ: Load address of layout
		move.w	#$4000,d2
		bsr.w	LoadTilesFromStart2
		moveq	#$13,d0
		bsr.w	PalLoad1	; load ending Palette
		bsr.w	Pal_MakeWhite
		bra.w	End_MainLoop

; ---------------------------------------------------------------------------
; Subroutine controlling Sonic on the ending sequence
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


End_MoveSonic:				; XREF: End_MainLoop
		move.b	(Sonic_Ending_Routine).w,d0
		bne.s	End_MoveSonic2
		cmpi.w	#$90,(Object_Space_1+8).w ; has Sonic passed $90 on y-axis?
		bcc.s	End_MoveSonExit	; if not, branch
		addq.b	#2,(Sonic_Ending_Routine).w
		move.b	#1,(Lock_Controls_Flag).w ; lock	player's controls
		move.w	#$800,(Sonic_Ctrl_Held).w ; move Sonic to the	right
		rts	
; ===========================================================================

End_MoveSonic2:				; XREF: End_MoveSonic
		subq.b	#2,d0
		bne.s	End_MoveSonic3
		cmpi.w	#$A0,(Object_Space_1+8).w ; has Sonic passed $A0 on y-axis?
		bcs.s	End_MoveSonExit	; if not, branch
		addq.b	#2,(Sonic_Ending_Routine).w
		moveq	#0,d0
		move.b	d0,(Lock_Controls_Flag).w
		move.w	d0,(Sonic_Ctrl_Held).w ; stop	Sonic moving
		move.w	d0,(Object_Space_1+$14).w
		move.b	#$81,(No_Player_Physics_Flag).w
		move.b	#3,(Object_Space_1+$1A).w
		move.w	#$505,(Object_Space_1+$1C).w ; use "standing" animation
		move.b	#3,(Object_Space_1+$1E).w
		rts	
; ===========================================================================

End_MoveSonic3:				; XREF: End_MoveSonic
		subq.b	#2,d0
		bne.s	End_MoveSonExit
		addq.b	#2,(Sonic_Ending_Routine).w
		move.w	#$A0,(Object_Space_1+8).w
		move.w	#0,(Object_Space_1+$24).w
		move.b	#$87,(Object_RAM).w ; load Sonic	ending sequence	object

End_MoveSonExit:
		rts	
; End of function End_MoveSonic

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 87 - Sonic on ending sequence
; ---------------------------------------------------------------------------

Obj87:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj87_Index(pc,d0.w),d1
		jsr	Obj87_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj87_Index:	dc.w Obj87_Main-Obj87_Index, Obj87_MakeEmlds-Obj87_Index
		dc.w Obj87_Animate-Obj87_Index,	Obj87_LookUp-Obj87_Index
		dc.w Obj87_ClrObjRam-Obj87_Index, Obj87_Animate-Obj87_Index
		dc.w Obj87_MakeLogo-Obj87_Index, Obj87_Animate-Obj87_Index
		dc.w Obj87_Leap-Obj87_Index, Obj87_Animate-Obj87_Index
; ===========================================================================

Obj87_Main:				; XREF: Obj87_Index
		cmpi.b	#6,(Emerald_Count).w ; do you have all 6 emeralds?
		beq.s	Obj87_Main2	; if yes, branch
		addi.b	#$10,$25(a0)	; else,	skip emerald sequence
		move.w	#$D8,$30(a0)
		rts	
; ===========================================================================

Obj87_Main2:				; XREF: Obj87_Main
		addq.b	#2,$25(a0)
		move.l	#Map_obj87,4(a0)
		move.w	#$3E1,2(a0)
		move.b	#4,1(a0)
		clr.b	$22(a0)
		move.b	#2,$18(a0)
		move.b	#0,$1A(a0)
		move.w	#$50,$30(a0)	; set duration for Sonic to pause

Obj87_MakeEmlds:			; XREF: Obj87_Index
		subq.w	#1,$30(a0)	; subtract 1 from duration
		bne.s	Obj87_Wait
		addq.b	#2,$25(a0)
		move.w	#1,$1C(a0)
		move.b	#$88,(Object_Space_17).w ; load chaos	emeralds objects

Obj87_Wait:
		rts	
; ===========================================================================

Obj87_LookUp:				; XREF: Obj87_Index
		cmpi.w	#$2000,(Object_Space_17+$3C).l
		bne.s	locret_5480
		move.w	#1,(Level_Inactive_Flag).w ; set level to	restart	(causes	flash)
		move.w	#$5A,$30(a0)
		addq.b	#2,$25(a0)

locret_5480:
		rts	
; ===========================================================================

Obj87_ClrObjRam:			; XREF: Obj87_Index
		subq.w	#1,$30(a0)
		bne.s	Obj87_Wait2
		lea	(Object_Space_17).w,a1
		move.w	#(Normal_Object_RAM_End-Object_Space_17)>>2-1,d1

Obj87_ClrLoop:
		clr.l	(a1)+
		dbf	d1,Obj87_ClrLoop ; clear the object RAM
		move.w	#1,(Level_Inactive_Flag).w
		addq.b	#2,$25(a0)
		move.b	#1,$1C(a0)
		move.w	#$3C,$30(a0)

Obj87_Wait2:
		rts	
; ===========================================================================

Obj87_MakeLogo:				; XREF: Obj87_Index
		subq.w	#1,$30(a0)
		bne.s	Obj87_Wait3
		addq.b	#2,$25(a0)
		move.w	#$B4,$30(a0)
		move.b	#2,$1C(a0)
		move.b	#$89,(Object_Space_17).w ; load "SONIC THE HEDGEHOG" object

Obj87_Wait3:
		rts	
; ===========================================================================

Obj87_Animate:				; XREF: Obj87_Index
		lea	(Ani_obj87).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj87_Leap:				; XREF: Obj87_Index
		subq.w	#1,$30(a0)
		bne.s	Obj87_Wait4
		addq.b	#2,$25(a0)
		move.l	#Map_obj87,4(a0)
		move.w	#$3E1,2(a0)
		move.b	#4,1(a0)
		clr.b	$22(a0)
		move.b	#2,$18(a0)
		move.b	#5,$1A(a0)
		move.b	#2,$1C(a0)	; use "leaping"	animation
		move.b	#$89,(Object_Space_17).w ; load "SONIC THE HEDGEHOG" object
		bra.s	Obj87_Animate
; ===========================================================================

Obj87_Wait4:				; XREF: Obj87_Leap
		rts	
; ===========================================================================
Ani_obj87:
	include "objects/animation/obj87.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 88 - chaos emeralds on	the ending sequence
; ---------------------------------------------------------------------------

Obj88:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj88_Index(pc,d0.w),d1
		jsr	Obj88_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj88_Index:	dc.w Obj88_Main-Obj88_Index
		dc.w Obj88_Move-Obj88_Index
; ===========================================================================

Obj88_Main:				; XREF: Obj88_Index
		cmpi.b	#2,(Object_Space_1+$1A).w
		beq.s	Obj88_Main2
		addq.l	#4,sp
		rts	
; ===========================================================================

Obj88_Main2:				; XREF: Obj88_Main
		move.w	(Object_Space_1+8).w,8(a0) ; match X position with Sonic
		move.w	(Object_Space_1+$C).w,$C(a0) ; match Y position	with Sonic
		movea.l	a0,a1
		moveq	#0,d3
		moveq	#1,d2
		moveq	#5,d1

Obj88_MainLoop:
		move.b	#$88,(a1)	; load chaos emerald object
		addq.b	#2,$24(a1)
		move.l	#Map_obj88,4(a1)
		move.w	#$3C5,2(a1)
		move.b	#4,1(a1)
		move.b	#1,$18(a1)
		move.w	8(a0),$38(a1)
		move.w	$C(a0),$3A(a1)
		move.b	d2,$1C(a1)
		move.b	d2,$1A(a1)
		addq.b	#1,d2
		move.b	d3,$26(a1)
		addi.b	#$2A,d3
		lea	$40(a1),a1
		dbf	d1,Obj88_MainLoop ; repeat 5 more times

Obj88_Move:				; XREF: Obj88_Index
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		moveq	#0,d4
		move.b	$3C(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	$38(a0),d1
		add.w	$3A(a0),d0
		move.w	d1,8(a0)
		move.w	d0,$C(a0)
		cmpi.w	#$2000,$3C(a0)
		beq.s	loc_55FA
		addi.w	#$20,$3C(a0)

loc_55FA:
		cmpi.w	#$2000,$3E(a0)
		beq.s	loc_5608
		addi.w	#$20,$3E(a0)

loc_5608:
		cmpi.w	#$140,$3A(a0)
		beq.s	locret_5614
		subq.w	#1,$3A(a0)

locret_5614:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 89 - "SONIC THE HEDGEHOG" text	on the ending sequence
; ---------------------------------------------------------------------------

Obj89:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj89_Index(pc,d0.w),d1
		jmp	Obj89_Index(pc,d1.w)
; ===========================================================================
Obj89_Index:	dc.w Obj89_Main-Obj89_Index
		dc.w Obj89_Move-Obj89_Index
		dc.w Obj89_GotoCredits-Obj89_Index
; ===========================================================================

Obj89_Main:				; XREF: Obj89_Index
		addq.b	#2,$24(a0)
		move.w	#-$20,8(a0)	; object starts	outside	the level boundary
		move.w	#$D8,$A(a0)
		move.l	#Map_obj89,4(a0)
		move.w	#$5C5,2(a0)
		move.b	#0,1(a0)
		move.b	#0,$18(a0)

Obj89_Move:				; XREF: Obj89_Index
		cmpi.w	#$C0,8(a0)	; has object reached $C0?
		beq.s	Obj89_Delay	; if yes, branch
		addi.w	#$10,8(a0)	; move object to the right
		jmp	DisplaySprite
; ===========================================================================

Obj89_Delay:				; XREF: Obj89_Move
		addq.b	#2,$24(a0)
		move.w	#120,$30(a0)	; set duration for delay (2 seconds)

Obj89_GotoCredits:			; XREF: Obj89_Index
		subq.w	#1,$30(a0)	; subtract 1 from duration
		bpl.s	Obj89_Display
		move.b	#$1C,(Game_Mode).w ; exit to credits

Obj89_Display:
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Sonic on the ending	sequence
; ---------------------------------------------------------------------------
Map_obj87:
	include "mappings/sprite/obj87.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds on the ending sequence
; ---------------------------------------------------------------------------
Map_obj88:
	include "mappings/sprite/obj88.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC THE HEDGEHOG" text on the ending sequence
; ---------------------------------------------------------------------------
Map_obj89:
	include "mappings/sprite/obj89.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Credits ending sequence
; ---------------------------------------------------------------------------

Credits:				; XREF: GameModeArray
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	(Water_Fullscreen_Flag).w
		bsr.w	ClearScreen
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1

Cred_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,Cred_ClrObjRam ; clear object RAM

		move.l	#$74000002,($C00004).l
		lea	(Nem_CreditText).l,a0 ;	load credits alphabet patterns
		bsr.w	NemDec
		lea	(Target_Palette).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

Cred_ClrPalette:
		move.l	d0,(a1)+
		dbf	d1,Cred_ClrPalette ; fill Palette	with black ($000)

		moveq	#3,d0
		bsr.w	PalLoad1	; load Sonic's Palette
		
		move.b	#$8A,(Object_Space_3).w ; load credits object
		jsr	ObjectsLoad
		jsr	BuildSprites
		addq.w	#1,(Credits_Index).w
		move.w	#120,(Universal_Timer).w ; display a credit for 2 seconds
		bsr.w	Pal_FadeTo

Cred_WaitLoop:
		move.b	#4,(V_Int_Routine).w
		bsr.w	DelayProgram
		bsr.w	RunPLC_RAM
		tst.w	(Universal_Timer).w	; have 2 seconds elapsed?
		bne.s	Cred_WaitLoop	; if not, branch
		tst.l	(PLC_Buffer).w	; have level gfx finished decompressing?
		bne.s	Cred_WaitLoop	; if not, branch
		cmpi.w	#9,(Credits_Index).w ; have	the credits finished?
		beq.w	TryAgainEnd	; if yes, branch
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

TryAgainEnd:				; XREF: Credits
		bsr.w	ClearPLC
		bsr.w	Pal_FadeFrom
		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	(Water_Fullscreen_Flag).w
		bsr.w	ClearScreen
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1

TryAg_ClrObjRam:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrObjRam ; clear object RAM

		moveq	#$1D,d0
		bsr.w	RunPLC_ROM	; load "TRY AGAIN" or "END" patterns
		lea	(Target_Palette).w,a1
		moveq	#0,d0
		move.w	#$1F,d1

TryAg_ClrPalette:
		move.l	d0,(a1)+
		dbf	d1,TryAg_ClrPalette ; fill Palette with black ($000)

		moveq	#$13,d0
		bsr.w	PalLoad1	; load ending Palette
		clr.w	(Normal_Palette+$C0).w
		move.b	#$8B,(Object_Space_3).w ; load Eggman object
		jsr	ObjectsLoad
		jsr	BuildSprites
		move.w	#1800,(Universal_Timer).w ; show screen for 30 seconds
		bsr.w	Pal_FadeTo

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------
TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#4,(V_Int_Routine).w
		bsr.w	DelayProgram
		jsr	ObjectsLoad
		jsr	BuildSprites
		andi.b	#$80,(Ctrl_1_Press).w ; is	Start button pressed?
		bne.s	TryAg_Exit	; if yes, branch
		tst.w	(Universal_Timer).w	; has 30 seconds elapsed?
		beq.s	TryAg_Exit	; if yes, branch
		cmpi.b	#$1C,(Game_Mode).w
		beq.s	TryAg_MainLoop

TryAg_Exit:
		move.b	#$20,(Game_Mode).w ; go to Sega screen
		rts	

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 8B - Eggman on "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

Obj8B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj8B_Index(pc,d0.w),d1
		jsr	Obj8B_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj8B_Index:	dc.w Obj8B_Main-Obj8B_Index
		dc.w Obj8B_Animate-Obj8B_Index
		dc.w Obj8B_Juggle-Obj8B_Index
		dc.w loc_5A8E-Obj8B_Index
; ===========================================================================

Obj8B_Main:				; XREF: Obj8B_Index
		addq.b	#2,$24(a0)
		move.w	#$120,8(a0)
		move.w	#$F4,$A(a0)
		move.l	#Map_obj8B,4(a0)
		move.w	#$3E1,2(a0)
		move.b	#0,1(a0)
		move.b	#2,$18(a0)
		move.b	#2,$1C(a0)	; use "END" animation
		cmpi.b	#6,(Emerald_Count).w ; do you have all 6 emeralds?
		beq.s	Obj8B_Animate	; if yes, branch
		move.b	#$8A,(Object_Space_4).w ; load credits object
		move.w	#9,(Credits_Index).w ; use "TRY AGAIN" text
		move.b	#$8C,(Object_Space_33).w ; load emeralds object on "TRY AGAIN" screen
		move.b	#0,$1C(a0)	; use "TRY AGAIN" animation

Obj8B_Animate:				; XREF: Obj8B_Index
		lea	(Ani_obj8B).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj8B_Juggle:				; XREF: Obj8B_Index
		addq.b	#2,$24(a0)
		moveq	#2,d0
		btst	#0,$1C(a0)
		beq.s	loc_5A6A
		neg.w	d0

loc_5A6A:
		lea	(Dynamic_Object_RAM).w,a1
		moveq	#5,d1

loc_5A70:
		move.b	d0,$3E(a1)
		move.w	d0,d2
		asl.w	#3,d2
		add.b	d2,$26(a1)
		lea	$40(a1),a1
		dbf	d1,loc_5A70
		addq.b	#1,$1A(a0)
		move.w	#112,$30(a0)

loc_5A8E:				; XREF: Obj8B_Index
		subq.w	#1,$30(a0)
		bpl.s	locret_5AA0
		bchg	#0,$1C(a0)
		move.b	#2,$24(a0)

locret_5AA0:
		rts	
; ===========================================================================
Ani_obj8B:
	include "objects/animation/obj8B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 8C - chaos emeralds on	the "TRY AGAIN"	screen
; ---------------------------------------------------------------------------

Obj8C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj8C_Index(pc,d0.w),d1
		jsr	Obj8C_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Obj8C_Index:	dc.w Obj8C_Main-Obj8C_Index
		dc.w Obj8C_Move-Obj8C_Index
; ===========================================================================

Obj8C_Main:				; XREF: Obj8C_Index
		movea.l	a0,a1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#5,d1
		sub.b	(Emerald_Count).w,d1

Obj8C_MakeEms:				; XREF: loc_5B42
		move.b	#$8C,(a1)	; load emerald object
		addq.b	#2,$24(a1)
		move.l	#Map_obj88,4(a1)
		move.w	#$3C5,2(a1)
		move.b	#0,1(a1)
		move.b	#1,$18(a1)
		move.w	#$104,8(a1)
		move.w	#$120,$38(a1)
		move.w	#$EC,$A(a1)
		move.w	$A(a1),$3A(a1)
		move.b	#$1C,$3C(a1)
		lea	(Got_Emeralds_Array).w,a3

Obj8C_ChkEms:
		moveq	#0,d0
		move.b	(Emerald_Count).w,d0
		subq.w	#1,d0
		bcs.s	loc_5B42

Obj8C_ChkEmLoop:
		cmp.b	(a3,d0.w),d2
		bne.s	loc_5B3E
		addq.b	#1,d2
		bra.s	Obj8C_ChkEms
; ===========================================================================

loc_5B3E:
		dbf	d0,Obj8C_ChkEmLoop ; checks which emeralds you have

loc_5B42:
		move.b	d2,$1A(a1)
		addq.b	#1,$1A(a1)
		addq.b	#1,d2
		move.b	#$80,$26(a1)
		move.b	d3,$1E(a1)
		move.b	d3,$1F(a1)
		addi.w	#$A,d3
		lea	$40(a1),a1
		dbf	d1,Obj8C_MakeEms

Obj8C_Move:				; XREF: Obj8C_Index
		tst.w	$3E(a0)
		beq.s	locret_5BBA
		tst.b	$1E(a0)
		beq.s	loc_5B78
		subq.b	#1,$1E(a0)
		bne.s	loc_5B80

loc_5B78:
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)

loc_5B80:
		move.b	$26(a0),d0
		beq.s	loc_5B8C
		cmpi.b	#$80,d0
		bne.s	loc_5B96

loc_5B8C:
		clr.w	$3E(a0)
		move.b	$1F(a0),$1E(a0)

loc_5B96:
		jsr	(CalcSine).l
		moveq	#0,d4
		move.b	$3C(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	$38(a0),d1
		add.w	$3A(a0),d0
		move.w	d1,8(a0)
		move.w	d0,$A(a0)

locret_5BBA:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - Eggman on	the "TRY AGAIN"	and "END" screens
; ---------------------------------------------------------------------------
Map_obj8B:
	include "mappings/sprite/obj8B.asm"

; ---------------------------------------------------------------------------
; Subroutine to	load level boundaries and start	locations
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LevelSizeLoad:				; XREF: TitleScreen; Level; EndingSequence
		moveq	#0,d0
		move.b	d0,(Scroll_Lock).w
		move.b	d0,(Deform_Lock).w
		move.b	d0,(Dynamic_Resize_Routine).w
		move.w	d0,(Camera_X_Pos).w
		move.w	d0,(Camera_Y_Pos).w
		move.b	d0,(Force_Scroll_Flag).w
		move.w	(Current_Zone_And_Act).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	LevelSizeArray(pc,d0.w),a0 ; load level	boundaries
		move.w	(a0)+,d0
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_X_Pos).w
		move.l	d0,(Target_Camera_Min_X_Pos).w
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_Y_Pos).w
		move.l	d0,(Target_Camera_Min_Y_Pos).w
		move.w	#$1010,(Horiz_Block_Crossed_Flag).w
		move.w	(a0)+,d0
		move.w	d0,(Camera_Y_Pos_Bias).w
		sf.b	(H_Wrap_Flag).w
		bra.w	LevSz_ChkLamp
; ===========================================================================
; ---------------------------------------------------------------------------
; Level size array and ending start location array
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------
; Level size array
; FORMAT:
; dc.w 4, left x boundary, right x boundary, upper y boundary, lower y boundary, $60
; Set the lower y boundary to $FF00 for vertical wrapping
; ---------------------------------------------------------------------------

LevelSizeArray:
		; GHZ
		dc.w 4,     0, $24BF,     0, $300, $60
		dc.w 4,     0, $1EBF,     0, $300, $60
		dc.w 4,     0, $2960,     0, $300, $60
		dc.w 4,     0, $2ABF,     0, $300, $60
		
		;LZ
		dc.w 4,     0, $1FBF,     0, $640, $60
		dc.w 4,     0, $1FBF,     0, $640, $60
		dc.w 4,     0, $2000,     0, $6C0, $60
		dc.w 4,     0, $3EC0,     0, $720, $60

		; MZ
		dc.w 4,     0, $1D5F,     0, $300, $60
		dc.w 4,     0, $17BF,     0, $300, $60
		dc.w 4,     0, $2960,     0, $300, $60
		dc.w 4,     0, $2ABF,     0, $300, $60
		
		; SLZ
		dc.w 4,     0, $1FBF,     0, $640, $60
		dc.w 4,     0, $1FBF,     0, $640, $60
		dc.w 4,     0, $2000,     0, $6C0, $60
		dc.w 4,     0, $3EC0,     0, $720, $60
		
		; SYZ
		dc.w 4,     0, $22C0,     0, $420, $60
		dc.w 4,     0, $28C0,     0, $520, $60
		dc.w 4,     0, $2C00,     0, $620, $60
		dc.w 4,     0, $2EC0,     0, $620, $60
		
		; SBZ
		dc.w 4,     0, $21C0,     0, $720, $60
		dc.w 4,     0, $1E40,     0, $800, $60
		dc.w 4, $2080, $2760,  $510, $510, $60
		dc.w 4,     0, $3EC0,     0, $720, $60
		
		; Ending
		dc.w 4,     0, $500,   $110, $110, $60
		dc.w 4,     0, $DC0,   $110, $110, $60
		dc.w 4,     0, $2FFF,     0, $320, $60
		dc.w 4,     0, $2FFF,     0, $320, $60
; ===========================================================================

LevSz_ChkLamp:				; XREF: LevelSizeLoad
		tst.b	(Last_Checkpoint_Hit).w	; have any lampposts been hit?
		beq.s	LevSz_StartLoc	; if not, branch
		jsr	Obj79_LoadInfo
		move.w	(Object_Space_1+8).w,d1
		move.w	(Object_Space_1+$C).w,d0
		bra.s	loc_60D0
; ===========================================================================

LevSz_StartLoc:				; XREF: LevelSizeLoad
		move.w	(Current_Zone_And_Act).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea	(StartLocArray).l,a1			; MJ: load location array
		lea	(a1,d0.w),a1				; MJ: load Sonic's start location address
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,(Object_Space_1+8).w ; set Sonic's position on x-axis
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(Object_Space_1+$C).w ; set Sonic's position on y-axis
		
loc_60D0:
		clr.w	(Sonic_Pos_Record_Index).w		; reset Sonic's position tracking index
		lea	(Sonic_Pos_Record_Buf).w,a2	; load the tracking array into a2
		moveq	#63,d2				; begin a 64-step loop
		
@looppoint:
		move.w	d1,(a2)+			; fill in X
		move.w	d0,(a2)+			; fill in Y
		dbf	d2,@looppoint		; loop
		subi.w	#$A0,d1
		bcc.s	loc_60D8
		moveq	#0,d1

loc_60D8:
		move.w	(Camera_Max_X_Pos).w,d2
		cmp.w	d2,d1
		bcs.s	loc_60E2
		move.w	d2,d1

loc_60E2:
		move.w	d1,(Camera_X_Pos).w
		subi.w	#$60,d0
		bcc.s	loc_60EE
		moveq	#0,d0

loc_60EE:
		cmp.w	(Camera_Max_Y_Pos).w,d0
		blt.s	loc_60F8
		move.w	(Camera_Max_Y_Pos).w,d0

loc_60F8:
		bclr	#0,d0
		move.w	d0,(Camera_Y_Pos).w
		bsr.w	BgScrollSpeed
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#3,d0
		lea	dword_61B4(pc,d0.w),a1
		lea	(Unk_Scroll_Values).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		rts	
; End of function LevelSizeLoad

; ===========================================================================
dword_61B4:
		dc.l $700100, $1000100
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $8000100, $1000000
		dc.l $700100, $1000100

; ===========================================================================
; ---------------------------------------------------------------------------
; MJ: Sonic start location array
; ---------------------------------------------------------------------------

StartLocArray:
		incbin	level/startpos/ghz1.bin
		incbin	level/startpos/ghz2.bin
		incbin	level/startpos/ghz3.bin
		incbin	level/startpos/ghz4.bin
		incbin	level/startpos/lz1.bin
		incbin	level/startpos/lz2.bin
		incbin	level/startpos/lz3.bin
		incbin	level/startpos/lz4.bin
		incbin	level/startpos/mz1.bin
		incbin	level/startpos/mz2.bin
		incbin	level/startpos/mz3.bin
		incbin	level/startpos/mz4.bin
		incbin	level/startpos/slz1.bin
		incbin	level/startpos/slz2.bin
		incbin	level/startpos/slz3.bin
		incbin	level/startpos/slz4.bin
		incbin	level/startpos/syz1.bin
		incbin	level/startpos/syz2.bin
		incbin	level/startpos/syz3.bin
		incbin	level/startpos/syz4.bin
		incbin	level/startpos/sbz1.bin
		incbin	level/startpos/sbz2.bin
		incbin	level/startpos/sbz3.bin
		incbin	level/startpos/sbz4.bin
		incbin	level/startpos/end1.bin
		incbin	level/startpos/end2.bin
		incbin	level/startpos/end3.bin
		incbin	level/startpos/end4.bin
		even

; ---------------------------------------------------------------------------
; Subroutine to	set scroll speed of some backgrounds
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BgScrollSpeed:				; XREF: LevelSizeLoad
		tst.b	(Last_Checkpoint_Hit).w
		bne.s	loc_6206
		move.w	d0,(Camera_BG_Y_Pos).w
		move.w	d0,(Camera_BG2_Y_Pos).w
		move.w	d1,(Camera_BG_X_Pos).w
		move.w	d1,(Camera_BG2_X_Pos).w
		move.w	d1,(Camera_BG3_X_Pos).w

loc_6206:
		moveq	#0,d2
		move.b	(Current_Zone).w,d2
		add.w	d2,d2
		move.w	BgScroll_Index(pc,d2.w),d2
		jmp	BgScroll_Index(pc,d2.w)
; End of function BgScrollSpeed

; ===========================================================================
BgScroll_Index:	dc.w BgScroll_GHZ-BgScroll_Index, BgScroll_LZ-BgScroll_Index
		dc.w BgScroll_MZ-BgScroll_Index, BgScroll_SLZ-BgScroll_Index
		dc.w BgScroll_SYZ-BgScroll_Index, BgScroll_SBZ-BgScroll_Index
		dc.w BgScroll_End-BgScroll_Index
; ===========================================================================

BgScroll_GHZ:				; XREF: BgScroll_Index
		bra.w	Deform_GHZ
; ===========================================================================

BgScroll_LZ:				; XREF: BgScroll_Index
		asr.l	#1,d0
		addi.w	#$C0,d0
		move.w	d0,(Camera_BG_Y_Pos).w
		rts		
; ===========================================================================

BgScroll_MZ:				; XREF: BgScroll_Index
		rts	
; ===========================================================================

BgScroll_SLZ:				; XREF: BgScroll_Index
		asr.l	#1,d0
		addi.w	#$C0,d0
		move.w	d0,(Camera_BG_Y_Pos).w
		rts	
; ===========================================================================

BgScroll_SYZ:				; XREF: BgScroll_Index
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		move.w	d0,(Camera_BG_Y_Pos).w
		move.w	d0,(Camera_BG2_Y_Pos).w
		rts	
; ===========================================================================

BgScroll_SBZ:				; XREF: BgScroll_Index
		asl.l	#4,d0
		asl.l	#1,d0
		asr.l	#8,d0
		move.w	d0,(Camera_BG_Y_Pos).w
		rts	
; ===========================================================================

BgScroll_End:				; XREF: BgScroll_Index
		move.w	#$1E,(Camera_BG_Y_Pos).w
		move.w	#$1E,(Camera_BG2_Y_Pos).w
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Background layer deformation subroutines
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DeformBgLayer:				; XREF: TitleScreen; Level; EndingSequence
		tst.b	(Deform_Lock).w
		beq.s	loc_628E
		rts	
; ===========================================================================

loc_628E:
		clr.w	(Scroll_Flags).w
		clr.w	(Scroll_Flags_BG).w
		clr.w	(Scroll_Flags_BG2).w
		clr.w	(Scroll_Flags_BG3).w
		clr.w	(Camera_X_Pos_Diff).w
		clr.w	(Camera_Y_Pos_Diff).w
		tst.b	(Scroll_Lock).w
		bne.s	@Skip
		bsr.w	ScrollHoriz
		bsr.w	ScrollVertical

@Skip:
		bsr.w	DynScrResizeLoad
		move.w	(Camera_X_Pos).w,(H_Scroll_Value_FG).w
		move.w	(Camera_Y_Pos).w,(V_Scroll_Value_FG).w
		move.w	(Camera_BG_X_Pos).w,(H_Scroll_Value_BG).w
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		move.w	(Camera_BG3_X_Pos).w,(Camera_BG3_X_Pos_Prev).w
		move.w	(Camera_BG3_Y_Pos).w,(Camera_BG3_Y_Pos_Prev).w
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	Deform_Index(pc,d0.w),d0
		jmp	Deform_Index(pc,d0.w)
; End of function DeformBgLayer

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for background layer deformation	code
; ---------------------------------------------------------------------------
Deform_Index:	dc.w Deform_GHZ-Deform_Index, Deform_LZ-Deform_Index
		dc.w Deform_MZ-Deform_Index, Deform_SLZ-Deform_Index
		dc.w Deform_SYZ-Deform_Index, Deform_SBZ-Deform_Index
		dc.w Deform_GHZ-Deform_Index
; ---------------------------------------------------------------------------
; Green	Hill Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_GHZ:				; XREF: Deform_Index
		move.w	(Camera_X_Pos_Diff).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d5
		bsr.w	ScrollBlock1
		bsr.w	ScrollBlock4
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	(Camera_Y_Pos).w,d0
		andi.w	#$7FF,d0
		lsr.w	#5,d0
		neg.w	d0
		addi.w	#$26,d0
		move.w	d0,(Camera_BG2_Y_Pos).w
		move.w	d0,d4
		bsr.w	ScrollBlock3
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		move.w	#$6F,d1
		sub.w	d4,d1
		move.w	(Camera_X_Pos).w,d0
		cmpi.b	#4,(Game_Mode).w
		bne.s	loc_633C
		moveq	#0,d0

loc_633C:
		neg.w	d0
		swap	d0
		move.w	(Camera_BG_X_Pos).w,d0
		neg.w	d0

loc_6346:
		move.l	d0,(a1)+
		dbf	d1,loc_6346
		move.w	#$27,d1
		move.w	(Camera_BG2_X_Pos).w,d0
		neg.w	d0

loc_6356:
		move.l	d0,(a1)+
		dbf	d1,loc_6356
		move.w	(Camera_BG2_X_Pos).w,d0
		addi.w	#0,d0
		move.w	(Camera_X_Pos).w,d2
		addi.w	#-$200,d2
		sub.w	d0,d2
		ext.l	d2
		asl.l	#8,d2
		divs.w	#$68,d2
		ext.l	d2
		asl.l	#8,d2
		moveq	#0,d3
		move.w	d0,d3
		move.w	#$47,d1
		add.w	d4,d1

loc_6384:
		move.w	d3,d0
		neg.w	d0
		move.l	d0,(a1)+
		swap	d3
		add.l	d2,d3
		swap	d3
		dbf	d1,loc_6384
		rts	
; End of function Deform_GHZ

; ---------------------------------------------------------------------------
; Labyrinth Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_LZ:				; XREF: Deform_Index
		move.w	(Camera_X_Pos_Diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		move.w	(Camera_Y_Pos_Diff).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	ScrollBlock2
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		bsr.w	Deform_SLZ_2
		lea	(TempArray_LayerDef).w,a2
		move.w	(Camera_BG_Y_Pos).w,d0
		move.w	d0,d2
		subi.w	#$C0,d0
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0.w),a2
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	#$E,d1
		move.w	(Camera_X_Pos).w,d0
		neg.w	d0
		swap	d0
		andi.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp	Deform_3LZ(pc,d2.w)
; ===========================================================================

Deform_2LZ:				; XREF: Deform_SLZ
		move.w	(a2)+,d0

Deform_3LZ:
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,Deform_2LZ
		rts	
; End of function Deform_LZ

; ---------------------------------------------------------------------------
; Marble Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_MZ:				; XREF: Deform_Index
		move.w	(Camera_X_Pos_Diff).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.l	d4,d1
		asl.l	#1,d4
		add.l	d1,d4
		moveq	#0,d5
		bsr.w	ScrollBlock1
		move.w	#$200,d0
		move.w	(Camera_Y_Pos).w,d1
		subi.w	#$1C8,d1
		bcs.s	loc_6402
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1
		asr.w	#2,d1
		add.w	d1,d0

loc_6402:
		move.w	d0,(Camera_BG2_Y_Pos).w
		bsr.w	ScrollBlock3
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	#(Horiz_Scroll_Buf_End-Horiz_Scroll_Buf)>>2-1,d1
		move.w	(Camera_X_Pos).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_BG_X_Pos).w,d0
		neg.w	d0

loc_6426:
		move.l	d0,(a1)+
		dbf	d1,loc_6426
		rts	
; End of function Deform_MZ

; ---------------------------------------------------------------------------
; Star Light Zone background layer deformation code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SLZ:				; XREF: Deform_Index
		move.w	(Camera_X_Pos_Diff).w,d4
		ext.l	d4
		asl.l	#7,d4
		move.w	(Camera_Y_Pos_Diff).w,d5
		ext.l	d5
		asl.l	#7,d5
		bsr.w	ScrollBlock2
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		bsr.w	Deform_SLZ_2
		lea	(TempArray_LayerDef).w,a2
		move.w	(Camera_BG_Y_Pos).w,d0
		move.w	d0,d2
		subi.w	#$C0,d0
		andi.w	#$3F0,d0
		lsr.w	#3,d0
		lea	(a2,d0.w),a2
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	#$E,d1
		move.w	(Camera_X_Pos).w,d0
		neg.w	d0
		swap	d0
		andi.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp	loc_6482(pc,d2.w)
; ===========================================================================

loc_6480:				; XREF: Deform_SLZ
		move.w	(a2)+,d0

loc_6482:
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbf	d1,loc_6480
		rts	
; End of function Deform_SLZ


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SLZ_2:				; XREF: Deform_SLZ
		lea	(TempArray_LayerDef).w,a1
		move.w	(Camera_X_Pos).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$1C,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		move.w	#$1B,d1

loc_64CE:
		move.w	d3,(a1)+
		swap	d3
		add.l	d0,d3
		swap	d3
		dbf	d1,loc_64CE
		move.w	d2,d0
		asr.w	#3,d0
		move.w	#4,d1

loc_64E2:
		move.w	d0,(a1)+
		dbf	d1,loc_64E2
		move.w	d2,d0
		asr.w	#2,d0
		move.w	#4,d1

loc_64F0:
		move.w	d0,(a1)+
		dbf	d1,loc_64F0
		move.w	d2,d0
		asr.w	#1,d0
		move.w	#$1D,d1

loc_64FE:
		move.w	d0,(a1)+
		dbf	d1,loc_64FE
		rts	
; End of function Deform_SLZ_2

; ---------------------------------------------------------------------------
; Spring Yard Zone background layer deformation	code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SYZ:				; XREF: Deform_Index
		move.w	(Camera_X_Pos_Diff).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.w	(Camera_Y_Pos_Diff).w,d5
		ext.l	d5
		asl.l	#4,d5
		move.l	d5,d1
		asl.l	#1,d5
		add.l	d1,d5
		bsr.w	ScrollBlock1
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	#(Horiz_Scroll_Buf_End-Horiz_Scroll_Buf)>>2-1,d1
		move.w	(Camera_X_Pos).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_BG_X_Pos).w,d0
		neg.w	d0

loc_653C:
		move.l	d0,(a1)+
		dbf	d1,loc_653C
		rts	
; End of function Deform_SYZ

; ---------------------------------------------------------------------------
; Scrap	Brain Zone background layer deformation	code
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Deform_SBZ:				; XREF: Deform_Index
		move.w	(Camera_X_Pos_Diff).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.w	(Camera_Y_Pos_Diff).w,d5
		ext.l	d5
		asl.l	#4,d5
		asl.l	#1,d5
		bsr.w	ScrollBlock1
		move.w	(Camera_BG_Y_Pos).w,(V_Scroll_Value_BG).w
		lea	(Horiz_Scroll_Buf).w,a1
		move.w	#(Horiz_Scroll_Buf_End-Horiz_Scroll_Buf)>>2-1,d1
		move.w	(Camera_X_Pos).w,d0
		neg.w	d0
		swap	d0
		move.w	(Camera_BG_X_Pos).w,d0
		neg.w	d0

loc_6576:
		move.l	d0,(a1)+
		dbf	d1,loc_6576
		rts	
; End of function Deform_SBZ

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level horizontally as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHoriz:				; XREF: DeformBgLayer
		move.w	(Camera_X_Pos).w,d4
		bsr.s	ScrollHoriz2
		move.w	(Camera_X_Pos).w,d0
		andi.w	#$10,d0
		move.b	(Horiz_Block_Crossed_Flag).w,d1
		eor.b	d1,d0
		bne.s	locret_65B0
		eori.b	#$10,(Horiz_Block_Crossed_Flag).w
		move.w	(Camera_X_Pos).w,d0
		sub.w	d4,d0
		bpl.s	loc_65AA
		bset	#2,(Scroll_Flags).w
		rts	
; ===========================================================================

loc_65AA:
		bset	#3,(Scroll_Flags).w

locret_65B0:
		rts	
; End of function ScrollHoriz


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollHoriz2:				; XREF: ScrollHoriz
		tst.b	(Force_Scroll_Flag).w		; Is the screen forced to scroll while wrapping?
		beq.s	@NoForce			; If not, branch
		bmi.s	@Left				; If scroll left, branch
		move.w	(Camera_X_Pos).w,d0		; Increment the camera's x position
		add.w	(Force_Scroll_Speed).w,d0
		bra.s	loc_65E4

@Left:
		move.w	(Camera_X_Pos).w,d0		; Decrement the camera's x position
		sub.w	(Force_Scroll_Speed).w,d0
		bra.s	loc_65E4

@NoForce:
		move.w	(Object_Space_1+8).w,d0
		sub.w	(Camera_X_Pos).w,d0
		subi.w	#$90,d0
		bmi.s	loc_65F6				; cs to mi (for negative)
		subi.w	#$10,d0
		bpl.s	loc_65CC				; cc to pl (for negative)
		clr.w	(Camera_X_Pos_Diff).w
		rts
; ===========================================================================

loc_65CC:
		cmpi.w	#$10,d0
		bcs.s	loc_65D6
		move.w	#$10,d0

loc_65D6:
		add.w	(Camera_X_Pos).w,d0
		cmp.w	(Camera_Max_X_Pos).w,d0
		blt.s	loc_65E4
		move.w	(Camera_Max_X_Pos).w,d0

loc_65E4:
		move.w	d0,d1
		sub.w	(Camera_X_Pos).w,d1
		asl.w	#8,d1
		move.w	d0,(Camera_X_Pos).w
		move.w	d1,(Camera_X_Pos_Diff).w
		rts	
; ===========================================================================

loc_65F6:
		cmpi.w	#$FFF0,d0				; has the screen moved more than 10 pixels left?
		bcc.s	Left_NoMax				; if not, branch
		move.w	#$FFF0,d0				; set the maximum move distance to 10 pixels left

Left_NoMax:
		add.w	(Camera_X_Pos).w,d0
		cmp.w	(Camera_Min_X_Pos).w,d0
		bgt.s	loc_65E4
		move.w	(Camera_Min_X_Pos).w,d0
		bra.s	loc_65E4
; End of function ScrollHoriz2

; ===========================================================================
		tst.w	d0
		bpl.s	loc_6610
		move.w	#-2,d0
		bra.s	loc_65F6
; ===========================================================================

loc_6610:
		move.w	#2,d0
		bra.s	loc_65CC

; ---------------------------------------------------------------------------
; Subroutine to	scroll the level vertically as Sonic moves
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollVertical:				; XREF: DeformBgLayer
		moveq	#0,d1
		move.w	(Object_Space_1+$C).w,d0
		sub.w	(Camera_Y_Pos).w,d0
		cmpi.w	#-$100,(Camera_Max_Y_Pos).w
		bne.s	@NoWrap
		andi.w	#$7FF,d0
		
@NoWrap:
		btst	#1,(Object_Space_1+$22).w
		beq.s	loc_664A
		addi.w	#$20,d0
		sub.w	(Camera_Y_Pos_Bias).w,d0
		bcs.s	loc_6696
		subi.w	#$40,d0
		bcc.s	loc_6696
		tst.b	(V_Scroll_BG_Flag).w
		bne.s	loc_66A8
		bra.s	loc_6656
; ===========================================================================

loc_664A:
		sub.w	(Camera_Y_Pos_Bias).w,d0
		bne.s	loc_665C
		tst.b	(V_Scroll_BG_Flag).w
		bne.s	loc_66A8

loc_6656:
		clr.w	(Camera_Y_Pos_Diff).w
		rts	
; ===========================================================================

loc_665C:
		cmpi.w	#$60,(Camera_Y_Pos_Bias).w
		bne.s	loc_6684
		move.w	(Object_Space_1+$14).w,d1
		bpl.s	loc_666C
		neg.w	d1

loc_666C:
		cmpi.w	#$800,d1
		bcc.s	loc_6696
		move.w	#$600,d1
		cmpi.w	#6,d0
		bgt.s	loc_66F6
		cmpi.w	#-6,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6684:
		move.w	#$200,d1
		cmpi.w	#2,d0
		bgt.s	loc_66F6
		cmpi.w	#-2,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_6696:
		move.w	#$1000,d1
		cmpi.w	#$10,d0
		bgt.s	loc_66F6
		cmpi.w	#-$10,d0
		blt.s	loc_66C0
		bra.s	loc_66AE
; ===========================================================================

loc_66A8:
		moveq	#0,d0
		move.b	d0,(V_Scroll_BG_Flag).w

loc_66AE:
		moveq	#0,d1
		move.w	d0,d1
		add.w	(Camera_Y_Pos).w,d1
		tst.w	d0
		bpl.w	loc_6700
		bra.w	loc_66CC
; ===========================================================================

loc_66C0:
		neg.w	d1
		ext.l	d1
		asl.l	#8,d1
		add.l	(Camera_Y_Pos).w,d1
		swap	d1

loc_66CC:
		cmp.w	(Camera_Min_Y_Pos).w,d1
		bgt.s	loc_6724
		cmpi.w	#-$100,d1
		bgt.s	loc_66F0
		andi.w	#$7FF,d1
		andi.w	#$7FF,(Object_Space_1+$C).w
		bra.s	loc_6724
; ===========================================================================

loc_66F0:
		move.w	(Camera_Min_Y_Pos).w,d1
		bra.s	loc_6724
; ===========================================================================

loc_66F6:
		ext.l	d1
		asl.l	#8,d1
		add.l	(Camera_Y_Pos).w,d1
		swap	d1

loc_6700:
		cmp.w	(Camera_Max_Y_Pos).w,d1
		blt.s	loc_6724
		subi.w	#$800,d1
		bcs.s	loc_6720
		subi.w	#$800,(Camera_Y_Pos).w
		bra.s	loc_6724
; ===========================================================================

loc_6720:
		move.w	(Camera_Max_Y_Pos).w,d1

loc_6724:
		move.w	(Camera_Y_Pos).w,d4
		swap	d1
		move.l	d1,d3
		sub.l	(Camera_Y_Pos).w,d3
		ror.l	#8,d3
		move.w	d3,(Camera_Y_Pos_Diff).w
		move.l	d1,(Camera_Y_Pos).w
		move.w	(Camera_Y_Pos).w,d0
		andi.w	#$10,d0
		move.b	(Verti_Block_Crossed_Flag).w,d1
		eor.b	d1,d0
		bne.s	locret_6766
		eori.b	#$10,(Verti_Block_Crossed_Flag).w
		move.w	(Camera_Y_Pos).w,d0
		sub.w	d4,d0
		bpl.s	loc_6760
		bset	#0,(Scroll_Flags).w
		rts	
; ===========================================================================

loc_6760:
		bset	#1,(Scroll_Flags).w

locret_6766:
		rts	
; End of function ScrollVertical


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock1:				; XREF: Deform_GHZ; et al
		move.l	(Camera_BG_X_Pos).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(Camera_BG_X_Pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Horiz_Block_Crossed_Flag_BG).w,d3
		eor.b	d3,d1
		bne.s	loc_679C
		eori.b	#$10,(Horiz_Block_Crossed_Flag_BG).w
		sub.l	d2,d0
		bpl.s	loc_6796
		bset	#2,(Scroll_Flags_BG).w
		bra.s	loc_679C
; ===========================================================================

loc_6796:
		bset	#3,(Scroll_Flags_BG).w

loc_679C:
		move.l	(Camera_BG_Y_Pos).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(Camera_BG_Y_Pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Verti_Block_Crossed_Flag_BG).w,d2
		eor.b	d2,d1
		bne.s	locret_67D0
		eori.b	#$10,(Verti_Block_Crossed_Flag_BG).w
		sub.l	d3,d0
		bpl.s	loc_67CA
		bset	#0,(Scroll_Flags_BG).w
		rts	
; ===========================================================================

loc_67CA:
		bset	#1,(Scroll_Flags_BG).w

locret_67D0:
		rts	
; End of function ScrollBlock1


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock2:				; XREF: Deform_SLZ
		move.l	(Camera_BG_X_Pos).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,(Camera_BG_X_Pos).w
		move.l	(Camera_BG_Y_Pos).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,(Camera_BG_Y_Pos).w
		move.l	d0,d1
		swap	d1
		andi.w	#$10,d1
		move.b	(Verti_Block_Crossed_Flag_BG).w,d2
		eor.b	d2,d1
		bne.s	locret_6812
		eori.b	#$10,(Verti_Block_Crossed_Flag_BG).w
		sub.l	d3,d0
		bpl.s	loc_680C
		bset	#0,(Scroll_Flags_BG).w
		rts	
; ===========================================================================

loc_680C:
		bset	#1,(Scroll_Flags_BG).w

locret_6812:
		rts	
; End of function ScrollBlock2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock3:				; XREF: Deform_GHZ; et al
		move.w	(Camera_BG_Y_Pos).w,d3
		move.w	d0,(Camera_BG_Y_Pos).w
		move.w	d0,d1
		andi.w	#$10,d1
		move.b	(Verti_Block_Crossed_Flag_BG).w,d2
		eor.b	d2,d1
		bne.s	locret_6842
		eori.b	#$10,(Verti_Block_Crossed_Flag_BG).w
		sub.w	d3,d0
		bpl.s	loc_683C
		bset	#0,(Scroll_Flags_BG).w
		rts	
; ===========================================================================

loc_683C:
		bset	#1,(Scroll_Flags_BG).w

locret_6842:
		rts	
; End of function ScrollBlock3


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ScrollBlock4:				; XREF: Deform_GHZ
		move.w	(Camera_BG2_X_Pos).w,d2
		move.w	(Camera_BG2_Y_Pos).w,d3
		move.w	(Camera_X_Pos_Diff).w,d0
		ext.l	d0
		asl.l	#7,d0
		add.l	d0,(Camera_BG2_X_Pos).w
		move.w	(Camera_BG2_X_Pos).w,d0
		andi.w	#$10,d0
		move.b	(Horiz_Block_Crossed_Flag_BG2).w,d1
		eor.b	d1,d0
		bne.s	locret_6884
		eori.b	#$10,(Horiz_Block_Crossed_Flag_BG2).w
		move.w	(Camera_BG2_X_Pos).w,d0
		sub.w	d2,d0
		bpl.s	loc_687E
		bset	#2,(Scroll_Flags_BG2).w
		bra.s	locret_6884
; ===========================================================================

loc_687E:
		bset	#3,(Scroll_Flags_BG2).w

locret_6884:
		rts	
; End of function ScrollBlock4


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6886:				; XREF: loc_C44
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(Scroll_Flags_BG).w,a2
		lea	(Camera_BG_X_Pos).w,a3
		movea.l	(Level_Layout_BG).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	sub_6954
		lea	(Scroll_Flags_BG2).w,a2
		lea	(Camera_BG2_X_Pos).w,a3
		bra.w	sub_69F4
; End of function sub_6886

; ---------------------------------------------------------------------------
; Subroutine to	display	correct	tiles as you move
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesAsYouMove:			; XREF: Demo_Time
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(Scroll_Flags_BG_Copy).w,a2
		lea	(Camera_BG_X_Pos_Copy).w,a3
		movea.l	(Level_Layout_BG).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
		bsr.w	sub_6954
		lea	(Scroll_Flags_BG2_Copy).w,a2
		lea	(Camera_BG2_X_Pos_Copy).w,a3
		bsr.w	sub_69F4
		lea	(Scroll_Flags_Copy).w,a2
		lea	(Camera_X_Pos_Copy).w,a3
		movea.l	(Level_Layout_FG).w,a4			; MJ: Load address of layout
		move.w	#$4000,d2
		tst.b	(Screen_Redraw_Flag).w
		beq.s	Draw_FG
		move.b	#0,(Screen_Redraw_Flag).w
		moveq	#-$10,d4
		moveq	#$F,d6

Draw_All:
		movem.l	d4-d6,-(sp)
		moveq	#-$10,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_LR
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,Draw_All
		move.b	#0,(Scroll_Flags_Copy).w
		rts

Draw_FG:
		tst.b	(a2)
		beq.s	locret_6952
		bclr	#0,(a2)
		beq.s	loc_6908
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_LR

loc_6908:
		bclr	#1,(a2)
		beq.s	loc_6922
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_LR

loc_6922:
		bclr	#2,(a2)
		beq.s	loc_6938
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	DrawTiles_TB

loc_6938:
		bclr	#3,(a2)
		beq.s	locret_6952
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	DrawTiles_TB

locret_6952:
		rts	
; End of function LoadTilesAsYouMove


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6954:				; XREF: sub_6886; LoadTilesAsYouMove
		tst.b	(a2)
		beq.w	locret_69F2
		bclr	#0,(a2)
		beq.s	loc_6972
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		moveq	#$1F,d6
		bsr.w	DrawTiles_LR_2

loc_6972:
		bclr	#1,(a2)
		beq.s	loc_698E
		move.w	#$E0,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	#$E0,d4
		moveq	#-$10,d5
		moveq	#$1F,d6
		bsr.w	DrawTiles_LR_2

loc_698E:
		bclr	#2,(a2)
		beq.s	loc_69BE
		moveq	#-$10,d4
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		moveq	#-$10,d5
		move.w	(Unk_Scroll_Values).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	loc_69BE
		lsr.w	#4,d6
		cmpi.w	#$F,d6
		bcs.s	loc_69BA
		moveq	#$F,d6

loc_69BA:
		bsr.w	DrawTiles_TB_2

loc_69BE:
		bclr	#3,(a2)
		beq.s	locret_69F2
		moveq	#-$10,d4
		move.w	#$140,d5
		bsr.w	Calc_VRAM_Pos
		moveq	#-$10,d4
		move.w	#$140,d5
		move.w	(Unk_Scroll_Values).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	locret_69F2
		lsr.w	#4,d6
		cmpi.w	#$F,d6
		bcs.s	loc_69EE
		moveq	#$F,d6

loc_69EE:
		bsr.w	DrawTiles_TB_2

locret_69F2:
		rts	
; End of function sub_6954


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_69F4:				; XREF: sub_6886; LoadTilesAsYouMove
		tst.b	(a2)
		beq.w	locret_6A80
		bclr	#2,(a2)
		beq.s	loc_6A3E
		cmpi.w	#$10,(a3)
		bcs.s	loc_6A3E
		move.w	(Unk_Scroll_Values).w,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		moveq	#-$10,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		moveq	#-$10,d5
		move.w	(Unk_Scroll_Values).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	loc_6A3E
		lsr.w	#4,d6
		subi.w	#$E,d6
		bcc.s	loc_6A3E
		neg.w	d6
		bsr.w	DrawTiles_TB_2

loc_6A3E:
		bclr	#3,(a2)
		beq.s	locret_6A80
		move.w	(Unk_Scroll_Values).w,d4
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d4
		move.w	d4,-(sp)
		move.w	#$140,d5
		bsr.w	Calc_VRAM_Pos
		move.w	(sp)+,d4
		move.w	#$140,d5
		move.w	(Unk_Scroll_Values).w,d6
		move.w	4(a3),d1
		andi.w	#-$10,d1
		sub.w	d1,d6
		blt.s	locret_6A80
		lsr.w	#4,d6
		subi.w	#$E,d6
		bcc.s	locret_6A80
		neg.w	d6
		bsr.w	DrawTiles_TB_2

locret_6A80:
		rts	
; End of function sub_69F4


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawTiles_LR:				; XREF: LoadTilesAsYouMove
		moveq	#$15,d6
; End of function DrawTiles_LR


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawTiles_LR_2:				; XREF: sub_6954; LoadTilesFromStart2
		move.l	#$800000,d7
		move.l	d0,d1

loc_6AE2:
		movem.l	d4-d5,-(sp)
		bsr.w	sub_6BD6
		move.l	d1,d0
		bsr.w	sub_6B32
		addq.b	#4,d1
		andi.b	#$7F,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d5
		dbf	d6,loc_6AE2
		rts	
; End of function DrawTiles_LR_2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DrawTiles_TB:				; XREF: LoadTilesAsYouMove
		moveq	#$F,d6
; End of function DrawTiles_TB


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; main draw section

DrawTiles_TB_2:
		move.l	#$800000,d7
		move.l	d0,d1

loc_6B0E:
		movem.l	d4-d5,-(sp)
		bsr.w	sub_6BD6
		move.l	d1,d0
		bsr.w	sub_6B32
		addi.w	#$100,d1
		andi.w	#$FFF,d1
		movem.l	(sp)+,d4-d5
		addi.w	#$10,d4
		dbf	d6,loc_6B0E
		rts	
; End of function DrawTiles_TB_2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_6B32:				; XREF: DrawTiles_LR_2; DrawTiles_TB_2
		or.w	d2,d0
		swap	d0
		btst	#3,(a0)					; MJ: checking bit 3 not 4 (Flip)
		bne.s	loc_6B6E
		btst	#2,(a0)					; MJ: checking bit 2 not 3 (Mirror)
		bne.s	loc_6B4E
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts	
; ===========================================================================

loc_6B4E:
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,d4
		eori.l	#$8000800,d4
		swap	d4
		move.l	d4,(a6)
		rts	
; ===========================================================================

loc_6B6E:
		btst	#2,(a0) 				; MJ: checking bit 2 not 3 (Mirror)
		bne.s	loc_6B90
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$10001000,d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$10001000,d5
		move.l	d5,(a6)
		rts	
; ===========================================================================

loc_6B90:
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d4
		eori.l	#$18001800,d4
		swap	d4
		move.l	d4,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eori.l	#$18001800,d5
		swap	d5
		move.l	d5,(a6)
		rts	
; End of function sub_6B32


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; Reading from layout

sub_6BD6:
		lea	(Block_Table).w,a1			; MJ: load Block's location
		add.w	4(a3),d4				; MJ: load Y position to d4
		add.w	(a3),d5					; MJ: load X position to d5
		move.w	d4,d3					; MJ: copy Y position to d3
		andi.w	#$780,d3				; MJ: get within 780 (Not 380) (E00 pixels (not 700)) in multiples of 80
		lsr.w	#3,d5					; MJ: divide X position by 8
		move.w	d5,d0					; MJ: copy to d0
		lsr.w	#4,d0					; MJ: divide by 10 (Not 20)
		andi.w	#$7F,d0					; MJ: get within 7F
		lsl.w	#$1,d3					; MJ: multiply by 2 (So it skips the BG)
		add.w	d3,d0					; MJ: add calc'd Y pos
		moveq	#-1,d3					; MJ: prepare FFFF in d3
		move.b	(a4,d0.w),d3				; MJ: collect correct chunk ID from layout
		andi.w	#$FF,d3					; MJ: keep within 7F
		lsl.w	#$7,d3					; MJ: multiply by 80
		andi.w	#$070,d4				; MJ: keep Y pos within 80 pixels
		andi.w	#$00E,d5				; MJ: keep X pos within 10
		add.w	d4,d3					; MJ: add calc'd Y pos to ror'd d3
		add.w	d5,d3					; MJ: add calc'd X pos to ror'd d3
		movea.l	d3,a0					; MJ: set address (Chunk to read)
		move.w	(a0),d3
		andi.w	#$3FF,d3
		lsl.w	#3,d3
		adda.w	d3,a1

locret_6C1E:
		rts	
; End of function sub_6BD6

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; getting VRam location

Calc_VRAM_Pos:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap	d0
		move.w	d4,d0
		rts	
; End of function Calc_VRAM_Pos


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; not used


sub_6C3C:
		add.w	4(a3),d4
		add.w	(a3),d5
		andi.w	#$F0,d4
		andi.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap	d0
		move.w	d4,d0
		rts	
; End of function sub_6C3C

; ---------------------------------------------------------------------------
; Subroutine to	load tiles as soon as the level	appears
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart:			; XREF: Level; EndingSequence
		lea	($C00004).l,a5
		lea	($C00000).l,a6
		lea	(Camera_RAM).w,a3
		movea.l	(Level_Layout_FG).w,a4			; MJ: Load address of layout
		move.w	#$4000,d2
		bsr.s	LoadTilesFromStart2
		lea	(Camera_BG_X_Pos).w,a3
		movea.l	(Level_Layout_BG).w,a4			; MJ: Load address of layout BG
		move.w	#$6000,d2
; End of function LoadTilesFromStart


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTilesFromStart2:			; XREF: LoadTilesFromStart
		moveq	#-$10,d4
		moveq	#$F,d6

loc_6C82:
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	Calc_VRAM_Pos
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	DrawTiles_LR_2
		movem.l	(sp)+,d4-d6
		addi.w	#$10,d4
		dbf	d6,loc_6C82
		rts	
; End of function LoadTilesFromStart2

; ---------------------------------------------------------------------------
; Main Load Block loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MainLoadBlockLoad:			; XREF: Level; EndingSequence
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lsl.w	#4,d0
		lea	(MainLoadBlocks).l,a2
		lea	(a2,d0.w),a2
		move.l	a2,-(sp)
		addq.l	#4,a2
		movea.l	(a2)+,a0
		lea	(Block_Table).w,a1 ; RAM address for 16x16 mappings
		move.w	#0,d0
		bsr.w	EniDec
		movea.l	(a2)+,a0
		lea	(Chunk_Table).l,a1	; RAM address for 256x256 mappings
		bsr.w	KosDec
		bsr.w	LevelLayoutLoad
		move.w	(a2)+,d0
		move.w	(a2),d0
		andi.w	#$FF,d0
		bsr.w	PalLoad1	; load Palette (based on d0)
		movea.l	(sp)+,a2
		addq.w	#4,a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	locret_6D10
		bsr.w	LoadPLC		; load pattern load cues

locret_6D10:
		rts	
; End of function MainLoadBlockLoad

; ---------------------------------------------------------------------------
; Level	layout loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||
; This method now releases free ram space from A408 - A7FF

LevelLayoutLoad:
		move.w	(Current_Zone_And_Act).w,d0
		ror.b	#2,d0
		lsr.w	#6,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(Level_Index).l,a1
		movea.l	(a1,d0.w),a1				; MJ: moving the address strait to a1 rather than adding a word to an address
		move.l	a1,(Level_Layout_FG).w			; MJ: save location of layout to Level_Layout_FG
		adda.w	#$80,a1					; MJ: add 80 (As the BG line is always after the FG line)
		move.l	a1,(Level_Layout_BG).w			; MJ: save location of layout to Level_Layout_BG
		rts						; MJ: Return

; End of function LevelLayoutLoad2

; ---------------------------------------------------------------------------
; Dynamic screen resize	loading	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DynScrResizeLoad:			; XREF: DeformBgLayer
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	Resize_Index(pc,d0.w),d0
		jsr	Resize_Index(pc,d0.w)
		moveq	#2,d1
		move.w	(Target_Camera_Max_Y_Pos).w,d0
		sub.w	(Camera_Max_Y_Pos).w,d0
		beq.s	locret_6DAA
		bcc.s	loc_6DAC
		neg.w	d1
		move.w	(Camera_Y_Pos).w,d0
		cmp.w	(Target_Camera_Max_Y_Pos).w,d0
		bls.s	loc_6DA0
		move.w	d0,(Camera_Max_Y_Pos).w
		andi.w	#-2,(Camera_Max_Y_Pos).w

loc_6DA0:
		add.w	d1,(Camera_Max_Y_Pos).w
		move.b	#1,(V_Scroll_BG_Flag).w

locret_6DAA:
		rts	
; ===========================================================================

loc_6DAC:				; XREF: DynScrResizeLoad
		move.w	(Camera_Y_Pos).w,d0
		addq.w	#8,d0
		cmp.w	(Camera_Max_Y_Pos).w,d0
		bcs.s	loc_6DC4
		btst	#1,(Object_Space_1+$22).w
		beq.s	loc_6DC4
		add.w	d1,d1
		add.w	d1,d1

loc_6DC4:
		add.w	d1,(Camera_Max_Y_Pos).w
		move.b	#1,(V_Scroll_BG_Flag).w
		rts	
; End of function DynScrResizeLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Offset index for dynamic screen resizing
; ---------------------------------------------------------------------------
Resize_Index:	dc.w Resize_GHZ-Resize_Index, Resize_LZ-Resize_Index
		dc.w Resize_MZ-Resize_Index, Resize_SLZ-Resize_Index
		dc.w Resize_SYZ-Resize_Index, Resize_SBZ-Resize_Index
		dc.w Resize_Ending-Resize_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Green	Hill Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_GHZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	Resize_GHZx(pc,d0.w),d0
		jmp	Resize_GHZx(pc,d0.w)
; ===========================================================================
Resize_GHZx:	dc.w Resize_GHZ1-Resize_GHZx
		dc.w Resize_GHZ2-Resize_GHZx
		dc.w Resize_GHZ3-Resize_GHZx
; ===========================================================================

Resize_GHZ1:
		move.w	#$300,(Target_Camera_Max_Y_Pos).w ; set lower	y-boundary
		cmpi.w	#$1780,(Camera_X_Pos).w ; has the camera reached $1780 on x-axis?
		bcs.s	locret_6E08	; if not, branch
		move.w	#$400,(Target_Camera_Max_Y_Pos).w ; set lower	y-boundary

locret_6E08:
		rts	
; ===========================================================================

Resize_GHZ2:
		move.w	#$300,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$ED0,(Camera_X_Pos).w
		bcs.s	locret_6E3A
		move.w	#$200,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$1600,(Camera_X_Pos).w
		bcs.s	locret_6E3A
		move.w	#$400,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$1D60,(Camera_X_Pos).w
		bcs.s	locret_6E3A
		move.w	#$300,(Target_Camera_Max_Y_Pos).w

locret_6E3A:
		rts	
; ===========================================================================

Resize_GHZ3:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_6E4A(pc,d0.w),d0
		jmp	off_6E4A(pc,d0.w)
; ===========================================================================
off_6E4A:	dc.w Resize_GHZ3main-off_6E4A
		dc.w Resize_GHZ3boss-off_6E4A
		dc.w Resize_GHZ3end-off_6E4A
; ===========================================================================

Resize_GHZ3main:
		move.w	#$300,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$380,(Camera_X_Pos).w
		bcs.s	locret_6E96
		move.w	#$310,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$960,(Camera_X_Pos).w
		bcs.s	locret_6E96
		cmpi.w	#$280,(Camera_Y_Pos).w
		bcs.s	loc_6E98
		move.w	#$400,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$1380,(Camera_X_Pos).w
		bcc.s	loc_6E8E
		move.w	#$4C0,(Target_Camera_Max_Y_Pos).w
		move.w	#$4C0,(Camera_Max_Y_Pos).w

loc_6E8E:
		cmpi.w	#$1700,(Camera_X_Pos).w
		bcc.s	loc_6E98

locret_6E96:
		rts	
; ===========================================================================

loc_6E98:
		move.w	#$300,(Target_Camera_Max_Y_Pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w
		rts	
; ===========================================================================

Resize_GHZ3boss:
		cmpi.w	#$960,(Camera_X_Pos).w
		bcc.s	loc_6EB0
		subq.b	#2,(Dynamic_Resize_Routine).w

loc_6EB0:
		cmpi.w	#$2960,(Camera_X_Pos).w
		bcs.s	locret_6EE8
		bsr.w	SingleObjLoad
		bne.s	loc_6ED0
		move.b	#$3D,0(a1)	; load GHZ boss	object
		move.w	#$2A60,8(a1)
		move.w	#$280,$C(a1)

loc_6ED0:
		move.b	#1,(Boss_Flag).w			; set boss flag
		bsr.w	LockScreen
		addq.b	#2,(Dynamic_Resize_Routine).w
		moveq	#$11,d0
		bra.w	LoadPLC		; load boss patterns
; ===========================================================================

locret_6EE8:
		rts	
; ===========================================================================

Resize_GHZ3end:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Labyrinth Zone dynamic screen	resizing
; ---------------------------------------------------------------------------

Resize_LZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	Resize_LZx(pc,d0.w),d0
		jmp	Resize_LZx(pc,d0.w)
; ===========================================================================
Resize_LZx:	dc.w Resize_LZ12-Resize_LZx
		dc.w Resize_LZ12-Resize_LZx
		dc.w Resize_LZ12-Resize_LZx
		dc.w Resize_LZ12-Resize_LZx
; ===========================================================================

Resize_LZ12:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Marble Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_MZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	Resize_MZx(pc,d0.w),d0
		jmp	Resize_MZx(pc,d0.w)
; ===========================================================================
Resize_MZx:	dc.w Resize_MZ1-Resize_MZx
		dc.w Resize_MZ2-Resize_MZx
		dc.w Resize_MZ1-Resize_MZx
; ===========================================================================

Resize_MZ1:
		cmpi.w	#$1780,(Camera_X_Pos).w
		bcs.s	@Do
		move.w	#$210,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$1A00,(Camera_X_Pos).w
		bcs.s	@Skip
		tst.b	(H_Wrap_Flag).w
		bne.s	@Skip
		st.b	(H_Wrap_Flag).w
		move.w	#$1A00,(H_Wrap_Min).w
		move.w	#$1B00,(H_Wrap_Max).w
		move.b	#1,(Force_Scroll_Flag).w
		move.w	#5,(Force_Scroll_Speed).w
		move.w	(Force_Scroll_Speed).w,d0
		asl.w	#8,d0
		subi.w	#$100,d0
		bsr.w	LockScreen
		move.b	#1,(Boss_Flag).w			; set boss flag

@Skip:
		rts

@Do:
		moveq	#0,d0
		move.b	(Dynamic_Resize_Routine).w,d0
		move.w	off_6FB2(pc,d0.w),d0
		jmp	off_6FB2(pc,d0.w)
; ===========================================================================
off_6FB2:	dc.w loc_6FBA-off_6FB2
		dc.w loc_6FEA-off_6FB2
		dc.w loc_702E-off_6FB2
		dc.w loc_7050-off_6FB2
; ===========================================================================

loc_6FBA:
		move.w	#$1D0,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$700,(Camera_X_Pos).w
		bcs.s	locret_6FE8
		move.w	#$220,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$D00,(Camera_X_Pos).w
		bcs.s	locret_6FE8
		move.w	#$340,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$340,(Camera_Y_Pos).w
		bcs.s	locret_6FE8
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_6FE8:
		rts	
; ===========================================================================

loc_6FEA:
		cmpi.w	#$340,(Camera_Y_Pos).w
		bcc.s	loc_6FF8
		subq.b	#2,(Dynamic_Resize_Routine).w
		rts	
; ===========================================================================

loc_6FF8:
		move.w	#0,(Camera_Min_Y_Pos).w
		cmpi.w	#$E00,(Camera_X_Pos).w
		bcc.s	locret_702C
		move.w	#$340,(Camera_Min_Y_Pos).w
		move.w	#$340,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$A90,(Camera_X_Pos).w
		bcc.s	locret_702C
		move.w	#$500,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$370,(Camera_Y_Pos).w
		bcs.s	locret_702C
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_702C:
		rts	
; ===========================================================================

loc_702E:
		cmpi.w	#$370,(Camera_Y_Pos).w
		bcc.s	loc_703C
		subq.b	#2,(Dynamic_Resize_Routine).w
		rts	
; ===========================================================================

loc_703C:
		cmpi.w	#$500,(Camera_Y_Pos).w
		bcs.s	locret_704E
		move.w	#$500,(Camera_Min_Y_Pos).w
		addq.b	#2,(Dynamic_Resize_Routine).w

locret_704E:
		rts	
; ===========================================================================

loc_7050:
		cmpi.w	#$E70,(Camera_X_Pos).w
		bcs.s	locret_7072
		move.w	#0,(Camera_Min_Y_Pos).w
		move.w	#$500,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$1430,(Camera_X_Pos).w
		bcs.s	locret_7072
		move.w	#$210,(Target_Camera_Max_Y_Pos).w

locret_7072:
		rts
; ===========================================================================

Resize_MZ2:
		move.w	#$520,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$1700,(Camera_X_Pos).w
		bcs.s	locret_7088
		move.w	#$200,(Target_Camera_Max_Y_Pos).w

locret_7088:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Star Light Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_SLZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	Resize_SLZx(pc,d0.w),d0
		jmp	Resize_SLZx(pc,d0.w)
; ===========================================================================
Resize_SLZx:	dc.w Resize_SLZ12-Resize_SLZx
		dc.w Resize_SLZ12-Resize_SLZx
		dc.w Resize_SLZ12-Resize_SLZx
; ===========================================================================

Resize_SLZ12:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Spring Yard Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_SYZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	Resize_SYZx(pc,d0.w),d0
		jmp	Resize_SYZx(pc,d0.w)
; ===========================================================================
Resize_SYZx:	dc.w Resize_SYZ1-Resize_SYZx
		dc.w Resize_SYZ2-Resize_SYZx
		dc.w Resize_SYZ1-Resize_SYZx
; ===========================================================================

Resize_SYZ1:
		rts	
; ===========================================================================

Resize_SYZ2:
		move.w	#$520,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$25A0,(Camera_X_Pos).w
		bcs.s	locret_71A2
		move.w	#$420,(Target_Camera_Max_Y_Pos).w
		cmpi.w	#$4D0,(Object_Space_1+$C).w
		bcs.s	locret_71A2
		move.w	#$520,(Target_Camera_Max_Y_Pos).w

locret_71A2:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Scrap	Brain Zone dynamic screen resizing
; ---------------------------------------------------------------------------

Resize_SBZ:				; XREF: Resize_Index
		moveq	#0,d0
		move.b	(Current_Act).w,d0
		add.w	d0,d0
		move.w	Resize_SBZx(pc,d0.w),d0
		jmp	Resize_SBZx(pc,d0.w)
; ===========================================================================
Resize_SBZx:	dc.w Resize_SBZ1-Resize_SBZx
		dc.w Resize_SBZ2-Resize_SBZx
		dc.w Resize_FZ-Resize_SBZx
; ===========================================================================

Resize_SBZ1:
		rts	
; ===========================================================================

Resize_SBZ2:
		rts	
; ===========================================================================

Resize_FZ:
		cmpi.w	#$2650,(Camera_X_Pos).w
		bcs.s	@End
		move.b	#$18,(Game_Mode).w 		; set screen mode to	$18 (Ending)
		move.w	#$600,(Current_Zone_And_Act).w 	; set level to 0600

@End:
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Ending sequence dynamic screen resizing (empty)
; ---------------------------------------------------------------------------

Resize_Ending:				; XREF: Resize_Index
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 11 - GHZ bridge
; ---------------------------------------------------------------------------

Obj11:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj11_Index(pc,d0.w),d1
		jmp	Obj11_Index(pc,d1.w)
; ===========================================================================
Obj11_Index:	dc.w Obj11_Main-Obj11_Index, Obj11_Action-Obj11_Index
		dc.w Obj11_Action2-Obj11_Index,	Obj11_Delete2-Obj11_Index
		dc.w Obj11_Delete2-Obj11_Index,	Obj11_Display2-Obj11_Index
; ===========================================================================

Obj11_Main:				; XREF: Obj11_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj11,4(a0)
		move.w	#$438E,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$80,$19(a0)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		move.b	0(a0),d4	; copy object number ($11) to d4
		lea	$28(a0),a2	; copy bridge subtype to a2
		moveq	#0,d1
		move.b	(a2),d1		; copy a2 to d1
		move.b	#0,(a2)+
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		subq.b	#2,d1
		bcs.s	Obj11_Action

Obj11_MakeBdg:
		bsr.w	SingleObjLoad
		bne.s	Obj11_Action
		addq.b	#1,$28(a0)
		cmp.w	8(a0),d3
		bne.s	loc_73B8
		addi.w	#$10,d3
		move.w	d2,$C(a0)
		move.w	d2,$3C(a0)
		move.w	a0,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		addq.b	#1,$28(a0)

loc_73B8:				; XREF: ROM:00007398j
		move.w	a1,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#$A,$24(a1)
		move.b	d4,0(a1)	; load bridge object (d4 = $11)
		move.w	d2,$C(a1)
		move.w	d2,$3C(a1)
		move.w	d3,8(a1)
		move.l	#Map_obj11,4(a1)
		move.w	#$438E,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#8,$19(a1)
		addi.w	#$10,d3
		dbf	d1,Obj11_MakeBdg ; repeat d1 times (length of bridge)

Obj11_Action:				; XREF: Obj11_Index
		bsr.s	Obj11_Solid
		tst.b	$3E(a0)
		beq.s	Obj11_Display
		subq.b	#4,$3E(a0)
		bsr.w	Obj11_Bend

Obj11_Display:
		bsr.w	DisplaySprite
		bra.w	Obj11_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_Solid:				; XREF: Obj11_Action
		moveq	#0,d1
		move.b	$28(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		add.w	d2,d2
		lea	(Object_RAM).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	locret_751E
		cmp.w	d2,d0
		bcc.w	locret_751E
		bra.s	Platform2
; End of function Obj11_Solid

; ---------------------------------------------------------------------------
; Platform subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PlatformObject:
		lea	(Object_RAM).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	locret_751E
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	locret_751E

Platform2:
		move.w	$C(a0),d0
		subq.w	#8,d0

Platform3:
		move.w	$C(a1),d2
		move.b	$16(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi.w	locret_751E
		cmpi.w	#-$10,d0
		bcs.w	locret_751E
		tst.b	(No_Player_Physics_Flag).w
		bmi.w	locret_751E
		cmpi.b	#6,$24(a1)
		bcc.w	locret_751E
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,$C(a1)
		addq.b	#2,$24(a0)

loc_74AE:
		btst	#3,$22(a1)
		beq.s	loc_74DC
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a2
		bclr	#3,$22(a2)
		clr.b	$25(a2)
		cmpi.b	#4,$24(a2)
		bne.s	loc_74DC
		subq.b	#2,$24(a2)

loc_74DC:
		move.w	a0,d0
		subi.w	#Object_RAM,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,$26(a1)
		move.w	#0,$12(a1)
		move.w	$10(a1),$14(a1)
		btst	#1,$22(a1)
		beq.s	loc_7512
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	Sonic_ResetOnFloor
		movea.l	(sp)+,a0

loc_7512:
		bset	#3,$22(a1)
		bset	#3,$22(a0)

locret_751E:
		rts	
; End of function PlatformObject

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	SLZ seesaws)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject:				; XREF: Obj1A_Slope; Obj5E_Slope
		lea	(Object_RAM).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	locret_751E
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	locret_751E
		btst	#0,1(a0)
		beq.s	loc_754A
		not.w	d0
		add.w	d1,d0

loc_754A:
		lsr.w	#1,d0
		moveq	#0,d3
		move.b	(a2,d0.w),d3
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function SlopeObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj15_Solid:				; XREF: Obj15_SetSolid
		lea	(Object_RAM).w,a1
		tst.w	$12(a1)
		bmi.w	locret_751E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	locret_751E
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	locret_751E
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.w	Platform3
; End of function Obj15_Solid

; ===========================================================================

Obj11_Action2:				; XREF: Obj11_Index
		bsr.s	Obj11_WalkOff
		bsr.w	DisplaySprite
		bra.w	Obj11_ChkDel

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk off a bridge
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_WalkOff:				; XREF: Obj11_Action2
		moveq	#0,d1
		move.b	$28(a0),d1
		lsl.w	#3,d1
		move.w	d1,d2
		addq.w	#8,d1
		bsr.s	ExitPlatform2
		bcc.s	locret_75BE
		lsr.w	#4,d0
		move.b	d0,$3F(a0)
		move.b	$3E(a0),d0
		cmpi.b	#$40,d0
		beq.s	loc_75B6
		addq.b	#4,$3E(a0)

loc_75B6:
		bsr.w	Obj11_Bend
		bsr.w	Obj11_MoveSonic

locret_75BE:
		rts	
; End of function Obj11_WalkOff

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk or jump off	a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ExitPlatform:
		move.w	d1,d2

ExitPlatform2:
		add.w	d2,d2
		lea	(Object_RAM).w,a1
		btst	#1,$22(a1)
		bne.s	loc_75E0
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_75E0
		cmp.w	d2,d0
		bcs.s	locret_75F2

loc_75E0:
		bclr	#3,$22(a1)
		move.b	#2,$24(a0)
		bclr	#3,$22(a0)

locret_75F2:
		rts	
; End of function ExitPlatform


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_MoveSonic:			; XREF: Obj11_WalkOff
		moveq	#0,d0
		move.b	$3F(a0),d0
		move.b	$29(a0,d0.w),d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a2
		lea	(Object_RAM).w,a1
		move.w	$C(a2),d0
		subq.w	#8,d0
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)	; change Sonic's position on y-axis
		rts	
; End of function Obj11_MoveSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj11_Bend:				; XREF: Obj11_Action; Obj11_WalkOff
		move.b	$3E(a0),d0
		bsr.w	CalcSine
		move.w	d0,d4
		lea	(Obj11_BendData2).l,a4
		moveq	#0,d0
		move.b	$28(a0),d0
		lsl.w	#4,d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		move.w	d3,d2
		add.w	d0,d3
		moveq	#0,d5
		lea	(Obj11_BendData).l,a5
		move.b	(a5,d3.w),d5
		andi.w	#$F,d3
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		lea	$29(a0),a2

loc_765C:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		moveq	#0,d0
		move.b	(a3)+,d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a1),d0
		move.w	d0,$C(a1)
		dbf	d2,loc_765C
		moveq	#0,d0
		move.b	$28(a0),d0
		moveq	#0,d3
		move.b	$3F(a0),d3
		addq.b	#1,d3
		sub.b	d0,d3
		neg.b	d3
		bmi.s	locret_76CA
		move.w	d3,d2
		lsl.w	#4,d3
		lea	(a4,d3.w),a3
		adda.w	d2,a3
		subq.w	#1,d2
		bcs.s	locret_76CA

loc_76A4:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		moveq	#0,d0
		move.b	-(a3),d0
		addq.w	#1,d0
		mulu.w	d5,d0
		mulu.w	d4,d0
		swap	d0
		add.w	$3C(a1),d0
		move.w	d0,$C(a1)
		dbf	d2,loc_76A4

locret_76CA:
		rts	
; End of function Obj11_Bend

; ===========================================================================
; ---------------------------------------------------------------------------
; GHZ bridge-bending data
; (Defines how the bridge bends	when Sonic walks across	it)
; ---------------------------------------------------------------------------
Obj11_BendData:	incbin	data/bridge/ghzbend1.bin
		even
Obj11_BendData2:incbin	data/bridge/ghzbend2.bin
		even

; ===========================================================================

Obj11_ChkDel:				; XREF: Obj11_Display; Obj11_Action2
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj11_DelAll
		rts	
; ===========================================================================

Obj11_DelAll:				; XREF: Obj11_ChkDel
		moveq	#0,d2
		lea	$28(a0),a2	; load bridge length
		move.b	(a2)+,d2	; move bridge length to	d2
		subq.b	#1,d2		; subtract 1
		bcs.s	Obj11_Delete

Obj11_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		cmp.w	a0,d0
		beq.s	loc_791E
		bsr.w	DeleteObject2

loc_791E:
		dbf	d2,Obj11_DelLoop ; repeat d2 times (bridge length)

Obj11_Delete:
		bsr.w	DeleteObject
		rts	
; ===========================================================================

Obj11_Delete2:				; XREF: Obj11_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================

Obj11_Display2:				; XREF: Obj11_Index
		bsr.w	DisplaySprite
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	bridge
; ---------------------------------------------------------------------------
Map_obj11:
	include "mappings/sprite/obj11.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 15 - swinging platforms (GHZ, MZ, SLZ)
; ---------------------------------------------------------------------------

Obj15:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj15_Index(pc,d0.w),d1
		jmp	Obj15_Index(pc,d1.w)
; ===========================================================================
Obj15_Index:	dc.w Obj15_Main-Obj15_Index, Obj15_SetSolid-Obj15_Index
		dc.w Obj15_Action2-Obj15_Index,	Obj15_Delete-Obj15_Index
		dc.w Obj15_Delete-Obj15_Index, Obj15_Display-Obj15_Index
		dc.w Obj15_Action-Obj15_Index
; ===========================================================================

Obj15_Main:				; XREF: Obj15_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj15,4(a0) ; GHZ and MZ specific code
		move.w	#$4380,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$18,$19(a0)
		move.b	#8,$16(a0)
		move.w	$C(a0),$38(a0)
		move.w	8(a0),$3A(a0)
		cmpi.b	#3,(Current_Zone).w ; check if level is SLZ
		bne.s	Obj15_NotSLZ
		move.l	#Map_obj15a,4(a0) ; SLZ	specific code
		move.w	#$43DC,2(a0)
		move.b	#$20,$19(a0)
		move.b	#$10,$16(a0)
		move.b	#$99,$20(a0)

Obj15_NotSLZ:
		move.b	0(a0),d4
		moveq	#0,d1
		lea	$28(a0),a2	; move chain length to a2
		move.b	(a2),d1		; move a2 to d1
		move.w	d1,-(sp)
		andi.w	#$F,d1
		move.b	#0,(a2)+
		move.w	d1,d3
		lsl.w	#4,d3
		addq.b	#8,d3
		move.b	d3,$3C(a0)
		subq.b	#8,d3
		tst.b	$1A(a0)
		beq.s	Obj15_MakeChain
		addq.b	#8,d3
		subq.w	#1,d1

Obj15_MakeChain:
		bsr.w	SingleObjLoad
		bne.s	loc_7A92
		addq.b	#1,$28(a0)
		move.w	a1,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#$A,$24(a1)
		move.b	d4,0(a1)	; load swinging	object
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		bclr	#6,2(a1)
		move.b	#4,1(a1)
		move.b	#4,$18(a1)
		move.b	#8,$19(a1)
		move.b	#1,$1A(a1)
		move.b	d3,$3C(a1)
		subi.b	#$10,d3
		bcc.s	loc_7A8E
		move.b	#2,$1A(a1)
		move.b	#3,$18(a1)
		bset	#6,2(a1)

loc_7A8E:
		dbf	d1,Obj15_MakeChain ; repeat d1 times (chain length)

loc_7A92:
		move.w	a0,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.w	#$4080,$26(a0)
		move.w	#-$200,$3E(a0)
		move.w	(sp)+,d1
		btst	#4,d1		; is object type $8X ?
		beq.s	Obj15_SetSolid	; if not, branch
		move.l	#Map_obj48,4(a0) ; use GHZ ball	mappings
		move.w	#$43AA,2(a0)
		move.b	#1,$1A(a0)
		move.b	#2,$18(a0)
		move.b	#$81,$20(a0)	; make object hurt when	touched

Obj15_SetSolid:				; XREF: Obj15_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		moveq	#0,d3
		move.b	$16(a0),d3
		bsr.w	Obj15_Solid

Obj15_Action:				; XREF: Obj15_Index
		bsr.w	Obj15_Move
		bsr.w	DisplaySprite
		bra.w	Obj15_ChkDel
; ===========================================================================

Obj15_Action2:				; XREF: Obj15_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		bsr.w	ExitPlatform
		move.w	8(a0),-(sp)
		bsr.w	Obj15_Move
		move.w	(sp)+,d2
		moveq	#0,d3
		move.b	$16(a0),d3
		addq.b	#1,d3
		bsr.w	MvSonicOnPtfm
		bsr.w	DisplaySprite
		bra.w	Obj15_ChkDel

		rts

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm:
		lea	(Object_RAM).w,a1
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.s	MvSonic2
; End of function MvSonicOnPtfm

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's position with a platform
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MvSonicOnPtfm2:
		lea	(Object_RAM).w,a1
		move.w	$C(a0),d0
		subi.w	#9,d0

MvSonic2:
		tst.b	(No_Player_Physics_Flag).w
		bmi.s	locret_7B62
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	locret_7B62
		tst.w	(Debug_Placement_Mode).w
		bne.s	locret_7B62
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d2
		sub.w	d2,8(a1)

locret_7B62:
		rts	
; End of function MvSonicOnPtfm2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj15_Move:				; XREF: Obj15_Action; Obj15_Action2
		move.b	(Oscillation_Data+$18).w,d0
		move.w	#$80,d1
		btst	#0,$22(a0)
		beq.s	loc_7B78
		neg.w	d0
		add.w	d1,d0

loc_7B78:
		bra.s	Obj15_Move2
; End of function Obj15_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj48_Move:				; XREF: Obj48_Display2
		tst.b	$3D(a0)
		bne.s	loc_7B9C
		move.w	$3E(a0),d0
		addq.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,$26(a0)
		cmpi.w	#$200,d0
		bne.s	loc_7BB6
		move.b	#1,$3D(a0)
		bra.s	loc_7BB6
; ===========================================================================

loc_7B9C:
		move.w	$3E(a0),d0
		subq.w	#8,d0
		move.w	d0,$3E(a0)
		add.w	d0,$26(a0)
		cmpi.w	#-$200,d0
		bne.s	loc_7BB6
		move.b	#0,$3D(a0)

loc_7BB6:
		move.b	$26(a0),d0
; End of function Obj48_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj15_Move2:				; XREF: Obj15_Move; Obj48_Display
		bsr.w	CalcSine
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		lea	$28(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_7BCE:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#Object_RAM,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	$3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a1)
		move.w	d5,8(a1)
		dbf	d6,loc_7BCE
		rts	
; End of function Obj15_Move2

; ===========================================================================

Obj15_ChkDel:				; XREF: Obj15_Action; Obj15_Action2
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj15_DelAll
		rts	
; ===========================================================================

Obj15_DelAll:				; XREF: Obj15_ChkDel
		moveq	#0,d2
		lea	$28(a0),a2
		move.b	(a2)+,d2

Obj15_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,Obj15_DelLoop ; repeat for length of	chain
		rts	
; ===========================================================================

Obj15_Delete:				; XREF: Obj15_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================

Obj15_Display:				; XREF: Obj15_Index
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	and MZ swinging	platforms
; ---------------------------------------------------------------------------
Map_obj15:
	include "mappings/sprite/obj15ghz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - SLZ	swinging platforms
; ---------------------------------------------------------------------------
Map_obj15a:
	include "mappings/sprite/obj15slz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)
; ---------------------------------------------------------------------------

Obj17:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj17_Index(pc,d0.w),d1
		jmp	Obj17_Index(pc,d1.w)
; ===========================================================================
Obj17_Index:	dc.w Obj17_Main-Obj17_Index
		dc.w Obj17_Action-Obj17_Index
		dc.w Obj17_Action-Obj17_Index
		dc.w Obj17_Delete-Obj17_Index
		dc.w Obj17_Display-Obj17_Index
; ===========================================================================

Obj17_Main:				; XREF: Obj17_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj17,4(a0)
		move.w	#$4398,2(a0)
		move.b	#7,$22(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$19(a0)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		move.b	0(a0),d4
		lea	$28(a0),a2	; move helix length to a2
		moveq	#0,d1
		move.b	(a2),d1		; move a2 to d1
		move.b	#0,(a2)+
		move.w	d1,d0
		lsr.w	#1,d0
		lsl.w	#4,d0
		sub.w	d0,d3
		subq.b	#2,d1
		bcs.s	Obj17_Action
		moveq	#0,d6

Obj17_MakeHelix:
		bsr.w	SingleObjLoad
		bne.s	Obj17_Action
		addq.b	#1,$28(a0)
		move.w	a1,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#8,$24(a1)
		move.b	d4,0(a1)
		move.w	d2,$C(a1)
		move.w	d3,8(a1)
		move.l	4(a0),4(a1)
		move.w	#$4398,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#8,$19(a1)
		move.b	d6,$3E(a1)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		cmp.w	8(a0),d3
		bne.s	loc_7D78
		move.b	d6,$3E(a0)
		addq.b	#1,d6
		andi.b	#7,d6
		addi.w	#$10,d3
		addq.b	#1,$28(a0)

loc_7D78:
		dbf	d1,Obj17_MakeHelix ; repeat d1 times (helix length)

Obj17_Action:				; XREF: Obj17_Index
		bsr.w	Obj17_RotateSpikes
		bsr.w	DisplaySprite
		bra.w	Obj17_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj17_RotateSpikes:			; XREF: Obj17_Action; Obj17_Display
		move.b	(Logspike_Anim_Frame).w,d0
		move.b	#0,$20(a0)	; make object harmless
		add.b	$3E(a0),d0
		andi.b	#7,d0
		move.b	d0,$1A(a0)	; change current frame
		bne.s	locret_7DA6
		move.b	#$84,$20(a0)	; make object harmful

locret_7DA6:
		rts	
; End of function Obj17_RotateSpikes

; ===========================================================================

Obj17_ChkDel:				; XREF: Obj17_Action
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj17_DelAll
		rts	
; ===========================================================================

Obj17_DelAll:				; XREF: Obj17_ChkDel
		moveq	#0,d2
		lea	$28(a0),a2	; move helix length to a2
		move.b	(a2)+,d2	; move a2 to d2
		subq.b	#2,d2
		bcs.s	Obj17_Delete

Obj17_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2	; delete object
		dbf	d2,Obj17_DelLoop ; repeat d2 times (helix length)

Obj17_Delete:				; XREF: Obj17_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================

Obj17_Display:				; XREF: Obj17_Index
		bsr.w	Obj17_RotateSpikes
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - helix of spikes on a pole (GHZ)
; ---------------------------------------------------------------------------
Map_obj17:
	include "mappings/sprite/obj17.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 18 - platforms	(GHZ, SYZ, SLZ)
; ---------------------------------------------------------------------------

Obj18:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj18_Index(pc,d0.w),d1
		jmp	Obj18_Index(pc,d1.w)
; ===========================================================================
Obj18_Index:	dc.w Obj18_Main-Obj18_Index
		dc.w Obj18_Solid-Obj18_Index
		dc.w Obj18_Action2-Obj18_Index
		dc.w Obj18_Delete-Obj18_Index
		dc.w Obj18_Action-Obj18_Index
; ===========================================================================

Obj18_Main:				; XREF: Obj18_Index
		addq.b	#2,$24(a0)
		move.w	#$4000,2(a0)
		move.l	#Map_obj18,4(a0)
		move.b	#$20,$19(a0)
		cmpi.b	#4,(Current_Zone).w ; check if level is SYZ
		bne.s	Obj18_NotSYZ
		move.l	#Map_obj18a,4(a0) ; SYZ	specific code
		move.b	#$20,$19(a0)

Obj18_NotSYZ:
		cmpi.b	#3,(Current_Zone).w ; check if level is SLZ
		bne.s	Obj18_NotSLZ
		move.l	#Map_obj18b,4(a0) ; SLZ	specific code
		move.b	#$20,$19(a0)
		move.w	#$4000,2(a0)
		move.b	#3,$28(a0)

Obj18_NotSLZ:
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.w	$C(a0),$2C(a0)
		move.w	$C(a0),$34(a0)
		move.w	8(a0),$32(a0)
		move.w	#$80,$26(a0)
		moveq	#0,d1
		move.b	$28(a0),d0
		cmpi.b	#$A,d0		; is object type $A (large platform)?
		bne.s	Obj18_SetFrame	; if not, branch
		addq.b	#1,d1		; use frame #1
		move.b	#$20,$19(a0)	; set width

Obj18_SetFrame:
		move.b	d1,$1A(a0)	; set frame to d1

Obj18_Solid:				; XREF: Obj18_Index
		tst.b	$38(a0)
		beq.s	loc_7EE0
		subq.b	#4,$38(a0)

loc_7EE0:
		moveq	#0,d1
		move.b	$19(a0),d1
		bsr.w	PlatformObject

Obj18_Action:				; XREF: Obj18_Index
		bsr.w	Obj18_Move
		bsr.w	Obj18_Nudge
		bsr.w	DisplaySprite
		bra.w	Obj18_ChkDel
; ===========================================================================

Obj18_Action2:				; XREF: Obj18_Index
		cmpi.b	#$40,$38(a0)
		beq.s	loc_7F06
		addq.b	#4,$38(a0)

loc_7F06:
		moveq	#0,d1
		move.b	$19(a0),d1
		bsr.w	ExitPlatform
		move.w	8(a0),-(sp)
		bsr.w	Obj18_Move
		bsr.w	Obj18_Nudge
		move.w	(sp)+,d2
		bsr.w	MvSonicOnPtfm2
		bsr.w	DisplaySprite
		bra.w	Obj18_ChkDel

		rts

; ---------------------------------------------------------------------------
; Subroutine to	move platform slightly when you	stand on it
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj18_Nudge:				; XREF: Obj18_Action; Obj18_Action2
		move.b	$38(a0),d0
		bsr.w	CalcSine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	$2C(a0),d0
		move.w	d0,$C(a0)
		rts	
; End of function Obj18_Nudge

; ---------------------------------------------------------------------------
; Subroutine to	move platforms
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj18_Move:				; XREF: Obj18_Action; Obj18_Action2
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj18_TypeIndex(pc,d0.w),d1
		jmp	Obj18_TypeIndex(pc,d1.w)
; End of function Obj18_Move

; ===========================================================================
Obj18_TypeIndex:dc.w Obj18_Type00-Obj18_TypeIndex, Obj18_Type01-Obj18_TypeIndex
		dc.w Obj18_Type02-Obj18_TypeIndex, Obj18_Type03-Obj18_TypeIndex
		dc.w Obj18_Type04-Obj18_TypeIndex, Obj18_Type05-Obj18_TypeIndex
		dc.w Obj18_Type06-Obj18_TypeIndex, Obj18_Type07-Obj18_TypeIndex
		dc.w Obj18_Type08-Obj18_TypeIndex, Obj18_Type00-Obj18_TypeIndex
		dc.w Obj18_Type0A-Obj18_TypeIndex, Obj18_Type0B-Obj18_TypeIndex
		dc.w Obj18_Type0C-Obj18_TypeIndex
; ===========================================================================

Obj18_Type00:
		rts			; platform 00 doesn't move
; ===========================================================================

Obj18_Type05:
		move.w	$32(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$40,d1
		bra.s	Obj18_01_Move
; ===========================================================================

Obj18_Type01:
		move.w	$32(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		subi.b	#$40,d1

Obj18_01_Move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,8(a0)	; change position on x-axis
		bra.w	Obj18_ChgMotion
; ===========================================================================

Obj18_Type0C:
		move.w	$34(a0),d0
		move.b	(Oscillation_Data+$C).w,d1 ; load	platform-motion	variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$30,d1
		bra.s	Obj18_02_Move
; ===========================================================================

Obj18_Type0B:
		move.w	$34(a0),d0
		move.b	(Oscillation_Data+$C).w,d1 ; load	platform-motion	variable
		subi.b	#$30,d1
		bra.s	Obj18_02_Move
; ===========================================================================

Obj18_Type06:
		move.w	$34(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		neg.b	d1		; reverse platform-motion
		addi.b	#$40,d1
		bra.s	Obj18_02_Move
; ===========================================================================

Obj18_Type02:
		move.w	$34(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		subi.b	#$40,d1

Obj18_02_Move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,$2C(a0)	; change position on y-axis
		bra.w	Obj18_ChgMotion
; ===========================================================================

Obj18_Type03:
		tst.w	$3A(a0)		; is time delay	set?
		bne.s	Obj18_03_Wait	; if yes, branch
		btst	#3,$22(a0)	; is Sonic standing on the platform?
		beq.s	Obj18_03_NoMove	; if not, branch
		move.w	#30,$3A(a0)	; set time delay to 0.5	seconds

Obj18_03_NoMove:
		rts	
; ===========================================================================

Obj18_03_Wait:
		subq.w	#1,$3A(a0)	; subtract 1 from time
		bne.s	Obj18_03_NoMove	; if time is > 0, branch
		move.w	#32,$3A(a0)
		addq.b	#1,$28(a0)	; change to type 04 (falling)
		rts	
; ===========================================================================

Obj18_Type04:
		tst.w	$3A(a0)
		beq.s	loc_8048
		subq.w	#1,$3A(a0)
		bne.s	loc_8048
		btst	#3,$22(a0)
		beq.s	loc_8042
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		move.w	$12(a0),$12(a1)

loc_8042:
		move.b	#8,$24(a0)

loc_8048:
		move.l	$2C(a0),d3
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d3,$2C(a0)
		addi.w	#$38,$12(a0)
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$2C(a0),d0
		bcc.s	locret_8074
		move.b	#6,$24(a0)

locret_8074:
		rts	
; ===========================================================================

Obj18_Type07:
		tst.w	$3A(a0)		; is time delay	set?
		bne.s	Obj18_07_Wait	; if yes, branch
		lea	(Switch_Statuses).w,a2 ; load	switch statuses
		moveq	#0,d0
		move.b	$28(a0),d0	; move object type ($x7) to d0
		lsr.w	#4,d0		; divide d0 by 8, round	down
		tst.b	(a2,d0.w)	; has switch no. d0 been pressed?
		beq.s	Obj18_07_NoMove	; if not, branch
		move.w	#60,$3A(a0)	; set time delay to 1 second

Obj18_07_NoMove:
		rts	
; ===========================================================================

Obj18_07_Wait:
		subq.w	#1,$3A(a0)	; subtract 1 from time delay
		bne.s	Obj18_07_NoMove	; if time is > 0, branch
		addq.b	#1,$28(a0)	; change to type 08
		rts	
; ===========================================================================

Obj18_Type08:
		subq.w	#2,$2C(a0)	; move platform	up
		move.w	$34(a0),d0
		subi.w	#$200,d0
		cmp.w	$2C(a0),d0	; has platform moved $200 pixels?
		bne.s	Obj18_08_NoStop	; if not, branch
		clr.b	$28(a0)		; change to type 00 (stop moving)

Obj18_08_NoStop:
		rts	
; ===========================================================================

Obj18_Type0A:
		move.w	$34(a0),d0
		move.b	$26(a0),d1	; load platform-motion variable
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,$2C(a0)	; change position on y-axis

Obj18_ChgMotion:
		move.b	(Oscillation_Data+$18).w,$26(a0) ;	update platform-movement variable
		rts	
; ===========================================================================

Obj18_ChkDel:				; XREF: Obj18_Action; Obj18_Action2
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj18_Delete
		rts	
; ===========================================================================

Obj18_Delete:				; XREF: Obj18_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - unused
; ---------------------------------------------------------------------------
Map_obj18x:
	include "mappings/sprite/obj18x.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	platforms
; ---------------------------------------------------------------------------
Map_obj18:
	include "mappings/sprite/obj18ghz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - SYZ	platforms
; ---------------------------------------------------------------------------
Map_obj18a:
	include "mappings/sprite/obj18syz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - SLZ	platforms
; ---------------------------------------------------------------------------
Map_obj18b:
	include "mappings/sprite/obj18slz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 19 - blank
; ---------------------------------------------------------------------------

Obj19:					; XREF: Obj_Index
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - swinging ball on a chain from GHZ boss
; ---------------------------------------------------------------------------
Map_obj48:
	include "mappings/sprite/obj48.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1A - GHZ collapsing ledge
; ---------------------------------------------------------------------------

Obj1A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1A_Index(pc,d0.w),d1
		jmp	Obj1A_Index(pc,d1.w)
; ===========================================================================
Obj1A_Index:	dc.w Obj1A_Main-Obj1A_Index, Obj1A_ChkTouch-Obj1A_Index
		dc.w Obj1A_Touch-Obj1A_Index, Obj1A_Display-Obj1A_Index
		dc.w Obj1A_Delete-Obj1A_Index, Obj1A_WalkOff-Obj1A_Index
; ===========================================================================

Obj1A_Main:				; XREF: Obj1A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1A,4(a0)
		move.w	#$4000,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#7,$38(a0)	; set time delay for collapse
		move.b	#$64,$19(a0)
		move.b	$28(a0),$1A(a0)
		move.b	#$38,$16(a0)
		bset	#4,1(a0)

Obj1A_ChkTouch:				; XREF: Obj1A_Index
		tst.b	$3A(a0)		; has Sonic touched the	platform?
		beq.s	Obj1A_Slope	; if not, branch
		tst.b	$38(a0)		; has time reached zero?
		beq.w	Obj1A_Collapse	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time

Obj1A_Slope:
		move.w	#$30,d1
		lea	(Obj1A_SlopeData).l,a2
		bsr.w	SlopeObject
		bra.w	MarkObjGone
; ===========================================================================

Obj1A_Touch:				; XREF: Obj1A_Index
		tst.b	$38(a0)
		beq.w	loc_847A
		move.b	#1,$3A(a0)	; set object as	"touched"
		subq.b	#1,$38(a0)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj1A_WalkOff:				; XREF: Obj1A_Index
		move.w	#$30,d1
		bsr.w	ExitPlatform
		move.w	#$30,d1
		lea	(Obj1A_SlopeData).l,a2
		move.w	8(a0),d2
		bsr.w	SlopeObject2
		bra.w	MarkObjGone
; End of function Obj1A_WalkOff

; ===========================================================================

Obj1A_Display:				; XREF: Obj1A_Index
		tst.b	$38(a0)		; has time delay reached zero?
		beq.s	Obj1A_TimeZero	; if yes, branch
		tst.b	$3A(a0)		; has Sonic touched the	object?
		bne.w	loc_82D0	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

loc_82D0:				; XREF: Obj1A_Display
		subq.b	#1,$38(a0)
		bsr.w	Obj1A_WalkOff
		lea	(Object_RAM).w,a1
		btst	#3,$22(a1)
		beq.s	loc_82FC
		tst.b	$38(a0)
		bne.s	locret_8308
		bclr	#3,$22(a1)
		bclr	#5,$22(a1)
		move.b	#1,$1D(a1)

loc_82FC:
		move.b	#0,$3A(a0)
		move.b	#6,$24(a0)	; run "Obj1A_Display" routine

locret_8308:
		rts	
; ===========================================================================

Obj1A_TimeZero:				; XREF: Obj1A_Display
		bsr.w	ObjectMoveAndFall
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.s	Obj1A_Delete
		rts	
; ===========================================================================

Obj1A_Delete:				; XREF: Obj1A_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 53 - collapsing floors	(MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

Obj53:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj53_Index(pc,d0.w),d1
		jmp	Obj53_Index(pc,d1.w)
; ===========================================================================
Obj53_Index:	dc.w Obj53_Main-Obj53_Index, Obj53_ChkTouch-Obj53_Index
		dc.w Obj53_Touch-Obj53_Index, Obj53_Display-Obj53_Index
		dc.w Obj53_Delete-Obj53_Index, Obj53_WalkOff-Obj53_Index
; ===========================================================================

Obj53_Main:				; XREF: Obj53_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj53,4(a0)
		move.w	#$42B8,2(a0)
		cmpi.b	#3,(Current_Zone).w ; check if level is SLZ
		bne.s	Obj53_NotSLZ
		move.w	#$44E0,2(a0)	; SLZ specific code
		addq.b	#2,$1A(a0)

Obj53_NotSLZ:
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#7,$38(a0)
		move.b	#$44,$19(a0)

Obj53_ChkTouch:				; XREF: Obj53_Index
		tst.b	$3A(a0)		; has Sonic touched the	object?
		beq.s	Obj53_Solid	; if not, branch
		tst.b	$38(a0)		; has time delay reached zero?
		beq.w	Obj53_Collapse	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time

Obj53_Solid:
		move.w	#$20,d1
		bsr.w	PlatformObject
		tst.b	$28(a0)
		bpl.s	Obj53_MarkAsGone
		btst	#3,$22(a1)
		beq.s	Obj53_MarkAsGone
		bclr	#0,1(a0)
		move.w	8(a1),d0
		sub.w	8(a0),d0
		bcc.s	Obj53_MarkAsGone
		bset	#0,1(a0)

Obj53_MarkAsGone:
		bra.w	MarkObjGone
; ===========================================================================

Obj53_Touch:				; XREF: Obj53_Index
		tst.b	$38(a0)
		beq.w	loc_8458
		move.b	#1,$3A(a0)	; set object as	"touched"
		subq.b	#1,$38(a0)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj53_WalkOff:				; XREF: Obj53_Index
		move.w	#$20,d1
		bsr.w	ExitPlatform
		move.w	8(a0),d2
		bsr.w	MvSonicOnPtfm2
		bra.w	MarkObjGone
; End of function Obj53_WalkOff

; ===========================================================================

Obj53_Display:				; XREF: Obj53_Index
		tst.b	$38(a0)		; has time delay reached zero?
		beq.s	Obj53_TimeZero	; if yes, branch
		tst.b	$3A(a0)		; has Sonic touched the	object?
		bne.w	loc_8402	; if yes, branch
		subq.b	#1,$38(a0)	; subtract 1 from time
		bra.w	DisplaySprite
; ===========================================================================

loc_8402:
		subq.b	#1,$38(a0)
		bsr.w	Obj53_WalkOff
		lea	(Object_RAM).w,a1
		btst	#3,$22(a1)
		beq.s	loc_842E
		tst.b	$38(a0)
		bne.s	locret_843A
		bclr	#3,$22(a1)
		bclr	#5,$22(a1)
		move.b	#1,$1D(a1)

loc_842E:
		move.b	#0,$3A(a0)
		move.b	#6,$24(a0)	; run "Obj53_Display" routine

locret_843A:
		rts	
; ===========================================================================

Obj53_TimeZero:				; XREF: Obj53_Display
		bsr.w	ObjectMoveAndFall
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.s	Obj53_Delete
		rts	
; ===========================================================================

Obj53_Delete:				; XREF: Obj53_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================

Obj53_Collapse:				; XREF: Obj53_ChkTouch
		move.b	#0,$3A(a0)

loc_8458:				; XREF: Obj53_Touch
		lea	(Obj53_Data2).l,a4
		btst	#0,$28(a0)
		beq.s	loc_846C
		lea	(Obj53_Data3).l,a4

loc_846C:
		moveq	#7,d1
		addq.b	#1,$1A(a0)
		bra.s	loc_8486
; ===========================================================================

Obj1A_Collapse:				; XREF: Obj1A_ChkTouch
		move.b	#0,$3A(a0)

loc_847A:				; XREF: Obj1A_Touch
		lea	(Obj53_Data1).l,a4
		moveq	#$18,d1
		addq.b	#2,$1A(a0)

loc_8486:				; XREF: Obj53_Collapse
		moveq	#0,d0
		move.b	$1A(a0),d0
		add.w	d0,d0
		movea.l	4(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,1(a0)
		move.b	0(a0),d4
		move.b	1(a0),d5
		movea.l	a0,a1
		bra.s	loc_84B2
; ===========================================================================

loc_84AA:
		bsr.w	SingleObjLoad
		bne.s	loc_84F2
		addq.w	#5,a3

loc_84B2:
		move.b	#6,$24(a1)
		move.b	d4,0(a1)
		move.l	a3,4(a1)
		move.b	d5,1(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	2(a0),2(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.b	(a4)+,$38(a1)
		cmpa.l	a0,a1
		bcc.s	loc_84EE
		bsr.w	DisplaySprite2

loc_84EE:
		dbf	d1,loc_84AA

loc_84F2:
		bsr.w	DisplaySprite
		move.w	#SndID_Collapse,d0
		jmp	(PlaySound_Special).l ;	play collapsing	sound
; ===========================================================================
; ---------------------------------------------------------------------------
; Disintegration data for collapsing ledges (MZ, SLZ, SBZ)
; ---------------------------------------------------------------------------
Obj53_Data1:	dc.b $1C, $18, $14, $10, $1A, $16, $12,	$E, $A,	6, $18,	$14, $10, $C, 8, 4
		dc.b $16, $12, $E, $A, 6, 2, $14, $10, $C, 0
Obj53_Data2:	dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2
Obj53_Data3:	dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2

; ---------------------------------------------------------------------------
; Sloped platform subroutine (GHZ collapsing ledges and	MZ platforms)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SlopeObject2:				; XREF: Obj1A_WalkOff; et al
		lea	(Object_RAM).w,a1
		btst	#3,$22(a1)
		beq.s	locret_856E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,1(a0)
		beq.s	loc_854E
		not.w	d0
		add.w	d1,d0

loc_854E:
		moveq	#0,d1
		move.b	(a2,d0.w),d1
		move.w	$C(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d2
		sub.w	d2,8(a1)

locret_856E:
		rts	
; End of function SlopeObject2

; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for GHZ collapsing ledge
; ---------------------------------------------------------------------------
Obj1A_SlopeData:
		incbin	data/ledge_GHZ/ghzledge.bin
		even

; ---------------------------------------------------------------------------
; Sprite mappings - GHZ	collapsing ledge
; ---------------------------------------------------------------------------
Map_obj1A:
	include "mappings/sprite/obj1A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - collapsing floors (MZ, SLZ,	SBZ)
; ---------------------------------------------------------------------------
Map_obj53:
	include "mappings/sprite/obj53.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, SLZ lava thrower)
; ---------------------------------------------------------------------------

Obj1C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1C_Index(pc,d0.w),d1
		jmp	Obj1C_Index(pc,d1.w)
; ===========================================================================
Obj1C_Index:	dc.w Obj1C_Main-Obj1C_Index
		dc.w Obj1C_ChkDel-Obj1C_Index
; ===========================================================================

Obj1C_Main:				; XREF: Obj1C_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; copy object type to d0
		mulu.w	#$A,d0		; multiply by $A
		lea	Obj1C_Var(pc,d0.w),a1
		move.l	(a1)+,4(a0)
		move.w	(a1)+,2(a0)
		ori.b	#4,1(a0)
		move.b	(a1)+,$1A(a0)
		move.b	(a1)+,$19(a0)
		move.b	(a1)+,$18(a0)
		move.b	(a1)+,$20(a0)

Obj1C_ChkDel:				; XREF: Obj1C_Index
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Variables for	object $1C are stored in an array
; ---------------------------------------------------------------------------
Obj1C_Var:	dc.l Map_obj1C		; mappings address
		dc.w $44D8		; VRAM setting
		dc.b 0,	8, 2, 0		; frame, width,	priority, collision response
		dc.l Map_obj1C
		dc.w $44D8
		dc.b 0,	8, 2, 0
		dc.l Map_obj1C
		dc.w $44D8
		dc.b 0,	8, 2, 0
		dc.l Map_obj11
		dc.w $438E
		dc.b 1,	$10, 1,	0
; ---------------------------------------------------------------------------
; Sprite mappings - SLZ	lava thrower
; ---------------------------------------------------------------------------
Map_obj1C:
	include "mappings/sprite/obj1C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1D - switch that activates when Sonic touches it
; (this	is not used anywhere in	the game)
; ---------------------------------------------------------------------------

Obj1D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1D_Index(pc,d0.w),d1
		jmp	Obj1D_Index(pc,d1.w)
; ===========================================================================
Obj1D_Index:	dc.w Obj1D_Main-Obj1D_Index
		dc.w Obj1D_Action-Obj1D_Index
		dc.w Obj1D_Delete-Obj1D_Index
; ===========================================================================

Obj1D_Main:				; XREF: Obj1D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1D,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.w	$C(a0),$30(a0)	; save position	on y-axis
		move.b	#$10,$19(a0)
		move.b	#5,$18(a0)

Obj1D_Action:				; XREF: Obj1D_Index
		move.w	$30(a0),$C(a0)	; restore position on y-axis
		move.w	#$10,d1
		bsr.w	Obj1D_ChkTouch
		beq.s	Obj1D_ChkDel
		addq.w	#2,$C(a0)	; move object 2	pixels
		moveq	#1,d0
		move.w	d0,(Switch_Statuses).w ; set switch 0	as "pressed"

Obj1D_ChkDel:
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj1D_Delete
		rts	
; ===========================================================================

Obj1D_Delete:				; XREF: Obj1D_Index
		bsr.w	DeleteObject
		rts	
; ---------------------------------------------------------------------------
; Subroutine to	check if Sonic touches the object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj1D_ChkTouch:				; XREF: Obj1D_Action
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_8918
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	loc_8918
		move.w	$C(a1),d2
		move.b	$16(a1),d1
		ext.w	d1
		add.w	d2,d1
		move.w	$C(a0),d0
		subi.w	#$10,d0
		sub.w	d1,d0
		bhi.s	loc_8918
		cmpi.w	#-$10,d0
		bcs.s	loc_8918
		moveq	#-1,d0
		rts	
; ===========================================================================

loc_8918:
		moveq	#0,d0
		rts	
; End of function Obj1D_ChkTouch

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - object 1D
; ---------------------------------------------------------------------------
Map_obj1D:
	include "mappings/sprite/obj1D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2A - Unused
; ---------------------------------------------------------------------------

Obj2A:					; XREF: Obj_Index
		rts

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall:			; XREF: Obj44_Solid
		bsr.w	Obj44_SolidWall2
		beq.s	loc_8AA8
		bmi.w	loc_8AC4
		tst.w	d0
		beq.w	loc_8A92
		bmi.s	loc_8A7C
		tst.w	$10(a1)
		bmi.s	loc_8A92
		bra.s	loc_8A82
; ===========================================================================

loc_8A7C:
		tst.w	$10(a1)
		bpl.s	loc_8A92

loc_8A82:
		sub.w	d0,8(a1)
		move.w	#0,$14(a1)
		move.w	#0,$10(a1)

loc_8A92:
		btst	#1,$22(a1)
		bne.s	loc_8AB6
		bset	#5,$22(a1)
		bset	#5,$22(a0)
		rts	
; ===========================================================================

loc_8AA8:
		btst	#5,$22(a0)
		beq.s	locret_8AC2
		move.w	#1,$1C(a1)

loc_8AB6:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)

locret_8AC2:
		rts	
; ===========================================================================

loc_8AC4:
		tst.w	$12(a1)
		bpl.s	locret_8AD8
		tst.w	d3
		bpl.s	locret_8AD8
		sub.w	d3,$C(a1)
		move.w	#0,$12(a1)

locret_8AD8:
		rts	
; End of function Obj44_SolidWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj44_SolidWall2:			; XREF: Obj44_SolidWall
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_8B48
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_8B48
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		add.w	d2,d3
		bmi.s	loc_8B48
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.s	loc_8B48
		tst.b	(No_Player_Physics_Flag).w
		bmi.s	loc_8B48
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	loc_8B48
		tst.w	(Debug_Placement_Mode).w
		bne.s	loc_8B48
		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_8B30
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_8B30:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_8B3C
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_8B3C:
		cmp.w	d1,d5
		bhi.s	loc_8B44
		moveq	#1,d4
		rts	
; ===========================================================================

loc_8B44:
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_8B48:
		moveq	#0,d4
		rts	
; End of function Obj44_SolidWall2

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1E - Ball Hog enemy (SBZ)
; ---------------------------------------------------------------------------

Obj1E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1E_Index(pc,d0.w),d1
		jmp	Obj1E_Index(pc,d1.w)
; ===========================================================================
Obj1E_Index:	dc.w Obj1E_Main-Obj1E_Index
		dc.w Obj1E_Action-Obj1E_Index
; ===========================================================================

Obj1E_Main:				; XREF: Obj1E_Index
		move.b	#$13,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj1E,4(a0)
		move.w	#$2302,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#5,$20(a0)
		move.b	#$C,$19(a0)
		bsr.w	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_8BAC
		add.w	d1,$C(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)

locret_8BAC:
		rts	
; ===========================================================================

Obj1E_Action:				; XREF: Obj1E_Index
		lea	(Ani_obj1E).l,a1
		bsr.w	AnimateSprite
		cmpi.b	#1,$1A(a0)	; is final frame (01) displayed?
		bne.s	Obj1E_SetBall	; if not, branch
		tst.b	$32(a0)		; is it	set to launch cannonball?
		beq.s	Obj1E_MakeBall	; if yes, branch
		bra.s	Obj1E_MarkAsGone
; ===========================================================================

Obj1E_SetBall:				; XREF: Obj1E_Action
		clr.b	$32(a0)		; set to launch	cannonball

Obj1E_MarkAsGone:			; XREF: Obj1E_Action
		bra.w	MarkObjGone
; ===========================================================================

Obj1E_MakeBall:				; XREF: Obj1E_Action
		move.b	#1,$32(a0)
		bsr.w	SingleObjLoad
		bne.s	loc_8C1A
		move.b	#$20,0(a1)	; load cannonball object ($20)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	#-$100,$10(a1)	; cannonball bounces to	the left
		move.w	#0,$12(a1)
		moveq	#-4,d0
		btst	#0,$22(a0)	; is Ball Hog facing right?
		beq.s	loc_8C0A	; if not, branch
		neg.w	d0
		neg.w	$10(a1)		; cannonball bounces to	the right

loc_8C0A:
		add.w	d0,8(a1)
		addi.w	#$C,$C(a1)
		move.b	$28(a0),$28(a1)	; copy object type from	Ball Hog

loc_8C1A:
		bra.s	Obj1E_MarkAsGone
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 20 - cannonball that Ball Hog throws (SBZ)
; ---------------------------------------------------------------------------

Obj20:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj20_Index(pc,d0.w),d1
		jmp	Obj20_Index(pc,d1.w)
; ===========================================================================
Obj20_Index:	dc.w Obj20_Main-Obj20_Index
		dc.w Obj20_Bounce-Obj20_Index
; ===========================================================================

Obj20_Main:				; XREF: Obj20_Index
		addq.b	#2,$24(a0)
		move.b	#7,$16(a0)
		move.l	#Map_obj1E,4(a0)
		move.w	#$2302,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$87,$20(a0)
		move.b	#8,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; move object type to d0
		mulu.w	#60,d0		; multiply by 60 frames	(1 second)
		move.w	d0,$30(a0)	; set explosion	time
		move.b	#4,$1A(a0)

Obj20_Bounce:				; XREF: Obj20_Index
		jsr	ObjectMoveAndFall
		tst.w	$12(a0)
		bmi.s	Obj20_ChkExplode
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	Obj20_ChkExplode
		add.w	d1,$C(a0)
		move.w	#-$300,$12(a0)
		tst.b	d3
		beq.s	Obj20_ChkExplode
		bmi.s	loc_8CA4
		tst.w	$10(a0)
		bpl.s	Obj20_ChkExplode
		neg.w	$10(a0)
		bra.s	Obj20_ChkExplode
; ===========================================================================

loc_8CA4:				; XREF: Obj20_Bounce
		tst.w	$10(a0)
		bmi.s	Obj20_ChkExplode
		neg.w	$10(a0)

Obj20_ChkExplode:			; XREF: Obj20_Bounce
		subq.w	#1,$30(a0)	; subtract 1 from explosion time
		bpl.s	Obj20_Animate	; if time is > 0, branch
		move.b	#$24,0(a0)
		move.b	#$3F,0(a0)	; change object	to an explosion	($3F)
		move.b	#0,$24(a0)	; reset	routine	counter
		bra.w	Obj3F		; jump to explosion code
; ===========================================================================

Obj20_Animate:				; XREF: Obj20_ChkExplode
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Obj20_Display
		move.b	#5,$1E(a0)	; set frame duration to	5 frames
		bchg	#0,$1A(a0)	; change frame

Obj20_Display:
		bsr.w	DisplaySprite
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object fallen off	the level?
		bcs.w	DeleteObject	; if yes, branch
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 24 - explosion	from a destroyed monitor
; ---------------------------------------------------------------------------

Obj24:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj24_Index(pc,d0.w),d1
		jmp	Obj24_Index(pc,d1.w)
; ===========================================================================
Obj24_Index:	dc.w Obj24_Main-Obj24_Index
		dc.w Obj24_Animate-Obj24_Index
; ===========================================================================

Obj24_Main:				; XREF: Obj24_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj24,4(a0)
		move.w	#$41C,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#0,$20(a0)
		move.b	#$C,$19(a0)
		move.b	#9,$1E(a0)
		move.b	#0,$1A(a0)
		move.w	#SndID_05,d0
		jsr	(PlaySound_Special).l ;	play explosion sound

Obj24_Animate:				; XREF: Obj24_Index
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Obj24_Display
		move.b	#9,$1E(a0)	; set frame duration to	9 frames
		addq.b	#1,$1A(a0)	; next frame
		cmpi.b	#4,$1A(a0)	; is the final frame (04) displayed?
		beq.w	DeleteObject	; if yes, branch

Obj24_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 27 - explosion	from a destroyed enemy
; ---------------------------------------------------------------------------

Obj27:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj27_Index(pc,d0.w),d1
		jmp	Obj27_Index(pc,d1.w)
; ===========================================================================
Obj27_Index:	dc.w Obj27_LoadAnimal-Obj27_Index
		dc.w Obj27_Main-Obj27_Index
		dc.w Obj27_Animate-Obj27_Index
; ===========================================================================

Obj27_LoadAnimal:			; XREF: Obj27_Index
		addq.b	#2,$24(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj27_Main
		move.b	#$28,0(a1)	; load animal object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	$3E(a0),$3E(a1)

Obj27_Main:				; XREF: Obj27_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj27,4(a0)
		move.w	#$5A0,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#0,$20(a0)
		move.b	#$C,$19(a0)
		move.b	#7,$1E(a0)	; set frame duration to	7 frames
		move.b	#0,$1A(a0)
		move.w	#SndID_BreakItem,d0
		jsr	(PlaySound_Special).l ;	play breaking enemy sound

Obj27_Animate:				; XREF: Obj27_Index
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Obj27_Display
		move.b	#7,$1E(a0)	; set frame duration to	7 frames
		addq.b	#1,$1A(a0)	; next frame
		cmpi.b	#5,$1A(a0)	; is the final frame (05) displayed?
		beq.w	DeleteObject	; if yes, branch

Obj27_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3F - explosion	from a destroyed boss, bomb or cannonball
; ---------------------------------------------------------------------------

Obj3F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3F_Index(pc,d0.w),d1
		jmp	Obj3F_Index(pc,d1.w)
; ===========================================================================
Obj3F_Index:	dc.w Obj3F_Main-Obj3F_Index
		dc.w Obj27_Animate-Obj3F_Index
; ===========================================================================

Obj3F_Main:				; XREF: Obj3F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj3F,4(a0)
		move.w	#$5A0,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#0,$20(a0)
		move.b	#$C,$19(a0)
		move.b	#7,$1E(a0)
		move.b	#0,$1A(a0)
		move.w	#SndID_Bomb,d0
		jmp	(PlaySound_Special).l ;	play exploding bomb sound
; ===========================================================================
Ani_obj1E:
	include "objects/animation/obj1E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Ball Hog enemy (SBZ)
; ---------------------------------------------------------------------------
Map_obj1E:
	include "mappings/sprite/obj1E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - explosion
; ---------------------------------------------------------------------------
Map_obj24:
	include "mappings/sprite/obj24.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - explosion
; ---------------------------------------------------------------------------
Map_obj27:	dc.w byte_8ED0-Map_obj27, byte_8ED6-Map_obj27
		dc.w byte_8EDC-Map_obj27, byte_8EE2-Map_obj27
		dc.w byte_8EF7-Map_obj27
byte_8ED0:	dc.b 1
		dc.b $F8, 9, 0,	0, $F4
byte_8ED6:	dc.b 1
		dc.b $F0, $F, 0, 6, $F0
byte_8EDC:	dc.b 1
		dc.b $F0, $F, 0, $16, $F0
byte_8EE2:	dc.b 4
		dc.b $EC, $A, 0, $26, $EC
		dc.b $EC, 5, 0,	$2F, 4
		dc.b 4,	5, $18,	$2F, $EC
		dc.b $FC, $A, $18, $26,	$FC
byte_8EF7:	dc.b 4
		dc.b $EC, $A, 0, $33, $EC
		dc.b $EC, 5, 0,	$3C, 4
		dc.b 4,	5, $18,	$3C, $EC
		dc.b $FC, $A, $18, $33,	$FC
		even
; ---------------------------------------------------------------------------
; Sprite mappings - explosion from when	a boss is destroyed
; ---------------------------------------------------------------------------
Map_obj3F:	dc.w byte_8ED0-Map_obj3F
		dc.w byte_8F16-Map_obj3F
		dc.w byte_8F1C-Map_obj3F
		dc.w byte_8EE2-Map_obj3F
		dc.w byte_8EF7-Map_obj3F
byte_8F16:	dc.b 1
		dc.b $F0, $F, 0, $40, $F0
byte_8F1C:	dc.b 1
		dc.b $F0, $F, 0, $50, $F0
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 28 - animals
; ---------------------------------------------------------------------------

Obj28:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj28_Index(pc,d0.w),d1
		jmp	Obj28_Index(pc,d1.w)
; ===========================================================================
Obj28_Index:	dc.w Obj28_Ending-Obj28_Index, loc_912A-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_91C0-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_9184-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_91C0-Obj28_Index
		dc.w loc_9184-Obj28_Index, loc_9240-Obj28_Index
		dc.w loc_9260-Obj28_Index, loc_9260-Obj28_Index
		dc.w loc_9280-Obj28_Index, loc_92BA-Obj28_Index
		dc.w loc_9314-Obj28_Index, loc_9332-Obj28_Index
		dc.w loc_9314-Obj28_Index, loc_9332-Obj28_Index
		dc.w loc_9314-Obj28_Index, loc_9370-Obj28_Index
		dc.w loc_92D6-Obj28_Index

Obj28_VarIndex:	dc.b 0,	5, 2, 3, 6, 3, 4, 5, 4,	1, 0, 1

Obj28_Variables:dc.w $FE00, $FC00
		dc.l Map_obj28
		dc.w $FE00, $FD00	; horizontal speed, vertical speed
		dc.l Map_obj28a		; mappings address
		dc.w $FE80, $FD00
		dc.l Map_obj28
		dc.w $FEC0, $FE80
		dc.l Map_obj28a
		dc.w $FE40, $FD00
		dc.l Map_obj28b
		dc.w $FD00, $FC00
		dc.l Map_obj28a
		dc.w $FD80, $FC80
		dc.l Map_obj28b

Obj28_EndSpeed:	dc.w $FBC0, $FC00, $FBC0, $FC00, $FBC0,	$FC00, $FD00, $FC00
		dc.w $FD00, $FC00, $FE80, $FD00, $FE80,	$FD00, $FEC0, $FE80
		dc.w $FE40, $FD00, $FE00, $FD00, $FD80,	$FC80

Obj28_EndMap:	dc.l Map_obj28a, Map_obj28a, Map_obj28a, Map_obj28, Map_obj28
		dc.l Map_obj28,	Map_obj28, Map_obj28a, Map_obj28b, Map_obj28a
		dc.l Map_obj28b

Obj28_EndVram:	dc.w $5A5, $5A5, $5A5, $553, $553, $573, $573, $585, $593
		dc.w $565, $5B3
; ===========================================================================

Obj28_Ending:				; XREF: Obj28_Index
		tst.b	$28(a0)		; did animal come from a destroyed enemy?
		beq.w	Obj28_FromEnemy	; if yes, branch
		moveq	#0,d0
		move.b	$28(a0),d0	; move object type to d0
		add.w	d0,d0		; multiply d0 by 2
		move.b	d0,$24(a0)	; move d0 to routine counter
		subi.w	#$14,d0
		move.w	Obj28_EndVram(pc,d0.w),2(a0)
		add.w	d0,d0
		move.l	Obj28_EndMap(pc,d0.w),4(a0)
		lea	Obj28_EndSpeed(pc),a1
		move.w	(a1,d0.w),$32(a0) ; load horizontal speed
		move.w	(a1,d0.w),$10(a0)
		move.w	2(a1,d0.w),$34(a0) ; load vertical speed
		move.w	2(a1,d0.w),$12(a0)
		move.b	#$C,$16(a0)
		move.b	#4,1(a0)
		bset	#0,1(a0)
		move.b	#6,$18(a0)
		move.b	#8,$19(a0)
		move.b	#7,$1E(a0)
		bra.w	DisplaySprite
; ===========================================================================

Obj28_FromEnemy:			; XREF: Obj28_Ending
		addq.b	#2,$24(a0)
		bsr.w	RandomNumber
		andi.w	#1,d0
		moveq	#0,d1
		move.b	(Current_Zone).w,d1
		add.w	d1,d1
		add.w	d0,d1
		lea	Obj28_VarIndex(pc),a1
		move.b	(a1,d1.w),d0
		move.b	d0,$30(a0)
		lsl.w	#3,d0
		lea	Obj28_Variables(pc),a1
		adda.w	d0,a1
		move.w	(a1)+,$32(a0)	; load horizontal speed
		move.w	(a1)+,$34(a0)	; load vertical	speed
		move.l	(a1)+,4(a0)	; load mappings
		move.w	#$580,2(a0)	; VRAM setting for 1st animal
		btst	#0,$30(a0)	; is 1st animal	used?
		beq.s	loc_90C0	; if yes, branch
		move.w	#$592,2(a0)	; VRAM setting for 2nd animal

loc_90C0:
		move.b	#$C,$16(a0)
		move.b	#4,1(a0)
		bset	#0,1(a0)
		move.b	#6,$18(a0)
		move.b	#8,$19(a0)
		move.b	#7,$1E(a0)
		move.b	#2,$1A(a0)
		move.w	#-$400,$12(a0)
		tst.b	(Boss_Defeated_Flags).w
		bne.s	loc_911C
		bsr.w	SingleObjLoad
		bne.s	Obj28_Display
		move.b	#$29,0(a1)	; load points object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	$3E(a0),d0
		lsr.w	#1,d0
		move.b	d0,$1A(a1)

Obj28_Display:
		bra.w	DisplaySprite
; ===========================================================================

loc_911C:
		move.b	#$12,$24(a0)
		clr.w	$10(a0)
		bra.w	DisplaySprite
; ===========================================================================

loc_912A:				; XREF: Obj28_Index
		tst.b	1(a0)
		bpl.w	DeleteObject
		bsr.w	ObjectMoveAndFall
		tst.w	$12(a0)
		bmi.s	loc_9180
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_9180
		add.w	d1,$C(a0)
		move.w	$32(a0),$10(a0)
		move.w	$34(a0),$12(a0)
		move.b	#1,$1A(a0)
		move.b	$30(a0),d0
		add.b	d0,d0
		addq.b	#4,d0
		move.b	d0,$24(a0)
		tst.b	(Boss_Defeated_Flags).w
		beq.s	loc_9180
		btst	#4,(V_Int_Counter+3).w
		beq.s	loc_9180
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_9180:
		bra.w	DisplaySprite
; ===========================================================================

loc_9184:				; XREF: Obj28_Index
		bsr.w	ObjectMoveAndFall
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	loc_91AE
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_91AE
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_91AE:
		tst.b	$28(a0)
		bne.s	loc_9224
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

loc_91C0:				; XREF: Obj28_Index
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		tst.w	$12(a0)
		bmi.s	loc_91FC
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_91FC
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)
		tst.b	$28(a0)
		beq.s	loc_91FC
		cmpi.b	#$A,$28(a0)
		beq.s	loc_91FC
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_91FC:
		subq.b	#1,$1E(a0)
		bpl.s	loc_9212
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		andi.b	#1,$1A(a0)

loc_9212:
		tst.b	$28(a0)
		bne.s	loc_9224
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

loc_9224:				; XREF: Obj28_Index
		move.w	8(a0),d0
		sub.w	(Object_Space_1+8).w,d0
		bcs.s	loc_923C
		subi.w	#$180,d0
		bpl.s	loc_923C
		tst.b	1(a0)
		bpl.w	DeleteObject

loc_923C:
		bra.w	DisplaySprite
; ===========================================================================

loc_9240:				; XREF: Obj28_Index
		tst.b	1(a0)
		bpl.w	DeleteObject
		subq.w	#1,$36(a0)
		bne.w	loc_925C
		move.b	#2,$24(a0)
		move.b	#3,$18(a0)

loc_925C:
		bra.w	DisplaySprite
; ===========================================================================

loc_9260:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bcc.s	loc_927C
		move.w	$32(a0),$10(a0)
		move.w	$34(a0),$12(a0)
		move.b	#$E,$24(a0)
		bra.w	loc_91C0
; ===========================================================================

loc_927C:
		bra.w	loc_9224
; ===========================================================================

loc_9280:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_92B6
		clr.w	$10(a0)
		clr.w	$32(a0)
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		bsr.w	loc_93C4
		bsr.w	loc_93EC
		subq.b	#1,$1E(a0)
		bpl.s	loc_92B6
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		andi.b	#1,$1A(a0)

loc_92B6:
		bra.w	loc_9224
; ===========================================================================

loc_92BA:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_9310
		move.w	$32(a0),$10(a0)
		move.w	$34(a0),$12(a0)
		move.b	#4,$24(a0)
		bra.w	loc_9184
; ===========================================================================

loc_92D6:				; XREF: Obj28_Index
		bsr.w	ObjectMoveAndFall
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	loc_9310
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_9310
		not.b	$29(a0)
		bne.s	loc_9306
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_9306:
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_9310:
		bra.w	loc_9224
; ===========================================================================

loc_9314:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_932E
		clr.w	$10(a0)
		clr.w	$32(a0)
		bsr.w	ObjectMoveAndFall
		bsr.w	loc_93C4
		bsr.w	loc_93EC

loc_932E:
		bra.w	loc_9224
; ===========================================================================

loc_9332:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_936C
		bsr.w	ObjectMoveAndFall
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	loc_936C
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_936C
		neg.w	$10(a0)
		bchg	#0,1(a0)
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_936C:
		bra.w	loc_9224
; ===========================================================================

loc_9370:				; XREF: Obj28_Index
		bsr.w	sub_9404
		bpl.s	loc_93C0
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		tst.w	$12(a0)
		bmi.s	loc_93AA
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_93AA
		not.b	$29(a0)
		bne.s	loc_93A0
		neg.w	$10(a0)
		bchg	#0,1(a0)

loc_93A0:
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

loc_93AA:
		subq.b	#1,$1E(a0)
		bpl.s	loc_93C0
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		andi.b	#1,$1A(a0)

loc_93C0:
		bra.w	loc_9224
; ===========================================================================

loc_93C4:
		move.b	#1,$1A(a0)
		tst.w	$12(a0)
		bmi.s	locret_93EA
		move.b	#0,$1A(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_93EA
		add.w	d1,$C(a0)
		move.w	$34(a0),$12(a0)

locret_93EA:
		rts	
; ===========================================================================

loc_93EC:
		bset	#0,1(a0)
		move.w	8(a0),d0
		sub.w	(Object_Space_1+8).w,d0
		bcc.s	locret_9402
		bclr	#0,1(a0)

locret_9402:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_9404:
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		subi.w	#$B8,d0
		rts	
; End of function sub_9404

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 29 - points that appear when you destroy something
; ---------------------------------------------------------------------------

Obj29:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj29_Index(pc,d0.w),d1
		jsr	Obj29_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj29_Index:	dc.w Obj29_Main-Obj29_Index
		dc.w Obj29_Slower-Obj29_Index
; ===========================================================================

Obj29_Main:				; XREF: Obj29_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj29,4(a0)
		move.w	#$2570,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#8,$19(a0)
		move.w	#-$300,$12(a0)	; move object upwards

Obj29_Slower:				; XREF: Obj29_Index
		cmpi.b	#$39,(Object_Space_4).w
		beq.w	DeleteObject
		tst.w	$12(a0)		; is object moving?
		bpl.w	DeleteObject	; if not, branch
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)	; reduce object	speed
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - animals
; ---------------------------------------------------------------------------
Map_obj28:
	include "mappings/sprite/obj28.asm"

Map_obj28a:
	include "mappings/sprite/obj28a.asm"

Map_obj28b:
	include "mappings/sprite/obj28b.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - points that	appear when you	destroy	something
; ---------------------------------------------------------------------------
Map_obj29:
	include "mappings/sprite/obj29.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1F - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------

Obj1F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1F_Index(pc,d0.w),d1
		jmp	Obj1F_Index(pc,d1.w)
; ===========================================================================
Obj1F_Index:	dc.w Obj1F_Main-Obj1F_Index
		dc.w Obj1F_Action-Obj1F_Index
		dc.w Obj1F_Delete-Obj1F_Index
		dc.w Obj1F_BallMain-Obj1F_Index
		dc.w Obj1F_BallMove-Obj1F_Index
; ===========================================================================

Obj1F_Main:				; XREF: Obj1F_Index
		move.b	#$10,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj1F,4(a0)
		move.w	#$400,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#6,$20(a0)
		move.b	#$15,$19(a0)
		bsr.w	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_955A
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)

locret_955A:
		rts	
; ===========================================================================

Obj1F_Action:				; XREF: Obj1F_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj1F_Index2(pc,d0.w),d1
		jsr	Obj1F_Index2(pc,d1.w)
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj1F_Index2:	dc.w Obj1F_WaitFire-Obj1F_Index2
		dc.w Obj1F_WalkOnFloor-Obj1F_Index2
; ===========================================================================

Obj1F_WaitFire:				; XREF: Obj1F_Index2
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	locret_95B6
		tst.b	1(a0)
		bpl.s	Obj1F_Move
		bchg	#1,$32(a0)
		bne.s	Obj1F_MakeFire

Obj1F_Move:
		addq.b	#2,$25(a0)
		move.w	#127,$30(a0)	; set time delay to approx 2 seconds
		move.w	#$80,$10(a0)	; move Crabmeat	to the right
		bsr.w	Obj1F_SetAni
		addq.b	#3,d0
		move.b	d0,$1C(a0)
		bchg	#0,$22(a0)
		bne.s	locret_95B6
		neg.w	$10(a0)		; change direction

locret_95B6:
		rts	
; ===========================================================================

Obj1F_MakeFire:				; XREF: Obj1F_WaitFire
		move.w	#$3B,$30(a0)
		move.b	#6,$1C(a0)	; use firing animation
		bsr.w	SingleObjLoad
		bne.s	Obj1F_MakeFire2
		move.b	#$1F,0(a1)	; load left fireball
		move.b	#6,$24(a1)
		move.w	8(a0),8(a1)
		subi.w	#$10,8(a1)
		move.w	$C(a0),$C(a1)
		move.w	#-$100,$10(a1)

Obj1F_MakeFire2:
		bsr.w	SingleObjLoad
		bne.s	locret_9618
		move.b	#$1F,0(a1)	; load right fireball
		move.b	#6,$24(a1)
		move.w	8(a0),8(a1)
		addi.w	#$10,8(a1)
		move.w	$C(a0),$C(a1)
		move.w	#$100,$10(a1)

locret_9618:
		rts	
; ===========================================================================

Obj1F_WalkOnFloor:			; XREF: Obj1F_Index2
		subq.w	#1,$30(a0)
		bmi.s	loc_966E
		bsr.w	ObjectMove
		bchg	#0,$32(a0)
		bne.s	loc_9654
		move.w	8(a0),d3
		addi.w	#$10,d3
		btst	#0,$22(a0)
		beq.s	loc_9640
		subi.w	#$20,d3

loc_9640:
		jsr	ObjHitFloor2
		cmpi.w	#-8,d1
		blt.s	loc_966E
		cmpi.w	#$C,d1
		bge.s	loc_966E
		rts	
; ===========================================================================

loc_9654:				; XREF: Obj1F_WalkOnFloor
		jsr	ObjHitFloor
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Obj1F_SetAni
		addq.b	#3,d0
		move.b	d0,$1C(a0)
		rts	
; ===========================================================================

loc_966E:				; XREF: Obj1F_WalkOnFloor
		subq.b	#2,$25(a0)
		move.w	#59,$30(a0)
		move.w	#0,$10(a0)
		bsr.w	Obj1F_SetAni
		move.b	d0,$1C(a0)
		rts	
; ---------------------------------------------------------------------------
; Subroutine to	set the	correct	animation for a	Crabmeat
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj1F_SetAni:				; XREF: loc_966E
		moveq	#0,d0
		move.b	$26(a0),d3
		bmi.s	loc_96A4
		cmpi.b	#6,d3
		bcs.s	locret_96A2
		moveq	#1,d0
		btst	#0,$22(a0)
		bne.s	locret_96A2
		moveq	#2,d0

locret_96A2:
		rts	
; ===========================================================================

loc_96A4:				; XREF: Obj1F_SetAni
		cmpi.b	#-6,d3
		bhi.s	locret_96B6
		moveq	#2,d0
		btst	#0,$22(a0)
		bne.s	locret_96B6
		moveq	#1,d0

locret_96B6:
		rts	
; End of function Obj1F_SetAni

; ===========================================================================

Obj1F_Delete:				; XREF: Obj1F_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sub-object - missile that the	Crabmeat throws
; ---------------------------------------------------------------------------

Obj1F_BallMain:				; XREF: Obj1F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1F,4(a0)
		move.w	#$400,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$87,$20(a0)
		move.b	#8,$19(a0)
		move.w	#-$400,$12(a0)
		move.b	#7,$1C(a0)

Obj1F_BallMove:				; XREF: Obj1F_Index
		lea	(Ani_obj1F).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMoveAndFall
		bsr.w	DisplaySprite
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object moved below the level boundary?
		bcs.s	Obj1F_Delete2	; if yes, branch
		rts	
; ===========================================================================

Obj1F_Delete2:
		bra.w	DeleteObject
; ===========================================================================
Ani_obj1F:
	include "objects/animation/obj1F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Crabmeat enemy (GHZ, SYZ)
; ---------------------------------------------------------------------------
Map_obj1F:
	include "mappings/sprite/obj1F.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber enemy	(GHZ, MZ, SYZ)
; ---------------------------------------------------------------------------

Obj22:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj22_Index(pc,d0.w),d1
		jmp	Obj22_Index(pc,d1.w)
; ===========================================================================
Obj22_Index:	dc.w Obj22_Main-Obj22_Index
		dc.w Obj22_Action-Obj22_Index
		dc.w Obj22_Delete-Obj22_Index
; ===========================================================================

Obj22_Main:				; XREF: Obj22_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj22,4(a0)
		move.w	#$444,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$20(a0)
		move.b	#$18,$19(a0)

Obj22_Action:				; XREF: Obj22_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj22_Index2(pc,d0.w),d1
		jsr	Obj22_Index2(pc,d1.w)
		lea	(Ani_obj22).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj22_Index2:	dc.w Obj22_Move-Obj22_Index2
		dc.w Obj22_ChkNrSonic-Obj22_Index2
; ===========================================================================

Obj22_Move:				; XREF: Obj22_Index2
		subq.w	#1,$32(a0)	; subtract 1 from time delay
		bpl.s	locret_986C	; if time remains, branch
		btst	#1,$34(a0)	; is Buzz Bomber near Sonic?
		bne.s	Obj22_Fire	; if yes, branch
		addq.b	#2,$25(a0)
		move.w	#127,$32(a0)	; set time delay to just over 2	seconds
		move.w	#$400,$10(a0)	; move Buzz Bomber to the right
		move.b	#1,$1C(a0)	; use "flying" animation
		btst	#0,$22(a0)	; is Buzz Bomber facing	left?
		bne.s	locret_986C	; if not, branch
		neg.w	$10(a0)		; move Buzz Bomber to the left

locret_986C:
		rts	
; ===========================================================================

Obj22_Fire:				; XREF: Obj22_Move
		bsr.w	SingleObjLoad
		bne.s	locret_98D0
		move.b	#$23,0(a1)	; load missile object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$1C,$C(a1)
		move.w	#$200,$12(a1)	; move missile downwards
		move.w	#$200,$10(a1)	; move missile to the right
		move.w	#$18,d0
		btst	#0,$22(a0)	; is Buzz Bomber facing	left?
		bne.s	loc_98AA	; if not, branch
		neg.w	d0
		neg.w	$10(a1)		; move missile to the left

loc_98AA:
		add.w	d0,8(a1)
		move.b	$22(a0),$22(a1)
		move.w	#$E,$32(a1)
		move.l	a0,$3C(a1)
		move.b	#1,$34(a0)	; set to "already fired" to prevent refiring
		move.w	#$3B,$32(a0)
		move.b	#2,$1C(a0)	; use "firing" animation

locret_98D0:
		rts	
; ===========================================================================

Obj22_ChkNrSonic:			; XREF: Obj22_Index2
		subq.w	#1,$32(a0)	; subtract 1 from time delay
		bmi.s	Obj22_ChgDir
		bsr.w	ObjectMove
		tst.b	$34(a0)
		bne.s	locret_992A
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bpl.s	Obj22_SetNrSonic
		neg.w	d0

Obj22_SetNrSonic:
		cmpi.w	#$60,d0		; is Buzz Bomber within	$60 pixels of Sonic?
		bcc.s	locret_992A	; if not, branch
		tst.b	1(a0)
		bpl.s	locret_992A
		move.b	#2,$34(a0)	; set Buzz Bomber to "near Sonic"
		move.w	#29,$32(a0)	; set time delay to half a second
		bra.s	Obj22_Stop
; ===========================================================================

Obj22_ChgDir:				; XREF: Obj22_ChkNrSonic
		move.b	#0,$34(a0)	; set Buzz Bomber to "normal"
		bchg	#0,$22(a0)	; change direction
		move.w	#59,$32(a0)

Obj22_Stop:				; XREF: Obj22_SetNrSonic
		subq.b	#2,$25(a0)	; run "Obj22_Fire" routine
		move.w	#0,$10(a0)	; stop Buzz Bomber moving
		move.b	#0,$1C(a0)	; use "hovering" animation

locret_992A:
		rts	
; ===========================================================================

Obj22_Delete:				; XREF: Obj22_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 23 - missile that Buzz	Bomber throws
; ---------------------------------------------------------------------------

Obj23:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj23_Index(pc,d0.w),d1
		jmp	Obj23_Index(pc,d1.w)
; ===========================================================================
Obj23_Index:	dc.w Obj23_Main-Obj23_Index
		dc.w Obj23_Animate-Obj23_Index
		dc.w Obj23_FromBuzz-Obj23_Index
		dc.w Obj23_Delete-Obj23_Index
		dc.w Obj23_FromNewt-Obj23_Index
; ===========================================================================

Obj23_Main:				; XREF: Obj23_Index
		subq.w	#1,$32(a0)
		bpl.s	Obj23_ChkCancel
		addq.b	#2,$24(a0)
		move.l	#Map_obj23,4(a0)
		move.w	#$2444,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$19(a0)
		andi.b	#3,$22(a0)
		tst.b	$28(a0)		; was object created by	a Newtron?
		beq.s	Obj23_Animate	; if not, branch
		move.b	#8,$24(a0)	; run "Obj23_FromNewt" routine
		move.b	#$87,$20(a0)
		move.b	#1,$1C(a0)
		bra.s	Obj23_Animate2
; ===========================================================================

Obj23_Animate:				; XREF: Obj23_Index
		bsr.s	Obj23_ChkCancel
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ---------------------------------------------------------------------------
; Subroutine to	check if the Buzz Bomber which fired the missile has been
; destroyed, and if it has, then cancel	the missile
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj23_ChkCancel:			; XREF: Obj23_Main
		movea.l	$3C(a0),a1
		cmpi.b	#$27,0(a1)	; has Buzz Bomber been destroyed?
		beq.s	Obj23_Delete	; if yes, branch
		rts	
; End of function Obj23_ChkCancel

; ===========================================================================

Obj23_FromBuzz:				; XREF: Obj23_Index
		btst	#7,$22(a0)
		bne.s	Obj23_Explode
		move.b	#$87,$20(a0)
		move.b	#1,$1C(a0)
		bsr.w	ObjectMove
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has object moved below the level boundary?
		bcs.s	Obj23_Delete	; if yes, branch
		rts	
; ===========================================================================

Obj23_Explode:				; XREF: Obj23_FromBuzz
		move.b	#$24,0(a0)	; change object	to an explosion	(Obj24)
		move.b	#0,$24(a0)
		bra.w	Obj24
; ===========================================================================

Obj23_Delete:				; XREF: Obj23_Index
		bsr.w	DeleteObject
		rts	
; ===========================================================================

Obj23_FromNewt:				; XREF: Obj23_Index
		tst.b	1(a0)
		bpl.s	Obj23_Delete
		bsr.w	ObjectMove

Obj23_Animate2:				; XREF: Obj23_Main
		lea	(Ani_obj23).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		rts	
; ===========================================================================
Ani_obj22:
	include "objects/animation/obj22.asm"

Ani_obj23:
	include "objects/animation/obj23.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Buzz Bomber	enemy
; ---------------------------------------------------------------------------
Map_obj22:
	include "mappings/sprite/obj22.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - missile that Buzz Bomber throws
; ---------------------------------------------------------------------------
Map_obj23:
	include "mappings/sprite/obj23.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 25 - rings
; ---------------------------------------------------------------------------

Obj25:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj25_Index(pc,d0.w),d1
		jmp	Obj25_Index(pc,d1.w)
; ===========================================================================
Obj25_Index:	dc.w Obj25_Main-Obj25_Index
		dc.w Obj25_Animate-Obj25_Index
		dc.w Obj25_Collect-Obj25_Index
		dc.w Obj25_Sparkle-Obj25_Index
		dc.w Obj25_Delete-Obj25_Index
; ---------------------------------------------------------------------------
; Distances between rings (format: horizontal, vertical)
; ---------------------------------------------------------------------------
Obj25_PosData:	dc.b $10, 0		; horizontal tight
		dc.b $18, 0		; horizontal normal
		dc.b $20, 0		; horizontal wide
		dc.b 0,	$10		; vertical tight
		dc.b 0,	$18		; vertical normal
		dc.b 0,	$20		; vertical wide
		dc.b $10, $10		; diagonal
		dc.b $18, $18
		dc.b $20, $20
		dc.b $F0, $10
		dc.b $E8, $18
		dc.b $E0, $20
		dc.b $10, 8
		dc.b $18, $10
		dc.b $F0, 8
		dc.b $E8, $10
; ===========================================================================

Obj25_Main:				; XREF: Obj25_Index
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		lea	2(a2,d0.w),a2
		move.b	(a2),d4
		move.b	$28(a0),d1
		move.b	d1,d0
		andi.w	#7,d1
		cmpi.w	#7,d1
		bne.s	loc_9B80
		moveq	#6,d1

loc_9B80:
		swap	d1
		move.w	#0,d1
		lsr.b	#4,d0
		add.w	d0,d0
		move.b	Obj25_PosData(pc,d0.w),d5 ; load ring spacing data
		ext.w	d5
		move.b	Obj25_PosData+1(pc,d0.w),d6
		ext.w	d6
		movea.l	a0,a1
		move.w	8(a0),d2
		move.w	$C(a0),d3
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bra.s	loc_9BBA
; ===========================================================================

Obj25_MakeRings:
		swap	d1
		lsr.b	#1,d4
		bcs.s	loc_9C02
		bclr	#7,(a2)
		bsr.w	SingleObjLoad
		bne.s	loc_9C0E

loc_9BBA:				; XREF: Obj25_Main
		move.b	#$25,0(a1)	; load ring object
		addq.b	#2,$24(a1)
		move.w	d2,8(a1)	; set x-axis position based on d2
		move.w	8(a0),$32(a1)
		move.w	d3,$C(a1)	; set y-axis position based on d3
		move.l	#Map_obj25,4(a1)
		move.w	#$27B2,2(a1)
		move.b	#4,1(a1)
		move.b	#2,$18(a1)
		move.b	#$47,$20(a1)
		move.b	#8,$19(a1)
		move.b	$23(a0),$23(a1)
		move.b	d1,$34(a1)

loc_9C02:
		addq.w	#1,d1
		add.w	d5,d2		; add ring spacing value to d2
		add.w	d6,d3		; add ring spacing value to d3
		swap	d1
		dbf	d1,Obj25_MakeRings ; repeat for	number of rings

loc_9C0E:
		btst	#0,(a2)
		bne.w	DeleteObject

Obj25_Animate:				; XREF: Obj25_Index
		move.b	(Rings_Anim_Frame).w,$1A(a0) ;	set frame
		bsr.w	DisplaySprite
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj25_Delete
		rts	
; ===========================================================================

Obj25_Collect:				; XREF: Obj25_Index
		addq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		move.b	#1,$18(a0)
		bsr.w	CollectRing
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		move.b	$34(a0),d1
		bset	d1,2(a2,d0.w)

Obj25_Sparkle:				; XREF: Obj25_Index
		lea	(Ani_obj25).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj25_Delete:				; XREF: Obj25_Index
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CollectRing:				; XREF: Obj25_Collect
		addq.w	#1,(Ring_Count).w ; add 1 to rings
		ori.b	#1,(Update_HUD_Rings).w ; update the rings counter
		move.w	#SndID_Ring,d0		; play ring sound
		cmpi.w	#100,(Ring_Count).w ; do	you have < 100 rings?
		bcs.s	Obj25_PlaySnd	; if yes, branch
		bset	#1,(Extra_Life_Flags).w ; update lives	counter
		beq.s	loc_9CA4
		cmpi.w	#200,(Ring_Count).w ; do	you have < 200 rings?
		bcs.s	Obj25_PlaySnd	; if yes, branch
		bset	#2,(Extra_Life_Flags).w ; update lives	counter
		bne.s	Obj25_PlaySnd

loc_9CA4:
		addq.b	#1,(Life_Count).w ; add 1 to the	number of lives	you have
		addq.b	#1,(Update_HUD_Lives).w ; add 1 to the	lives counter
		move.w	#MusID_1UP,d0		; play extra life music

Obj25_PlaySnd:
		jmp	(PlaySound_Special).l
; End of function CollectRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit
; ---------------------------------------------------------------------------

Obj37:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj37_Index(pc,d0.w),d1
		jmp	Obj37_Index(pc,d1.w)
; ===========================================================================
Obj37_Index:	dc.w Obj37_CountRings-Obj37_Index
		dc.w Obj37_Bounce-Obj37_Index
		dc.w Obj37_Collect-Obj37_Index
		dc.w Obj37_Sparkle-Obj37_Index
		dc.w Obj37_Delete-Obj37_Index
; ===========================================================================

Obj37_CountRings:			; XREF: Obj37_Index
		movea.l	a0,a1
		moveq	#0,d5
		move.w	(Ring_Count).w,d5 ; check number	of rings you have
		moveq	#32,d0
		cmp.w	d0,d5		; do you have 32 or more?
		bcs.s	loc_9CDE	; if not, branch
		move.w	d0,d5		; if yes, set d5 to 32

loc_9CDE:
		subq.w	#1,d5
		move.w	#$288,d4
		bra.s	Obj37_MakeRings
; ===========================================================================

Obj37_Loop:
		bsr.w	SingleObjLoad
		bne.w	Obj37_ResetCounter

Obj37_MakeRings:			; XREF: Obj37_CountRings
		move.b	#$37,0(a1)	; load bouncing	ring object
		addq.b	#2,$24(a1)
		move.b	#8,$16(a1)
		move.b	#8,$17(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#Map_obj25,4(a1)
		move.w	#$27B2,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#$47,$20(a1)
		move.b	#8,$19(a1)
		tst.w	d4
		bmi.s	loc_9D62
		move.w	d4,d0
		jsr	CalcSine
		move.w	d4,d2
		lsr.w	#8,d2
		tst.b	(Water_On).w		; Does the level have water?
		beq.s	@skiphalvingvel		; If not, branch and skip underwater checks
		move.w	(Water_Height).w,d6	; Move water level to d6
		cmp.w	$C(a0),d6		; Is the ring object underneath the water level?
		bgt.s	@skiphalvingvel		; If not, branch and skip underwater commands
		asr.w	d0			; Half d0. Makes the ring's x_vel bounce to the left/right slower
		asr.w	d1			; Half d1. Makes the ring's y_vel bounce up/down slower

@skiphalvingvel:
		asl.w	d2,d0
		asl.w	d2,d1
		move.w	d0,d2
		move.w	d1,d3
		addi.b	#$10,d4
		bcc.s	loc_9D62
		subi.w	#$80,d4
		bcc.s	loc_9D62
		move.w	#$288,d4

loc_9D62:
		move.w	d2,$10(a1)
		move.w	d3,$12(a1)
		neg.w	d2
		neg.w	d4
		dbf	d5,Obj37_Loop	; repeat for number of rings (max 31)

Obj37_ResetCounter:			; XREF: Obj37_Loop
		move.w	#0,(Ring_Count).w ; reset number	of rings to zero
		move.b	#$80,(Update_HUD_Rings).w ; update ring counter
		move.b	#0,(Extra_Life_Flags).w
        moveq   #-1,d0                  ; Move #-1 to d0
        move.b  d0,$1F(a0)       ; Move d0 to new timer
        move.b  d0,(Ring_Spill_Anim_Counter).w      ; Move d0 to old timer (for animated purposes)
		move.w	#SndID_RingLoss,d0
		jsr	(PlaySound_Special).l ;	play ring loss sound

Obj37_Bounce:				; XREF: Obj37_Index
		move.b	(Ring_Spill_Anim_Frame).w,$1A(a0)
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		tst.b	(Water_On).w		; Does the level have water?
		beq.s	@skipbounceslow		; If not, branch and skip underwater checks
		move.w	(Water_Height).w,d6	; Move water level to d6
		cmp.w	$C(a0),d6		; Is the ring object underneath the water level?
		bgt.s	@skipbounceslow		; If not, branch and skip underwater commands
		subi.w	#$E,$12(a0)		; Reduce gravity by $E ($18-$E=$A), giving the underwater effect

@skipbounceslow:
		bmi.s	Obj37_ChkDel
		move.b	(V_Int_Counter+3).w,d0
		add.b	d7,d0
		andi.b	#3,d0
		bne.s	Obj37_ChkDel
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	Obj37_ChkDel
		add.w	d1,$C(a0)
		move.w	$12(a0),d0
		asr.w	#2,d0
		sub.w	d0,$12(a0)
		neg.w	$12(a0)

Obj37_ChkDel:
		subq.b  #1,$1F(a0)  ; Subtract 1   ; RHS Ring Timer fix
        beq.w   DeleteObject       ; If 0, delete ; RHS Ring Timer fix
        cmpi.w	#$FF00,(Camera_Min_Y_Pos).w		; is vertical wrapping enabled?
		beq.w	DisplaySprite			; if so, branch
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	   ; has object moved below level boundary?
		bcs.s	Obj37_Delete	   ; if yes, branch	
;Mercury Lost Rings Flash
		btst	#0, $1F(a0) ; Test the first bit of the timer, so rings flash every other frame.
		beq.w	DisplaySprite      ; If the bit is 0, the ring will appear.
		cmpi.b	#80,$1F(a0) ; Rings will flash during last 80 steps of their life.
		bhi.w	DisplaySprite      ; If the timer is higher than 80, obviously the rings will STAY visible.
		rts
;end Lost Rings Flash
; ===========================================================================

Obj37_Collect:				; XREF: Obj37_Index
		addq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		move.b	#1,$18(a0)
		bsr.w	CollectRing

Obj37_Sparkle:				; XREF: Obj37_Index
		lea	(Ani_obj25).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj37_Delete:				; XREF: Obj37_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4B - giant ring for entry to special stage
; ---------------------------------------------------------------------------

Obj4B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4B_Index(pc,d0.w),d1
		jmp	Obj4B_Index(pc,d1.w)
; ===========================================================================
Obj4B_Index:	dc.w Obj4B_Main-Obj4B_Index
		dc.w Obj4B_Animate-Obj4B_Index
		dc.w Obj4B_Collect-Obj4B_Index
		dc.w Obj4B_Delete-Obj4B_Index
; ===========================================================================

Obj4B_Main:				; XREF: Obj4B_Index
		move.l	#Map_obj4B,4(a0)
		move.w	#$2400,2(a0)
		ori.b	#4,1(a0)
		move.b	#$40,$19(a0)
		tst.b	1(a0)
		bpl.s	Obj4B_Animate
		cmpi.b	#6,(Emerald_Count).w ; do you have 6 emeralds?
		beq.w	Obj4B_Delete	; if yes, branch
		cmpi.w	#50,(Ring_Count).w ; do you have	at least 50 rings?
		bcc.s	Obj4B_Okay	; if yes, branch
		rts	
; ===========================================================================

Obj4B_Okay:				; XREF: Obj4B_Main
		addq.b	#2,$24(a0)
		move.b	#2,$18(a0)
		move.b	#$52,$20(a0)
		move.w	#$C40,(Big_Ring_GFX_Offset).w

Obj4B_Animate:				; XREF: Obj4B_Index
		move.b	(Rings_Anim_Frame).w,$1A(a0)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Obj4B_Collect:				; XREF: Obj4B_Index
		subq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		bsr.w	SingleObjLoad
		bne.w	Obj4B_PlaySnd
		move.b	#$7C,0(a1)	; load giant ring flash	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	a0,$3C(a1)
		move.w	(Object_Space_1+8).w,d0
		cmp.w	8(a0),d0	; has Sonic come from the left?
		bcs.s	Obj4B_PlaySnd	; if yes, branch
		bset	#0,1(a1)	; reverse flash	object

Obj4B_PlaySnd:
		move.w	#SndID_GiantRing,d0
		jsr	(PlaySound_Special).l ;	play giant ring	sound
		bra.s	Obj4B_Animate
; ===========================================================================

Obj4B_Delete:				; XREF: Obj4B_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7C - flash effect when	you collect the	giant ring
; ---------------------------------------------------------------------------

Obj7C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7C_Index(pc,d0.w),d1
		jmp	Obj7C_Index(pc,d1.w)
; ===========================================================================
Obj7C_Index:	dc.w Obj7C_Main-Obj7C_Index
		dc.w Obj7C_ChkDel-Obj7C_Index
		dc.w Obj7C_Delete-Obj7C_Index
; ===========================================================================

Obj7C_Main:				; XREF: Obj7C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj7C,4(a0)
		move.w	#$2462,2(a0)
		ori.b	#4,1(a0)
		move.b	#0,$18(a0)
		move.b	#$20,$19(a0)
		move.b	#$FF,$1A(a0)

Obj7C_ChkDel:				; XREF: Obj7C_Index
		bsr.s	Obj7C_Collect
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj7C_Collect:				; XREF: Obj7C_ChkDel
		subq.b	#1,$1E(a0)
		bpl.s	locret_9F76
		move.b	#1,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#8,$1A(a0)	; has animation	finished?
		bcc.s	Obj7C_End	; if yes, branch
		cmpi.b	#3,$1A(a0)	; is 3rd frame displayed?
		bne.s	locret_9F76	; if not, branch
		movea.l	$3C(a0),a1
		move.b	#6,$24(a1)	; delete giant ring object (Obj4B)
		move.b	#$1C,(Object_Space_1+$1C).w ; make Sonic	invisible
		move.b	#1,(Jumped_In_Big_Ring_Flag).w ; stop	Sonic getting bonuses
		clr.b	(Invincibility_Flag).w	; remove invincibility
		clr.b	(Shield_Flag).w	; remove shield

locret_9F76:
		rts	
; ===========================================================================

Obj7C_End:				; XREF: Obj7C_Collect
		addq.b	#2,$24(a0)
		move.w	#0,(Object_RAM).w ; remove Sonic	object
		addq.l	#4,sp
		rts	
; End of function Obj7C_Collect

; ===========================================================================

Obj7C_Delete:				; XREF: Obj7C_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj25:
	include "objects/animation/obj25.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - rings
; ---------------------------------------------------------------------------
Map_obj25:
	include "mappings/sprite/obj25.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - giant ring
; ---------------------------------------------------------------------------
Map_obj4B:
	include "mappings/sprite/obj4B.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - flash effect when you collect the giant ring
; ---------------------------------------------------------------------------
Map_obj7C:
	include "mappings/sprite/obj7C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Obj26:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj26_Index(pc,d0.w),d1
		jmp	Obj26_Index(pc,d1.w)
; ===========================================================================
Obj26_Index:	dc.w Obj26_Main-Obj26_Index
		dc.w Obj26_Solid-Obj26_Index
		dc.w Obj26_BreakOpen-Obj26_Index
		dc.w Obj26_Animate-Obj26_Index
		dc.w Obj26_Display-Obj26_Index
; ===========================================================================

Obj26_Main:				; XREF: Obj26_Index
		addq.b	#2,$24(a0)
		move.b	#$E,$16(a0)
		move.b	#$E,$17(a0)
		move.l	#Map_obj26,4(a0)
		move.w	#$680,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$F,$19(a0)
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)	; has monitor been broken?
		beq.s	Obj26_NotBroken	; if not, branch
		move.b	#8,$24(a0)	; run "Obj26_Display" routine
		move.b	#$B,$1A(a0)	; use broken monitor frame
		rts	
; ===========================================================================

Obj26_NotBroken:			; XREF: Obj26_Main
		move.b	#$46,$20(a0)
		move.b	$28(a0),$1C(a0)

Obj26_Solid:				; XREF: Obj26_Index
		move.b	$25(a0),d0	; is monitor set to fall?
		beq.s	loc_A1EC	; if not, branch
		subq.b	#2,d0
		bne.s	Obj26_Fall
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,$22(a1)
		bne.w	loc_A1BC
		clr.b	$25(a0)
		bra.w	Obj26_Animate
; ===========================================================================

loc_A1BC:				; XREF: Obj26_Solid
		move.w	#$10,d3
		move.w	8(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Obj26_Animate
; ===========================================================================

Obj26_Fall:				; XREF: Obj26_Solid
		bsr.w	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	Obj26_Animate
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		clr.b	$25(a0)
		bra.w	Obj26_Animate
; ===========================================================================

loc_A1EC:				; XREF: Obj26_Solid
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Obj26_SolidSides
		beq.w	loc_A25C
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,$C(a1)
		bsr.w	loc_74AE
		move.b	#2,$25(a0)
		bra.w	Obj26_Animate
; ===========================================================================

loc_A220:
		tst.b	$3A(a1)
		beq.s	@NotBiting
		move.w	8(a0),d2
		move.w	8(a1),d3
		cmp.w	d3,d2
		bge.s	@Right
		btst	#0,$22(a1)
		beq.s	@NotBiting
		addq.b	#2,$24(a0)
		bra.s	loc_A25C
		
@Right:
		btst	#0,$22(a1)
		bne.s	@NotBiting
		addq.b	#2,$24(a0)
		bra.s	loc_A25C

@NotBiting:
		tst.w	d0
		bmi.w	loc_A230
		beq.s	loc_A246
		tst.w	$10(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	$10(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,8(a1)
		move.w	#0,$14(a1)
		move.w	#0,$10(a1)

loc_A246:
		btst	#1,$22(a1)
		bne.s	loc_A26A
		bset	#5,$22(a1)
		bset	#5,$22(a0)
		bra.s	Obj26_Animate
; ===========================================================================

loc_A25C:
		btst	#5,$22(a0)
		beq.s	Obj26_Animate
		cmp.b	#2,$1C(a1)	; check if in jumping/rolling animation
		beq.s	loc_A26A
		cmp.b	#$17,$1C(a1)	; check if in drowning animation
		beq.s	loc_A26A
		move.w	#1,$1C(a1)

loc_A26A:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)

Obj26_Animate:				; XREF: Obj26_Index
		lea	(Ani_obj26).l,a1
		bsr.w	AnimateSprite

Obj26_Display:				; XREF: Obj26_Index
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================

Obj26_BreakOpen:			; XREF: Obj26_Index
		addq.b	#2,$24(a0)
		move.b	#0,$20(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj26_Explode
		move.b	#$2E,0(a1)	; load monitor contents	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$1C(a0),$1C(a1)

Obj26_Explode:
		bsr.w	SingleObjLoad
		bne.s	Obj26_SetBroken
		move.b	#$27,0(a1)	; load explosion object
		addq.b	#2,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj26_SetBroken:
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#9,$1C(a0)	; set monitor type to broken
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

Obj2E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2E_Index(pc,d0.w),d1
		jsr	Obj2E_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj2E_Index:	dc.w Obj2E_Main-Obj2E_Index
		dc.w Obj2E_Move-Obj2E_Index
		dc.w Obj2E_Delete-Obj2E_Index
; ===========================================================================

Obj2E_Main:				; XREF: Obj2E_Index
		addq.b	#2,$24(a0)
		move.w	#$680,2(a0)
		move.b	#$24,1(a0)
		move.b	#3,$18(a0)
		move.b	#8,$19(a0)
		move.w	#-$300,$12(a0)
		moveq	#0,d0
		move.b	$1C(a0),d0
		addq.b	#2,d0
		move.b	d0,$1A(a0)
		movea.l	#Map_obj26,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#1,a1
		move.l	a1,4(a0)

Obj2E_Move:				; XREF: Obj2E_Index
		tst.w	$12(a0)		; is object moving?
		bpl.w	Obj2E_ChkEggman	; if not, branch
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)	; reduce object	speed
		rts	
; ===========================================================================

Obj2E_ChkEggman:    ; XREF: Obj2E_Move
        addq.b    #2,$24(a0)
        move.w    #29,$1E(a0)
        move.b    $1C(a0),d0
        cmpi.b    #1,d0				; does monitor contain Eggman?
        bne.s    Obj2E_ChkSonic 	; if not, go and check for the next monitor type (1-up icon)
        move.l    a0,a1 			; move a0 to a1, because Touch_ChkHurt wants the damaging object to be in a1
        move.l    a0,-(sp) 			; push a0 on the stack, and decrement stack pointer
        lea    (Object_RAM).w,a0 	; put Sonic's ram address in a0, because Touch_ChkHurt wants the damaged object to be in a0
        jsr    Touch_ChkHurt 		; run the Touch_ChkHurt routine
        move.l    (sp)+,a0 			; pop the previous value of a0 from the stack, and increment stack pointer
        rts 						; The Eggman monitor now does something!
; ===========================================================================

Obj2E_ChkSonic:
		cmpi.b	#2,d0		; does monitor contain Sonic?
		bne.s	Obj2E_ChkShoes

ExtraLife:
		addq.b	#1,(Life_Count).w ; add 1 to the	number of lives	you have
		addq.b	#1,(Update_HUD_Lives).w ; add 1 to the	lives counter
		move.w	#MusID_1UP,d0
		jmp	(PlaySound).l	; play extra life music
; ===========================================================================

Obj2E_ChkShoes:
		cmpi.b	#3,d0		; does monitor contain speed shoes?
		bne.s	Obj2E_ChkShield
		move.w	#$4B0,(Object_Space_1+$34).w ; time limit for the power-up

		tst.b	(Speed_Shoes_Flag).w	; am I already speed shoe'd?
		bne.s	Obj2E_NoShoes	; if so, branch
		move.b	#1,(Speed_Shoes_Flag).w ; speed up the	BG music
		
		move.w	#CmdID_SpeedUp,d0
		jmp	PlaySound_Special
		
Obj2E_NoShoes:
		rts
; ===========================================================================

Obj2E_ChkShield:
		cmpi.b	#4,d0		; does monitor contain a shield?
		bne.s	Obj2E_ChkInvinc
		move.b	#1,(Shield_Flag).w ; give	Sonic a	shield
		move.b	#$38,(Object_Space_7).w ; load shield object	($38)
		move.w	#SndID_Shield,d0
		jmp	(PlaySound).l	; play shield sound
; ===========================================================================

Obj2E_ChkInvinc:
		cmpi.b	#5,d0		; does monitor contain invincibility?
		bne.w	Obj2E_ChkRings
		move.w	#$4B0,(Object_Space_1+$32).w ; time limit for the power-up

		tst.b	(Invincibility_Flag).w	; am I already invincible?
		bne.s	Obj2E_NoInv		; if so, branch

		move.b	#1,(Invincibility_Flag).w ; make	Sonic invincible

		move.b	#$38,(Object_Space_9).w 	; load stars	object ($3801)
		move.b	#1,(Object_Space_9+$1C).w
		move.b	#$38,(Object_Space_10).w 	; load stars	object ($3802)
		move.b	#2,(Object_Space_10+$1C).w
		move.b	#$38,(Object_Space_11).w 	; load stars	object ($3803)
		move.b	#3,(Object_Space_11+$1C).w
		move.b	#$38,(Object_Space_12).w 	; load stars	object ($3804)
		move.b	#4,(Object_Space_12+$1C).w
		
Obj2E_NoInv:
		rts	
; ===========================================================================

Obj2E_ChkRings:
		cmpi.b	#6,d0		; does monitor contain 10 rings?
		bne.s	Obj2E_ChkS
		addi.w	#$A,(Ring_Count).w ; add	10 rings to the	number of rings	you have
		ori.b	#1,(Update_HUD_Rings).w ; update the ring counter
		cmpi.w	#100,(Ring_Count).w ; check if you have 100 rings
		bcs.s	Obj2E_RingSound
		bset	#1,(Extra_Life_Flags).w
		beq.w	ExtraLife
		cmpi.w	#200,(Ring_Count).w ; check if you have 200 rings
		bcs.s	Obj2E_RingSound
		bset	#2,(Extra_Life_Flags).w
		beq.w	ExtraLife

Obj2E_RingSound:
		move.w	#SndID_Ring,d0
		jmp	(PlaySound).l	; play ring sound
; ===========================================================================

Obj2E_ChkS:
		cmpi.b	#7,d0		; does monitor contain 'S'
		bne	Obj2E_ChkGoggles		; if not, branch to Goggle code
		nop

Obj2E_ChkGoggles:	
		cmpi.b	#8,d0		; does monitor contain Goggles?
		bne	Obj2E_ChkEnd		; if not, branch to ChkEnd
		nop

Obj2E_ChkEnd:
		rts			; 'S' and goggles monitors do nothing
; ===========================================================================

Obj2E_Delete:				; XREF: Obj2E_Index
		subq.w	#1,$1E(a0)
		bmi.w	DeleteObject
		rts	
; ---------------------------------------------------------------------------
; Subroutine to	make the sides of a monitor solid
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj26_SolidSides:			; XREF: loc_A1EC
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_A4E6
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.s	loc_A4E6
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		add.w	d2,d3
		bmi.s	loc_A4E6
		add.w	d2,d2
		cmp.w	d2,d3
		bcc.s	loc_A4E6
		tst.b	(No_Player_Physics_Flag).w
		bmi.s	loc_A4E6
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	loc_A4E6
		tst.w	(Debug_Placement_Mode).w
		bne.s	loc_A4E6
		cmp.w	d0,d1
		bcc.s	loc_A4DC
		add.w	d1,d1
		sub.w	d1,d0

loc_A4DC:
		cmpi.w	#$10,d3
		bcs.s	loc_A4EA

loc_A4E2:
		moveq	#1,d1
		rts	
; ===========================================================================

loc_A4E6:
		moveq	#0,d1
		rts	
; ===========================================================================

loc_A4EA:
		moveq	#0,d1
		move.b	$19(a0),d1
		addq.w	#4,d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	8(a1),d1
		sub.w	8(a0),d1
		bmi.s	loc_A4E2
		cmp.w	d2,d1
		bcc.s	loc_A4E2
		moveq	#-1,d1
		rts	
; End of function Obj26_SolidSides

; ===========================================================================
Ani_obj26:
	include "objects/animation/obj26.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - monitors
; ---------------------------------------------------------------------------
Map_obj26:
	include "mappings/sprite/obj26.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0E - Sonic on the title screen
; ---------------------------------------------------------------------------

Obj0E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0E_Index(pc,d0.w),d1
		jmp	Obj0E_Index(pc,d1.w)
; ===========================================================================
Obj0E_Index:	dc.w Obj0E_Main-Obj0E_Index
		dc.w Obj0E_Delay-Obj0E_Index
		dc.w Obj0E_Move-Obj0E_Index
		dc.w Obj0E_Animate-Obj0E_Index
; ===========================================================================

Obj0E_Main:				; XREF: Obj0E_Index
		addq.b	#2,$24(a0)
		move.w	#$F0,8(a0)
		move.w	#$DE,$A(a0)
		move.l	#Map_obj0E,4(a0)
		move.w	#$23D1,2(a0)
		move.b	#1,$18(a0)
		move.b	#29,$1F(a0)	; set time delay to 0.5	seconds
		lea	(Ani_obj0E).l,a1
		bsr.w	AnimateSprite

Obj0E_Delay:				; XREF: Obj0E_Index
		subq.b	#1,$1F(a0)	; subtract 1 from time delay
		bpl.s	Obj0E_Wait	; if time remains, branch
		addq.b	#2,$24(a0)	; go to	next routine
		bra.w	DisplaySprite
; ===========================================================================

Obj0E_Wait:				; XREF: Obj0E_Delay
		rts	
; ===========================================================================

Obj0E_Move:				; XREF: Obj0E_Index
		subq.w	#8,$A(a0)
		cmpi.w	#$96,$A(a0)
		bne.s	Obj0E_Display
		addq.b	#2,$24(a0)

Obj0E_Display:
		bra.w	DisplaySprite
; ===========================================================================
		rts	
; ===========================================================================

Obj0E_Animate:				; XREF: Obj0E_Index
		lea	(Ani_obj0E).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------

Obj0F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0F_Index(pc,d0.w),d1
		jsr	Obj0F_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj0F_Index:	dc.w Obj0F_Main-Obj0F_Index
		dc.w Obj0F_PrsStart-Obj0F_Index
		dc.w locret_A6F8-Obj0F_Index
; ===========================================================================

Obj0F_Main:				; XREF: Obj0F_Index
		addq.b	#2,$24(a0)
		move.w	#$D0,8(a0)
		move.w	#$130,$A(a0)
		move.l	#Map_obj0F,4(a0)
		move.w	#$200,2(a0)
		cmpi.b	#2,$1A(a0)	; is object "PRESS START"?
		bcs.s	Obj0F_PrsStart	; if yes, branch
		addq.b	#2,$24(a0)
		cmpi.b	#3,$1A(a0)	; is the object	"TM"?
		bne.s	locret_A6F8	; if not, branch
		move.w	#$2510,2(a0)	; "TM" specific	code
		move.w	#$170,8(a0)
		move.w	#$F8,$A(a0)

locret_A6F8:				; XREF: Obj0F_Index
		rts	
; ===========================================================================

Obj0F_PrsStart:				; XREF: Obj0F_Index
		lea	(Ani_obj0F).l,a1
		bra.w	AnimateSprite
; ===========================================================================
Ani_obj0E:
	include "objects/animation/obj0E.asm"

Ani_obj0F:
	include "objects/animation/obj0F.asm"

; ---------------------------------------------------------------------------
; Subroutine to	animate	a sprite using an animation script
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AnimateSprite:
		moveq	#0,d0
		move.b	$1C(a0),d0	; move animation number	to d0
		cmp.b	$1D(a0),d0	; is animation set to restart?
		beq.s	Anim_Run	; if not, branch
		move.b	d0,$1D(a0)	; set to "no restart"
		move.b	#0,$1B(a0)	; reset	animation
		move.b	#0,$1E(a0)	; reset	frame duration

Anim_Run:
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	Anim_Wait	; if time remains, branch
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),$1E(a0)	; load frame duration
		moveq	#0,d1
		move.b	$1B(a0),d1	; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		bmi.s	Anim_End_FF	; if animation is complete, branch

Anim_Next:
		move.b	d0,d1
		andi.b	#$1F,d0
		move.b	d0,$1A(a0)	; load sprite number
		move.b	$22(a0),d0
		rol.b	#3,d1
		eor.b	d0,d1
		andi.b	#3,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		addq.b	#1,$1B(a0)	; next frame number

Anim_Wait:
		rts	
; ===========================================================================

Anim_End_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	Anim_End_FE	; if not, branch
		move.b	#0,$1B(a0)	; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_End_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	Anim_End_FD	; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,$1B(a0)	; jump back d0 bytes in	the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_End_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	Anim_End_FC	; if not, branch
		move.b	2(a1,d1.w),$1C(a0) ; read next byte, run that animation

Anim_End_FC:
		addq.b	#1,d0		; is the end flag = $FC	?
		bne.s	Anim_End_FB	; if not, branch
		addq.b	#2,$24(a0)	; jump to next routine

Anim_End_FB:
		addq.b	#1,d0		; is the end flag = $FB	?
		bne.s	Anim_End_FA	; if not, branch
		move.b	#0,$1B(a0)	; reset	animation
		clr.b	$25(a0)		; reset	2nd routine counter

Anim_End_FA:
		addq.b	#1,d0		; is the end flag = $FA	?
		bne.s	Anim_End	; if not, branch
		addq.b	#2,$25(a0)	; jump to next routine

Anim_End:
		rts	
; End of function AnimateSprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------
Map_obj0F:
	include "mappings/sprite/obj0F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Sonic on the title screen
; ---------------------------------------------------------------------------
Map_obj0E:
	include "mappings/sprite/obj0E.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------

Obj2B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2B_Index(pc,d0.w),d1
		jsr	Obj2B_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj2B_Index:	dc.w Obj2B_Main-Obj2B_Index
		dc.w Obj2B_ChgSpeed-Obj2B_Index
; ===========================================================================

Obj2B_Main:				; XREF: Obj2B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2B,4(a0)
		move.w	#$47B,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#9,$20(a0)
		move.b	#$10,$19(a0)
		move.w	#-$700,$12(a0)	; set vertical speed
		move.w	$C(a0),$30(a0)

Obj2B_ChgSpeed:				; XREF: Obj2B_Index
		lea	(Ani_obj2B).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)	; reduce speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0
		bcc.s	Obj2B_ChgAni
		move.w	d0,$C(a0)
		move.w	#-$700,$12(a0)	; set vertical speed

Obj2B_ChgAni:
		move.b	#1,$1C(a0)	; use fast animation
		subi.w	#$C0,d0
		cmp.w	$C(a0),d0
		bcc.s	locret_ABB6
		move.b	#0,$1C(a0)	; use slow animation
		tst.w	$12(a0)		; is Chopper at	its highest point?
		bmi.s	locret_ABB6	; if not, branch
		move.b	#2,$1C(a0)	; use stationary animation

locret_ABB6:
		rts	
; ===========================================================================
Ani_obj2B:
	include "objects/animation/obj2B.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Chopper enemy (GHZ)
; ---------------------------------------------------------------------------
Map_obj2B:
	include "mappings/sprite/obj2B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2C - Jaws enemy (LZ)
; ---------------------------------------------------------------------------

Obj2C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2C_Index(pc,d0.w),d1
		jmp	Obj2C_Index(pc,d1.w)
; ===========================================================================
Obj2C_Index:	dc.w Obj2C_Main-Obj2C_Index
		dc.w Obj2C_Turn-Obj2C_Index
; ===========================================================================

Obj2C_Main:				; XREF: Obj2C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2C,4(a0)
		move.w	#$2486,2(a0)
		ori.b	#4,1(a0)
		move.b	#$A,$20(a0)
		move.b	#4,$18(a0)
		move.b	#$10,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; load object subtype number
		lsl.w	#6,d0		; multiply d0 by 64
		subq.w	#1,d0
		move.w	d0,$30(a0)	; set turn delay time
		move.w	d0,$32(a0)
		move.w	#-$40,$10(a0)	; move Jaws to the left
		btst	#0,$22(a0)	; is Jaws facing left?
		beq.s	Obj2C_Turn	; if yes, branch
		neg.w	$10(a0)		; move Jaws to the right

Obj2C_Turn:				; XREF: Obj2C_Index
		subq.w	#1,$30(a0)	; subtract 1 from turn delay time
		bpl.s	Obj2C_Animate	; if time remains, branch
		move.w	$32(a0),$30(a0)	; reset	turn delay time
		neg.w	$10(a0)		; change speed direction
		bchg	#0,$22(a0)	; change Jaws facing direction
		move.b	#1,$1D(a0)	; reset	animation

Obj2C_Animate:
		lea	(Ani_obj2C).l,a1
		bsr.w	AnimateSprite
		bsr.w	ObjectMove
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj2C:
	include "objects/animation/obj2C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Jaws enemy (LZ)
; ---------------------------------------------------------------------------
Map_obj2C:
	include "mappings/sprite/obj2C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2D - Burrobot enemy (LZ)
; ---------------------------------------------------------------------------

Obj2D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2D_Index(pc,d0.w),d1
		jmp	Obj2D_Index(pc,d1.w)
; ===========================================================================
Obj2D_Index:	dc.w Obj2D_Main-Obj2D_Index
		dc.w Obj2D_Action-Obj2D_Index
; ===========================================================================

Obj2D_Main:				; XREF: Obj2D_Index
		addq.b	#2,$24(a0)
		move.b	#$13,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj2D,4(a0)
		move.w	#$4A6,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#5,$20(a0)
		move.b	#$C,$19(a0)
		addq.b	#6,$25(a0)	; run "Obj2D_ChkSonic" routine
		move.b	#2,$1C(a0)

Obj2D_Action:				; XREF: Obj2D_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj2D_Index2(pc,d0.w),d1
		jsr	Obj2D_Index2(pc,d1.w)
		lea	(Ani_obj2D).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj2D_Index2:	dc.w Obj2D_ChgDir-Obj2D_Index2
		dc.w Obj2D_Move-Obj2D_Index2
		dc.w Obj2D_Jump-Obj2D_Index2
		dc.w Obj2D_ChkSonic-Obj2D_Index2
; ===========================================================================

Obj2D_ChgDir:				; XREF: Obj2D_Index2
		subq.w	#1,$30(a0)
		bpl.s	locret_AD42
		addq.b	#2,$25(a0)
		move.w	#$FF,$30(a0)
		move.w	#$80,$10(a0)
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)	; change direction the Burrobot	is facing
		beq.s	locret_AD42
		neg.w	$10(a0)		; change direction the Burrobot	is moving

locret_AD42:
		rts	
; ===========================================================================

Obj2D_Move:				; XREF: Obj2D_Index2
		subq.w	#1,$30(a0)
		bmi.s	loc_AD84
		bsr.w	ObjectMove
		bchg	#0,$32(a0)
		bne.s	loc_AD78
		move.w	8(a0),d3
		addi.w	#$C,d3
		btst	#0,$22(a0)
		bne.s	loc_AD6A
		subi.w	#$18,d3

loc_AD6A:
		jsr	ObjHitFloor2
		cmpi.w	#$C,d1
		bge.s	loc_AD84
		rts	
; ===========================================================================

loc_AD78:				; XREF: Obj2D_Move
		jsr	ObjHitFloor
		add.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_AD84:				; XREF: Obj2D_Move
		btst	#2,(V_Int_Counter+3).w
		beq.s	loc_ADA4
		subq.b	#2,$25(a0)
		move.w	#$3B,$30(a0)
		move.w	#0,$10(a0)
		move.b	#0,$1C(a0)
		rts	
; ===========================================================================

loc_ADA4:
		addq.b	#2,$25(a0)
		move.w	#-$400,$12(a0)
		move.b	#2,$1C(a0)
		rts	
; ===========================================================================

Obj2D_Jump:				; XREF: Obj2D_Index2
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		bmi.s	locret_ADF0
		move.b	#3,$1C(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_ADF0
		add.w	d1,$C(a0)
		move.w	#0,$12(a0)
		move.b	#1,$1C(a0)
		move.w	#$FF,$30(a0)
		subq.b	#2,$25(a0)
		bsr.w	Obj2D_ChkSonic2

locret_ADF0:
		rts	
; ===========================================================================

Obj2D_ChkSonic:				; XREF: Obj2D_Index2
		move.w	#$60,d2
		bsr.w	Obj2D_ChkSonic2
		bcc.s	locret_AE20
		move.w	(Object_Space_1+$C).w,d0
		sub.w	$C(a0),d0
		bcc.s	locret_AE20
		cmpi.w	#-$80,d0
		bcs.s	locret_AE20
		tst.w	(Debug_Placement_Mode).w
		bne.s	locret_AE20
		subq.b	#2,$25(a0)
		move.w	d1,$10(a0)
		move.w	#-$400,$12(a0)

locret_AE20:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj2D_ChkSonic2:			; XREF: Obj2D_ChkSonic
		move.w	#$80,d1
		bset	#0,$22(a0)
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_AE40
		neg.w	d0
		neg.w	d1
		bclr	#0,$22(a0)

loc_AE40:
		cmp.w	d2,d0
		rts	
; End of function Obj2D_ChkSonic2

; ===========================================================================
Ani_obj2D:
	include "objects/animation/obj2D.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Burrobot enemy (LZ)
; ---------------------------------------------------------------------------
Map_obj2D:
	include "mappings/sprite/obj2D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 2F - large moving platforms (MZ)
; ---------------------------------------------------------------------------

Obj2F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj2F_Index(pc,d0.w),d1
		jmp	Obj2F_Index(pc,d1.w)
; ===========================================================================
Obj2F_Index:	dc.w Obj2F_Main-Obj2F_Index
		dc.w Obj2F_Action-Obj2F_Index

Obj2F_Data:	dc.w Obj2F_Data1-Obj2F_Data 	; collision angle data
		dc.b 0,	$40			; frame	number,	platform width
		dc.w Obj2F_Data3-Obj2F_Data
		dc.b 1,	$40
		dc.w Obj2F_Data2-Obj2F_Data
		dc.b 2,	$20
; ===========================================================================

Obj2F_Main:				; XREF: Obj2F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj2F,4(a0)
		move.w	#$C000,2(a0)
		move.b	#4,1(a0)
		move.b	#5,$18(a0)
		move.w	$C(a0),$2C(a0)
		move.w	8(a0),$2A(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#2,d0
		andi.w	#$1C,d0
		lea	Obj2F_Data(pc,d0.w),a1
		move.w	(a1)+,d0
		lea	Obj2F_Data(pc,d0.w),a2
		move.l	a2,$30(a0)
		move.b	(a1)+,$1A(a0)
		move.b	(a1),$19(a0)
		andi.b	#$F,$28(a0)
		move.b	#$40,$16(a0)
		bset	#4,1(a0)

Obj2F_Action:				; XREF: Obj2F_Index
		bsr.w	Obj2F_Types
		tst.b	$25(a0)
		beq.s	Obj2F_Solid
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,$22(a1)
		bne.w	Obj2F_Slope
		clr.b	$25(a0)
		bra.s	Obj2F_Display
; ===========================================================================

Obj2F_Slope:				; XREF: Obj2F_Action
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		movea.l	$30(a0),a2
		move.w	8(a0),d2
		bsr.w	SlopeObject2
		bra.s	Obj2F_Display
; ===========================================================================

Obj2F_Solid:				; XREF: Obj2F_Action
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$20,d2
		cmpi.b	#2,$1A(a0)
		bne.s	loc_AF8E
		move.w	#$30,d2

loc_AF8E:
		movea.l	$30(a0),a2
		bsr.w	SolidObject2F

Obj2F_Display:				; XREF: Obj2F_Action
		bsr.w	DisplaySprite
		bra.w	Obj2F_ChkDel

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj2F_Types:				; XREF: Obj2F_Action
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj2F_TypeIndex(pc,d0.w),d1
		jmp	Obj2F_TypeIndex(pc,d1.w)
; End of function Obj2F_Types

; ===========================================================================
Obj2F_TypeIndex:dc.w Obj2F_Type00-Obj2F_TypeIndex
		dc.w Obj2F_Type01-Obj2F_TypeIndex
		dc.w Obj2F_Type02-Obj2F_TypeIndex
		dc.w Obj2F_Type03-Obj2F_TypeIndex
		dc.w Obj2F_Type04-Obj2F_TypeIndex
		dc.w Obj2F_Type05-Obj2F_TypeIndex
; ===========================================================================

Obj2F_Type00:				; XREF: Obj2F_TypeIndex
		rts			; type 00 platform doesn't move
; ===========================================================================

Obj2F_Type01:				; XREF: Obj2F_TypeIndex
		move.b	(Oscillation_Data).w,d0
		move.w	#$20,d1
		bra.s	Obj2F_Move
; ===========================================================================

Obj2F_Type02:				; XREF: Obj2F_TypeIndex
		move.b	(Oscillation_Data+$4).w,d0
		move.w	#$30,d1
		bra.s	Obj2F_Move
; ===========================================================================

Obj2F_Type03:				; XREF: Obj2F_TypeIndex
		move.b	(Oscillation_Data+$8).w,d0
		move.w	#$40,d1
		bra.s	Obj2F_Move
; ===========================================================================

Obj2F_Type04:				; XREF: Obj2F_TypeIndex
		move.b	(Oscillation_Data+$C).w,d0
		move.w	#$60,d1

Obj2F_Move:
		btst	#3,$28(a0)
		beq.s	loc_AFF2
		neg.w	d0
		add.w	d1,d0

loc_AFF2:
		move.w	$2C(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; update position on y-axis
		rts	
; ===========================================================================

Obj2F_Type05:				; XREF: Obj2F_TypeIndex
		move.b	$34(a0),d0
		tst.b	$25(a0)
		bne.s	loc_B010
		subq.b	#2,d0
		bcc.s	loc_B01C
		moveq	#0,d0
		bra.s	loc_B01C
; ===========================================================================

loc_B010:
		addq.b	#4,d0
		cmpi.b	#$40,d0
		bcs.s	loc_B01C
		move.b	#$40,d0

loc_B01C:
		move.b	d0,$34(a0)
		jsr	(CalcSine).l
		lsr.w	#4,d0
		move.w	d0,d1
		add.w	$2C(a0),d0
		move.w	d0,$C(a0)
		cmpi.b	#$20,$34(a0)
		bne.s	loc_B07A
		tst.b	$35(a0)
		bne.s	loc_B07A
		move.b	#1,$35(a0)
		bsr.w	SingleObjLoad2
		bne.s	loc_B07A
		move.b	#$35,0(a1)	; load sitting flame object
		move.w	8(a0),8(a1)
		move.w	$2C(a0),$2C(a1)
		addq.w	#8,$2C(a1)
		subq.w	#3,$2C(a1)
		subi.w	#$40,8(a1)
		move.l	$30(a0),$30(a1)
		move.l	a0,$38(a1)
		movea.l	a0,a2
		bsr.s	sub_B09C

loc_B07A:
		moveq	#0,d2
		lea	$36(a0),a2
		move.b	(a2)+,d2
		subq.b	#1,d2
		bcs.s	locret_B09A

loc_B086:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.w	#Object_RAM,d0
		movea.w	d0,a1
		move.w	d1,$3C(a1)
		dbf	d2,loc_B086

locret_B09A:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_B09C:
		lea	$36(a2),a2
		moveq	#0,d0
		move.b	(a2),d0
		addq.b	#1,(a2)
		lea	1(a2,d0.w),a2
		move.w	a1,d0
		subi.w	#Object_RAM,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,(a2)
		rts	
; End of function sub_B09C

; ===========================================================================

Obj2F_ChkDel:				; XREF: Obj2F_Display
		tst.b	$35(a0)
		beq.s	loc_B0C6
		tst.b	1(a0)
		bpl.s	Obj2F_DelFlames

loc_B0C6:
		move.w	$2A(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================

Obj2F_DelFlames:			; XREF: Obj2F_ChkDel
		moveq	#0,d2

loc_B0E8:
		lea	$36(a0),a2
		move.b	(a2),d2
		clr.b	(a2)+
		subq.b	#1,d2
		bcs.s	locret_B116

loc_B0F4:
		moveq	#0,d0
		move.b	(a2),d0
		clr.b	(a2)+
		lsl.w	#6,d0
		addi.w	#Object_RAM,d0
		movea.w	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,loc_B0F4
		move.b	#0,$35(a0)
		move.b	#0,$34(a0)

locret_B116:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Collision data for large moving platforms (MZ)
; ---------------------------------------------------------------------------
Obj2F_Data1:	incbin	data/platform_MZ/mz_pfm1.bin
		even
Obj2F_Data2:	incbin	data/platform_MZ/mz_pfm2.bin
		even
Obj2F_Data3:	incbin	data/platform_MZ/mz_pfm3.bin
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 35 - fireball that sits on the	floor (MZ)
; (appears when	you walk on sinking platforms)
; ---------------------------------------------------------------------------

Obj35:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj35_Index(pc,d0.w),d1
		jmp	Obj35_Index(pc,d1.w)
; ===========================================================================
Obj35_Index:	dc.w Obj35_Main-Obj35_Index
		dc.w loc_B238-Obj35_Index
		dc.w Obj35_Move-Obj35_Index
; ===========================================================================

Obj35_Main:				; XREF: Obj35_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj14,4(a0)
		move.w	#$345,2(a0)
		move.w	8(a0),$2A(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$8B,$20(a0)
		move.b	#8,$19(a0)
		move.w	#SndID_Burn,d0
		jsr	(PlaySound_Special).l ;	play flame sound
		tst.b	$28(a0)
		beq.s	loc_B238
		addq.b	#2,$24(a0)
		bra.w	Obj35_Move
; ===========================================================================

loc_B238:				; XREF: Obj35_Index
		movea.l	$30(a0),a1
		move.w	8(a0),d1
		sub.w	$2A(a0),d1
		addi.w	#$C,d1
		move.w	d1,d0
		lsr.w	#1,d0
		move.b	(a1,d0.w),d0
		neg.w	d0
		add.w	$2C(a0),d0
		move.w	d0,d2
		add.w	$3C(a0),d0
		move.w	d0,$C(a0)
		cmpi.w	#$84,d1
		bcc.s	loc_B2B0
		addi.l	#$10000,8(a0)
		cmpi.w	#$80,d1
		bcc.s	loc_B2B0
		move.l	8(a0),d0
		addi.l	#$80000,d0
		andi.l	#$FFFFF,d0
		bne.s	loc_B2B0
		bsr.w	SingleObjLoad2
		bne.s	loc_B2B0
		move.b	#$35,0(a1)
		move.w	8(a0),8(a1)
		move.w	d2,$2C(a1)
		move.w	$3C(a0),$3C(a1)
		move.b	#1,$28(a1)
		movea.l	$38(a0),a2
		bsr.w	sub_B09C

loc_B2B0:
		bra.s	Obj35_Animate
; ===========================================================================

Obj35_Move:				; XREF: Obj35_Index
		move.w	$2C(a0),d0
		add.w	$3C(a0),d0
		move.w	d0,$C(a0)

Obj35_Animate:				; XREF: loc_B238
		lea	(Ani_obj35).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================
Ani_obj35:
	include "objects/animation/obj35.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - large moving platforms (MZ)
; ---------------------------------------------------------------------------
Map_obj2F:
	include "mappings/sprite/obj2F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - lava balls (MZ, SLZ)
; ---------------------------------------------------------------------------
Map_obj14:
	include "mappings/sprite/obj14.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 30 - large green glassy blocks	(MZ)
; ---------------------------------------------------------------------------

Obj30:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj30_Index(pc,d0.w),d1
		jsr	Obj30_Index(pc,d1.w)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj30_Delete
		bra.w	DisplaySprite
; ===========================================================================

Obj30_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj30_Index:	dc.w Obj30_Main-Obj30_Index
		dc.w Obj30_Block012-Obj30_Index
		dc.w Obj30_Reflect012-Obj30_Index
		dc.w Obj30_Block34-Obj30_Index
		dc.w Obj30_Reflect34-Obj30_Index

Obj30_Vars1:	dc.b 2,	0, 0	; routine num, y-axis dist from	origin,	frame num
		dc.b 4,	0, 1
Obj30_Vars2:	dc.b 6,	0, 2
		dc.b 8,	0, 1
; ===========================================================================

Obj30_Main:				; XREF: Obj30_Index
		lea	(Obj30_Vars1).l,a2
		moveq	#1,d1
		move.b	#$48,$16(a0)
		cmpi.b	#3,$28(a0)	; is object type 0/1/2 ?
		bcs.s	loc_B40C	; if yes, branch
		lea	(Obj30_Vars2).l,a2
		moveq	#1,d1
		move.b	#$38,$16(a0)

loc_B40C:
		movea.l	a0,a1
		bra.s	Obj30_Load	; load main object
; ===========================================================================

Obj30_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_B480

Obj30_Load:				; XREF: Obj30_Main
		move.b	(a2)+,$24(a1)
		move.b	#$30,0(a1)
		move.w	8(a0),8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		move.l	#Map_obj30,4(a1)
		move.w	#$C38E,2(a1)
		move.b	#4,1(a1)
		move.w	$C(a1),$30(a1)
		move.b	$28(a0),$28(a1)
		move.b	#$20,$19(a1)
		move.b	#4,$18(a1)
		move.b	(a2)+,$1A(a1)
		move.l	a0,$3C(a1)
		dbf	d1,Obj30_Loop	; repeat once to load "reflection object"

		move.b	#$10,$19(a1)
		move.b	#3,$18(a1)
		addq.b	#8,$28(a1)
		andi.b	#$F,$28(a1)

loc_B480:
		move.w	#$90,$32(a0)
		bset	#4,1(a0)

Obj30_Block012:				; XREF: Obj30_Index
		bsr.w	Obj30_Types
		move.w	#$2B,d1
		move.w	#$48,d2
		move.w	#$49,d3
		move.w	8(a0),d4
		bra.w	SolidObject
; ===========================================================================

Obj30_Reflect012:			; XREF: Obj30_Index
		movea.l	$3C(a0),a1
		move.w	$32(a1),$32(a0)
		bra.w	Obj30_Types
; ===========================================================================

Obj30_Block34:				; XREF: Obj30_Index
		bsr.w	Obj30_Types
		move.w	#$2B,d1
		move.w	#$38,d2
		move.w	#$39,d3
		move.w	8(a0),d4
		bra.w	SolidObject
; ===========================================================================

Obj30_Reflect34:			; XREF: Obj30_Index
		movea.l	$3C(a0),a1
		move.w	$32(a1),$32(a0)
		move.w	$C(a1),$30(a0)
		bra.w	*+4

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj30_Types:				; XREF: Obj30_Block012; et al
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj30_TypeIndex(pc,d0.w),d1
		jmp	Obj30_TypeIndex(pc,d1.w)
; End of function Obj30_Types

; ===========================================================================
Obj30_TypeIndex:dc.w Obj30_Type00-Obj30_TypeIndex
		dc.w Obj30_Type01-Obj30_TypeIndex
		dc.w Obj30_Type02-Obj30_TypeIndex
		dc.w Obj30_Type03-Obj30_TypeIndex
		dc.w Obj30_Type04-Obj30_TypeIndex
; ===========================================================================

Obj30_Type00:				; XREF: Obj30_TypeIndex
		rts	
; ===========================================================================

Obj30_Type01:				; XREF: Obj30_TypeIndex
		move.b	(Oscillation_Data+$10).w,d0
		move.w	#$40,d1
		bra.s	loc_B514
; ===========================================================================

Obj30_Type02:				; XREF: Obj30_TypeIndex
		move.b	(Oscillation_Data+$10).w,d0
		move.w	#$40,d1
		neg.w	d0
		add.w	d1,d0

loc_B514:				; XREF: Obj30_Type01
		btst	#3,$28(a0)
		beq.s	loc_B526
		neg.w	d0
		add.w	d1,d0
		lsr.b	#1,d0
		addi.w	#$20,d0

loc_B526:
		bra.w	loc_B5EE
; ===========================================================================

Obj30_Type03:				; XREF: Obj30_TypeIndex
		btst	#3,$28(a0)
		beq.s	loc_B53E
		move.b	(Oscillation_Data+$10).w,d0
		subi.w	#$10,d0
		bra.w	loc_B5EE
; ===========================================================================

loc_B53E:
		btst	#3,$22(a0)
		bne.s	loc_B54E
		bclr	#0,$34(a0)
		bra.s	loc_B582
; ===========================================================================

loc_B54E:
		tst.b	$34(a0)
		bne.s	loc_B582
		move.b	#1,$34(a0)
		bset	#0,$35(a0)
		beq.s	loc_B582
		bset	#7,$34(a0)
		move.w	#$10,$36(a0)
		move.b	#$A,$38(a0)
		cmpi.w	#$40,$32(a0)
		bne.s	loc_B582
		move.w	#$40,$36(a0)

loc_B582:
		tst.b	$34(a0)
		bpl.s	loc_B5AA
		tst.b	$38(a0)
		beq.s	loc_B594
		subq.b	#1,$38(a0)
		bne.s	loc_B5AA

loc_B594:
		tst.w	$32(a0)
		beq.s	loc_B5A4
		subq.w	#1,$32(a0)
		subq.w	#1,$36(a0)
		bne.s	loc_B5AA

loc_B5A4:
		bclr	#7,$34(a0)

loc_B5AA:
		move.w	$32(a0),d0
		bra.s	loc_B5EE
; ===========================================================================

Obj30_Type04:				; XREF: Obj30_TypeIndex
		btst	#3,$28(a0)
		beq.s	Obj30_ChkSwitch
		move.b	(Oscillation_Data+$10).w,d0
		subi.w	#$10,d0
		bra.s	loc_B5EE
; ===========================================================================

Obj30_ChkSwitch:			; XREF: Obj30_Type04
		tst.b	$34(a0)
		bne.s	loc_B5E0
		lea	(Switch_Statuses).w,a2
		moveq	#0,d0
		move.b	$28(a0),d0	; load object type number
		lsr.w	#4,d0		; read only the	first nybble
		tst.b	(a2,d0.w)	; has switch number d0 been pressed?
		beq.s	loc_B5EA	; if not, branch
		move.b	#1,$34(a0)

loc_B5E0:
		tst.w	$32(a0)
		beq.s	loc_B5EA
		subq.w	#2,$32(a0)

loc_B5EA:
		move.w	$32(a0),d0

loc_B5EE:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - large green	glassy blocks (MZ)
; ---------------------------------------------------------------------------
Map_obj30:
	include "mappings/sprite/obj30.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 31 - stomping metal blocks on chains (MZ)
; ---------------------------------------------------------------------------

Obj31:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj31_Index(pc,d0.w),d1
		jmp	Obj31_Index(pc,d1.w)
; ===========================================================================
Obj31_Index:	dc.w Obj31_Main-Obj31_Index
		dc.w loc_B798-Obj31_Index
		dc.w loc_B7FE-Obj31_Index
		dc.w Obj31_Display2-Obj31_Index
		dc.w loc_B7E2-Obj31_Index

Obj31_SwchNums:	dc.b 0,	0		; switch number, obj number
		dc.b 1,	0

Obj31_Var:	dc.b 2,	0, 0		; XREF: ROM:0000B6E0o
		dc.b 4,	$1C, 1		; routine number, y-position, frame number
		dc.b 8,	$CC, 3
		dc.b 6,	$F0, 2

word_B6A4:	dc.w $7000, $A000
		dc.w $5000, $7800
		dc.w $3800, $5800
		dc.w $B800
; ===========================================================================

Obj31_Main:				; XREF: Obj31_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		bpl.s	loc_B6CE
		andi.w	#$7F,d0
		add.w	d0,d0
		lea	Obj31_SwchNums(pc,d0.w),a2
		move.b	(a2)+,$3A(a0)
		move.b	(a2)+,d0
		move.b	d0,$28(a0)

loc_B6CE:
		andi.b	#$F,d0
		add.w	d0,d0
		move.w	word_B6A4(pc,d0.w),d2
		tst.w	d0
		bne.s	loc_B6E0
		move.w	d2,$32(a0)

loc_B6E0:
		lea	(Obj31_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj31_MakeStomper
; ===========================================================================

Obj31_Loop:
		bsr.w	SingleObjLoad2
		bne.w	Obj31_SetSize

Obj31_MakeStomper:			; XREF: Obj31_Main
		move.b	(a2)+,$24(a1)
		move.b	#$31,0(a1)
		move.w	8(a0),8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		move.l	#Map_obj31,4(a1)
		move.w	#$300,2(a1)
		move.b	#4,1(a1)
		move.w	$C(a1),$30(a1)
		move.b	$28(a0),$28(a1)
		move.b	#$10,$19(a1)
		move.w	d2,$34(a1)
		move.b	#4,$18(a1)
		move.b	(a2)+,$1A(a1)
		cmpi.b	#1,$1A(a1)
		bne.s	loc_B76A
		subq.w	#1,d1
		move.b	$28(a0),d0
		andi.w	#$F0,d0
		cmpi.w	#$20,d0
		beq.s	Obj31_MakeStomper
		move.b	#$38,$19(a1)
		move.b	#$90,$20(a1)
		addq.w	#1,d1

loc_B76A:
		move.l	a0,$3C(a1)
		dbf	d1,Obj31_Loop

		move.b	#3,$18(a1)

Obj31_SetSize:
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.b	#$E,d0
		lea	Obj31_Var2(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		bra.s	loc_B798
; ===========================================================================
Obj31_Var2:	dc.b $38, 0		; width, frame number
		dc.b $30, 9
		dc.b $10, $A
; ===========================================================================

loc_B798:				; XREF: Obj31_Index
		bsr.w	Obj31_Types
		move.w	$C(a0),(Obj31_Y_Pos).w
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$C,d2
		move.w	#$D,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		beq.s	Obj31_Display
		cmpi.b	#$10,$32(a0)
		bcc.s	Obj31_Display
		movea.l	a0,a2
		lea	(Object_RAM).w,a0
		jsr	KillSonic
		movea.l	a2,a0

Obj31_Display:
		bsr.w	DisplaySprite
		bra.w	Obj31_ChkDel
; ===========================================================================

loc_B7E2:				; XREF: Obj31_Index
		move.b	#$80,$16(a0)
		bset	#4,1(a0)
		movea.l	$3C(a0),a1
		move.b	$32(a1),d0
		lsr.b	#5,d0
		addq.b	#3,d0
		move.b	d0,$1A(a0)

loc_B7FE:				; XREF: Obj31_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$32(a1),d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)

Obj31_Display2:				; XREF: Obj31_Index
		bsr.w	DisplaySprite

Obj31_ChkDel:				; XREF: Obj31_Display
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================

Obj31_Types:				; XREF: loc_B798
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj31_TypeIndex(pc,d0.w),d1
		jmp	Obj31_TypeIndex(pc,d1.w)
; ===========================================================================
Obj31_TypeIndex:dc.w Obj31_Type00-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
		dc.w Obj31_Type03-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
		dc.w Obj31_Type03-Obj31_TypeIndex
		dc.w Obj31_Type01-Obj31_TypeIndex
; ===========================================================================

Obj31_Type00:				; XREF: Obj31_TypeIndex
		lea	(Switch_Statuses).w,a2 ; load	switch statuses
		moveq	#0,d0
		move.b	$3A(a0),d0	; move number 0	or 1 to	d0
		tst.b	(a2,d0.w)	; has switch (d0) been pressed?
		beq.s	loc_B8A8	; if not, branch
		tst.w	(Obj31_Y_Pos).w
		bpl.s	loc_B872
		cmpi.b	#$10,$32(a0)
		beq.s	loc_B8A0

loc_B872:
		tst.w	$32(a0)
		beq.s	loc_B8A0
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$F,d0
		bne.s	loc_B892
		tst.b	1(a0)
		bpl.s	loc_B892
		move.w	#SndID_ChainRise,d0
		jsr	(PlaySound_Special).l ;	play rising chain sound

loc_B892:
		subi.w	#$80,$32(a0)
		bcc.s	Obj31_Restart
		move.w	#0,$32(a0)

loc_B8A0:
		move.w	#0,$12(a0)
		bra.s	Obj31_Restart
; ===========================================================================

loc_B8A8:				; XREF: Obj31_Type00
		move.w	$34(a0),d1
		cmp.w	$32(a0),d1
		beq.s	Obj31_Restart
		move.w	$12(a0),d0
		addi.w	#$70,$12(a0)	; make object fall
		add.w	d0,$32(a0)
		cmp.w	$32(a0),d1
		bhi.s	Obj31_Restart
		move.w	d1,$32(a0)
		move.w	#0,$12(a0)	; stop object falling
		tst.b	1(a0)
		bpl.s	Obj31_Restart
		move.w	#SndID_ChainStomp,d0
		jsr	(PlaySound_Special).l ;	play stomping sound

Obj31_Restart:
		moveq	#0,d0
		move.b	$32(a0),d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		rts	
; ===========================================================================

Obj31_Type01:				; XREF: Obj31_TypeIndex
		tst.w	$36(a0)
		beq.s	loc_B938
		tst.w	$38(a0)
		beq.s	loc_B902
		subq.w	#1,$38(a0)
		bra.s	loc_B97C
; ===========================================================================

loc_B902:
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$F,d0
		bne.s	loc_B91C
		tst.b	1(a0)
		bpl.s	loc_B91C
		move.w	#SndID_ChainRise,d0
		jsr	(PlaySound_Special).l ;	play rising chain sound

loc_B91C:
		subi.w	#$80,$32(a0)
		bcc.s	loc_B97C
		move.w	#0,$32(a0)
		move.w	#0,$12(a0)
		move.w	#0,$36(a0)
		bra.s	loc_B97C
; ===========================================================================

loc_B938:				; XREF: Obj31_Type01
		move.w	$34(a0),d1
		cmp.w	$32(a0),d1
		beq.s	loc_B97C
		move.w	$12(a0),d0
		addi.w	#$70,$12(a0)	; make object fall
		add.w	d0,$32(a0)
		cmp.w	$32(a0),d1
		bhi.s	loc_B97C
		move.w	d1,$32(a0)
		move.w	#0,$12(a0)	; stop object falling
		move.w	#1,$36(a0)
		move.w	#$3C,$38(a0)
		tst.b	1(a0)
		bpl.s	loc_B97C
		move.w	#SndID_ChainStomp,d0
		jsr	(PlaySound_Special).l ;	play stomping sound

loc_B97C:
		bra.w	Obj31_Restart
; ===========================================================================

Obj31_Type03:				; XREF: Obj31_TypeIndex
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_B98C
		neg.w	d0

loc_B98C:
		cmpi.w	#$90,d0
		bcc.s	loc_B996
		addq.b	#1,$28(a0)

loc_B996:
		bra.w	Obj31_Restart
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 45 - spiked metal block from beta version (MZ)
; ---------------------------------------------------------------------------

Obj45:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj45_Index(pc,d0.w),d1
		jmp	Obj45_Index(pc,d1.w)
; ===========================================================================
Obj45_Index:	dc.w Obj45_Main-Obj45_Index
		dc.w Obj45_Solid-Obj45_Index
		dc.w loc_BA8E-Obj45_Index
		dc.w Obj45_Display-Obj45_Index
		dc.w loc_BA7A-Obj45_Index

Obj45_Var:	dc.b	2,   4,	  0	; routine number, x-position, frame number
		dc.b	4, $E4,	  1
		dc.b	8, $34,	  3
		dc.b	6, $28,	  2

word_B9BE:	dc.w $3800
		dc.w -$6000
		dc.w $5000
; ===========================================================================

Obj45_Main:				; XREF: Obj45_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	word_B9BE(pc,d0.w),d2
		lea	(Obj45_Var).l,a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj45_Load
; ===========================================================================

Obj45_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_BA52

Obj45_Load:				; XREF: Obj45_Main
		move.b	(a2)+,$24(a1)
		move.b	#$45,0(a1)
		move.w	$C(a0),$C(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	8(a0),d0
		move.w	d0,8(a1)
		move.l	#Map_obj45,4(a1)
		move.w	#$300,2(a1)
		move.b	#4,1(a1)
		move.w	8(a1),$30(a1)
		move.w	8(a0),$3A(a1)
		move.b	$28(a0),$28(a1)
		move.b	#$20,$19(a1)
		move.w	d2,$34(a1)
		move.b	#4,$18(a1)
		cmpi.b	#1,(a2)
		bne.s	loc_BA40
		move.b	#$91,$20(a1)

loc_BA40:
		move.b	(a2)+,$1A(a1)
		move.l	a0,$3C(a1)
		dbf	d1,Obj45_Loop	; repeat 3 times

		move.b	#3,$18(a1)

loc_BA52:
		move.b	#$10,$19(a0)

Obj45_Solid:				; XREF: Obj45_Index
		move.w	8(a0),-(sp)
		bsr.w	Obj45_Move
		move.w	#$17,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	(sp)+,d4
		bsr.w	SolidObject
		bsr.w	DisplaySprite
		bra.w	Obj45_ChkDel
; ===========================================================================

loc_BA7A:				; XREF: Obj45_Index
		movea.l	$3C(a0),a1
		move.b	$32(a1),d0
		addi.b	#$10,d0
		lsr.b	#5,d0
		addq.b	#3,d0
		move.b	d0,$1A(a0)

loc_BA8E:				; XREF: Obj45_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$32(a1),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)

Obj45_Display:				; XREF: Obj45_Index
		bsr.w	DisplaySprite

Obj45_ChkDel:				; XREF: Obj45_Solid
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj45_Move:				; XREF: Obj45_Solid
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	off_BAD6(pc,d0.w),d1
		jmp	off_BAD6(pc,d1.w)
; End of function Obj45_Move

; ===========================================================================
off_BAD6:	dc.w loc_BADA-off_BAD6
		dc.w loc_BADA-off_BAD6
; ===========================================================================

loc_BADA:				; XREF: off_BAD6
		tst.w	$36(a0)
		beq.s	loc_BB08
		tst.w	$38(a0)
		beq.s	loc_BAEC
		subq.w	#1,$38(a0)
		bra.s	loc_BB3C
; ===========================================================================

loc_BAEC:
		subi.w	#$80,$32(a0)
		bcc.s	loc_BB3C
		move.w	#0,$32(a0)
		move.w	#0,$10(a0)
		move.w	#0,$36(a0)
		bra.s	loc_BB3C
; ===========================================================================

loc_BB08:				; XREF: loc_BADA
		move.w	$34(a0),d1
		cmp.w	$32(a0),d1
		beq.s	loc_BB3C
		move.w	$10(a0),d0
		addi.w	#$70,$10(a0)
		add.w	d0,$32(a0)
		cmp.w	$32(a0),d1
		bhi.s	loc_BB3C
		move.w	d1,$32(a0)
		move.w	#0,$10(a0)
		move.w	#1,$36(a0)
		move.w	#$3C,$38(a0)

loc_BB3C:
		moveq	#0,d0
		move.b	$32(a0),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - metal stomping blocks on chains (MZ)
; ---------------------------------------------------------------------------
Map_obj31:
	include "mappings/sprite/obj31.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spiked metal block from beta version (MZ)
; ---------------------------------------------------------------------------
Map_obj45:
	include "mappings/sprite/obj45.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 32 - switches (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Obj32:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj32_Index(pc,d0.w),d1
		jmp	Obj32_Index(pc,d1.w)
; ===========================================================================
Obj32_Index:	dc.w Obj32_Main-Obj32_Index
		dc.w Obj32_Pressed-Obj32_Index
; ===========================================================================

Obj32_Main:				; XREF: Obj32_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj32,4(a0)
		move.w	#$4513,2(a0)	; MZ specific code
		cmpi.b	#2,(Current_Zone).w
		beq.s	loc_BD60
		move.w	#$513,2(a0)	; SYZ, LZ and SBZ specific code

loc_BD60:
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		addq.w	#3,$C(a0)

Obj32_Pressed:				; XREF: Obj32_Index
		tst.b	1(a0)
		bpl.s	Obj32_Display
		move.w	#$1B,d1
		move.w	#5,d2
		move.w	#5,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		bclr	#0,$1A(a0)	; use "unpressed" frame
		move.b	$28(a0),d0
		andi.w	#$F,d0
		lea	(Switch_Statuses).w,a3
		lea	(a3,d0.w),a3
		moveq	#0,d3
		btst	#6,$28(a0)
		beq.s	loc_BDB2
		moveq	#7,d3

loc_BDB2:
		tst.b	$28(a0)
		bpl.s	loc_BDBE
		bsr.w	Obj32_MZBlock
		bne.s	loc_BDC8

loc_BDBE:
		tst.b	$25(a0)
		bne.s	loc_BDC8
		bclr	d3,(a3)
		bra.s	loc_BDDE
; ===========================================================================

loc_BDC8:
		tst.b	(a3)
		bne.s	loc_BDD6
		move.w	#SndID_Switch,d0
		jsr	(PlaySound_Special).l ;	play switch sound

loc_BDD6:
		bset	d3,(a3)
		bset	#0,$1A(a0)	; use "pressed"	frame

loc_BDDE:
		btst	#5,$28(a0)
		beq.s	Obj32_Display
		subq.b	#1,$1E(a0)
		bpl.s	Obj32_Display
		move.b	#7,$1E(a0)
		bchg	#1,$1A(a0)

Obj32_Display:
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj32_Delete
		rts	
; ===========================================================================

Obj32_Delete:
		bsr.w	DeleteObject
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj32_MZBlock:				; XREF: Obj32_Pressed
		move.w	d3,-(sp)
		move.w	8(a0),d2
		move.w	$C(a0),d3
		subi.w	#$10,d2
		subq.w	#8,d3
		move.w	#$20,d4
		move.w	#$10,d5
		lea	(Dynamic_Object_RAM).w,a1 ; begin checking object RAM
		move.w	#((Object_RAM_End-(Dynamic_Object_RAM))/$40)-1,d6

Obj32_MZLoop:
		tst.b	1(a1)
		bpl.s	loc_BE4E
		cmpi.b	#$33,(a1)	; is the object	a green	MZ block?
		beq.s	loc_BE5E	; if yes, branch

loc_BE4E:
		lea	$40(a1),a1	; check	next object
		dbf	d6,Obj32_MZLoop	; repeat $5F times

		move.w	(sp)+,d3
		moveq	#0,d0

locret_BE5A:
		rts	
; ===========================================================================
Obj32_MZData:	dc.b $10, $10
; ===========================================================================

loc_BE5E:				; XREF: Obj32_MZBlock
		moveq	#1,d0
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	Obj32_MZData-2(pc,d0.w),a2
		move.b	(a2)+,d1
		ext.w	d1
		move.w	8(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_BE80
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_BE84
		bra.s	loc_BE4E
; ===========================================================================

loc_BE80:
		cmp.w	d4,d0
		bhi.s	loc_BE4E

loc_BE84:
		move.b	(a2)+,d1
		ext.w	d1
		move.w	$C(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_BE9A
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_BE9E
		bra.s	loc_BE4E
; ===========================================================================

loc_BE9A:
		cmp.w	d5,d0
		bhi.s	loc_BE4E

loc_BE9E:
		move.w	(sp)+,d3
		moveq	#1,d0
		rts	
; End of function Obj32_MZBlock

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - switches (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj32:
	include "mappings/sprite/obj32.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 33 - pushable blocks (MZ, LZ)
; ---------------------------------------------------------------------------

Obj33:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj33_Index(pc,d0.w),d1
		jmp	Obj33_Index(pc,d1.w)
; ===========================================================================
Obj33_Index:	dc.w Obj33_Main-Obj33_Index
		dc.w loc_BF6E-Obj33_Index
		dc.w loc_C02C-Obj33_Index

Obj33_Var:	dc.b $10, 0	; object width,	frame number
		dc.b $40, 1
; ===========================================================================

Obj33_Main:				; XREF: Obj33_Index
		addq.b	#2,$24(a0)
		move.b	#$F,$16(a0)
		move.b	#$F,$17(a0)
		move.l	#Map_obj33,4(a0)
		move.w	#$42B8,2(a0)	; MZ specific code
		cmpi.b	#1,(Current_Zone).w
		bne.s	loc_BF16
		move.w	#$43DE,2(a0)	; LZ specific code

loc_BF16:
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$36(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		andi.w	#$E,d0
		lea	Obj33_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		tst.b	$28(a0)
		beq.s	Obj33_ChkGone
		move.w	#$C2B8,2(a0)

Obj33_ChkGone:
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_BF6E
		bclr	#7,2(a2,d0.w)
		bset	#0,2(a2,d0.w)
		bne.w	DeleteObject

loc_BF6E:				; XREF: Obj33_Index
		tst.b	$32(a0)
		bne.w	loc_C046
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	loc_C186
		cmpi.w	#$200,(Current_Zone_And_Act).w ; is the level MZ act 1?
		bne.s	loc_BFC6	; if not, branch
		bclr	#7,$28(a0)
		move.w	8(a0),d0
		cmpi.w	#$A20,d0
		bcs.s	loc_BFC6
		cmpi.w	#$AA1,d0
		bcc.s	loc_BFC6
		move.w	(Obj31_Y_Pos).w,d0
		subi.w	#$1C,d0
		move.w	d0,$C(a0)
		bset	#7,(Obj31_Y_Pos).w
		bset	#7,$28(a0)

loc_BFC6:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_BFE6
		bra.w	DisplaySprite
; ===========================================================================

loc_BFE6:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	loc_C016
		move.w	$34(a0),8(a0)
		move.w	$36(a0),$C(a0)
		move.b	#4,$24(a0)
		bra.s	loc_C02C
; ===========================================================================

loc_C016:
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_C028
		bclr	#0,2(a2,d0.w)

loc_C028:
		bra.w	DeleteObject
; ===========================================================================

loc_C02C:				; XREF: Obj33_Index
		bsr.w	ChkObjOnScreen2
		beq.s	locret_C044
		move.b	#2,$24(a0)
		clr.b	$32(a0)
		clr.w	$10(a0)
		clr.w	$12(a0)

locret_C044:
		rts	
; ===========================================================================

loc_C046:				; XREF: loc_BF6E
		move.w	8(a0),-(sp)
		cmpi.b	#4,$25(a0)
		bcc.s	loc_C056
		bsr.w	ObjectMove

loc_C056:
		btst	#1,$22(a0)
		beq.s	loc_C0A0
		addi.w	#$18,$12(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	loc_C09E
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		bclr	#1,$22(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0
		bcs.s	loc_C09E
		move.w	$30(a0),d0
		asr.w	#3,d0
		move.w	d0,$10(a0)
		move.b	#1,$32(a0)
		clr.w	$E(a0)

loc_C09E:
		bra.s	loc_C0E6
; ===========================================================================

loc_C0A0:
		tst.w	$10(a0)
		beq.w	loc_C0D6
		bmi.s	loc_C0BC
		moveq	#0,d3
		move.b	$19(a0),d3
		jsr	ObjHitWallRight
		tst.w	d1		; has block touched a wall?
		bmi.s	Obj33_StopPush	; if yes, branch
		bra.s	loc_C0E6
; ===========================================================================

loc_C0BC:
		moveq	#0,d3
		move.b	$19(a0),d3
		not.w	d3
		jsr	ObjHitWallLeft
		tst.w	d1		; has block touched a wall?
		bmi.s	Obj33_StopPush	; if yes, branch
		bra.s	loc_C0E6
; ===========================================================================

Obj33_StopPush:
		clr.w	$10(a0)		; stop block moving
		bra.s	loc_C0E6
; ===========================================================================

loc_C0D6:
		addi.l	#$2001,$C(a0)
		cmpi.b	#-$60,$F(a0)
		bcc.s	loc_C104

loc_C0E6:
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	(sp)+,d4
		bsr.w	loc_C186
		bsr.s	Obj33_ChkLava
		bra.w	loc_BFC6
; ===========================================================================

loc_C104:
		move.w	(sp)+,d4
		lea	(Object_RAM).w,a1
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		bra.w	loc_BFE6
; ===========================================================================

Obj33_ChkLava:
		cmpi.w	#$201,(Current_Zone_And_Act).w ; is the level MZ act 2?
		bne.s	Obj33_ChkLava2	; if not, branch
		move.w	#-$20,d2
		cmpi.w	#$DD0,8(a0)
		beq.s	Obj33_LoadLava
		cmpi.w	#$CC0,8(a0)
		beq.s	Obj33_LoadLava
		cmpi.w	#$BA0,8(a0)
		beq.s	Obj33_LoadLava
		rts	
; ===========================================================================

Obj33_ChkLava2:
		cmpi.w	#$202,(Current_Zone_And_Act).w ; is the level MZ act 3?
		bne.s	Obj33_NoLava	; if not, branch
		move.w	#$20,d2
		cmpi.w	#$560,8(a0)
		beq.s	Obj33_LoadLava
		cmpi.w	#$5C0,8(a0)
		beq.s	Obj33_LoadLava

Obj33_NoLava:
		rts	
; ===========================================================================

Obj33_LoadLava:
		bsr.w	SingleObjLoad
		bne.s	locret_C184
		move.b	#$4C,0(a1)	; load lava geyser object
		move.w	8(a0),8(a1)
		add.w	d2,8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$10,$C(a1)
		move.l	a0,$3C(a1)

locret_C184:
		rts	
; ===========================================================================

loc_C186:				; XREF: loc_BF6E
		move.b	$25(a0),d0
		beq.w	loc_C218
		subq.b	#2,d0
		bne.s	loc_C1AA
		bsr.w	ExitPlatform
		btst	#3,$22(a1)
		bne.s	loc_C1A4
		clr.b	$25(a0)
		rts	
; ===========================================================================

loc_C1A4:
		move.w	d4,d2
		bra.w	MvSonicOnPtfm
; ===========================================================================

loc_C1AA:
		subq.b	#2,d0
		bne.s	loc_C1F2
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	locret_C1F0
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		clr.b	$25(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0
		bcs.s	locret_C1F0
		move.w	$30(a0),d0
		asr.w	#3,d0
		move.w	d0,$10(a0)
		move.b	#1,$32(a0)
		clr.w	$E(a0)

locret_C1F0:
		rts	
; ===========================================================================

loc_C1F2:
		bsr.w	ObjectMove
		move.w	8(a0),d0
		andi.w	#$C,d0
		bne.w	locret_C2E4
		andi.w	#-$10,8(a0)
		move.w	$10(a0),$30(a0)
		clr.w	$10(a0)
		subq.b	#2,$25(a0)
		rts	
; ===========================================================================

loc_C218:
		bsr.w	loc_FAC8
		tst.w	d4
		beq.w	locret_C2E4
		bmi.w	locret_C2E4
		tst.b	$32(a0)
		beq.s	loc_C230
		bra.w	locret_C2E4
; ===========================================================================

loc_C230:
		tst.w	d0
		beq.w	locret_C2E4
		bmi.s	loc_C268
		btst	#0,$22(a1)
		bne.w	locret_C2E4
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	$19(a0),d3
		jsr	ObjHitWallRight
		move.w	(sp)+,d0
		tst.w	d1
		bmi.w	locret_C2E4
		addi.l	#$10000,8(a0)
		moveq	#1,d0
		move.w	#$40,d1
		bra.s	loc_C294
; ===========================================================================

loc_C268:
		btst	#0,$22(a1)
		beq.s	locret_C2E4
		move.w	d0,-(sp)
		moveq	#0,d3
		move.b	$19(a0),d3
		not.w	d3
		jsr	ObjHitWallLeft
		move.w	(sp)+,d0
		tst.w	d1
		bmi.s	locret_C2E4
		subi.l	#$10000,8(a0)
		moveq	#-1,d0
		move.w	#-$40,d1

loc_C294:
		lea	(Object_RAM).w,a1
		add.w	d0,8(a1)
		move.w	d1,$14(a1)
		move.w	#0,$10(a1)
		move.w	d0,-(sp)
		move.w	#SndID_Push,d0
		jsr	(PlaySound_Special).l ;	play pushing sound
		move.w	(sp)+,d0
		tst.b	$28(a0)
		bmi.s	locret_C2E4
		move.w	d0,-(sp)
		jsr	ObjHitFloor
		move.w	(sp)+,d0
		cmpi.w	#4,d1
		ble.s	loc_C2E0
		move.w	#$400,$10(a0)
		tst.w	d0
		bpl.s	loc_C2D8
		neg.w	$10(a0)

loc_C2D8:
		move.b	#6,$25(a0)
		bra.s	locret_C2E4
; ===========================================================================

loc_C2E0:
		add.w	d1,$C(a0)

locret_C2E4:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - pushable blocks (MZ, LZ)
; ---------------------------------------------------------------------------
Map_obj33:
	include "mappings/sprite/obj33.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 34 - zone title cards
; ---------------------------------------------------------------------------

Obj34:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj34_Index(pc,d0.w),d1
		jmp	Obj34_Index(pc,d1.w)
; ===========================================================================
Obj34_Index:	dc.w Obj34_CheckFinal-Obj34_Index
		dc.w Obj34_ChkPos-Obj34_Index
		dc.w Obj34_Wait-Obj34_Index
		dc.w Obj34_Wait-Obj34_Index
; ===========================================================================

Obj34_CheckFinal:			; XREF: Obj34_Index
		movea.l	a0,a1
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lea	(Obj34_ConData).l,a3
		lsl.w	#4,d0
		adda.w	d0,a3
		lea	(Obj34_ItemData).l,a2
		moveq	#3,d1

Obj34_Loop:
		move.b	#$34,0(a1)
		move.w	(a3),8(a1)	; load start x-position
		move.w	(a3)+,$32(a1)	; load finish x-position (same as start)
		move.w	(a3)+,$30(a1)	; load main x-position
		move.w	(a2)+,$A(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,d0
		bne.s	Obj34_ActNumber
		move.b	d2,d0

Obj34_ActNumber:
		cmpi.b	#$A,d0
		beq.s	Obj34_Oval
		cmpi.b	#7,d0
		bne.s	Obj34_MakeSprite
		move.b	(Current_Act).w,d0
		cmpi.b	#2,d0
		blt.s	Obj34_MakeSprite
		move.b	#1,d0
		bra.s	Obj34_MakeSprite
		
Obj34_Oval:
		move.b	#2,d0

Obj34_MakeSprite:
		move.b	d0,$1A(a1)	; display frame	number d0
		move.l	#Map_obj34,4(a1)
		move.w	#$8580,2(a1)
		cmpi.w	#1,d1
		ble.s	@NotText
		bsr.w	Obj34_GetMappings
		move.w	#$85AD,2(a1)
		
@NotText:
		move.b	#$78,$19(a1)
		move.b	#0,1(a1)
		move.b	#0,$18(a1)
		move.w	#60,$1E(a1)	; set time delay to 1 second
		lea	$40(a1),a1	; next object
		dbf	d1,Obj34_Loop	; repeat sequence another 3 times

Obj34_ChkPos:				; XREF: Obj34_Index
		moveq	#$10,d1		; set horizontal speed
		move.w	$30(a0),d0
		cmp.w	8(a0),d0	; has item reached the target position?
		beq.s	loc_C3C8	; if yes, branch
		bge.s	Obj34_Move
		neg.w	d1

Obj34_Move:
		add.w	d1,8(a0)	; change item's position

loc_C3C8:
		move.w	8(a0),d0
		bmi.s	locret_C3D8
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C3D8	; if yes, branch
		
Obj34_Display:
		bra.w	DisplaySprite
; ===========================================================================

locret_C3D8:
		rts	
; ===========================================================================

Obj34_Wait:				; XREF: Obj34_Index
		tst.w	$1E(a0)		; is time remaining zero?
		beq.s	Obj34_ChkPos2	; if yes, branch
		subq.w	#1,$1E(a0)	; subtract 1 from time
		bra.w	Obj34_Display
; ===========================================================================

Obj34_ChkPos2:				; XREF: Obj34_Wait
		tst.b	1(a0)
		bpl.s	Obj34_ChangeArt
		moveq	#$20,d1
		move.w	$32(a0),d0
		cmp.w	8(a0),d0	; has item reached the finish position?
		beq.s	Obj34_ChangeArt	; if yes, branch
		bge.s	Obj34_Move2
		neg.w	d1

Obj34_Move2:
		add.w	d1,8(a0)	; change item's position
		move.w	8(a0),d0
		bmi.s	locret_C412
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C412	; if yes, branch
		bra.w	Obj34_Display
; ===========================================================================

locret_C412:
		rts	
; ===========================================================================

Obj34_ChangeArt:			; XREF: Obj34_ChkPos2
		cmpi.b	#4,$24(a0)
		bne.s	Obj34_Delete
		moveq	#2,d0
		jsr	(LoadPLC).l	; load explosion patterns
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		addi.w	#$15,d0
		jsr	(LoadPLC).l	; load animal patterns

Obj34_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj34_ItemData:	dc.w $D0	; y-axis position
		dc.b 2,	0	; routine number, frame	number (changes)
		dc.w $E4
		dc.b 2,	1
		dc.w $EA
		dc.b 2,	7
		dc.w $E0
		dc.b 2,	$A
; ---------------------------------------------------------------------------
; Title	card configuration data
; Format:
; 4 bytes per item (YYYY XXXX)
; 4 items per level (GREEN HILL, ZONE, ACT X, oval)
; ---------------------------------------------------------------------------
Obj34_ConData:	dc.w 0,	$120, $FEFC, $13C, $414, $154, $214, $154 ; GHZ
		dc.w 0,	$120, $FEF4, $134, $40C, $14C, $20C, $14C ; LZ
		dc.w 0,	$120, $FEE0, $120, $3F8, $138, $1F8, $138 ; MZ
		dc.w 0,	$120, $FEFC, $13C, $414, $154, $214, $154 ; SLZ
		dc.w 0,	$120, $FF04, $144, $41C, $15C, $21C, $15C ; SYZ
		dc.w 0,	$120, $FEE4, $124, $3EC, $3EC, $1EC, $12C ; FZ
; ===========================================================================
Obj34_MappingArray:
		dc.l Map_obj34_Tutorial
		dc.l Map_obj34_FuckedUp
		dc.l Map_obj34_Dzien
		dc.l Map_obj34_Appendicitis
		dc.l Map_obj34_Teeth
		dc.l Map_obj34_Final
; ===========================================================================
Obj34_GetMappings:
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.l	Obj34_MappingArray(pc,d0.w),4(a1)
		rts
; ===========================================================================
Map_obj34_Tutorial:
		include "mappings/sprite/Title Cards/obj34_tutorial.asm"
Map_obj34_FuckedUp:
		include "mappings/sprite/Title Cards/obj34_fuckedup.asm"
Map_obj34_Dzien:
		include "mappings/sprite/Title Cards/obj34_dzien.asm"
Map_obj34_Appendicitis:
		include "mappings/sprite/Title Cards/obj34_appendicitis.asm"
Map_obj34_Teeth:
		include "mappings/sprite/Title Cards/obj34_teeth.asm"
Map_obj34_Final:
		include "mappings/sprite/Title Cards/obj34_final.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 39 - "GAME OVER" and "TIME OVER"
; ---------------------------------------------------------------------------

Obj39:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj39_Index(pc,d0.w),d1
		jmp	Obj39_Index(pc,d1.w)
; ===========================================================================
Obj39_Index:	dc.w Obj39_ChkPLC-Obj39_Index
		dc.w loc_C50C-Obj39_Index
		dc.w Obj39_Wait-Obj39_Index
; ===========================================================================

Obj39_ChkPLC:				; XREF: Obj39_Index
		tst.l	(PLC_Buffer).w	; are the pattern load cues empty?
		beq.s	Obj39_Main	; if yes, branch
		rts	
; ===========================================================================

Obj39_Main:
		addq.b	#2,$24(a0)
		move.w	#$50,8(a0)	; set x-position
		btst	#0,$1A(a0)	; is the object	"OVER"?
		beq.s	loc_C4EC	; if not, branch
		move.w	#$1F0,8(a0)	; set x-position for "OVER"

loc_C4EC:
		move.w	#$F0,$A(a0)
		move.l	#Map_obj39,4(a0)
		move.w	#$8541,2(a0)
		move.b	#0,1(a0)
		move.b	#0,$18(a0)

loc_C50C:				; XREF: Obj39_Index
		moveq	#$10,d1		; set horizontal speed
		cmpi.w	#$120,8(a0)	; has item reached its target position?
		beq.s	Obj39_SetWait	; if yes, branch
		bcs.s	Obj39_Move
		neg.w	d1

Obj39_Move:
		add.w	d1,8(a0)	; change item's position
		bra.w	DisplaySprite
; ===========================================================================

Obj39_SetWait:				; XREF: Obj39_Main
		move.w	#720,$1E(a0)	; set time delay to 12 seconds
		addq.b	#2,$24(a0)
		rts	
; ===========================================================================

Obj39_Wait:				; XREF: Obj39_Index
		move.b	(Ctrl_1_Press).w,d0
		andi.b	#$70,d0		; is button A, B or C pressed?
		bne.s	Obj39_ChgMode	; if yes, branch
		btst	#0,$1A(a0)
		bne.s	Obj39_Display
		tst.w	$1E(a0)		; has time delay reached zero?
		beq.s	Obj39_ChgMode	; if yes, branch
		subq.w	#1,$1E(a0)	; subtract 1 from time delay
		bra.w	DisplaySprite
; ===========================================================================

Obj39_ChgMode:				; XREF: Obj39_Wait
		tst.b	(Time_Over_Flag).w	; is time over flag set?
		bne.s	Obj39_ResetLvl	; if yes, branch
		move.b	#$14,(Game_Mode).w ; set mode to $14 (continue screen)
		tst.b	(Continue_Count).w	; do you have any continues?
		bne.s	Obj39_Display	; if yes, branch
		move.b	#$20,(Game_Mode).w ; set mode to 0 (Sega screen)
		bra.s	Obj39_Display
; ===========================================================================

Obj39_ResetLvl:				; XREF: Obj39_ChgMode
		move.w	#1,(Level_Inactive_Flag).w ; restart level

Obj39_Display:				; XREF: Obj39_ChgMode
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3A - "SONIC GOT THROUGH" title	card
; ---------------------------------------------------------------------------

Obj3A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3A_Index(pc,d0.w),d1
		jmp	Obj3A_Index(pc,d1.w)
; ===========================================================================
Obj3A_Index:	
		dc.w Obj3A_ChkPLC-Obj3A_Index
		dc.w Obj3A_ChkPos-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
		dc.w Obj3A_TimeBonus-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
		dc.w Obj3A_NextLevel-Obj3A_Index
		dc.w Obj3A_Wait-Obj3A_Index
; ===========================================================================

Obj3A_ChkPLC:				; XREF: Obj3A_Index
		tst.l	(PLC_Buffer).w	; are the pattern load cues empty?
		beq.s	Obj3A_Main	; if yes, branch
		rts	
; ===========================================================================

Obj3A_Main:
		movea.l	a0,a1
		lea	(Obj3A_Config).l,a2
		moveq	#6,d1

Obj3A_Loop:
		move.b	#$3A,0(a1)
		move.w	(a2),8(a1)	; load start x-position
		move.w	(a2)+,$32(a1)	; load finish x-position (same as start)
		move.w	(a2)+,$30(a1)	; load main x-position
		move.w	(a2)+,$A(a1)	; load y-position
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,d0
		cmpi.b	#6,d0
		bne.s	loc_C5CA
		add.b	(Current_Act).w,d0 ; add act number to frame number

loc_C5CA:
		move.b	d0,$1A(a1)
		move.l	#Map_obj3A,4(a1)
		move.w	#$8580,2(a1)
		cmpi.w	#5,d1
		blt.s	@NotText
		move.w	#$85AD,2(a1)
		
	@NotText:
		move.b	#0,1(a1)
		lea	$40(a1),a1
		dbf	d1,Obj3A_Loop	; repeat 6 times

Obj3A_ChkPos:				; XREF: Obj3A_Index
		moveq	#$10,d1		; set horizontal speed
		move.w	$30(a0),d0
		cmp.w	8(a0),d0	; has item reached its target position?
		beq.s	loc_C61A	; if yes, branch
		bge.s	Obj3A_Move
		neg.w	d1

Obj3A_Move:
		add.w	d1,8(a0)	; change item's position

loc_C5FE:				; XREF: loc_C61A
		move.w	8(a0),d0
		bmi.s	locret_C60E
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C60E	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C60E:
		rts	
; ===========================================================================

loc_C610:				; XREF: loc_C61A
		move.b	#$E,$24(a0)
		bra.w	Obj3A_ChkPos2
; ===========================================================================

loc_C61A:				; XREF: Obj3A_ChkPos
		cmpi.b	#$E,(Object_Space_29+$24).w
		beq.s	loc_C610
		cmpi.b	#4,$1A(a0)
		bne.s	loc_C5FE
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds

Obj3A_Wait:				; XREF: Obj3A_Index
		subq.w	#1,$1E(a0)	; subtract 1 from time delay
		bne.s	Obj3A_Display
		addq.b	#2,$24(a0)

Obj3A_Display:
		bra.w	DisplaySprite
; ===========================================================================

Obj3A_TimeBonus:			; XREF: Obj3A_Index
		bsr.w	DisplaySprite
		move.b	#1,(Update_Bonus_Flag).w ; set time/ring bonus update flag
		moveq	#0,d0
		tst.w	(Time_Bonus).w	; is time bonus	= zero?
		beq.s	Obj3A_RingBonus	; if yes, branch
		addi.w	#10,d0		; add 10 to score
		subi.w	#10,(Time_Bonus).w ; subtract 10	from time bonus

Obj3A_RingBonus:
		tst.w	(Ring_Bonus).w	; is ring bonus	= zero?
		beq.s	Obj3A_ChkBonus	; if yes, branch
		addi.w	#10,d0		; add 10 to score
		subi.w	#10,(Ring_Bonus).w ; subtract 10	from ring bonus

Obj3A_ChkBonus:
		tst.w	d0		; is there any bonus?
		bne.s	Obj3A_AddBonus	; if yes, branch
		move.w	#SndID_KaChing,d0
		jsr	(PlaySound_Special).l ;	play "ker-ching" sound
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds

locret_C692:
		rts	
; ===========================================================================

Obj3A_AddBonus:				; XREF: Obj3A_ChkBonus
		jsr	AddPoints
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#3,d0
		bne.s	locret_C692
		move.w	#SndID_Switch,d0
		jmp	(PlaySound_Special).l ;	play "blip" sound
; ===========================================================================

Obj3A_NextLevel:			; XREF: Obj3A_Index
		move.b	(Current_Zone).w,d0
		andi.w	#7,d0
		lsl.w	#3,d0
		move.b	(Current_Act).w,d1
		andi.w	#3,d1
		add.w	d1,d1
		add.w	d1,d0
		move.w	LevelOrder(pc,d0.w),d0 ; load level from level order array
		move.w	d0,(Current_Zone_And_Act).w ; set level number
		tst.w	d0
		bne.s	Obj3A_ChkSS
		move.b	#0,(Game_Mode).w ; set game mode to level (00)
		bra.s	Obj3A_Display2
; ===========================================================================

Obj3A_ChkSS:				; XREF: Obj3A_NextLevel
		clr.b	(Last_Checkpoint_Hit).w	; clear	lamppost counter
		tst.b	(Jumped_In_Big_Ring_Flag).w	; has Sonic jumped into	a giant	ring?
		beq.s	loc_C6EA	; if not, branch
		move.b	#$10,(Game_Mode).w ; set game mode to Special Stage (10)
		bra.s	Obj3A_Display2
; ===========================================================================

loc_C6EA:				; XREF: Obj3A_ChkSS
		move.w	#1,(Level_Inactive_Flag).w ; restart level

Obj3A_Display2:				; XREF: Obj3A_NextLevel, Obj3A_ChkSS
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Level	order array
; ---------------------------------------------------------------------------
LevelOrder:
		dc.w $200, $000, $000, $000	; GHZ1 -> MZ1
		dc.w $101, $502, $000, $000	; LZ1  -> LZ2,  LZ2  -> FZ
		dc.w $201, $400, $000, $000	; MZ1  -> MZ2,  MZ2  -> SYZ1
		dc.w $301, $100, $000, $000	; SLZ1 -> SLZ2, SLZ2 -> LZ1
		dc.w $401, $300, $000, $000	; SYZ1 -> SYZ2, SYZ2 -> SLZ1
		dc.w $000, $000, $000, $000
		even
; ===========================================================================

Obj3A_ChkPos2:				; XREF: Obj3A_Index
		moveq	#$20,d1		; set horizontal speed
		move.w	$32(a0),d0
		cmp.w	8(a0),d0	; has item reached its finish position?
		bge.s	Obj3A_Move2
		neg.w	d1

Obj3A_Move2:
		add.w	d1,8(a0)	; change item's position
		move.w	8(a0),d0
		bmi.s	locret_C748
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C748	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C748:
		rts	
; ===========================================================================
Obj3A_Config:	dc.w 4,	$124, $BC	; x-start, x-main, y-main
		dc.b 2,	0		; routine number, frame	number (changes)
		dc.w $FEE0, $120, $D0
		dc.b 2,	1
		dc.w $40C, $14C, $D6
		dc.b 2,	6
		dc.w $520, $120, $EC
		dc.b 2,	2
		dc.w $540, $120, $FC
		dc.b 2,	3
		dc.w $560, $120, $10C
		dc.b 2,	4
		dc.w $20C, $14C, $CC
		dc.b 2,	5
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7E - special stage results screen
; ---------------------------------------------------------------------------

Obj7E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7E_Index(pc,d0.w),d1
		jmp	Obj7E_Index(pc,d1.w)
; ===========================================================================
Obj7E_Index:	dc.w Obj7E_ChkPLC-Obj7E_Index
		dc.w Obj7E_ChkPos-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_RingBonus-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_Exit-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_Continue-Obj7E_Index
		dc.w Obj7E_Wait-Obj7E_Index
		dc.w Obj7E_Exit-Obj7E_Index
		dc.w loc_C91A-Obj7E_Index
; ===========================================================================

Obj7E_ChkPLC:				; XREF: Obj7E_Index
		tst.l	(PLC_Buffer).w	; are the pattern load cues empty?
		beq.s	Obj7E_Main	; if yes, branch
		rts	
; ===========================================================================

Obj7E_Main:
		movea.l	a0,a1
		lea	(Obj7E_Config).l,a2
		moveq	#3,d1
		cmpi.w	#50,(Ring_Count).w ; do you have	50 or more rings?
		bcs.s	Obj7E_Loop	; if no, branch
		addq.w	#1,d1		; if yes, add 1	to d1 (number of sprites)

Obj7E_Loop:
		move.b	#$7E,0(a1)
		move.w	(a2)+,8(a1)	; load start x-position
		move.w	(a2)+,$30(a1)	; load main x-position
		move.w	(a2)+,$A(a1)	; load y-position
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1A(a1)
		move.l	#Map_obj7E,4(a1)
		move.w	#$8580,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1
		dbf	d1,Obj7E_Loop	; repeat sequence 3 or 4 times

		moveq	#7,d0
		move.b	(Emerald_Count).w,d1
		beq.s	loc_C842
		moveq	#0,d0
		cmpi.b	#6,d1		; do you have all chaos	emeralds?
		bne.s	loc_C842	; if not, branch
		moveq	#8,d0		; load "Sonic got them all" text
		move.w	#$18,8(a0)
		move.w	#$118,$30(a0)	; change position of text

loc_C842:
		move.b	d0,$1A(a0)

Obj7E_ChkPos:				; XREF: Obj7E_Index
		moveq	#$10,d1		; set horizontal speed
		move.w	$30(a0),d0
		cmp.w	8(a0),d0	; has item reached its target position?
		beq.s	loc_C86C	; if yes, branch
		bge.s	Obj7E_Move
		neg.w	d1

Obj7E_Move:
		add.w	d1,8(a0)	; change item's position

loc_C85A:				; XREF: loc_C86C
		move.w	8(a0),d0
		bmi.s	locret_C86A
		cmpi.w	#$200,d0	; has item moved beyond	$200 on	x-axis?
		bcc.s	locret_C86A	; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

locret_C86A:
		rts	
; ===========================================================================

loc_C86C:				; XREF: Obj7E_ChkPos
		cmpi.b	#2,$1A(a0)
		bne.s	loc_C85A
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds
		move.b	#$7F,(Object_Space_33).w ; load chaos	emerald	object

Obj7E_Wait:				; XREF: Obj7E_Index
		subq.w	#1,$1E(a0)	; subtract 1 from time delay
		bne.s	Obj7E_Display
		addq.b	#2,$24(a0)

Obj7E_Display:
		bra.w	DisplaySprite
; ===========================================================================

Obj7E_RingBonus:			; XREF: Obj7E_Index
		bsr.w	DisplaySprite
		move.b	#1,(Update_Bonus_Flag).w ; set ring bonus update flag
		tst.w	(Ring_Bonus).w	; is ring bonus	= zero?
		beq.s	loc_C8C4	; if yes, branch
		subi.w	#10,(Ring_Bonus).w ; subtract 10	from ring bonus
		moveq	#10,d0		; add 10 to score
		jsr	AddPoints
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#3,d0
		bne.s	locret_C8EA
		move.w	#SndID_Switch,d0
		jmp	(PlaySound_Special).l ;	play "blip" sound
; ===========================================================================

loc_C8C4:				; XREF: Obj7E_RingBonus
		move.w	#SndID_KaChing,d0
		jsr	(PlaySound_Special).l ;	play "ker-ching" sound
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)	; set time delay to 3 seconds
		cmpi.w	#50,(Ring_Count).w ; do you have	at least 50 rings?
		bcs.s	locret_C8EA	; if not, branch
		move.w	#60,$1E(a0)	; set time delay to 1 second
		addq.b	#4,$24(a0)	; goto "Obj7E_Continue"	routine

locret_C8EA:
		rts	
; ===========================================================================

Obj7E_Exit:				; XREF: Obj7E_Index
		move.w	#1,(Level_Inactive_Flag).w ; restart level
		bra.w	DisplaySprite
; ===========================================================================

Obj7E_Continue:				; XREF: Obj7E_Index
		move.b	#4,(Object_Space_28+$1A).w
		move.b	#$14,(Object_Space_28+$24).w
		move.w	#SndID_GetContinue,d0
		jsr	(PlaySound_Special).l ;	play continues music
		addq.b	#2,$24(a0)
		move.w	#360,$1E(a0)	; set time delay to 6 seconds
		bra.w	DisplaySprite
; ===========================================================================

loc_C91A:				; XREF: Obj7E_Index
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$F,d0
		bne.s	Obj7E_Display2
		bchg	#0,$1A(a0)

Obj7E_Display2:
		bra.w	DisplaySprite
; ===========================================================================
Obj7E_Config:	dc.w $20, $120,	$C4	; start	x-pos, main x-pos, y-pos
		dc.b 2,	0		; rountine number, frame number
		dc.w $320, $120, $118
		dc.b 2,	1
		dc.w $360, $120, $128
		dc.b 2,	2
		dc.w $1EC, $11C, $C4
		dc.b 2,	3
		dc.w $3A0, $120, $138
		dc.b 2,	6
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7F - chaos emeralds from the special stage results screen
; ---------------------------------------------------------------------------

Obj7F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7F_Index(pc,d0.w),d1
		jmp	Obj7F_Index(pc,d1.w)
; ===========================================================================
Obj7F_Index:	dc.w Obj7F_Main-Obj7F_Index
		dc.w Obj7F_Flash-Obj7F_Index

; ---------------------------------------------------------------------------
; X-axis positions for chaos emeralds
; ---------------------------------------------------------------------------
Obj7F_PosData:	dc.w $110, $128, $F8, $140, $E0, $158
; ===========================================================================

Obj7F_Main:				; XREF: Obj7F_Index
		movea.l	a0,a1
		lea	(Obj7F_PosData).l,a2
		moveq	#0,d2
		moveq	#0,d1
		move.b	(Emerald_Count).w,d1 ; d1 is number	of emeralds
		subq.b	#1,d1		; subtract 1 from d1
		bcs.w	DeleteObject	; if you have 0	emeralds, branch

Obj7F_Loop:
		move.b	#$7F,0(a1)
		move.w	(a2)+,8(a1)	; set x-position
		move.w	#$F0,$A(a1)	; set y-position
		lea	(Got_Emeralds_Array).w,a3 ; check which emeralds	you have
		move.b	(a3,d2.w),d3
		move.b	d3,$1A(a1)
		move.b	d3,$1C(a1)
		addq.b	#1,d2
		addq.b	#2,$24(a1)
		move.l	#Map_obj7F,4(a1)
		move.w	#$8541,2(a1)
		move.b	#0,1(a1)
		lea	$40(a1),a1	; next object
		dbf	d1,Obj7F_Loop	; loop for d1 number of	emeralds

Obj7F_Flash:				; XREF: Obj7F_Index
		move.b	$1A(a0),d0
		move.b	#6,$1A(a0)	; load 6th frame (blank)
		cmpi.b	#6,d0
		bne.s	Obj7F_Display
		move.b	$1C(a0),$1A(a0)	; load visible frame

Obj7F_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_obj34:	
	include "mappings/sprite/obj34_title_card.asm"
; ---------------------------------------------------------------------------
; Sprite mappings - "GAME OVER"	and "TIME OVER"
; ---------------------------------------------------------------------------
Map_obj39:
	include "mappings/sprite/obj39.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_obj3A:	
	include "mappings/sprite/obj3A_passed.asm"
; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_obj7E:	
		dc.w byte_CCAC-Map_obj7E
		dc.w byte_CCEE-Map_obj7E
		dc.w byte_CD0D-Map_obj7E
		dc.w byte_CB47-Map_obj7E
		dc.w byte_CD31-Map_obj7E
		dc.w byte_CD46-Map_obj7E
		dc.w byte_CD5B-Map_obj7E
		dc.w byte_CD6B-Map_obj7E
		dc.w byte_CDA8-Map_obj7E
byte_CCAC:	dc.b $D			; "CHAOS EMERALDS"
		dc.b $F8, 5, 0,	8, $90
		dc.b $F8, 5, 0,	$1C, $A0
		dc.b $F8, 5, 0,	0, $B0
		dc.b $F8, 5, 0,	$32, $C0
		dc.b $F8, 5, 0,	$3E, $D0
		dc.b $F8, 5, 0,	$10, $F0
		dc.b $F8, 5, 0,	$2A, 0
		dc.b $F8, 5, 0,	$10, $10
		dc.b $F8, 5, 0,	$3A, $20
		dc.b $F8, 5, 0,	0, $30
		dc.b $F8, 5, 0,	$26, $40
		dc.b $F8, 5, 0,	$C, $50
		dc.b $F8, 5, 0,	$3E, $60
byte_CCEE:	dc.b 6			; "SCORE"
		dc.b $F8, $D, 1, $4A, $B0
		dc.b $F8, 1, 1,	$62, $D0
		dc.b $F8, 9, 1,	$64, $18
		dc.b $F8, $D, 1, $6A, $30
		dc.b $F7, 4, 0,	$6E, $CD
		dc.b $FF, 4, $18, $6E, $CD
byte_CD0D:	dc.b 7
		dc.b $F8, $D, 1, $52, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F8,	$28
		dc.b $F8, 1, 1,	$70, $48
byte_CD31:	dc.b 4
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
		dc.b $F8, 6, $1F, $E3, $40
byte_CD46:	dc.b 4
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
		dc.b $F8, 6, $1F, $E9, $40
byte_CD5B:	dc.b 3
		dc.b $F8, $D, $FF, $D1,	$B0
		dc.b $F8, $D, $FF, $D9,	$D0
		dc.b $F8, 1, $FF, $E1, $F0
byte_CD6B:	dc.b $C			; "SPECIAL STAGE"
		dc.b $F8, 5, 0,	$3E, $9C
		dc.b $F8, 5, 0,	$36, $AC
		dc.b $F8, 5, 0,	$10, $BC
		dc.b $F8, 5, 0,	8, $CC
		dc.b $F8, 1, 0,	$20, $DC
		dc.b $F8, 5, 0,	0, $E4
		dc.b $F8, 5, 0,	$26, $F4
		dc.b $F8, 5, 0,	$3E, $14
		dc.b $F8, 5, 0,	$42, $24
		dc.b $F8, 5, 0,	0, $34
		dc.b $F8, 5, 0,	$18, $44
		dc.b $F8, 5, 0,	$10, $54
byte_CDA8:	dc.b $F			; "SONIC GOT THEM ALL"
		dc.b $F8, 5, 0,	$3E, $88
		dc.b $F8, 5, 0,	$32, $98
		dc.b $F8, 5, 0,	$2E, $A8
		dc.b $F8, 1, 0,	$20, $B8
		dc.b $F8, 5, 0,	8, $C0
		dc.b $F8, 5, 0,	$18, $D8
		dc.b $F8, 5, 0,	$32, $E8
		dc.b $F8, 5, 0,	$42, $F8
		dc.b $F8, 5, 0,	$42, $10
		dc.b $F8, 5, 0,	$1C, $20
		dc.b $F8, 5, 0,	$10, $30
		dc.b $F8, 5, 0,	$2A, $40
		dc.b $F8, 5, 0,	0, $58
		dc.b $F8, 5, 0,	$26, $68
		dc.b $F8, 5, 0,	$26, $78
		even
byte_CB47:	dc.b $D			; Oval
		dc.b $E4, $C, 0, $70, $F4
		dc.b $E4, 2, 0,	$74, $14
		dc.b $EC, 4, 0,	$77, $EC
		dc.b $F4, 5, 0,	$79, $E4
		dc.b $14, $C, $18, $70,	$EC
		dc.b 4,	2, $18,	$74, $E4
		dc.b $C, 4, $18, $77, 4
		dc.b $FC, 5, $18, $79, $C
		dc.b $EC, 8, 0,	$7D, $FC
		dc.b $F4, $C, 0, $7C, $F4
		dc.b $FC, 8, 0,	$7C, $F4
		dc.b 4,	$C, 0, $7C, $EC
		dc.b $C, 8, 0, $7C, $EC
		dc.b 0
; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds from	the special stage results screen
; ---------------------------------------------------------------------------
Map_obj7F:
	include "mappings/sprite/obj7F.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 36 - spikes
; ---------------------------------------------------------------------------

Obj36:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj36_Index(pc,d0.w),d1
		jmp	Obj36_Index(pc,d1.w)
; ===========================================================================
Obj36_Index:	dc.w Obj36_Main-Obj36_Index
		dc.w Obj36_Solid-Obj36_Index

Obj36_Var:	dc.b 0,	$14		; frame	number,	object width
		dc.b 1,	$10
		dc.b 2,	4
		dc.b 3,	$1C
		dc.b 4,	$40
		dc.b 5,	$10
; ===========================================================================

Obj36_Main:				; XREF: Obj36_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj36,4(a0)
		move.w	#$51B,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),d0
		andi.b	#$F,$28(a0)
		andi.w	#$F0,d0
		lea	(Obj36_Var).l,a1
		lsr.w	#3,d0
		adda.w	d0,a1
		move.b	(a1)+,$1A(a0)
		move.b	(a1)+,$19(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$32(a0)

Obj36_Solid:				; XREF: Obj36_Index
		bsr.w	Obj36_Type0x	; make the object move
		move.w	#4,d2
		cmpi.b	#5,$1A(a0)	; is object type $5x ?
		beq.s	Obj36_SideWays	; if yes, branch
		cmpi.b	#1,$1A(a0)	; is object type $1x ?
		bne.s	Obj36_Upright	; if not, branch
		move.w	#$14,d2

; Spikes types $1x and $5x face	sideways

Obj36_SideWays:				; XREF: Obj36_Solid
		move.w	#$1B,d1
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		bne.s	Obj36_Display
		cmpi.w	#1,d4
		beq.s	Obj36_Hurt
		bra.s	Obj36_Display
; ===========================================================================

; Spikes types $x, $2x, $3x and $4x face up or	down

Obj36_Upright:				; XREF: Obj36_Solid
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		bne.s	Obj36_Hurt
		tst.w	d4
		bpl.s	Obj36_Display

Obj36_Hurt:				; XREF: Obj36_SideWays; Obj36_Upright
		tst.b	(Invincibility_Flag).w	; is Sonic invincible?
		bne.s	Obj36_Display	; if yes, branch
		tst.w	(Object_Space_1+$30).w	; +++ is Sonic invulnerable?
		bne.s	Obj36_Display	; +++ if yes, branch
		move.l	a0,-(sp)
		movea.l	a0,a2
		lea	(Object_RAM).w,a0
		cmpi.b	#4,$24(a0)
		bcc.s	loc_CF20
		move.l	$C(a0),d3
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		jsr	HurtSonic

loc_CF20:
		movea.l	(sp)+,a0

Obj36_Display:
		bsr.w	DisplaySprite
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================

Obj36_Type0x:				; XREF: Obj36_Solid
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj36_TypeIndex(pc,d0.w),d1
		jmp	Obj36_TypeIndex(pc,d1.w)
; ===========================================================================
Obj36_TypeIndex:dc.w Obj36_Type00-Obj36_TypeIndex
		dc.w Obj36_Type01-Obj36_TypeIndex
		dc.w Obj36_Type02-Obj36_TypeIndex
; ===========================================================================

Obj36_Type00:				; XREF: Obj36_TypeIndex
		rts			; don't move the object
; ===========================================================================

Obj36_Type01:				; XREF: Obj36_TypeIndex
		bsr.w	Obj36_Wait
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	$32(a0),d0
		move.w	d0,$C(a0)	; move the object vertically
		rts	
; ===========================================================================

Obj36_Type02:				; XREF: Obj36_TypeIndex
		bsr.w	Obj36_Wait
		moveq	#0,d0
		move.b	$34(a0),d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)	; move the object horizontally
		rts	
; ===========================================================================

Obj36_Wait:
		tst.w	$38(a0)		; is time delay	= zero?
		beq.s	loc_CFA4	; if yes, branch
		subq.w	#1,$38(a0)	; subtract 1 from time delay
		bne.s	locret_CFE6
		tst.b	1(a0)
		bpl.s	locret_CFE6
		move.w	#SndID_SpikeMove,d0
		jsr	(PlaySound_Special).l ;	play "spikes moving" sound
		bra.s	locret_CFE6
; ===========================================================================

loc_CFA4:
		tst.w	$36(a0)
		beq.s	loc_CFC6
		subi.w	#$800,$34(a0)
		bcc.s	locret_CFE6
		move.w	#0,$34(a0)
		move.w	#0,$36(a0)
		move.w	#60,$38(a0)	; set time delay to 1 second
		bra.s	locret_CFE6
; ===========================================================================

loc_CFC6:
		addi.w	#$800,$34(a0)
		cmpi.w	#$2000,$34(a0)
		bcs.s	locret_CFE6
		move.w	#$2000,$34(a0)
		move.w	#1,$36(a0)
		move.w	#60,$38(a0)	; set time delay to 1 second

locret_CFE6:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - spikes
; ---------------------------------------------------------------------------
Map_obj36:
	include "mappings/sprite/obj36.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3B - purple rock (GHZ)
; ---------------------------------------------------------------------------

Obj3B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3B_Index(pc,d0.w),d1
		jmp	Obj3B_Index(pc,d1.w)
; ===========================================================================
Obj3B_Index:	dc.w Obj3B_Main-Obj3B_Index
		dc.w Obj3B_Solid-Obj3B_Index
; ===========================================================================

Obj3B_Main:				; XREF: Obj3B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj3B,4(a0)
		move.w	#$63D0,2(a0)
		move.b	#4,1(a0)
		move.b	#$13,$19(a0)
		move.b	#4,$18(a0)

Obj3B_Solid:				; XREF: Obj3B_Index
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$10,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 49 - waterfall	sound effect (GHZ)
; ---------------------------------------------------------------------------

Obj49:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj49_Index(pc,d0.w),d1
		jmp	Obj49_Index(pc,d1.w)
; ===========================================================================
Obj49_Index:	dc.w Obj49_Main-Obj49_Index
		dc.w Obj49_PlaySnd-Obj49_Index
; ===========================================================================

Obj49_Main:				; XREF: Obj49_Index
		addq.b	#2,$24(a0)
		move.b	#4,1(a0)

Obj49_PlaySnd:				; XREF: Obj49_Index
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$3F,d0
		bne.s	Obj49_ChkDel
		move.w	#SndID_Waterfall,d0
		jsr	(PlaySound_Special).l ;	play waterfall sound

Obj49_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - purple rock	(GHZ)
; ---------------------------------------------------------------------------
Map_obj3B:
	include "mappings/sprite/obj3B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3C - smashable	wall (GHZ, SLZ)
; ---------------------------------------------------------------------------

Obj3C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3C_Index(pc,d0.w),d1
		jsr	Obj3C_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj3C_Index:	dc.w Obj3C_Main-Obj3C_Index
		dc.w Obj3C_Solid-Obj3C_Index
		dc.w Obj3C_FragMove-Obj3C_Index
; ===========================================================================

Obj3C_Main:				; XREF: Obj3C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj3C,4(a0)
		move.w	#$450F,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),$1A(a0)

Obj3C_Solid:				; XREF: Obj3C_Index
		move.w	(Object_Space_1+$10).w,$30(a0) ;	load Sonic's horizontal speed
		move.w	#$1B,d1
		move.w	#$20,d2
		move.w	#$20,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#5,$22(a0)
		bne.s	Obj3C_ChkRoll

locret_D180:
		rts	
; ===========================================================================

Obj3C_ChkRoll:				; XREF: Obj3C_Solid
		move.w	$30(a0),d0
		bpl.s	Obj3C_ChkSpeed
		neg.w	d0

Obj3C_ChkSpeed:
		tst.b	$3A(a1)	; is Sonic biting?
		bne.s	@is_biting	; if so, branch
		cmpi.w	#$480,d0	; is Sonic's speed $480 or higher?
		bcs.s	locret_D180	; if not, branch
		move.w	$30(a0),$10(a1)
		addq.w	#4,8(a1)

@is_biting:
		lea	(Obj3C_FragSpd1).l,a4 ;	use fragments that move	right
		move.w	8(a0),d0
		cmp.w	8(a1),d0	; is Sonic to the right	of the block?
		bcs.s	Obj3C_Smash	; if yes, branch
		tst.b	$3A(a1)	; is Sonic biting?
		bne.s	@is_biting2	; if so, branch
		subq.w	#8,8(a1)

@is_biting2:
		lea	(Obj3C_FragSpd2).l,a4 ;	use fragments that move	left

Obj3C_Smash:
		tst.b	$3A(a1)	; is Sonic biting?
		bne.s	@is_biting	; if so, branch
		move.w	$10(a1),$14(a1)

@is_biting:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)
		moveq	#7,d1		; load 8 fragments
		move.w	#$70,d2
		bsr.s	SmashObject

Obj3C_FragMove:				; XREF: Obj3C_Index
		bsr.w	ObjectMove
		addi.w	#$70,$12(a0)	; make fragment	fall faster
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ walls and MZ	blocks)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SmashObject:				; XREF: Obj3C_Smash
		moveq	#0,d0
		move.b	$1A(a0),d0
		add.w	d0,d0
		movea.l	4(a0),a3
		adda.w	(a3,d0.w),a3
		addq.w	#1,a3
		bset	#5,1(a0)
		move.b	0(a0),d4
		move.b	1(a0),d5
		movea.l	a0,a1
		bra.s	Smash_LoadFrag
; ===========================================================================

Smash_Loop:
		bsr.w	SingleObjLoad
		bne.s	Smash_PlaySnd
		addq.w	#5,a3

Smash_LoadFrag:				; XREF: SmashObject
		move.b	#4,$24(a1)
		move.b	d4,0(a1)
		move.l	a3,4(a1)
		move.b	d5,1(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	2(a0),2(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.w	(a4)+,$10(a1)
		move.w	(a4)+,$12(a1)
		cmpa.l	a0,a1
		bcc.s	loc_D268
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	ObjectMove
		add.w	d2,$12(a0)
		movea.l	(sp)+,a0
		bsr.w	DisplaySprite2

loc_D268:
		dbf	d1,Smash_Loop

Smash_PlaySnd:
		move.w	#SndID_WallSmash,d0
		jmp	(PlaySound_Special).l ;	play smashing sound
; End of function SmashObject

; ===========================================================================
; Smashed block	fragment speeds
;
Obj3C_FragSpd1:	dc.w $400, $FB00	; x-move speed,	y-move speed
		dc.w $600, $FF00
		dc.w $600, $100
		dc.w $400, $500
		dc.w $600, $FA00
		dc.w $800, $FE00
		dc.w $800, $200
		dc.w $600, $600

Obj3C_FragSpd2:	dc.w $FA00, $FA00
		dc.w $F800, $FE00
		dc.w $F800, $200
		dc.w $FA00, $600
		dc.w $FC00, $FB00
		dc.w $FA00, $FF00
		dc.w $FA00, $100
		dc.w $FC00, $500
; ---------------------------------------------------------------------------
; Sprite mappings - smashable walls (GHZ, SLZ)
; ---------------------------------------------------------------------------
Map_obj3C:
	include "mappings/sprite/obj3C.asm"

; ---------------------------------------------------------------------------
; Object code loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectsLoad:				; XREF: TitleScreen; et al
		lea	(Object_RAM).w,a0 ; set address for object RAM
		moveq	#((Object_RAM_End-Object_RAM)/$40)-1,d7
		moveq	#0,d0
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.s	loc_D362

loc_D348:
		move.b	(a0),d0		; load object number from RAM
		beq.s	loc_D358
		add.w	d0,d0
		add.w	d0,d0
		movea.l	Obj_Index-4(pc,d0.w),a1
		jsr	(a1)		; run the object's code
		moveq	#0,d0

loc_D358:
		lea	$40(a0),a0	; next object
		dbf	d7,loc_D348
		rts	
; ===========================================================================

loc_D362:
        cmpi.b  #$A,(Object_Space_1+$24).w		      ; Has Sonic drowned?
        beq.s   loc_D348                        ; If so, run objects a little longer
		moveq	#$1F,d7
		bsr.s	loc_D348
		moveq	#$5F,d7

loc_D368:
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_D378
		tst.b	1(a0)
		bpl.s	loc_D378
		bsr.w	DisplaySprite

loc_D378:
		lea	$40(a0),a0

loc_D37C:
		dbf	d7,loc_D368
		rts	
; End of function ObjectsLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Object pointers
; ---------------------------------------------------------------------------
Obj_Index:
	dc.l Obj01, ObjectMoveAndFall,	Obj03, ObjectMoveAndFall
	dc.l Obj05, ObjectMoveAndFall, ObjectMoveAndFall, Obj08
	dc.l Obj09, Obj0A, Obj0B, Obj0C
	dc.l Obj0D, Obj0E, Obj0F, Obj10
	dc.l Obj11, Obj12, Obj13, Obj14
	dc.l Obj15, Obj16, Obj17, Obj18
	dc.l Obj19, Obj1A, Obj1B, Obj1C
	dc.l Obj1D, Obj1E, Obj1F, Obj20
	dc.l Obj21, Obj22, Obj23, Obj24
	dc.l Obj25, Obj26, Obj27, Obj28
	dc.l Obj29, Obj2A, Obj2B, Obj2C
	dc.l Obj2D, Obj2E, Obj2F, Obj30
	dc.l Obj31, Obj32, Obj33, Obj34
	dc.l Obj35, Obj36, Obj37, Obj38
	dc.l Obj39, Obj3A, Obj3B, Obj3C
	dc.l Obj3D, Obj3E, Obj3F, Obj40
	dc.l Obj41, Obj42, Obj43, Obj44
	dc.l Obj45, Obj46, Obj47, Obj48
	dc.l Obj49, Obj4A, Obj4B, Obj4C
	dc.l Obj4D, Obj4E, Obj4F, Obj50
	dc.l Obj51, Obj52, Obj53, Obj54
	dc.l Obj55, Obj56, Obj57, Obj58
	dc.l Obj59, Obj5A, Obj5B, Obj5C
	dc.l Obj5D, Obj5E, Obj5F, Obj60
	dc.l Obj61, Obj62, Obj63, Obj64
	dc.l Obj65, Obj66, Obj67, Obj68
	dc.l Obj69, Obj6A, Obj6B, Obj6C
	dc.l Obj6D, Obj6E, Obj6F, Obj70
	dc.l Obj71, Obj72, Obj73, Obj74
	dc.l Obj75, Obj76, Obj77, Obj78
	dc.l Obj79, Obj7A, Obj7B, Obj7C
	dc.l Obj7D, Obj7E, Obj7F, Obj80
	dc.l Obj81, Obj82, Obj83, Obj84
	dc.l Obj85, Obj86, Obj87, Obj88
	dc.l Obj89, Obj8A, Obj8B, Obj8C
	dc.l ObjFlicky, ObjCat, ObjChick, ObjDoor

; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectMoveAndFall:
		move.w	$10(a0),d0
		ext.l	d0
		lsl.l	#8,d0
		add.l	d0,8(a0)
		move.w	$12(a0),d0
		addi.w	#$38,$12(a0)	; increase vertical speed
		ext.l	d0
		lsl.l	#8,d0
		add.l	d0,$C(a0)
		rts	
; End of function ObjectMoveAndFall

; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectMove:
		move.w	$10(a0),d0	; load horizontal speed
		ext.l	d0
		lsl.l	#8,d0		; multiply speed by $100
		add.l	d0,8(a0)	; add to x-axis	position
		move.w	$12(a0),d0	; load vertical	speed
		ext.l	d0
		lsl.l	#8,d0		; multiply by $100
		add.l	d0,$C(a0)	; add to y-axis	position
		rts	
; End of function ObjectMove

; ---------------------------------------------------------------------------
; Subroutine to	display	a sprite/object, when a0 is the	object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite:
		lea	(Sprite_Table_Input).w,a1
		move.w	$18(a0),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a1
		cmpi.w	#$7E,(a1)
		bcc.s	locret_D620
		addq.w	#2,(a1)
		adda.w	(a1),a1
		move.w	a0,(a1)

locret_D620:
		rts	
; End of function DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	display	a 2nd sprite/object, when a1 is	the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DisplaySprite2:
		lea	(Sprite_Table_Input).w,a2
		move.w	$18(a1),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		adda.w	d0,a2
		cmpi.w	#$7E,(a2)
		bcc.s	locret_D63E
		addq.w	#2,(a2)
		adda.w	(a2),a2
		move.w	a1,(a2)

locret_D63E:
		rts	
; End of function DisplaySprite2

; ---------------------------------------------------------------------------
; Subroutine to	delete an object
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DeleteObject:
		movea.l	a0,a1

DeleteObject2:
		moveq	#0,d1
		moveq	#$F,d0

loc_D646:
		move.l	d1,(a1)+	; clear	the object RAM
		dbf	d0,loc_D646	; repeat $F times (length of object RAM)
		rts	
; End of function DeleteObject

; ===========================================================================
LoadDPLC:
		moveq	#0,d0
		move.b	$1A(a0),d0	; load frame number
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	DPLC_End

DPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,DPLC_ReadEntry	; repeat for number of entries

DPLC_End:
		rts
; End of function LoadDPLC
; ===========================================================================
BldSpr_ScrPos:	dc.l 0			; blank
		dc.l Camera_X_Pos&$FFFFFF		; main screen x-position
		dc.l Camera_BG_X_Pos&$FFFFFF	; background x-position	1
		dc.l Camera_BG2_X_Pos&$FFFFFF	; background x-position	2
; ---------------------------------------------------------------------------
; Subroutine to	convert	mappings (etc) to proper Megadrive sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BuildSprites:				; XREF: TitleScreen; et al
		lea	(Sprite_Table).w,a2 ; set address for sprite table
		moveq	#0,d5
		lea	(Sprite_Table_Input).w,a4
		moveq	#7,d7

loc_D66A:
		tst.w	(a4)
		beq.w	loc_D72E
		moveq	#2,d6

loc_D672:
		movea.w	(a4,d6.w),a0
		tst.b	(a0)
		beq.w	loc_D726
		bclr	#7,1(a0)
		move.b	1(a0),d0
		move.b	d0,d4
		cmpi.b	#$10,(Game_Mode).w
		beq.s	BuildSprites_Flicky
		andi.w	#$C,d0
		beq.s	loc_D6DE
		movea.l	BldSpr_ScrPos(pc,d0.w),a1
		moveq	#0,d0
		move.b	$19(a0),d0
		move.w	8(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi.w	loc_D726
		move.w	d3,d1
		sub.w	d0,d1
		cmpi.w	#$140,d1
		bge.w	loc_D726
		addi.w	#$80,d3
		btst	#4,d4
		beq.s	loc_D6E8
		moveq	#0,d0
		move.b	$16(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_D726
		move.w	d2,d1
		sub.w	d0,d1
		cmpi.w	#$E0,d1
		bge.s	loc_D726
		addi.w	#$80,d2
		bra.s	loc_D700
; ===========================================================================

loc_D6DE:
		move.w	$A(a0),d2
		move.w	8(a0),d3
		bra.s	loc_D700
; ===========================================================================

BuildSprites_Flicky:
		move.w	$C(a0),d2
		addi.w	#$80,d2
		sub.w	(Camera_Y_Pos).w,d2
		move.w	8(a0),d3
		sub.w	(Camera_X_Pos).w,d3
		andi.w	#$FF,d3
		addi.w	#$80,d3
		bra.s	loc_D700
; ===========================================================================

loc_D6E8:
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		addi.w	#$80,d2
		cmpi.w	#$60,d2
		bcs.s	loc_D726
		cmpi.w	#$180,d2
		bcc.s	loc_D726

loc_D700:
		movea.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_D71C
		move.b	$1A(a0),d1
		add.b	d1,d1
		adda.w	(a1,d1.w),a1
		move.b	(a1)+,d1
		subq.b	#1,d1
		bmi.s	loc_D720

loc_D71C:
		bsr.w	sub_D750

loc_D720:
		bset	#7,1(a0)

loc_D726:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_D672

loc_D72E:
		lea	$80(a4),a4
		dbf	d7,loc_D66A
		move.b	d5,(Sprite_Count).w
		cmpi.b	#$50,d5
		beq.s	loc_D748
		move.l	#0,(a2)
		rts	
; ===========================================================================

loc_D748:
		move.b	#0,-5(a2)
		rts	
; End of function BuildSprites


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D750:				; XREF: BuildSprites
		movea.w	2(a0),a3
		btst	#0,d4
		bne.s	loc_D796
		btst	#1,d4
		bne.w	loc_D7E4
; End of function sub_D750


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_D762:				; XREF: sub_D762; SS_ShowLayout
		cmpi.b	#$50,d5
		beq.s	locret_D794
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D78E
		addq.w	#1,d0

loc_D78E:
		move.w	d0,(a2)+
		dbf	d1,sub_D762

locret_D794:
		rts	
; End of function sub_D762

; ===========================================================================

loc_D796:
		btst	#1,d4
		bne.w	loc_D82A

loc_D79E:
		cmpi.b	#$50,d5
		beq.s	locret_D7E2
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D7DC
		addq.w	#1,d0

loc_D7DC:
		move.w	d0,(a2)+
		dbf	d1,loc_D79E

locret_D7E2:
		rts	
; ===========================================================================

loc_D7E4:				; XREF: sub_D750
		cmpi.b	#$50,d5
		beq.s	locret_D828
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1000,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D822
		addq.w	#1,d0

loc_D822:
		move.w	d0,(a2)+
		dbf	d1,loc_D7E4

locret_D828:
		rts	
; ===========================================================================

loc_D82A:
		cmpi.b	#$50,d5
		beq.s	locret_D87C
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		lsl.b	#3,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.b	(a1)+,d0
		lsl.w	#8,d0
		move.b	(a1)+,d0
		add.w	a3,d0
		eori.w	#$1800,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d0
		ext.w	d0
		neg.w	d0
		add.b	d4,d4
		andi.w	#$18,d4
		addq.w	#8,d4
		sub.w	d4,d0
		add.w	d3,d0
		andi.w	#$1FF,d0
		bne.s	loc_D876
		addq.w	#1,d0

loc_D876:
		move.w	d0,(a2)+
		dbf	d1,loc_D82A

locret_D87C:
		rts	
; ---------------------------------------------------------------------------
; Subroutine to	check if an object is on the screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChkObjOnScreen:
		move.w	8(a0),d0	; get object x-position
		sub.w	(Camera_X_Pos).w,d0 ; subtract screen x-position
		bmi.s	NotOnScreen
		cmpi.w	#320,d0		; is object on the screen?
		bge.s	NotOnScreen	; if not, branch

		move.w	$C(a0),d1	; get object y-position
		sub.w	(Camera_Y_Pos).w,d1 ; subtract screen y-position
		bmi.s	NotOnScreen
		cmpi.w	#224,d1		; is object on the screen?
		bge.s	NotOnScreen	; if not, branch

		moveq	#0,d0		; set flag to 0
		rts	
; ===========================================================================

NotOnScreen:				; XREF: ChkObjOnScreen
		moveq	#1,d0		; set flag to 1
		rts	
; End of function ChkObjOnScreen


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ChkObjOnScreen2:
		moveq	#0,d1
		move.b	$19(a0),d1
		move.w	8(a0),d0
		sub.w	(Camera_X_Pos).w,d0
		add.w	d1,d0
		bmi.s	NotOnScreen2
		add.w	d1,d1
		sub.w	d1,d0
		cmpi.w	#320,d0
		bge.s	NotOnScreen2

		move.w	$C(a0),d1
		sub.w	(Camera_Y_Pos).w,d1
		bmi.s	NotOnScreen2
		cmpi.w	#224,d1
		bge.s	NotOnScreen2

		moveq	#0,d0
		rts	
; ===========================================================================

NotOnScreen2:				; XREF: ChkObjOnScreen2
		moveq	#1,d0
		rts	
; End of function ChkObjOnScreen2

; ---------------------------------------------------------------------------
; Subroutine to	load a level's objects
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjectsManager:				; XREF: Level; et al
		moveq	#0,d0
		move.b	(Obj_Manager_Routine).w,d0
		move.w	ObjectsManager_Index(pc,d0.w),d0
		jmp	ObjectsManager_Index(pc,d0.w)
; End of function ObjectsManager

; ===========================================================================
ObjectsManager_Index:
		dc.w ObjectsManager_Init-ObjectsManager_Index
		dc.w ObjectsManager_Main-ObjectsManager_Index
; ===========================================================================

ObjectsManager_Init:				; XREF: ObjectsManager_Index
		addq.b	#2,(Obj_Manager_Routine).w
		move.w	(Current_Zone_And_Act).w,d0
		ror.b	#2,d0
		lsr.w	#6,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(ObjPos_Index).l,a0
		movea.l	(a0,d0.w),a0
		move.l	a0,(Obj_Load_Addr_Right).w
		move.l	a0,(Obj_Load_Addr_Left).w
		lea	(Object_Respawn_Table).w,a2
		move.w	#$101,(a2)+
		move.w	#$5E,d0

OPL_ClrList:
		clr.l	(a2)+
		dbf	d0,OPL_ClrList	; clear	pre-destroyed object list

		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d2
		move.w	(Camera_X_Pos).w,d6
		subi.w	#$80,d6
		bcc.s	loc_D93C
		moveq	#0,d6

loc_D93C:
		andi.w	#$FF80,d6
		movea.l	(Obj_Load_Addr_Right).w,a0

loc_D944:
		cmp.w	(a0),d6
		bls.s	loc_D956
		tst.b	4(a0)
		bpl.s	loc_D952
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_D952:
		addq.w	#6,a0
		bra.s	loc_D944
; ===========================================================================

loc_D956:
		move.l	a0,(Obj_Load_Addr_Right).w
		movea.l	(Obj_Load_Addr_Left).w,a0
		subi.w	#$80,d6
		bcs.s	loc_D976

loc_D964:
		cmp.w	(a0),d6
		bls.s	loc_D976
		tst.b	4(a0)
		bpl.s	loc_D972
		addq.b	#1,1(a2)

loc_D972:
		addq.w	#6,a0
		bra.s	loc_D964
; ===========================================================================

loc_D976:
		move.l	a0,(Obj_Load_Addr_Left).w
		move.w	#-1,(Camera_X_Pos_Last).w
; ===========================================================================

ObjectsManager_Main:				; XREF: ObjectsManager_Index
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d2
		move.w	(Camera_X_Pos).w,d6
		andi.w	#$FF80,d6
		cmp.w	(Camera_X_Pos_Last).w,d6
		beq.w	locret_DA3A
		bge.s	loc_D9F6
		move.w	d6,(Camera_X_Pos_Last).w
		movea.l	(Obj_Load_Addr_Left).w,a0
		subi.w	#$80,d6
		bcs.s	loc_D9D2

loc_D9A6:
		cmp.w	-6(a0),d6
		bge.s	loc_D9D2
		subq.w	#6,a0
		tst.b	4(a0)
		bpl.s	loc_D9BC
		subq.b	#1,1(a2)
		move.b	1(a2),d2

loc_D9BC:
		bsr.w	loc_DA3C
		bne.s	loc_D9C6
		subq.w	#6,a0
		bra.s	loc_D9A6
; ===========================================================================

loc_D9C6:
		tst.b	4(a0)
		bpl.s	loc_D9D0
		addq.b	#1,1(a2)

loc_D9D0:
		addq.w	#6,a0

loc_D9D2:
		move.l	a0,(Obj_Load_Addr_Left).w
		movea.l	(Obj_Load_Addr_Right).w,a0
		addi.w	#$300,d6

loc_D9DE:
		cmp.w	-6(a0),d6
		bgt.s	loc_D9F0
		tst.b	-2(a0)
		bpl.s	loc_D9EC
		subq.b	#1,(a2)

loc_D9EC:
		subq.w	#6,a0
		bra.s	loc_D9DE
; ===========================================================================

loc_D9F0:
		move.l	a0,(Obj_Load_Addr_Right).w
		rts	
; ===========================================================================

loc_D9F6:
		move.w	d6,(Camera_X_Pos_Last).w
		movea.l	(Obj_Load_Addr_Right).w,a0
		addi.w	#$280,d6

loc_DA02:
		cmp.w	(a0),d6
		bls.s	loc_DA16
		tst.b	4(a0)
		bpl.s	loc_DA10
		move.b	(a2),d2
		addq.b	#1,(a2)

loc_DA10:
		bsr.w	loc_DA3C
		beq.s	loc_DA02
		tst.b	$4(a0)			; MJ: was this object a remember state?
		bpl.s	loc_DA16		; MJ: if not, branch
		subq.b	#$1,(a2)		; MJ: move right counter back

loc_DA16:
		move.l	a0,(Obj_Load_Addr_Right).w
		movea.l	(Obj_Load_Addr_Left).w,a0
		subi.w	#$300,d6
		bcs.s	loc_DA36

loc_DA24:
		cmp.w	(a0),d6
		bls.s	loc_DA36
		tst.b	4(a0)
		bpl.s	loc_DA32
		addq.b	#1,1(a2)

loc_DA32:
		addq.w	#6,a0
		bra.s	loc_DA24
; ===========================================================================

loc_DA36:
		move.l	a0,(Obj_Load_Addr_Left).w

locret_DA3A:
		rts	
; ===========================================================================

loc_DA3C:
		tst.b	4(a0)
		bpl.s	OPL_MakeItem
		btst	#7,2(a2,d2.w)
		beq.s	OPL_MakeItem
		addq.w	#6,a0
		moveq	#0,d0
		rts	
; ===========================================================================

OPL_MakeItem:
		bsr.w	SingleObjLoad
		bne.s	locret_DA8A
		move.w	(a0)+,8(a1)
		move.w	(a0)+,d0
		move.w	d0,d1
		andi.w	#$FFF,d0
		move.w	d0,$C(a1)
		rol.w	#2,d1
		andi.b	#3,d1
		move.b	d1,1(a1)
		move.b	d1,$22(a1)
		move.b	(a0)+,d0
		bpl.s	loc_DA80
		bset	#$7,$2(a2,d2.w)		; MJ: set as removed
		andi.b	#$7F,d0
		move.b	d2,$23(a1)

loc_DA80:
		move.b	d0,0(a1)
		move.b	(a0)+,$28(a1)
		moveq	#0,d0

locret_DA8A:
		rts	
; ---------------------------------------------------------------------------
; Single object	loading	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SingleObjLoad:
		lea	(Dynamic_Object_RAM).w,a1 ; start address for object RAM
		move.w	#((Dynamic_Object_RAM_End-Dynamic_Object_RAM)/$40)-1,d0

loc_DA94:
		tst.b	(a1)		; is object RAM	slot empty?
		beq.s	locret_DAA0	; if yes, branch
		lea	$40(a1),a1	; goto next object RAM slot
		dbf	d0,loc_DA94	; repeat $5F times

locret_DAA0:
		rts	
; End of function SingleObjLoad


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SingleObjLoad2:
		movea.l	a0,a1
		move.w	#Object_RAM_End,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	locret_DABC

loc_DAB0:
		tst.b	(a1)
		beq.s	locret_DABC
		lea	$40(a1),a1
		dbf	d0,loc_DAB0

locret_DABC:
		rts	
; End of function SingleObjLoad2

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 41 - springs
; ---------------------------------------------------------------------------

Obj41:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj41_Index(pc,d0.w),d1
		jsr	Obj41_Index(pc,d1.w)
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
Obj41_Index:	dc.w Obj41_Main-Obj41_Index
		dc.w Obj41_Up-Obj41_Index
		dc.w Obj41_AniUp-Obj41_Index
		dc.w Obj41_ResetUp-Obj41_Index
		dc.w Obj41_LR-Obj41_Index
		dc.w Obj41_AniLR-Obj41_Index
		dc.w Obj41_ResetLR-Obj41_Index
		dc.w Obj41_Dwn-Obj41_Index
		dc.w Obj41_AniDwn-Obj41_Index
		dc.w Obj41_ResetDwn-Obj41_Index

Obj41_Powers:	dc.w -$1000		; power	of red spring
		dc.w -$A00		; power	of yellow spring
; ===========================================================================

Obj41_Main:				; XREF: Obj41_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj41,4(a0)
		move.w	#$523,2(a0)
		ori.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),d0
		btst	#4,d0		; does the spring face left/right?
		beq.s	loc_DB54	; if not, branch
		move.b	#8,$24(a0)	; use "Obj41_LR" routine
		move.b	#1,$1C(a0)
		move.b	#3,$1A(a0)
		move.w	#$533,2(a0)
		move.b	#8,$19(a0)

loc_DB54:
		btst	#5,d0		; does the spring face downwards?
		beq.s	loc_DB66	; if not, branch
		move.b	#$E,$24(a0)	; use "Obj41_Dwn" routine
		bset	#1,$22(a0)

loc_DB66:
		btst	#1,d0
		beq.s	loc_DB72
		bset	#5,2(a0)

loc_DB72:
		andi.w	#$F,d0
		move.w	Obj41_Powers(pc,d0.w),$30(a0)
		rts	
; ===========================================================================

Obj41_Up:				; XREF: Obj41_Index
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		tst.b	$25(a0)		; is Sonic on top of the spring?
		bne.s	Obj41_BounceUp	; if yes, branch
		rts	
; ===========================================================================

Obj41_BounceUp:				; XREF: Obj41_Up
		addq.b	#2,$24(a0)
		addq.w	#8,$C(a1)
		move.w	$30(a0),$12(a1)	; move Sonic upwards
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#$10,$1C(a1)	; use "bouncing" animation
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		move.w	#SndID_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

Obj41_AniUp:				; XREF: Obj41_Index
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Obj41_ResetUp:				; XREF: Obj41_Index
		move.b	#1,$1D(a0)	; reset	animation
		subq.b	#4,$24(a0)	; goto "Obj41_Up" routine
		rts	
; ===========================================================================

Obj41_LR:				; XREF: Obj41_Index
		move.w	#$13,d1
		move.w	#$E,d2
		move.w	#$F,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		cmpi.b	#2,$24(a0)
		bne.s	loc_DC0C
		move.b	#8,$24(a0)

loc_DC0C:
		btst	#5,$22(a0)
		bne.s	Obj41_BounceLR
		rts	
; ===========================================================================

Obj41_BounceLR:				; XREF: Obj41_LR
		addq.b	#2,$24(a0)
		move.w	$30(a0),$10(a1)	; move Sonic to	the left
		addq.w	#8,8(a1)
		btst	#0,$22(a0)	; is object flipped?
		bne.s	loc_DC36	; if yes, branch
		subi.w	#$10,8(a1)
		neg.w	$10(a1)		; move Sonic to	the right
		
loc_DC36:
		move.w	#$F,$2E(a1)
		move.w	$10(a1),$14(a1)
		bchg	#0,$22(a1)
		btst	#2,$22(a1)
		bne.s	loc_DC56
		move.b	#0,d0
		tst.b	$39(a1)
		beq.s	@not_crawling
		nop
		move.b	#$A,d0 	; use crawling animation
		
@not_crawling:
		move.b	d0,$1C(a1)

loc_DC56:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)
		move.w	#SndID_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

Obj41_AniLR:				; XREF: Obj41_Index
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Obj41_ResetLR:				; XREF: Obj41_Index
		move.b	#2,$1D(a0)	; reset	animation
		subq.b	#4,$24(a0)	; goto "Obj41_LR" routine
		rts	
; ===========================================================================

Obj41_Dwn:				; XREF: Obj41_Index
		move.w	#$1B,d1
		move.w	#8,d2
		move.w	#$10,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		cmpi.b	#2,$24(a0)
		bne.s	loc_DCA4
		move.b	#$E,$24(a0)

loc_DCA4:
		tst.b	$25(a0)
		bne.s	locret_DCAE
		tst.w	d4
		bmi.s	Obj41_BounceDwn

locret_DCAE:
		rts	
; ===========================================================================

Obj41_BounceDwn:			; XREF: Obj41_Dwn
		addq.b	#2,$24(a0)
		subq.w	#8,$C(a1)
		move.w	$30(a0),$12(a1)
		neg.w	$12(a1)		; move Sonic downwards
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		move.w	#SndID_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

Obj41_AniDwn:				; XREF: Obj41_Index
		lea	(Ani_obj41).l,a1
		bra.w	AnimateSprite
; ===========================================================================

Obj41_ResetDwn:				; XREF: Obj41_Index
		move.b	#1,$1D(a0)	; reset	animation
		subq.b	#4,$24(a0)	; goto "Obj41_Dwn" routine
		rts	
; ===========================================================================
Ani_obj41:
	include "objects/animation/obj41.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - springs
; ---------------------------------------------------------------------------
Map_obj41:
	include "mappings/sprite/obj41.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 42 - Newtron enemy (GHZ)
; ---------------------------------------------------------------------------

Obj42:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj42_Index(pc,d0.w),d1
		jmp	Obj42_Index(pc,d1.w)
; ===========================================================================
Obj42_Index:	dc.w Obj42_Main-Obj42_Index
		dc.w Obj42_Action-Obj42_Index
		dc.w Obj42_Delete-Obj42_Index
; ===========================================================================

Obj42_Main:				; XREF: Obj42_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj42,4(a0)
		move.w	#$49B,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$14,$19(a0)
		move.b	#$10,$16(a0)
		move.b	#8,$17(a0)

Obj42_Action:				; XREF: Obj42_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj42_Index2(pc,d0.w),d1
		jsr	Obj42_Index2(pc,d1.w)
		lea	(Ani_obj42).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj42_Index2:	dc.w Obj42_ChkDist-Obj42_Index2
		dc.w Obj42_Type00-Obj42_Index2
		dc.w Obj42_MatchFloor-Obj42_Index2
		dc.w Obj42_Speed-Obj42_Index2
		dc.w Obj42_Type01-Obj42_Index2
; ===========================================================================

Obj42_ChkDist:				; XREF: Obj42_Index2
		bset	#0,$22(a0)
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_DDEA
		neg.w	d0
		bclr	#0,$22(a0)

loc_DDEA:
		cmpi.w	#$80,d0		; is Sonic within $80 pixels of	the newtron?
		bcc.s	locret_DE12	; if not, branch
		addq.b	#2,$25(a0)
		move.b	#1,$1C(a0)
		tst.b	$28(a0)		; check	object type
		beq.s	locret_DE12	; if type is 00, branch
		move.w	#$249B,2(a0)
		move.b	#8,$25(a0)	; run type 01 newtron subroutine
		move.b	#4,$1C(a0)	; use different	animation

locret_DE12:
		rts	
; ===========================================================================

Obj42_Type00:				; XREF: Obj42_Index2
		cmpi.b	#4,$1A(a0)	; has "appearing" animation finished?
		bcc.s	Obj42_Fall	; is yes, branch
		bset	#0,$22(a0)
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	locret_DE32
		bclr	#0,$22(a0)

locret_DE32:
		rts	
; ===========================================================================

Obj42_Fall:				; XREF: Obj42_Type00
		cmpi.b	#1,$1A(a0)
		bne.s	loc_DE42
		move.b	#$C,$20(a0)

loc_DE42:
		bsr.w	ObjectMoveAndFall
		bsr.w	ObjHitFloor
		tst.w	d1		; has newtron hit the floor?
		bpl.s	locret_DE86	; if not, branch
		add.w	d1,$C(a0)
		move.w	#0,$12(a0)	; stop newtron falling
		addq.b	#2,$25(a0)
		move.b	#2,$1C(a0)
		btst	#5,2(a0)
		beq.s	Obj42_Move
		addq.b	#1,$1C(a0)

Obj42_Move:
		move.b	#$D,$20(a0)
		move.w	#$200,$10(a0)	; move newtron horizontally
		btst	#0,$22(a0)
		bne.s	locret_DE86
		neg.w	$10(a0)

locret_DE86:
		rts	
; ===========================================================================

Obj42_MatchFloor:			; XREF: Obj42_Index2
		bsr.w	ObjectMove
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	loc_DEA2
		cmpi.w	#$C,d1
		bge.s	loc_DEA2
		add.w	d1,$C(a0)	; match	newtron's position with floor
		rts	
; ===========================================================================

loc_DEA2:
		addq.b	#2,$25(a0)
		rts	
; ===========================================================================

Obj42_Speed:				; XREF: Obj42_Index2
		bsr.w	ObjectMove
		rts	
; ===========================================================================

Obj42_Type01:				; XREF: Obj42_Index2
		cmpi.b	#1,$1A(a0)
		bne.s	Obj42_FireMissile
		move.b	#$C,$20(a0)

Obj42_FireMissile:
		cmpi.b	#2,$1A(a0)
		bne.s	locret_DF14
		tst.b	$32(a0)
		bne.s	locret_DF14
		move.b	#1,$32(a0)
		bsr.w	SingleObjLoad
		bne.s	locret_DF14
		move.b	#$23,0(a1)	; load missile object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		subq.w	#8,$C(a1)
		move.w	#$200,$10(a1)
		move.w	#$14,d0
		btst	#0,$22(a0)
		bne.s	loc_DF04
		neg.w	d0
		neg.w	$10(a1)

loc_DF04:
		add.w	d0,8(a1)
		move.b	$22(a0),$22(a1)
		move.b	#1,$28(a1)

locret_DF14:
		rts	
; ===========================================================================

Obj42_Delete:				; XREF: Obj42_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj42:
	include "objects/animation/obj42.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Newtron enemy (GHZ)
; ---------------------------------------------------------------------------
Map_obj42:
	include "mappings/sprite/obj42.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 43 - Roller enemy (SYZ)
; ---------------------------------------------------------------------------

Obj43:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj43_Index(pc,d0.w),d1
		jmp	Obj43_Index(pc,d1.w)
; ===========================================================================
Obj43_Index:	dc.w Obj43_Main-Obj43_Index
		dc.w Obj43_Action-Obj43_Index
; ===========================================================================

Obj43_Main:				; XREF: Obj43_Index
		move.b	#$E,$16(a0)
		move.b	#8,$17(a0)
		bsr.w	ObjectMoveAndFall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_E052
		add.w	d1,$C(a0)	; match	roller's position with the floor
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)
		move.l	#Map_obj43,4(a0)
		move.w	#$4B8,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$10,$19(a0)

locret_E052:
		rts	
; ===========================================================================

Obj43_Action:				; XREF: Obj43_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj43_Index2(pc,d0.w),d1
		jsr	Obj43_Index2(pc,d1.w)
		lea	(Ani_obj43).l,a1
		bsr.w	AnimateSprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bgt.w	Obj43_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Obj43_ChkGone:				; XREF: Obj43_Action
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj43_Delete
		bclr	#7,2(a2,d0.w)

Obj43_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj43_Index2:	dc.w Obj43_RollChk-Obj43_Index2
		dc.w Obj43_RollNoChk-Obj43_Index2
		dc.w Obj43_ChkJump-Obj43_Index2
		dc.w Obj43_MatchFloor-Obj43_Index2
; ===========================================================================

Obj43_RollChk:				; XREF: Obj43_Index2
		move.w	(Object_Space_1+8).w,d0
		subi.w	#$100,d0
		bcs.s	loc_E0D2
		sub.w	8(a0),d0	; check	distance between Roller	and Sonic
		bcs.s	loc_E0D2
		addq.b	#4,$25(a0)
		move.b	#2,$1C(a0)
		move.w	#$700,$10(a0)	; move Roller horizontally
		move.b	#$8E,$20(a0)	; make Roller invincible

loc_E0D2:
		addq.l	#4,sp
		rts	
; ===========================================================================

Obj43_RollNoChk:			; XREF: Obj43_Index2
		cmpi.b	#2,$1C(a0)
		beq.s	loc_E0F8
		subq.w	#1,$30(a0)
		bpl.s	locret_E0F6
		move.b	#1,$1C(a0)
		move.w	#$700,$10(a0)
		move.b	#$8E,$20(a0)

locret_E0F6:
		rts	
; ===========================================================================

loc_E0F8:
		addq.b	#2,$25(a0)
		rts	
; ===========================================================================

Obj43_ChkJump:				; XREF: Obj43_Index2
		bsr.w	Obj43_Stop
		bsr.w	ObjectMove
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	Obj43_Jump
		cmpi.w	#$C,d1
		bge.s	Obj43_Jump
		add.w	d1,$C(a0)
		rts	
; ===========================================================================

Obj43_Jump:
		addq.b	#2,$25(a0)
		bset	#0,$32(a0)
		beq.s	locret_E12E
		move.w	#-$600,$12(a0)	; move Roller vertically

locret_E12E:
		rts	
; ===========================================================================

Obj43_MatchFloor:			; XREF: Obj43_Index2
		bsr.w	ObjectMoveAndFall
		tst.w	$12(a0)
		bmi.s	locret_E150
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_E150
		add.w	d1,$C(a0)	; match	Roller's position with the floor
		subq.b	#2,$25(a0)
		move.w	#0,$12(a0)

locret_E150:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj43_Stop:				; XREF: Obj43_ChkJump
		tst.b	$32(a0)
		bmi.s	locret_E188
		move.w	(Object_Space_1+8).w,d0
		subi.w	#$30,d0
		sub.w	8(a0),d0
		bcc.s	locret_E188
		move.b	#0,$1C(a0)
		move.b	#$E,$20(a0)
		clr.w	$10(a0)
		move.w	#120,$30(a0)	; set waiting time to 2	seconds
		move.b	#2,$25(a0)
		bset	#7,$32(a0)

locret_E188:
		rts	
; End of function Obj43_Stop

; ===========================================================================
Ani_obj43:
	include "objects/animation/obj43.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Roller enemy (SYZ)
; ---------------------------------------------------------------------------
Map_obj43:
	include "mappings/sprite/obj43.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 44 - walls (GHZ)
; ---------------------------------------------------------------------------

Obj44:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj44_Index(pc,d0.w),d1
		jmp	Obj44_Index(pc,d1.w)
; ===========================================================================
Obj44_Index:	dc.w Obj44_Main-Obj44_Index
		dc.w Obj44_Solid-Obj44_Index
		dc.w Obj44_Display-Obj44_Index
; ===========================================================================

Obj44_Main:				; XREF: Obj44_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj44,4(a0)
		move.w	#$434C,2(a0)
		ori.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#6,$18(a0)
		move.b	$28(a0),$1A(a0)	; copy object type number to frame number
		bclr	#4,$1A(a0)	; clear	4th bit	(deduct	$10)
		beq.s	Obj44_Solid	; make object solid if 4th bit = 0
		addq.b	#2,$24(a0)
		bra.s	Obj44_Display	; don't make it solid if 4th bit = 1
; ===========================================================================

Obj44_Solid:				; XREF: Obj44_Index
		move.w	#$13,d1
		move.w	#$28,d2
		bsr.w	Obj44_SolidWall

Obj44_Display:				; XREF: Obj44_Index
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - walls (GHZ)
; ---------------------------------------------------------------------------
Map_obj44:
	include "mappings/sprite/obj44.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 13 - lava ball	producer (MZ, SLZ)
; ---------------------------------------------------------------------------

Obj13:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj13_Index(pc,d0.w),d1
		jsr	Obj13_Index(pc,d1.w)
		bra.w	Obj14_ChkDel
; ===========================================================================
Obj13_Index:	dc.w Obj13_Main-Obj13_Index
		dc.w Obj13_MakeLava-Obj13_Index
; ---------------------------------------------------------------------------
;
; Lava ball production rates
;
Obj13_Rates:	dc.b 30, 60, 90, 120, 150, 180
; ===========================================================================

Obj13_Main:				; XREF: Obj13_Index
		addq.b	#2,$24(a0)
		move.b	$28(a0),d0
		lsr.w	#4,d0
		andi.w	#$F,d0
		move.b	Obj13_Rates(pc,d0.w),$1F(a0)
		move.b	$1F(a0),$1E(a0)	; set time delay for lava balls
		andi.b	#$F,$28(a0)

Obj13_MakeLava:				; XREF: Obj13_Index
		subq.b	#1,$1E(a0)	; subtract 1 from time delay
		bne.s	locret_E302	; if time still	remains, branch
		move.b	$1F(a0),$1E(a0)	; reset	time delay
		bsr.w	ChkObjOnScreen
		bne.s	locret_E302
		bsr.w	SingleObjLoad
		bne.s	locret_E302
		move.b	#$14,0(a1)	; load lava ball object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$28(a0),$28(a1)

locret_E302:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 14 - lava balls (MZ, SLZ)
; ---------------------------------------------------------------------------

Obj14:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj14_Index(pc,d0.w),d1
		jsr	Obj14_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj14_Index:	dc.w Obj14_Main-Obj14_Index
		dc.w Obj14_Action-Obj14_Index
		dc.w Obj14_Delete-Obj14_Index

Obj14_Speeds:	dc.w $FC00, $FB00, $FA00, $F900, $FE00
		dc.w $200, $FE00, $200,	0
; ===========================================================================

Obj14_Main:				; XREF: Obj14_Index
		addq.b	#2,$24(a0)
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj14,4(a0)
		move.w	#$345,2(a0)
		cmpi.b	#3,(Current_Zone).w ; check if level is SLZ
		bne.s	loc_E35A
		move.w	#$480,2(a0)	; SLZ specific code

loc_E35A:
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$8B,$20(a0)
		move.w	$C(a0),$30(a0)
		tst.b	$29(a0)
		beq.s	Obj14_SetSpeed
		addq.b	#2,$18(a0)

Obj14_SetSpeed:
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj14_Speeds(pc,d0.w),$12(a0) ;	load object speed (vertical)
		move.b	#8,$19(a0)
		cmpi.b	#6,$28(a0)	; is object type below $6 ?
		bcs.s	Obj14_PlaySnd	; if yes, branch
		move.b	#$10,$19(a0)
		move.b	#2,$1C(a0)	; use horizontal animation
		move.w	$12(a0),$10(a0)	; set horizontal speed
		move.w	#0,$12(a0)	; delete vertical speed

Obj14_PlaySnd:
		move.w	#SndID_Fireball,d0
		jsr	(PlaySound_Special).l ;	play lava ball sound

Obj14_Action:				; XREF: Obj14_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj14_TypeIndex(pc,d0.w),d1
		jsr	Obj14_TypeIndex(pc,d1.w)
		bsr.w	ObjectMove
		lea	(Ani_obj14).l,a1
		bsr.w	AnimateSprite

Obj14_ChkDel:				; XREF: Obj13
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
Obj14_TypeIndex:dc.w Obj14_Type00-Obj14_TypeIndex, Obj14_Type00-Obj14_TypeIndex
		dc.w Obj14_Type00-Obj14_TypeIndex, Obj14_Type00-Obj14_TypeIndex
		dc.w Obj14_Type04-Obj14_TypeIndex, Obj14_Type05-Obj14_TypeIndex
		dc.w Obj14_Type06-Obj14_TypeIndex, Obj14_Type07-Obj14_TypeIndex
		dc.w Obj14_Type08-Obj14_TypeIndex
; ===========================================================================
; lavaball types 00-03 fly up and fall back down

Obj14_Type00:				; XREF: Obj14_TypeIndex
		addi.w	#$18,$12(a0)	; increase object's downward speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0	; has object fallen back to its	original position?
		bcc.s	loc_E41E	; if not, branch
		addq.b	#2,$24(a0)	; goto "Obj14_Delete" routine

loc_E41E:
		bclr	#1,$22(a0)
		tst.w	$12(a0)
		bpl.s	locret_E430
		bset	#1,$22(a0)

locret_E430:
		rts	
; ===========================================================================
; lavaball type	04 flies up until it hits the ceiling

Obj14_Type04:				; XREF: Obj14_TypeIndex
		bset	#1,$22(a0)
		bsr.w	ObjHitCeiling
		tst.w	d1
		bpl.s	locret_E452
		move.b	#8,$28(a0)
		move.b	#1,$1C(a0)
		move.w	#0,$12(a0)	; stop the object when it touches the ceiling

locret_E452:
		rts	
; ===========================================================================
; lavaball type	05 falls down until it hits the	floor

Obj14_Type05:				; XREF: Obj14_TypeIndex
		bclr	#1,$22(a0)
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_E474
		move.b	#8,$28(a0)
		move.b	#1,$1C(a0)
		move.w	#0,$12(a0)	; stop the object when it touches the floor

locret_E474:
		rts	
; ===========================================================================
; lavaball types 06-07 move sideways

Obj14_Type06:				; XREF: Obj14_TypeIndex
		bset	#0,$22(a0)
		moveq	#-8,d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bpl.s	locret_E498
		move.b	#8,$28(a0)
		move.b	#3,$1C(a0)
		move.w	#0,$10(a0)	; stop object when it touches a	wall

locret_E498:
		rts	
; ===========================================================================

Obj14_Type07:				; XREF: Obj14_TypeIndex
		bclr	#0,$22(a0)
		moveq	#8,d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bpl.s	locret_E4BC
		move.b	#8,$28(a0)
		move.b	#3,$1C(a0)
		move.w	#0,$10(a0)	; stop object when it touches a	wall

locret_E4BC:
		rts	
; ===========================================================================

Obj14_Type08:				; XREF: Obj14_TypeIndex
		rts	
; ===========================================================================

Obj14_Delete:				; XREF: Obj14_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj14:
	include "objects/animation/obj14.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6D - Unused
; ---------------------------------------------------------------------------

Obj6D:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 46 - solid blocks and blocks that fall	from the ceiling (MZ)
; ---------------------------------------------------------------------------

Obj46:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj46_Index(pc,d0.w),d1
		jmp	Obj46_Index(pc,d1.w)
; ===========================================================================
Obj46_Index:	dc.w Obj46_Main-Obj46_Index
		dc.w Obj46_Action-Obj46_Index
; ===========================================================================

Obj46_Main:				; XREF: Obj46_Index
		addq.b	#2,$24(a0)
		move.b	#$F,$16(a0)
		move.b	#$F,$17(a0)
		move.l	#Map_obj46,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$10,$19(a0)
		move.w	$C(a0),$30(a0)
		move.w	#$5C0,$32(a0)

Obj46_Action:				; XREF: Obj46_Index
		tst.b	1(a0)
		bpl.s	Obj46_ChkDel
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#7,d0		; read only the	1st digit
		add.w	d0,d0
		move.w	Obj46_TypeIndex(pc,d0.w),d1
		jsr	Obj46_TypeIndex(pc,d1.w)
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject

Obj46_ChkDel:
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
Obj46_TypeIndex:dc.w Obj46_Type00-Obj46_TypeIndex
		dc.w Obj46_Type01-Obj46_TypeIndex
		dc.w Obj46_Type02-Obj46_TypeIndex
		dc.w Obj46_Type03-Obj46_TypeIndex
		dc.w Obj46_Type04-Obj46_TypeIndex
; ===========================================================================

Obj46_Type00:				; XREF: Obj46_TypeIndex
		rts	
; ===========================================================================

Obj46_Type02:				; XREF: Obj46_TypeIndex
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_E888
		neg.w	d0

loc_E888:
		cmpi.w	#$90,d0		; is Sonic within $90 pixels of	the block?
		bcc.s	Obj46_Type01	; if not, resume wobbling
		move.b	#3,$28(a0)	; if yes, make the block fall

Obj46_Type01:				; XREF: Obj46_TypeIndex
		moveq	#0,d0
		move.b	(Oscillation_Data+$14).w,d0
		btst	#3,$28(a0)
		beq.s	loc_E8A8
		neg.w	d0
		addi.w	#$10,d0

loc_E8A8:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; update the block's position to make it wobble
		rts	
; ===========================================================================

Obj46_Type03:				; XREF: Obj46_TypeIndex
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)	; increase falling speed
		bsr.w	ObjHitFloor
		tst.w	d1		; has the block	hit the	floor?
		bpl.w	locret_E8EE	; if not, branch
		add.w	d1,$C(a0)
		clr.w	$12(a0)		; stop the block falling
		move.w	$C(a0),$30(a0)
		move.b	#4,$28(a0)
		move.w	(a1),d0
		andi.w	#$3FF,d0
		cmpi.w	#$2E8,d0
		bcc.s	locret_E8EE
		move.b	#0,$28(a0)

locret_E8EE:
		rts	
; ===========================================================================

Obj46_Type04:				; XREF: Obj46_TypeIndex
		moveq	#0,d0
		move.b	(Oscillation_Data+$10).w,d0
		lsr.w	#3,d0
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; make the block wobble
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - solid blocks and blocks that fall from the ceiling (MZ)
; ---------------------------------------------------------------------------
Map_obj46:
	include "mappings/sprite/obj46.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 12 - lamp (SYZ)
; ---------------------------------------------------------------------------

Obj12:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj12_Index(pc,d0.w),d1
		jmp	Obj12_Index(pc,d1.w)
; ===========================================================================
Obj12_Index:	dc.w Obj12_Main-Obj12_Index
		dc.w Obj12_Animate-Obj12_Index
; ===========================================================================

Obj12_Main:				; XREF: Obj12_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj12,4(a0)
		move.w	#0,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#6,$18(a0)

Obj12_Animate:				; XREF: Obj12_Index
		subq.b	#1,$1E(a0)
		bpl.s	Obj12_ChkDel
		move.b	#7,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#6,$1A(a0)
		bcs.s	Obj12_ChkDel
		move.b	#0,$1A(a0)

Obj12_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - lamp (SYZ)
; ---------------------------------------------------------------------------
Map_obj12:
	include "mappings/sprite/obj12.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 47 - pinball bumper (SYZ)
; ---------------------------------------------------------------------------

Obj47:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj47_Index(pc,d0.w),d1
		jmp	Obj47_Index(pc,d1.w)
; ===========================================================================
Obj47_Index:	dc.w Obj47_Main-Obj47_Index
		dc.w Obj47_Hit-Obj47_Index
; ===========================================================================

Obj47_Main:				; XREF: Obj47_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj47,4(a0)
		move.w	#$380,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#1,$18(a0)
		move.b	#$D7,$20(a0)

Obj47_Hit:				; XREF: Obj47_Index
		tst.b	$21(a0)		; has Sonic touched the	bumper?
		beq.w	Obj47_Display	; if not, branch
		clr.b	$21(a0)
		lea	(Object_RAM).w,a1
		move.w	8(a0),d1
		move.w	$C(a0),d2
		sub.w	8(a1),d1
		sub.w	$C(a1),d2
		jsr	(CalcAngle).l
		jsr	(CalcSine).l
		muls.w	#-$700,d1
		asr.l	#8,d1
		move.w	d1,$10(a1)	; bounce Sonic away
		muls.w	#-$700,d0
		asr.l	#8,d0
		move.w	d0,$12(a1)	; bounce Sonic away
		bset	#1,$22(a1)
		bclr	#4,$22(a1)
		bclr	#5,$22(a1)
		clr.b	$3C(a1)
		move.b	#1,$1C(a0)
		move.w	#SndID_Bumper,d0
		jsr	(PlaySound_Special).l ;	play bumper sound
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj47_Score
		cmpi.b	#$8A,2(a2,d0.w)	; has bumper been hit $8A times?
		bcc.s	Obj47_Display	; if yes, Sonic	gets no	points
		addq.b	#1,2(a2,d0.w)

Obj47_Score:
		moveq	#1,d0
		jsr	AddPoints	; add 10 to score
		bsr.w	SingleObjLoad
		bne.s	Obj47_Display
		move.b	#$29,0(a1)	; load points object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#4,$1A(a1)

Obj47_Display:
		lea	(Ani_obj47).l,a1
		bsr.w	AnimateSprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj47_ChkHit
		bra.w	DisplaySprite
; ===========================================================================

Obj47_ChkHit:				; XREF: Obj47_Display
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj47_Delete
		bclr	#7,2(a2,d0.w)

Obj47_Delete:
		bra.w	DeleteObject
; ===========================================================================
Ani_obj47:
	include "objects/animation/obj47.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - pinball bumper (SYZ)
; ---------------------------------------------------------------------------
Map_obj47:
	include "mappings/sprite/obj47.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0D - signpost at the end of a level
; ---------------------------------------------------------------------------

Obj0D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0D_Index(pc,d0.w),d1
		jsr	Obj0D_Index(pc,d1.w)
		lea	(Ani_obj0D).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
Obj0D_Index:	dc.w Obj0D_Main-Obj0D_Index
		dc.w Obj0D_Touch-Obj0D_Index
		dc.w Obj0D_Spin-Obj0D_Index
		dc.w Obj0D_SonicRun-Obj0D_Index
		dc.w locret_ED1A-Obj0D_Index
; ===========================================================================

Obj0D_Main:				; XREF: Obj0D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0D,4(a0)
		move.w	#$680,2(a0)
		move.b	#4,1(a0)
		move.b	#$18,$19(a0)
		move.b	#4,$18(a0)

Obj0D_Touch:				; XREF: Obj0D_Index
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcs.s	locret_EBBA
		cmpi.w	#$20,d0		; is Sonic within $20 pixels of	the signpost?
		bcc.s	locret_EBBA	; if not, branch
		move.w	#SndID_Signpost,d0
		jsr	(PlaySound).l	; play signpost	sound
		clr.b	(Update_HUD_Timer).w	; stop time counter
		move.w	(Camera_Max_X_Pos).w,(Camera_Min_X_Pos).w ; lock screen position
		addq.b	#2,$24(a0)

locret_EBBA:
		rts	
; ===========================================================================

Obj0D_Spin:				; XREF: Obj0D_Index
		subq.w	#1,$30(a0)	; subtract 1 from spin time
		bpl.s	Obj0D_Sparkle	; if time remains, branch
		move.w	#60,$30(a0)	; set spin cycle time to 1 second
		addq.b	#1,$1C(a0)	; next spin cycle
		cmpi.b	#3,$1C(a0)	; have 3 spin cycles completed?
		bne.s	Obj0D_Sparkle	; if not, branch
		addq.b	#2,$24(a0)

Obj0D_Sparkle:
		subq.w	#1,$32(a0)	; subtract 1 from time delay
		bpl.s	locret_EC42	; if time remains, branch
		move.w	#$B,$32(a0)	; set time between sparkles to $B frames
		moveq	#0,d0
		move.b	$34(a0),d0
		addq.b	#2,$34(a0)
		andi.b	#$E,$34(a0)
		lea	Obj0D_SparkPos(pc,d0.w),a2 ; load sparkle position data
		bsr.w	SingleObjLoad
		bne.s	locret_EC42
		move.b	#$25,0(a1)	; load rings object
		move.b	#6,$24(a1)	; jump to ring sparkle subroutine
		move.b	(a2)+,d0
		ext.w	d0
		add.w	8(a0),d0
		move.w	d0,8(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	$C(a0),d0
		move.w	d0,$C(a1)
		move.l	#Map_obj25,4(a1)
		move.w	#$27B2,2(a1)
		move.b	#4,1(a1)
		move.b	#2,$18(a1)
		move.b	#8,$19(a1)

locret_EC42:
		rts	
; ===========================================================================
Obj0D_SparkPos:	dc.b -$18,-$10		; x-position, y-position
		dc.b	8,   8
		dc.b -$10,   0
		dc.b  $18,  -8
		dc.b	0,  -8
		dc.b  $10,   0
		dc.b -$18,   8
		dc.b  $18, $10
; ===========================================================================

Obj0D_SonicRun:				; XREF: Obj0D_Index
		tst.w	(Debug_Placement_Mode).w	; is debug mode	on?
		bne.w	locret_ECEE	; if yes, branch
		btst	#1,(Object_Space_1+$22).w
		bne.s	loc_EC70
		move.b	#1,(Lock_Controls_Flag).w ; lock	controls
		move.w	#$800,(Sonic_Ctrl_Held).w ; make Sonic run to	the right

loc_EC70:
		tst.b	(Object_RAM).w
		beq.s	loc_EC86
		move.w	(Object_Space_1+8).w,d0
		move.w	(Camera_Max_X_Pos).w,d1
		addi.w	#$128,d1
		cmp.w	d1,d0
		bcs.s	locret_ECEE

loc_EC86:
		addq.b	#2,$24(a0)

; ---------------------------------------------------------------------------
; Subroutine to	set up bonuses at the end of an	act
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GotThroughAct:				; XREF: Obj3E_EndAct
		tst.b	(Object_Space_24).w
		bne.s	locret_ECEE
		move.w	(Camera_Max_X_Pos).w,(Camera_Min_X_Pos).w
		clr.b	(Invincibility_Flag).w	; disable invincibility
		clr.b	(Update_HUD_Timer).w	; stop time counter
		move.b	#$3A,(Object_Space_24).w
		moveq	#$10,d0
		jsr	(LoadPLC2).l	; load title card patterns
		move.b	#1,(Update_Bonus_Flag).w
		moveq	#0,d0
		move.b	(Timer_Minute).w,d0
		mulu.w	#60,d0		; convert minutes to seconds
		moveq	#0,d1
		move.b	(Timer_Second).w,d1
		add.w	d1,d0		; add up your time
		divu.w	#15,d0		; divide by 15
		moveq	#$14,d1
		cmp.w	d1,d0		; is time 5 minutes or higher?
		bcs.s	loc_ECD0	; if not, branch
		move.w	d1,d0		; use minimum time bonus (0)

loc_ECD0:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),(Time_Bonus).w ; set time bonus
		move.w	(Ring_Count).w,d0 ; load	number of rings
		mulu.w	#10,d0		; multiply by 10
		move.w	d0,(Ring_Bonus).w ; set ring bonus
		move.b	#1,(No_Music_Ctrl).w
		move.w	#MusID_EndOfAct,d0
		jsr	(PlaySound_Special).l ;	play "Sonic got	through" music

locret_ECEE:
		rts	
; End of function GotThroughAct

; ===========================================================================
TimeBonuses:	dc.w 5000, 5000, 1000, 500, 400, 400, 300, 300,	200, 200
		dc.w 200, 200, 100, 100, 100, 100, 50, 50, 50, 50, 0
; ===========================================================================

locret_ED1A:				; XREF: Obj0D_Index
		rts	
; ===========================================================================
Ani_obj0D:
	include "objects/animation/obj0D.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - signpost
; ---------------------------------------------------------------------------
Map_obj0D:
	include "mappings/sprite/obj0D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4C - lava geyser / lavafall producer (MZ)
; ---------------------------------------------------------------------------

Obj4C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4C_Index(pc,d0.w),d1
		jsr	Obj4C_Index(pc,d1.w)
		bra.w	Obj4D_ChkDel
; ===========================================================================
Obj4C_Index:	dc.w Obj4C_Main-Obj4C_Index
		dc.w loc_EDCC-Obj4C_Index
		dc.w loc_EE3E-Obj4C_Index
		dc.w Obj4C_MakeLava-Obj4C_Index
		dc.w Obj4C_Display-Obj4C_Index
		dc.w Obj4C_Delete-Obj4C_Index
; ===========================================================================

Obj4C_Main:				; XREF: Obj4C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj4C,4(a0)
		move.w	#$E3A8,2(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$38,$19(a0)
		move.w	#120,$34(a0)	; set time delay to 2 seconds

loc_EDCC:				; XREF: Obj4C_Index
		subq.w	#1,$32(a0)
		bpl.s	locret_EDF0
		move.w	$34(a0),$32(a0)
		move.w	(Object_Space_1+$C).w,d0
		move.w	$C(a0),d1
		cmp.w	d1,d0
		bcc.s	locret_EDF0
		subi.w	#$170,d1
		cmp.w	d1,d0
		bcs.s	locret_EDF0
		addq.b	#2,$24(a0)

locret_EDF0:
		rts	
; ===========================================================================

Obj4C_MakeLava:				; XREF: Obj4C_Index
		addq.b	#2,$24(a0)
		bsr.w	SingleObjLoad2
		bne.s	loc_EE18
		move.b	#$4D,0(a1)	; load lavafall	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$28(a0),$28(a1)
		move.l	a0,$3C(a1)

loc_EE18:
		move.b	#1,$1C(a0)
		tst.b	$28(a0)		; is object type 00 (geyser) ?
		beq.s	Obj4C_Type00	; if yes, branch
		move.b	#4,$1C(a0)
		bra.s	Obj4C_Display
; ===========================================================================

Obj4C_Type00:				; XREF: Obj4C_MakeLava
		movea.l	$3C(a0),a1	; load geyser object
		bset	#1,$22(a1)
		move.w	#-$580,$12(a1)
		bra.s	Obj4C_Display
; ===========================================================================

loc_EE3E:				; XREF: Obj4C_Index
		tst.b	$28(a0)		; is object type 00 (geyser) ?
		beq.s	Obj4C_Display	; if yes, branch
		addq.b	#2,$24(a0)
		rts	
; ===========================================================================

Obj4C_Display:				; XREF: Obj4C_Index
		lea	(Ani_obj4C).l,a1
		bsr.w	AnimateSprite
		bsr.w	DisplaySprite
		rts	
; ===========================================================================

Obj4C_Delete:				; XREF: Obj4C_Index
		move.b	#0,$1C(a0)
		move.b	#2,$24(a0)
		tst.b	$28(a0)
		beq.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4D - lava geyser / lavafall (MZ)
; ---------------------------------------------------------------------------

Obj4D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4D_Index(pc,d0.w),d1
		jsr	Obj4D_Index(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Obj4D_Index:	dc.w Obj4D_Main-Obj4D_Index
		dc.w Obj4D_Action-Obj4D_Index
		dc.w loc_EFFC-Obj4D_Index
		dc.w Obj4D_Delete-Obj4D_Index

Obj4D_Speeds:	dc.w $FB00, 0
; ===========================================================================

Obj4D_Main:				; XREF: Obj4D_Index
		addq.b	#2,$24(a0)
		move.w	$C(a0),$30(a0)
		tst.b	$28(a0)
		beq.s	loc_EEA4
		subi.w	#$250,$C(a0)

loc_EEA4:
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj4D_Speeds(pc,d0.w),$12(a0)
		movea.l	a0,a1
		moveq	#1,d1
		bsr.s	Obj4D_MakeLava
		bra.s	loc_EF10
; ===========================================================================

Obj4D_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_EF0A

Obj4D_MakeLava:				; XREF: Obj4D_Main
		move.b	#$4D,0(a1)
		move.l	#Map_obj4C,4(a1)
		move.w	#$63A8,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$28(a0),$28(a1)
		move.b	#1,$18(a1)
		move.b	#5,$1C(a1)
		tst.b	$28(a0)
		beq.s	loc_EF0A
		move.b	#2,$1C(a1)

loc_EF0A:
		dbf	d1,Obj4D_Loop
		rts	
; ===========================================================================

loc_EF10:				; XREF: Obj4D_Main
		addi.w	#$60,$C(a1)
		move.w	$30(a0),$30(a1)
		addi.w	#$60,$30(a1)
		move.b	#$93,$20(a1)
		move.b	#$80,$16(a1)
		bset	#4,1(a1)
		addq.b	#4,$24(a1)
		move.l	a0,$3C(a1)
		tst.b	$28(a0)
		beq.s	Obj4D_PlaySnd
		moveq	#0,d1
		bsr.w	Obj4D_Loop
		addq.b	#2,$24(a1)
		bset	#4,2(a1)
		addi.w	#$100,$C(a1)
		move.b	#0,$18(a1)
		move.w	$30(a0),$30(a1)
		move.l	$3C(a0),$3C(a1)
		move.b	#0,$28(a0)

Obj4D_PlaySnd:
		move.w	#SndID_Burn,d0
		jsr	(PlaySound_Special).l ;	play flame sound

Obj4D_Action:				; XREF: Obj4D_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj4D_TypeIndex(pc,d0.w),d1
		jsr	Obj4D_TypeIndex(pc,d1.w)
		bsr.w	ObjectMove
		lea	(Ani_obj4C).l,a1
		bsr.w	AnimateSprite

Obj4D_ChkDel:				; XREF: Obj4C
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
Obj4D_TypeIndex:dc.w Obj4D_Type00-Obj4D_TypeIndex
		dc.w Obj4D_Type01-Obj4D_TypeIndex
; ===========================================================================

Obj4D_Type00:				; XREF: Obj4D_TypeIndex
		addi.w	#$18,$12(a0)	; increase object's falling speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0
		bcc.s	locret_EFDA
		addq.b	#4,$24(a0)
		movea.l	$3C(a0),a1
		move.b	#3,$1C(a1)

locret_EFDA:
		rts	
; ===========================================================================

Obj4D_Type01:				; XREF: Obj4D_TypeIndex
		addi.w	#$18,$12(a0)	; increase object's falling speed
		move.w	$30(a0),d0
		cmp.w	$C(a0),d0
		bcc.s	locret_EFFA
		addq.b	#4,$24(a0)
		movea.l	$3C(a0),a1
		move.b	#1,$1C(a1)

locret_EFFA:
		rts	
; ===========================================================================

loc_EFFC:				; XREF: Obj4D_Index
		movea.l	$3C(a0),a1
		cmpi.b	#6,$24(a1)
		beq.w	Obj4D_Delete
		move.w	$C(a1),d0
		addi.w	#$60,d0
		move.w	d0,$C(a0)
		sub.w	$30(a0),d0
		neg.w	d0
		moveq	#8,d1
		cmpi.w	#$40,d0
		bge.s	loc_F026
		moveq	#$B,d1

loc_F026:
		cmpi.w	#$80,d0
		ble.s	loc_F02E
		moveq	#$E,d1

loc_F02E:
		subq.b	#1,$1E(a0)
		bpl.s	loc_F04C
		move.b	#7,$1E(a0)
		addq.b	#1,$1B(a0)
		cmpi.b	#2,$1B(a0)
		bcs.s	loc_F04C
		move.b	#0,$1B(a0)

loc_F04C:
		move.b	$1B(a0),d0
		add.b	d1,d0
		move.b	d0,$1A(a0)
		bra.w	Obj4D_ChkDel
; ===========================================================================

Obj4D_Delete:				; XREF: Obj4D_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4E - advancing	wall of	lava (MZ)
; ---------------------------------------------------------------------------

Obj4E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4E_Index(pc,d0.w),d1
		jmp	Obj4E_Index(pc,d1.w)
; ===========================================================================
Obj4E_Index:	dc.w Obj4E_Main-Obj4E_Index
		dc.w Obj4E_Solid-Obj4E_Index
		dc.w Obj4E_Action-Obj4E_Index
		dc.w Obj4E_Move2-Obj4E_Index
		dc.w Obj4E_Delete-Obj4E_Index
; ===========================================================================

Obj4E_Main:				; XREF: Obj4E_Index
		addq.b	#4,$24(a0)
		movea.l	a0,a1
		moveq	#1,d1
		bra.s	Obj4E_Main2
; ===========================================================================

Obj4E_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_F0C8

Obj4E_Main2:				; XREF: Obj4E_Main
		move.b	#$4E,0(a1)	; load object
		move.l	#Map_obj4E,4(a1)
		move.w	#$63A8,2(a1)
		move.b	#4,1(a1)
		move.b	#$50,$19(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#1,$18(a1)
		move.b	#0,$1C(a1)
		move.b	#$94,$20(a1)
		move.l	a0,$3C(a1)

loc_F0C8:
		dbf	d1,Obj4E_Loop	; repeat sequence once

		addq.b	#6,$24(a1)
		move.b	#4,$1A(a1)

Obj4E_Action:				; XREF: Obj4E_Index
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	Obj4E_ChkSonic
		neg.w	d0

Obj4E_ChkSonic:
		cmpi.w	#$C0,d0		; is Sonic within $C0 pixels (x-axis)?
		bcc.s	Obj4E_Move	; if not, branch
		move.w	(Object_Space_1+$C).w,d0
		sub.w	$C(a0),d0
		bcc.s	loc_F0F4
		neg.w	d0

loc_F0F4:
		cmpi.w	#$60,d0		; is Sonic within $60 pixels (y-axis)?
		bcc.s	Obj4E_Move	; if not, branch
		move.b	#1,$36(a0)	; set object to	move
		bra.s	Obj4E_Solid
; ===========================================================================

Obj4E_Move:				; XREF: Obj4E_ChkSonic
		tst.b	$36(a0)		; is object set	to move?
		beq.s	Obj4E_Solid	; if not, branch
		move.w	#$180,$10(a0)	; set object speed
		subq.b	#2,$24(a0)

Obj4E_Solid:				; XREF: Obj4E_Index
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		move.b	$24(a0),d0
		move.w	d0,-(sp)
		bsr.w	SolidObject
		move.w	(sp)+,d0
		move.b	d0,$24(a0)
		cmpi.w	#$6A0,8(a0)	; has object reached $6A0 on the x-axis?
		bne.s	Obj4E_Animate	; if not, branch
		clr.w	$10(a0)		; stop object moving
		clr.b	$36(a0)

Obj4E_Animate:
		lea	(Ani_obj4E).l,a1
		bsr.w	AnimateSprite
		cmpi.b	#4,(Object_Space_1+$24).w
		bcc.s	Obj4E_ChkDel
		bsr.w	ObjectMove

Obj4E_ChkDel:
		bsr.w	DisplaySprite
		tst.b	$36(a0)
		bne.s	locret_F17E
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj4E_ChkGone

locret_F17E:
		rts	
; ===========================================================================

Obj4E_ChkGone:				; XREF: Obj4E_ChkDel
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bclr	#7,2(a2,d0.w)
		move.b	#8,$24(a0)
		rts	
; ===========================================================================

Obj4E_Move2:				; XREF: Obj4E_Index
		movea.l	$3C(a0),a1
		cmpi.b	#8,$24(a1)
		beq.s	Obj4E_Delete
		move.w	8(a1),8(a0)	; move rest of lava wall
		subi.w	#$80,8(a0)
		bra.w	DisplaySprite
; ===========================================================================

Obj4E_Delete:				; XREF: Obj4E_Index
		bra.w	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 54 - invisible	lava tag (MZ)
; ---------------------------------------------------------------------------

Obj54:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj54_Index(pc,d0.w),d1
		jmp	Obj54_Index(pc,d1.w)
; ===========================================================================
Obj54_Index:	dc.w Obj54_Main-Obj54_Index
		dc.w Obj54_ChkDel-Obj54_Index

Obj54_Sizes:	dc.b $96, $94, $95, 0
; ===========================================================================

Obj54_Main:				; XREF: Obj54_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		move.b	Obj54_Sizes(pc,d0.w),$20(a0)
		move.l	#Map_obj54,4(a0)
		move.b	#$84,1(a0)

Obj54_ChkDel:				; XREF: Obj54_Index
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	DeleteObject
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - invisible lava tag (MZ)
; ---------------------------------------------------------------------------
Map_obj54:
	include "mappings/sprite/obj54.asm"

Ani_obj4C:
	include "objects/animation/obj4C.asm"

Ani_obj4E:
	include "objects/animation/obj4E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - lava geyser / lava that falls from the ceiling (MZ)
; ---------------------------------------------------------------------------
Map_obj4C:
	include "mappings/sprite/obj4C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - advancing wall of lava (MZ)
; ---------------------------------------------------------------------------
Map_obj4E:
	include "mappings/sprite/obj4E.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------

Obj40:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj40_Index(pc,d0.w),d1
		jmp	Obj40_Index(pc,d1.w)
; ===========================================================================
Obj40_Index:	dc.w Obj40_Main-Obj40_Index
		dc.w Obj40_Action-Obj40_Index
		dc.w Obj40_Animate-Obj40_Index
		dc.w Obj40_Delete-Obj40_Index
; ===========================================================================

Obj40_Main:				; XREF: Obj40_Index
		move.l	#Map_obj40,4(a0)
		move.w	#$4F0,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$14,$19(a0)
		tst.b	$1C(a0)		; is object a smoke trail?
		bne.s	Obj40_SetSmoke	; if yes, branch
		move.b	#$E,$16(a0)
		move.b	#8,$17(a0)
		move.b	#$C,$20(a0)
		bsr.w	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_F68A
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)
		bchg	#0,$22(a0)

locret_F68A:
		rts	
; ===========================================================================

Obj40_SetSmoke:				; XREF: Obj40_Main
		addq.b	#4,$24(a0)
		bra.w	Obj40_Animate
; ===========================================================================

Obj40_Action:				; XREF: Obj40_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj40_Index2(pc,d0.w),d1
		jsr	Obj40_Index2(pc,d1.w)
		lea	(Ani_obj40).l,a1
		bsr.w	AnimateSprite

; ---------------------------------------------------------------------------
; Routine to mark an enemy/monitor/ring	as destroyed
; ---------------------------------------------------------------------------

MarkObjGone:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Mark_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Mark_ChkGone:
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Mark_Delete
		bclr	#7,2(a2,d0.w)

Mark_Delete:
		bra.w	DeleteObject

; ===========================================================================
Obj40_Index2:	dc.w Obj40_Move-Obj40_Index2
		dc.w Obj40_FixToFloor-Obj40_Index2
; ===========================================================================

Obj40_Move:				; XREF: Obj40_Index2
		subq.w	#1,$30(a0)	; subtract 1 from pause	time
		bpl.s	locret_F70A	; if time remains, branch
		addq.b	#2,$25(a0)
		move.w	#-$100,$10(a0)	; move object to the left
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)
		bne.s	locret_F70A
		neg.w	$10(a0)		; change direction

locret_F70A:
		rts	
; ===========================================================================

Obj40_FixToFloor:			; XREF: Obj40_Index2
		bsr.w	ObjectMove
		jsr	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	Obj40_Pause
		cmpi.w	#$C,d1
		bge.s	Obj40_Pause
		add.w	d1,$C(a0)	; match	object's position with the floor
		subq.b	#1,$33(a0)
		bpl.s	locret_F756
		move.b	#$F,$33(a0)
		bsr.w	SingleObjLoad
		bne.s	locret_F756
		move.b	#$40,0(a1)	; load exhaust smoke object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.b	#2,$1C(a1)

locret_F756:
		rts	
; ===========================================================================

Obj40_Pause:				; XREF: Obj40_FixToFloor
		subq.b	#2,$25(a0)
		move.w	#59,$30(a0)	; set pause time to 1 second
		move.w	#0,$10(a0)	; stop the object moving
		move.b	#0,$1C(a0)
		rts	
; ===========================================================================

Obj40_Animate:				; XREF: Obj40_Index
		lea	(Ani_obj40).l,a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite
; ===========================================================================

Obj40_Delete:				; XREF: Obj40_Index
		bra.w	DeleteObject
; ===========================================================================
Ani_obj40:
	include "objects/animation/obj40.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Moto Bug enemy (GHZ)
; ---------------------------------------------------------------------------
Map_obj40:
	include "mappings/sprite/obj40.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4F - blank
; ---------------------------------------------------------------------------

Obj4F:					; XREF: Obj_Index
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj50_ChkWall:				; XREF: Obj50_FixToFloor
		move.w	(Level_Timer).w,d0
		add.w	d7,d0
		andi.w	#3,d0
		bne.s	loc_F836
		moveq	#0,d3
		move.b	$19(a0),d3
		tst.w	$10(a0)
		bmi.s	loc_F82C
		bsr.w	ObjHitWallRight
		tst.w	d1
		bpl.s	loc_F836

loc_F828:
		moveq	#1,d0
		rts	
; ===========================================================================

loc_F82C:
		not.w	d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.s	loc_F828

loc_F836:
		moveq	#0,d0
		rts	
; End of function Obj50_ChkWall

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 50 - Yadrin enemy (SYZ)
; ---------------------------------------------------------------------------

Obj50:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj50_Index(pc,d0.w),d1
		jmp	Obj50_Index(pc,d1.w)
; ===========================================================================
Obj50_Index:	dc.w Obj50_Main-Obj50_Index
		dc.w Obj50_Action-Obj50_Index
; ===========================================================================

Obj50_Main:				; XREF: Obj50_Index
		move.l	#Map_obj50,4(a0)
		move.w	#$247B,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$14,$19(a0)
		move.b	#$11,$16(a0)
		move.b	#8,$17(a0)
		move.b	#$CC,$20(a0)
		bsr.w	ObjectMoveAndFall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_F89E
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		addq.b	#2,$24(a0)
		bchg	#0,$22(a0)

locret_F89E:
		rts	
; ===========================================================================

Obj50_Action:				; XREF: Obj50_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj50_Index2(pc,d0.w),d1
		jsr	Obj50_Index2(pc,d1.w)
		lea	(Ani_obj50).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj50_Index2:	dc.w Obj50_Move-Obj50_Index2
		dc.w Obj50_FixToFloor-Obj50_Index2
; ===========================================================================

Obj50_Move:				; XREF: Obj50_Index2
		subq.w	#1,$30(a0)	; subtract 1 from pause	time
		bpl.s	locret_F8E2	; if time remains, branch
		addq.b	#2,$25(a0)
		move.w	#-$100,$10(a0)	; move object
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)
		bne.s	locret_F8E2
		neg.w	$10(a0)		; change direction

locret_F8E2:
		rts	
; ===========================================================================

Obj50_FixToFloor:			; XREF: Obj50_Index2
		bsr.w	ObjectMove
		bsr.w	ObjHitFloor
		cmpi.w	#-8,d1
		blt.s	Obj50_Pause
		cmpi.w	#$C,d1
		bge.s	Obj50_Pause
		add.w	d1,$C(a0)	; match	object's position to the floor
		bsr.w	Obj50_ChkWall
		bne.s	Obj50_Pause
		rts	
; ===========================================================================

Obj50_Pause:				; XREF: Obj50_FixToFloor
		subq.b	#2,$25(a0)
		move.w	#59,$30(a0)	; set pause time to 1 second
		move.w	#0,$10(a0)
		move.b	#0,$1C(a0)
		rts	
; ===========================================================================
Ani_obj50:
	include "objects/animation/obj50.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Yadrin enemy (SYZ)
; ---------------------------------------------------------------------------
Map_obj50:
	include "mappings/sprite/obj50.asm"

; ---------------------------------------------------------------------------
; Solid	object subroutine (includes spikes, blocks, rocks etc)
;
; variables:
; d1 = width
; d2 = height /	2 (when	jumping)
; d3 = height /	2 (when	walking)
; d4 = x-axis position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SolidObject:
		tst.b	$25(a0)
		beq.w	loc_FAC8
		move.w	d1,d2
		add.w	d2,d2
		lea	(Object_RAM).w,a1
		btst	#1,$22(a1)
		bne.s	loc_F9FE
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_F9FE
		cmp.w	d2,d0
		bcs.s	loc_FA12

loc_F9FE:
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		moveq	#0,d4
		rts	
; ===========================================================================

loc_FA12:
		move.w	d4,d2
		jsr	MvSonicOnPtfm
		moveq	#0,d4
		rts	
; ===========================================================================

SolidObject71:				; XREF: Obj71_Solid
		tst.b	$25(a0)
		beq.w	loc_FAD0
		move.w	d1,d2
		add.w	d2,d2
		lea	(Object_RAM).w,a1
		btst	#1,$22(a1)
		bne.s	loc_FA44
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_FA44
		cmp.w	d2,d0
		bcs.s	loc_FA58

loc_FA44:
		bclr	#3,$22(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		moveq	#0,d4
		rts	
; ===========================================================================

loc_FA58:
		move.w	d4,d2
		jsr	MvSonicOnPtfm
		moveq	#0,d4
		rts	
; ===========================================================================

SolidObject2F:				; XREF: Obj2F_Solid
		lea	(Object_RAM).w,a1
		tst.b	1(a0)
		bpl.w	loc_FB92
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	loc_FB92
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	loc_FB92
		move.w	d0,d5
		btst	#0,1(a0)
		beq.s	loc_FA94
		not.w	d5
		add.w	d3,d5

loc_FA94:
		lsr.w	#1,d5
		moveq	#0,d3
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		move.w	$C(a0),d5
		sub.w	d3,d5
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	loc_FB92
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.w	loc_FB92
		bra.w	loc_FB0E
; ===========================================================================

loc_FAC8:
		tst.b	1(a0)
		bpl.w	loc_FB92

loc_FAD0:
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.w	loc_FB92
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	loc_FB92
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	loc_FB92
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc.w	loc_FB92

loc_FB0E:
		tst.b	(No_Player_Physics_Flag).w
		bmi.w	loc_FB92
		cmpi.b	#6,(Object_Space_1+$24).w
		bcc.w	loc_FB92
		tst.w	(Debug_Placement_Mode).w
		bne.w	loc_FBAC
		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_FB36
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

loc_FB36:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_FB44
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

loc_FB44:
		cmp.w	d1,d5
		bhi.w	loc_FBB0
		cmpi.w	#4,d1
		bls.s	loc_FB8C
		tst.w	d0
		beq.s	loc_FB70
		bmi.s	loc_FB5E
		tst.w	$10(a1)
		bmi.s	loc_FB70
		bra.s	loc_FB64
; ===========================================================================

loc_FB5E:
		tst.w	$10(a1)
		bpl.s	loc_FB70

loc_FB64:
		move.w	#0,$14(a1)	; stop Sonic moving
		move.w	#0,$10(a1)

loc_FB70:
		sub.w	d0,8(a1)
		btst	#1,$22(a1)
		bne.s	loc_FB8C
		bset	#5,$22(a1)
		bset	#5,$22(a0)
		moveq	#1,d4
		rts	
; ===========================================================================

loc_FB8C:
		bsr.s	loc_FBA0
		moveq	#1,d4
		rts	
; ===========================================================================

loc_FB92:
		btst	#5,$22(a0)
		beq.s	loc_FBAC
		cmp.b	#2,$1C(a1)	; check if in jumping/rolling animation
		beq.s	loc_FBA0
		cmp.b	#$17,$1C(a1)	; check if in drowning animation
		beq.s	loc_FBA0
		cmp.b	#$1A,$1C(a1)	; check if in hurt animation
		beq.s	loc_FBA0
		move.w	#1,$1C(a1)	; use walking animation

loc_FBA0:
		bclr	#5,$22(a0)
		bclr	#5,$22(a1)

loc_FBAC:
		moveq	#0,d4
		rts	
; ===========================================================================

loc_FBB0:
		tst.w	d3
		bmi.s	loc_FBBC
		cmpi.w	#$10,d3
		bcs.s	loc_FBEE
		bra.s	loc_FB92
; ===========================================================================

loc_FBBC:
		tst.w	$12(a1)
		beq.s	loc_FBD6
		bpl.s	loc_FBD2
		tst.w	d3
		bpl.s	loc_FBD2
		sub.w	d3,$C(a1)
		move.w	#0,$12(a1)	; stop Sonic moving

loc_FBD2:
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_FBD6:
		btst	#1,$22(a1)
		bne.s	loc_FBD2
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	KillSonic
		movea.l	(sp)+,a0
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_FBEE:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	$19(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	8(a1),d1
		sub.w	8(a0),d1
		bmi.s	loc_FC28
		cmp.w	d2,d1
		bcc.s	loc_FC28
		tst.w	$12(a1)
		bmi.s	loc_FC28
		sub.w	d3,$C(a1)
		subq.w	#1,$C(a1)
		bsr.s	sub_FC2C
		move.b	#2,$25(a0)
		bset	#3,$22(a0)
		moveq	#-1,d4
		rts	
; ===========================================================================

loc_FC28:
		moveq	#0,d4
		rts	
; End of function SolidObject


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_FC2C:				; XREF: SolidObject
		btst	#3,$22(a1)
		beq.s	loc_FC4E
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a2
		bclr	#3,$22(a2)
		clr.b	$25(a2)

loc_FC4E:
		move.w	a0,d0
		subi.w	#Object_RAM,d0
		lsr.w	#6,d0
		andi.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,$26(a1)
		move.w	#0,$12(a1)
		move.w	$10(a1),$14(a1)
		btst	#1,$22(a1)
		beq.s	loc_FC84
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	Sonic_ResetOnFloor
		movea.l	(sp)+,a0

loc_FC84:
		bset	#3,$22(a1)
		bset	#3,$22(a0)
		rts	
; End of function sub_FC2C

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 51 - smashable	green block (MZ)
; ---------------------------------------------------------------------------

Obj51:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj51_Index(pc,d0.w),d1
		jsr	Obj51_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj51_Index:	dc.w Obj51_Main-Obj51_Index
		dc.w Obj51_Solid-Obj51_Index
		dc.w Obj51_Display-Obj51_Index
; ===========================================================================

Obj51_Main:				; XREF: Obj51_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj51,4(a0)
		move.w	#$42B8,2(a0)
		move.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),$1A(a0)

Obj51_Solid:				; XREF: Obj51_Index
		move.w	(Chain_Bonus_Counter).w,$34(a0)
		move.b	(Object_Space_1+$1C).w,$32(a0) ;	load Sonic's animation number
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		btst	#3,$22(a0)
		bne.s	Obj51_Smash

locret_FCFC:
		rts	
; ===========================================================================

Obj51_Smash:				; XREF: Obj51_Solid
	;	cmpi.b	#2,$32(a0)	; is Sonic rolling/jumping?
	;	bne.s	locret_FCFC	; if not, branch
		move.w	$34(a0),(Chain_Bonus_Counter).w
		bset	#2,$22(a1)
		move.b	#$E,$16(a1)
		move.b	#7,$17(a1)
		move.b	#2,$1C(a1)
		move.w	#-$300,$12(a1)	; bounce Sonic upwards
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)
		bclr	#3,$22(a0)
		clr.b	$25(a0)
		move.b	#1,$1A(a0)
		lea	(Obj51_Speeds).l,a4 ; load broken	fragment speed data
		moveq	#3,d1		; set number of	fragments to 4
		move.w	#$38,d2
		bsr.w	SmashObject
		bsr.w	SingleObjLoad
		bne.s	Obj51_Display
		move.b	#$29,0(a1)	; load points object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	(Chain_Bonus_Counter).w,d2
		addq.w	#2,(Chain_Bonus_Counter).w
		cmpi.w	#6,d2
		bcs.s	Obj51_Bonus
		moveq	#6,d2

Obj51_Bonus:
		moveq	#0,d0
		move.w	Obj51_Points(pc,d2.w),d0
		cmpi.w	#$20,(Chain_Bonus_Counter).w ; have 16 blocks been smashed?
		bcs.s	loc_FD98	; if not, branch
		move.w	#1000,d0	; give higher points for 16th block
		moveq	#10,d2

loc_FD98:
		jsr	AddPoints
		lsr.w	#1,d2
		move.b	d2,$1A(a1)

Obj51_Display:				; XREF: Obj51_Index
		bsr.w	ObjectMove
		addi.w	#$38,$12(a0)
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts	
; ===========================================================================
Obj51_Speeds:	dc.w $FE00, $FE00	; x-speed, y-speed
		dc.w $FF00, $FF00
		dc.w $200, $FE00
		dc.w $100, $FF00

Obj51_Points:	dc.w 10, 20, 50, 100
; ---------------------------------------------------------------------------
; Sprite mappings - smashable green block (MZ)
; ---------------------------------------------------------------------------
Map_obj51:
	include "mappings/sprite/obj51.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 52 - moving platform blocks (MZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Obj52:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj52_Index(pc,d0.w),d1
		jmp	Obj52_Index(pc,d1.w)
; ===========================================================================
Obj52_Index:	dc.w Obj52_Main-Obj52_Index
		dc.w Obj52_Platform-Obj52_Index
		dc.w Obj52_StandOn-Obj52_Index

Obj52_Var:	dc.b $10, 0		; object width,	frame number
		dc.b $20, 1
		dc.b $20, 2
		dc.b $40, 3
		dc.b $30, 4
; ===========================================================================

Obj52_Main:				; XREF: Obj52_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj52,4(a0)
		move.w	#$42B8,2(a0)
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		bne.s	loc_FE44
		move.l	#Map_obj52a,4(a0) ; LZ specific	code
		move.w	#$43BC,2(a0)
		move.b	#7,$16(a0)

loc_FE44:
		move.b	#4,1(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj52_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		move.b	#4,$18(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$32(a0)
		andi.b	#$F,$28(a0)

Obj52_Platform:				; XREF: Obj52_Index
		bsr.w	Obj52_Move
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.s	Obj52_ChkDel
; ===========================================================================

Obj52_StandOn:				; XREF: Obj52_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	Obj52_Move
		move.w	(sp)+,d2
		jsr	(MvSonicOnPtfm2).l

Obj52_ChkDel:				; XREF: Obj52_Platform
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Obj52_Move:				; XREF: Obj52_Platform; Obj52_StandOn
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj52_TypeIndex(pc,d0.w),d1
		jmp	Obj52_TypeIndex(pc,d1.w)
; ===========================================================================
Obj52_TypeIndex:dc.w Obj52_Type00-Obj52_TypeIndex, Obj52_Type01-Obj52_TypeIndex
		dc.w Obj52_Type02-Obj52_TypeIndex, Obj52_Type03-Obj52_TypeIndex
		dc.w Obj52_Type02-Obj52_TypeIndex, Obj52_Type05-Obj52_TypeIndex
		dc.w Obj52_Type06-Obj52_TypeIndex, Obj52_Type07-Obj52_TypeIndex
		dc.w Obj52_Type08-Obj52_TypeIndex, Obj52_Type02-Obj52_TypeIndex
		dc.w Obj52_Type0A-Obj52_TypeIndex
; ===========================================================================

Obj52_Type00:				; XREF: Obj52_TypeIndex
		rts	
; ===========================================================================

Obj52_Type01:				; XREF: Obj52_TypeIndex
		move.b	(Oscillation_Data+$C).w,d0
		move.w	#$60,d1
		btst	#0,$22(a0)
		beq.s	loc_FF26
		neg.w	d0
		add.w	d1,d0

loc_FF26:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)
		rts	
; ===========================================================================

Obj52_Type02:				; XREF: Obj52_TypeIndex
		cmpi.b	#4,$24(a0)	; is Sonic standing on the platform?
		bne.s	Obj52_02_Wait
		addq.b	#1,$28(a0)	; if yes, add 1	to type

Obj52_02_Wait:
		rts	
; ===========================================================================

Obj52_Type03:				; XREF: Obj52_TypeIndex
		moveq	#0,d3
		move.b	$19(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1		; has the platform hit a wall?
		bmi.s	Obj52_03_End	; if yes, branch
		addq.w	#1,8(a0)	; move platform	to the right
		move.w	8(a0),$30(a0)
		rts	
; ===========================================================================

Obj52_03_End:
		clr.b	$28(a0)		; change to type 00 (non-moving	type)
		rts	
; ===========================================================================

Obj52_Type05:				; XREF: Obj52_TypeIndex
		moveq	#0,d3
		move.b	$19(a0),d3
		bsr.w	ObjHitWallRight
		tst.w	d1		; has the platform hit a wall?
		bmi.s	Obj52_05_End	; if yes, branch
		addq.w	#1,8(a0)	; move platform	to the right
		move.w	8(a0),$30(a0)
		rts	
; ===========================================================================

Obj52_05_End:
		addq.b	#1,$28(a0)	; change to type 06 (falling)
		rts	
; ===========================================================================

Obj52_Type06:				; XREF: Obj52_TypeIndex
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)	; make the platform fall
		bsr.w	ObjHitFloor
		tst.w	d1		; has platform hit the floor?
		bpl.w	locret_FFA0	; if not, branch
		add.w	d1,$C(a0)
		clr.w	$12(a0)		; stop platform	falling
		clr.b	$28(a0)		; change to type 00 (non-moving)

locret_FFA0:
		rts	
; ===========================================================================

Obj52_Type07:				; XREF: Obj52_TypeIndex
		tst.b	(Switch_Statuses+2).w	; has switch number 02 been pressed?
		beq.s	Obj52_07_ChkDel
		subq.b	#3,$28(a0)	; if yes, change object	type to	04

Obj52_07_ChkDel:
		addq.l	#4,sp
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================

Obj52_Type08:				; XREF: Obj52_TypeIndex
		move.b	(Oscillation_Data+$1C).w,d0
		move.w	#$80,d1
		btst	#0,$22(a0)
		beq.s	loc_FFE2
		neg.w	d0
		add.w	d1,d0

loc_FFE2:
		move.w	$32(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)
		rts	
; ===========================================================================

Obj52_Type0A:				; XREF: Obj52_TypeIndex
		moveq	#0,d3
		move.b	$19(a0),d3
		add.w	d3,d3
		moveq	#8,d1
		btst	#0,$22(a0)
		beq.s	loc_10004
		neg.w	d1
		neg.w	d3

loc_10004:
		tst.w	$36(a0)		; is platform set to move back?
		bne.s	Obj52_0A_Back	; if yes, branch
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		cmp.w	d3,d0
		beq.s	Obj52_0A_Wait
		add.w	d1,8(a0)	; move platform
		move.w	#300,$34(a0)	; set time delay to 5 seconds
		rts	
; ===========================================================================

Obj52_0A_Wait:
		subq.w	#1,$34(a0)	; subtract 1 from time delay
		bne.s	locret_1002E	; if time remains, branch
		move.w	#1,$36(a0)	; set platform to move back to its original position

locret_1002E:
		rts	
; ===========================================================================

Obj52_0A_Back:
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		beq.s	Obj52_0A_Reset
		sub.w	d1,8(a0)	; return platform to its original position
		rts	
; ===========================================================================

Obj52_0A_Reset:
		clr.w	$36(a0)
		subq.b	#1,$28(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - moving blocks (MZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj52:
	include "mappings/sprite/obj52mz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - moving block (LZ)
; ---------------------------------------------------------------------------
Map_obj52a:
	include "mappings/sprite/obj52lz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 55 - Basaran enemy (MZ)
; ---------------------------------------------------------------------------

Obj55:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj55_Index(pc,d0.w),d1
		jmp	Obj55_Index(pc,d1.w)
; ===========================================================================
Obj55_Index:	dc.w Obj55_Main-Obj55_Index
		dc.w Obj55_Action-Obj55_Index
; ===========================================================================

Obj55_Main:				; XREF: Obj55_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj55,4(a0)
		move.w	#$84B8,2(a0)
		move.b	#4,1(a0)
		move.b	#$C,$16(a0)
		move.b	#2,$18(a0)
		move.b	#$B,$20(a0)
		move.b	#$10,$19(a0)

Obj55_Action:				; XREF: Obj55_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj55_Index2(pc,d0.w),d1
		jsr	Obj55_Index2(pc,d1.w)
		lea	(Ani_obj55).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj55_Index2:	dc.w Obj55_ChkDrop-Obj55_Index2
		dc.w Obj55_DropFly-Obj55_Index2
		dc.w Obj55_PlaySnd-Obj55_Index2
		dc.w Obj55_FlyUp-Obj55_Index2
; ===========================================================================

Obj55_ChkDrop:				; XREF: Obj55_Index2
		move.w	#$80,d2
		bsr.w	Obj55_ChkSonic
		bcc.s	Obj55_NoDrop
		move.w	(Object_Space_1+$C).w,d0
		move.w	d0,$36(a0)
		sub.w	$C(a0),d0
		bcs.s	Obj55_NoDrop
		cmpi.w	#$80,d0		; is Sonic within $80 pixels of	basaran?
		bcc.s	Obj55_NoDrop	; if not, branch
		tst.w	(Debug_Placement_Mode).w	; is debug mode	on?
		bne.s	Obj55_NoDrop	; if yes, branch
		move.b	(V_Int_Counter+3).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	Obj55_NoDrop
		move.b	#1,$1C(a0)
		addq.b	#2,$25(a0)

Obj55_NoDrop:
		rts	
; ===========================================================================

Obj55_DropFly:				; XREF: Obj55_Index2
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)	; make basaran fall
		move.w	#$80,d2
		bsr.w	Obj55_ChkSonic
		move.w	$36(a0),d0
		sub.w	$C(a0),d0
		bcs.s	Obj55_ChkDel
		cmpi.w	#$10,d0
		bcc.s	locret_10180
		move.w	d1,$10(a0)	; make basaran fly horizontally
		move.w	#0,$12(a0)	; stop basaran falling
		move.b	#2,$1C(a0)
		addq.b	#2,$25(a0)

locret_10180:
		rts	
; ===========================================================================

Obj55_ChkDel:				; XREF: Obj55_DropFly
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts	
; ===========================================================================

Obj55_PlaySnd:				; XREF: Obj55_Index2
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#$F,d0
		bne.s	loc_101A0
		move.w	#SndID_BasaranFlap,d0
		jsr	(PlaySound_Special).l ;	play flapping sound

loc_101A0:
		bsr.w	ObjectMove
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_101B0
		neg.w	d0

loc_101B0:
		cmpi.w	#$80,d0
		bcs.s	locret_101C6
		move.b	(V_Int_Counter+3).w,d0
		add.b	d7,d0
		andi.b	#7,d0
		bne.s	locret_101C6
		addq.b	#2,$25(a0)

locret_101C6:
		rts	
; ===========================================================================

Obj55_FlyUp:				; XREF: Obj55_Index2
		bsr.w	ObjectMove
		subi.w	#$18,$12(a0)	; make basaran fly upwards
		bsr.w	ObjHitCeiling
		tst.w	d1		; has basaran hit the ceiling?
		bpl.s	locret_101F4	; if not, branch
		sub.w	d1,$C(a0)
		andi.w	#$FFF8,8(a0)
		clr.w	$10(a0)		; stop basaran moving
		clr.w	$12(a0)
		clr.b	$1C(a0)
		clr.b	$25(a0)

locret_101F4:
		rts	
; ===========================================================================

Obj55_ChkSonic:				; XREF: Obj55_ChkDrop
		move.w	#$100,d1
		bset	#0,$22(a0)
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_10214
		neg.w	d0
		neg.w	d1
		bclr	#0,$22(a0)

loc_10214:
		cmp.w	d2,d0
		rts	
; ===========================================================================
		bsr.w	ObjectMove
		bsr.w	DisplaySprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		rts	
; ===========================================================================
Ani_obj55:
	include "objects/animation/obj55.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Basaran enemy (MZ)
; ---------------------------------------------------------------------------
Map_obj55:
	include "mappings/sprite/obj55.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 56 - moving blocks (SYZ/SLZ), large doors (LZ)
; ---------------------------------------------------------------------------

Obj56:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj56_Index(pc,d0.w),d1
		jmp	Obj56_Index(pc,d1.w)
; ===========================================================================
Obj56_Index:	dc.w Obj56_Main-Obj56_Index
		dc.w Obj56_Action-Obj56_Index

Obj56_Var:	dc.b  $10, $10		; width, height
		dc.b  $20, $20
		dc.b  $10, $20
		dc.b  $20, $1A
		dc.b  $10, $27
		dc.b  $10, $10
		dc.b	8, $20
		dc.b  $40, $10
; ===========================================================================

Obj56_Main:				; XREF: Obj56_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj56,4(a0)
		move.w	#$4000,2(a0)
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		bne.s	loc_102C8
		move.w	#$43C4,2(a0)	; LZ specific code

loc_102C8:
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		lea	Obj56_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2),$16(a0)
		lsr.w	#1,d0
		move.b	d0,$1A(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$30(a0)
		moveq	#0,d0
		move.b	(a2),d0
		add.w	d0,d0
		move.w	d0,$3A(a0)
		moveq	#0,d0
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		beq.s	loc_10332
		move.b	$28(a0),d0	; SYZ/SLZ specific code
		andi.w	#$F,d0
		subq.w	#8,d0
		bcs.s	loc_10332
		lsl.w	#2,d0
		lea	(Oscillation_Data+$2A).w,a2
		lea	(a2,d0.w),a2
		tst.w	(a2)
		bpl.s	loc_10332
		bchg	#0,$22(a0)

loc_10332:
		move.b	$28(a0),d0
		bpl.s	Obj56_Action
		andi.b	#$F,d0
		move.b	d0,$3C(a0)
		move.b	#5,$28(a0)
		cmpi.b	#7,$1A(a0)
		bne.s	Obj56_ChkGone
		move.b	#$C,$28(a0)
		move.w	#$80,$3A(a0)

Obj56_ChkGone:
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	Obj56_Action
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		beq.s	Obj56_Action
		addq.b	#1,$28(a0)
		clr.w	$3A(a0)

Obj56_Action:				; XREF: Obj56_Index
		move.w	8(a0),-(sp)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		add.w	d0,d0
		move.w	Obj56_TypeIndex(pc,d0.w),d1
		jsr	Obj56_TypeIndex(pc,d1.w)
		move.w	(sp)+,d4
		tst.b	1(a0)
		bpl.s	Obj56_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject

Obj56_ChkDel:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj56_TypeIndex:dc.w Obj56_Type00-Obj56_TypeIndex, Obj56_Type01-Obj56_TypeIndex
		dc.w Obj56_Type02-Obj56_TypeIndex, Obj56_Type03-Obj56_TypeIndex
		dc.w Obj56_Type04-Obj56_TypeIndex, Obj56_Type05-Obj56_TypeIndex
		dc.w Obj56_Type06-Obj56_TypeIndex, Obj56_Type07-Obj56_TypeIndex
		dc.w Obj56_Type08-Obj56_TypeIndex, Obj56_Type09-Obj56_TypeIndex
		dc.w Obj56_Type0A-Obj56_TypeIndex, Obj56_Type0B-Obj56_TypeIndex
		dc.w Obj56_Type0C-Obj56_TypeIndex, Obj56_Type0D-Obj56_TypeIndex
; ===========================================================================

Obj56_Type00:				; XREF: Obj56_TypeIndex
		rts	
; ===========================================================================

Obj56_Type01:				; XREF: Obj56_TypeIndex
		move.w	#$40,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$8).w,d0
		bra.s	Obj56_Move_LR
; ===========================================================================

Obj56_Type02:				; XREF: Obj56_TypeIndex
		move.w	#$80,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$1C).w,d0

Obj56_Move_LR:
		btst	#0,$22(a0)
		beq.s	loc_10416
		neg.w	d0
		add.w	d1,d0

loc_10416:
		move.w	$34(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)	; move object horizontally
		rts	
; ===========================================================================

Obj56_Type03:				; XREF: Obj56_TypeIndex
		move.w	#$40,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$8).w,d0
		bra.s	Obj56_Move_UD
; ===========================================================================

Obj56_Type04:				; XREF: Obj56_TypeIndex
		move.w	#$80,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$1C).w,d0

Obj56_Move_UD:
		btst	#0,$22(a0)
		beq.s	loc_10444
		neg.w	d0
		add.w	d1,d0

loc_10444:
		move.w	$30(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; move object vertically
		rts	
; ===========================================================================

Obj56_Type05:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_104A4
		cmpi.w	#$100,(Current_Zone_And_Act).w ; is level LZ1 ?
		bne.s	loc_1047A	; if not, branch
		cmpi.b	#3,$3C(a0)
		bne.s	loc_1047A
		clr.b	(Wind_Tunnel_Flag).w
		move.w	(Object_Space_1+8).w,d0
		cmp.w	8(a0),d0
		bcc.s	loc_1047A
		move.b	#1,(Wind_Tunnel_Flag).w

loc_1047A:
		lea	(Switch_Statuses).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	loc_104AE
		cmpi.w	#$100,(Current_Zone_And_Act).w ; is level LZ1 ?
		bne.s	loc_1049E	; if not, branch
		cmpi.b	#3,d0
		bne.s	loc_1049E
		clr.b	(Wind_Tunnel_Flag).w

loc_1049E:
		move.b	#1,$38(a0)

loc_104A4:
		tst.w	$3A(a0)
		beq.s	loc_104C8
		subq.w	#2,$3A(a0)

loc_104AE:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_104BC
		neg.w	d0

loc_104BC:
		move.w	$30(a0),d1
		add.w	d0,d1
		move.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_104C8:
		addq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_104AE
		bset	#0,2(a2,d0.w)
		bra.s	loc_104AE
; ===========================================================================

Obj56_Type06:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_10500
		lea	(Switch_Statuses).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		tst.b	(a2,d0.w)
		bpl.s	loc_10512
		move.b	#1,$38(a0)

loc_10500:
		moveq	#0,d0
		move.b	$16(a0),d0
		add.w	d0,d0
		cmp.w	$3A(a0),d0
		beq.s	loc_1052C
		addq.w	#2,$3A(a0)

loc_10512:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_10520
		neg.w	d0

loc_10520:
		move.w	$30(a0),d1
		add.w	d0,d1
		move.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_1052C:
		subq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_10512
		bclr	#0,2(a2,d0.w)
		bra.s	loc_10512
; ===========================================================================

Obj56_Type07:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_1055E
		tst.b	(Switch_Statuses+$F).w	; has switch number $F been pressed?
		beq.s	locret_10578
		move.b	#1,$38(a0)
		clr.w	$3A(a0)

loc_1055E:
		addq.w	#1,8(a0)
		move.w	8(a0),$34(a0)
		addq.w	#1,$3A(a0)
		cmpi.w	#$380,$3A(a0)
		bne.s	locret_10578
		clr.b	$28(a0)

locret_10578:
		rts	
; ===========================================================================

Obj56_Type0C:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_10598
		lea	(Switch_Statuses).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		btst	#0,(a2,d0.w)
		beq.s	loc_105A2
		move.b	#1,$38(a0)

loc_10598:
		tst.w	$3A(a0)
		beq.s	loc_105C0
		subq.w	#2,$3A(a0)

loc_105A2:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_105B4
		neg.w	d0
		addi.w	#$80,d0

loc_105B4:
		move.w	$34(a0),d1
		add.w	d0,d1
		move.w	d1,8(a0)
		rts	
; ===========================================================================

loc_105C0:
		addq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_105A2
		bset	#0,2(a2,d0.w)
		bra.s	loc_105A2
; ===========================================================================

Obj56_Type0D:				; XREF: Obj56_TypeIndex
		tst.b	$38(a0)
		bne.s	loc_105F8
		lea	(Switch_Statuses).w,a2
		moveq	#0,d0
		move.b	$3C(a0),d0
		tst.b	(a2,d0.w)
		bpl.s	loc_10606
		move.b	#1,$38(a0)

loc_105F8:
		move.w	#$80,d0
		cmp.w	$3A(a0),d0
		beq.s	loc_10624
		addq.w	#2,$3A(a0)

loc_10606:
		move.w	$3A(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_10618
		neg.w	d0
		addi.w	#$80,d0

loc_10618:
		move.w	$34(a0),d1
		add.w	d0,d1
		move.w	d1,8(a0)
		rts	
; ===========================================================================

loc_10624:
		subq.b	#1,$28(a0)
		clr.b	$38(a0)
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_10606
		bclr	#0,2(a2,d0.w)
		bra.s	loc_10606
; ===========================================================================

Obj56_Type08:				; XREF: Obj56_TypeIndex
		move.w	#$10,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$28).w,d0
		lsr.w	#1,d0
		move.w	(Oscillation_Data+$2A).w,d3
		bra.s	Obj56_Move_Sqr
; ===========================================================================

Obj56_Type09:				; XREF: Obj56_TypeIndex
		move.w	#$30,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$2C).w,d0
		move.w	(Oscillation_Data+$2E).w,d3
		bra.s	Obj56_Move_Sqr
; ===========================================================================

Obj56_Type0A:				; XREF: Obj56_TypeIndex
		move.w	#$50,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$30).w,d0
		move.w	(Oscillation_Data+$32).w,d3
		bra.s	Obj56_Move_Sqr
; ===========================================================================

Obj56_Type0B:				; XREF: Obj56_TypeIndex
		move.w	#$70,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$34).w,d0
		move.w	(Oscillation_Data+$36).w,d3

Obj56_Move_Sqr:
		tst.w	d3
		bne.s	loc_1068E
		addq.b	#1,$22(a0)
		andi.b	#3,$22(a0)

loc_1068E:
		move.b	$22(a0),d2
		andi.b	#3,d2
		bne.s	loc_106AE
		sub.w	d1,d0
		add.w	$34(a0),d0
		move.w	d0,8(a0)
		neg.w	d1
		add.w	$30(a0),d1
		move.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_106AE:
		subq.b	#1,d2
		bne.s	loc_106CC
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		addq.w	#1,d1
		add.w	$34(a0),d1
		move.w	d1,8(a0)
		rts	
; ===========================================================================

loc_106CC:
		subq.b	#1,d2
		bne.s	loc_106EA
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	$34(a0),d0
		move.w	d0,8(a0)
		addq.w	#1,d1
		add.w	$30(a0),d1
		move.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_106EA:
		sub.w	d1,d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		neg.w	d1
		add.w	$34(a0),d1
		move.w	d1,8(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - moving blocks (SYZ/SLZ/LZ)
; ---------------------------------------------------------------------------
Map_obj56:
	include "mappings/sprite/obj56.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 57 - spiked balls (SYZ, LZ)
; ---------------------------------------------------------------------------

Obj57:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj57_Index(pc,d0.w),d1
		jmp	Obj57_Index(pc,d1.w)
; ===========================================================================
Obj57_Index:	dc.w Obj57_Main-Obj57_Index
		dc.w Obj57_Move-Obj57_Index
		dc.w Obj57_Display-Obj57_Index
; ===========================================================================

Obj57_Main:				; XREF: Obj57_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj57,4(a0)
		move.w	#$3BA,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#8,$19(a0)
		move.w	8(a0),$3A(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$98,$20(a0)	; SYZ specific code (chain hurts Sonic)
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		bne.s	loc_107E8
		move.b	#0,$20(a0)	; LZ specific code (chain doesn't hurt)
		move.w	#$310,2(a0)
		move.l	#Map_obj57a,4(a0)

loc_107E8:
		move.b	$28(a0),d1	; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1		; multiply by 8
		move.w	d1,$3E(a0)	; set object twirl speed
		move.b	$22(a0),d0
		ror.b	#2,d0
		andi.b	#-$40,d0
		move.b	d0,$26(a0)
		lea	$29(a0),a2
		move.b	$28(a0),d1	; get object type
		andi.w	#7,d1		; read only the	2nd digit
		move.b	#0,(a2)+
		move.w	d1,d3
		lsl.w	#4,d3
		move.b	d3,$3C(a0)
		subq.w	#1,d1		; set chain length (type-1)
		bcs.s	loc_10894
		btst	#3,$28(a0)
		beq.s	Obj57_MakeChain
		subq.w	#1,d1
		bcs.s	loc_10894

Obj57_MakeChain:
		bsr.w	SingleObjLoad
		bne.s	loc_10894
		addq.b	#1,$29(a0)
		move.w	a1,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#4,$24(a1)
		move.b	0(a0),0(a1)
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		move.b	1(a0),1(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.b	$20(a0),$20(a1)
		subi.b	#$10,d3
		move.b	d3,$3C(a1)
		cmpi.b	#1,(Current_Zone).w
		bne.s	loc_10890
		tst.b	d3
		bne.s	loc_10890
		move.b	#2,$1A(a1)

loc_10890:
		dbf	d1,Obj57_MakeChain ; repeat for	length of chain

loc_10894:
		move.w	a0,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		bne.s	Obj57_Move
		move.b	#$8B,$20(a0)	; if yes, make last spikeball larger
		move.b	#1,$1A(a0)	; use different	frame

Obj57_Move:				; XREF: Obj57_Index
		bsr.w	Obj57_MoveSub
		bra.w	Obj57_ChkDel
; ===========================================================================

Obj57_MoveSub:				; XREF: Obj57_Move
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		lea	$29(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

Obj57_MoveLoop:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#Object_RAM,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	$3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a1)
		move.w	d5,8(a1)
		dbf	d6,Obj57_MoveLoop
		rts	
; ===========================================================================

Obj57_ChkDel:				; XREF: Obj57_Move
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj57_Delete
		bra.w	DisplaySprite
; ===========================================================================

Obj57_Delete:				; XREF: Obj57_ChkDel
		moveq	#0,d2
		lea	$29(a0),a2
		move.b	(a2)+,d2

Obj57_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,Obj57_DelLoop ; delete all pieces of	chain

		rts	
; ===========================================================================

Obj57_Display:				; XREF: Obj57_Index
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - chain of spiked balls (SYZ)
; ---------------------------------------------------------------------------
Map_obj57:
	include "mappings/sprite/obj57syz.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spiked ball	on a chain (LZ)
; ---------------------------------------------------------------------------
Map_obj57a:
	include "mappings/sprite/obj57lz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 58 - giant spiked balls (SYZ)
; ---------------------------------------------------------------------------

Obj58:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj58_Index(pc,d0.w),d1
		jmp	Obj58_Index(pc,d1.w)
; ===========================================================================
Obj58_Index:	dc.w Obj58_Main-Obj58_Index
		dc.w Obj58_Move-Obj58_Index
; ===========================================================================

Obj58_Main:				; XREF: Obj58_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj15b,4(a0)
		move.w	#$396,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$18,$19(a0)
		move.w	8(a0),$3A(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$86,$20(a0)
		move.b	$28(a0),d1	; get object type
		andi.b	#$F0,d1		; read only the	1st digit
		ext.w	d1
		asl.w	#3,d1		; multiply by 8
		move.w	d1,$3E(a0)	; set object speed
		move.b	$22(a0),d0
		ror.b	#2,d0
		andi.b	#$C0,d0
		move.b	d0,$26(a0)
		move.b	#$50,$3C(a0)	; set diameter of circle of rotation

Obj58_Move:				; XREF: Obj58_Index
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		andi.w	#7,d0		; read only the	2nd digit
		add.w	d0,d0
		move.w	Obj58_TypeIndex(pc,d0.w),d1
		jsr	Obj58_TypeIndex(pc,d1.w)
		move.w	$3A(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj58_TypeIndex:dc.w Obj58_Type00-Obj58_TypeIndex
		dc.w Obj58_Type01-Obj58_TypeIndex
		dc.w Obj58_Type02-Obj58_TypeIndex
		dc.w Obj58_Type03-Obj58_TypeIndex
; ===========================================================================

Obj58_Type00:				; XREF: Obj58_TypeIndex
		rts	
; ===========================================================================

Obj58_Type01:				; XREF: Obj58_TypeIndex
		move.w	#$60,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$C).w,d0
		btst	#0,$22(a0)
		beq.s	loc_10A38
		neg.w	d0
		add.w	d1,d0

loc_10A38:
		move.w	$3A(a0),d1
		sub.w	d0,d1
		move.w	d1,8(a0)	; move object horizontally
		rts	
; ===========================================================================

Obj58_Type02:				; XREF: Obj58_TypeIndex
		move.w	#$60,d1
		moveq	#0,d0
		move.b	(Oscillation_Data+$C).w,d0
		btst	#0,$22(a0)
		beq.s	loc_10A5C
		neg.w	d0
		addi.w	#$80,d0

loc_10A5C:
		move.w	$38(a0),d1
		sub.w	d0,d1
		move.w	d1,$C(a0)	; move object vertically
		rts	
; ===========================================================================

Obj58_Type03:				; XREF: Obj58_TypeIndex
		move.w	$3E(a0),d0
		add.w	d0,$26(a0)
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		move.w	$38(a0),d2
		move.w	$3A(a0),d3
		moveq	#0,d4
		move.b	$3C(a0),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,$C(a0)
		move.w	d5,8(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SBZ	spiked ball on a chain
; ---------------------------------------------------------------------------
Map_obj15b:
	include "mappings/sprite/obj15sbz.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 59 - platforms	that move when you stand on them (SLZ)
; ---------------------------------------------------------------------------

Obj59:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj59_Index(pc,d0.w),d1
		jsr	Obj59_Index(pc,d1.w)
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj59_Index:	dc.w Obj59_Main-Obj59_Index
		dc.w Obj59_Platform-Obj59_Index
		dc.w Obj59_Action-Obj59_Index
		dc.w Obj59_MakeMulti-Obj59_Index

Obj59_Var1:	dc.b $28, 0		; width, frame number

Obj59_Var2:	dc.b $10, 1		; width, action	type
		dc.b $20, 1
		dc.b $34, 1
		dc.b $10, 3
		dc.b $20, 3
		dc.b $34, 3
		dc.b $14, 1
		dc.b $24, 1
		dc.b $2C, 1
		dc.b $14, 3
		dc.b $24, 3
		dc.b $2C, 3
		dc.b $20, 5
		dc.b $20, 7
		dc.b $30, 9
; ===========================================================================

Obj59_Main:				; XREF: Obj59_Index
		addq.b	#2,$24(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		bpl.s	Obj59_Main2
		addq.b	#4,$24(a0)
		andi.w	#$7F,d0
		mulu.w	#6,d0
		move.w	d0,$3C(a0)
		move.w	d0,$3E(a0)
		addq.l	#4,sp
		rts	
; ===========================================================================

Obj59_Main2:
		lsr.w	#3,d0
		andi.w	#$1E,d0
		lea	Obj59_Var1(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2)+,$1A(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	Obj59_Var2(pc,d0.w),a2
		move.b	(a2)+,d0
		lsl.w	#2,d0
		move.w	d0,$3C(a0)
		move.b	(a2)+,$28(a0)
		move.l	#Map_obj59,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.w	8(a0),$32(a0)
		move.w	$C(a0),$30(a0)

Obj59_Platform:				; XREF: Obj59_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.w	Obj59_Types
; ===========================================================================

Obj59_Action:				; XREF: Obj59_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	Obj59_Types
		move.w	(sp)+,d2
		tst.b	0(a0)
		beq.s	locret_10BD4
		jmp	(MvSonicOnPtfm2).l
; ===========================================================================

locret_10BD4:
		rts	
; ===========================================================================

Obj59_Types:
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj59_TypeIndex(pc,d0.w),d1
		jmp	Obj59_TypeIndex(pc,d1.w)
; ===========================================================================
Obj59_TypeIndex:dc.w Obj59_Type00-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type02-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type04-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type06-Obj59_TypeIndex, Obj59_Type01-Obj59_TypeIndex
		dc.w Obj59_Type08-Obj59_TypeIndex, Obj59_Type09-Obj59_TypeIndex
; ===========================================================================

Obj59_Type00:				; XREF: Obj59_TypeIndex
		rts	
; ===========================================================================

Obj59_Type01:				; XREF: Obj59_TypeIndex
		cmpi.b	#4,$24(a0)	; check	if Sonic is standing on	the object
		bne.s	locret_10C0C
		addq.b	#1,$28(a0)	; if yes, add 1	to type

locret_10C0C:
		rts	
; ===========================================================================

Obj59_Type02:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		rts	
; ===========================================================================

Obj59_Type04:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		rts	
; ===========================================================================

Obj59_Type06:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		asr.w	#1,d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		move.w	$34(a0),d0
		add.w	$32(a0),d0
		move.w	d0,8(a0)
		rts	
; ===========================================================================

Obj59_Type08:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		asr.w	#1,d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		move.w	$34(a0),d0
		neg.w	d0
		add.w	$32(a0),d0
		move.w	d0,8(a0)
		rts	
; ===========================================================================

Obj59_Type09:				; XREF: Obj59_TypeIndex
		bsr.w	Obj59_Move
		move.w	$34(a0),d0
		neg.w	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)
		tst.b	$28(a0)
		beq.w	loc_10C94
		rts	
; ===========================================================================

loc_10C94:
		btst	#3,$22(a0)
		beq.s	Obj59_Delete
		bset	#1,$22(a1)
		bclr	#3,$22(a1)
		move.b	#2,$24(a1)

Obj59_Delete:
		bra.w	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj59_Move:				; XREF: Obj59_Type02; et al
		move.w	$38(a0),d0
		tst.b	$3A(a0)
		bne.s	loc_10CC8
		cmpi.w	#$800,d0
		bcc.s	loc_10CD0
		addi.w	#$10,d0
		bra.s	loc_10CD0
; ===========================================================================

loc_10CC8:
		tst.w	d0
		beq.s	loc_10CD0
		subi.w	#$10,d0

loc_10CD0:
		move.w	d0,$38(a0)
		ext.l	d0
		asl.l	#8,d0
		add.l	$34(a0),d0
		move.l	d0,$34(a0)
		swap	d0
		move.w	$3C(a0),d2
		cmp.w	d2,d0
		bls.s	loc_10CF0
		move.b	#1,$3A(a0)

loc_10CF0:
		add.w	d2,d2
		cmp.w	d2,d0
		bne.s	locret_10CFA
		clr.b	$28(a0)

locret_10CFA:
		rts	
; End of function Obj59_Move

; ===========================================================================

Obj59_MakeMulti:			; XREF: Obj59_Index
		subq.w	#1,$3C(a0)
		bne.s	Obj59_ChkDel
		move.w	$3E(a0),$3C(a0)
		bsr.w	SingleObjLoad
		bne.s	Obj59_ChkDel
		move.b	#$59,0(a1)	; duplicate the	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$E,$28(a1)

Obj59_ChkDel:
		addq.l	#4,sp
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - platforms that move	when you stand on them (SLZ)
; ---------------------------------------------------------------------------
Map_obj59:
	include "mappings/sprite/obj59.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5A - platforms	moving in circles (SLZ)
; ---------------------------------------------------------------------------

Obj5A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5A_Index(pc,d0.w),d1
		jsr	Obj5A_Index(pc,d1.w)
		move.w	$32(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5A_Index:	dc.w Obj5A_Main-Obj5A_Index
		dc.w Obj5A_Platform-Obj5A_Index
		dc.w Obj5A_Action-Obj5A_Index
; ===========================================================================

Obj5A_Main:				; XREF: Obj5A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5A,4(a0)
		move.w	#$4000,2(a0)
		move.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$18,$19(a0)
		move.w	8(a0),$32(a0)
		move.w	$C(a0),$30(a0)

Obj5A_Platform:				; XREF: Obj5A_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(PlatformObject).l
		bra.w	Obj5A_Types
; ===========================================================================

Obj5A_Action:				; XREF: Obj5A_Index
		moveq	#0,d1
		move.b	$19(a0),d1
		jsr	(ExitPlatform).l
		move.w	8(a0),-(sp)
		bsr.w	Obj5A_Types
		move.w	(sp)+,d2
		jmp	(MvSonicOnPtfm2).l
; ===========================================================================

Obj5A_Types:
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$C,d0
		lsr.w	#1,d0
		move.w	Obj5A_TypeIndex(pc,d0.w),d1
		jmp	Obj5A_TypeIndex(pc,d1.w)
; ===========================================================================
Obj5A_TypeIndex:dc.w Obj5A_Type00-Obj5A_TypeIndex
		dc.w Obj5A_Type04-Obj5A_TypeIndex
; ===========================================================================

Obj5A_Type00:				; XREF: Obj5A_TypeIndex
		move.b	(Oscillation_Data+$20).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	(Oscillation_Data+$24).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,$28(a0)
		beq.s	loc_10E24
		neg.w	d1
		neg.w	d2

loc_10E24:
		btst	#1,$28(a0)
		beq.s	loc_10E30
		neg.w	d1
		exg	d1,d2

loc_10E30:
		add.w	$32(a0),d1
		move.w	d1,8(a0)
		add.w	$30(a0),d2
		move.w	d2,$C(a0)
		rts	
; ===========================================================================

Obj5A_Type04:				; XREF: Obj5A_TypeIndex
		move.b	(Oscillation_Data+$20).w,d1
		subi.b	#$50,d1
		ext.w	d1
		move.b	(Oscillation_Data+$24).w,d2
		subi.b	#$50,d2
		ext.w	d2
		btst	#0,$28(a0)
		beq.s	loc_10E62
		neg.w	d1
		neg.w	d2

loc_10E62:
		btst	#1,$28(a0)
		beq.s	loc_10E6E
		neg.w	d1
		exg	d1,d2

loc_10E6E:
		neg.w	d1
		add.w	$32(a0),d1
		move.w	d1,8(a0)
		add.w	$30(a0),d2
		move.w	d2,$C(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - platforms that move	in circles (SLZ)
; ---------------------------------------------------------------------------
Map_obj5A:
	include "mappings/sprite/obj5A.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5B - blocks that form a staircase (SLZ)
; ---------------------------------------------------------------------------

Obj5B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5B_Index(pc,d0.w),d1
		jsr	Obj5B_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5B_Index:	dc.w Obj5B_Main-Obj5B_Index
		dc.w Obj5B_Move-Obj5B_Index
		dc.w Obj5B_Solid-Obj5B_Index
; ===========================================================================

Obj5B_Main:				; XREF: Obj5B_Index
		addq.b	#2,$24(a0)
		moveq	#$38,d3
		moveq	#1,d4
		btst	#0,$22(a0)
		beq.s	loc_10EDA
		moveq	#$3B,d3
		moveq	#-1,d4

loc_10EDA:
		move.w	8(a0),d2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj5B_MakeBlocks
; ===========================================================================

Obj5B_Loop:
		bsr.w	SingleObjLoad2
		bne.w	Obj5B_Move
		move.b	#4,$24(a1)

Obj5B_MakeBlocks:			; XREF: Obj5B_Main
		move.b	#$5B,0(a1)	; load another block object
		move.l	#Map_obj5B,4(a1)
		move.w	#$4000,2(a1)
		move.b	#4,1(a1)
		move.b	#3,$18(a1)
		move.b	#$10,$19(a1)
		move.b	$28(a0),$28(a1)
		move.w	d2,8(a1)
		move.w	$C(a0),$C(a1)
		move.w	8(a0),$30(a1)
		move.w	$C(a1),$32(a1)
		addi.w	#$20,d2
		move.b	d3,$37(a1)
		move.l	a0,$3C(a1)
		add.b	d4,d3
		dbf	d1,Obj5B_Loop	; repeat sequence 3 times

Obj5B_Move:				; XREF: Obj5B_Index
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#7,d0
		add.w	d0,d0
		move.w	Obj5B_TypeIndex(pc,d0.w),d1
		jsr	Obj5B_TypeIndex(pc,d1.w)

Obj5B_Solid:				; XREF: Obj5B_Index
		movea.l	$3C(a0),a2
		moveq	#0,d0
		move.b	$37(a0),d0
		move.b	(a2,d0.w),d0
		add.w	$32(a0),d0
		move.w	d0,$C(a0)
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		bsr.w	SolidObject
		tst.b	d4
		bpl.s	loc_10F92
		move.b	d4,$36(a2)

loc_10F92:
		btst	#3,$22(a0)
		beq.s	locret_10FA0
		move.b	#1,$36(a2)

locret_10FA0:
		rts	
; ===========================================================================
Obj5B_TypeIndex:dc.w Obj5B_Type00-Obj5B_TypeIndex
		dc.w Obj5B_Type01-Obj5B_TypeIndex
		dc.w Obj5B_Type02-Obj5B_TypeIndex
		dc.w Obj5B_Type01-Obj5B_TypeIndex
; ===========================================================================

Obj5B_Type00:				; XREF: Obj5B_TypeIndex
		tst.w	$34(a0)
		bne.s	loc_10FC0
		cmpi.b	#1,$36(a0)
		bne.s	locret_10FBE
		move.w	#$1E,$34(a0)

locret_10FBE:
		rts	
; ===========================================================================

loc_10FC0:
		subq.w	#1,$34(a0)
		bne.s	locret_10FBE
		addq.b	#1,$28(a0)	; add 1	to type
		rts	
; ===========================================================================

Obj5B_Type02:				; XREF: Obj5B_TypeIndex
		tst.w	$34(a0)
		bne.s	loc_10FE0
		tst.b	$36(a0)
		bpl.s	locret_10FDE
		move.w	#$3C,$34(a0)

locret_10FDE:
		rts	
; ===========================================================================

loc_10FE0:
		subq.w	#1,$34(a0)
		bne.s	loc_10FEC
		addq.b	#1,$28(a0)	; add 1	to type
		rts	
; ===========================================================================

loc_10FEC:
		lea	$38(a0),a1
		move.w	$34(a0),d0
		lsr.b	#2,d0
		andi.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		eori.b	#1,d0
		move.b	d0,(a1)+
		rts	
; ===========================================================================

Obj5B_Type01:				; XREF: Obj5B_TypeIndex
		lea	$38(a0),a1
		cmpi.b	#$80,(a1)
		beq.s	locret_11038
		addq.b	#1,(a1)
		moveq	#0,d1
		move.b	(a1)+,d1
		swap	d1
		lsr.l	#1,d1
		move.l	d1,d2
		lsr.l	#1,d1
		move.l	d1,d3
		add.l	d2,d3
		swap	d1
		swap	d2
		swap	d3
		move.b	d3,(a1)+
		move.b	d2,(a1)+
		move.b	d1,(a1)+

locret_11038:
		rts	
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	form a staircase (SLZ)
; ---------------------------------------------------------------------------
Map_obj5B:
	include "mappings/sprite/obj5B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5C - metal girders in foreground (SLZ)
; ---------------------------------------------------------------------------

Obj5C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5C_Index(pc,d0.w),d1
		jmp	Obj5C_Index(pc,d1.w)
; ===========================================================================
Obj5C_Index:	dc.w Obj5C_Main-Obj5C_Index
		dc.w Obj5C_Display-Obj5C_Index
; ===========================================================================

Obj5C_Main:				; XREF: Obj5C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5C,4(a0)
		move.w	#$83CC,2(a0)
		move.b	#$10,$19(a0)

Obj5C_Display:				; XREF: Obj5C_Index
		move.l	(Camera_X_Pos).w,d1
		add.l	d1,d1
		swap	d1
		neg.w	d1
		move.w	d1,8(a0)
		move.l	(Camera_Y_Pos).w,d1
		add.l	d1,d1
		swap	d1
		andi.w	#$3F,d1
		neg.w	d1
		addi.w	#$100,d1
		move.w	d1,$A(a0)
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - metal girders in foreground	(SLZ)
; ---------------------------------------------------------------------------
Map_obj5C:
	include "mappings/sprite/obj5C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 1B - water surface (LZ)
; ---------------------------------------------------------------------------

Obj1B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj1B_Index(pc,d0.w),d1
		jmp	Obj1B_Index(pc,d1.w)
; ===========================================================================
Obj1B_Index:	dc.w Obj1B_Main-Obj1B_Index
		dc.w Obj1B_Action-Obj1B_Index
; ===========================================================================

Obj1B_Main:				; XREF: Obj1B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj1B,4(a0)
		move.w	#$C300,2(a0)
		move.b	#4,1(a0)
		move.b	#$80,$19(a0)
		move.w	8(a0),$30(a0)

Obj1B_Action:				; XREF: Obj1B_Index
		move.w	(Camera_X_Pos).w,d1
		andi.w	#$FFE0,d1
		add.w	$30(a0),d1
		btst	#0,(Level_Timer+1).w
		beq.s	loc_11114
		addi.w	#$20,d1

loc_11114:
		move.w	d1,8(a0)	; match	obj x-position to screen position
		move.w	(Water_Height).w,d1
		move.w	d1,$C(a0)	; match	obj y-position to water	height
		tst.b	$32(a0)
		bne.s	Obj1B_Animate
		btst	#7,(Ctrl_1_Press).w ; is Start button pressed?
		beq.s	loc_1114A	; if not, branch
		addq.b	#3,$1A(a0)	; use different	frames
		move.b	#1,$32(a0)	; stop animation
		bra.s	Obj1B_Display
; ===========================================================================

Obj1B_Animate:				; XREF: loc_11114
		tst.w	(Pause_Flag).w	; is the game paused?
		bne.s	Obj1B_Display	; if yes, branch
		move.b	#0,$32(a0)	; resume animation
		subq.b	#3,$1A(a0)	; use normal frames

loc_1114A:				; XREF: loc_11114
		subq.b	#1,$1E(a0)
		bpl.s	Obj1B_Display
		move.b	#7,$1E(a0)
		addq.b	#1,$1A(a0)
		cmpi.b	#3,$1A(a0)
		bcs.s	Obj1B_Display
		move.b	#0,$1A(a0)

Obj1B_Display:
		bra.w	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - water surface (LZ)
; ---------------------------------------------------------------------------
Map_obj1B:
	include "mappings/sprite/obj1B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0B - pole that	breaks (LZ)
; ---------------------------------------------------------------------------

Obj0B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0B_Index(pc,d0.w),d1
		jmp	Obj0B_Index(pc,d1.w)
; ===========================================================================
Obj0B_Index:	dc.w Obj0B_Main-Obj0B_Index
		dc.w Obj0B_Action-Obj0B_Index
		dc.w Obj0B_Display-Obj0B_Index
; ===========================================================================

Obj0B_Main:				; XREF: Obj0B_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0B,4(a0)
		move.w	#$43DE,2(a0)
		move.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#4,$18(a0)
		move.b	#$E1,$20(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		mulu.w	#60,d0		; multiply by 60 (1 second)
		move.w	d0,$30(a0)	; set breakage time

Obj0B_Action:				; XREF: Obj0B_Index
		tst.b	$32(a0)
		beq.s	Obj0B_Grab
		tst.w	$30(a0)
		beq.s	Obj0B_MoveUp
		subq.w	#1,$30(a0)
		bne.s	Obj0B_MoveUp
		move.b	#1,$1A(a0)	; break	the pole
		bra.s	Obj0B_Release
; ===========================================================================

Obj0B_MoveUp:				; XREF: Obj0B_Action
		lea	(Object_RAM).w,a1
		move.w	$C(a0),d0
		subi.w	#$18,d0
		btst	#0,(Ctrl_1_Held).w ; check if "up" is pressed
		beq.s	Obj0B_MoveDown
		subq.w	#1,$C(a1)	; move Sonic up
		cmp.w	$C(a1),d0
		bcs.s	Obj0B_MoveDown
		move.w	d0,$C(a1)

Obj0B_MoveDown:
		addi.w	#$24,d0
		btst	#1,(Ctrl_1_Held).w ; check if "down" is pressed
		beq.s	Obj0B_LetGo
		addq.w	#1,$C(a1)	; move Sonic down
		cmp.w	$C(a1),d0
		bcc.s	Obj0B_LetGo
		move.w	d0,$C(a1)

Obj0B_LetGo:
		move.b	(Sonic_Ctrl_Press).w,d0
		andi.w	#$70,d0
		beq.s	Obj0B_Display

Obj0B_Release:				; XREF: Obj0B_Action
		clr.b	$20(a0)
		addq.b	#2,$24(a0)
		clr.b	(No_Player_Physics_Flag).w
		clr.b	(Wind_Tunnel_Flag).w
		clr.b	$32(a0)
		bra.s	Obj0B_Display
; ===========================================================================

Obj0B_Grab:				; XREF: Obj0B_Action
		tst.b	$21(a0)		; has Sonic touched the	pole?
		beq.s	Obj0B_Display	; if not, branch
		lea	(Object_RAM).w,a1
		move.w	8(a0),d0
		addi.w	#$14,d0
		cmp.w	8(a1),d0
		bcc.s	Obj0B_Display
		clr.b	$21(a0)
		cmpi.b	#4,$24(a1)
		bcc.s	Obj0B_Display
		clr.w	$10(a1)		; stop Sonic moving
		clr.w	$12(a1)		; stop Sonic moving
		move.w	8(a0),d0
		addi.w	#$14,d0
		move.w	d0,8(a1)
		bclr	#0,$22(a1)
		move.b	#$11,$1C(a1)	; set Sonic's animation to "hanging" ($11)
		move.b	#1,(No_Player_Physics_Flag).w ; lock	controls
		move.b	#1,(Wind_Tunnel_Flag).w ; disable wind	tunnel
		move.b	#1,$32(a0)	; begin	countdown to breakage

Obj0B_Display:				; XREF: Obj0B_Index
		bra.w	MarkObjGone
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - pole that breaks (LZ)
; ---------------------------------------------------------------------------
Map_obj0B:
	include "mappings/sprite/obj0B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0C - flapping door (LZ)
; ---------------------------------------------------------------------------

Obj0C:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0C_Index(pc,d0.w),d1
		jmp	Obj0C_Index(pc,d1.w)
; ===========================================================================
Obj0C_Index:	dc.w Obj0C_Main-Obj0C_Index
		dc.w Obj0C_OpenClose-Obj0C_Index
; ===========================================================================

Obj0C_Main:				; XREF: Obj0C_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0C,4(a0)
		move.w	#$4328,2(a0)
		ori.b	#4,1(a0)
		move.b	#$28,$19(a0)
		moveq	#0,d0
		move.b	$28(a0),d0	; get object type
		mulu.w	#60,d0		; multiply by 60 (1 second)
		move.w	d0,$32(a0)	; set flap delay time

Obj0C_OpenClose:			; XREF: Obj0C_Index
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	Obj0C_Solid	; if time remains, branch
		move.w	$32(a0),$30(a0)	; reset	time delay
		bchg	#0,$1C(a0)	; open/close door
		tst.b	1(a0)
		bpl.s	Obj0C_Solid
		move.w	#SndID_Door,d0
		jsr	(PlaySound_Special).l ;	play door sound

Obj0C_Solid:
		lea	(Ani_obj0C).l,a1
		bsr.w	AnimateSprite
		clr.b	(Wind_Tunnel_Flag).w	; enable wind tunnel
		tst.b	$1A(a0)		; is the door open?
		bne.s	Obj0C_Display	; if yes, branch
		move.w	(Object_Space_1+8).w,d0
		cmp.w	8(a0),d0	; is Sonic in front of the door?
		bcc.s	Obj0C_Display	; if yes, branch
		move.b	#1,(Wind_Tunnel_Flag).w ; disable wind	tunnel
		move.w	#$13,d1
		move.w	#$20,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject	; make the door	solid

Obj0C_Display:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj0C:
	include "objects/animation/obj0C.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - flapping door (LZ)
; ---------------------------------------------------------------------------
Map_obj0C:
	include "mappings/sprite/obj0C.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 71 - invisible	solid blocks
; ---------------------------------------------------------------------------

Obj71:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj71_Index(pc,d0.w),d1
		jmp	Obj71_Index(pc,d1.w)
; ===========================================================================
Obj71_Index:	dc.w Obj71_Main-Obj71_Index
		dc.w Obj71_Solid-Obj71_Index
; ===========================================================================

Obj71_Main:				; XREF: Obj71_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj71,4(a0)
		move.w	#$8680,2(a0)
		ori.b	#4,1(a0)
		move.b	$28(a0),d0	; get object type
		move.b	d0,d1
		andi.w	#$F0,d0		; read only the	1st byte
		addi.w	#$10,d0
		lsr.w	#1,d0
		move.b	d0,$19(a0)	; set object width
		andi.w	#$F,d1		; read only the	2nd byte
		addq.w	#1,d1
		lsl.w	#3,d1
		move.b	d1,$16(a0)	; set object height

Obj71_Solid:				; XREF: Obj71_Index
		bsr.w	ChkObjOnScreen
		bne.s	Obj71_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	8(a0),d4
		bsr.w	SolidObject71

Obj71_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj71_Delete
		tst.w	(Debug_Placement_Mode).w	; are you using	debug mode?
		beq.s	Obj71_NoDisplay	; if not, branch
		jmp	DisplaySprite	; if yes, display the object
; ===========================================================================

Obj71_NoDisplay:
		rts	
; ===========================================================================

Obj71_Delete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - invisible solid blocks
; ---------------------------------------------------------------------------
Map_obj71:
	include "mappings/sprite/obj71.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5D - fans (SLZ)
; ---------------------------------------------------------------------------

Obj5D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5D_Index(pc,d0.w),d1
		jmp	Obj5D_Index(pc,d1.w)
; ===========================================================================
Obj5D_Index:	dc.w Obj5D_Main-Obj5D_Index
		dc.w Obj5D_Delay-Obj5D_Index
; ===========================================================================

Obj5D_Main:				; XREF: Obj5D_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5D,4(a0)
		move.w	#$43A0,2(a0)
		ori.b	#4,1(a0)
		move.b	#$10,$19(a0)
		move.b	#4,$18(a0)

Obj5D_Delay:				; XREF: Obj5D_Index
		btst	#1,$28(a0)	; is object type 02/03?
		bne.s	Obj5D_Blow	; if yes, branch
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	Obj5D_Blow	; if time remains, branch
		move.w	#120,$30(a0)	; set delay to 2 seconds
		bchg	#0,$32(a0)	; switch fan on/off
		beq.s	Obj5D_Blow	; if fan is off, branch
		move.w	#180,$30(a0)	; set delay to 3 seconds

Obj5D_Blow:
		tst.b	$32(a0)		; is fan switched on?
		bne.w	Obj5D_ChkDel	; if not, branch
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		btst	#0,$22(a0)
		bne.s	Obj5D_ChkSonic
		neg.w	d0

Obj5D_ChkSonic:
		addi.w	#$50,d0
		cmpi.w	#$F0,d0		; is Sonic more	than $A0 pixels	from the fan?
		bcc.s	Obj5D_Animate	; if yes, branch
		move.w	$C(a1),d1
		addi.w	#$60,d1
		sub.w	$C(a0),d1
		bcs.s	Obj5D_Animate
		cmpi.w	#$70,d1
		bcc.s	Obj5D_Animate
		subi.w	#$50,d0
		bcc.s	loc_1159A
		not.w	d0
		add.w	d0,d0

loc_1159A:
		addi.w	#$60,d0
		btst	#0,$22(a0)
		bne.s	loc_115A8
		neg.w	d0

loc_115A8:
		neg.b	d0
		asr.w	#4,d0
		btst	#0,$28(a0)
		beq.s	Obj5D_MoveSonic
		neg.w	d0

Obj5D_MoveSonic:
		add.w	d0,8(a1)	; push Sonic away from the fan

Obj5D_Animate:				; XREF: Obj5D_ChkSonic
		subq.b	#1,$1E(a0)
		bpl.s	Obj5D_ChkDel
		move.b	#0,$1E(a0)
		addq.b	#1,$1B(a0)
		cmpi.b	#3,$1B(a0)
		bcs.s	loc_115D8
		move.b	#0,$1B(a0)

loc_115D8:
		moveq	#0,d0
		btst	#0,$28(a0)
		beq.s	loc_115E4
		moveq	#2,d0

loc_115E4:
		add.b	$1B(a0),d0
		move.b	d0,$1A(a0)

Obj5D_ChkDel:				; XREF: Obj5D_Animate
		bsr.w	DisplaySprite
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - fans (SLZ)
; ---------------------------------------------------------------------------
Map_obj5D:
	include "mappings/sprite/obj5D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5E - seesaws (SLZ)
; ---------------------------------------------------------------------------

Obj5E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5E_Index(pc,d0.w),d1
		jsr	Obj5E_Index(pc,d1.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	DeleteObject
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5E_Index:	dc.w Obj5E_Main-Obj5E_Index
		dc.w Obj5E_Slope-Obj5E_Index
		dc.w Obj5E_Slope2-Obj5E_Index
		dc.w Obj5E_Spikeball-Obj5E_Index
		dc.w Obj5E_MoveSpike-Obj5E_Index
		dc.w Obj5E_SpikeFall-Obj5E_Index
; ===========================================================================

Obj5E_Main:				; XREF: Obj5E_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5E,4(a0)
		move.w	#$374,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$30,$19(a0)
		move.w	8(a0),$30(a0)
		tst.b	$28(a0)		; is object type 00 ?
		bne.s	loc_116D2	; if not, branch
		bsr.w	SingleObjLoad2
		bne.s	loc_116D2
		move.b	#$5E,0(a1)	; load spikeball object
		addq.b	#6,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.l	a0,$3C(a1)

loc_116D2:
		btst	#0,$22(a0)
		beq.s	loc_116E0
		move.b	#2,$1A(a0)

loc_116E0:
		move.b	$1A(a0),$3A(a0)

Obj5E_Slope:				; XREF: Obj5E_Index
		move.b	$3A(a0),d1
		bsr.w	loc_11766
		lea	(Obj5E_Data1).l,a2
		btst	#0,$1A(a0)
		beq.s	loc_11702
		lea	(Obj5E_Data2).l,a2

loc_11702:
		lea	(Object_RAM).w,a1
		move.w	$12(a1),$38(a0)
		move.w	#$30,d1
		jsr	(SlopeObject).l
		rts	
; ===========================================================================

Obj5E_Slope2:				; XREF: Obj5E_Index
		bsr.w	loc_1174A
		lea	(Obj5E_Data1).l,a2
		btst	#0,$1A(a0)
		beq.s	loc_11730
		lea	(Obj5E_Data2).l,a2

loc_11730:
		move.w	#$30,d1
		jsr	(ExitPlatform).l
		move.w	#$30,d1
		move.w	8(a0),d2
		jsr	SlopeObject2
		rts	
; ===========================================================================

loc_1174A:				; XREF: Obj5E_Slope2
		moveq	#2,d1
		lea	(Object_RAM).w,a1
		move.w	8(a0),d0
		sub.w	8(a1),d0
		bcc.s	loc_1175E
		neg.w	d0
		moveq	#0,d1

loc_1175E:
		cmpi.w	#8,d0
		bcc.s	loc_11766
		moveq	#1,d1

loc_11766:
		move.b	$1A(a0),d0
		cmp.b	d1,d0
		beq.s	locret_11790
		bcc.s	loc_11772
		addq.b	#2,d0

loc_11772:
		subq.b	#1,d0
		move.b	d0,$1A(a0)
		move.b	d1,$3A(a0)
		bclr	#0,1(a0)
		btst	#1,$1A(a0)
		beq.s	locret_11790
		bset	#0,1(a0)

locret_11790:
		rts	
; ===========================================================================

Obj5E_Spikeball:			; XREF: Obj5E_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5Ea,4(a0)
		move.w	#$4F0,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$8B,$20(a0)
		move.b	#$C,$19(a0)
		move.w	8(a0),$30(a0)
		addi.w	#$28,8(a0)
		move.w	$C(a0),$34(a0)
		move.b	#1,$1A(a0)
		btst	#0,$22(a0)
		beq.s	Obj5E_MoveSpike
		subi.w	#$50,8(a0)
		move.b	#2,$3A(a0)

Obj5E_MoveSpike:			; XREF: Obj5E_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$3A(a0),d0
		sub.b	$3A(a1),d0
		beq.s	loc_1183E
		bcc.s	loc_117FC
		neg.b	d0

loc_117FC:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0
		beq.s	loc_11822
		move.w	#-$AF0,d1
		move.w	#-$CC,d2
		cmpi.w	#$A00,$38(a1)
		blt.s	loc_11822
		move.w	#-$E00,d1
		move.w	#-$A0,d2

loc_11822:
		move.w	d1,$12(a0)
		move.w	d2,$10(a0)
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		bcc.s	loc_11838
		neg.w	$10(a0)

loc_11838:
		addq.b	#2,$24(a0)
		bra.s	Obj5E_SpikeFall
; ===========================================================================

loc_1183E:				; XREF: Obj5E_MoveSpike
		lea	(Obj5E_Speeds).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	#$28,d2
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_1185C
		neg.w	d2
		addq.w	#2,d0

loc_1185C:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,$C(a0)
		add.w	$30(a0),d2
		move.w	d2,8(a0)
		clr.w	$E(a0)
		clr.w	$A(a0)
		rts	
; ===========================================================================

Obj5E_SpikeFall:			; XREF: Obj5E_Index
		tst.w	$12(a0)
		bpl.s	loc_1189A
		bsr.w	ObjectMoveAndFall
		move.w	$34(a0),d0
		subi.w	#$2F,d0
		cmp.w	$C(a0),d0
		bgt.s	locret_11898
		bsr.w	ObjectMoveAndFall

locret_11898:
		rts	
; ===========================================================================

loc_1189A:				; XREF: Obj5E_SpikeFall
		bsr.w	ObjectMoveAndFall
		movea.l	$3C(a0),a1
		lea	(Obj5E_Speeds).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_118BA
		addq.w	#2,d0

loc_118BA:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	$C(a0),d1
		bgt.s	locret_11938
		movea.l	$3C(a0),a1
		moveq	#2,d1
		tst.w	$10(a0)
		bmi.s	Obj5E_Spring
		moveq	#0,d1

Obj5E_Spring:
		move.b	d1,$3A(a1)
		move.b	d1,$3A(a0)
		cmp.b	$1A(a1),d1
		beq.s	loc_1192C
		bclr	#3,$22(a1)
		beq.s	loc_1192C
		clr.b	$25(a1)
		move.b	#2,$24(a1)
		lea	(Object_RAM).w,a2
		move.w	$12(a0),$12(a2)
		neg.w	$12(a2)
		bset	#1,$22(a2)
		bclr	#3,$22(a2)
		clr.b	$3C(a2)
		move.b	#$10,$1C(a2)	; change Sonic's animation to "spring" ($10)
		move.b	#2,$24(a2)
		move.w	#SndID_Spring,d0
		jsr	(PlaySound_Special).l ;	play spring sound

loc_1192C:
		clr.w	$10(a0)
		clr.w	$12(a0)
		subq.b	#2,$24(a0)

locret_11938:
		rts	
; ===========================================================================
Obj5E_Speeds:	dc.w $FFF8, $FFE4, $FFD1, $FFE4, $FFF8

Obj5E_Data1:	incbin	data/seesaw/slzssaw1.bin
		even
Obj5E_Data2:	incbin	data/seesaw/slzssaw2.bin
		even
; ---------------------------------------------------------------------------
; Sprite mappings - seesaws (SLZ)
; ---------------------------------------------------------------------------
Map_obj5E:
	include "mappings/sprite/obj5E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - spiked balls on the	seesaws	(SLZ)
; ---------------------------------------------------------------------------
Map_obj5Ea:
	include "mappings/sprite/obj5Eballs.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 5F - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------

Obj5F:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj5F_Index(pc,d0.w),d1
		jmp	Obj5F_Index(pc,d1.w)
; ===========================================================================
Obj5F_Index:	dc.w Obj5F_Main-Obj5F_Index
		dc.w Obj5F_Action-Obj5F_Index
		dc.w Obj5F_Display-Obj5F_Index
		dc.w Obj5F_End-Obj5F_Index
; ===========================================================================

Obj5F_Main:				; XREF: Obj5F_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj5F,4(a0)
		move.w	#$400,2(a0)
		ori.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$C,$19(a0)
		move.b	$28(a0),d0
		beq.s	loc_11A3C
		move.b	d0,$24(a0)
		rts	
; ===========================================================================

loc_11A3C:
		move.b	#$9A,$20(a0)
		bchg	#0,$22(a0)

Obj5F_Action:				; XREF: Obj5F_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj5F_Index2(pc,d0.w),d1
		jsr	Obj5F_Index2(pc,d1.w)
		lea	(Ani_obj5F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================
Obj5F_Index2:	dc.w Obj5F_Walk-Obj5F_Index2
		dc.w Obj5F_Wait-Obj5F_Index2
		dc.w Obj5F_Explode-Obj5F_Index2
; ===========================================================================

Obj5F_Walk:				; XREF: Obj5F_Index2
		bsr.w	Obj5F_ChkSonic
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bpl.s	locret_11A96	; if time remains, branch
		addq.b	#2,$25(a0)
		move.w	#1535,$30(a0)	; set time delay to 25 seconds
		move.w	#$10,$10(a0)
		move.b	#1,$1C(a0)
		bchg	#0,$22(a0)
		beq.s	locret_11A96
		neg.w	$10(a0)		; change direction

locret_11A96:
		rts	
; ===========================================================================

Obj5F_Wait:				; XREF: Obj5F_Index2
		bsr.w	Obj5F_ChkSonic
		subq.w	#1,$30(a0)	; subtract 1 from time delay
		bmi.s	loc_11AA8
		bsr.w	ObjectMove
		rts	
; ===========================================================================

loc_11AA8:
		subq.b	#2,$25(a0)
		move.w	#179,$30(a0)	; set time delay to 3 seconds
		clr.w	$10(a0)		; stop walking
		move.b	#0,$1C(a0)	; stop animation
		rts	
; ===========================================================================

Obj5F_Explode:				; XREF: Obj5F_Index2
		subq.w	#1,$30(a0)
		bpl.s	locret_11AD0
		move.b	#$3F,0(a0)	; change bomb into an explosion
		move.b	#0,$24(a0)

locret_11AD0:
		rts	
; ===========================================================================

Obj5F_ChkSonic:				; XREF: Obj5F_Walk; Obj5F_Wait
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_11ADE
		neg.w	d0

loc_11ADE:
		cmpi.w	#$60,d0
		bcc.s	locret_11B5E
		move.w	(Object_Space_1+$C).w,d0
		sub.w	$C(a0),d0
		bcc.s	Obj5F_MakeFuse
		neg.w	d0

Obj5F_MakeFuse:
		cmpi.w	#$60,d0
		bcc.s	locret_11B5E
		tst.w	(Debug_Placement_Mode).w
		bne.s	locret_11B5E
		move.b	#4,$25(a0)
		move.w	#143,$30(a0)	; set fuse time
		clr.w	$10(a0)
		move.b	#2,$1C(a0)
		bsr.w	SingleObjLoad2
		bne.s	locret_11B5E
		move.b	#$5F,0(a1)	; load fuse object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	$C(a0),$34(a1)
		move.b	$22(a0),$22(a1)
		move.b	#4,$28(a1)
		move.b	#3,$1C(a1)
		move.w	#$10,$12(a1)
		btst	#1,$22(a0)
		beq.s	loc_11B54
		neg.w	$12(a1)

loc_11B54:
		move.w	#143,$30(a1)	; set fuse time
		move.l	a0,$3C(a1)

locret_11B5E:
		rts	
; ===========================================================================

Obj5F_Display:				; XREF: Obj5F_Index
		bsr.s	loc_11B70
		lea	(Ani_obj5F).l,a1
		bsr.w	AnimateSprite
		bra.w	MarkObjGone
; ===========================================================================

loc_11B70:
		subq.w	#1,$30(a0)
		bmi.s	loc_11B7C
		bsr.w	ObjectMove
		rts	
; ===========================================================================

loc_11B7C:
		clr.w	$30(a0)
		clr.b	$24(a0)
		move.w	$34(a0),$C(a0)
		moveq	#3,d1
		movea.l	a0,a1
		lea	(Obj5F_ShrSpeed).l,a2 ;	load shrapnel speed data
		bra.s	Obj5F_MakeShrap
; ===========================================================================

Obj5F_Loop:
		bsr.w	SingleObjLoad2
		bne.s	loc_11BCE

Obj5F_MakeShrap:			; XREF: loc_11B7C
		move.b	#$5F,0(a1)	; load shrapnel	object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#6,$28(a1)
		move.b	#4,$1C(a1)
		move.w	(a2)+,$10(a1)
		move.w	(a2)+,$12(a1)
		move.b	#$98,$20(a1)
		bset	#7,1(a1)

loc_11BCE:
		dbf	d1,Obj5F_Loop	; repeat 3 more	times

		move.b	#6,$24(a0)

Obj5F_End:				; XREF: Obj5F_Index
		bsr.w	ObjectMove
		addi.w	#$18,$12(a0)
		lea	(Ani_obj5F).l,a1
		bsr.w	AnimateSprite
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj5F_ShrSpeed:	dc.w $FE00, $FD00, $FF00, $FE00, $200, $FD00, $100, $FE00

Ani_obj5F:
	include "objects/animation/obj5F.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - walking bomb enemy (SLZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj5F:
	include "mappings/sprite/obj5F.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 60 - Orbinaut enemy (LZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

Obj60:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj60_Index(pc,d0.w),d1
		jmp	Obj60_Index(pc,d1.w)
; ===========================================================================
Obj60_Index:	dc.w Obj60_Main-Obj60_Index
		dc.w Obj60_ChkSonic-Obj60_Index
		dc.w Obj60_Display-Obj60_Index
		dc.w Obj60_MoveOrb-Obj60_Index
		dc.w Obj60_ChkDel2-Obj60_Index
; ===========================================================================

Obj60_Main:				; XREF: Obj60_Index
		move.l	#Map_obj60,4(a0)
		move.w	#$2429,2(a0)	; SLZ specific code
		cmpi.b	#1,(Current_Zone).w ; check if level is LZ
		bne.s	loc_11D10
		move.w	#$467,2(a0)	; LZ specific code

loc_11D10:
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$B,$20(a0)
		move.b	#$C,$19(a0)
		moveq	#0,d2
		lea	$37(a0),a2
		movea.l	a2,a3
		addq.w	#1,a2
		moveq	#3,d1

Obj60_MakeOrbs:
		bsr.w	SingleObjLoad2
		bne.s	loc_11D90
		addq.b	#1,(a3)
		move.w	a1,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	0(a0),0(a1)	; load spiked orb object
		move.b	#6,$24(a1)
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		ori.b	#4,1(a1)
		move.b	#4,$18(a1)
		move.b	#8,$19(a1)
		move.b	#3,$1A(a1)
		move.b	#$98,$20(a1)
		move.b	d2,$26(a1)
		addi.b	#$40,d2
		move.l	a0,$3C(a1)
		dbf	d1,Obj60_MakeOrbs ; repeat sequence 3 more times

loc_11D90:
		moveq	#1,d0
		btst	#0,$22(a0)
		beq.s	Obj60_Move
		neg.w	d0

Obj60_Move:
		move.b	d0,$36(a0)
		move.b	$28(a0),$24(a0)	; if type is 02, skip the firing rountine
		addq.b	#2,$24(a0)
		move.w	#-$40,$10(a0)	; move orbinaut	to the left
		btst	#0,$22(a0)	; is orbinaut reversed?
		beq.s	locret_11DBC	; if not, branch
		neg.w	$10(a0)		; move orbinaut	to the right

locret_11DBC:
		rts	
; ===========================================================================

Obj60_ChkSonic:				; XREF: Obj60_Index
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		bcc.s	loc_11DCA
		neg.w	d0

loc_11DCA:
		cmpi.w	#$A0,d0		; is Sonic within $A0 pixels of	orbinaut?
		bcc.s	Obj60_Animate	; if not, branch
		move.w	(Object_Space_1+$C).w,d0
		sub.w	$C(a0),d0
		bcc.s	loc_11DDC
		neg.w	d0

loc_11DDC:
		cmpi.w	#$50,d0		; is Sonic within $50 pixels of	orbinaut?
		bcc.s	Obj60_Animate	; if not, branch
		tst.w	(Debug_Placement_Mode).w	; is debug mode	on?
		bne.s	Obj60_Animate	; if yes, branch
		move.b	#1,$1C(a0)	; use "angry" animation

Obj60_Animate:
		lea	(Ani_obj60).l,a1
		bsr.w	AnimateSprite
		bra.w	Obj60_ChkDel
; ===========================================================================

Obj60_Display:				; XREF: Obj60_Index
		bsr.w	ObjectMove

Obj60_ChkDel:				; XREF: Obj60_Animate
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj60_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Obj60_ChkGone:				; XREF: Obj60_ChkDel
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_11E34
		bclr	#7,2(a2,d0.w)

loc_11E34:
		lea	$37(a0),a2
		moveq	#0,d2
		move.b	(a2)+,d2
		subq.w	#1,d2
		bcs.s	Obj60_Delete

loc_11E40:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#6,d0
		addi.l	#Object_RAM,d0
		movea.l	d0,a1
		bsr.w	DeleteObject2
		dbf	d2,loc_11E40

Obj60_Delete:
		bra.w	DeleteObject
; ===========================================================================

Obj60_MoveOrb:				; XREF: Obj60_Index
		movea.l	$3C(a0),a1
		cmpi.b	#$60,0(a1)
		bne.w	DeleteObject
		cmpi.b	#2,$1A(a1)
		bne.s	Obj60_Circle
		cmpi.b	#$40,$26(a0)
		bne.s	Obj60_Circle
		addq.b	#2,$24(a0)
		subq.b	#1,$37(a1)
		bne.s	Obj60_FireOrb
		addq.b	#2,$24(a1)

Obj60_FireOrb:
		move.w	#-$200,$10(a0)	; move orb to the left (quickly)
		btst	#0,$22(a1)
		beq.s	Obj60_Display2
		neg.w	$10(a0)

Obj60_Display2:
		bra.w	DisplaySprite
; ===========================================================================

Obj60_Circle:				; XREF: Obj60_MoveOrb
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		asr.w	#4,d1
		add.w	8(a1),d1
		move.w	d1,8(a0)
		asr.w	#4,d0
		add.w	$C(a1),d0
		move.w	d0,$C(a0)
		move.b	$36(a1),d0
		add.b	d0,$26(a0)
		bra.w	DisplaySprite
; ===========================================================================

Obj60_ChkDel2:				; XREF: Obj60_Index
		bsr.w	ObjectMove
		tst.b	1(a0)
		bpl.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Ani_obj60:
	include "objects/animation/obj60.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Orbinaut enemy (LZ,	SLZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj60:
	include "mappings/sprite/obj60.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)
; ---------------------------------------------------------------------------

Obj16:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj16_Index(pc,d0.w),d1
		jmp	Obj16_Index(pc,d1.w)
; ===========================================================================
Obj16_Index:	dc.w Obj16_Main-Obj16_Index
		dc.w Obj16_Move-Obj16_Index
		dc.w Obj16_Wait-Obj16_Index
; ===========================================================================

Obj16_Main:				; XREF: Obj16_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj16,4(a0)
		move.w	#$3CC,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	$28(a0),$1C(a0)
		move.b	#$14,$19(a0)
		move.w	#60,$30(a0)

Obj16_Move:				; XREF: Obj16_Index
		lea	(Ani_obj16).l,a1
		bsr.w	AnimateSprite
		moveq	#0,d0
		move.b	$1A(a0),d0	; move frame number to d0
		move.b	Obj16_Data(pc,d0.w),$20(a0) ; load collision response (based on	d0)
		bra.w	MarkObjGone
; ===========================================================================
Obj16_Data:	dc.b $9B, $9C, $9D, $9E, $9F, $A0
; ===========================================================================

Obj16_Wait:				; XREF: Obj16_Index
		subq.w	#1,$30(a0)
		bpl.s	Obj16_ChkDel
		move.w	#60,$30(a0)
		subq.b	#2,$24(a0)	; run "Obj16_Move" subroutine
		bchg	#0,$1C(a0)	; reverse animation

Obj16_ChkDel:
		bra.w	MarkObjGone
; ===========================================================================
Ani_obj16:
	include "objects/animation/obj16.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - harpoon (LZ)
; ---------------------------------------------------------------------------
Map_obj16:
	include "mappings/sprite/obj16.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 61 - blocks (LZ)
; ---------------------------------------------------------------------------

Obj61:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj61_Index(pc,d0.w),d1
		jmp	Obj61_Index(pc,d1.w)
; ===========================================================================
Obj61_Index:	dc.w Obj61_Main-Obj61_Index
		dc.w Obj61_Action-Obj61_Index

Obj61_Var:	dc.b $10, $10		; width, height
		dc.b $20, $C
		dc.b $10, $10
		dc.b $10, $10
; ===========================================================================

Obj61_Main:				; XREF: Obj61_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj61,4(a0)
		move.w	#$43E6,2(a0)
		move.b	#4,1(a0)
		move.b	#3,$18(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		lea	Obj61_Var(pc,d0.w),a2
		move.b	(a2)+,$19(a0)
		move.b	(a2),$16(a0)
		lsr.w	#1,d0
		move.b	d0,$1A(a0)
		move.w	8(a0),$34(a0)
		move.w	$C(a0),$30(a0)
		move.b	$28(a0),d0
		andi.b	#$F,d0
		beq.s	Obj61_Action
		cmpi.b	#7,d0
		beq.s	Obj61_Action
		move.b	#1,$38(a0)

Obj61_Action:				; XREF: Obj61_Index
		move.w	8(a0),-(sp)
		moveq	#0,d0
		move.b	$28(a0),d0
		andi.w	#$F,d0
		add.w	d0,d0
		move.w	Obj61_TypeIndex(pc,d0.w),d1
		jsr	Obj61_TypeIndex(pc,d1.w)
		move.w	(sp)+,d4
		tst.b	1(a0)
		bpl.s	Obj61_ChkDel
		moveq	#0,d1
		move.b	$19(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	$16(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject
		move.b	d4,$3F(a0)
		bsr.w	loc_12180

Obj61_ChkDel:
		move.w	$34(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
Obj61_TypeIndex:dc.w Obj61_Type00-Obj61_TypeIndex, Obj61_Type01-Obj61_TypeIndex
		dc.w Obj61_Type02-Obj61_TypeIndex, Obj61_Type01-Obj61_TypeIndex
		dc.w Obj61_Type04-Obj61_TypeIndex, Obj61_Type05-Obj61_TypeIndex
		dc.w Obj61_Type02-Obj61_TypeIndex, Obj61_Type07-Obj61_TypeIndex
; ===========================================================================

Obj61_Type00:				; XREF: Obj61_TypeIndex
		rts	
; ===========================================================================

Obj61_Type01:				; XREF: Obj61_TypeIndex
		tst.w	$36(a0)		; is Sonic standing on the object?
		bne.s	loc_120D6	; if yes, branch
		btst	#3,$22(a0)
		beq.s	locret_120D4
		move.w	#30,$36(a0)	; wait for \AB second

locret_120D4:
		rts	
; ===========================================================================

loc_120D6:
		subq.w	#1,$36(a0)	; subtract 1 from waiting time
		bne.s	locret_120D4	; if time remains, branch
		addq.b	#1,$28(a0)	; add 1	to type
		clr.b	$38(a0)
		rts	
; ===========================================================================

Obj61_Type02:				; XREF: Obj61_TypeIndex
		bsr.w	ObjectMove
		addq.w	#8,$12(a0)	; make object fall
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.w	locret_12106
		addq.w	#1,d1
		add.w	d1,$C(a0)
		clr.w	$12(a0)		; stop when it touches the floor
		clr.b	$28(a0)		; set type to 00 (non-moving type)

locret_12106:
		rts	
; ===========================================================================

Obj61_Type04:				; XREF: Obj61_TypeIndex
		bsr.w	ObjectMove
		subq.w	#8,$12(a0)	; make object rise
		bsr.w	ObjHitCeiling
		tst.w	d1
		bpl.w	locret_12126
		sub.w	d1,$C(a0)
		clr.w	$12(a0)		; stop when it touches the ceiling
		clr.b	$28(a0)		; set type to 00 (non-moving type)

locret_12126:
		rts	
; ===========================================================================

Obj61_Type05:				; XREF: Obj61_TypeIndex
		cmpi.b	#1,$3F(a0)	; is Sonic touching the	object?
		bne.s	locret_12138	; if not, branch
		addq.b	#1,$28(a0)	; if yes, add 1	to type
		clr.b	$38(a0)

locret_12138:
		rts	
; ===========================================================================

Obj61_Type07:				; XREF: Obj61_TypeIndex
		move.w	(Water_Height).w,d0
		sub.w	$C(a0),d0
		beq.s	locret_1217E
		bcc.s	loc_12162
		cmpi.w	#-2,d0
		bge.s	loc_1214E
		moveq	#-2,d0

loc_1214E:
		add.w	d0,$C(a0)	; make the block rise with water level
		bsr.w	ObjHitCeiling
		tst.w	d1
		bpl.w	locret_12160
		sub.w	d1,$C(a0)

locret_12160:
		rts	
; ===========================================================================

loc_12162:				; XREF: Obj61_Type07
		cmpi.w	#2,d0
		ble.s	loc_1216A
		moveq	#2,d0

loc_1216A:
		add.w	d0,$C(a0)	; make the block sink with water level
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.w	locret_1217E
		addq.w	#1,d1
		add.w	d1,$C(a0)

locret_1217E:
		rts	
; ===========================================================================

loc_12180:				; XREF: Obj61_Action
		tst.b	$38(a0)
		beq.s	locret_121C0
		btst	#3,$22(a0)
		bne.s	loc_1219A
		tst.b	$3E(a0)
		beq.s	locret_121C0
		subq.b	#4,$3E(a0)
		bra.s	loc_121A6
; ===========================================================================

loc_1219A:
		cmpi.b	#$40,$3E(a0)
		beq.s	locret_121C0
		addq.b	#4,$3E(a0)

loc_121A6:
		move.b	$3E(a0),d0
		jsr	(CalcSine).l
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	$30(a0),d0
		move.w	d0,$C(a0)

locret_121C0:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - blocks (LZ)
; ---------------------------------------------------------------------------
Map_obj61:
	include "mappings/sprite/obj61.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 62 - gargoyle head (LZ)
; ---------------------------------------------------------------------------

Obj62:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj62_Index(pc,d0.w),d1
		jsr	Obj62_Index(pc,d1.w)
		bra.w	MarkObjGone
; ===========================================================================
Obj62_Index:	dc.w Obj62_Main-Obj62_Index
		dc.w Obj62_MakeFire-Obj62_Index
		dc.w Obj62_FireBall-Obj62_Index
		dc.w Obj62_AniFire-Obj62_Index

Obj62_SpitRate:	dc.b 30, 60, 90, 120, 150, 180,	210, 240
; ===========================================================================

Obj62_Main:				; XREF: Obj62_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj62,4(a0)
		move.w	#$42E9,2(a0)
		ori.b	#4,1(a0)
		move.b	#3,$18(a0)
		move.b	#$10,$19(a0)
		move.b	$28(a0),d0	; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		move.b	Obj62_SpitRate(pc,d0.w),$1F(a0)	; set fireball spit rate
		move.b	$1F(a0),$1E(a0)
		andi.b	#$F,$28(a0)

Obj62_MakeFire:				; XREF: Obj62_Index
		subq.b	#1,$1E(a0)
		bne.s	Obj62_NoFire
		move.b	$1F(a0),$1E(a0)
		bsr.w	ChkObjOnScreen
		bne.s	Obj62_NoFire
		bsr.w	SingleObjLoad
		bne.s	Obj62_NoFire
		move.b	#$62,0(a1)	; load fireball	object
		addq.b	#4,$24(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	1(a0),1(a1)
		move.b	$22(a0),$22(a1)

Obj62_NoFire:
		rts	
; ===========================================================================

Obj62_FireBall:				; XREF: Obj62_Index
		addq.b	#2,$24(a0)
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj62,4(a0)
		move.w	#$2E9,2(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$98,$20(a0)
		move.b	#8,$19(a0)
		move.b	#2,$1A(a0)
		addq.w	#8,$C(a0)
		move.w	#$200,$10(a0)
		btst	#0,$22(a0)
		bne.s	Obj62_Sound
		neg.w	$10(a0)

Obj62_Sound:
		move.w	#SndID_Fireball,d0
		jsr	(PlaySound_Special).l ;	play lava ball sound

Obj62_AniFire:				; XREF: Obj62_Index
		move.b	(Level_Timer+1).w,d0
		andi.b	#7,d0
		bne.s	Obj62_StopFire
		bchg	#0,$1A(a0)	; switch between frame 01 and 02

Obj62_StopFire:
		bsr.w	ObjectMove
		btst	#0,$22(a0)
		bne.s	Obj62_StopFire2
		moveq	#-8,d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.w	DeleteObject	; delete if the	fireball hits a	wall
		rts	
; ===========================================================================

Obj62_StopFire2:
		moveq	#8,d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bmi.w	DeleteObject
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - gargoyle head (LZ)
; ---------------------------------------------------------------------------
Map_obj62:
	include "mappings/sprite/obj62.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 63 - Unused
; ---------------------------------------------------------------------------

Obj63:					; XREF: Obj_Index
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 64 - bubbles (LZ)
; ---------------------------------------------------------------------------

Obj64:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj64_Index(pc,d0.w),d1
		jmp	Obj64_Index(pc,d1.w)
; ===========================================================================
Obj64_Index:	dc.w Obj64_Main-Obj64_Index
		dc.w Obj64_Animate-Obj64_Index
		dc.w Obj64_ChkWater-Obj64_Index
		dc.w Obj64_Display2-Obj64_Index
		dc.w Obj64_Delete3-Obj64_Index
		dc.w Obj64_BblMaker-Obj64_Index
; ===========================================================================

Obj64_Main:				; XREF: Obj64_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0A,4(a0)
		move.w	#$8348,2(a0)
		move.b	#$84,1(a0)
		move.b	#$10,$19(a0)
		move.b	#1,$18(a0)
		move.b	$28(a0),d0	; get object type
		bpl.s	Obj64_Bubble	; if type is $-$7F, branch
		addq.b	#8,$24(a0)
		andi.w	#$7F,d0		; read only last 7 bits	(deduct	$80)
		move.b	d0,$32(a0)
		move.b	d0,$33(a0)
		move.b	#6,$1C(a0)
		bra.w	Obj64_BblMaker
; ===========================================================================

Obj64_Bubble:				; XREF: Obj64_Main
		move.b	d0,$1C(a0)
		move.w	8(a0),$30(a0)
		move.w	#-$88,$12(a0)	; float	bubble upwards
		jsr	(RandomNumber).l
		move.b	d0,$26(a0)

Obj64_Animate:				; XREF: Obj64_Index
		lea	(Ani_obj64).l,a1
		jsr	AnimateSprite
		cmpi.b	#6,$1A(a0)
		bne.s	Obj64_ChkWater
		move.b	#1,$2E(a0)

Obj64_ChkWater:				; XREF: Obj64_Index
		move.w	(Water_Height).w,d0
		cmp.w	$C(a0),d0	; is bubble underwater?
		bcs.s	Obj64_Wobble	; if yes, branch
		move.b	#6,$24(a0)
		addq.b	#3,$1C(a0)	; run "bursting" animation
		bra.w	Obj64_Display2
; ===========================================================================

Obj64_Wobble:				; XREF: Obj64_ChkWater
		move.b	$26(a0),d0
		addq.b	#1,$26(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)	; change bubble's horizontal position
		tst.b	$2E(a0)
		beq.s	Obj64_Display
		bsr.w	Obj64_ChkSonic	; has Sonic touched the	bubble?
		cmpi.b	#6,$24(a0)
		beq.s	Obj64_Display2	; if not, branch
; ===========================================================================

Obj64_Display:				; XREF: Obj64_Wobble
		bsr.w	ObjectMove
		tst.b	1(a0)
		bpl.s	Obj64_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj64_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj64_Display2:				; XREF: Obj64_Index
		lea	(Ani_obj64).l,a1
		jsr	AnimateSprite
		tst.b	1(a0)
		bpl.s	Obj64_Delete2
		jmp	DisplaySprite
; ===========================================================================

Obj64_Delete2:
		jmp	DeleteObject
; ===========================================================================

Obj64_Delete3:				; XREF: Obj64_Index
		bra.w	DeleteObject
; ===========================================================================

Obj64_BblMaker:				; XREF: Obj64_Index
		tst.w	$36(a0)
		bne.s	loc_12874
		move.w	(Water_Height).w,d0
		cmp.w	$C(a0),d0	; is bubble maker underwater?
		bcc.w	Obj64_ChkDel	; if not, branch
		tst.b	1(a0)
		bpl.w	Obj64_ChkDel
		subq.w	#1,$38(a0)
		bpl.w	loc_12914
		move.w	#1,$36(a0)

loc_1283A:
		jsr	(RandomNumber).l
		move.w	d0,d1
		andi.w	#7,d0
		cmpi.w	#6,d0
		bcc.s	loc_1283A

		move.b	d0,$34(a0)
		andi.w	#$C,d1
		lea	(Obj64_BblTypes).l,a1
		adda.w	d1,a1
		move.l	a1,$3C(a0)
		subq.b	#1,$32(a0)
		bpl.s	loc_12872
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)

loc_12872:
		bra.s	loc_1287C
; ===========================================================================

loc_12874:				; XREF: Obj64_BblMaker
		subq.w	#1,$38(a0)
		bpl.w	loc_12914

loc_1287C:
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		move.w	d0,$38(a0)
		bsr.w	SingleObjLoad
		bne.s	loc_128F8
		move.b	#$64,0(a1)	; load bubble object
		move.w	8(a0),8(a1)
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		subq.w	#8,d0
		add.w	d0,8(a1)
		move.w	$C(a0),$C(a1)
		moveq	#0,d0
		move.b	$34(a0),d0
		movea.l	$3C(a0),a2
		move.b	(a2,d0.w),$28(a1)
		btst	#7,$36(a0)
		beq.s	loc_128F8
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_128E4
		bset	#6,$36(a0)
		bne.s	loc_128F8
		move.b	#2,$28(a1)

loc_128E4:
		tst.b	$34(a0)
		bne.s	loc_128F8
		bset	#6,$36(a0)
		bne.s	loc_128F8
		move.b	#2,$28(a1)

loc_128F8:
		subq.b	#1,$34(a0)
		bpl.s	loc_12914
		jsr	(RandomNumber).l
		andi.w	#$7F,d0
		addi.w	#$80,d0
		add.w	d0,$38(a0)
		clr.w	$36(a0)

loc_12914:
		lea	(Ani_obj64).l,a1
		jsr	AnimateSprite

Obj64_ChkDel:				; XREF: Obj64_BblMaker
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	DeleteObject
		move.w	(Water_Height).w,d0
		cmp.w	$C(a0),d0
		bcs.w	DisplaySprite
		rts	
; ===========================================================================
; bubble production sequence

; 0 = small bubble, 1 =	large bubble

Obj64_BblTypes:	dc.b 0,	1, 0, 0, 0, 0, 1, 0, 0,	0, 0, 1, 0, 1, 0, 0, 1,	0

; ===========================================================================

Obj64_ChkSonic:				; XREF: Obj64_Wobble
		tst.b	(No_Player_Physics_Flag).w
		bmi.w	loc_12998
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		move.w	8(a0),d1
		subi.w	#$10,d1
		cmp.w	d0,d1
		bcc.w	loc_12998
		addi.w	#$20,d1
		cmp.w	d0,d1
		bcs.w	loc_12998
		move.w	$C(a1),d0
		move.w	$C(a0),d1
		cmp.w	d0,d1
		bcc.s	loc_12998
		addi.w	#$10,d1
		cmp.w	d0,d1
		bcs.s	loc_12998
		bsr.w	StopDrowning	; cancel countdown music
		move.w	#SndID_GetBubble,d0
		jsr	(PlaySound_Special).l ;	play collecting	bubble sound
		lea	(Object_RAM).w,a1
		clr.w	$10(a1)
		clr.w	$12(a1)
		clr.w	$14(a1)
		move.b	#$15,$1C(a1)
		move.w	#$23,$3E(a1)
		move.b	#0,$3C(a1)
		bclr	#5,$22(a1)
		bclr	#4,$22(a1)
		btst	#2,$22(a1)
		beq.w	Obj64_Burst
		bclr	#2,$22(a1)
		move.b	#$13,$16(a1)
		move.b	#9,$17(a1)
		subq.w	#5,$C(a1)
; ===========================================================================

Obj64_Burst:
		cmpi.b	#6,$24(a0)
		beq.s	loc_12998
		move.b	#6,$24(a0)
		addq.b	#3,$1C(a0)

loc_12998:
		rts	
; ===========================================================================
Ani_obj64:
	include "objects/animation/obj64.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - bubbles (LZ)
; ---------------------------------------------------------------------------
Map_obj64:
	include "mappings/sprite/obj64.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 65 - waterfalls (LZ)
; ---------------------------------------------------------------------------

Obj65:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj65_Index(pc,d0.w),d1
		jmp	Obj65_Index(pc,d1.w)
; ===========================================================================
Obj65_Index:	dc.w Obj65_Main-Obj65_Index
		dc.w Obj65_Animate-Obj65_Index
		dc.w Obj65_ChkDel-Obj65_Index
		dc.w Obj65_FixHeight-Obj65_Index
		dc.w loc_12B36-Obj65_Index
; ===========================================================================

Obj65_Main:				; XREF: Obj65_Index
		addq.b	#4,$24(a0)
		move.l	#Map_obj65,4(a0)
		move.w	#$4259,2(a0)
		ori.b	#4,1(a0)
		move.b	#$18,$19(a0)
		move.b	#1,$18(a0)
		move.b	$28(a0),d0	; get object type
		bpl.s	loc_12AE6
		bset	#7,2(a0)

loc_12AE6:
		andi.b	#$F,d0		; read only the	2nd byte
		move.b	d0,$1A(a0)	; set frame number
		cmpi.b	#9,d0		; is object type $x9 ?
		bne.s	Obj65_ChkDel	; if not, branch
		clr.b	$18(a0)
		subq.b	#2,$24(a0)
		btst	#6,$28(a0)	; is object type $4x ?
		beq.s	loc_12B0A	; if not, branch
		move.b	#6,$24(a0)

loc_12B0A:
		btst	#5,$28(a0)	; is object type $Ax ?
		beq.s	Obj65_Animate	; if not, branch
		move.b	#8,$24(a0)

Obj65_Animate:				; XREF: Obj65_Index
		lea	(Ani_obj65).l,a1
		jsr	AnimateSprite

Obj65_ChkDel:				; XREF: Obj65_Index
		bra.w	MarkObjGone
; ===========================================================================

Obj65_FixHeight:			; XREF: Obj65_Index
		move.w	(Water_Height).w,d0
		subi.w	#$10,d0
		move.w	d0,$C(a0)	; match	object position	to water height
		bra.s	Obj65_Animate
; ===========================================================================

loc_12B36:				; XREF: Obj65_Index
		bclr	#7,2(a0)
		cmpi.b	#7,(Level_Layout+$106).w
		bne.s	Obj65_Animate2
		bset	#7,2(a0)

Obj65_Animate2:
		bra.s	Obj65_Animate
; ===========================================================================
Ani_obj65:
	include "objects/animation/obj65.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - waterfalls (LZ)
; ---------------------------------------------------------------------------
Map_obj65:
	include "mappings/sprite/obj65.asm"
; ===========================================================================
	include "objects\spindash_dust.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 01 - Sonic
; ---------------------------------------------------------------------------
; ===========================================================================
crawling								= $39
biting									= $3A
; ===========================================================================
Obj01_PhysicsTable:
		dc.w $600,   $C,  $80				; Normal
		dc.w $300,    6,  $40				; Underwater
		dc.w $C00,  $18,  $80				; Speed shoes
		dc.w $600,   $C,  $80				; Speed shoes underwater
		dc.w  $C0,  $18,  $24				; Crawling
		dc.w  $60,   $C,  $12				; Crawling underwater
		dc.w $180,  $30,  $48				; Crawling with speed shoes
		dc.w  $C0,  $18,  $24				; Crawling with speed shoes underwater
; ===========================================================================
; Get physics for Sonic
; ===========================================================================
Obj01_GetPhysics:
		moveq	#0,d0					; Set up the crawling flag, speed shoes flag, and underwater flag into a bitfield in d0
		move.b	crawling(a0),d0				; Like so:
		asl.b	#1,d0					; 0000 0CSU
		or.b	(Speed_Shoes_Flag).w,d0			; C = Crawling
		asl.b	#1,d0					; S = Speed shoes
		btst	#6,$22(a0)				; U = Underwater
		beq.s	@not_underwater
		ori.b	#1,d0
		
@not_underwater:
		mulu.w	#6,d0					; Multiply by 6 to make it a table index
		lea	Obj01_PhysicsTable(pc,d0.w),a1		; Get address where the values for Lover's physics are for the correct conditions
		move.w	(a1)+,(Sonic_Top_Speed).w		; Apply speeds
		move.w	(a1)+,(Sonic_Acceleration).w
		move.w	(a1),(Sonic_Deceleration).w
		rts						; Return
; ===========================================================================
; Apply speed cap for Sonic
; ===========================================================================
Obj01_ApplySpeedCap:
		move.w	$14(a0),d1				; Get Lover's ground velocity
		bpl.s	@not_negative				; If it's positive, skip having it negated
		neg.w	d1					; If it's negative, negate it to make it positive
		
@not_negative:
		move.w	(Sonic_Top_Speed).w,d2			; Get Lover's top speed
		cmp.w	d2,d1					; Check if Lover's current speed has surpassed the top speed
		ble.s	@no_cap					; If it didn't, branch
		sub.w	(Sonic_Deceleration).w,d1		; Subtract Lover's deceleration from the speed
		tst.w	$14(a0)					; Has Lover been moving right?
		bpl.s	@apply					; If so, branch
		neg.w	d1					; If Lover has been moving left, negate to set the correct value
		
@apply:
		move.w	d1,$14(a0)				; Apply the new value
		
@no_cap:
		rts						; Return
; ===========================================================================
; Check for crawling
; ===========================================================================
Obj01_CheckCrawl:
		btst	#1,(Sonic_Ctrl_Held).w			; Is the down button being held?
		bne.s	@is_crawling				; If so, then allow Lover to crawl
		moveq	#0,d0					; Check the distance between Lover and the ceiling
		move.b	$26(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#3,d1					; Is it less than 3?
		blt.w	@end					; If so, branch
		tst.b	crawling(a0)				; Has Lover already not been crawling beforehand?
		beq.s	@end					; If so, branch
		move.b	#$13,$16(a0)				; Reset y radius
		subq.w	#5,$C(a0)				; Reset y position
		move.b	#0,crawling(a0)				; Exit out of crawling mode
		rts						; Return
		
@is_crawling:
		bsr.w	Obj01_ApplySpeedCap			; If crawling, apply a speed cap
		bclr	#5,$22(a0)				; Clear push flag
		move.b	#8,$1C(a0)				; If not moving, use the ducking animation
		tst.w	$14(a0)					; Is Lover moving?
		beq.s	@chk					; If not, branch
		move.b	#$A,$1C(a0)				; If moving, use the crawling animation

@chk:
		tst.b	crawling(a0)				; Has Lover already been crawling beforehand?
		bne.s	@end					; If so, branch
		move.b	#$E,$16(a0)				; Decrease y radius
		addq.w	#5,$C(a0)				; Set new y position for the new y radius
		move.b	#1,crawling(a0)				; Enter crawling mode
		
@end:
		rts						; Return
; ===========================================================================
; Main object code
; ===========================================================================
Obj01:					; XREF: Obj_Index
		tst.w	(Debug_Placement_Mode).w	; is debug mode	being used?
		beq.s	Obj01_Normal			; if not, branch
		jmp	DebugMode
; ===========================================================================

Obj01_Normal:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj01_Index(pc,d0.w),d1
		jmp	Obj01_Index(pc,d1.w)
; ===========================================================================
Obj01_Index:
		dc.w Obj01_Main-Obj01_Index
		dc.w Obj01_Control-Obj01_Index
		dc.w Obj01_Hurt-Obj01_Index
		dc.w Obj01_Death-Obj01_Index
		dc.w Obj01_ResetLevel-Obj01_Index
		dc.w Obj01_Drowned-Obj01_Index
; ===========================================================================

Obj01_Main:				; XREF: Obj01_Index
		move.b	#$0,(Sonic_Current_Coll_Layer).w	; MJ: set collision to 1st
		addq.b	#2,$24(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		move.l	#Map_Sonic,4(a0)
		move.w	#$780,2(a0)
		move.b	#2,$18(a0)
		move.b	#$18,$19(a0)
		move.b	#4,1(a0)
		move.w	#$600,(Sonic_Top_Speed).w 	; Sonic's top speed
		move.w	#$C,(Sonic_Acceleration).w 	; Sonic's acceleration
		move.w	#$80,(Sonic_Deceleration).w 	; Sonic's deceleration
		move.w	#0,(Sonic_Min_Speed).w		; Sonic's minimum speed
		move.b	#$1E,$28(a0)
		move.b	#5,(Object_Space_8).w

Obj01_Control:				; XREF: Obj01_Index
		tst.w	(Debug_Cheat_On).w		; is debug cheat enabled?
		beq.s	loc_12C58			; if not, branch
		btst	#4,(Ctrl_1_Press).w 		; is button C pressed?
		beq.s	loc_12C58			; if not, branch
		move.w	#1,(Debug_Placement_Mode).w 	; change Sonic into a ring/item
		clr.b	(Lock_Controls_Flag).w
		rts	
; ===========================================================================

loc_12C58:
		bsr.w	Obj01_GetPhysics
		tst.b	(Lock_Controls_Flag).w			; are controls locked?
		bne.s	loc_12C64				; if yes, branch
		move.w	(Ctrl_1_Held).w,(Sonic_Ctrl_Held).w 	; enable joypad control

loc_12C64:
		btst	#0,(No_Player_Physics_Flag).w 		; are controls locked?
		bne.s	loc_12C7E				; if yes, branch
		bsr.w	Obj01_DoModes

loc_12C7E:
		tst.b	crawling(a0)
		bne.s	@no_bite
		tst.b	biting(a0)
		bne.s	@chk_bite
		btst	#6,(Sonic_Ctrl_Held).w
		beq.s	@no_bite
		tst.b	(Bite_Flag).w
		bne.s	@chk_bite
		bclr	#5,$22(a0)
		move.b	#13,biting(a0)
		move.b	#1,(Bite_Flag).w

@chk_bite:
		tst.b	biting(a0)
		beq.s	@no_dec
		move.b	#9,$1C(a0) ; Use "biting" animation
		subq.b	#1,biting(a0)
		bra.s	@no_dec
		
@no_bite:
		move.b	#0,(Bite_Flag).w
		move.b	#0,biting(a0)
		
@no_dec:
		bsr.s	Sonic_Display
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Water
		move.b	(Primary_Angle).w,$36(a0)
		move.b	(Secondary_Angle).w,$37(a0)
		tst.b	(Wind_Tunnel_Mode).w
		beq.s	loc_12CA6
		tst.b	$1C(a0)
		bne.s	loc_12CA6
		move.b	$1D(a0),$1C(a0)

loc_12CA6:
		bsr.w	Sonic_Animate
		tst.b	(No_Player_Physics_Flag).w
		bmi.s	loc_12CB6
		jsr	TouchResponse

loc_12CB6:
		bra.w	LoadSonicDynPLC
; ===========================================================================

Obj01_DoModes:
		moveq	#0,d0
		move.b	$22(a0),d0
		andi.w	#6,d0
		move.w	Obj01_Modes(pc,d0.w),d1
		jmp	Obj01_Modes(pc,d1.w)
; ===========================================================================

Obj01_Modes:	dc.w Obj01_MdNormal-Obj01_Modes
		dc.w Obj01_MdAir-Obj01_Modes
		dc.w Obj01_MdRoll-Obj01_Modes
		dc.w Obj01_MdJump-Obj01_Modes
; ===========================================================================

Sonic_Display:				; XREF: loc_12C7E
		move.w	$30(a0),d0
		beq.s	Obj01_Display
		subq.w	#1,$30(a0)
		lsr.w	#3,d0
		bcc.s	Obj01_ChkInvin

Obj01_Display:
		jsr	DisplaySprite

Obj01_ChkInvin:
		tst.b	(Invincibility_Flag).w	; does Sonic have invincibility?
		beq.s	Obj01_ChkShoes	; if not, branch
		tst.w	$32(a0)		; check	time remaining for invinciblity
		beq.s	Obj01_ChkShoes	; if no	time remains, branch
		subq.w	#1,$32(a0)	; subtract 1 from time
		bne.b	Obj01_ChkShoes
		move.b	#0,(Invincibility_Flag).w ; cancel invincibility

Obj01_ChkShoes:
		tst.b	(Speed_Shoes_Flag).w	; does Sonic have speed	shoes?
		beq.s	Obj01_ExitChk	; if not, branch
		tst.w	$34(a0)		; check	time remaining
		beq.s	Obj01_ExitChk
		subq.w	#1,$34(a0)	; subtract 1 from time
		bne.s	Obj01_ExitChk
		move.w	#$600,(Sonic_Top_Speed).w ; restore Sonic's speed
		move.w	#$C,(Sonic_Acceleration).w ; restore Sonic's acceleration
		move.w	#$80,(Sonic_Deceleration).w ; restore Sonic's deceleration
		move.b	#0,(Speed_Shoes_Flag).w ; cancel speed	shoes
		move.w	#CmdID_SlowDown,d0
		jmp	PlaySound_Special
; ===========================================================================

Obj01_ExitChk:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	record Sonic's previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RecordPos:			; XREF: loc_12C7E; Obj01_Hurt; Obj01_Death
		move.w	(Sonic_Pos_Record_Index).w,d0
		lea	(Sonic_Pos_Record_Buf).w,a1
		lea	(a1,d0.w),a1
		move.w	8(a0),(a1)+
		move.w	$C(a0),(a1)+
		addq.b	#4,(Sonic_Pos_Record_Index+1).w
		rts	
; End of function Sonic_RecordPos

; ---------------------------------------------------------------------------
; Subroutine for Sonic when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Water:				; XREF: loc_12C7E
		cmpi.b	#1,(Current_Zone).w ; is level LZ?
		beq.s	Obj01_InWater	; if yes, branch

locret_12D80:
		rts	
; ===========================================================================

Obj01_InWater:
		move.w	(Water_Height).w,d0
		cmp.w	$C(a0),d0	; is Sonic above the water?
		bge.s	Obj01_OutWater	; if yes, branch
		bset	#6,$22(a0)
		bne.s	locret_12D80
		bsr.w	StopDrowning
		move.b	#$A,(Object_Space_14).w ; load bubbles object	from Sonic's mouth
		move.b	#$81,(Object_Space_14+$28).w
		asr.w	$10(a0)
		asr.w	$12(a0)
		asr.w	$12(a0)
		beq.s	locret_12D80
		move.w	#$100,(Object_Space_8+$1C).w
		move.w	#SndID_Splash,d0
		jmp	(PlaySound_Special).l ;	play splash sound
; ===========================================================================

Obj01_OutWater:
		bclr	#6,$22(a0)
		beq.s	locret_12D80
		bsr.w	StopDrowning
		cmpi.b	#4,$24(a0)
		beq.s	@IsHurt
		asl.w	$12(a0)
		
@IsHurt:
		tst.w	$12(a0)
		beq.w	locret_12D80
		move.w	#$100,(Object_Space_8+$1C).w
		cmpi.w	#-$1000,$12(a0)
		bgt.s	loc_12E0E
		move.w	#-$1000,$12(a0)	; set maximum speed on leaving water

loc_12E0E:
		move.w	#SndID_Splash,d0
		jmp	(PlaySound_Special).l ;	play splash sound
; End of function Sonic_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes	for controlling	Sonic
; ---------------------------------------------------------------------------

Obj01_MdNormal:				; XREF: Obj01_Modes
		bsr.w	Sonic_Jump
		tst.b	crawling(a0)
		bne.s	@is_crawling
		bsr.w	Sonic_SlopeResist
		
@is_crawling:
		bsr.w	Sonic_Move
		bsr.w	Sonic_LevelBound
		jsr	ObjectMove
		bsr.w	Sonic_AnglePos
		tst.b	crawling(a0)
		bne.s	@is_crawling2
		bsr.w	Sonic_SlopeRepel
		
@is_crawling2:
		tst.w	$2E(a0)
		beq.s	@no_movelock
		subq.w	#1,$2E(a0)
		
@no_movelock:
		bra.w	Obj01_CheckCrawl	
; ===========================================================================

Obj01_MdAir:				; XREF: Obj01_Modes
		tst.b	crawling(a0)
		beq.s	@do
		move.b	#$13,$16(a0)
		subq.w	#5,$C(a0)

@do:
		move.b	#0,crawling(a0)
		bsr.w	Sonic_JumpHeight
		tst.b	(Force_Scroll_Touched_Boundary).w
		beq.s	@skip
		move.w	$14(a0),$10(a0)

@skip:
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		jsr	ObjectMoveAndFall
		btst	#6,$22(a0)
		beq.s	loc_12E5C
		subi.w	#$28,$12(a0)

loc_12E5C:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	
; ===========================================================================

Obj01_MdRoll:				; XREF: Obj01_Modes
		rts					; Nothing to see here
; ===========================================================================

Obj01_MdJump:				; XREF: Obj01_Modes
		tst.b	crawling(a0)
		beq.s	@do
		move.b	#$13,$16(a0)
		subq.w	#5,$C(a0)

@do:
		move.b	#0,crawling(a0)
		bsr.w	Sonic_JumpHeight
		tst.b	(Force_Scroll_Touched_Boundary).w
		beq.s	@skip
		move.w	$14(a0),$10(a0)

@skip:
		bsr.w	Sonic_ChgJumpDir
		bsr.w	Sonic_LevelBound
		bsr.w 	Sonic_JumpAnimate
		jsr	ObjectMoveAndFall
		btst	#6,$22(a0)
		beq.s	loc_12EA6
		subi.w	#$28,$12(a0)

loc_12EA6:
		bsr.w	Sonic_JumpAngle
		bsr.w	Sonic_Floor
		rts	
; ---------------------------------------------------------------------------
; Subroutine to	make Sonic walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Move:				; XREF: Obj01_MdNormal
		move.w	(Sonic_Top_Speed).w,d6
		move.w	(Sonic_Acceleration).w,d5
		move.w	(Sonic_Deceleration).w,d4
		tst.b	(Jump_Only_Flag).w
		bne.w	loc_12FEE
		tst.w	$2E(a0)
		bne.w	Obj01_ResetScr
		btst	#2,(Sonic_Ctrl_Held).w ; is left being pressed?
		beq.s	Obj01_NotLeft	; if not, branch
		bsr.w	Sonic_MoveLeft

Obj01_NotLeft:
		btst	#3,(Sonic_Ctrl_Held).w ; is right being pressed?
		beq.s	Obj01_NotRight	; if not, branch
		bsr.w	Sonic_MoveRight

Obj01_NotRight:
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0		; is Sonic on a	slope?
		bne.w	Obj01_ResetScr	; if yes, branch
		tst.w	$14(a0)		; is Sonic moving?
		bne.w	Obj01_ResetScr	; if yes, branch
		bclr	#5,$22(a0)
		move.b	#5,$1C(a0)	; use "standing" animation
		tst.b	crawling(a0)
		beq.s	@nocrawl
		move.b	#8,$1C(a0)

@nocrawl:
		btst	#3,$22(a0)
		beq.s	Sonic_Balance
		moveq	#0,d0
		move.b	$3D(a0),d0
		lsl.w	#6,d0
		lea	(Object_RAM).w,a1
		lea	(a1,d0.w),a1
		tst.b	$22(a1)
		bmi.s	Sonic_LookUp
		moveq	#0,d1
		move.b	$19(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	8(a0),d1
		sub.w	8(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_12F6A
		cmp.w	d2,d1
		bge.s	loc_12F5A
		bra.s	Sonic_LookUp
; ===========================================================================

Sonic_Balance:
		jsr	ObjHitFloor
		cmpi.w	#$C,d1
		blt.s	Sonic_LookUp
		cmpi.b	#3,$36(a0)
		bne.s	loc_12F62

loc_12F5A:
		bclr	#0,$22(a0)
		bra.s	loc_12F70
; ===========================================================================

loc_12F62:
		cmpi.b	#3,$37(a0)
		bne.s	Sonic_LookUp

loc_12F6A:
		bset	#0,$22(a0)

loc_12F70:
		move.b	#6,$1C(a0)	; use "balancing" animation
		bra.w	Obj01_ResetScr
; ===========================================================================

Sonic_LookUp:
		btst	#0,(Sonic_Ctrl_Held).w ; is up being pressed?
		beq.s	Sonic_Duck	; if not, branch
		move.b	#7,$1C(a0)	; use "looking up" animation
		addq.b	#1,(Sonic_Look_Delay_Counter+1).w
		cmp.b	#$78,(Sonic_Look_Delay_Counter+1).w
		bcs.s	Obj01_ResetScr_Part2
		move.b	#$78,(Sonic_Look_Delay_Counter+1).w
		cmpi.w	#$C8,(Camera_Y_Pos_Bias).w
		beq.w	loc_12FC2
		addq.w	#2,(Camera_Y_Pos_Bias).w
		bra.s	loc_12FC2
; ===========================================================================

Sonic_Duck:
		btst	#1,(Sonic_Ctrl_Held).w ; is down being pressed?
		beq.s	Obj01_ResetScr	; if not, branch
		move.b	#8,$1C(a0)	; use "ducking"	animation
		addq.b	#1,(Sonic_Look_Delay_Counter+1).w
		cmpi.b	#$78,(Sonic_Look_Delay_Counter+1).w
		bcs.s	Obj01_ResetScr_Part2
		move.b	#$78,(Sonic_Look_Delay_Counter+1).w
		cmpi.w	#8,(Camera_Y_Pos_Bias).w
		beq.s	loc_12FC2
		subq.w	#2,(Camera_Y_Pos_Bias).w
		bra.s	loc_12FC2
; ===========================================================================

Obj01_StopMove_OnForceScroll:
		move.w	$14(a0),d0
		bpl.s	@skip
		neg.w	d0

@skip:
		cmp.w	(Sonic_Min_Speed).w,d0
		beq.s	loc_12FEE

		sub.w	d5,d0
		cmp.w	(Sonic_Min_Speed).w,d0
		bge.s	@skip2
		move.w	(Sonic_Min_Speed).w,d0

@skip2:
		tst.w	$14(a0)
		bpl.s	@skip3
		neg.w	d0

@skip3:
		move.b	#0,$1C(a0)
		bra.s	loc_12FEA
; ===========================================================================

Obj01_ResetScr:
		move.b	#0,(Sonic_Look_Delay_Counter+1).w
		
Obj01_ResetScr_Part2:
		cmpi.w	#$60,(Camera_Y_Pos_Bias).w ; is	screen in its default position?
		beq.s	loc_12FC2	; if yes, branch
		bcc.s	loc_12FBE
		addq.w	#4,(Camera_Y_Pos_Bias).w ; move	screen back to default

loc_12FBE:
		subq.w	#2,(Camera_Y_Pos_Bias).w ; move	screen back to default

loc_12FC2:
		move.b	(Sonic_Ctrl_Held).w,d0
		andi.b	#$C,d0		; is left/right	pressed?
		bne.s	loc_12FEE	; if yes, branch
		tst.b	(Force_Scroll_Flag).w
		bne.s	Obj01_StopMove_OnForceScroll
		move.w	$14(a0),d0
		beq.s	loc_12FEE
		bmi.s	loc_12FE2
		sub.w	d5,d0
		bcc.s	loc_12FDC
		move.w	#0,d0

loc_12FDC:
		move.w	d0,$14(a0)
		bra.s	loc_12FEE
; ===========================================================================

loc_12FE2:
		add.w	d5,d0
		bcc.s	loc_12FEA
		move.w	#0,d0

loc_12FEA:
		move.w	d0,$14(a0)

loc_12FEE:
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		muls.w	$14(a0),d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	$14(a0),d0
		asr.l	#8,d0
		move.w	d0,$12(a0)

loc_1300C:
		move.b	$26(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307C
		move.b	#$40,d1
		tst.w	$14(a0)
		beq.s	locret_1307C
		bmi.s	loc_13024
		neg.w	d1

loc_13024:
		move.b	$26(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307C
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078
		cmpi.b	#$40,d0
		beq.s	loc_13066
		cmpi.b	#$80,d0
		beq.s	loc_13060
		add.w	d1,$10(a0)
		bset	#5,$22(a0)
		move.w	#0,$14(a0)
		rts	
; ===========================================================================

loc_13060:
		sub.w	d1,$12(a0)
		rts	
; ===========================================================================

loc_13066:
		sub.w	d1,$10(a0)
		bset	#5,$22(a0)
		move.w	#0,$14(a0)
		rts	
; ===========================================================================

loc_13078:
		add.w	d1,$12(a0)

locret_1307C:
		rts	
; End of function Sonic_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveLeft:		   ; XREF: Sonic_Move
		move.w	$14(a0),d0
		beq.s	loc_13086
		bpl.s	Sonic_TurnLeft

loc_13086:
		bset	#0,$22(a0)
		bne.s	loc_1309A
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)

loc_1309A:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6
		add.w	d5,d0
		cmp.w	d1,d0
		ble.s	loc_130A6
		move.w	d1,d0

loc_130A6:
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0); use walking animation
		rts
; ===========================================================================

Sonic_TurnLeft:				; XREF: Sonic_MoveLeft
		sub.w	d4,d0
		move.w	(Sonic_Min_Speed).w,d1
		tst.w	(Force_Scroll_Flag).w
		bne.s	@cmp
		move.w	#0,d1

@cmp:
		cmp.w	d1,d0
		bcc.s	loc_130BA
		move.w	d1,d0
		tst.w	(Force_Scroll_Flag).w
		bne.s	loc_130BA
		move.w	#-$80,d0

loc_130BA:
		move.w	d0,$14(a0)
		tst.w	(Force_Scroll_Flag).w
		bne.s	locret_130E8
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8
		cmpi.w	#$400,d0
		blt.s	locret_130E8
		move.b	#$D,$1C(a0)	; use "stopping" animation
		bclr	#0,$22(a0)
		move.w	#SndID_Skid,d0
		jsr	(PlaySound_Special).l ;	play stopping sound
		cmpi.b	#$C,$28(a0)
		blo.s	locret_130E8
		move.b	#6,(Object_Space_8+$24).w
		move.b	#$15,(Object_Space_8+$1A).w

locret_130E8:
		rts	
; End of function Sonic_MoveLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_MoveRight:	   ; XREF: Sonic_Move
		move.w	$14(a0),d0
		bmi.s	Sonic_TurnRight
		bclr	#0,$22(a0)
		beq.s	loc_13104
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)

loc_13104:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310C
		sub.w	d5,d0
		cmp.w	d6,d0
		bge.s	loc_1310C
		move.w	d6,d0

loc_1310C:
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0); use walking animation
		rts
; ===========================================================================

Sonic_TurnRight:				; XREF: Sonic_MoveRight
		add.w	d4,d0
		move.w	(Sonic_Min_Speed).w,d1
		tst.w	(Force_Scroll_Flag).w
		bne.s	@cmp
		move.w	#0,d1

@cmp:
		cmp.w	d1,d0
		bcc.s	loc_13120
		neg.w	d1
		move.w	d1,d0
		tst.w	(Force_Scroll_Flag).w
		bne.s	loc_13120
		move.w	#$80,d0

loc_13120:
		move.w	d0,$14(a0)
		tst.w	(Force_Scroll_Flag).w
		bne.s	locret_1314E
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314E
		cmpi.w	#-$400,d0
		bgt.s	locret_1314E
		move.b	#$D,$1C(a0)	; use "stopping" animation
		bset	#0,$22(a0)
		move.w	#SndID_Skid,d0
		jsr	(PlaySound_Special).l ;	play stopping sound
		cmpi.b	#$C,$28(a0)
		blo.s	locret_1314E
		move.b	#6,(Object_Space_8+$24).w
		move.b	#$15,(Object_Space_8+$1A).w

locret_1314E:
		rts	
; End of function Sonic_MoveRight

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollSpeed:			; XREF: Obj01_MdRoll
		rts
; End of function Sonic_RollSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollLeft:				; XREF: Sonic_RollSpeed
		rts	
; End of function Sonic_RollLeft


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRight:			; XREF: Sonic_RollSpeed
		rts	
; End of function Sonic_RollRight

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ChgJumpDir:		; XREF: Obj01_MdAir; Obj01_MdJump
		move.w	(Sonic_Top_Speed).w,d6
		move.w	(Sonic_Acceleration).w,d5
		asl.w	#1,d5
		btst	#4,$22(a0)	
		bne.s	Obj01_ResetScr2	
		move.w	$10(a0),d0	
		btst	#2,(Sonic_Ctrl_Held).w; is left being pressed?	
		beq.s	loc_13278; if not, branch	
		bset	#0,$22(a0)	
		sub.w	d5,d0	
		move.w	d6,d1	
		neg.w	d1	
		cmp.w	d1,d0	
		bgt.s	loc_13278	
		add.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d1,d0		; +++ compare speed with top speed
		ble.s	loc_13278	; +++ if speed was already greater than the maximum, branch	
		move.w	d1,d0

loc_13278:
		btst	#3,(Sonic_Ctrl_Held).w; is right being pressed?	
		beq.s	Obj01_JumpMove; if not, branch	
		bclr	#0,$22(a0)	
		add.w	d5,d0	
		cmp.w	d6,d0	
		blt.s	Obj01_JumpMove
		sub.w	d5,d0		; +++ remove this frame's acceleration change
		cmp.w	d6,d0		; +++ compare speed with top speed
		bge.s	Obj01_JumpMove	; +++ if speed was already greater than the maximum, branch
		move.w	d6,d0

Obj01_JumpMove:
		move.w	d0,$10(a0)	; change Sonic's horizontal speed

Obj01_ResetScr2:
		cmpi.w	#$60,(Camera_Y_Pos_Bias).w ; is	the screen in its default position?
		beq.s	loc_132A4	; if yes, branch
		bcc.s	loc_132A0
		addq.w	#4,(Camera_Y_Pos_Bias).w

loc_132A0:
		subq.w	#2,(Camera_Y_Pos_Bias).w

loc_132A4:
		cmpi.w	#-$400,$12(a0)	; is Sonic moving faster than -$400 upwards?
		bcs.s	locret_132D2	; if yes, branch
		move.w	$10(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_132D2
		bmi.s	loc_132C6
		sub.w	d1,d0
		bcc.s	loc_132C0
		move.w	#0,d0

loc_132C0:
		move.w	d0,$10(a0)
		rts	
; ===========================================================================

loc_132C6:
		sub.w	d1,d0
		bcs.s	loc_132CE
		move.w	#0,d0

loc_132CE:
		move.w	d0,$10(a0)

locret_132D2:
		rts	
; End of function Sonic_ChgJumpDir

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Sonic
; ---------------------------------------------------------------------------
sonic_squash:
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_13302
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_13302
		move.w	#0,$14(a0)	; stop Sonic moving
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.b	#$B,$1C(a0)	; use "warping"	animation

locret_13302:
		rts	
; ---------------------------------------------------------------------------
; Subroutine to	prevent	Sonic leaving the boundaries of	a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LevelBound:			; XREF: Obj01_MdNormal; et al
		move.b	#0,(Force_Scroll_Touched_Boundary).w
		move.l	8(a0),d1
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(Camera_Min_X_Pos).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bhi.s	Boundary_Sides	; if yes, branch
		move.w	(Camera_Max_X_Pos).w,d0
		addi.w	#$128,d0
		tst.b	(Screen_Lock).w
		bne.s	loc_13332
		addi.w	#$40,d0

loc_13332:
		cmp.w	d1,d0		; has Sonic touched the	side boundary?
		bls.s	Boundary_Sides	; if yes, branch

loc_13336:
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0	; has Sonic touched the	bottom boundary?
		blt.s	Boundary_Bottom	; if yes, branch
		rts	
; ===========================================================================

Boundary_Bottom:
		jmp	KillSonic
; ===========================================================================

Boundary_Sides:
		move.w	#0,$10(a0)	; stop Sonic moving
		move.w	d0,8(a0)
		move.w	#0,$A(a0)
		tst.b	(Force_Scroll_Flag).w
		bne.s	@forced_scroll
		move.w	#0,$14(a0)
		bra.s	loc_13336

@forced_scroll:
		move.w	(Force_Scroll_Speed).w,d0
		asl.w	#8,d0
		tst.b	(Force_Scroll_Flag).w
		bpl.s	@apply
		neg.w	d0

@apply:
		move.b	#1,(Force_Scroll_Touched_Boundary).w
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0)
		bra.s	loc_13336

; End of function Sonic_LevelBound

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Jump:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		move.b	(Sonic_Ctrl_Press).w,d0
		andi.b	#$30,d0		; is B or C pressed?
		beq.w	locret_1348E	; if not, branch
		moveq	#0,d0
		move.b	$26(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48
		cmpi.w	#6,d1
		blt.w	locret_1348E
		move.w	#$680,d2
		btst	#6,$22(a0)
		beq.s	loc_1341C
		move.w	#$380,d2

loc_1341C:
		moveq	#0,d0
		move.b	$26(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	d2,d1
		asr.l	#8,d1
		add.w	d1,$10(a0)	; make Sonic jump
		muls.w	d2,d0
		asr.l	#8,d0
		add.w	d0,$12(a0)	; make Sonic jump
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		addq.l	#4,sp
		move.b	#1,$3C(a0)
		clr.b	$38(a0)
		move.w	#SndID_Jump,d0
		jsr	(PlaySound_Special).l ;	play jumping sound
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		btst	#2,$22(a0)
		bne.s	loc_13490
		move.b	#$1F,$1C(a0)	; use "jumping"	animation
		bset	#2,$22(a0)

locret_1348E:
		rts	
; ===========================================================================

loc_13490:
		bset	#4,$22(a0)
		rts	
; End of function Sonic_Jump


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAnimate:
		move.b	#$20,d0 ;animation down
		tst.w	$12(a0)
		bpl.s	@positive
		move.b	#$1F,d0 ;animation up

@positive:
		move.b	d0,$1C(a0)
		rts

Sonic_JumpHeight:			; XREF: Obj01_MdAir; Obj01_MdJump
		tst.b	$3C(a0)
		beq.s	loc_134C4
		move.w	#-$400,d1
		btst	#6,$22(a0)
		beq.s	loc_134AE
		move.w	#-$200,d1

loc_134AE:
		cmp.w	$12(a0),d1
		ble.s	locret_134C2
		move.b	(Sonic_Ctrl_Held).w,d0
		andi.b	#$30,d0		; is B or C pressed?
		bne.s	locret_134C2	; if yes, branch
		move.w	d1,$12(a0)

locret_134C2:
		rts	
; ===========================================================================

loc_134C4:
		cmpi.w	#-$FC0,$12(a0)
		bge.s	locret_134D2
		move.w	#-$FC0,$12(a0)

locret_134D2:
		rts	
; End of function Sonic_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine to	slow Sonic walking up a	slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeResist:			; XREF: Obj01_MdNormal
		move.b	$26(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bcc.s	locret_13508
		move.b	$26(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	$14(a0)
		beq.s	locret_13508
		bmi.s	loc_13504
		tst.w	d0
		beq.s	locret_13502
		add.w	d0,$14(a0)	; change Sonic's inertia

locret_13502:
		rts	
; ===========================================================================

loc_13504:
		add.w	d0,$14(a0)

locret_13508:
		rts	
; End of function Sonic_SlopeResist

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope	while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_RollRepel:			; XREF: Obj01_MdRoll
		rts	
; End of function Sonic_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to	push Sonic down	a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_SlopeRepel:			; XREF: Obj01_MdNormal; Obj01_MdRoll
		nop	
		tst.b	$38(a0)
		bne.s	locret_13580
		tst.w	$2E(a0)
		bne.s	locret_13580
		move.b	$26(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_13580
		move.w	$14(a0),d0
		bpl.s	loc_1356A
		neg.w	d0

loc_1356A:
		cmpi.w	#$280,d0
		bcc.s	locret_13580
		clr.w	$14(a0)
		bset	#1,$22(a0)
		move.w	#$1E,$2E(a0)

locret_13580:
		rts	
; ===========================================================================

loc_13582:
		rts	
; End of function Sonic_SlopeRepel

; ---------------------------------------------------------------------------
; Subroutine to	return Sonic's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_JumpAngle:			; XREF: Obj01_MdAir; Obj01_MdJump
		move.b	$26(a0),d0	; get Sonic's angle
		beq.s	locret_135A2	; if already 0,	branch
		bpl.s	loc_13598	; if higher than 0, branch

		addq.b	#2,d0		; increase angle
		bcc.s	loc_13596
		moveq	#0,d0

loc_13596:
		bra.s	loc_1359E
; ===========================================================================

loc_13598:
		subq.b	#2,d0		; decrease angle
		bcc.s	loc_1359E
		moveq	#0,d0

loc_1359E:
		move.b	d0,$26(a0)

locret_135A2:
		rts	
; End of function Sonic_JumpAngle

; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with	the floor after	jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Floor:				; XREF: Obj01_MdAir; Obj01_MdJump
		move.w	$10(a0),d1
		move.w	$12(a0),d2
		jsr	(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_13680
		cmpi.b	#$80,d0
		beq.w	loc_136E2
		cmpi.b	#-$40,d0
		beq.w	loc_1373E
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_135F0
		sub.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_135F0:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13602
		add.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_13602:
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_1367E
		move.b	$12(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361E
		cmp.b	d2,d0
		blt.s	locret_1367E

loc_1361E:
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,$1C(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365C
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364E
		asr	$12(a0)
		bra.s	loc_13670
; ===========================================================================

loc_1364E:
		move.w	#0,$12(a0)
		move.w	$10(a0),$14(a0)
		rts	
; ===========================================================================

loc_1365C:
		move.w	#0,$10(a0)
		cmpi.w	#$FC0,$12(a0)
		ble.s	loc_13670
		move.w	#$FC0,$12(a0)

loc_13670:
		move.w	$12(a0),$14(a0)
		tst.b	d3
		bpl.s	locret_1367E
		neg.w	$14(a0)

locret_1367E:
		rts	
; ===========================================================================

loc_13680:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_1369A
		sub.w	d1,8(a0)
		move.w	#0,$10(a0)
		move.w	$12(a0),$14(a0)
		rts	
; ===========================================================================

loc_1369A:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_136B4
		sub.w	d1,$C(a0)
		tst.w	$12(a0)
		bpl.s	locret_136B2
		move.w	#0,$12(a0)

locret_136B2:
		rts	
; ===========================================================================

loc_136B4:
		tst.w	$12(a0)
		bmi.s	locret_136E0
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_136E0
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,$1C(a0)
		move.w	#0,$12(a0)
		move.w	$10(a0),$14(a0)

locret_136E0:
		rts	
; ===========================================================================

loc_136E2:
		bsr.w	Sonic_HitWall
		tst.w	d1
		bpl.s	loc_136F4
		sub.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_136F4:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13706
		add.w	d1,8(a0)
		move.w	#0,$10(a0)

loc_13706:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	locret_1373C
		sub.w	d1,$C(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_13726
		move.w	#0,$12(a0)
		rts	
; ===========================================================================

loc_13726:
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.w	$12(a0),$14(a0)
		tst.b	d3
		bpl.s	locret_1373C
		neg.w	$14(a0)

locret_1373C:
		rts	
; ===========================================================================

loc_1373E:
		bsr.w	sub_14EB4
		tst.w	d1
		bpl.s	loc_13758
		add.w	d1,8(a0)
		move.w	#0,$10(a0)
		move.w	$12(a0),$14(a0)
		rts	
; ===========================================================================

loc_13758:
		bsr.w	Sonic_DontRunOnWalls
		tst.w	d1
		bpl.s	loc_13772
		sub.w	d1,$C(a0)
		tst.w	$12(a0)
		bpl.s	locret_13770
		move.w	#0,$12(a0)

locret_13770:
		rts	
; ===========================================================================

loc_13772:
		tst.w	$12(a0)
		bmi.s	locret_1379E
		bsr.w	Sonic_HitFloor
		tst.w	d1
		bpl.s	locret_1379E
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		bsr.w	Sonic_ResetOnFloor
		move.b	#0,$1C(a0)
		move.w	#0,$12(a0)
		move.w	$10(a0),$14(a0)

locret_1379E:
		rts	
; End of function Sonic_Floor

; ---------------------------------------------------------------------------
; Subroutine to	reset Sonic's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_ResetOnFloor:			; XREF: PlatformObject; et al
		btst	#4,$22(a0)
		beq.s	loc_137AE
		nop	
		nop	
		nop	

loc_137AE:
		bclr	#5,$22(a0)
		bclr	#1,$22(a0)
		bclr	#4,$22(a0)
		btst	#2,$22(a0)
		beq.s	loc_137E4
		bclr	#2,$22(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		move.b	#0,$1C(a0)	; use running/walking animation

loc_137E4:
		move.b	#0,$3C(a0)
		move.w	#0,(Chain_Bonus_Counter).w
		rts	
; End of function Sonic_ResetOnFloor

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	when he	gets hurt
; ---------------------------------------------------------------------------

Obj01_Hurt:				; XREF: Obj01_Index
		jsr	ObjectMove
		addi.w	#$30,$12(a0)
		btst	#6,$22(a0)
		beq.s	loc_1380C
		subi.w	#$20,$12(a0)

loc_1380C:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HurtStop:				; XREF: Obj01_Hurt
		move.w	(Camera_Max_Y_Pos).w,d0
		addi.w	#$E0,d0
		cmp.w	$C(a0),d0
		bcs.w	KillSonic
		bsr.w	Sonic_Floor
		btst	#1,$22(a0)
		bne.s	locret_13860
		moveq	#0,d0
		move.w	d0,$12(a0)
		move.w	d0,$10(a0)
		move.w	d0,$14(a0)
		move.b	#0,$1C(a0)
		subq.b	#2,$24(a0)
		move.w	#$78,$30(a0)

locret_13860:
		rts	
; End of function Sonic_HurtStop

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Obj01_Death:				; XREF: Obj01_Index
		move.b	#$18,$1C(a0)
		bsr.w	GameOver
		jsr	ObjectMoveAndFall
		bsr.w	Sonic_RecordPos
		bsr.w	Sonic_Animate
		bsr.w	LoadSonicDynPLC
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GameOver:				; XREF: Obj01_Death
		move.w	(Camera_Y_Pos).w,d0
		addi.w	#$100,d0
		cmp.w	$C(a0),d0
		bpl.w	locret_13900
		move.w	#-$38,$12(a0)
		addq.b	#2,$24(a0)
		move.w	#0,(Shield_Flag).w
		clr.b	(Update_HUD_Timer).w	; stop time counter
		addq.b	#1,(Update_HUD_Lives).w ; update lives	counter
		subq.b	#1,(Life_Count).w ; subtract 1 from number of lives
		bne.s	loc_138D4
		move.w	#0,$3A(a0)
		move.b	#$39,(Object_Space_3).w ; load GAME object
		move.b	#$39,(Object_Space_4).w ; load OVER object
		move.b	#1,(Object_Space_4+$1A).w ; set OVER object to correct frame
		clr.b	(Time_Over_Flag).w
		move.w	#MusID_GameOver,d0
		jsr	(PlaySound).l	; play game over music
		moveq	#3,d0
		jmp	(LoadPLC).l	; load game over patterns
; ===========================================================================

loc_138D4:
		move.w	#60,$3A(a0)	; set time delay to 1 second
		tst.b	(Time_Over_Flag).w	; is TIME OVER tag set?
		beq.s	locret_13900	; if not, branch
		move.w	#0,$3A(a0)
		move.b	#$39,(Object_Space_3).w ; load TIME object
		move.b	#$39,(Object_Space_4).w ; load OVER object
		move.b	#2,(Object_Space_3+$1A).w
		move.b	#3,(Object_Space_4+$1A).w
		move.w	#MusID_GameOver,d0
		jsr	(PlaySound).l	; play game over music
		moveq	#$20,d0
		jmp	(LoadPLC).l	; load game over patterns
; ===========================================================================

locret_13900:
		rts	
; End of function GameOver

; ===========================================================================
; ---------------------------------------------------------------------------
; Sonic	when the level is restarted
; ---------------------------------------------------------------------------

Obj01_ResetLevel:			; XREF: Obj01_Index
		tst.w	$3A(a0)
		beq.s	locret_13914
		subq.w	#1,$3A(a0)	; subtract 1 from time delay
		bne.s	locret_13914
		clr.w	(Ring_Count).w
		clr.b	(Extra_Life_Flags).w
		move.b	#5,$1C(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.w	#0,$14(a0)
		move.b	#2,$22(a0)
		move.w	#0,$2E(a0)
		move.w	#0,$3A(a0)
		move.w	#1,(Level_Inactive_Flag).w ; restart the level

locret_13914:
		rts	

; ---------------------------------------------------------------------------
; Sonic when he's drowning
; ---------------------------------------------------------------------------
 
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
 
 
Obj01_Drowned:
        bsr.w   ObjectMove              ; Make Sonic able to move
        addi.w  #$10,$12(a0)          ; Apply gravity
        bsr.w   Sonic_RecordPos    ; Record position
        bsr.s   Sonic_Animate           ; Animate Sonic
        bsr.w   LoadSonicDynPLC           ; Load Sonic's DPLCs
        bra.w   DisplaySprite           ; And finally, display Sonic

; ---------------------------------------------------------------------------
; Subroutine to	animate	Sonic's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Animate:				; XREF: Obj01_Control; et al
		lea	(SonicAniData).l,a1
		moveq	#0,d0
		move.b	$1C(a0),d0
		cmp.b	$1D(a0),d0	; is animation set to restart?
		beq.s	SAnim_Do	; if not, branch
		move.b	d0,$1D(a0)	; set to "no restart"
		move.b	#0,$1B(a0)	; reset	animation
		move.b	#0,$1E(a0)	; reset	frame durations

SAnim_Do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation	script
		move.b	(a1),d0
		bmi.s	SAnim_WalkRun	; if animation is walk/run/roll/jump, branch
		move.b	$22(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	SAnim_Delay	; if time remains, branch
		move.b	d0,$1E(a0)	; load frame duration

SAnim_Do2:
		moveq	#0,d1
		move.b	$1B(a0),d1	; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		bmi.s	SAnim_End_FF	; if animation is complete, branch

SAnim_Next:
		move.b	d0,$1A(a0)	; load sprite number
		addq.b	#1,$1B(a0)	; next frame number

SAnim_Delay:
		rts	
; ===========================================================================

SAnim_End_FF:
		addq.b	#1,d0		; is the end flag = $FF	?
		bne.s	SAnim_End_FE	; if not, branch
		move.b	#0,$1B(a0)	; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	SAnim_Next
; ===========================================================================

SAnim_End_FE:
		addq.b	#1,d0		; is the end flag = $FE	?
		bne.s	SAnim_End_FD	; if not, branch
		move.b	2(a1,d1.w),d0	; read the next	byte in	the script
		sub.b	d0,$1B(a0)	; jump back d0 bytes in	the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	SAnim_Next
; ===========================================================================

SAnim_End_FD:
		addq.b	#1,d0		; is the end flag = $FD	?
		bne.s	SAnim_End	; if not, branch
		move.b	2(a1,d1.w),$1C(a0) ; read next byte, run that animation

SAnim_End:
		rts	
; ===========================================================================

SAnim_WalkRun:				; XREF: SAnim_Do
		subq.b	#1,$1E(a0)	; subtract 1 from frame	duration
		bpl.s	SAnim_Delay	; if time remains, branch
		addq.b	#1,d0		; is animation walking/running?
		bne.w	SAnim_RollJump	; if not, branch
		moveq	#0,d1
		move.b	$26(a0),d0	; get Sonic's angle
		bmi.s	@ZeroOrNeg
		beq.s	@ZeroOrNeg
		subq.b	#1,d0
		
@ZeroOrNeg:
		move.b	$22(a0),d2
		andi.b	#1,d2		; is Sonic mirrored horizontally?
		bne.s	loc_13A70	; if yes, branch
		not.b	d0		; reverse angle

loc_13A70:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	loc_13A78	; if angle is $-$7F, branch
		moveq	#3,d1

loc_13A78:
		andi.b	#$FC,1(a0)
		eor.b	d1,d2
		or.b	d2,1(a0)
		btst	#5,$22(a0)
		bne.w	SAnim_Push
		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle	must be	0, 2, 4	or 6
		move.w	$14(a0),d2	; get Sonic's speed
		bpl.s	loc_13A9C
		neg.w	d2

loc_13A9C:
		lea	(SonAni_Crawl).l,a1 ; use crawling animation
		tst.b	crawling(a0)
		bne.s	loc_13AB4
		lea	(SonAni_Run).l,a1 ; use	running	animation
		cmpi.w	#$600,d2	; is Sonic at running speed?
		bcc.s	loc_13AB4	; if yes, branch
		lea	(SonAni_Walk).l,a1 ; use walking animation
		move.b	d0,d1
		lsr.b	#1,d1
		add.b	d1,d0

loc_13AB4:
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	loc_13AC2
		moveq	#0,d2

loc_13AC2:
		lsr.w	#8,d2
		move.b	d2,$1E(a0)	; modify frame duration
		bsr.w	SAnim_Do2
		add.b	d3,$1A(a0)	; modify frame number
		rts	
; ===========================================================================

SAnim_RollJump:				; XREF: SAnim_WalkRun
		addq.b	#1,d0		; is animation rolling/jumping?
		bne.s	SAnim_Push	; if not, branch
		move.w	$14(a0),d2	; get Sonic's speed
		bpl.s	loc_13ADE
		neg.w	d2

loc_13ADE:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	loc_13AFA
		moveq	#0,d2

loc_13AFA:
		lsr.w	#8,d2
		move.b	d2,$1E(a0)	; modify frame duration
		move.b	$22(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	SAnim_Do2
; ===========================================================================

SAnim_Push:				; XREF: SAnim_RollJump
		move.w	$14(a0),d2	; get Sonic's speed
		bmi.s	loc_13B1E
		neg.w	d2

loc_13B1E:
		addi.w	#$800,d2
		bpl.s	loc_13B26
		moveq	#0,d2

loc_13B26:
		lsr.w	#6,d2
		move.b	d2,$1E(a0)	; modify frame duration
		lea	(SonAni_Push).l,a1
		move.b	$22(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,1(a0)
		or.b	d1,1(a0)
		bra.w	SAnim_Do2
; End of function Sonic_Animate

; ===========================================================================
SonicAniData:
	include "objects/animation/Sonic.asm"

; ---------------------------------------------------------------------------
; Sonic	pattern	loading	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadSonicDynPLC:			; XREF: Obj01_Control; et al
		moveq	#0,d0
		move.b	$1A(a0),d0	; load frame number
		cmp.b	(Sonic_Last_DPLC_Frame).w,d0
		beq.s	locret_13C96
		move.b	d0,(Sonic_Last_DPLC_Frame).w
		lea	(SonicDynPLC).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5
		subq.w	#1,d5
		bmi.s	locret_13C96
		move.w	#$F000,d4
		move.l	#Art_Sonic,d6

SPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	d6,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr	(QueueDMATransfer).l
		dbf	d5,SPLC_ReadEntry	; repeat for number of entries

locret_13C96:
		rts	
; End of function LoadSonicDynPLC

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 0A - drowning countdown numbers and small bubbles (LZ)
; ---------------------------------------------------------------------------

Obj0A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj0A_Index(pc,d0.w),d1
		jmp	Obj0A_Index(pc,d1.w)
; ===========================================================================
Obj0A_Index:
		dc.w Obj0A_Init-Obj0A_Index
		dc.w Obj0A_Animate-Obj0A_Index
		dc.w Obj0A_ChkWater-Obj0A_Index
		dc.w Obj0A_Display-Obj0A_Index
		dc.w Obj0A_Delete2-Obj0A_Index
		dc.w Obj0A_Countdown-Obj0A_Index
		dc.w Obj0A_AirLeft-Obj0A_Index
		dc.w Obj0A_Display-Obj0A_Index
		dc.w Obj0A_Delete2-Obj0A_Index
; ===========================================================================

Obj0A_Init:				; XREF: Obj0A_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj0A,4(a0)
		move.w	#$8348,2(a0)
		move.b	#$84,1(a0)
		move.b	#$10,$19(a0)
		move.b	#1,$18(a0)
		move.b	$28(a0),d0
		bpl.s	loc_13D00
		addq.b	#8,$24(a0)
		andi.w	#$7F,d0
		move.b	d0,$33(a0)
		bra.w	Obj0A_Countdown
; ===========================================================================

loc_13D00:
		move.b	d0,$1C(a0)
		move.w	8(a0),$30(a0)
		move.w	#-$88,$12(a0)

Obj0A_Animate:				; XREF: Obj0A_Index
		lea	(Ani_obj0A).l,a1
		jsr	AnimateSprite

Obj0A_ChkWater:				; XREF: Obj0A_Index
		move.w	(Water_Height).w,d0
		cmp.w	$C(a0),d0	; has bubble reached the water surface?
		bcs.s	Obj0A_Wobble	; if not, branch
		move.b	#6,$24(a0)
		addq.b	#7,$1C(a0)
		cmpi.b	#$D,$1C(a0)
		beq.s	Obj0A_Display
		blo.s	Obj0A_Display
		move.b	#$D,$1C(a0)
		bra.s	Obj0A_Display
; ===========================================================================

Obj0A_Wobble:
		tst.b	(Wind_Tunnel_Mode).w
		beq.s	loc_13D44
		addq.w	#4,$30(a0)

loc_13D44:
		move.b	$26(a0),d0
		addq.b	#1,$26(a0)
		andi.w	#$7F,d0
		lea	(Obj0A_WobbleData).l,a1
		move.b	(a1,d0.w),d0
		ext.w	d0
		add.w	$30(a0),d0
		move.w	d0,8(a0)
		bsr.s	Obj0A_ShowNumber
		jsr	ObjectMove
		tst.b	1(a0)
		bpl.s	Obj0A_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj0A_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj0A_DisplayNumber:
		lea	(Object_RAM).w,a2
		cmpi.b	#$C,$28(a2)
		bhi.s	Obj0A_Delete2

Obj0A_Display:				; XREF: Obj0A_Index
		bsr.s	Obj0A_ShowNumber
		lea	(Ani_obj0A).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj0A_Delete2:				; XREF: Obj0A_Index
		jmp	DeleteObject
; ===========================================================================

Obj0A_AirLeft:				; XREF: Obj0A_Index
		lea	(Object_RAM).w,a2
		cmpi.b	#$C,$28(a2)		; check air remaining
		bhi.s	Obj0A_Delete3	; if higher than $C, branch
		subq.w	#1,$38(a0)
		bne.s	Obj0A_Display2
		move.b	#$E,$24(a0)
		addq.b	#7,$1C(a0)
		bra.s	Obj0A_Display
; ===========================================================================

Obj0A_Display2:
		lea	(Ani_obj0A).l,a1
		jsr	AnimateSprite
		bsr.w	Obj0A_LoadCountdownArt
		tst.b	1(a0)
		bpl.s	Obj0A_Delete3
		jmp	DisplaySprite
; ===========================================================================

Obj0A_Delete3:
		jmp	DeleteObject
; ===========================================================================

Obj0A_ShowNumber:			; XREF: Obj0A_Wobble; Obj0A_Display
		tst.w	$38(a0)
		beq.s	locret_13E1A
		subq.w	#1,$38(a0)
		bne.s	locret_13E1A
		cmpi.b	#7,$1C(a0)
		bcc.s	locret_13E1A
		move.w	#$F,$38(a0)
		clr.w	$12(a0)
		move.b	#$80,1(a0)
		move.w	8(a0),d0
		sub.w	(Camera_X_Pos).w,d0
		addi.w	#$80,d0
		move.w	d0,8(a0)
		move.w	$C(a0),d0
		sub.w	(Camera_Y_Pos).w,d0
		addi.w	#$80,d0
		move.w	d0,$A(a0)
		move.b	#$C,$24(a0)

locret_13E1A:
		rts	
; ===========================================================================
Obj0A_WobbleData:
		dc.b  0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2
		dc.b  2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
		dc.b  3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2
		dc.b  2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0
		dc.b  0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-3,-3,-3,-3,-3
		dc.b -3,-3,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4
		dc.b -4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-4,-3
		dc.b -3,-3,-3,-3,-3,-3,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1
; ===========================================================================

Obj0A_LoadCountdownArt:
		moveq	#0,d1
		move.b	$1A(a0),d1
		cmpi.b	#8,d1
		blo.s	return_1D604
		cmpi.b	#$E,d1
		bhs.s	return_1D604
		cmp.b	$2E(a0),d1
		beq.s	return_1D604
		move.b	d1,$2E(a0)
		subq.w	#8,d1
		move.w	d1,d0
		add.w	d1,d1
		add.w	d0,d1
		lsl.w	#6,d1
		addi.l	#ArtUnc_Countdown,d1
		move.w	#$F400,d2
		move.w	#$60,d3
		jsr	(QueueDMATransfer).l

return_1D604:
	rts
; ===========================================================================

Obj0A_Countdown:			; XREF: Obj0A_Index
		lea	(Object_RAM).w,a2
		tst.w	$2C(a0)
		bne.w	loc_13F86
		cmpi.b	#6,$24(a2)
		bcc.w	locret_1408C
		btst	#6,$22(a2)
		beq.w	locret_1408C
		subq.w	#1,$38(a0)
		bpl.w	loc_13FAC
		move.w	#$3B,$38(a0)
		move.w	#1,$36(a0)
		jsr	(RandomNumber).l
		andi.w	#1,d0
		move.b	d0,$34(a0)
		move.b	$28(a2),d0 ; check air remaining
		cmpi.w	#$19,d0
		beq.s	Obj0A_WarnSound	; play sound if	air is $19
		cmpi.w	#$14,d0
		beq.s	Obj0A_WarnSound
		cmpi.w	#$F,d0
		beq.s	Obj0A_WarnSound
		cmpi.w	#$C,d0
		bhi.s	Obj0A_ReduceAir	; if air is above $C, branch
		subq.b	#1,$32(a0)
		bpl.s	Obj0A_ReduceAir
		move.b	$33(a0),$32(a0)
		bset	#7,$36(a0)
		bra.s	Obj0A_ReduceAir
; ===========================================================================

Obj0A_WarnSound:			; XREF: Obj0A_Countdown
		move.w	#SndID_DrownWarn,d0
		jsr	(PlaySound_Special).l ;	play "ding-ding" warning sound

Obj0A_ReduceAir:
		subq.b	#1,$28(a2) ; subtract 1 from air remaining
		bcc.w	Obj0A_GoMakeItem ; if air is above 0, branch
		bsr.w	StopDrowning
		move.b	#$81,(No_Player_Physics_Flag).w ; lock controls
		move.w	#SndID_Drown,d0
		jsr	(PlaySound_Special).l ;	play drowning sound
		move.b	#$A,$34(a0)
		move.w	#1,$36(a0)
		move.w	#$78,$2C(a0)
		move.l	a0,-(sp)
		lea	(Object_RAM).w,a0
		bsr.w	Sonic_ResetOnFloor
		move.b	#$17,$1C(a0)	; use Sonic's drowning animation
		bset	#1,$22(a0)
		bset	#7,2(a0)
		move.w	#0,$12(a0)
		move.w	#0,$10(a0)
		move.w	#0,$14(a0)
		move.b  #$A,$24(a0)       ; Force the character to drown
		move.b	#1,(Deform_Lock).w
		move.b  #0,(Update_HUD_Timer).w      ; Stop the timer immediately
		move.b	#1,(No_Music_Ctrl).w
		movea.l	(sp)+,a0
		rts	
; ===========================================================================

loc_13F86:
		subq.w  #1,$2C(a0)
		bne.s   loc_13FAC                       ; Make it jump straight to this location
		move.b  #6,(Object_Space_1+$24).w
		rts
; ===========================================================================

Obj0A_GoMakeItem:			; XREF: Obj0A_ReduceAir
		bra.s	Obj0A_MakeItem
; ===========================================================================

loc_13FAC:
		tst.w	$36(a0)
		beq.w	locret_1408C
		subq.w	#1,$3A(a0)
		bpl.w	locret_1408C

Obj0A_MakeItem:
		jsr	(RandomNumber).l
		andi.w	#$F,d0
		addq.w	#8,d0
		move.w	d0,$3A(a0)
		jsr	SingleObjLoad
		bne.w	locret_1408C
		move.b	0(a0),0(a1)	; load object
		move.w	8(a2),8(a1) ; match X position to Sonic
		moveq	#6,d0
		btst	#0,$22(a2)
		beq.s	loc_13FF2
		neg.w	d0
		move.b	#$40,$26(a1)

loc_13FF2:
		add.w	d0,8(a1)
		move.w	$C(a2),$C(a1)
		move.b	#6,$28(a1)
		tst.w	$2C(a0)
		beq.w	loc_1403E
		andi.w	#7,$3A(a0)
		addi.w	#0,$3A(a0)
		move.w	$C(a2),d0
		subi.w	#$C,d0
		move.w	d0,$C(a1)
		jsr	(RandomNumber).l
		move.b	d0,$26(a1)
		move.w	(Level_Timer).w,d0
		andi.b	#3,d0
		bne.s	loc_14082
		move.b	#$E,$28(a1)
		bra.s	loc_14082
; ===========================================================================

loc_1403E:
		btst	#7,$36(a0)
		beq.s	loc_14082
		moveq	#0,d2
		move.b	$28(a2),d2
		cmpi.b	#$C,d2
		bhs.s	loc_14082
		lsr.w	#1,d2
		jsr	(RandomNumber).l
		andi.w	#3,d0
		bne.s	loc_1406A
		bset	#6,$36(a0)
		bne.s	loc_14082
		move.b	d2,$28(a1)
		move.w	#$1C,$38(a1)

loc_1406A:
		tst.b	$34(a0)
		bne.s	loc_14082
		bset	#6,$36(a0)
		bne.s	loc_14082
		move.b	d2,$28(a1)
		move.w	#$1C,$38(a1)

loc_14082:
		subq.b	#1,$34(a0)
		bpl.s	locret_1408C
		clr.w	$36(a0)

locret_1408C:
		rts	

; ---------------------------------------------------------------------------
; Subroutine to stop drowning
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


StopDrowning:				; XREF: Obj64_Wobble; Sonic_Water; Obj0A_ReduceAir
		move.b	#$1E,(Object_Space_1+$28).w
		clr.b	(Object_Space_14+$32).w
		rts	
; End of function StopDrowning

; ===========================================================================
Ani_obj0A:
	include "objects/animation/obj0A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - drowning countdown numbers (LZ)
; ---------------------------------------------------------------------------
Map_obj0A:
	include "mappings/sprite/obj0A.asm"
; ===========================================================================
LoadShieldDPLC:
		move.l	#Art_Shield,d6
		bra.s	LoadShieldStarsDPLC
		
LoadStarsDPLC:
		move.l	#Art_Stars,d6

LoadShieldStarsDPLC:
		lea	(ShieldStarsDPLC).l,a2
		move.w	#$541*$20,d4
		jmp	LoadDPLC
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 38 - shield and invincibility stars
; ---------------------------------------------------------------------------

Obj38:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj38_Index(pc,d0.w),d1
		jmp	Obj38_Index(pc,d1.w)
; ===========================================================================
Obj38_Index:	dc.w Obj38_Main-Obj38_Index
		dc.w Obj38_Shield-Obj38_Index
		dc.w Obj38_Stars-Obj38_Index
; ===========================================================================

Obj38_Main:				; XREF: Obj38_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj38,4(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$10,$19(a0)
		move.w	#$541,2(a0)	; shield specific code
		tst.b	$1C(a0)		; is object a shield?
		bne.s	Obj38_DoStars	; if not, branch
		rts	
; ===========================================================================

Obj38_DoStars:
		addq.b	#2,$24(a0)	; stars	specific code
		rts	
; ===========================================================================

Obj38_Shield:				; XREF: Obj38_Index
		tst.b	(Invincibility_Flag).w	; does Sonic have invincibility?
		bne.s	Obj38_RmvShield	; if yes, branch
		tst.b	(Shield_Flag).w	; does Sonic have shield?
		beq.s	Obj38_Delete	; if not, branch
		move.w	(Object_Space_1+8).w,8(a0)
		move.w	(Object_Space_1+$C).w,$C(a0)
		move.b	(Object_Space_1+$22).w,$22(a0)
		lea	(Ani_obj38).l,a1
		jsr	AnimateSprite
		jsr	LoadShieldDPLC
		jmp	DisplaySprite
; ===========================================================================

Obj38_RmvShield:
		rts	
; ===========================================================================

Obj38_Delete:
		jmp	DeleteObject
; ===========================================================================

Obj38_Stars:				; XREF: Obj38_Index
		tst.b	(Invincibility_Flag).w	; does Sonic have invincibility?
		beq.s	Obj38_Delete2	; if not, branch
		move.w	(Sonic_Pos_Record_Index).w,d0
		move.b	$1C(a0),d1
		subq.b	#1,d1
		bra.s	Obj38_StarTrail
; ===========================================================================
		lsl.b	#4,d1
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0
		addq.b	#4,d1
		andi.b	#$F,d1
		move.b	d1,$30(a0)
		bra.s	Obj38_StarTrail2a
; ===========================================================================

Obj38_StarTrail:			; XREF: Obj38_Stars
		lsl.b	#3,d1
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	$30(a0),d1
		sub.b	d1,d0
		addq.b	#4,d1
		cmpi.b	#$18,d1
		bcs.s	Obj38_StarTrail2
		moveq	#0,d1

Obj38_StarTrail2:
		move.b	d1,$30(a0)

Obj38_StarTrail2a:
		lea	(Sonic_Pos_Record_Buf).w,a1
		lea	(a1,d0.w),a1
		move.w	(a1)+,8(a0)
		move.w	(a1)+,$C(a0)
		move.b	(Object_Space_1+$22).w,$22(a0)
		lea	(Ani_obj38).l,a1
		jsr	AnimateSprite
		jsr	LoadStarsDPLC
		jmp	DisplaySprite
; ===========================================================================

Obj38_Delete2:				; XREF: Obj38_Stars
		jmp	DeleteObject
; ===========================================================================
	
ShieldStarsDPLC:
		include "mappings/DPLC/obj38.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 4A - special stage entry from beta
; ---------------------------------------------------------------------------

Obj4A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj4A_Index(pc,d0.w),d1
		jmp	Obj4A_Index(pc,d1.w)
; ===========================================================================
Obj4A_Index:	dc.w Obj4A_Main-Obj4A_Index
		dc.w Obj4A_RmvSonic-Obj4A_Index
		dc.w Obj4A_LoadSonic-Obj4A_Index
; ===========================================================================

Obj4A_Main:				; XREF: Obj4A_Index
		tst.l	(PLC_Buffer).w	; are pattern load cues	empty?
		beq.s	Obj4A_Main2	; if yes, branch
		rts	
; ===========================================================================

Obj4A_Main2:
		addq.b	#2,$24(a0)
		move.l	#Map_obj4A,4(a0)
		move.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$38,$19(a0)
		move.w	#$541,2(a0)
		move.w	#120,$30(a0)	; set time for Sonic's disappearance to 2 seconds

Obj4A_RmvSonic:				; XREF: Obj4A_Index
		move.w	(Object_Space_1+8).w,8(a0)
		move.w	(Object_Space_1+$C).w,$C(a0)
		move.b	(Object_Space_1+$22).w,$22(a0)
		lea	(Ani_obj4A).l,a1
		jsr	AnimateSprite
		cmpi.b	#2,$1A(a0)
		bne.s	Obj4A_Display
		tst.b	(Object_RAM).w
		beq.s	Obj4A_Display
		move.b	#0,(Object_RAM).w ; remove Sonic
		move.w	#SndID_SSGoal,d0
		jsr	(PlaySound_Special).l ;	play Special Stage "GOAL" sound

Obj4A_Display:
		jmp	DisplaySprite
; ===========================================================================

Obj4A_LoadSonic:			; XREF: Obj4A_Index
		subq.w	#1,$30(a0)	; subtract 1 from time
		bne.s	Obj4A_Wait	; if time remains, branch
		move.b	#1,(Object_RAM).w ; load	Sonic object
		jmp	DeleteObject
; ===========================================================================

Obj4A_Wait:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)
; ---------------------------------------------------------------------------

Obj08:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj08_Index(pc,d0.w),d1
		jmp	Obj08_Index(pc,d1.w)
; ===========================================================================
Obj08_Index:	dc.w Obj08_Main-Obj08_Index
		dc.w Obj08_Display-Obj08_Index
		dc.w Obj08_Delete-Obj08_Index
; ===========================================================================

Obj08_Main:				; XREF: Obj08_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj08,4(a0)
		ori.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$10,$19(a0)
		move.w	#$4259,2(a0)
		move.w	(Object_Space_1+8).w,8(a0) ; copy x-position from Sonic

Obj08_Display:				; XREF: Obj08_Index
		move.w	(Water_Height).w,$C(a0) ; copy y-position from water height
		lea	(Ani_obj08).l,a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================

Obj08_Delete:				; XREF: Obj08_Index
		jmp	DeleteObject	; delete when animation	is complete
; ===========================================================================
Ani_obj38:
	include "objects/animation/obj38.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - shield and invincibility stars
; ---------------------------------------------------------------------------
Map_obj38:
	include "mappings/sprite/obj38.asm"

Ani_obj4A:
	include "objects/animation/obj4A.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - special stage entry	from beta
; ---------------------------------------------------------------------------
Map_obj4A:
	include "mappings/sprite/obj4A.asm"

Ani_obj08:
	include "objects/animation/obj08.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - water splash (LZ)
; ---------------------------------------------------------------------------
Map_obj08:
	include "mappings/sprite/obj08.asm"






; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle & position as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Sonic_AnglePos:				; XREF: Obj01_MdNormal; Obj01_MdRoll
		move.l	(First_Collision_Addr).w,(Collision_Addr).w		; MJ: load first collision data location
		tst.b	(Sonic_Current_Coll_Layer).w				; MJ: is second sollision set to be used?
		beq.s	SAP_First				; MJ: if not, branch
		move.l	(Second_Collision_Addr).w,(Collision_Addr).w		; MJ: load second collision data location

SAP_First:
		btst	#3,$22(a0)
		beq.s	loc_14602
		moveq	#0,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		rts	
; ===========================================================================

loc_14602:
		moveq	#3,d0
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	$26(a0),d0
		addi.b	#$20,d0
		bpl.s	loc_14624
		move.b	$26(a0),d0
		bpl.s	loc_1461E
		subq.b	#1,d0

loc_1461E:
		addi.b	#$20,d0
		bra.s	loc_14630
; ===========================================================================

loc_14624:
		move.b	$26(a0),d0
		bpl.s	loc_1462C
		addq.b	#1,d0

loc_1462C:
		addi.b	#$1F,d0

loc_14630:
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	Sonic_WalkVertL
		cmpi.b	#$80,d0
		beq.w	Sonic_WalkCeiling
		cmpi.b	#$C0,d0
		beq.w	Sonic_WalkVertR
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_146BE
		bpl.s	loc_146C0
		cmpi.w	#-$E,d1
		blt.s	locret_146E6
		add.w	d1,$C(a0)

locret_146BE:
		rts	
; ===========================================================================

loc_146C0:
		cmpi.w	#$E,d1
		bgt.s	loc_146CC

loc_146C6:
		add.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_146CC:
		tst.b	$38(a0)
		bne.s	loc_146C6
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts	
; ===========================================================================

locret_146E6:
		rts	
; End of function Sonic_AnglePos

; ===========================================================================
		move.l	8(a0),d2
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.l	d2,8(a0)
		move.w	#$38,d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		rts	
; ===========================================================================

locret_1470A:
		rts	
; ===========================================================================
		move.l	$C(a0),d3
		move.w	$12(a0),d0
		subi.w	#$38,d0
		move.w	d0,$12(a0)
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,$C(a0)
		rts	
		rts	
; ===========================================================================
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d2,8(a0)
		move.l	d3,$C(a0)
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	change Sonic's angle as he walks along the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Angle:				; XREF: Sonic_AnglePos; et al
		move.b	(Secondary_Angle).w,d2
		cmp.w	d0,d1
		ble.s	loc_1475E
		move.b	(Primary_Angle).w,d2
		move.w	d0,d1

loc_1475E:
		btst	#0,d2
		bne.s	loc_1476A
		move.b	d2,$26(a0)
		rts	
; ===========================================================================

loc_1476A:
		move.b	$26(a0),d2
		addi.b	#$20,d2
		andi.b	#$C0,d2
		move.b	d2,$26(a0)
		rts	
; End of function Sonic_Angle

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertR:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_147F0
		bpl.s	loc_147F2
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		add.w	d1,8(a0)

locret_147F0:
		rts	
; ===========================================================================

loc_147F2:
		cmpi.w	#$E,d1
		bgt.s	loc_147FE

loc_147F8:
		add.w	d1,8(a0)
		rts	
; ===========================================================================

loc_147FE:
		tst.b	$38(a0)
		bne.s	loc_147F8
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts	
; End of function Sonic_WalkVertR

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk upside-down
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkCeiling:			; XREF: Sonic_AnglePos
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14892
		bpl.s	loc_14894
		cmpi.w	#-$E,d1
		blt.w	locret_146E6
		sub.w	d1,$C(a0)

locret_14892:
		rts	
; ===========================================================================

loc_14894:
		cmpi.w	#$E,d1
		bgt.s	loc_148A0

loc_1489A:
		sub.w	d1,$C(a0)
		rts	
; ===========================================================================

loc_148A0:
		tst.b	$38(a0)
		bne.s	loc_1489A
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts	
; End of function Sonic_WalkCeiling

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk up a vertical slope/wall to	his left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkVertL:
		move.w	$C(a0),d2				; MJ: Load Y position
		move.w	8(a0),d3				; MJ: Load X position
		moveq	#0,d0					; MJ: clear d0
		move.b	$17(a0),d0				; MJ: load height
		ext.w	d0					; MJ: set left byte pos or neg
		sub.w	d0,d2					; MJ: subtract from Y position
		move.b	$16(a0),d0				; MJ: load width
		ext.w	d0					; MJ: set left byte pos or neg
		sub.w	d0,d3					; MJ: subtract from X position
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4			; MJ: load address of the angle value set
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	(sp)+,d0
		bsr.w	Sonic_Angle
		tst.w	d1
		beq.s	locret_14934
		bpl.s	loc_14936
		cmpi.w	#-$E,d1
		blt.w	locret_1470A
		sub.w	d1,8(a0)

locret_14934:
		rts

; ===========================================================================

loc_14936:
		cmpi.w	#$E,d1
		bgt.s	loc_14942

loc_1493C:
		sub.w	d1,8(a0)
		rts	

; ===========================================================================

loc_14942:
		tst.b	$38(a0)
		bne.s	loc_1493C
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts	
; End of function Sonic_WalkVertL

; ---------------------------------------------------------------------------
; Subroutine to	find which tile	the object is standing on
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

Floor_ChkTile:				; XREF: FindFloor; et al
		move.w	d2,d0					; MJ: load Y position
		andi.w	#$780,d0				; MJ: get within 780 (E00 pixels) in multiples of 80
		add.w	d0,d0					; MJ: multiply by 2
		move.w	d3,d1					; MJ: load X position
		lsr.w	#7,d1					; MJ: shift to right side
		andi.w	#$07F,d1				; MJ: get within 7F
		add.w	d1,d0					; MJ: add calc'd Y to calc'd X
		moveq	#-1,d1					; MJ: prepare FFFF in d3
		movea.l	(Level_Layout_FG).w,a1			; MJ: load address of Layout to a1
		move.b	(a1,d0.w),d1				; MJ: collect correct chunk ID based on the X and Y position
		andi.w	#$FF,d1					; MJ: keep within FF
		lsl.w	#$7,d1					; MJ: multiply by 80
		move.w	d2,d0					; MJ: load Y position
		andi.w	#$070,d0				; MJ: keep Y within 80 pixels
		add.w	d0,d1					; MJ: add to ror'd chunk ID
		move.w	d3,d0					; MJ: load X position
		lsr.w	#3,d0					; MJ: divide by 8
		andi.w	#$00E,d0				; MJ: keep X within 10 pixels
		add.w	d0,d1					; MJ: add to ror'd chunk ID

loc_14996:
		movea.l	d1,a1					; MJ: set address (Chunk to read)
		rts						; MJ: return
; ===========================================================================

loc_1499A:
		andi.w	#$7F,d1
		btst	#6,1(a0)
		beq.s	loc_149B2
		addq.w	#1,d1
		cmpi.w	#$29,d1
		bne.s	loc_149B2
		move.w	#$51,d1

loc_149B2:
		ror.w	#7,d1
		ror.w	#2,d1
		move.w	d2,d0
		add.w	d0,d0
		andi.w	#$70,d0
		add.w	d0,d1
		move.w	d3,d0
		lsr.w	#3,d0
		andi.w	#$E,d0
		add.w	d0,d1
		movea.l	d1,a1
		rts
; End of function Floor_ChkTile


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ColisionChkLayer:
		tst.b	(Sonic_Current_Coll_Layer).w				; MJ: is collision set to first?
		beq.s	CCL_NoChange				; MJ: if so, branch
		move.w	d0,d4					; MJ: load block ID to d4
		and.w	#$FFF,d0				; MJ: clear solid settings of d0
		and.w	#$C000,d4				; MJ: get only second solid settings of d4
		lsr.w	#$2,d4					; MJ: shift them to first solid settings location
		add.w	d4,d0					; MJ: add to rest of block ID

CCL_NoChange:
		rts						; MJ: return


FindFloor:
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		bsr.s	ColisionChkLayer			; MJ: check solid settings to use
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_149DE
		btst	d5,d4
		bne.s	loc_149EC

loc_149DE:
		add.w	a3,d2
		bsr.w	FindFloor2
		sub.w	a3,d2
		addi.w	#$10,d1
		rts	
; ===========================================================================

loc_149EC:
		movea.l	(Collision_Addr).w,a2			; MJ: load collision index address
		move.b	(a2,d0.w),d0				; MJ: load correct Collision ID based on the Block ID
		andi.w	#$FF,d0					; MJ: clear the left byte
		beq.s	loc_149DE				; MJ: if collision ID is 00, branch
		lea	(AngleMap).l,a2				; MJ: load angle map data to a2
		move.b	(a2,d0.w),(a4)				; MJ: collect correct angle based on the collision ID
		lsl.w	#4,d0					; MJ: multiply collision ID by 10
		move.w	d3,d1					; MJ: load X position
		btst	#$A,d4					; MJ: is the block mirrored?
		beq.s	loc_14A12				; MJ: if not, branch
		not.w	d1					; MJ: reverse bits of the X position
		neg.b	(a4)					; MJ: reverse the angle ID

loc_14A12:
		btst	#$B,d4					; MJ: is the block flipped?
		beq.s	loc_14A22				; MJ: if not, branch
		addi.b	#$40,(a4)				; MJ: increase angle ID by 40..
		neg.b	(a4)					; MJ: ..reverse the angle ID..
		subi.b	#$40,(a4)				; MJ: ..and subtract 40 again 

loc_14A22:
		andi.w	#$F,d1					; MJ: get only within 10 (d1 is pixel based on the collision block)
		add.w	d0,d1					; MJ: add collision ID (x10) (d0 is the collision block being read)
		lea	(CollArray1).l,a2			; MJ: load collision array
		move.b	(a2,d1.w),d0				; MJ: load solid value
		ext.w	d0					; MJ: clear left byte
		eor.w	d6,d4					; MJ: set ceiling/wall bits
		btst	#$B,d4					; MJ: is sonic walking on the left wall?
		beq.s	loc_14A3E				; MJ: if not, branch
		neg.w	d0					; MJ: reverse solid value

loc_14A3E:
		tst.w	d0					; MJ: is the solid data null?
		beq.s	loc_149DE				; MJ: if so, branch
		bmi.s	loc_14A5A				; MJ: if it's negative, branch
		cmpi.b	#$10,d0					; MJ: is it 10?
		beq.s	loc_14A66				; MJ: if so, branch
		move.w	d2,d1					; MJ: load Y position
		andi.w	#$F,d1					; MJ: get only within 10 pixels
		add.w	d1,d0					; MJ: add to solid value
		move.w	#$F,d1					; MJ: set F
		sub.w	d0,d1					; MJ: minus solid value from F
		rts			; d1 = position?	; MJ: return

; ===========================================================================

loc_14A5A:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_149DE

loc_14A66:
		sub.w	a3,d2
		bsr.w	FindFloor2
		add.w	a3,d2
		subi.w	#$10,d1
		rts	
; End of function FindFloor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindFloor2:				; XREF: FindFloor
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		bsr.w	ColisionChkLayer			; MJ: check solid settings to use
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_14A86
		btst	d5,d4
		bne.s	loc_14A94

loc_14A86:
		move.w	#$F,d1
		move.w	d2,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts	
; ===========================================================================

loc_14A94:
		movea.l	(Collision_Addr).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_14A86
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4					; MJ: B to A (because S2 format has two solids)
		beq.s	loc_14ABA
		not.w	d1
		neg.b	(a4)

loc_14ABA:
		btst	#$B,d4					; MJ: C to B (because S2 format has two solids)
		beq.s	loc_14ACA
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_14ACA:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray1).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4					; MJ: C to B (because S2 format has two solids)
		beq.s	loc_14AE6
		neg.w	d0

loc_14AE6:
		tst.w	d0
		beq.s	loc_14A86
		bmi.s	loc_14AFC
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts	
; ===========================================================================

loc_14AFC:
		move.w	d2,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_14A86
		not.w	d1
		rts	
; End of function FindFloor2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindWall:
		bsr.w	Floor_ChkTile				; MJ: get chunk/block location
		move.w	(a1),d0					; MJ: load block ID from chunk
		bsr.w	ColisionChkLayer			; MJ: check solid settings to use
		move.w	d0,d4					; MJ: copy to d4
		andi.w	#$3FF,d0				; MJ: clear flip/mirror/etc data
		beq.s	loc_14B1E				; MJ: if it was null, branch
		btst	d5,d4					; MJ: check solid set (C top solid | D Left/right solid)
		bne.s	loc_14B2C				; MJ: if the specific solid is set, branch

loc_14B1E:
		add.w	a3,d3					; MJ: add 10 to X position
		bsr.w	FindWall2
		sub.w	a3,d3					; MJ: minus 10 from X position
		addi.w	#$10,d1
		rts	
; ===========================================================================

loc_14B2C:
		movea.l	(Collision_Addr).w,a2			; MJ: load address of collision for level
		move.b	(a2,d0.w),d0				; MJ: load correct colision ID based on the block ID
		andi.w	#$FF,d0					; MJ: keep within FF
		beq.s	loc_14B1E				; MJ: if it's null, branch
		lea	(AngleMap).l,a2				; MJ: load angle map data to a2
		move.b	(a2,d0.w),(a4)				; MJ: load angle set location based on collision ID
		lsl.w	#4,d0					; MJ: multiply by 10
		move.w	d2,d1					; MJ: load Y position
		btst	#$B,d4					; MJ: is the block ID flipped?
		beq.s	loc_14B5A				; MJ: if not, branch
		not.w	d1
		addi.b	#$40,(a4)				; MJ: increase angle set by 40
		neg.b	(a4)					; MJ: negate to opposite
		subi.b	#$40,(a4)				; MJ: decrease angle set by 40

loc_14B5A:
		btst	#$A,d4					; MJ: is the block ID mirrored?
		beq.s	loc_14B62				; MJ: if not, branch
		neg.b	(a4)					; MJ: negate to opposite

loc_14B62:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4					; MJ: B to A (because S2 format has two solids)
		beq.s	loc_14B7E
		neg.w	d0

loc_14B7E:
		tst.w	d0
		beq.s	loc_14B1E
		bmi.s	loc_14B9A
		cmpi.b	#$10,d0
		beq.s	loc_14BA6
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts	
; ===========================================================================

loc_14B9A:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_14B1E

loc_14BA6:
		sub.w	a3,d3
		bsr.w	FindWall2
		add.w	a3,d3
		subi.w	#$10,d1
		rts	
; End of function FindWall


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindWall2:				; XREF: FindWall
		bsr.w	Floor_ChkTile
		move.w	(a1),d0
		bsr.w	ColisionChkLayer			; MJ: check solid settings to use
		move.w	d0,d4
		andi.w	#$3FF,d0
		beq.s	loc_14BC6
		btst	d5,d4
		bne.s	loc_14BD4

loc_14BC6:
		move.w	#$F,d1
		move.w	d3,d0
		andi.w	#$F,d0
		sub.w	d0,d1
		rts	
; ===========================================================================

loc_14BD4:
		movea.l	(Collision_Addr).w,a2
		move.b	(a2,d0.w),d0
		andi.w	#$FF,d0
		beq.s	loc_14BC6
		lea	(AngleMap).l,a2
		move.b	(a2,d0.w),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4					; MJ: C to B (because S2 format has two solids)
		beq.s	loc_14C02
		not.w	d1
		addi.b	#$40,(a4)
		neg.b	(a4)
		subi.b	#$40,(a4)

loc_14C02:
		btst	#$A,d4					; MJ: B to A (because S2 format has two solids)
		beq.s	loc_14C0A
		neg.b	(a4)

loc_14C0A:
		andi.w	#$F,d1
		add.w	d0,d1
		lea	(CollArray2).l,a2
		move.b	(a2,d1.w),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4					; MJ: B to A (because S2 format has two solids)
		beq.s	loc_14C26
		neg.w	d0

loc_14C26:
		tst.w	d0
		beq.s	loc_14BC6
		bmi.s	loc_14C3C
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts	
; ===========================================================================

loc_14C3C:
		move.w	d3,d1
		andi.w	#$F,d1
		add.w	d1,d0
		bpl.w	loc_14BC6
		not.w	d1
		rts	
; End of function FindWall2

; ---------------------------------------------------------------------------
; Unused floor/wall subroutine - logs something	to do with collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FloorLog_Unk:				; XREF: Level
		rts	

		lea	(CollArray1).l,a1
		lea	(CollArray1).l,a2
		move.w	#$FF,d3

loc_14C5E:
		moveq	#$10,d5
		move.w	#$F,d2

loc_14C64:
		moveq	#0,d4
		move.w	#$F,d1

loc_14C6A:
		move.w	(a1)+,d0
		lsr.l	d5,d0
		addx.w	d4,d4
		dbf	d1,loc_14C6A

		move.w	d4,(a2)+
		suba.w	#$20,a1
		subq.w	#1,d5
		dbf	d2,loc_14C64

		adda.w	#$20,a1
		dbf	d3,loc_14C5E

		lea	(CollArray1).l,a1
		lea	(CollArray2).l,a2
		bsr.s	FloorLog_Unk2
		lea	(CollArray1).l,a1
		lea	(CollArray1).l,a2

; End of function FloorLog_Unk

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FloorLog_Unk2:				; XREF: FloorLog_Unk
		move.w	#$FFF,d3

loc_14CA6:
		moveq	#0,d2
		move.w	#$F,d1
		move.w	(a1)+,d0
		beq.s	loc_14CD4
		bmi.s	loc_14CBE

loc_14CB2:
		lsr.w	#1,d0
		bcc.s	loc_14CB8
		addq.b	#1,d2

loc_14CB8:
		dbf	d1,loc_14CB2

		bra.s	loc_14CD6
; ===========================================================================

loc_14CBE:
		cmpi.w	#-1,d0
		beq.s	loc_14CD0

loc_14CC4:
		lsl.w	#1,d0
		bcc.s	loc_14CCA
		subq.b	#1,d2

loc_14CCA:
		dbf	d1,loc_14CC4

		bra.s	loc_14CD6
; ===========================================================================

loc_14CD0:
		move.w	#$10,d0

loc_14CD4:
		move.w	d0,d2

loc_14CD6:
		move.b	d2,(a2)+
		dbf	d3,loc_14CA6

		rts	

; End of function FloorLog_Unk2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_WalkSpeed:			; XREF: Sonic_Move
		move.l	8(a0),d3
		move.l	$C(a0),d2
		move.w	$10(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	$12(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap	d2
		swap	d3
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		move.b	d0,d1
		addi.b	#$20,d0
		bpl.s	loc_14D1A
		move.b	d1,d0
		bpl.s	loc_14D14
		subq.b	#1,d0

loc_14D14:
		addi.b	#$20,d0
		bra.s	loc_14D24
; ===========================================================================

loc_14D1A:
		move.b	d1,d0
		bpl.s	loc_14D20
		addq.b	#1,d0

loc_14D20:
		addi.b	#$1F,d0

loc_14D24:
		andi.b	#$C0,d0
		beq.w	loc_14DF0
		cmpi.b	#$80,d0
		beq.w	loc_14F7C
		andi.b	#$38,d1
		bne.s	loc_14D3C
		addq.w	#8,d2

loc_14D3C:
		cmpi.b	#$40,d0
		beq.w	loc_1504A
		bra.w	loc_14EBC

; End of function Sonic_WalkSpeed


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14D48:				; XREF: Sonic_Jump
		move.b	d0,(Primary_Angle).w
		move.b	d0,(Secondary_Angle).w
		addi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_14FD6
		cmpi.b	#$80,d0
		beq.w	Sonic_DontRunOnWalls
		cmpi.b	#$C0,d0
		beq.w	sub_14E50

; End of function sub_14D48

; ---------------------------------------------------------------------------
; Subroutine to	make Sonic land	on the floor after jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HitFloor:				; XREF: Sonic_Floor
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#0,d2

loc_14DD0:
		move.b	(Secondary_Angle).w,d3
		cmp.w	d0,d1
		ble.s	loc_14DDE
		move.b	(Primary_Angle).w,d3
		exg	d0,d1

loc_14DDE:
		btst	#0,d3
		beq.s	locret_14DE6
		move.b	d2,d3

locret_14DE6:
		rts	

; End of function Sonic_HitFloor

; ===========================================================================
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_14DF0:				; XREF: Sonic_WalkSpeed
		addi.w	#$A,d2
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	#0,d2

loc_14E0A:				; XREF: sub_14EB4
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_14E16
		move.b	d2,d3

locret_14E16:
		rts	

; ---------------------------------------------------------------------------
; Subroutine allowing objects to interact with the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitFloor:
		move.w	8(a0),d3

; End of function ObjHitFloor


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitFloor2:
		move.w	$C(a0),d2
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_14E4E
		move.b	#0,d3

locret_14E4E:
		rts	
; End of function ObjHitFloor2


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14E50:				; XREF: sub_14D48
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$40,d2
		bra.w	loc_14DD0

; End of function sub_14E50


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_14EB4:				; XREF: Sonic_Floor
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_14EBC:
		addi.w	#$A,d3
		lea	(Primary_Angle).w,a4
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	#-$40,d2
		bra.w	loc_14E0A

; End of function sub_14EB4

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its right
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallRight:
		add.w	8(a0),d3
		move.w	$C(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_14F06
		move.b	#-$40,d3

locret_14F06:
		rts	

; End of function ObjHitWallRight

; ---------------------------------------------------------------------------
; Subroutine preventing	Sonic from running on walls and	ceilings when he
; touches them
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_DontRunOnWalls:			; XREF: Sonic_Floor; et al
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#-$80,d2
		bra.w	loc_14DD0
; End of function Sonic_DontRunOnWalls

; ===========================================================================
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_14F7C:
		subi.w	#$A,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	#-$80,d2
		bra.w	loc_14E0A

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitCeiling:
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eori.w	#$F,d2
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$800,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindFloor				; MJ: check solidity
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_14FD4
		move.b	#-$80,d3

locret_14FD4:
		rts	
; End of function ObjHitCeiling

; ===========================================================================

loc_14FD6:				; XREF: sub_14D48
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eori.w	#$F,d3
		lea	(Secondary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_14DD0

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic when	he jumps at a wall
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HitWall:				; XREF: Sonic_Floor
		move.w	$C(a0),d2
		move.w	8(a0),d3

loc_1504A:
		subi.w	#$A,d3
		eori.w	#$F,d3
		lea	(Primary_Angle).w,a4
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	#$40,d2
		bra.w	loc_14E0A
; End of function Sonic_HitWall

; ---------------------------------------------------------------------------
; Subroutine to	detect when an object hits a wall to its left
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ObjHitWallLeft:
		add.w	8(a0),d3
		move.w	$C(a0),d2
		lea	(Primary_Angle).w,a4
		move.b	#0,(a4)
		movea.w	#-$10,a3
		move.w	#$400,d6
		moveq	#$D,d5					; MJ: set solid type to check
		bsr.w	FindWall				; MJ: check solidity
		move.b	(Primary_Angle).w,d3
		btst	#0,d3
		beq.s	locret_15098
		move.b	#$40,d3

locret_15098:
		rts	
; End of function ObjHitWallLeft

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 66 - unused
; ---------------------------------------------------------------------------

Obj66:					; XREF: Obj_Index
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 67 - Unused
; ---------------------------------------------------------------------------

Obj67:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 68 - Unused
; ---------------------------------------------------------------------------

Obj68:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 69 - Unused
; ---------------------------------------------------------------------------

Obj69:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6A - Unused
; ---------------------------------------------------------------------------

Obj6A:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6B - Unused
; ---------------------------------------------------------------------------

Obj6B:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6C - Unused
; ---------------------------------------------------------------------------

Obj6C:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6E - Unused
; ---------------------------------------------------------------------------

Obj6E:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 6F - Unused
; ---------------------------------------------------------------------------

Obj6F:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 70 - Unused
; ---------------------------------------------------------------------------

Obj70:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 72 - Unused
; ---------------------------------------------------------------------------

Obj72:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 78 - Caterkiller enemy	(MZ, SBZ)
; ---------------------------------------------------------------------------

Obj78:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj78_Index(pc,d0.w),d1
		jmp	Obj78_Index(pc,d1.w)
; ===========================================================================
Obj78_Index:	dc.w Obj78_Main-Obj78_Index
		dc.w Obj78_Action-Obj78_Index
		dc.w Obj78_BodySeg1-Obj78_Index
		dc.w Obj78_BodySeg2-Obj78_Index
		dc.w Obj78_BodySeg1-Obj78_Index
		dc.w Obj78_Delete-Obj78_Index
		dc.w loc_16CC0-Obj78_Index
; ===========================================================================

locret_16950:
		rts	
; ===========================================================================

Obj78_Main:				; XREF: Obj78_Index
		move.b	#7,$16(a0)
		move.b	#8,$17(a0)
		jsr	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	locret_16950
		add.w	d1,$C(a0)
		clr.w	$12(a0)
		addq.b	#2,$24(a0)
		move.l	#Map_obj78,4(a0)
		move.w	#$24FF,2(a0)
		andi.b	#3,1(a0)
		ori.b	#4,1(a0)
		move.b	1(a0),$22(a0)
		move.b	#4,$18(a0)
		move.b	#8,$19(a0)
		move.b	#$B,$20(a0)
		move.w	8(a0),d2
		moveq	#$C,d5
		btst	#0,$22(a0)
		beq.s	loc_169CA
		neg.w	d5

loc_169CA:
		move.b	#4,d6
		moveq	#0,d3
		moveq	#4,d4
		movea.l	a0,a2
		moveq	#2,d1

Obj78_LoadBody:
		jsr	SingleObjLoad2
		bne.s	Obj78_QuitLoad
		move.b	#$78,0(a1)	; load body segment object
		move.b	d6,$24(a1)
		addq.b	#2,d6
		move.l	4(a0),4(a1)
		move.w	2(a0),2(a1)
		move.b	#5,$18(a1)
		move.b	#8,$19(a1)
		move.b	#$CB,$20(a1)
		add.w	d5,d2
		move.w	d2,8(a1)
		move.w	$C(a0),$C(a1)
		move.b	$22(a0),$22(a1)
		move.b	$22(a0),1(a1)
		move.b	#8,$1A(a1)
		move.l	a2,$3C(a1)
		move.b	d4,$3C(a1)
		addq.b	#4,d4
		movea.l	a1,a2

Obj78_QuitLoad:
		dbf	d1,Obj78_LoadBody ; repeat sequence 2 more times

		move.b	#7,$2A(a0)
		clr.b	$3C(a0)

Obj78_Action:				; XREF: Obj78_Index
		tst.b	$22(a0)
		bmi.w	loc_16C96
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj78_Index2(pc,d0.w),d1
		jsr	Obj78_Index2(pc,d1.w)
		move.b	$2B(a0),d1
		bpl.s	Obj78_Display
		lea	(Ani_obj78).l,a1
		move.b	$26(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,$26(a0)
		move.b	(a1,d0.w),d0
		bpl.s	Obj78_AniHead
		bclr	#7,$2B(a0)
		bra.s	Obj78_Display
; ===========================================================================

Obj78_AniHead:
		andi.b	#$10,d1
		add.b	d1,d0
		move.b	d0,$1A(a0)

Obj78_Display:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.w	Obj78_ChkGone
		jmp	DisplaySprite
; ===========================================================================

Obj78_ChkGone:
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_16ABC
		bclr	#7,2(a2,d0.w)

loc_16ABC:
		move.b	#$A,$24(a0)	; run "Obj78_Delete" routine
		rts	
; ===========================================================================

Obj78_Delete:				; XREF: Obj78_Index
		jmp	DeleteObject
; ===========================================================================
Obj78_Index2:	dc.w Obj78_Move-Obj78_Index2
		dc.w loc_16B02-Obj78_Index2
; ===========================================================================

Obj78_Move:				; XREF: Obj78_Index2
		subq.b	#1,$2A(a0)
		bmi.s	Obj78_Move2
		rts	
; ===========================================================================

Obj78_Move2:
		addq.b	#2,$25(a0)
		move.b	#$10,$2A(a0)
		move.w	#-$C0,$10(a0)
		move.w	#$40,$14(a0)
		bchg	#4,$2B(a0)
		bne.s	loc_16AFC
		clr.w	$10(a0)
		neg.w	$14(a0)

loc_16AFC:
		bset	#7,$2B(a0)

loc_16B02:				; XREF: Obj78_Index2
		subq.b	#1,$2A(a0)
		bmi.s	loc_16B5E
		move.l	8(a0),-(sp)
		move.l	8(a0),d2
		move.w	$10(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_16B1E
		neg.w	d0

loc_16B1E:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,8(a0)
		jsr	ObjHitFloor
		move.l	(sp)+,d2
		cmpi.w	#-8,d1
		blt.s	loc_16B70
		cmpi.w	#$C,d1
		bge.s	loc_16B70
		add.w	d1,$C(a0)
		swap	d2
		cmp.w	8(a0),d2
		beq.s	locret_16B5C
		moveq	#0,d0
		move.b	$3C(a0),d0
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		move.b	d1,$2C(a0,d0.w)

locret_16B5C:
		rts	
; ===========================================================================

loc_16B5E:
		subq.b	#2,$25(a0)
		move.b	#7,$2A(a0)
		move.w	#0,$10(a0)
		rts	
; ===========================================================================

loc_16B70:
		move.l	d2,8(a0)
		bchg	#0,$22(a0)
		move.b	$22(a0),1(a0)
		moveq	#0,d0
		move.b	$3C(a0),d0
		move.b	#$80,$2C(a0,d0.w)
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		rts	
; ===========================================================================

Obj78_BodySeg2:				; XREF: Obj78_Index
		movea.l	$3C(a0),a1
		move.b	$2B(a1),$2B(a0)
		bpl.s	Obj78_BodySeg1
		lea	(Ani_obj78).l,a1
		move.b	$26(a0),d0
		andi.w	#$7F,d0
		addq.b	#4,$26(a0)
		tst.b	4(a1,d0.w)
		bpl.s	Obj78_AniBody
		addq.b	#4,$26(a0)

Obj78_AniBody:
		move.b	(a1,d0.w),d0
		addq.b	#8,d0
		move.b	d0,$1A(a0)

Obj78_BodySeg1:				; XREF: Obj78_Index
		movea.l	$3C(a0),a1
		tst.b	$22(a0)
		bmi.w	loc_16C90
		move.b	$2B(a1),$2B(a0)
		move.b	$25(a1),$25(a0)
		beq.w	loc_16C64
		move.w	$14(a1),$14(a0)
		move.w	$10(a1),d0
		add.w	$14(a1),d0
		move.w	d0,$10(a0)
		move.l	8(a0),d2
		move.l	d2,d3
		move.w	$10(a0),d0
		btst	#0,$22(a0)
		beq.s	loc_16C0C
		neg.w	d0

loc_16C0C:
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.l	d2,8(a0)
		swap	d3
		cmp.w	8(a0),d3
		beq.s	loc_16C64
		moveq	#0,d0
		move.b	$3C(a0),d0
		move.b	$2C(a1,d0.w),d1
		cmpi.b	#-$80,d1
		bne.s	loc_16C50
		swap	d3
		move.l	d3,8(a0)
		move.b	d1,$2C(a0,d0.w)
		bchg	#0,$22(a0)
		move.b	$22(a0),1(a0)
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		bra.s	loc_16C64
; ===========================================================================

loc_16C50:
		ext.w	d1
		add.w	d1,$C(a0)
		addq.b	#1,$3C(a0)
		andi.b	#$F,$3C(a0)
		move.b	d1,$2C(a0,d0.w)

loc_16C64:
		cmpi.b	#$C,$24(a1)
		beq.s	loc_16C90
		cmpi.b	#$27,0(a1)
		beq.s	loc_16C7C
		cmpi.b	#$A,$24(a1)
		bne.s	loc_16C82

loc_16C7C:
		clr.b	$20(a1)	; immediately remove all touch response values when destroying the head to avoid taking damage
		move.b	#$A,$24(a0)

loc_16C82:
		jmp	DisplaySprite

; ===========================================================================
Obj78_FragSpeed:dc.w $FE00, $FE80, $180, $200
; ===========================================================================

loc_16C90:
		bset	#7,$22(a1)

loc_16C96:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj78_FragSpeed-2(pc,d0.w),d0
		btst	#0,$22(a0)
		beq.s	loc_16CAA
		neg.w	d0

loc_16CAA:
		move.w	d0,$10(a0)
		move.w	#-$400,$12(a0)
		move.b	#$C,$24(a0)
		andi.b	#-8,$1A(a0)

loc_16CC0:				; XREF: Obj78_Index
		jsr	ObjectMoveAndFall
		tst.w	$12(a0)
		bmi.s	loc_16CE0
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	loc_16CE0
		add.w	d1,$C(a0)
		move.w	#-$400,$12(a0)

loc_16CE0:
		tst.b	1(a0)
		bpl.w	Obj78_ChkGone
		jmp	DisplaySprite
; ===========================================================================
Ani_obj78:
	include "objects/animation/obj78.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Caterkiller	enemy (MZ, SBZ)
; ---------------------------------------------------------------------------
Map_obj78:
	include "mappings/sprite/obj78.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 79 - lamppost
; ---------------------------------------------------------------------------

Obj79:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj79_Index(pc,d0.w),d1
		jsr	Obj79_Index(pc,d1.w)
		jmp	MarkObjGone
; ===========================================================================
Obj79_Index:	dc.w Obj79_Main-Obj79_Index
		dc.w Obj79_BlueLamp-Obj79_Index
		dc.w Obj79_AfterHit-Obj79_Index
		dc.w Obj79_Twirl-Obj79_Index
; ===========================================================================

Obj79_Main:				; XREF: Obj79_Index
		addq.b	#2,$24(a0)
		move.l	#Map_obj79,4(a0)
		move.w	#($D800/$20),2(a0)
		move.b	#4,1(a0)
		move.b	#8,$19(a0)
		move.b	#5,$18(a0)
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)
		bne.s	Obj79_RedLamp
		move.b	(Last_Checkpoint_Hit).w,d1
		andi.b	#$7F,d1
		move.b	$28(a0),d2	; get lamppost number
		andi.b	#$7F,d2
		cmp.b	d2,d1		; is lamppost number higher than the number hit?
		bcs.s	Obj79_BlueLamp	; if yes, branch

Obj79_RedLamp:
		bset	#0,2(a2,d0.w)
		move.b	#4,$24(a0)	; run "Obj79_AfterHit" routine
		move.b	#3,$1A(a0)	; use red lamppost frame
		rts	
; ===========================================================================

Obj79_BlueLamp:				; XREF: Obj79_Index
		tst.w	(Debug_Placement_Mode).w	; is debug mode	being used?
		bne.w	locret_16F90	; if yes, branch
		tst.b	(No_Player_Physics_Flag).w
		bmi.w	locret_16F90
		move.b	(Last_Checkpoint_Hit).w,d1
		andi.b	#$7F,d1
		move.b	$28(a0),d2
		andi.b	#$7F,d2
		cmp.b	d2,d1
		bcs.s	Obj79_HitLamp
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bset	#0,2(a2,d0.w)
		move.b	#4,$24(a0)
		move.b	#3,$1A(a0)
		bra.w	locret_16F90
; ===========================================================================

Obj79_HitLamp:
		move.w	(Object_Space_1+8).w,d0
		sub.w	8(a0),d0
		addq.w	#8,d0
		cmpi.w	#$10,d0
		bcc.w	locret_16F90
		move.w	(Object_Space_1+$C).w,d0
		sub.w	$C(a0),d0
		addi.w	#$40,d0
		cmpi.w	#$68,d0
		bcc.s	locret_16F90
		move.w	#SndID_Checkpoint,d0
		jsr	(PlaySound_Special).l ;	play lamppost sound
		addq.b	#2,$24(a0)
		jsr	SingleObjLoad
		bne.s	loc_16F76
		move.b	#$79,0(a1)	; load twirling	lamp object
		move.b	#6,$24(a1)	; use "Obj79_Twirl" routine
		move.w	8(a0),$30(a1)
		move.w	$C(a0),$32(a1)
		subi.w	#$18,$32(a1)
		move.l	#Map_obj79,4(a1)
		move.w	#($D800/$20),2(a1)
		move.b	#4,1(a1)
		move.b	#8,$19(a1)
		move.b	#4,$18(a1)
		move.b	#2,$1A(a1)
		move.w	#$20,$36(a1)

loc_16F76:
		move.b	#1,$1A(a0)	; use "post only" frame, with no lamp
		bsr.w	Obj79_StoreInfo
		lea	(Object_Respawn_Table).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		bset	#0,2(a2,d0.w)

locret_16F90:
		rts	
; ===========================================================================

Obj79_AfterHit:				; XREF: Obj79_Index
		rts	
; ===========================================================================

Obj79_Twirl:				; XREF: Obj79_Index
		subq.w	#1,$36(a0)
		bpl.s	loc_16FA0
		move.b	#4,$24(a0)

loc_16FA0:
		move.b	$26(a0),d0
		subi.b	#$10,$26(a0)
		subi.b	#$40,d0
		jsr	(CalcSine).l
		muls.w	#$C00,d1
		swap	d1
		add.w	$30(a0),d1
		move.w	d1,8(a0)
		muls.w	#$C00,d0
		swap	d0
		add.w	$32(a0),d0
		move.w	d0,$C(a0)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	store information when you hit a lamppost
; ---------------------------------------------------------------------------

Obj79_StoreInfo:			; XREF: Obj79_HitLamp
		move.b	$28(a0),(Last_Checkpoint_Hit).w 		; lamppost number
		move.b	(Last_Checkpoint_Hit).w,(Saved_Last_Checkpoint_Hit).w
		move.w	8(a0),(Saved_X_Pos).w		; x-position
		move.w	$C(a0),(Saved_Y_Pos).w		; y-position
		move.w	(Ring_Count).w,(Saved_Ring_Count).w 	; rings
		move.b	(Extra_Life_Flags).w,(Saved_Extra_Life_Flags).w 	; lives
		move.l	(Timer).w,(Saved_Timer).w 	; time
		move.b	(Dynamic_Resize_Routine).w,(Saved_Resize_Routine).w 	; routine counter for dynamic level mod
		move.w	(Camera_Max_Y_Pos).w,(Saved_Camera_Max_Y_Pos).w 	; lower y-boundary of level
		move.w	(Camera_X_Pos).w,(Saved_Camera_X_Pos).w 	; screen x-position
		move.w	(Camera_Y_Pos).w,(Saved_Camera_Y_Pos).w 	; screen y-position
		move.w	(Camera_BG_X_Pos).w,(Saved_Camera_BG_X_Pos).w 	; bg position
		move.w	(Camera_BG_Y_Pos).w,(Saved_Camera_BG_Y_Pos).w 	; bg position
		move.w	(Camera_BG2_X_Pos).w,(Saved_Camera_BG2_X_Pos).w 	; bg position
		move.w	(Camera_BG2_Y_Pos).w,(Saved_Camera_BG2_Y_Pos).w 	; bg position
		move.w	(Camera_BG3_X_Pos).w,(Saved_Camera_BG3_X_Pos).w 	; bg position
		move.w	(Camera_BG3_Y_Pos).w,(Saved_Camera_BG3_Y_Pos).w 	; bg position
		move.w	(Water_Height_No_Sway).w,(Saved_Water_Height).w 	; water height
		move.b	(Water_Routine).w,(Saved_Water_Routine).w 	; rountine counter for water
		move.b	(Water_Fullscreen_Flag).w,(Saved_Water_Fullscreen_Flag).w 	; water direction
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	load stored info when you start	a level	from a lamppost
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj79_LoadInfo:				; XREF: LevelSizeLoad
		move.b	(Saved_Last_Checkpoint_Hit).w,(Last_Checkpoint_Hit).w
		move.w	(Saved_X_Pos).w,(Object_Space_1+8).w
		move.w	(Saved_Y_Pos).w,(Object_Space_1+$C).w
		move.w	(Saved_Ring_Count).w,(Ring_Count).w
		move.b	(Saved_Extra_Life_Flags).w,(Extra_Life_Flags).w
		clr.w	(Ring_Count).w
		clr.b	(Extra_Life_Flags).w
		move.l	(Saved_Timer).w,(Timer).w
		move.b	#59,(Timer_Frame).w
		subq.b	#1,(Timer_Second).w
		move.b	(Saved_Resize_Routine).w,(Dynamic_Resize_Routine).w
		move.b	(Saved_Water_Routine).w,(Water_Routine).w
		move.w	(Saved_Camera_Max_Y_Pos).w,(Camera_Max_Y_Pos).w
		move.w	(Saved_Camera_Max_Y_Pos).w,(Target_Camera_Max_Y_Pos).w
		move.w	(Saved_Camera_X_Pos).w,(Camera_X_Pos).w
		move.w	(Saved_Camera_Y_Pos).w,(Camera_Y_Pos).w
		move.w	(Saved_Camera_BG_X_Pos).w,(Camera_BG_X_Pos).w
		move.w	(Saved_Camera_BG_Y_Pos).w,(Camera_BG_Y_Pos).w
		move.w	(Saved_Camera_BG2_X_Pos).w,(Camera_BG2_X_Pos).w
		move.w	(Saved_Camera_BG2_Y_Pos).w,(Camera_BG2_Y_Pos).w
		move.w	(Saved_Camera_BG3_X_Pos).w,(Camera_BG3_X_Pos).w
		move.w	(Saved_Camera_BG3_Y_Pos).w,(Camera_BG3_Y_Pos).w
		cmpi.b	#1,(Current_Zone).w
		bne.s	loc_170E4
		move.w	(Saved_Water_Height).w,(Water_Height_No_Sway).w
		move.b	(Saved_Water_Routine).w,(Water_Routine).w
		move.b	(Saved_Water_Fullscreen_Flag).w,(Water_Fullscreen_Flag).w

loc_170E4:
		tst.b	(Last_Checkpoint_Hit).w
		bpl.s	locret_170F6
		move.w	(Saved_X_Pos).w,d0
		subi.w	#$A0,d0
		move.w	d0,(Camera_Min_X_Pos).w

locret_170F6:
		rts	
; End of function Obj79_LoadInfo

; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - lamppost
; ---------------------------------------------------------------------------
Map_obj79:
	include "mappings/sprite/obj79.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7D - hidden points at the end of a level
; ---------------------------------------------------------------------------

Obj7D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7D_Index(pc,d0.w),d1
		jmp	Obj7D_Index(pc,d1.w)
; ===========================================================================
Obj7D_Index:	dc.w Obj7D_Main-Obj7D_Index
		dc.w Obj7D_DelayDel-Obj7D_Index
; ===========================================================================

Obj7D_Main:				; XREF: Obj7D_Index
		moveq	#$10,d2
		move.w	d2,d3
		add.w	d3,d3
		lea	(Object_RAM).w,a1
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	Obj7D_ChkDel
		move.w	$C(a1),d1
		sub.w	$C(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	Obj7D_ChkDel
		tst.w	(Debug_Placement_Mode).w
		bne.s	Obj7D_ChkDel
		tst.b	(Jumped_In_Big_Ring_Flag).w
		bne.s	Obj7D_ChkDel
		addq.b	#2,$24(a0)
		move.l	#Map_obj7D,4(a0)
		move.w	#$84B6,2(a0)
		ori.b	#4,1(a0)
		move.b	#0,$18(a0)
		move.b	#$10,$19(a0)
		move.b	$28(a0),$1A(a0)
		move.w	#119,$30(a0)	; set display time to 2	seconds
		move.w	#SndID_HiddenBonus,d0
		jsr	(PlaySound_Special).l ;	play bonus sound
		moveq	#0,d0
		move.b	$28(a0),d0
		add.w	d0,d0
		move.w	Obj7D_Points(pc,d0.w),d0 ; load	bonus points array
		jsr	AddPoints

Obj7D_ChkDel:
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj7D_Delete
		rts	
; ===========================================================================

Obj7D_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj7D_Points:	dc.w 0			; Bonus	points array
		dc.w 1000
		dc.w 100
		dc.w 10
; ===========================================================================

Obj7D_DelayDel:				; XREF: Obj7D_Index
		subq.w	#1,$30(a0)	; subtract 1 from display time
		bmi.s	Obj7D_Delete2	; if time is zero, branch
		move.w	8(a0),d0
		andi.w	#-$80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#-$80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj7D_Delete2
		jmp	DisplaySprite
; ===========================================================================

Obj7D_Delete2:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - hidden points at the end of	a level
; ---------------------------------------------------------------------------
Map_obj7D:
	include "mappings/sprite/obj7D.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 8A - "SONIC TEAM PRESENTS" and	credits
; ---------------------------------------------------------------------------

Obj8A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj8A_Index(pc,d0.w),d1
		jmp	Obj8A_Index(pc,d1.w)
; ===========================================================================
Obj8A_Index:	dc.w Obj8A_Main-Obj8A_Index
		dc.w Obj8A_Display-Obj8A_Index
; ===========================================================================

Obj8A_Main:				; XREF: Obj8A_Index
		addq.b	#2,$24(a0)
		move.w	#$120,8(a0)
		move.w	#$F0,$A(a0)
		move.l	#Map_obj8A,4(a0)
		move.w	#$5A0,2(a0)
		move.w	(Credits_Index).w,d0 ; load	credits	index number
		move.b	d0,$1A(a0)	; display appropriate sprite
		move.b	#0,1(a0)
		move.b	#0,$18(a0)
		cmpi.b	#4,(Game_Mode).w ; is the scene	number 04 (title screen)?
		bne.s	Obj8A_Display	; if not, branch
		move.w	#$A6,2(a0)
		move.b	#$A,$1A(a0)	; display "SONIC TEAM PRESENTS"
		tst.b	(Jap_Credits_Cheat_Flag).w	; is hidden credits cheat on?
		beq.s	Obj8A_Display	; if not, branch
		cmpi.b	#$72,(Ctrl_1_Held).w ; is	Start+A+C+Down being pressed?
		bne.s	Obj8A_Display	; if not, branch
		move.w	#$EEE,(Normal_Palette+$C0).w ; 3rd Palette, 1st entry = white
		move.w	#$880,(Normal_Palette+$C2).w ; 3rd Palette, 2nd entry = cyan
		jmp	DeleteObject
; ===========================================================================

Obj8A_Display:				; XREF: Obj8A_Index
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC TEAM	PRESENTS" and credits
; ---------------------------------------------------------------------------
Map_obj8A:
	include "mappings/sprite/obj8A.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ)
; ---------------------------------------------------------------------------

Obj3D:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3D_Index(pc,d0.w),d1
		jmp	Obj3D_Index(pc,d1.w)
; ===========================================================================
Obj3D_Index:	dc.w Obj3D_Main-Obj3D_Index
		dc.w Obj3D_ShipMain-Obj3D_Index
		dc.w Obj3D_FaceMain-Obj3D_Index
		dc.w Obj3D_FlameMain-Obj3D_Index

Obj3D_ObjData:	dc.b 2,	0		; routine counter, animation
		dc.b 4,	1
		dc.b 6,	7
; ===========================================================================

Obj3D_Main:				; XREF: Obj3D_Index
		lea	(Obj3D_ObjData).l,a2
		movea.l	a0,a1
		moveq	#2,d1
		bra.s	Obj3D_LoadBoss
; ===========================================================================

Obj3D_Loop:
		jsr	SingleObjLoad2
		bne.s	loc_17772

Obj3D_LoadBoss:				; XREF: Obj3D_Main
		move.b	(a2)+,$24(a1)
		cmpi.b	#2,$24(a1)
		bne.s	@Skip
		move.b	#24,$16(a1)
		
@Skip:
		move.b	#$3D,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.b	#3,$18(a1)
		move.b	(a2)+,$1C(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj3D_Loop	; repeat sequence 2 more times

loc_17772:
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8

Obj3D_ShipMain:				; XREF: Obj3D_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj3D_ShipIndex(pc,d0.w),d1
		jsr	Obj3D_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		move.b	$22(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj3D_ShipIndex:dc.w Obj3D_ShipStart-Obj3D_ShipIndex
		dc.w Obj3D_MakeBall-Obj3D_ShipIndex
		dc.w Obj3D_ShipMove-Obj3D_ShipIndex
		dc.w loc_17954-Obj3D_ShipIndex
		dc.w loc_1797A-Obj3D_ShipIndex
		dc.w loc_179AC-Obj3D_ShipIndex
		dc.w loc_179F6-Obj3D_ShipIndex
		dc.w Obj3D_Dead-Obj3D_ShipIndex
; ===========================================================================

Obj3D_ShipStart:			; XREF: Obj3D_ShipIndex
		move.w	#$100,$12(a0)	; move ship down
		bsr.w	BossMove
		cmpi.w	#$328,$38(a0)
		bne.s	loc_177E6
		move.w	#0,$12(a0)	; stop ship
		move.w	#0,$2E(a0)
		addq.b	#2,$25(a0)	; goto next routine

loc_177E6:
		move.b	$3F(a0),d0
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		add.w	$2E(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		addq.b	#2,$3F(a0)
		cmpi.b	#8,$25(a0)
		bcc.s	locret_1784A
		tst.b	$22(a0)
		bmi.s	loc_1784C
		tst.b	$20(a0)
		bne.s	locret_1784A
		tst.b	$3E(a0)
		bne.s	Obj3D_ShipFlash
		move.b	#$20,$3E(a0)	; set number of	times for ship to flash
		move.w	#SndID_HitBoss,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

Obj3D_ShipFlash:
		lea	(Normal_Palette+$22).w,a1 ; load	2nd Palette, 2nd	entry
		moveq	#0,d0		; move 0 (black) to d0
		tst.w	(a1)
		bne.s	loc_1783C
		move.w	#$EEE,d0	; move 0EEE (white) to d0

loc_1783C:
		move.w	d0,(a1)		; load colour stored in	d0
		subq.b	#1,$3E(a0)
		bne.s	locret_1784A
		move.b	#$F,$20(a0)

locret_1784A:
		rts	
; ===========================================================================

loc_1784C:				; XREF: loc_177E6
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#8,$25(a0)
		move.w	#$B3,$3C(a0)
		rts	

; ---------------------------------------------------------------------------
; Defeated boss	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossDefeated:
		move.b	(V_Int_Counter+3).w,d0
		andi.b	#7,d0
		bne.s	locret_178A2
		jsr	SingleObjLoad
		bne.s	locret_178A2
		move.b	#$3F,0(a1)	; load explosion object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,8(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,$C(a1)

locret_178A2:
		rts	
; End of function BossDefeated

; ---------------------------------------------------------------------------
; Subroutine to	move a boss
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


BossMove:
		move.l	$30(a0),d2
		move.l	$38(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,$30(a0)
		move.l	d3,$38(a0)
		rts	
; End of function BossMove

; ===========================================================================

Obj3D_MakeBall:				; XREF: Obj3D_ShipIndex
		move.w	#-$100,$10(a0)
		move.w	#-$40,$12(a0)
		bsr.w	BossMove
		cmpi.w	#$2A00,$30(a0)
		bne.s	loc_17916
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		addq.b	#2,$25(a0)
		jsr	SingleObjLoad2
		bne.s	loc_17910
		move.b	#$48,0(a1)	; load swinging	ball object
		move.w	$30(a0),8(a1)
		move.w	$38(a0),$C(a1)
		move.l	a0,$34(a1)

loc_17910:
		move.w	#$77,$3C(a0)

loc_17916:
		bra.w	loc_177E6
; ===========================================================================

Obj3D_ShipMove:				; XREF: Obj3D_ShipIndex
		move.b	#1,(Tutorial_Boss_Flags+1).w
		move.b	(V_Int_Counter+3).w,d0
		move.b	d0,d1
		andi.b	#4,d0
		bne.s	@ChkGoUp
		addi.w	#1,$2E(a0)
		
@ChkGoUp:
		andi.b	#7,d1
		bne.s	@DoChks
		subi.w	#2,$2E(a0)
		
@DoChks:
		tst.b	(Tutorial_Boss_Flags).w
		beq.s	@Normal
		cmpi.b	#2,(Tutorial_Boss_Flags+1).w
		beq.s	@Fall
		move.b	#2,(Tutorial_Boss_Flags+1).w
		moveq	#$FFFFFF98,d0
		jsr	PlaySample
		
@Fall:
		jsr	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	@NoExplode
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		move.w	#$7F,$3C(a0)
		addq.b	#4,$25(a0)
		
@NoExplode:
		rts
		
@Normal:
		subq.w	#1,$3C(a0)
		bpl.s	Obj3D_Reverse
		addq.b	#2,$25(a0)
		move.w	#$3F,$3C(a0)
		move.w	#$10,$C(a0)
		cmpi.w	#$2A00,$30(a0)
		bne.s	Obj3D_Reverse
		move.w	#$7F,$3C(a0)
		move.w	#$40,$10(a0)

Obj3D_Reverse:
		btst	#0,$22(a0)
		bne.s	loc_17950
		neg.w	$10(a0)		; reverse direction of the ship

loc_17950:
		bra.w	loc_177E6
; ===========================================================================

loc_17954:				; XREF: Obj3D_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_17960
		bsr.w	BossMove
		bra.s	loc_17976
; ===========================================================================

loc_17960:
		bchg	#0,$22(a0)
		move.w	#$3F,$3C(a0)
		subq.b	#2,$25(a0)
		move.w	#0,$10(a0)

loc_17976:
		bra.w	loc_177E6
; ===========================================================================

loc_1797A:				; XREF: Obj3D_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_17984
		bra.w	BossDefeated
; ===========================================================================

loc_17984:
		move.b	#2,(Tutorial_Boss_Flags).w
		jsr	SingleObjLoad
		bne.w	@End
		move.b	#$3F,(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	SingleObjLoad
		bne.w	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		subi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		subi.w	#$10,d0
		move.w	d0,$C(a1)
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		subi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		addi.w	#$10,d0
		move.w	d0,$C(a1)
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		addi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		subi.w	#$10,d0
		move.w	d0,$C(a1)
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		addi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		addi.w	#$10,d0
		move.w	d0,$C(a1)
		
@End:
		move.w	#$200,$10(a0)
		move.w	#-$400,$12(a0)
		move.b	#$E,$25(a0)
		rts
; ===========================================================================
		
Obj3D_Dead:
		tst.b	(Boss_Defeated_Flags).w
		bne.s	@loc_179AA
		move.b	#1,(Boss_Defeated_Flags).w
		move.w	#SndID_HitBoss,d0
		jsr	PlaySound_Special

@loc_179AA:
		jsr	ObjectMoveAndFall
		tst.w	$12(a0)
		bmi.s	@Skip
		jsr	ObjHitFloor
		tst.w	d1
		bpl.s	@Skip
		add.w	d1,$C(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.w	#$2AC0,(Camera_Max_X_Pos).w
		bsr.w	BossEnd
		move.b	#0,$20(a0)
		
@Skip:
		jmp	DisplaySprite
; ===========================================================================

loc_179AC:				; XREF: Obj3D_ShipIndex
		addq.w	#1,$3C(a0)
		beq.s	loc_179BC
		bpl.s	loc_179C2
		addi.w	#$18,$12(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179BC:
		clr.w	$12(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179C2:
		cmpi.w	#$30,$3C(a0)
		bcs.s	loc_179DA
		beq.s	loc_179E0
		cmpi.w	#$38,$3C(a0)
		bcs.s	loc_179EE
		addq.b	#2,$25(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179DA:
		subq.w	#8,$12(a0)
		bra.s	loc_179EE
; ===========================================================================

loc_179E0:
		clr.w	$12(a0)
		bsr.w	BossEnd

loc_179EE:
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

loc_179F6:				; XREF: Obj3D_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2AC0,(Camera_Max_X_Pos).w
		beq.s	loc_17A10
		addq.w	#2,(Camera_Max_X_Pos).w
		bra.s	loc_17A16
; ===========================================================================

loc_17A10:
		tst.b	1(a0)
		bpl.s	Obj3D_ShipDel

loc_17A16:
		bsr.w	BossMove
		bra.w	loc_177E6
; ===========================================================================

Obj3D_ShipDel:
		jmp	DeleteObject
; ===========================================================================

Obj3D_FaceMain:				; XREF: Obj3D_Index
		cmpi.b	#2,(Tutorial_Boss_Flags).w
		beq.s	Obj3D_FaceDel
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		subq.b	#4,d0
		bne.s	loc_17A3E
		cmpi.w	#$2A00,$30(a1)
		bne.s	loc_17A46
		moveq	#4,d1

loc_17A3E:
		subq.b	#6,d0
		bmi.s	loc_17A46
		moveq	#$A,d1
		bra.s	loc_17A5A
; ===========================================================================

loc_17A46:
		tst.b	$20(a1)
		bne.s	loc_17A50
		moveq	#5,d1
		bra.s	loc_17A5A
; ===========================================================================

loc_17A50:
		cmpi.b	#4,(Object_Space_1+$24).w
		bcs.s	loc_17A5A
		moveq	#4,d1

loc_17A5A:
		move.b	d1,$1C(a0)
		cmpi.b	#2,(Tutorial_Boss_Flags+1).w
		bne.s	@Chk
		move.b	#5,$1C(a0)
		bra.s	Obj3D_FaceDisp
		
@Chk:
		tst.b	(Tutorial_Boss_Flags+1).w
		beq.s	@Skip
		move.b	#6,$1C(a0)
		bra.s	Obj3D_FaceDisp
		
@Skip:
		subq.b	#2,d0
		bne.s	Obj3D_FaceDisp
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj3D_FaceDel

Obj3D_FaceDisp:
		bra.s	Obj3D_Display
; ===========================================================================

Obj3D_FaceDel:
		jmp	DeleteObject
; ===========================================================================

Obj3D_FlameMain:			; XREF: Obj3D_Index
		cmpi.b	#2,(Tutorial_Boss_Flags).w
		beq.s	Obj3D_FlameDel
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$C,$25(a1)
		bne.s	loc_17A96
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj3D_FlameDel
		bra.s	Obj3D_FlameDisp
; ===========================================================================

loc_17A96:
		move.w	$10(a1),d0
		beq.s	Obj3D_FlameDisp
		move.b	#8,$1C(a0)

Obj3D_FlameDisp:
		bra.s	Obj3D_Display
; ===========================================================================

Obj3D_FlameDel:
		jmp	DeleteObject
; ===========================================================================

Obj3D_Display:				; XREF: Obj3D_FaceDisp; Obj3D_FlameDisp
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		move.b	$22(a0),d0
		andi.b	#3,d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

BossEnd:
		move.b	#0,(Boss_Flag).w	; clear Boss flag
		rts
; ===========================================================================
; LEVEL MUSIC CONTROLLER
; ===========================================================================

CtrlLevelMusic:
		tst.b	(Sound_Driver_RAM+$27).w	; Is the extra life jingle playing?
		bne.s	@end				; If so, let it play
		tst.b	(No_Music_Ctrl).w		; Is the music controller disabled?
		bne.s	@end				; If so, skip all this
		move.b	(Level_Music_ID).w,d0		; Level music
		tst.b	(Invincibility_Flag).w		; Is Sonic invincible?
		beq.s	@chk_spdshoes			; If not, check if he has speed shoes
		move.b	#MusID_Invincibility,d0		; Invincibility music
		
@chk_spdshoes:
		tst.b	(Boss_Flag).w			; Is there a boss?
		beq.s	@chk_drowning			; If not, check if Sonic is drowning
		moveq	#0,d0				; Clear d0
		move.w	(Current_Zone_And_Act).w,d1	; Get music ID depending on the current level
		ror.b	#2,d1
		lsr.w	#6,d1
		lea	(MusicList_Bosses).l,a1		; Load Music Playlist for bosses
		move.b	(a1,d1.w),d0			; Set music ID
		
@chk_drowning:
		cmpi.b	#$C,(Object_Space_1+$28).w	; Check air remaining
		bcc.s	@chk_value			; If air is above $C, branch
		move.b	#MusID_Drowning,d0		; Drowning music
		
@chk_value:
		move.b	(Current_Music_ID).w,d1		; Get current music playing
		cmp.b	d0,d1				; If the value is the same,
		beq.s	@end				; Don't play it again
		jmp	(PlayMusic).l			; Play music and return
		
@end:
		rts					; Return
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 48 - ball on a	chain that Eggman swings (GHZ)
; ---------------------------------------------------------------------------

Obj48:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj48_Index(pc,d0.w),d1
		jmp	Obj48_Index(pc,d1.w)
; ===========================================================================
Obj48_Index:	dc.w Obj48_Main-Obj48_Index
		dc.w Obj48_Base-Obj48_Index
		dc.w Obj48_Display2-Obj48_Index
		dc.w loc_17C68-Obj48_Index
		dc.w Obj48_ChkVanish-Obj48_Index
; ===========================================================================

Obj48_Main:				; XREF: Obj48_Index
		addq.b	#2,$24(a0)
		move.w	#$4080,$26(a0)
		move.w	#-$200,$3E(a0)
		move.l	#Map_BossItems,4(a0)
		move.w	#$46C,2(a0)
		lea	$28(a0),a2
		move.b	#0,(a2)+
		moveq	#5,d1
		movea.l	a0,a1
		bra.s	loc_17B60
; ===========================================================================

Obj48_MakeLinks:
		jsr	SingleObjLoad2
		bne.s	Obj48_MakeBall
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$48,0(a1)	; load chain link object
		move.b	#6,$24(a1)
		move.l	#Map_obj15,4(a1)
		move.w	#$380,2(a1)
		move.b	#1,$1A(a1)
		addq.b	#1,$28(a0)

loc_17B60:				; XREF: Obj48_Main
		move.w	a1,d5
		subi.w	#Object_RAM,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5
		move.b	d5,(a2)+
		move.b	#4,1(a1)
		move.b	#8,$19(a1)
		move.b	#6,$18(a1)
		move.b	#8,$16(a1)
		move.l	$34(a0),$34(a1)
		dbf	d1,Obj48_MakeLinks ; repeat sequence 5 more times

Obj48_MakeBall:
		move.b	#8,$24(a1)
		move.l	#Map_obj48,4(a1) ; load	different mappings for final link
		move.w	#$43AA,2(a1)	; use different	graphics
		move.b	#1,$1A(a1)
		move.b	#5,$18(a1)
		move.b	#20,$16(a1)
		move.b	#$81,$20(a1)	; make object hurt Sonic
		rts	
; ===========================================================================

Obj48_PosData:	dc.b 0,	$10, $20, $30, $40, $60	; y-position data for links and	giant ball

; ===========================================================================

Obj48_Base:				; XREF: Obj48_Index
		lea	(Obj48_PosData).l,a3
		lea	$28(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_17BC6:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#6,d4
		addi.l	#Object_RAM,d4
		movea.l	d4,a1
		move.b	(a3)+,d0
		cmp.b	$3C(a1),d0
		beq.s	loc_17BE0
		addq.b	#1,$3C(a1)

loc_17BE0:
		dbf	d6,loc_17BC6

		cmp.b	$3C(a1),d0
		bne.s	loc_17BFA
		move.b	#1,(Tutorial_Boss_Flags).w
		movea.l	$34(a0),a1
		cmpi.b	#6,$25(a1)
		bne.s	loc_17BFA
		addq.b	#2,$24(a0)

loc_17BFA:
		cmpi.w	#$20,$32(a0)
		beq.s	Obj48_Display
		addq.w	#1,$32(a0)

Obj48_Display:
		bsr.w	sub_17C2A
		move.b	$26(a0),d0
		jsr	(Obj15_Move2).l
		
Obj48_Display5:
		jmp	DisplaySprite
; ===========================================================================

Obj48_Display2:				; XREF: Obj48_Index
		bsr.w	sub_17C2A
		jsr	(Obj48_Move).l
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


sub_17C2A:				; XREF: Obj48_Display; Obj48_Display2
		tst.b	(Tutorial_Boss_Flags).w
		beq.s	@Skip
		jsr	ObjectMoveAndFall
		jsr	ObjHitFloor
		addq.l	#4,sp
		tst.w	d1
		bpl.w	@End
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		move.b	#$3F,(a0)
		move.b	#0,$24(a0)

@End:
		jmp	DisplaySprite
		
@Skip:
		movea.l	$34(a0),a1
		addi.b	#$20,$1B(a0)
		bcc.s	loc_17C3C
		bchg	#0,$1A(a0)

loc_17C3C:
		move.w	8(a1),$3A(a0)
		move.w	$C(a1),d0
		add.w	$32(a0),d0
		move.w	d0,$38(a0)
		move.b	$22(a1),$22(a0)
		tst.b	$22(a1)
		bpl.s	locret_17C66
		move.b	#$3F,0(a0)
		move.b	#0,$24(a0)

locret_17C66:
		rts	
; End of function sub_17C2A

; ===========================================================================

loc_17C68:				; XREF: Obj48_Index
		tst.b	(Tutorial_Boss_Flags).w
		beq.s	@Skip
		jsr	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	Obj48_Display3
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		move.b	#$3F,(a0)
		move.b	#0,$24(a0)
		rts
		
@Skip:
		movea.l	$34(a0),a1
		tst.b	$22(a1)
		bpl.s	Obj48_Display3
		move.b	#$3F,0(a0)
		move.b	#0,$24(a0)

Obj48_Display3:
		jmp	DisplaySprite
; ===========================================================================

Obj48_ChkVanish:			; XREF: Obj48_Index
		tst.b	(Tutorial_Boss_Flags).w
		beq.w	@Skip
		jsr	ObjectMoveAndFall
		jsr	ObjHitFloor
		tst.w	d1
		bpl.w	Obj48_Display4
		add.w	d1,$C(a0)	; match	object's position with the floor
		move.w	#0,$12(a0)
		move.b	#$3F,(a0)
		move.b	#0,$24(a0)
		jsr	SingleObjLoad
		bne.w	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		subi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		subi.w	#$10,d0
		move.w	d0,$C(a1)
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		subi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		addi.w	#$10,d0
		move.w	d0,$C(a1)
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		addi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		subi.w	#$10,d0
		move.w	d0,$C(a1)
		jsr	SingleObjLoad
		bne.s	@End
		move.b	#$3F,(a1)
		move.w	8(a0),d0
		addi.w	#$10,d0
		move.w	d0,8(a1)
		move.w	$C(a0),d0
		addi.w	#$10,d0
		move.w	d0,$C(a1)
		
@End:
		rts
		
@Skip:
		moveq	#0,d0
		tst.b	$1A(a0)
		bne.s	Obj48_Vanish
		addq.b	#1,d0

Obj48_Vanish:
		move.b	d0,$1A(a0)
		movea.l	$34(a0),a1
		tst.b	$22(a1)
		bpl.s	Obj48_Display4
		move.b	#0,$20(a0)
		bsr.w	BossDefeated
		subq.b	#1,$3C(a0)
		bpl.s	Obj48_Display4
		move.b	#$3F,(a0)
		move.b	#0,$24(a0)

Obj48_Display4:
		jmp	DisplaySprite
; ===========================================================================
Ani_Eggman:
	include "objects/animation/Eggman.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Eggman (boss levels)
; ---------------------------------------------------------------------------
Map_Eggman:
	include "mappings/sprite/Eggman.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - extra boss items (e.g. swinging ball on a chain in GHZ)
; ---------------------------------------------------------------------------
Map_BossItems:
	include "mappings/sprite/Boss items.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 77 - Eggman (LZ)
; ---------------------------------------------------------------------------

obj77:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	obj77_Index(pc,d0.w),d1
		jmp	obj77_Index(pc,d1.w)
; ===========================================================================
obj77_Index:	dc.w obj77_Main-obj77_Index
		dc.w obj77_ShipMain-obj77_Index
		dc.w obj77_FaceMain-obj77_Index
		dc.w obj77_FlameMain-obj77_Index
		dc.w obj77_TubeMain-obj77_Index

obj77_ObjData:	dc.b 2,	0, 4		; routine number, animation, priority
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

obj77_Main:				; XREF: obj77_Index
		move.w	#$2188,8(a0)
		move.w	#$228,$C(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	obj77_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	obj77_LoadBoss
; ===========================================================================

obj77_Loop:
		jsr	SingleObjLoad2
		bne.s	lz_1895C
		move.b	#$7A,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

obj77_LoadBoss:				; XREF: obj77_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,obj77_Loop	; repeat sequence 3 more times

lz_1895C:
		lea	(Object_Space_2).w,a1
		lea	$2A(a0),a2
		moveq	#$5E,d0
		moveq	#$3E,d1

lz_18968:
		cmp.b	(a1),d0
		bne.s	lz_18974
		tst.b	$28(a1)
		beq.s	lz_18974
		move.w	a1,(a2)+

lz_18974:
		adda.w	#$40,a1
		dbf	d1,lz_18968

obj77_ShipMain:				; XREF: obj77_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	obj77_ShipIndex(pc,d0.w),d0
		jsr	obj77_ShipIndex(pc,d0.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
obj77_ShipIndex:dc.w lz_189B8-obj77_ShipIndex
		dc.w lz_18A5E-obj77_ShipIndex
		dc.w obj77_MakeBall-obj77_ShipIndex
		dc.w lz_18B48-obj77_ShipIndex
		dc.w lz_18B80-obj77_ShipIndex
		dc.w lz_18BC6-obj77_ShipIndex
; ===========================================================================

lz_189B8:				; XREF: obj77_ShipIndex
		move.w	#-$100,$10(a0)
		cmpi.w	#$2120,$30(a0)
		bcc.s	lz_189CA
		addq.b	#2,$25(a0)

lz_189CA:
		bsr.w	BossMove
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		bra.s	lz_189FE
; ===========================================================================

lz_189EE:
		bsr.w	BossMove
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)

lz_189FE:
		cmpi.b	#6,$25(a0)
		bcc.s	lz_18A44
		tst.b	$22(a0)
		bmi.s	lz_18A46
		tst.b	$20(a0)
		bne.s	lz_18A44
		tst.b	$3E(a0)
		bne.s	lz_18A28
		move.b	#$20,$3E(a0)
		move.w	#SndID_HitBoss,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

lz_18A28:
		lea	(Normal_Palette+$22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	lz_18A36
		move.w	#$EEE,d0

lz_18A36:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	lz_18A44
		move.b	#$F,$20(a0)

lz_18A44:
		rts	
; ===========================================================================

lz_18A46:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,$25(a0)
		move.b	#$78,$3C(a0)
		clr.w	$10(a0)
		rts	
; ===========================================================================

lz_18A5E:				; XREF: obj77_ShipIndex
		move.w	$30(a0),d0
		move.w	#$200,$10(a0)
		btst	#0,$22(a0)
		bne.s	lz_18A7C
		neg.w	$10(a0)
		cmpi.w	#$2008,d0
		bgt.s	lz_18A88
		bra.s	lz_18A82
; ===========================================================================

lz_18A7C:
		cmpi.w	#$2138,d0
		blt.s	lz_18A88

lz_18A82:
		bchg	#0,$22(a0)

lz_18A88:
		move.w	8(a0),d0
		moveq	#-1,d1
		moveq	#2,d2
		lea	$2A(a0),a2
		moveq	#$28,d4
		tst.w	$10(a0)
		bpl.s	lz_18A9E
		neg.w	d4

lz_18A9E:
		move.w	(a2)+,d1
		movea.l	d1,a3
		btst	#3,$22(a3)
		bne.s	lz_18AB4
		move.w	8(a3),d3
		add.w	d4,d3
		sub.w	d0,d3
		beq.s	lz_18AC0

lz_18AB4:
		dbf	d2,lz_18A9E

		move.b	d2,$28(a0)
		bra.w	lz_189CA
; ===========================================================================

lz_18AC0:
		move.b	d2,$28(a0)
		addq.b	#2,$25(a0)
		move.b	#$28,$3C(a0)
		bra.w	lz_189CA
; ===========================================================================

obj77_MakeBall:				; XREF: obj77_ShipIndex
		cmpi.b	#$28,$3C(a0)
		bne.s	lz_18B36
		moveq	#-1,d0
		move.b	$28(a0),d0
		ext.w	d0
		bmi.s	lz_18B40
		subq.w	#2,d0
		neg.w	d0
		add.w	d0,d0
		lea	$2A(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2
		lea	(Object_Space_2).w,a1
		moveq	#$3E,d1

lz_18AFA:
		cmp.l	$3C(a1),d0
		beq.s	lz_18B40
		adda.w	#$40,a1
		dbf	d1,lz_18AFA

		move.l	a0,-(sp)
		lea	(a2),a0
		jsr	SingleObjLoad2
		movea.l	(sp)+,a0
		bne.s	lz_18B40
		move.b	#$7B,(a1)	; load spiked ball object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$20,$C(a1)
		move.b	$22(a2),$22(a1)
		move.l	a2,$3C(a1)

lz_18B36:
		subq.b	#1,$3C(a0)
		beq.s	lz_18B40
		bra.w	lz_189FE
; ===========================================================================

lz_18B40:
		subq.b	#2,$25(a0)
		bra.w	lz_189CA
; ===========================================================================

lz_18B48:				; XREF: obj77_ShipIndex
		subq.b	#1,$3C(a0)
		bmi.s	lz_18B52
		bra.w	BossDefeated
; ===========================================================================

lz_18B52:
		addq.b	#2,$25(a0)
		clr.w	$12(a0)
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		move.b	#-$18,$3C(a0)
		tst.b	(Boss_Defeated_Flags).w
		bne.s	lz_18B7C
		move.b	#1,(Boss_Defeated_Flags).w

lz_18B7C:
		bra.w	lz_189FE
; ===========================================================================

lz_18B80:				; XREF: obj77_ShipIndex
		addq.b	#1,$3C(a0)
		beq.s	lz_18B90
		bpl.s	lz_18B96
		addi.w	#$18,$12(a0)
		bra.s	lz_18BC2
; ===========================================================================

lz_18B90:
		clr.w	$12(a0)
		bra.s	lz_18BC2
; ===========================================================================

lz_18B96:
		cmpi.b	#$20,$3C(a0)
		bcs.s	lz_18BAE
		beq.s	lz_18BB4
		cmpi.b	#$2A,$3C(a0)
		bcs.s	lz_18BC2
		addq.b	#2,$25(a0)
		bra.s	lz_18BC2
; ===========================================================================

lz_18BAE:
		subq.w	#8,$12(a0)
		bra.s	lz_18BC2
; ===========================================================================

lz_18BB4:
		clr.w	$12(a0)
		bsr.w	BossEnd

lz_18BC2:
		bra.w	lz_189EE
; ===========================================================================

lz_18BC6:				; XREF: obj77_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2160,(Camera_Max_X_Pos).w
		bcc.s	lz_18BE0
		addq.w	#2,(Camera_Max_X_Pos).w
		bra.s	lz_18BE8
; ===========================================================================

lz_18BE0:
		tst.b	1(a0)
		bpl.w	obj77_Delete

lz_18BE8:
		bsr.w	BossMove
		bra.w	lz_189CA
; ===========================================================================

obj77_FaceMain:				; XREF: obj77_Index
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		cmpi.b	#6,d0
		bmi.s	lz_18C06
		moveq	#$A,d1
		bra.s	lz_18C1A
; ===========================================================================

lz_18C06:
		tst.b	$20(a1)
		bne.s	lz_18C10
		moveq	#5,d1
		bra.s	lz_18C1A
; ===========================================================================

lz_18C10:
		cmpi.b	#4,(Object_Space_1+$24).w
		bcs.s	lz_18C1A
		moveq	#4,d1

lz_18C1A:
		move.b	d1,$1C(a0)
		cmpi.b	#$A,d0
		bne.s	lz_18C32
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.w	obj77_Delete

lz_18C32:
		bra.s	lz_18C6C
; ===========================================================================

obj77_FlameMain:			; XREF: obj77_Index
		move.b	#8,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	lz_18C56
		tst.b	1(a0)
		bpl.w	obj77_Delete
		move.b	#$B,$1C(a0)
		bra.s	lz_18C6C
; ===========================================================================

lz_18C56:
		cmpi.b	#8,$25(a1)
		bgt.s	lz_18C6C
		cmpi.b	#4,$25(a1)
		blt.s	lz_18C6C
		move.b	#7,$1C(a0)

lz_18C6C:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite

lz_18C78:
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

obj77_TubeMain:				; XREF: obj77_Index
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	lz_18CB8
		tst.b	1(a0)
		bpl.w	obj77_Delete

lz_18CB8:
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#3,$1A(a0)
		bra.s	lz_18C78



; ===========================================================================
; ---------------------------------------------------------------------------
; Object 73 - Eggman (MZ)
; ---------------------------------------------------------------------------

Obj73:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj73_Index(pc,d0.w),d1
		jmp	Obj73_Index(pc,d1.w)
; ===========================================================================
Obj73_Index:	dc.w Obj73_Main-Obj73_Index
		dc.w Obj73_ShipMain-Obj73_Index
		dc.w Obj73_FaceMain-Obj73_Index
		dc.w Obj73_FlameMain-Obj73_Index
		dc.w Obj73_TubeMain-Obj73_Index

Obj73_ObjData:	dc.b 2,	0, 4		; routine number, animation, priority
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

Obj73_Main:				; XREF: Obj73_Index
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	Obj73_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj73_LoadBoss
; ===========================================================================

Obj73_Loop:
		jsr	SingleObjLoad2
		bne.s	Obj73_ShipMain
		move.b	#$73,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj73_LoadBoss:				; XREF: Obj73_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj73_Loop	; repeat sequence 3 more times

Obj73_ShipMain:
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj73_ShipIndex(pc,d0.w),d1
		jsr	Obj73_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj73_ShipIndex:dc.w loc_18302-Obj73_ShipIndex
		dc.w loc_183AA-Obj73_ShipIndex
		dc.w loc_184F6-Obj73_ShipIndex
		dc.w loc_1852C-Obj73_ShipIndex
		dc.w loc_18582-Obj73_ShipIndex
; ===========================================================================

loc_18302:				; XREF: Obj73_ShipIndex
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#2,d0
		move.w	d0,$12(a0)
		move.w	#-$100,$10(a0)
		bsr.w	BossMove
		cmpi.w	#$1910,$30(a0)
		bne.s	loc_18334
		addq.b	#2,$25(a0)
		clr.b	$28(a0)
		clr.l	$10(a0)

loc_18334:
		jsr	(RandomNumber).l
		move.b	d0,$34(a0)

loc_1833E:
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)
		cmpi.b	#4,$25(a0)
		bcc.s	locret_18390
		tst.b	$22(a0)
		bmi.s	loc_18392
		tst.b	$20(a0)
		bne.s	locret_18390
		tst.b	$3E(a0)
		bne.s	loc_18374
		move.b	#$28,$3E(a0)
		move.w	#SndID_HitBoss,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_18374:
		lea	(Normal_Palette+$22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_18382
		move.w	#$EEE,d0

loc_18382:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_18390
		move.b	#$F,$20(a0)

locret_18390:
		rts	
; ===========================================================================

loc_18392:				; XREF: loc_1833E
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#4,$25(a0)
		move.w	#$B4,$3C(a0)
		clr.w	$10(a0)
		rts	
; ===========================================================================

loc_183AA:				; XREF: Obj73_ShipIndex
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	off_183C2(pc,d0.w),d0
		jsr	off_183C2(pc,d0.w)
		andi.b	#6,$28(a0)
		bra.w	loc_1833E
; ===========================================================================
off_183C2:	dc.w loc_183CA-off_183C2
		dc.w Obj73_MakeLava2-off_183C2
		dc.w loc_183CA-off_183C2
		dc.w Obj73_MakeLava2-off_183C2
; ===========================================================================

loc_183CA:				; XREF: off_183C2
		tst.w	$10(a0)
		bne.s	loc_183FE
		moveq	#$40,d0
		cmpi.w	#$22C,$38(a0)
		beq.s	loc_183E6
		bcs.s	loc_183DE
		neg.w	d0

loc_183DE:
		move.w	d0,$12(a0)
		bra.w	BossMove
; ===========================================================================

loc_183E6:
		move.w	#$200,$10(a0)
		move.w	#$100,$12(a0)
		btst	#0,$22(a0)
		bne.s	loc_183FE
		neg.w	$10(a0)

loc_183FE:
		cmpi.b	#$18,$3E(a0)
		bcc.s	Obj73_MakeLava
		bsr.w	BossMove
		subq.w	#4,$12(a0)

Obj73_MakeLava:
		subq.b	#1,$34(a0)
		bcc.s	loc_1845C
		jsr	SingleObjLoad
		bne.s	loc_1844A
		move.b	#$14,0(a1)	; load lava ball object
		move.w	#$2E8,$C(a1)	; set Y	position
		jsr	(RandomNumber).l
		andi.l	#$FFFF,d0
		divu.w	#$50,d0
		swap	d0
		addi.w	#$1878,d0
		move.w	d0,8(a1)
		lsr.b	#7,d1
		move.w	#$FF,$28(a1)

loc_1844A:
		jsr	(RandomNumber).l
		andi.b	#$1F,d0
		addi.b	#$40,d0
		move.b	d0,$34(a0)

loc_1845C:
		btst	#0,$22(a0)
		beq.s	loc_18474
		cmpi.w	#$1910,$30(a0)
		blt.s	locret_1849C
		move.w	#$1910,$30(a0)
		bra.s	loc_18482
; ===========================================================================

loc_18474:
		cmpi.w	#$1830,$30(a0)
		bgt.s	locret_1849C
		move.w	#$1830,$30(a0)

loc_18482:
		clr.w	$10(a0)
		move.w	#-$180,$12(a0)
		cmpi.w	#$22C,$38(a0)
		bcc.s	loc_18498
		neg.w	$12(a0)

loc_18498:
		addq.b	#2,$28(a0)

locret_1849C:
		rts	
; ===========================================================================

Obj73_MakeLava2:			; XREF: off_183C2
		bsr.w	BossMove
		move.w	$38(a0),d0
		subi.w	#$22C,d0
		bgt.s	locret_184F4
		move.w	#$22C,d0
		tst.w	$12(a0)
		beq.s	loc_184EA
		clr.w	$12(a0)
		move.w	#$50,$3C(a0)
		bchg	#0,$22(a0)
		jsr	SingleObjLoad
		bne.s	loc_184EA
		move.w	$30(a0),8(a1)
		move.w	$38(a0),$C(a1)
		addi.w	#$18,$C(a1)
		move.b	#$74,(a1)	; load lava ball object
		move.b	#1,$28(a1)

loc_184EA:
		subq.w	#1,$3C(a0)
		bne.s	locret_184F4
		addq.b	#2,$28(a0)

locret_184F4:
		rts	
; ===========================================================================

loc_184F6:				; XREF: Obj73_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_18500
		bra.w	BossDefeated
; ===========================================================================

loc_18500:
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		addq.b	#2,$25(a0)
		move.w	#-$26,$3C(a0)
		tst.b	(Boss_Defeated_Flags).w
		bne.s	locret_1852A
		move.b	#1,(Boss_Defeated_Flags).w
		clr.w	$12(a0)

locret_1852A:
		rts	
; ===========================================================================

loc_1852C:				; XREF: Obj73_ShipIndex
		addq.w	#1,$3C(a0)
		beq.s	loc_18544
		bpl.s	loc_1854E
		cmpi.w	#$270,$38(a0)
		bcc.s	loc_18544
		addi.w	#$18,$12(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_18544:
		clr.w	$12(a0)
		clr.w	$3C(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_1854E:
		cmpi.w	#$30,$3C(a0)
		bcs.s	loc_18566
		beq.s	loc_1856C
		cmpi.w	#$38,$3C(a0)
		bcs.s	loc_1857A
		addq.b	#2,$25(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_18566:
		subq.w	#8,$12(a0)
		bra.s	loc_1857A
; ===========================================================================

loc_1856C:
		clr.w	$12(a0)
		bsr.w	BossEnd

loc_1857A:
		bsr.w	BossMove
		bra.w	loc_1833E
; ===========================================================================

loc_18582:				; XREF: Obj73_ShipIndex
		move.w	#$500,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$1960,(Camera_Max_X_Pos).w
		bcc.s	loc_1859C
		addq.w	#2,(Camera_Max_X_Pos).w
		bra.s	loc_185A2
; ===========================================================================

loc_1859C:
		tst.b	1(a0)
		bpl.s	Obj73_ShipDel

loc_185A2:
		bsr.w	BossMove
		bra.w	loc_1833E
; ===========================================================================

Obj73_ShipDel:
		jmp	DeleteObject
; ===========================================================================

Obj73_FaceMain:				; XREF: Obj73_Index
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		subq.w	#2,d0
		bne.s	loc_185D2
		btst	#1,$28(a1)
		beq.s	loc_185DA
		tst.w	$12(a1)
		bne.s	loc_185DA
		moveq	#4,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185D2:
		subq.b	#2,d0
		bmi.s	loc_185DA
		moveq	#$A,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185DA:
		tst.b	$20(a1)
		bne.s	loc_185E4
		moveq	#5,d1
		bra.s	loc_185EE
; ===========================================================================

loc_185E4:
		cmpi.b	#4,(Object_Space_1+$24).w
		bcs.s	loc_185EE
		moveq	#4,d1

loc_185EE:
		move.b	d1,$1C(a0)
		subq.b	#4,d0
		bne.s	loc_18602
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj73_FaceDel

loc_18602:
		bra.s	Obj73_Display
; ===========================================================================

Obj73_FaceDel:
		jmp	DeleteObject
; ===========================================================================

Obj73_FlameMain:			; XREF: Obj73_Index
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#8,$25(a1)
		blt.s	loc_1862A
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj73_FlameDel
		bra.s	loc_18636
; ===========================================================================

loc_1862A:
		tst.w	$10(a1)
		beq.s	loc_18636
		move.b	#8,$1C(a0)

loc_18636:
		bra.s	Obj73_Display
; ===========================================================================

Obj73_FlameDel:				; XREF: Obj73_FlameMain
		jmp	DeleteObject
; ===========================================================================

Obj73_Display:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite

loc_1864A:
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

Obj73_TubeMain:				; XREF: Obj73_Index
		movea.l	$34(a0),a1
		cmpi.b	#8,$25(a1)
		bne.s	loc_18688
		tst.b	1(a0)
		bpl.s	Obj73_TubeDel

loc_18688:
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#4,$1A(a0)
		bra.s	loc_1864A
; ===========================================================================

Obj73_TubeDel:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 74 - lava that	Eggman drops (MZ)
; ---------------------------------------------------------------------------

Obj74:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj74_Index(pc,d0.w),d0
		jsr	Obj74_Index(pc,d0.w)
		jmp	DisplaySprite
; ===========================================================================
Obj74_Index:	dc.w Obj74_Main-Obj74_Index
		dc.w Obj74_Action-Obj74_Index
		dc.w loc_18886-Obj74_Index
		dc.w Obj74_Delete3-Obj74_Index
; ===========================================================================

Obj74_Main:				; XREF: Obj74_Index
		move.b	#8,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_obj14,4(a0)
		move.w	#$345,2(a0)
		move.b	#4,1(a0)
		move.b	#5,$18(a0)
		move.w	$C(a0),$38(a0)
		move.b	#8,$19(a0)
		addq.b	#2,$24(a0)
		tst.b	$28(a0)
		bne.s	loc_1870A
		move.b	#$8B,$20(a0)
		addq.b	#2,$24(a0)
		bra.w	loc_18886
; ===========================================================================

loc_1870A:
		move.b	#$1E,$29(a0)
		move.w	#SndID_Fireball,d0
		jsr	(PlaySound_Special).l ;	play lava sound

Obj74_Action:				; XREF: Obj74_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj74_Index2(pc,d0.w),d0
		jsr	Obj74_Index2(pc,d0.w)
		jsr	ObjectMove
		lea	(Ani_obj14).l,a1
		jsr	AnimateSprite
		cmpi.w	#$2E8,$C(a0)
		bhi.s	Obj74_Delete
		rts	
; ===========================================================================

Obj74_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj74_Index2:	dc.w Obj74_Drop-Obj74_Index2
		dc.w Obj74_MakeFlame-Obj74_Index2
		dc.w Obj74_Duplicate-Obj74_Index2
		dc.w Obj74_FallEdge-Obj74_Index2
; ===========================================================================

Obj74_Drop:				; XREF: Obj74_Index2
		bset	#1,$22(a0)
		subq.b	#1,$29(a0)
		bpl.s	locret_18780
		move.b	#$8B,$20(a0)
		clr.b	$28(a0)
		addi.w	#$18,$12(a0)
		bclr	#1,$22(a0)
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_18780
		addq.b	#2,$25(a0)

locret_18780:
		rts	
; ===========================================================================

Obj74_MakeFlame:			; XREF: Obj74_Index2
		subq.w	#2,$C(a0)
		bset	#7,2(a0)
		move.w	#$A0,$10(a0)
		clr.w	$12(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#3,$29(a0)
		jsr	SingleObjLoad2
		bne.s	loc_187CA
		lea	(a1),a3
		lea	(a0),a2
		moveq	#3,d0

Obj74_Loop:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d0,Obj74_Loop

		neg.w	$10(a1)
		addq.b	#2,$25(a1)

loc_187CA:
		addq.b	#2,$25(a0)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj74_Duplicate2:			; XREF: Obj74_Duplicate
		jsr	SingleObjLoad2
		bne.s	locret_187EE
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	#$74,(a1)
		move.w	#$67,$28(a1)

locret_187EE:
		rts	
; End of function Obj74_Duplicate2

; ===========================================================================

Obj74_Duplicate:			; XREF: Obj74_Index2
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	loc_18826
		move.w	8(a0),d0
		cmpi.w	#$1940,d0
		bgt.s	loc_1882C
		move.w	$30(a0),d1
		cmp.w	d0,d1
		beq.s	loc_1881E
		andi.w	#$10,d0
		andi.w	#$10,d1
		cmp.w	d0,d1
		beq.s	loc_1881E
		bsr.s	Obj74_Duplicate2
		move.w	8(a0),$32(a0)

loc_1881E:
		move.w	8(a0),$30(a0)
		rts	
; ===========================================================================

loc_18826:
		addq.b	#2,$25(a0)
		rts	
; ===========================================================================

loc_1882C:
		addq.b	#2,$24(a0)
		rts	
; ===========================================================================

Obj74_FallEdge:				; XREF: Obj74_Index2
		bclr	#1,$22(a0)
		addi.w	#$24,$12(a0)	; make flame fall
		move.w	8(a0),d0
		sub.w	$32(a0),d0
		bpl.s	loc_1884A
		neg.w	d0

loc_1884A:
		cmpi.w	#$12,d0
		bne.s	loc_18856
		bclr	#7,2(a0)

loc_18856:
		bsr.w	ObjHitFloor
		tst.w	d1
		bpl.s	locret_1887E
		subq.b	#1,$29(a0)
		beq.s	Obj74_Delete2
		clr.w	$12(a0)
		move.w	$32(a0),8(a0)
		move.w	$38(a0),$C(a0)
		bset	#7,2(a0)
		subq.b	#2,$25(a0)

locret_1887E:
		rts	
; ===========================================================================

Obj74_Delete2:
		jmp	DeleteObject
; ===========================================================================

loc_18886:				; XREF: Obj74_Index
		bset	#7,2(a0)
		subq.b	#1,$29(a0)
		bne.s	Obj74_Animate
		move.b	#1,$1C(a0)
		subq.w	#4,$C(a0)
		clr.b	$20(a0)

Obj74_Animate:
		lea	(Ani_obj14).l,a1
		jmp	AnimateSprite
; ===========================================================================

Obj74_Delete3:				; XREF: Obj74_Index
		jmp	DeleteObject
; ===========================================================================

Obj7A_Delete:
		jmp	DeleteObject

Obj77_Delete:
		jmp	DeleteObject

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------

Obj7A:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7A_Index(pc,d0.w),d1
		jmp	Obj7A_Index(pc,d1.w)
; ===========================================================================
Obj7A_Index:	dc.w Obj7A_Main-Obj7A_Index
		dc.w Obj7A_ShipMain-Obj7A_Index
		dc.w Obj7A_FaceMain-Obj7A_Index
		dc.w Obj7A_FlameMain-Obj7A_Index
		dc.w Obj7A_TubeMain-Obj7A_Index

Obj7A_ObjData:	dc.b 2,	0, 4		; routine number, animation, priority
		dc.b 4,	1, 4
		dc.b 6,	7, 4
		dc.b 8,	0, 3
; ===========================================================================

Obj7A_Main:				; XREF: Obj7A_Index
		move.w	#$2188,8(a0)
		move.w	#$228,$C(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	Obj7A_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj7A_LoadBoss
; ===========================================================================

Obj7A_Loop:
		jsr	SingleObjLoad2
		bne.s	loc_1895C
		move.b	#$7A,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj7A_LoadBoss:				; XREF: Obj7A_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj7A_Loop	; repeat sequence 3 more times

loc_1895C:
		lea	(Object_Space_2).w,a1
		lea	$2A(a0),a2
		moveq	#$5E,d0
		moveq	#$3E,d1

loc_18968:
		cmp.b	(a1),d0
		bne.s	loc_18974
		tst.b	$28(a1)
		beq.s	loc_18974
		move.w	a1,(a2)+

loc_18974:
		adda.w	#$40,a1
		dbf	d1,loc_18968

Obj7A_ShipMain:				; XREF: Obj7A_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj7A_ShipIndex(pc,d0.w),d0
		jsr	Obj7A_ShipIndex(pc,d0.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj7A_ShipIndex:dc.w loc_189B8-Obj7A_ShipIndex
		dc.w loc_18A5E-Obj7A_ShipIndex
		dc.w Obj7A_MakeBall-Obj7A_ShipIndex
		dc.w loc_18B48-Obj7A_ShipIndex
		dc.w loc_18B80-Obj7A_ShipIndex
		dc.w loc_18BC6-Obj7A_ShipIndex
; ===========================================================================

loc_189B8:				; XREF: Obj7A_ShipIndex
		move.w	#-$100,$10(a0)
		cmpi.w	#$2120,$30(a0)
		bcc.s	loc_189CA
		addq.b	#2,$25(a0)

loc_189CA:
		bsr.w	BossMove
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#6,d0
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		bra.s	loc_189FE
; ===========================================================================

loc_189EE:
		bsr.w	BossMove
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)

loc_189FE:
		cmpi.b	#6,$25(a0)
		bcc.s	locret_18A44
		tst.b	$22(a0)
		bmi.s	loc_18A46
		tst.b	$20(a0)
		bne.s	locret_18A44
		tst.b	$3E(a0)
		bne.s	loc_18A28
		move.b	#$20,$3E(a0)
		move.w	#SndID_HitBoss,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_18A28:
		lea	(Normal_Palette+$22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_18A36
		move.w	#$EEE,d0

loc_18A36:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_18A44
		move.b	#$F,$20(a0)

locret_18A44:
		rts	
; ===========================================================================

loc_18A46:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,$25(a0)
		move.b	#$78,$3C(a0)
		clr.w	$10(a0)
		rts	
; ===========================================================================

loc_18A5E:				; XREF: Obj7A_ShipIndex
		move.w	$30(a0),d0
		move.w	#$200,$10(a0)
		btst	#0,$22(a0)
		bne.s	loc_18A7C
		neg.w	$10(a0)
		cmpi.w	#$2008,d0
		bgt.s	loc_18A88
		bra.s	loc_18A82
; ===========================================================================

loc_18A7C:
		cmpi.w	#$2138,d0
		blt.s	loc_18A88

loc_18A82:
		bchg	#0,$22(a0)

loc_18A88:
		move.w	8(a0),d0
		moveq	#-1,d1
		moveq	#2,d2
		lea	$2A(a0),a2
		moveq	#$28,d4
		tst.w	$10(a0)
		bpl.s	loc_18A9E
		neg.w	d4

loc_18A9E:
		move.w	(a2)+,d1
		movea.l	d1,a3
		btst	#3,$22(a3)
		bne.s	loc_18AB4
		move.w	8(a3),d3
		add.w	d4,d3
		sub.w	d0,d3
		beq.s	loc_18AC0

loc_18AB4:
		dbf	d2,loc_18A9E

		move.b	d2,$28(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18AC0:
		move.b	d2,$28(a0)
		addq.b	#2,$25(a0)
		move.b	#$28,$3C(a0)
		bra.w	loc_189CA
; ===========================================================================

Obj7A_MakeBall:				; XREF: Obj7A_ShipIndex
		cmpi.b	#$28,$3C(a0)
		bne.s	loc_18B36
		moveq	#-1,d0
		move.b	$28(a0),d0
		ext.w	d0
		bmi.s	loc_18B40
		subq.w	#2,d0
		neg.w	d0
		add.w	d0,d0
		lea	$2A(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2
		lea	(Object_Space_2).w,a1
		moveq	#$3E,d1

loc_18AFA:
		cmp.l	$3C(a1),d0
		beq.s	loc_18B40
		adda.w	#$40,a1
		dbf	d1,loc_18AFA

		move.l	a0,-(sp)
		lea	(a2),a0
		jsr	SingleObjLoad2
		movea.l	(sp)+,a0
		bne.s	loc_18B40
		move.b	#$7B,(a1)	; load spiked ball object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		addi.w	#$20,$C(a1)
		move.b	$22(a2),$22(a1)
		move.l	a2,$3C(a1)

loc_18B36:
		subq.b	#1,$3C(a0)
		beq.s	loc_18B40
		bra.w	loc_189FE
; ===========================================================================

loc_18B40:
		subq.b	#2,$25(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18B48:				; XREF: Obj7A_ShipIndex
		subq.b	#1,$3C(a0)
		bmi.s	loc_18B52
		bra.w	BossDefeated
; ===========================================================================

loc_18B52:
		addq.b	#2,$25(a0)
		clr.w	$12(a0)
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		move.b	#-$18,$3C(a0)
		tst.b	(Boss_Defeated_Flags).w
		bne.s	loc_18B7C
		move.b	#1,(Boss_Defeated_Flags).w

loc_18B7C:
		bra.w	loc_189FE
; ===========================================================================

loc_18B80:				; XREF: Obj7A_ShipIndex
		addq.b	#1,$3C(a0)
		beq.s	loc_18B90
		bpl.s	loc_18B96
		addi.w	#$18,$12(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18B90:
		clr.w	$12(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18B96:
		cmpi.b	#$20,$3C(a0)
		bcs.s	loc_18BAE
		beq.s	loc_18BB4
		cmpi.b	#$2A,$3C(a0)
		bcs.s	loc_18BC2
		addq.b	#2,$25(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18BAE:
		subq.w	#8,$12(a0)
		bra.s	loc_18BC2
; ===========================================================================

loc_18BB4:
		clr.w	$12(a0)
		bsr.w	BossEnd

loc_18BC2:
		bra.w	loc_189EE
; ===========================================================================

loc_18BC6:				; XREF: Obj7A_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2160,(Camera_Max_X_Pos).w
		bcc.s	loc_18BE0
		addq.w	#2,(Camera_Max_X_Pos).w
		bra.s	loc_18BE8
; ===========================================================================

loc_18BE0:
		tst.b	1(a0)
		bpl.w	Obj7A_Delete

loc_18BE8:
		bsr.w	BossMove
		bra.w	loc_189CA
; ===========================================================================

Obj7A_FaceMain:				; XREF: Obj7A_Index
		moveq	#0,d0
		moveq	#1,d1
		movea.l	$34(a0),a1
		move.b	$25(a1),d0
		cmpi.b	#6,d0
		bmi.s	loc_18C06
		moveq	#$A,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C06:
		tst.b	$20(a1)
		bne.s	loc_18C10
		moveq	#5,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C10:
		cmpi.b	#4,(Object_Space_1+$24).w
		bcs.s	loc_18C1A
		moveq	#4,d1

loc_18C1A:
		move.b	d1,$1C(a0)
		cmpi.b	#$A,d0
		bne.s	loc_18C32
		move.b	#6,$1C(a0)
		tst.b	1(a0)
		bpl.w	Obj7A_Delete

loc_18C32:
		bra.s	loc_18C6C
; ===========================================================================

Obj7A_FlameMain:			; XREF: Obj7A_Index
		move.b	#8,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_18C56
		tst.b	1(a0)
		bpl.w	Obj7A_Delete
		move.b	#$B,$1C(a0)
		bra.s	loc_18C6C
; ===========================================================================

loc_18C56:
		cmpi.b	#8,$25(a1)
		bgt.s	loc_18C6C
		cmpi.b	#4,$25(a1)
		blt.s	loc_18C6C
		move.b	#7,$1C(a0)

loc_18C6C:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite

loc_18C78:
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#-4,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

Obj7A_TubeMain:				; XREF: Obj7A_Index
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_18CB8
		tst.b	1(a0)
		bpl.w	Obj7A_Delete

loc_18CB8:
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#3,$1A(a0)
		bra.s	loc_18C78
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 7B - exploding	spikeys	that Eggman drops (SLZ)
; ---------------------------------------------------------------------------

Obj7B:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj7B_Index(pc,d0.w),d0
		jsr	Obj7B_Index(pc,d0.w)
		move.w	$30(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		bmi.w	Obj7A_Delete
		cmpi.w	#$280,d0
		bhi.w	Obj7A_Delete
		jmp	DisplaySprite
; ===========================================================================
Obj7B_Index:	dc.w Obj7B_Main-Obj7B_Index
		dc.w Obj7B_Fall-Obj7B_Index
		dc.w loc_18DC6-Obj7B_Index
		dc.w loc_18EAA-Obj7B_Index
		dc.w Obj7B_Explode-Obj7B_Index
		dc.w Obj7B_MoveFrag-Obj7B_Index
; ===========================================================================

Obj7B_Main:				; XREF: Obj7B_Index
		move.l	#Map_obj5Ea,4(a0)
		move.w	#$518,2(a0)
		move.b	#1,$1A(a0)
		ori.b	#4,1(a0)
		move.b	#4,$18(a0)
		move.b	#$8B,$20(a0)
		move.b	#$C,$19(a0)
		movea.l	$3C(a0),a1
		move.w	8(a1),$30(a0)
		move.w	$C(a1),$34(a0)
		bset	#0,$22(a0)
		move.w	8(a0),d0
		cmp.w	8(a1),d0
		bgt.s	loc_18D68
		bclr	#0,$22(a0)
		move.b	#2,$3A(a0)

loc_18D68:
		addq.b	#2,$24(a0)

Obj7B_Fall:				; XREF: Obj7B_Index
		jsr	ObjectMoveAndFall
		movea.l	$3C(a0),a1
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_18D8E
		addq.w	#2,d0

loc_18D8E:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	$C(a0),d1
		bgt.s	locret_18DC4
		movea.l	$3C(a0),a1
		moveq	#2,d1
		btst	#0,$22(a0)
		beq.s	loc_18DAE
		moveq	#0,d1

loc_18DAE:
		move.w	#$F0,$28(a0)
		move.b	#10,$1F(a0)	; set frame duration to	10 frames
		move.b	$1F(a0),$1E(a0)
		bra.w	loc_18FA2
; ===========================================================================

locret_18DC4:
		rts	
; ===========================================================================

loc_18DC6:				; XREF: Obj7B_Index
		movea.l	$3C(a0),a1
		moveq	#0,d0
		move.b	$3A(a0),d0
		sub.b	$3A(a1),d0
		beq.s	loc_18E2A
		bcc.s	loc_18DDA
		neg.b	d0

loc_18DDA:
		move.w	#-$818,d1
		move.w	#-$114,d2
		cmpi.b	#1,d0
		beq.s	loc_18E00
		move.w	#-$960,d1
		move.w	#-$F4,d2
		cmpi.w	#$9C0,$38(a1)
		blt.s	loc_18E00
		move.w	#-$A20,d1
		move.w	#-$80,d2

loc_18E00:
		move.w	d1,$12(a0)
		move.w	d2,$10(a0)
		move.w	8(a0),d0
		sub.w	$30(a0),d0
		bcc.s	loc_18E16
		neg.w	$10(a0)

loc_18E16:
		move.b	#1,$1A(a0)
		move.w	#$20,$28(a0)
		addq.b	#2,$24(a0)
		bra.w	loc_18EAA
; ===========================================================================

loc_18E2A:				; XREF: loc_18DC6
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	#$28,d2
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_18E48
		neg.w	d2
		addq.w	#2,d0

loc_18E48:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		move.w	d1,$C(a0)
		add.w	$30(a0),d2
		move.w	d2,8(a0)
		clr.w	$E(a0)
		clr.w	$A(a0)
		subq.w	#1,$28(a0)
		bne.s	loc_18E7A
		move.w	#$20,$28(a0)
		move.b	#8,$24(a0)
		rts	
; ===========================================================================

loc_18E7A:
		cmpi.w	#$78,$28(a0)
		bne.s	loc_18E88
		move.b	#5,$1F(a0)

loc_18E88:
		cmpi.w	#$3C,$28(a0)
		bne.s	loc_18E96
		move.b	#2,$1F(a0)

loc_18E96:
		subq.b	#1,$1E(a0)
		bgt.s	locret_18EA8
		bchg	#0,$1A(a0)
		move.b	$1F(a0),$1E(a0)

locret_18EA8:
		rts	
; ===========================================================================

loc_18EAA:				; XREF: Obj7B_Index
		lea	(Object_Space_2).w,a1
		moveq	#$7A,d0
		moveq	#$40,d1
		moveq	#$3E,d2

loc_18EB4:
		cmp.b	(a1),d0
		beq.s	loc_18EC0
		adda.w	d1,a1
		dbf	d2,loc_18EB4

		bra.s	loc_18F38
; ===========================================================================

loc_18EC0:
		move.w	8(a1),d0
		move.w	$C(a1),d1
		move.w	8(a0),d2
		move.w	$C(a0),d3
		lea	byte_19022(pc),a2
		lea	byte_19026(pc),a3
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d0,d2
		bcs.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d0
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d2
		cmp.w	d2,d0
		bcs.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d1,d3
		bcs.s	loc_18F38
		move.b	(a2)+,d4
		ext.w	d4
		add.w	d4,d1
		move.b	(a3)+,d4
		ext.w	d4
		add.w	d4,d3
		cmp.w	d3,d1
		bcs.s	loc_18F38
		addq.b	#2,$24(a0)
		clr.w	$28(a0)
		clr.b	$20(a1)
		subq.b	#1,$21(a1)
		bne.s	loc_18F38
		bset	#7,$22(a1)
		clr.w	$10(a0)
		clr.w	$12(a0)

loc_18F38:
		tst.w	$12(a0)
		bpl.s	loc_18F5C
		jsr	ObjectMoveAndFall
		move.w	$34(a0),d0
		subi.w	#$2F,d0
		cmp.w	$C(a0),d0
		bgt.s	loc_18F58
		jsr	ObjectMoveAndFall

loc_18F58:
		bra.w	loc_18E7A
; ===========================================================================

loc_18F5C:
		jsr	ObjectMoveAndFall
		movea.l	$3C(a0),a1
		lea	(word_19018).l,a2
		moveq	#0,d0
		move.b	$1A(a1),d0
		move.w	8(a0),d1
		sub.w	$30(a0),d1
		bcc.s	loc_18F7E
		addq.w	#2,d0

loc_18F7E:
		add.w	d0,d0
		move.w	$34(a0),d1
		add.w	(a2,d0.w),d1
		cmp.w	$C(a0),d1
		bgt.s	loc_18F58
		movea.l	$3C(a0),a1
		moveq	#2,d1
		tst.w	$10(a0)
		bmi.s	loc_18F9C
		moveq	#0,d1

loc_18F9C:
		move.w	#0,$28(a0)

loc_18FA2:
		move.b	d1,$3A(a1)
		move.b	d1,$3A(a0)
		cmp.b	$1A(a1),d1
		beq.s	loc_19008
		bclr	#3,$22(a1)
		beq.s	loc_19008
		clr.b	$25(a1)
		move.b	#2,$24(a1)
		lea	(Object_RAM).w,a2
		move.w	$12(a0),$12(a2)
		neg.w	$12(a2)
		cmpi.b	#1,$1A(a1)
		bne.s	loc_18FDC
		asr	$12(a2)

loc_18FDC:
		bset	#1,$22(a2)
		bclr	#3,$22(a2)
		clr.b	$3C(a2)
		move.l	a0,-(sp)
		lea	(a2),a0
	;	jsr	Obj01_ChkRoll
		move.b	#$10,$1C(a2)	; change Sonic's animation to "spring" ($10)
		movea.l	(sp)+,a0
		move.b	#2,$24(a2)
		move.w	#SndID_Spring,d0
		jsr	(PlaySound_Special).l ;	play "spring" sound

loc_19008:
		clr.w	$10(a0)
		clr.w	$12(a0)
		addq.b	#2,$24(a0)
		bra.w	loc_18E7A
; ===========================================================================
word_19018:	dc.w $FFF8, $FFE4, $FFD1, $FFE4, $FFF8
		even
byte_19022:	dc.b $E8, $30, $E8, $30
		even
byte_19026:	dc.b 8,	$F0, 8,	$F0
		even
; ===========================================================================

Obj7B_Explode:				; XREF: Obj7B_Index
		move.b	#$3F,(a0)
		clr.b	$24(a0)
		cmpi.w	#$20,$28(a0)
		beq.s	Obj7B_MakeFrag
		rts	
; ===========================================================================

Obj7B_MakeFrag:
		move.w	$34(a0),$C(a0)
		moveq	#3,d1
		lea	Obj7B_FragSpeed(pc),a2

Obj7B_Loop:
		jsr	SingleObjLoad
		bne.s	loc_1909A
		move.b	#$7B,(a1)	; load shrapnel	object
		move.b	#$A,$24(a1)
		move.l	#Map_obj7B,4(a1)
		move.b	#3,$18(a1)
		move.w	#$518,2(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	(a2)+,$10(a1)
		move.w	(a2)+,$12(a1)
		move.b	#$98,$20(a1)
		ori.b	#4,1(a1)
		bset	#7,1(a1)
		move.b	#$C,$19(a1)

loc_1909A:
		dbf	d1,Obj7B_Loop	; repeat sequence 3 more times

		rts	
; ===========================================================================
Obj7B_FragSpeed:dc.w $FF00, $FCC0	; horizontal, vertical
		dc.w $FF60, $FDC0
		dc.w $100, $FCC0
		dc.w $A0, $FDC0
; ===========================================================================

Obj7B_MoveFrag:				; XREF: Obj7B_Index
		jsr	ObjectMove
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$34(a0)
		addi.w	#$18,$12(a0)
		moveq	#4,d0
		and.w	(V_Int_Counter+2).w,d0
		lsr.w	#2,d0
		move.b	d0,$1A(a0)
		tst.b	1(a0)
		bpl.w	Obj7A_Delete
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - exploding spikeys that the SLZ boss	drops
; ---------------------------------------------------------------------------
Map_obj7B:
	include "mappings/sprite/obj7B.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 75 - Eggman (SYZ)
; ---------------------------------------------------------------------------

Obj75:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj75_Index(pc,d0.w),d1
		jmp	Obj75_Index(pc,d1.w)
; ===========================================================================
Obj75_Index:	dc.w Obj75_Main-Obj75_Index
		dc.w Obj75_ShipMain-Obj75_Index
		dc.w Obj75_FaceMain-Obj75_Index
		dc.w Obj75_FlameMain-Obj75_Index
		dc.w Obj75_SpikeMain-Obj75_Index

Obj75_ObjData:	dc.b 2,	0, 5		; routine number, animation, priority
		dc.b 4,	1, 5
		dc.b 6,	7, 5
		dc.b 8,	0, 5
; ===========================================================================

Obj75_Main:				; XREF: Obj75_Index
		move.w	#$2DB0,8(a0)
		move.w	#$4DA,$C(a0)
		move.w	8(a0),$30(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$F,$20(a0)
		move.b	#8,$21(a0)	; set number of	hits to	8
		lea	Obj75_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	Obj75_LoadBoss
; ===========================================================================

Obj75_Loop:
		jsr	SingleObjLoad2
		bne.s	Obj75_ShipMain
		move.b	#$75,(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Obj75_LoadBoss:				; XREF: Obj75_Main
		bclr	#0,$22(a0)
		clr.b	$25(a1)
		move.b	(a2)+,$24(a1)
		move.b	(a2)+,$1C(a1)
		move.b	(a2)+,$18(a1)
		move.l	#Map_Eggman,4(a1)
		move.w	#$400,2(a1)
		move.b	#4,1(a1)
		move.b	#$20,$19(a1)
		move.l	a0,$34(a1)
		dbf	d1,Obj75_Loop	; repeat sequence 3 more times

Obj75_ShipMain:				; XREF: Obj75_Index
		moveq	#0,d0
		move.b	$25(a0),d0
		move.w	Obj75_ShipIndex(pc,d0.w),d1
		jsr	Obj75_ShipIndex(pc,d1.w)
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================
Obj75_ShipIndex:dc.w loc_191CC-Obj75_ShipIndex,	loc_19270-Obj75_ShipIndex
		dc.w loc_192EC-Obj75_ShipIndex,	loc_19474-Obj75_ShipIndex
		dc.w loc_194AC-Obj75_ShipIndex,	loc_194F2-Obj75_ShipIndex
; ===========================================================================

loc_191CC:				; XREF: Obj75_ShipIndex
		move.w	#-$100,$10(a0)
		cmpi.w	#$2D38,$30(a0)
		bcc.s	loc_191DE
		addq.b	#2,$25(a0)

loc_191DE:
		move.b	$3F(a0),d0
		addq.b	#2,$3F(a0)
		jsr	(CalcSine).l
		asr.w	#2,d0
		move.w	d0,$12(a0)

loc_191F2:
		bsr.w	BossMove
		move.w	$38(a0),$C(a0)
		move.w	$30(a0),8(a0)

loc_19202:
		move.w	8(a0),d0
		subi.w	#$2C00,d0
		lsr.w	#5,d0
		move.b	d0,$34(a0)
		cmpi.b	#6,$25(a0)
		bcc.s	locret_19256
		tst.b	$22(a0)
		bmi.s	loc_19258
		tst.b	$20(a0)
		bne.s	locret_19256
		tst.b	$3E(a0)
		bne.s	loc_1923A
		move.b	#$20,$3E(a0)
		move.w	#SndID_HitBoss,d0
		jsr	(PlaySound_Special).l ;	play boss damage sound

loc_1923A:
		lea	(Normal_Palette+$22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_19248
		move.w	#$EEE,d0

loc_19248:
		move.w	d0,(a1)
		subq.b	#1,$3E(a0)
		bne.s	locret_19256
		move.b	#$F,$20(a0)

locret_19256:
		rts	
; ===========================================================================

loc_19258:				; XREF: loc_19202
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,$25(a0)
		move.w	#$B4,$3C(a0)
		clr.w	$10(a0)
		rts	
; ===========================================================================

loc_19270:				; XREF: Obj75_ShipIndex
		move.w	$30(a0),d0
		move.w	#$140,$10(a0)
		btst	#0,$22(a0)
		bne.s	loc_1928E
		neg.w	$10(a0)
		cmpi.w	#$2C08,d0
		bgt.s	loc_1929E
		bra.s	loc_19294
; ===========================================================================

loc_1928E:
		cmpi.w	#$2D38,d0
		blt.s	loc_1929E

loc_19294:
		bchg	#0,$22(a0)
		clr.b	$3D(a0)

loc_1929E:
		subi.w	#$2C10,d0
		andi.w	#$1F,d0
		subi.w	#$1F,d0
		bpl.s	loc_192AE
		neg.w	d0

loc_192AE:
		subq.w	#1,d0
		bgt.s	loc_192E8
		tst.b	$3D(a0)
		bne.s	loc_192E8
		move.w	(Object_Space_18).w,d1
		subi.w	#$2C00,d1
		asr.w	#5,d1
		cmp.b	$34(a0),d1
		bne.s	loc_192E8
		moveq	#0,d0
		move.b	$34(a0),d0
		asl.w	#5,d0
		addi.w	#$2C10,d0
		move.w	d0,$30(a0)
		bsr.w	Obj75_FindBlocks
		addq.b	#2,$25(a0)
		clr.w	$28(a0)
		clr.w	$10(a0)

loc_192E8:
		bra.w	loc_191DE
; ===========================================================================

loc_192EC:				; XREF: Obj75_ShipIndex
		moveq	#0,d0
		move.b	$28(a0),d0
		move.w	off_192FA(pc,d0.w),d0
		jmp	off_192FA(pc,d0.w)
; ===========================================================================
off_192FA:	dc.w loc_19302-off_192FA
		dc.w loc_19348-off_192FA
		dc.w loc_1938E-off_192FA
		dc.w loc_193D0-off_192FA
; ===========================================================================

loc_19302:				; XREF: off_192FA
		move.w	#$180,$12(a0)
		move.w	$38(a0),d0
		cmpi.w	#$556,d0
		bcs.s	loc_19344
		move.w	#$556,$38(a0)
		clr.w	$3C(a0)
		moveq	#-1,d0
		move.w	$36(a0),d0
		beq.s	loc_1933C
		movea.l	d0,a1
		move.b	#-1,$29(a1)
		move.b	#-1,$29(a0)
		move.l	a0,$34(a1)
		move.w	#$32,$3C(a0)

loc_1933C:
		clr.w	$12(a0)
		addq.b	#2,$28(a0)

loc_19344:
		bra.w	loc_191F2
; ===========================================================================

loc_19348:				; XREF: off_192FA
		subq.w	#1,$3C(a0)
		bpl.s	loc_19366
		addq.b	#2,$28(a0)
		move.w	#-$800,$12(a0)
		tst.w	$36(a0)
		bne.s	loc_19362
		asr	$12(a0)

loc_19362:
		moveq	#0,d0
		bra.s	loc_1937C
; ===========================================================================

loc_19366:
		moveq	#0,d0
		cmpi.w	#$1E,$3C(a0)
		bgt.s	loc_1937C
		moveq	#2,d0
		btst	#1,$3D(a0)
		beq.s	loc_1937C
		neg.w	d0

loc_1937C:
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)
		bra.w	loc_19202
; ===========================================================================

loc_1938E:				; XREF: off_192FA
		move.w	#$4DA,d0
		tst.w	$36(a0)
		beq.s	loc_1939C
		subi.w	#$18,d0

loc_1939C:
		cmp.w	$38(a0),d0
		blt.s	loc_193BE
		move.w	#8,$3C(a0)
		tst.w	$36(a0)
		beq.s	loc_193B4
		move.w	#$2D,$3C(a0)

loc_193B4:
		addq.b	#2,$28(a0)
		clr.w	$12(a0)
		bra.s	loc_193CC
; ===========================================================================

loc_193BE:
		cmpi.w	#-$40,$12(a0)
		bge.s	loc_193CC
		addi.w	#$C,$12(a0)

loc_193CC:
		bra.w	loc_191F2
; ===========================================================================

loc_193D0:				; XREF: off_192FA
		subq.w	#1,$3C(a0)
		bgt.s	loc_19406
		bmi.s	loc_193EE
		moveq	#-1,d0
		move.w	$36(a0),d0
		beq.s	loc_193E8
		movea.l	d0,a1
		move.b	#$A,$29(a1)

loc_193E8:
		clr.w	$36(a0)
		bra.s	loc_19406
; ===========================================================================

loc_193EE:
		cmpi.w	#-$1E,$3C(a0)
		bne.s	loc_19406
		clr.b	$29(a0)
		subq.b	#2,$25(a0)
		move.b	#-1,$3D(a0)
		bra.s	loc_19446
; ===========================================================================

loc_19406:
		moveq	#1,d0
		tst.w	$36(a0)
		beq.s	loc_19410
		moveq	#2,d0

loc_19410:
		cmpi.w	#$4DA,$38(a0)
		beq.s	loc_19424
		blt.s	loc_1941C
		neg.w	d0

loc_1941C:
		tst.w	$36(a0)
		add.w	d0,$38(a0)

loc_19424:
		moveq	#0,d0
		tst.w	$36(a0)
		beq.s	loc_19438
		moveq	#2,d0
		btst	#0,$3D(a0)
		beq.s	loc_19438
		neg.w	d0

loc_19438:
		add.w	$38(a0),d0
		move.w	d0,$C(a0)
		move.w	$30(a0),8(a0)

loc_19446:
		bra.w	loc_19202

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj75_FindBlocks:			; XREF: loc_192AE
		clr.w	$36(a0)
		lea	(Object_Space_2).w,a1
		moveq	#$3E,d0
		moveq	#$76,d1
		move.b	$34(a0),d2

Obj75_FindLoop:
		cmp.b	(a1),d1		; is object a SYZ boss block?
		bne.s	loc_1946A	; if not, branch
		cmp.b	$28(a1),d2
		bne.s	loc_1946A
		move.w	a1,$36(a0)
		bra.s	locret_19472
; ===========================================================================

loc_1946A:
		lea	$40(a1),a1	; next object RAM entry
		dbf	d0,Obj75_FindLoop

locret_19472:
		rts	
; End of function Obj75_FindBlocks

; ===========================================================================

loc_19474:				; XREF: Obj75_ShipIndex
		subq.w	#1,$3C(a0)
		bmi.s	loc_1947E
		bra.w	BossDefeated
; ===========================================================================

loc_1947E:
		addq.b	#2,$25(a0)
		clr.w	$12(a0)
		bset	#0,$22(a0)
		bclr	#7,$22(a0)
		clr.w	$10(a0)
		move.w	#-1,$3C(a0)
		tst.b	(Boss_Defeated_Flags).w
		bne.s	loc_194A8
		move.b	#1,(Boss_Defeated_Flags).w

loc_194A8:
		bra.w	loc_19202
; ===========================================================================

loc_194AC:				; XREF: Obj75_ShipIndex
		addq.w	#1,$3C(a0)
		beq.s	loc_194BC
		bpl.s	loc_194C2
		addi.w	#$18,$12(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194BC:
		clr.w	$12(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194C2:
		cmpi.w	#$20,$3C(a0)
		bcs.s	loc_194DA
		beq.s	loc_194E0
		cmpi.w	#$2A,$3C(a0)
		bcs.s	loc_194EE
		addq.b	#2,$25(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194DA:
		subq.w	#8,$12(a0)
		bra.s	loc_194EE
; ===========================================================================

loc_194E0:
		clr.w	$12(a0)
		bsr.w	BossEnd

loc_194EE:
		bra.w	loc_191F2
; ===========================================================================

loc_194F2:				; XREF: Obj75_ShipIndex
		move.w	#$400,$10(a0)
		move.w	#-$40,$12(a0)
		cmpi.w	#$2D40,(Camera_Max_X_Pos).w
		bcc.s	loc_1950C
		addq.w	#2,(Camera_Max_X_Pos).w
		bra.s	loc_19512
; ===========================================================================

loc_1950C:
		tst.b	1(a0)
		bpl.s	Obj75_ShipDelete

loc_19512:
		bsr.w	BossMove
		bra.w	loc_191DE
; ===========================================================================

Obj75_ShipDelete:
		jmp	DeleteObject
; ===========================================================================

Obj75_FaceMain:				; XREF: Obj75_Index
		moveq	#1,d1
		movea.l	$34(a0),a1
		moveq	#0,d0
		move.b	$25(a1),d0
		move.w	off_19546(pc,d0.w),d0
		jsr	off_19546(pc,d0.w)
		move.b	d1,$1C(a0)
		move.b	(a0),d0
		cmp.b	(a1),d0
		bne.s	Obj75_FaceDelete
		bra.s	loc_195BE
; ===========================================================================

Obj75_FaceDelete:
		jmp	DeleteObject
; ===========================================================================
off_19546:	dc.w loc_19574-off_19546, loc_19574-off_19546
		dc.w loc_1955A-off_19546, loc_19552-off_19546
		dc.w loc_19552-off_19546, loc_19556-off_19546
; ===========================================================================

loc_19552:				; XREF: off_19546
		moveq	#$A,d1
		rts	
; ===========================================================================

loc_19556:				; XREF: off_19546
		moveq	#6,d1
		rts	
; ===========================================================================

loc_1955A:				; XREF: off_19546
		moveq	#0,d0
		move.b	$28(a1),d0
		move.w	off_19568(pc,d0.w),d0
		jmp	off_19568(pc,d0.w)
; ===========================================================================
off_19568:	dc.w loc_19570-off_19568, loc_19572-off_19568
		dc.w loc_19570-off_19568, loc_19570-off_19568
; ===========================================================================

loc_19570:				; XREF: off_19568
		bra.s	loc_19574
; ===========================================================================

loc_19572:				; XREF: off_19568
		moveq	#6,d1

loc_19574:				; XREF: off_19546
		tst.b	$20(a1)
		bne.s	loc_1957E
		moveq	#5,d1
		rts	
; ===========================================================================

loc_1957E:
		cmpi.b	#4,(Object_Space_1+$24).w
		bcs.s	locret_19588
		moveq	#4,d1

locret_19588:
		rts	
; ===========================================================================

Obj75_FlameMain:			; XREF: Obj75_Index
		move.b	#7,$1C(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_195AA
		move.b	#$B,$1C(a0)
		tst.b	1(a0)
		bpl.s	Obj75_FlameDelete
		bra.s	loc_195B6
; ===========================================================================

loc_195AA:
		tst.w	$10(a1)
		beq.s	loc_195B6
		move.b	#8,$1C(a0)

loc_195B6:
		bra.s	loc_195BE
; ===========================================================================

Obj75_FlameDelete:
		jmp	DeleteObject
; ===========================================================================

loc_195BE:
		lea	(Ani_Eggman).l,a1
		jsr	AnimateSprite
		movea.l	$34(a0),a1
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)

loc_195DA:
		move.b	$22(a1),$22(a0)
		moveq	#3,d0
		and.b	$22(a0),d0
		andi.b	#$FC,1(a0)
		or.b	d0,1(a0)
		jmp	DisplaySprite
; ===========================================================================

Obj75_SpikeMain:			; XREF: Obj75_Index
		move.l	#Map_BossItems,4(a0)
		move.w	#$246C,2(a0)
		move.b	#5,$1A(a0)
		movea.l	$34(a0),a1
		cmpi.b	#$A,$25(a1)
		bne.s	loc_1961C
		tst.b	1(a0)
		bpl.s	Obj75_SpikeDelete

loc_1961C:
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		move.w	$3C(a0),d0
		cmpi.b	#4,$25(a1)
		bne.s	loc_19652
		cmpi.b	#6,$28(a1)
		beq.s	loc_1964C
		tst.b	$28(a1)
		bne.s	loc_19658
		cmpi.w	#$94,d0
		bge.s	loc_19658
		addq.w	#7,d0
		bra.s	loc_19658
; ===========================================================================

loc_1964C:
		tst.w	$3C(a1)
		bpl.s	loc_19658

loc_19652:
		tst.w	d0
		ble.s	loc_19658
		subq.w	#5,d0

loc_19658:
		move.w	d0,$3C(a0)
		asr.w	#2,d0
		add.w	d0,$C(a0)
		move.b	#8,$19(a0)
		move.b	#$C,$16(a0)
		clr.b	$20(a0)
		movea.l	$34(a0),a1
		tst.b	$20(a1)
		beq.s	loc_19688
		tst.b	$29(a1)
		bne.s	loc_19688
		move.b	#$84,$20(a0)

loc_19688:
		bra.w	loc_195DA
; ===========================================================================

Obj75_SpikeDelete:
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 76 - blocks that Eggman picks up (SYZ)
; ---------------------------------------------------------------------------

Obj76:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj76_Index(pc,d0.w),d1
		jmp	Obj76_Index(pc,d1.w)
; ===========================================================================
Obj76_Index:	dc.w Obj76_Main-Obj76_Index
		dc.w Obj76_Action-Obj76_Index
		dc.w loc_19762-Obj76_Index
; ===========================================================================

Obj76_Main:				; XREF: Obj76_Index
		moveq	#0,d4
		move.w	#$2C10,d5
		moveq	#9,d6
		lea	(a0),a1
		bra.s	Obj76_MakeBlock
; ===========================================================================

Obj76_Loop:
		jsr	SingleObjLoad
		bne.s	Obj76_ExitLoop

Obj76_MakeBlock:			; XREF: Obj76_Main
		move.b	#$76,(a1)
		move.l	#Map_obj76,4(a1)
		move.w	#$4000,2(a1)
		move.b	#4,1(a1)
		move.b	#$10,$19(a1)
		move.b	#$10,$16(a1)
		move.b	#3,$18(a1)
		move.w	d5,8(a1)	; set x-position
		move.w	#$582,$C(a1)
		move.w	d4,$28(a1)
		addi.w	#$101,d4
		addi.w	#$20,d5		; add $20 to next x-position
		addq.b	#2,$24(a1)
		dbf	d6,Obj76_Loop	; repeat sequence 9 more times

Obj76_ExitLoop:
		rts	
; ===========================================================================

Obj76_Action:				; XREF: Obj76_Index
		move.b	$29(a0),d0
		cmp.b	$28(a0),d0
		beq.s	Obj76_Solid
		tst.b	d0
		bmi.s	loc_19718

loc_19712:
		bsr.w	Obj76_Break
		bra.s	Obj76_Display
; ===========================================================================

loc_19718:
		movea.l	$34(a0),a1
		tst.b	$21(a1)
		beq.s	loc_19712
		move.w	8(a1),8(a0)
		move.w	$C(a1),$C(a0)
		addi.w	#$2C,$C(a0)
		cmpa.w	a0,a1
		bcs.s	Obj76_Display
		move.w	$12(a1),d0
		ext.l	d0
		asr.l	#8,d0
		add.w	d0,$C(a0)
		bra.s	Obj76_Display
; ===========================================================================

Obj76_Solid:				; XREF: Obj76_Action
		move.w	#$1B,d1
		move.w	#$10,d2
		move.w	#$11,d3
		move.w	8(a0),d4
		jsr	SolidObject

Obj76_Display:				; XREF: Obj76_Action
		jmp	DisplaySprite
; ===========================================================================

loc_19762:				; XREF: Obj76_Index
		tst.b	1(a0)
		bpl.s	Obj76_Delete
		jsr	ObjectMoveAndFall
		jmp	DisplaySprite
; ===========================================================================

Obj76_Delete:
		jmp	DeleteObject

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj76_Break:				; XREF: Obj76_Action
		lea	Obj76_FragSpeed(pc),a4
		lea	Obj76_FragPos(pc),a5
		moveq	#1,d4
		moveq	#3,d1
		moveq	#$38,d2
		addq.b	#2,$24(a0)
		move.b	#8,$19(a0)
		move.b	#8,$16(a0)
		lea	(a0),a1
		bra.s	Obj76_MakeFrag
; ===========================================================================

Obj76_LoopFrag:
		jsr	SingleObjLoad2
		bne.s	loc_197D4

Obj76_MakeFrag:
		lea	(a0),a2
		lea	(a1),a3
		moveq	#3,d3

loc_197AA:
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		move.l	(a2)+,(a3)+
		dbf	d3,loc_197AA

		move.w	(a4)+,$10(a1)
		move.w	(a4)+,$12(a1)
		move.w	(a5)+,d3
		add.w	d3,8(a1)
		move.w	(a5)+,d3
		add.w	d3,$C(a1)
		move.b	d4,$1A(a1)
		addq.w	#1,d4
		dbf	d1,Obj76_LoopFrag ; repeat sequence 3 more times

loc_197D4:
		move.w	#SndID_WallSmash,d0
		jmp	(PlaySound_Special).l ;	play smashing sound
; End of function Obj76_Break

; ===========================================================================
Obj76_FragSpeed:dc.w $FE80, $FE00
		dc.w $180, $FE00
		dc.w $FF00, $FF00
		dc.w $100, $FF00
Obj76_FragPos:	dc.w $FFF8, $FFF8
		dc.w $10, 0
		dc.w 0,	$10
		dc.w $10, $10
; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	Eggman picks up (SYZ)
; ---------------------------------------------------------------------------
Map_obj76:
	include "mappings/sprite/obj76.asm"

; ===========================================================================

loc_1982C:				; XREF: loc_19C62; loc_19C80
		jmp	DeleteObject
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 82 - Unused
; ---------------------------------------------------------------------------

Obj82:					; XREF: Obj_Index
		rts
; ===========================================================================
Ani_obj82:
	include "objects/animation/obj82.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - Eggman (SBZ2)
; ---------------------------------------------------------------------------
Map_obj82:
	include "mappings/sprite/obj82.asm"

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 83 - Unused
; ---------------------------------------------------------------------------

Obj83:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 85 - Unused
; ---------------------------------------------------------------------------

Obj85:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 84 - Unused
; ---------------------------------------------------------------------------

Obj84:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 86 - Unused
; ---------------------------------------------------------------------------

Obj86:					; XREF: Obj_Index
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 3E - prison capsule
; ---------------------------------------------------------------------------

Obj3E:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj3E_Index(pc,d0.w),d1
		jsr	Obj3E_Index(pc,d1.w)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj3E_Delete
		jmp	DisplaySprite
; ===========================================================================

Obj3E_Delete:
		jmp	DeleteObject
; ===========================================================================
Obj3E_Index:	dc.w Obj3E_Main-Obj3E_Index
		dc.w Obj3E_BodyMain-Obj3E_Index
		dc.w Obj3E_Switched-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Explosion-Obj3E_Index
		dc.w Obj3E_Animals-Obj3E_Index
		dc.w Obj3E_EndAct-Obj3E_Index

Obj3E_Var:	dc.b 2,	$20, 4,	0	; routine, width, priority, frame
		dc.b 4,	$C, 5, 1
		dc.b 6,	$10, 4,	3
		dc.b 8,	$10, 3,	5
; ===========================================================================

Obj3E_Main:				; XREF: Obj3E_Index
		move.l	#Map_obj3E,4(a0)
		move.w	#$49D,2(a0)
		move.b	#4,1(a0)
		move.w	$C(a0),$30(a0)
		moveq	#0,d0
		move.b	$28(a0),d0
		lsl.w	#2,d0
		lea	Obj3E_Var(pc,d0.w),a1
		move.b	(a1)+,$24(a0)
		move.b	(a1)+,$19(a0)
		move.b	(a1)+,$18(a0)
		move.b	(a1)+,$1A(a0)
		cmpi.w	#8,d0		; is object type number	02?
		bne.s	Obj3E_Not02	; if not, branch
		move.b	#6,$20(a0)
		move.b	#8,$21(a0)

Obj3E_Not02:
		rts	
; ===========================================================================

Obj3E_BodyMain:				; XREF: Obj3E_Index
		cmpi.b	#2,(Boss_Defeated_Flags).w
		beq.s	Obj3E_ChkOpened
		move.w	#$2B,d1
		move.w	#$18,d2
		move.w	#$18,d3
		move.w	8(a0),d4
		jmp	SolidObject
; ===========================================================================

Obj3E_ChkOpened:
		tst.b	$25(a0)		; has the prison been opened?
		beq.s	Obj3E_DoOpen	; if yes, branch
		clr.b	$25(a0)
		bclr	#3,(Object_Space_1+$22).w
		bset	#1,(Object_Space_1+$22).w

Obj3E_DoOpen:
		move.b	#2,$1A(a0)	; use frame number 2 (destroyed	prison)
		rts	
; ===========================================================================

Obj3E_Switched:				; XREF: Obj3E_Index
		move.w	#$17,d1
		move.w	#8,d2
		move.w	#8,d3
		move.w	8(a0),d4
		jsr	SolidObject
		lea	(Ani_obj3E).l,a1
		jsr	AnimateSprite
		move.w	$30(a0),$C(a0)
		tst.b	$25(a0)
		beq.s	locret_1AC60
		addq.w	#8,$C(a0)
		move.b	#$A,$24(a0)
		move.w	#$3C,$1E(a0)
		clr.b	(Update_HUD_Timer).w	; stop time counter
		clr.b	(Screen_Lock).w	; lock screen position
		move.w	(Camera_Max_X_Pos).w,(Camera_Min_X_Pos).w
		move.b	#1,(Lock_Controls_Flag).w ; lock	controls
		move.w	#$800,(Sonic_Ctrl_Held).w ; make Sonic run to	the right
		clr.b	$25(a0)
		bclr	#3,(Object_Space_1+$22).w
		bset	#1,(Object_Space_1+$22).w

locret_1AC60:
		rts	
; ===========================================================================

Obj3E_Explosion:			; XREF: Obj3E_Index
		moveq	#7,d0
		and.b	(V_Int_Counter+3).w,d0
		bne.s	loc_1ACA0
		jsr	SingleObjLoad
		bne.s	loc_1ACA0
		move.b	#$3F,0(a1)	; load explosion object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,8(a1)
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,$C(a1)

loc_1ACA0:
		subq.w	#1,$1E(a0)
		beq.s	Obj3E_MakeAnimal
		rts	
; ===========================================================================

Obj3E_MakeAnimal:
		move.b	#2,(Boss_Defeated_Flags).w
		move.b	#$C,$24(a0)	; replace explosions with animals
		move.b	#6,$1A(a0)
		move.w	#$96,$1E(a0)
		addi.w	#$20,$C(a0)
		moveq	#7,d6
		move.w	#$9A,d5
		moveq	#-$1C,d4

Obj3E_Loop:
		jsr	SingleObjLoad
		bne.s	locret_1ACF8
		move.b	#$28,0(a1)	; load animal object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		add.w	d4,8(a1)
		addq.w	#7,d4
		move.w	d5,$36(a1)
		subq.w	#8,d5
		dbf	d6,Obj3E_Loop	; repeat 7 more	times

locret_1ACF8:
		rts	
; ===========================================================================

Obj3E_Animals:				; XREF: Obj3E_Index
		moveq	#7,d0
		and.b	(V_Int_Counter+3).w,d0
		bne.s	loc_1AD38
		jsr	SingleObjLoad
		bne.s	loc_1AD38
		move.b	#$28,0(a1)	; load animal object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	(RandomNumber).l
		andi.w	#$1F,d0
		subq.w	#6,d0
		tst.w	d1
		bpl.s	loc_1AD2E
		neg.w	d0

loc_1AD2E:
		add.w	d0,8(a1)
		move.w	#$C,$36(a1)

loc_1AD38:
		subq.w	#1,$1E(a0)
		bne.s	locret_1AD48
		addq.b	#2,$24(a0)
		move.w	#180,$1E(a0)

locret_1AD48:
		rts	
; ===========================================================================

Obj3E_EndAct:				; XREF: Obj3E_Index
		moveq	#$3E,d0
		moveq	#$28,d1
		moveq	#$40,d2
		lea	(Object_Space_2).w,a1 ; load	object RAM

Obj3E_FindObj28:
		cmp.b	(a1),d1		; is object $28	(animal) loaded?
		beq.s	Obj3E_Obj28Found ; if yes, branch
		adda.w	d2,a1		; next object RAM
		dbf	d0,Obj3E_FindObj28 ; repeat $3E	times

		jsr	GotThroughAct
		jmp	DeleteObject
; ===========================================================================

Obj3E_Obj28Found:
		rts	
; ===========================================================================
Ani_obj3E:
	include "objects/animation/obj3E.asm"

; ---------------------------------------------------------------------------
; Sprite mappings - prison capsule
; ---------------------------------------------------------------------------
Map_obj3E:
	include "mappings/sprite/obj3E.asm"

; ---------------------------------------------------------------------------
; Object touch response	subroutine - $20(a0) in	the object RAM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TouchResponse:				; XREF: Obj01
		nop	
		move.w	8(a0),d2	; load Sonic's x-axis value
		move.w	$C(a0),d3	; load Sonic's y-axis value
		subq.w	#8,d2
		moveq	#0,d5
		move.b	$16(a0),d5	; load Sonic's height
		subq.b	#3,d5
		sub.w	d5,d3
		cmpi.b	#$39,$1A(a0)	; is Sonic ducking?
		bne.s	Touch_NoDuck	; if not, branch
		addi.w	#$C,d3
		moveq	#$A,d5

Touch_NoDuck:
		move.w	#$10,d4
		add.w	d5,d5
		lea	(Dynamic_Object_RAM).w,a1 ; begin checking the object RAM
		move.w	#((Dynamic_Object_RAM_End-Dynamic_Object_RAM)/$40)-1,d6

Touch_Loop:
		tst.b	1(a1)
		bpl.s	Touch_NextObj
		move.b	$20(a1),d0	; load touch response number
		bne.s	Touch_Height	; if touch response is not 0, branch

Touch_NextObj:
		lea	$40(a1),a1	; next object RAM
		dbf	d6,Touch_Loop	; repeat $5F more times

		moveq	#0,d0
		rts	
; ===========================================================================
Touch_Sizes:	dc.b  $14, $14		; width, height
		dc.b   $C, $14
		dc.b  $14,  $C
		dc.b	4, $10
		dc.b   $C, $12
		dc.b  $10, $10
		dc.b	6,   6
		dc.b  $18,  $C
		dc.b   $C, $10
		dc.b  $10,  $C
		dc.b	8,   8
		dc.b  $14, $10
		dc.b  $14,   8
		dc.b   $E,  $E
		dc.b  $18, $18
		dc.b  $28, $10
		dc.b  $10, $18
		dc.b	8, $10
		dc.b  $20, $70
		dc.b  $40, $20
		dc.b  $80, $20
		dc.b  $20, $20
		dc.b	8,   8
		dc.b	4,   4
		dc.b  $20,   8
		dc.b   $C,  $C
		dc.b	8,   4
		dc.b  $18,   4
		dc.b  $28,   4
		dc.b	4,   8
		dc.b	4, $18
		dc.b	4, $28
		dc.b	4, $20
		dc.b  $18, $18
		dc.b   $C, $18
		dc.b  $48,   8
; ===========================================================================

Touch_Height:				; XREF: TouchResponse
		andi.w	#$3F,d0
		add.w	d0,d0
		lea	Touch_Sizes-2(pc,d0.w),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		tst.b	biting(a0)
		beq.s	@not_biting
		addq.b	#4,d1
		
@not_biting:
		move.w	8(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_1AE98
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	Touch_Width
		bra.w	Touch_NextObj
; ===========================================================================

loc_1AE98:
		cmp.w	d4,d0
		bhi.w	Touch_NextObj

Touch_Width:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	$C(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_1AEB6
		add.w	d1,d1
		add.w	d0,d1
		bcs.s	Touch_ChkValue
		bra.w	Touch_NextObj
; ===========================================================================

loc_1AEB6:
		cmp.w	d5,d0
		bhi.w	Touch_NextObj

Touch_ChkValue:
		move.b	$20(a1),d1	; load touch response number
		andi.b	#$C0,d1		; is touch response $40	or higher?
		beq.w	Touch_Enemy	; if not, branch
		cmpi.b	#$C0,d1		; is touch response $C0	or higher?
		beq.w	Touch_Special	; if yes, branch
		tst.b	d1		; is touch response $80-$BF ?
		bmi.w	Touch_ChkHurt	; if yes, branch

; touch	response is $40-$7F

		move.b	$20(a1),d0
		andi.b	#$3F,d0
		cmpi.b	#6,d0		; is touch response $46	?
		beq.s	Touch_Monitor	; if yes, branch
		cmpi.w	#$5A,$30(a0)
		bcc.w	locret_1AEF2
		addq.b	#2,$24(a1)	; advance the object's routine counter

locret_1AEF2:
		rts	
; ===========================================================================

Touch_Monitor:
		rts	
; ===========================================================================

Touch_Enemy:				; XREF: Touch_ChkValue
		tst.b	(Invincibility_Flag).w	; is Sonic invincible?
		bne.s	loc_1AF40	; if yes, branch
		tst.b	biting(a0)
		beq.w	Touch_ChkHurt
		move.w	8(a1),d0
		move.w	8(a0),d1
		btst	#0,$22(a0)
		bne.s	@left
		cmp.w	d0,d1
		ble.s	loc_1AF40
		bra.w	Touch_ChkHurt
		
	@left:
		cmp.w	d0,d1
		bge.s	loc_1AF40
		bra.w	Touch_ChkHurt

loc_1AF40:
		tst.b	$21(a1)
		beq.s	Touch_KillEnemy
		move.b	#0,$20(a1)
		subq.b	#1,$21(a1)
		bne.s	locret_1AF68
		bset	#7,$22(a1)

locret_1AF68:
		rts	
; ===========================================================================

Touch_KillEnemy:
		bset	#7,$22(a1)
		moveq	#0,d0
		move.w	(Chain_Bonus_Counter).w,d0
		addq.w	#2,(Chain_Bonus_Counter).w ; add 2 to item bonus counter
		cmpi.w	#6,d0
		bcs.s	loc_1AF82
		moveq	#6,d0

loc_1AF82:
		move.w	d0,$3E(a1)
		move.w	Enemy_Points(pc,d0.w),d0
		cmpi.w	#$20,(Chain_Bonus_Counter).w ; have 16 enemies been destroyed?
		bcs.s	loc_1AF9C	; if not, branch
		move.w	#1000,d0	; fix bonus to 10000
		move.w	#$A,$3E(a1)

loc_1AF9C:
		bsr.w	AddPoints
		move.b	#$27,0(a1)	; change object	to points
		move.b	#0,$24(a1)
		rts	
; ===========================================================================
Enemy_Points:	dc.w 10, 20, 50, 100
; ===========================================================================

loc_1AFDA:				; XREF: Touch_CatKiller
		bset	#7,$22(a1)

Touch_ChkHurt:				; XREF: Touch_ChkValue
		tst.b	(Invincibility_Flag).w	; is Sonic invincible?
		beq.s	Touch_Hurt	; if not, branch

loc_1AFE6:				; XREF: Touch_Hurt
		moveq	#-1,d0
		rts	
; ===========================================================================

Touch_Hurt:				; XREF: Touch_ChkHurt
		nop	
		tst.w	$30(a0)
		bne.s	loc_1AFE6
		movea.l	a1,a2

; End of function TouchResponse
; continue straight to HurtSonic

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HurtSonic:
		tst.b	(Shield_Flag).w	; does Sonic have a shield?
		bne.s	Hurt_Shield	; if yes, branch
		tst.w	(Ring_Count).w	; does Sonic have any rings?
		beq.w	Hurt_NoRings	; if not, branch
		jsr	SingleObjLoad
		bne.s	Hurt_Shield
		move.b	#$37,0(a1)	; load bouncing	multi rings object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)

Hurt_Shield:
		move.b	#0,(Shield_Flag).w ; remove shield
		move.b	#4,$24(a0)
		bsr.w	Sonic_ResetOnFloor
		bset	#1,$22(a0)
		move.w	#-$400,$12(a0)	; make Sonic bounce away from the object
		move.w	#-$200,$10(a0)
		btst	#6,$22(a0)
		beq.s	Hurt_Reverse
		move.w	#-$200,$12(a0)
		move.w	#-$100,$10(a0)

Hurt_Reverse:
		move.w	8(a0),d0
		cmp.w	8(a2),d0
		bcs.s	Hurt_ChkSpikes	; if Sonic is left of the object, branch
		neg.w	$10(a0)		; if Sonic is right of the object, reverse

Hurt_ChkSpikes:
		move.w	#0,$14(a0)
		move.b	#$1A,$1C(a0)
		move.w	#$78,$30(a0)
		move.w	#SndID_Death,d0		; load normal damage sound
		cmpi.b	#$36,(a2)	; was damage caused by spikes?
		bne.s	Hurt_Sound	; if not, branch
		cmpi.b	#$16,(a2)	; was damage caused by LZ harpoon?
		bne.s	Hurt_Sound	; if not, branch
		move.w	#SndID_HitSpike,d0		; load spikes damage sound

Hurt_Sound:
		jsr	(PlaySound_Special).l
		moveq	#-1,d0
		rts	
; ===========================================================================

Hurt_NoRings:
		tst.w	(Debug_Cheat_On).w	; is debug mode	cheat on?
		bne.w	Hurt_Shield	; if yes, branch
; End of function HurtSonic

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


KillSonic:
		tst.w	(Debug_Placement_Mode).w	; is debug mode	active?
		bne.s	Kill_NoDeath	; if yes, branch
		move.w	#0,(Shield_Flag).w ; remove shield and invincibility
		move.b	#6,$24(a0)
		bsr.w	Sonic_ResetOnFloor
		bset	#1,$22(a0)
		move.w	#-$700,$12(a0)
		move.w	#0,$10(a0)
		move.w	#0,$14(a0)
		move.w	$C(a0),$38(a0)
		move.b	#$18,$1C(a0)
		bset	#7,2(a0)
		move.w	#SndID_Death,d0		; play normal death sound
		cmpi.b	#$36,(a2)	; check	if you were killed by spikes
		bne.s	Kill_Sound
		move.w	#SndID_HitSpike,d0		; play spikes death sound

Kill_Sound:
		jsr	(PlaySound_Special).l

Kill_NoDeath:
		moveq	#-1,d0
		rts	
; End of function KillSonic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Touch_Special:				; XREF: Touch_ChkValue
		move.b	$20(a1),d1
		andi.b	#$3F,d1
		cmpi.b	#$B,d1		; is touch response $CB	?
		beq.s	Touch_CatKiller	; if yes, branch
		cmpi.b	#$C,d1		; is touch response $CC	?
		beq.s	Touch_Yadrin	; if yes, branch
		cmpi.b	#$17,d1		; is touch response $D7	?
		beq.s	Touch_D7orE1	; if yes, branch
		cmpi.b	#$21,d1		; is touch response $E1	?
		beq.s	Touch_D7orE1	; if yes, branch
		rts	
; ===========================================================================

Touch_CatKiller:			; XREF: Touch_Special
		bra.w	loc_1AFDA
; ===========================================================================

Touch_Yadrin:				; XREF: Touch_Special
		sub.w	d0,d5
		cmpi.w	#8,d5
		bcc.s	loc_1B144
		move.w	8(a1),d0
		subq.w	#4,d0
		btst	#0,$22(a1)
		beq.s	loc_1B130
		subi.w	#$10,d0

loc_1B130:
		sub.w	d2,d0
		bcc.s	loc_1B13C
		addi.w	#$18,d0
		bcs.s	loc_1B140
		bra.s	loc_1B144
; ===========================================================================

loc_1B13C:
		cmp.w	d4,d0
		bhi.s	loc_1B144

loc_1B140:
		bra.w	Touch_ChkHurt
; ===========================================================================

loc_1B144:
		bra.w	Touch_Enemy
; ===========================================================================

Touch_D7orE1:				; XREF: Touch_Special
		addq.b	#1,$21(a1)
		rts	
; End of function Touch_Special
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 09 - blank
; ---------------------------------------------------------------------------

Obj09:					; XREF: Obj_Index
		rts	
		
; ===========================================================================
; ---------------------------------------------------------------------------
; Object 10 - blank
; ---------------------------------------------------------------------------

Obj10:					; XREF: Obj_Index
		rts	

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 03 - Collision plane/layer switcher (From Sonic 2 [Modified])
; ---------------------------------------------------------------------------

Obj03:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj03_Index(pc,d0.w),d1
		jsr	Obj03_Index(pc,d1.w)
		move.w	8(a0),d0
		andi.w	#$FF80,d0
		move.w	(Camera_X_Pos).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bhi.s	Obj03_MarkChkGone
		rts

Obj03_MarkChkGone:
		jmp	Mark_ChkGone
; ===========================================================================
; ---------------------------------------------------------------------------
Obj03_Index:	dc.w Obj03_Init-Obj03_Index
		dc.w Obj03_MainX-Obj03_Index
		dc.w Obj03_MainY-Obj03_Index
; ---------------------------------------------------------------------------
; ===========================================================================
; ---------------------------------------------------------------------------
; Initiation
; ---------------------------------------------------------------------------

Obj03_Init:
		addq.b	#2,$24(a0)
		move.l	#$0000000,$4(a0)
		move.w	#$26BC,$2(a0)
		ori.b	#4,$1(a0)
		move.b	#$10,$19(a0)
		move.b	#5,$18(a0)
		move.b	$28(a0),d0
		btst	#2,d0
		beq.s	Obj03_Init_CheckX

;Obj03_Init_CheckY:
		addq.b	#2,$24(a0) ; => Obj03_MainY
		andi.w	#7,d0
		move.b	d0,$1A(a0)
		andi.w	#3,d0
		add.w	d0,d0
		move.w	word_1FD68(pc,d0.w),$32(a0)
		move.w	$C(a0),d1
		lea	(Object_RAM).w,a1 ; a1=character
		cmp.w	$C(a1),d1
		bcc.s	Obj03_Init_Next
		move.b	#1,$34(a0)
Obj03_Init_Next:
	;	lea	(Sidekick).w,a1 ; a1=character
	;	cmp.w	$C(a1),d1
	;	bcc.s	+
	;	move.b	#1,$35(a0)
;+
		bra.w	Obj03_MainY
; ===========================================================================
word_1FD68:
	dc.w  $20
	dc.w  $40	; 1
	dc.w  $80	; 2
	dc.w  $100	; 3
; ===========================================================================
; loc_1FD70:
Obj03_Init_CheckX:
		andi.w	#3,d0
		move.b	d0,$1A(a0)
		add.w	d0,d0
		move.w	word_1FD68(pc,d0.w),$32(a0)
		move.w	$8(a0),d1
		lea	(Object_RAM).w,a1 ; a1=character
		cmp.w	$8(a1),d1
		bcc.s	Obj03_Init_CheckX_Next
		move.b	#1,$34(a0)
Obj03_Init_CheckX_Next:
	;	lea	(Sidekick).w,a1 ; a1=character
	;	cmp.w	$8(a1),d1
	;	bcc.s	+
	;	move.b	#1,$35(a0)
;+

Obj03_MainX:
		tst.w	(Debug_Placement_Mode).w
		bne.w	return_1FEAC
		move.w	$8(a0),d1
		lea	$34(a0),a2
		lea	(Object_RAM).w,a1 ; a1=character
;		bsr.s	+
;		lea	(Sidekick).w,a1 ; a1=character

;+
		tst.b	(a2)+
		bne.s	Obj03_MainX_Alt
		cmp.w	$8(a1),d1
		bhi.w	return_1FEAC
		move.b	#1,-1(a2)
		move.w	$C(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	$C(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FEAC
		cmp.w	d3,d4
		bge.w	return_1FEAC
		move.b	$28(a0),d0
		bpl.s	Obj03_ICX_B1
		btst	#1,$2B(a1)
		bne.w	return_1FEAC

Obj03_ICX_B1:
		btst	#0,$1(a0)
		bne.s	Obj03_ICX_B2
		move.b	#$0,(Sonic_Current_Coll_Layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#3,d0
		beq.s	Obj03_ICX_B2
		move.b	#$1,(Sonic_Current_Coll_Layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_ICX_B2:
		andi.w	#$7FFF,$2(a1)
		btst	#5,d0
		beq.s	return_1FEAC
		ori.w	#$8000,$2(a1)
		bra.s	return_1FEAC
; ===========================================================================

Obj03_MainX_Alt:
		cmp.w	$8(a1),d1
		bls.w	return_1FEAC
		move.b	#0,-1(a2)
		move.w	$C(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	$C(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FEAC
		cmp.w	d3,d4
		bge.w	return_1FEAC
		move.b	$28(a0),d0
		bpl.s	Obj03_MXA_B1
		btst	#1,$2B(a1)
		bne.w	return_1FEAC

Obj03_MXA_B1:
		btst	#0,$1(a0)
		bne.s	Obj03_MXA_B2
		move.b	#$0,(Sonic_Current_Coll_Layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#4,d0
		beq.s	Obj03_MXA_B2
		move.b	#$1,(Sonic_Current_Coll_Layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_MXA_B2:
		andi.w	#$7FFF,$2(a1)
		btst	#6,d0
		beq.s	return_1FEAC
		ori.w	#$8000,$2(a1)

return_1FEAC:
		rts

; ===========================================================================

Obj03_MainY:
		tst.w	(Debug_Placement_Mode).w
		bne.w	return_1FFB6
		move.w	$C(a0),d1
		lea	$34(a0),a2
		lea	(Object_RAM).w,a1 ; a1=character
;		bsr.s	+
;		lea	(Sidekick).w,a1 ; a1=character

;+
		tst.b	(a2)+
		bne.s	Obj03_MainY_Alt
		cmp.w	$C(a1),d1
		bhi.w	return_1FFB6
		move.b	#1,-1(a2)
		move.w	$8(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	$8(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FFB6
		cmp.w	d3,d4
		bge.w	return_1FFB6
		move.b	$28(a0),d0
		bpl.s	Obj03_MY_B1
		btst	#1,$2B(a1)
		bne.w	return_1FFB6

Obj03_MY_B1:
		btst	#0,$1(a0)
		bne.s	Obj03_MY_B2
		move.b	#$0,(Sonic_Current_Coll_Layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#3,d0
		beq.s	Obj03_MY_B2
		move.b	#$1,(Sonic_Current_Coll_Layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_MY_B2:
		andi.w	#$7FFF,$2(a1)
		btst	#5,d0
		beq.s	return_1FFB6
		ori.w	#$8000,$2(a1)
		bra.s	return_1FFB6

; ===========================================================================

Obj03_MainY_Alt:
		cmp.w	$C(a1),d1
		bls.w	return_1FFB6
		move.b	#0,-1(a2)
		move.w	$8(a0),d2
		move.w	d2,d3
		move.w	$32(a0),d4
		sub.w	d4,d2
		add.w	d4,d3
		move.w	$8(a1),d4
		cmp.w	d2,d4
		blt.w	return_1FFB6
		cmp.w	d3,d4
		bge.w	return_1FFB6
		move.b	$28(a0),d0
		bpl.s	Obj03_MYA_B1
		btst	#1,$2B(a1)
		bne.w	return_1FFB6

Obj03_MYA_B1
		btst	#0,$1(a0)
		bne.s	Obj03_MYA_B2
		move.b	#$0,(Sonic_Current_Coll_Layer).w
	;	move.b	#$C,$3E(a1)
	;	move.b	#$D,$3F(a1)
		btst	#4,d0
		beq.s	Obj03_MYA_B2
		move.b	#$1,(Sonic_Current_Coll_Layer).w
	;	move.b	#$E,$3E(a1)
	;	move.b	#$F,$3F(a1)

Obj03_MYA_B2:
		andi.w	#$7FFF,$2(a1)
		btst	#6,d0
		beq.s	return_1FFB6
		ori.w	#$8000,$2(a1)

return_1FFB6:
		rts

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	animate	level graphics
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AniArt_Load:				; XREF: Demo_Time; loc_F54
		tst.w	(Pause_Flag).w	; is the game paused?
		bne.s	AniArt_Pause	; if yes, branch
		lea	($C00000).l,a6
		bsr.w	AniArt_GiantRing
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		add.w	d0,d0
		move.w	AniArt_Index(pc,d0.w),d0
		jmp	AniArt_Index(pc,d0.w)
; ===========================================================================

AniArt_Pause:
		rts	
; End of function AniArt_Load

; ===========================================================================
AniArt_Index:	dc.w AniArt_none-AniArt_Index, AniArt_none-AniArt_Index
		dc.w AniArt_mz-AniArt_Index, AniArt_none-AniArt_Index
		dc.w AniArt_none-AniArt_Index, AniArt_none-AniArt_Index
		dc.w AniArt_ending-AniArt_Index
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Green Hill
; ---------------------------------------------------------------------------

AniArt_GHZ:				; XREF: AniArt_Index
		subq.b	#1,(Level_Ani0_Timer).w
		bpl.s	loc_1C08A
		move.b	#5,(Level_Ani0_Timer).w ; time	to display each	frame for
		lea	(Art_GhzWater).l,a1 ; load waterfall patterns
		move.b	(Level_Ani0_Frame).w,d0
		addq.b	#1,(Level_Ani0_Frame).w
		andi.w	#1,d0
		beq.s	loc_1C078
		lea	$100(a1),a1	; load next frame

loc_1C078:
		move.l	#$6F000001,($C00004).l ; VRAM address
		move.w	#7,d1		; number of 8x8	tiles
		bra.w	LoadTiles
; ===========================================================================

loc_1C08A:
		subq.b	#1,(Level_Ani1_Timer).w
		bpl.s	loc_1C0C0
		move.b	#$F,(Level_Ani1_Timer).w
		lea	(Art_GhzFlower1).l,a1 ;	load big flower	patterns
		move.b	(Level_Ani1_Frame).w,d0
		addq.b	#1,(Level_Ani1_Frame).w
		andi.w	#1,d0
		beq.s	loc_1C0AE
		lea	$200(a1),a1

loc_1C0AE:
		move.l	#$6B800001,($C00004).l
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C0C0:
		subq.b	#1,(Level_Ani2_Timer).w
		bpl.s	locret_1C10C
		move.b	#7,(Level_Ani2_Timer).w
		move.b	(Level_Ani2_Frame).w,d0
		addq.b	#1,(Level_Ani2_Frame).w
		andi.w	#3,d0
		move.b	byte_1C10E(pc,d0.w),d0
		btst	#0,d0
		bne.s	loc_1C0E8
		move.b	#$7F,(Level_Ani2_Timer).w

loc_1C0E8:
		lsl.w	#7,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.l	#$6D800001,($C00004).l
		lea	(Art_GhzFlower2).l,a1 ;	load small flower patterns
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bsr.w	LoadTiles

locret_1C10C:
		rts	
; ===========================================================================
byte_1C10E:	dc.b 0,	1, 2, 1
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Marble
; ---------------------------------------------------------------------------

AniArt_MZ:				; XREF: AniArt_Index
		subq.b	#1,(Level_Ani0_Timer).w
		bpl.s	loc_1C150
		move.b	#$13,(Level_Ani0_Timer).w
		lea	(Art_MzLava1).l,a1 ; load lava surface patterns
		moveq	#0,d0
		move.b	(Level_Ani0_Frame).w,d0
		addq.b	#1,d0
		cmpi.b	#3,d0
		bne.s	loc_1C134
		moveq	#0,d0

loc_1C134:
		move.b	d0,(Level_Ani0_Frame).w
		mulu.w	#$100,d0
		adda.w	d0,a1
		move.l	#$5C400001,($C00004).l
		move.w	#7,d1
		bsr.w	LoadTiles

loc_1C150:
		subq.b	#1,(Level_Ani1_Timer).w
		bpl.s	loc_1C1AE
		move.b	#1,(Level_Ani1_Timer).w
		moveq	#0,d0
		move.b	(Level_Ani0_Frame).w,d0
		lea	(Art_MzLava2).l,a4 ; load lava patterns
		ror.w	#7,d0
		adda.w	d0,a4
		move.l	#$5A400001,($C00004).l
		moveq	#0,d3
		move.b	(Level_Ani1_Frame).w,d3
		addq.b	#1,(Level_Ani1_Frame).w
		move.b	(Oscillation_Data+$8).w,d3
		move.w	#3,d2

loc_1C188:
		move.w	d3,d0
		add.w	d0,d0
		andi.w	#$1E,d0
		lea	(AniArt_MZextra).l,a3
		move.w	(a3,d0.w),d0
		lea	(a3,d0.w),a3
		movea.l	a4,a1
		move.w	#$1F,d1
		jsr	(a3)
		addq.w	#4,d3
		dbf	d2,loc_1C188
		rts	
; ===========================================================================

loc_1C1AE:
		subq.b	#1,(Level_Ani2_Timer).w
		bpl.w	locret_1C1EA
		move.b	#7,(Level_Ani2_Timer).w
		lea	(Art_MzTorch).l,a1 ; load torch	patterns
		moveq	#0,d0
		move.b	(Level_Ani3_Frame).w,d0
		addq.b	#1,(Level_Ani3_Frame).w
		andi.b	#3,(Level_Ani3_Frame).w
		mulu.w	#$C0,d0
		adda.w	d0,a1
		move.l	#$5E400001,($C00004).l
		move.w	#5,d1
		bra.w	LoadTiles
; ===========================================================================

locret_1C1EA:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - Scrap Brain
; ---------------------------------------------------------------------------

AniArt_SBZ:				; XREF: AniArt_Index
		tst.b	(Level_Ani2_Frame).w
		beq.s	loc_1C1F8
		subq.b	#1,(Level_Ani2_Frame).w
		bra.s	loc_1C250
; ===========================================================================

loc_1C1F8:
		subq.b	#1,(Level_Ani0_Timer).w
		bpl.s	loc_1C250
		move.b	#7,(Level_Ani0_Timer).w
		lea	(Art_SbzSmoke).l,a1 ; load smoke patterns
		move.l	#$49000002,($C00004).l
		move.b	(Level_Ani0_Frame).w,d0
		addq.b	#1,(Level_Ani0_Frame).w
		andi.w	#7,d0
		beq.s	loc_1C234
		subq.w	#1,d0
		mulu.w	#$180,d0
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C234:
		move.b	#$B4,(Level_Ani2_Frame).w

loc_1C23A:
		move.w	#5,d1
		bsr.w	LoadTiles
		lea	(Art_SbzSmoke).l,a1
		move.w	#5,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C250:
		tst.b	(Level_Ani2_Timer).w
		beq.s	loc_1C25C
		subq.b	#1,(Level_Ani2_Timer).w
		bra.s	locret_1C2A0
; ===========================================================================

loc_1C25C:
		subq.b	#1,(Level_Ani1_Timer).w
		bpl.s	locret_1C2A0
		move.b	#7,(Level_Ani1_Timer).w
		lea	(Art_SbzSmoke).l,a1
		move.l	#$4A800002,($C00004).l
		move.b	(Level_Ani1_Frame).w,d0
		addq.b	#1,(Level_Ani1_Frame).w
		andi.w	#7,d0
		beq.s	loc_1C298
		subq.w	#1,d0
		mulu.w	#$180,d0
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C298:
		move.b	#$78,(Level_Ani2_Timer).w
		bra.s	loc_1C23A
; ===========================================================================

locret_1C2A0:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - ending sequence
; ---------------------------------------------------------------------------

AniArt_Ending:				; XREF: AniArt_Index
		subq.b	#1,(Level_Ani1_Timer).w
		bpl.s	loc_1C2F4
		move.b	#7,(Level_Ani1_Timer).w
		lea	(Art_GhzFlower1).l,a1 ;	load big flower	patterns
		lea	(General_Buffer+$9400).w,a2
		move.b	(Level_Ani1_Frame).w,d0
		addq.b	#1,(Level_Ani1_Frame).w
		andi.w	#1,d0
		beq.s	loc_1C2CE
		lea	$200(a1),a1
		lea	$200(a2),a2

loc_1C2CE:
		move.l	#$6B800001,($C00004).l
		move.w	#$F,d1
		bsr.w	LoadTiles
		movea.l	a2,a1
		move.l	#$72000001,($C00004).l
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

loc_1C2F4:
		subq.b	#1,(Level_Ani2_Timer).w
		bpl.s	loc_1C33C
		move.b	#7,(Level_Ani2_Timer).w
		move.b	(Level_Ani2_Frame).w,d0
		addq.b	#1,(Level_Ani2_Frame).w
		andi.w	#7,d0
		move.b	byte_1C334(pc,d0.w),d0
		lsl.w	#7,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.l	#$6D800001,($C00004).l
		lea	(Art_GhzFlower2).l,a1 ;	load small flower patterns
		lea	(a1,d0.w),a1
		move.w	#$B,d1
		bra.w	LoadTiles
; ===========================================================================
byte_1C334:	dc.b 0,	0, 0, 1, 2, 2, 2, 1
; ===========================================================================

loc_1C33C:
		subq.b	#1,(Level_Ani4_Timer).w
		bpl.s	loc_1C37A
		move.b	#$E,(Level_Ani4_Timer).w
		move.b	(Level_Ani4_Frame).w,d0
		addq.b	#1,(Level_Ani4_Frame).w
		andi.w	#3,d0
		move.b	byte_1C376(pc,d0.w),d0
		lsl.w	#8,d0
		add.w	d0,d0
		move.l	#$70000001,($C00004).l
		lea	(General_Buffer+$9800).w,a1 ; load	special	flower patterns	(from RAM)
		lea	(a1,d0.w),a1
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================
byte_1C376:	dc.b 0,	1, 2, 1
; ===========================================================================

loc_1C37A:
		subq.b	#1,(Level_Ani5_Timer).w
		bpl.s	locret_1C3B4
		move.b	#$B,(Level_Ani5_Timer).w
		move.b	(Level_Ani5_Frame).w,d0
		addq.b	#1,(Level_Ani5_Frame).w
		andi.w	#3,d0
		move.b	byte_1C376(pc,d0.w),d0
		lsl.w	#8,d0
		add.w	d0,d0
		move.l	#$68000001,($C00004).l
		lea	(General_Buffer+$9E00).w,a1 ; load	special	flower patterns	(from RAM)
		lea	(a1,d0.w),a1
		move.w	#$F,d1
		bra.w	LoadTiles
; ===========================================================================

locret_1C3B4:
		rts	
; ===========================================================================

AniArt_none:				; XREF: AniArt_Index
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	load (d1 - 1) 8x8 tiles
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


LoadTiles:
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a6)
		dbf	d1,LoadTiles
		rts	
; End of function LoadTiles

; ===========================================================================
; ---------------------------------------------------------------------------
; Animated pattern routine - more Marble Zone
; ---------------------------------------------------------------------------
AniArt_MZextra:	dc.w loc_1C3EE-AniArt_MZextra, loc_1C3FA-AniArt_MZextra
		dc.w loc_1C410-AniArt_MZextra, loc_1C41E-AniArt_MZextra
		dc.w loc_1C434-AniArt_MZextra, loc_1C442-AniArt_MZextra
		dc.w loc_1C458-AniArt_MZextra, loc_1C466-AniArt_MZextra
		dc.w loc_1C47C-AniArt_MZextra, loc_1C48A-AniArt_MZextra
		dc.w loc_1C4A0-AniArt_MZextra, loc_1C4AE-AniArt_MZextra
		dc.w loc_1C4C4-AniArt_MZextra, loc_1C4D2-AniArt_MZextra
		dc.w loc_1C4E8-AniArt_MZextra, loc_1C4FA-AniArt_MZextra
; ===========================================================================

loc_1C3EE:				; XREF: AniArt_MZextra
		move.l	(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C3EE
		rts	
; ===========================================================================

loc_1C3FA:				; XREF: AniArt_MZextra
		move.l	2(a1),d0
		move.b	1(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C3FA
		rts	
; ===========================================================================

loc_1C410:				; XREF: AniArt_MZextra
		move.l	2(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C410
		rts	
; ===========================================================================

loc_1C41E:				; XREF: AniArt_MZextra
		move.l	4(a1),d0
		move.b	3(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C41E
		rts	
; ===========================================================================

loc_1C434:				; XREF: AniArt_MZextra
		move.l	4(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C434
		rts	
; ===========================================================================

loc_1C442:				; XREF: AniArt_MZextra
		move.l	6(a1),d0
		move.b	5(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C442
		rts	
; ===========================================================================

loc_1C458:				; XREF: AniArt_MZextra
		move.l	6(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C458
		rts	
; ===========================================================================

loc_1C466:				; XREF: AniArt_MZextra
		move.l	8(a1),d0
		move.b	7(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C466
		rts	
; ===========================================================================

loc_1C47C:				; XREF: AniArt_MZextra
		move.l	8(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C47C
		rts	
; ===========================================================================

loc_1C48A:				; XREF: AniArt_MZextra
		move.l	$A(a1),d0
		move.b	9(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C48A
		rts	
; ===========================================================================

loc_1C4A0:				; XREF: AniArt_MZextra
		move.l	$A(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4A0
		rts	
; ===========================================================================

loc_1C4AE:				; XREF: AniArt_MZextra
		move.l	$C(a1),d0
		move.b	$B(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4AE
		rts	
; ===========================================================================

loc_1C4C4:				; XREF: AniArt_MZextra
		move.l	$C(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4C4
		rts	
; ===========================================================================

loc_1C4D2:				; XREF: AniArt_MZextra
		move.l	$C(a1),d0
		rol.l	#8,d0
		move.b	0(a1),d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4D2
		rts	
; ===========================================================================

loc_1C4E8:				; XREF: AniArt_MZextra
		move.w	$E(a1),(a6)
		move.w	0(a1),(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4E8
		rts	
; ===========================================================================

loc_1C4FA:				; XREF: AniArt_MZextra
		move.l	0(a1),d0
		move.b	$F(a1),d0
		ror.l	#8,d0
		move.l	d0,(a6)
		lea	$10(a1),a1
		dbf	d1,loc_1C4FA
		rts	

; ---------------------------------------------------------------------------
; Animated pattern routine - giant ring
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AniArt_GiantRing:			; XREF: AniArt_Load
		tst.w	(Big_Ring_GFX_Offset).w
		bne.s	loc_1C518
		rts	
; ===========================================================================

loc_1C518:
		subi.w	#$1C0,(Big_Ring_GFX_Offset).w
		lea	(Art_BigRing).l,a1 ; load giant	ring patterns
		moveq	#0,d0
		move.w	(Big_Ring_GFX_Offset).w,d0
		lea	(a1,d0.w),a1
		addi.w	#$8000,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		ori.w	#$4000,d0
		swap	d0
		move.l	d0,4(a6)
		move.w	#$D,d1
		bra.w	LoadTiles
; End of function AniArt_GiantRing

; ===========================================================================
; ---------------------------------------------------------------------------
; Object 21 - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------

Obj21:					; XREF: Obj_Index
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj21_Index(pc,d0.w),d1
		jmp	Obj21_Index(pc,d1.w)
; ===========================================================================
Obj21_Index:	dc.w Obj21_Main-Obj21_Index
		dc.w Obj21_Flash-Obj21_Index
; ===========================================================================

Obj21_Main:				; XREF: Obj21_Main
		addq.b	#2,$24(a0)
		move.w	#$90,8(a0)
		move.w	#$108,$A(a0)
		move.l	#Map_obj21,4(a0)
		move.w	#$86CA,2(a0)
		move.b	#0,1(a0)
		move.b	#0,$18(a0)

Obj21_Flash:				; XREF: Obj21_Main
		moveq	#0,d0
		btst	#3,(Level_Timer+1).w
		bne.s	Obj21_Display
		tst.w	(Ring_Count).w	; do you have any rings?
		bne.s	Obj21_Flash2	; if not, branch
		addq.w	#1,d0		; make ring counter flash red

Obj21_Flash2:
		cmpi.b	#9,(Timer_Minute).w ; have	9 minutes elapsed?
		bne.s	Obj21_Display	; if not, branch
		addq.w	#2,d0		; make time counter flash red

Obj21_Display:
		move.b	d0,$1A(a0)
		jmp	DisplaySprite
; ===========================================================================
; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; ---------------------------------------------------------------------------
Map_obj21:
	include "mappings/sprite/obj21.asm"

; ---------------------------------------------------------------------------
; Add points subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


AddPoints:
		move.b	#1,(Update_HUD_Score).w ; set score counter to	update
		lea	(Score_Copy).w,a2
		lea	(Score).w,a3
		add.l	d0,(a3)		; add d0*10 to the score
		move.l	#999999,d1
		cmp.l	(a3),d1		; is #999999 higher than the score?
		bhi.w	loc_1C6AC	; if yes, branch
		move.l	d1,(a3)		; reset	score to #999999
		move.l	d1,(a2)

loc_1C6AC:
		move.l	(a3),d0
		cmp.l	(a2),d0
		bcs.w	locret_1C6B6
		move.l	d0,(a2)

locret_1C6B6:
		rts	
; End of function AddPoints

; ---------------------------------------------------------------------------
; Subroutine to	update the HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudUpdate:
		tst.w	(Debug_Cheat_On).w	; is debug mode	on?
		bne.w	HudDebug	; if yes, branch
		tst.b	(Update_HUD_Score).w	; does the score need updating?
		beq.s	Hud_ChkRings	; if not, branch
		clr.b	(Update_HUD_Score).w
		move.l	#$5C800003,d0	; set VRAM address
		move.l	(Score).w,d1 ; load	score
		bsr.w	Hud_Score

Hud_ChkRings:
		tst.b	(Update_HUD_Rings).w	; does the ring	counter	need updating?
		beq.s	Hud_ChkTime	; if not, branch
		bpl.s	loc_1C6E4
		bsr.w	Hud_LoadZero

loc_1C6E4:
		clr.b	(Update_HUD_Rings).w
		move.l	#$5F400003,d0	; set VRAM address
		moveq	#0,d1
		move.w	(Ring_Count).w,d1 ; load	number of rings
		bsr.w	Hud_Rings

Hud_ChkTime:
		tst.b	(Update_HUD_Timer).w	; does the time	need updating?
		beq.s	Hud_ChkLives	; if not, branch
		tst.w	(Pause_Flag).w	; is the game paused?
		bne.s	Hud_ChkLives	; if yes, branch
		lea	(Timer).w,a1
		cmpi.l	#$93B3B,(a1)+	; is the time 9.59?
		beq.s	TimeOver	; if yes, branch
		addq.b	#1,-(a1)
		cmpi.b	#60,(a1)
		bcs.s	Hud_ChkLives
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmpi.b	#60,(a1)
		bcs.s	loc_1C734
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmpi.b	#9,(a1)
		bcs.s	loc_1C734
		move.b	#9,(a1)

loc_1C734:
		move.l	#$5E400003,d0
		moveq	#0,d1
		move.b	(Timer_Minute).w,d1 ; load	minutes
		bsr.w	Hud_Mins
		move.l	#$5EC00003,d0
		moveq	#0,d1
		move.b	(Timer_Second).w,d1 ; load	seconds
		bsr.w	Hud_Secs

Hud_ChkLives:
		tst.b	(Update_HUD_Lives).w	; does the lives counter need updating?
		beq.s	Hud_ChkBonus	; if not, branch
		clr.b	(Update_HUD_Lives).w
		bsr.w	Hud_Lives

Hud_ChkBonus:
		tst.b	(Update_Bonus_Flag).w	; do time/ring bonus counters need updating?
		beq.s	Hud_End		; if not, branch
		clr.b	(Update_Bonus_Flag).w
		move.l	#$6E000002,($C00004).l
		moveq	#0,d1
		move.w	(Time_Bonus).w,d1 ; load	time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(Ring_Bonus).w,d1 ; load	ring bonus
		bsr.w	Hud_TimeRingBonus

Hud_End:
		rts	
; ===========================================================================

TimeOver:				; XREF: Hud_ChkTime
		clr.b	(Update_HUD_Timer).w
		lea	(Object_RAM).w,a0
		movea.l	a0,a2
		bsr.w	KillSonic
		move.b	#1,(Time_Over_Flag).w
		rts	
; ===========================================================================

HudDebug:				; XREF: HudUpdate
		bsr.w	HudDb_XY
		tst.b	(Update_HUD_Rings).w	; does the ring	counter	need updating?
		beq.s	HudDb_ObjCount	; if not, branch
		bpl.s	HudDb_Rings
		bsr.w	Hud_LoadZero

HudDb_Rings:
		clr.b	(Update_HUD_Rings).w
		move.l	#$5F400003,d0	; set VRAM address
		moveq	#0,d1
		move.w	(Ring_Count).w,d1 ; load	number of rings
		bsr.w	Hud_Rings

HudDb_ObjCount:
		move.l	#$5EC00003,d0	; set VRAM address
		moveq	#0,d1
		move.b	(Sprite_Count).w,d1 ; load	"number	of objects" counter
		bsr.w	Hud_Secs
		tst.b	(Update_HUD_Lives).w	; does the lives counter need updating?
		beq.s	HudDb_ChkBonus	; if not, branch
		clr.b	(Update_HUD_Lives).w
		bsr.w	Hud_Lives

HudDb_ChkBonus:
		tst.b	(Update_Bonus_Flag).w	; does the ring/time bonus counter need	updating?
		beq.s	HudDb_End	; if not, branch
		clr.b	(Update_Bonus_Flag).w
		move.l	#$6E000002,($C00004).l ; set VRAM address
		moveq	#0,d1
		move.w	(Time_Bonus).w,d1 ; load	time bonus
		bsr.w	Hud_TimeRingBonus
		moveq	#0,d1
		move.w	(Ring_Bonus).w,d1 ; load	ring bonus
		bsr.w	Hud_TimeRingBonus

HudDb_End:
		rts	
; End of function HudUpdate

; ---------------------------------------------------------------------------
; Subroutine to	load "0" on the	HUD
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_LoadZero:				; XREF: HudUpdate
		move.l	#$5F400003,($C00004).l
		lea	Hud_TilesZero(pc),a2
		move.w	#2,d2
		bra.s	loc_1C83E
; End of function Hud_LoadZero

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed HUD patterns ("E", "0", colon)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Base:				; XREF: Level; SS_EndLoop; EndingSequence
		lea	($C00000).l,a6
		bsr.w	Hud_Lives
		move.l	#$5C400003,($C00004).l
		lea	Hud_TilesBase(pc),a2
		move.w	#$E,d2

loc_1C83E:				; XREF: Hud_LoadZero
		lea	Art_Hud(pc),a1

loc_1C842:
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_1C85E
		ext.w	d0
		lsl.w	#5,d0
		lea	(a1,d0.w),a3

loc_1C852:
		move.l	(a3)+,(a6)
		dbf	d1,loc_1C852

loc_1C858:
		dbf	d2,loc_1C842

		rts	
; ===========================================================================

loc_1C85E:
		move.l	#0,(a6)
		dbf	d1,loc_1C85E

		bra.s	loc_1C858
; End of function Hud_Base

; ===========================================================================
Hud_TilesBase:	dc.b $16, $FF, $FF, $FF, $FF, $FF, $FF,	0, 0, $14, 0, 0
Hud_TilesZero:	dc.b $FF, $FF, 0, 0
; ---------------------------------------------------------------------------
; Subroutine to	load debug mode	numbers	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY:				; XREF: HudDebug
		move.l	#$5C400003,($C00004).l ; set VRAM address
		move.w	(Camera_X_Pos).w,d1 ; load	camera x-position
		swap	d1
		move.w	(Object_Space_1+8).w,d1 ; load	Sonic's x-position
		bsr.s	HudDb_XY2
		move.w	(Camera_Y_Pos).w,d1 ; load	camera y-position
		swap	d1
		move.w	(Object_Space_1+$C).w,d1 ; load	Sonic's y-position
; End of function HudDb_XY


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


HudDb_XY2:
		moveq	#7,d6
		lea	(Art_Text).l,a1

HudDb_XYLoop:
		rol.w	#4,d1
		move.w	d1,d2
		andi.w	#$F,d2
		cmpi.w	#$A,d2
		bcs.s	loc_1C8B2
		addq.w	#7,d2

loc_1C8B2:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		swap	d1
		dbf	d6,HudDb_XYLoop	; repeat 7 more	times

		rts	
; End of function HudDb_XY2

; ---------------------------------------------------------------------------
; Subroutine to	load rings numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Rings:				; XREF: HudUpdate
		lea	(Hud_100).l,a2
		moveq	#2,d6
		bra.s	Hud_LoadArt
; End of function Hud_Rings

; ---------------------------------------------------------------------------
; Subroutine to	load score numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Score:				; XREF: HudUpdate
		lea	(Hud_100000).l,a2
		moveq	#5,d6

Hud_LoadArt:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_ScoreLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C8EC:
		sub.l	d3,d1
		bcs.s	loc_1C8F4
		addq.w	#1,d2
		bra.s	loc_1C8EC
; ===========================================================================

loc_1C8F4:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C8FE
		move.w	#1,d4

loc_1C8FE:
		tst.w	d4
		beq.s	loc_1C92C
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1C92C:
		addi.l	#$400000,d0
		dbf	d6,Hud_ScoreLoop

		rts	
; End of function Hud_Score

; ---------------------------------------------------------------------------
; Subroutine to	load countdown numbers on the continue screen
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


ContScrCounter:				; XREF: ContinueScreen
		move.l	#$5F800003,($C00004).l ; set VRAM address
		lea	($C00000).l,a6
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1 ; load numbers patterns

ContScr_Loop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C95A:
		sub.l	d3,d1
		bcs.s	loc_1C962
		addq.w	#1,d2
		bra.s	loc_1C95A
; ===========================================================================

loc_1C962:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		dbf	d6,ContScr_Loop	; repeat 1 more	time

		rts	
; End of function ContScrCounter

; ===========================================================================
; ---------------------------------------------------------------------------
; HUD counter sizes
; ---------------------------------------------------------------------------
Hud_100000:	dc.l 100000		; XREF: Hud_Score
Hud_10000:	dc.l 10000
Hud_1000:	dc.l 1000		; XREF: Hud_TimeRingBonus
Hud_100:	dc.l 100		; XREF: Hud_Rings
Hud_10:		dc.l 10			; XREF: ContScrCounter; Hud_Secs; Hud_Lives
Hud_1:		dc.l 1			; XREF: Hud_Mins

; ---------------------------------------------------------------------------
; Subroutine to	load time numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Mins:				; XREF: Hud_ChkTime
		lea	(Hud_1).l,a2
		moveq	#0,d6
		bra.s	loc_1C9BA
; End of function Hud_Mins


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Secs:				; XREF: Hud_ChkTime
		lea	(Hud_10).l,a2
		moveq	#1,d6

loc_1C9BA:
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_TimeLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1C9C4:
		sub.l	d3,d1
		bcs.s	loc_1C9CC
		addq.w	#1,d2
		bra.s	loc_1C9C4
; ===========================================================================

loc_1C9CC:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1C9D6
		move.w	#1,d4

loc_1C9D6:
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		dbf	d6,Hud_TimeLoop

		rts	
; End of function Hud_Secs

; ---------------------------------------------------------------------------
; Subroutine to	load time/ring bonus numbers patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_TimeRingBonus:			; XREF: Hud_ChkBonus
		lea	(Hud_1000).l,a2
		moveq	#3,d6
		moveq	#0,d4
		lea	Art_Hud(pc),a1

Hud_BonusLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA1E:
		sub.l	d3,d1
		bcs.s	loc_1CA26
		addq.w	#1,d2
		bra.s	loc_1CA1E
; ===========================================================================

loc_1CA26:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CA30
		move.w	#1,d4

loc_1CA30:
		tst.w	d4
		beq.s	Hud_ClrBonus
		lsl.w	#6,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)

loc_1CA5A:
		dbf	d6,Hud_BonusLoop ; repeat 3 more times

		rts	
; ===========================================================================

Hud_ClrBonus:
		moveq	#$F,d5

Hud_ClrBonusLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_ClrBonusLoop

		bra.s	loc_1CA5A
; End of function Hud_TimeRingBonus

; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed lives	counter	patterns
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Hud_Lives:				; XREF: Hud_ChkLives
		move.l	#$7B200003,d0	; set VRAM address
		moveq	#0,d1
		move.b	(Life_Count).w,d1 ; load	number of lives
		lea	(Hud_10).l,a2
		moveq	#1,d6
		moveq	#0,d4
		lea	Art_LivesNums(pc),a1
		move.l	d0,4(a6)

Hud_LivesLoop:
		moveq	#0,d2
		move.l	(a2)+,d3

loc_1CA90:
		sub.l	d3,d1
		bcs.s	loc_1CA98
		addq.w	#1,d2
		bra.s	loc_1CA90
; ===========================================================================

loc_1CA98:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_1CAA2
		move.w	#1,d4

loc_1CAA2:
		tst.w	d4
		beq.s	@chk
		tst.w	d6
		beq.s	loc_1CAA6
		cmpi.w	#1,d2
		beq.s	Hud_Lives_Draw10
		bra.s	loc_1CAA6

@chk:
		tst.w	d6
		beq.s	Hud_Lives_DrawDigit
		bra.s	Hud_Lives_End

loc_1CAA6:
		tst.w	d6
		bne.s	Hud_Lives_DrawDigit
		moveq	#0,d1
		move.b	(Life_Count).w,d1
		divu.w	#10,d1
		swap	d1
		tst.w	d1
		beq.s	Hud_Lives_DrawBlank

Hud_Lives_DrawDigit:
		lsl.w	#5,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		move.l	d0,4(a6)
		
Hud_Lives_Draw10:
		tst.w	d6
		beq.s	Hud_Lives_End
		move.w	#10*$20,d2
		lea	(a1,d2.w),a3
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		move.l	(a3)+,(a6)
		addi.l	#$400000,d0
		move.l	d0,4(a6)
		
Hud_Lives_End:
		dbf	d6,Hud_LivesLoop ; repeat 1 more time
		rts	
; ===========================================================================

Hud_Lives_DrawBlank:
		moveq	#7,d5

Hud_Lives_DrawBlankLoop:
		move.l	#0,(a6)
		dbf	d5,Hud_Lives_DrawBlankLoop
		addi.l	#$400000,d0
		move.l	d0,4(a6)
		bra.s	Hud_Lives_End
; End of function Hud_Lives

; ===========================================================================
Art_Hud:	incbin	art/uncompressed/HUD.bin		; 8x16 pixel numbers on HUD
		even
Art_LivesNums:	incbin	art/uncompressed/livescnt.bin	; 8x8 pixel numbers on lives counter
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:				; XREF: Obj01; Obj09
		moveq	#0,d0
		move.b	(Debug_Placement_Mode).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jmp	Debug_Index(pc,d1.w)
; ===========================================================================
Debug_Index:	dc.w Debug_Main-Debug_Index
		dc.w Debug_Skip-Debug_Index
; ===========================================================================

Debug_Main:				; XREF: Debug_Index
		addq.b	#2,(Debug_Placement_Mode).w
		move.w	(Camera_Min_Y_Pos).w,(Camera_Min_Y_Pos_Debug_Copy).w ; buffer level x-boundary
		move.w	(Target_Camera_Max_Y_Pos).w,(Camera_Max_Y_Pos_Debug_Copy).w ; buffer level y-boundary
		tst.w	(Object_Space_1+$C).w
		bpl.s	@NotNeg
		move.w	#0,(Object_Space_1+$C).w
		
@NotNeg:
		andi.w	#$7FF,(Object_Space_1+$C).w
		andi.w	#$7FF,(Camera_Y_Pos).w
		andi.w	#$7FF,(Camera_BG_Y_Pos).w
		move.b	#0,$1A(a0)
		move.b	#0,$1C(a0)
		moveq	#0,d0
		move.b	(Current_Zone).w,d0

Debug_UseList:
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		cmp.b	(Debug_Item).w,d6
		bhi.s	loc_1CF9E
		move.b	#0,(Debug_Item).w

loc_1CF9E:
		bsr.w	Debug_ShowItem
		move.b	#$C,(Debug_Accel_Timer).w
		move.b	#1,(Debug_Speed).w

Debug_Skip:				; XREF: Debug_Index
		moveq	#0,d0
		move.b	(Current_Zone).w,d0
		lea	(DebugList).l,a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		move.w	(a2)+,d6
		bsr.w	Debug_Control
		jmp	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_Control:
		moveq	#0,d4
		move.w	#1,d1
		move.b	(Ctrl_1_Press).w,d4
		andi.w	#$F,d4		; is up/down/left/right	pressed?
		bne.s	loc_1D018	; if yes, branch
		move.b	(Ctrl_1_Held).w,d0
		andi.w	#$F,d0
		bne.s	loc_1D000
		move.b	#$C,(Debug_Accel_Timer).w
		move.b	#$F,(Debug_Speed).w
		bra.w	Debug_BackItem
; ===========================================================================

loc_1D000:
		subq.b	#1,(Debug_Accel_Timer).w
		bne.s	loc_1D01C
		move.b	#1,(Debug_Accel_Timer).w
		addq.b	#1,(Debug_Speed).w
		bne.s	loc_1D018
		move.b	#-1,(Debug_Speed).w

loc_1D018:
		move.b	(Ctrl_1_Held).w,d4

loc_1D01C:
		moveq	#0,d1
		move.b	(Debug_Speed).w,d1
		addq.w	#1,d1
		swap	d1
		asr.l	#4,d1
		move.l	$C(a0),d2
		move.l	8(a0),d3
		btst	#0,d4		; is up	being pressed?
		beq.s	loc_1D03C	; if not, branch
		sub.l	d1,d2
		bcc.s	loc_1D03C
		moveq	#0,d2

loc_1D03C:
		btst	#1,d4		; is down being	pressed?
		beq.s	loc_1D052	; if not, branch
		add.l	d1,d2
		cmpi.l	#$7FF0000,d2
		bcs.s	loc_1D052
		move.l	#$7FF0000,d2

loc_1D052:
		btst	#2,d4
		beq.s	loc_1D05E
		sub.l	d1,d3
		bcc.s	loc_1D05E
		moveq	#0,d3

loc_1D05E:
		btst	#3,d4
		beq.s	loc_1D066
		add.l	d1,d3

loc_1D066:
		move.l	d2,$C(a0)
		move.l	d3,8(a0)

Debug_BackItem:
		btst	#6,(Ctrl_1_Held).w ; is button A pressed?
		beq.s	Debug_MakeItem	; if not, branch
		btst	#5,(Ctrl_1_Press).w ; is button C pressed?
		beq.s	Debug_NextItem	; if not, branch
		subq.b	#1,(Debug_Item).w ; go back 1 item
		bcc.s	Debug_NoLoop
		add.b	d6,(Debug_Item).w
		bra.s	Debug_NoLoop
; ===========================================================================

Debug_NextItem:
		btst	#6,(Ctrl_1_Press).w ; is button A pressed?
		beq.s	Debug_MakeItem	; if not, branch
		addq.b	#1,(Debug_Item).w ; go forwards 1 item
		cmp.b	(Debug_Item).w,d6
		bhi.s	Debug_NoLoop
		move.b	#0,(Debug_Item).w ; loop	back to	first item

Debug_NoLoop:
		bra.w	Debug_ShowItem
; ===========================================================================

Debug_MakeItem:
		btst	#5,(Ctrl_1_Press).w ; is button C pressed?
		beq.s	Debug_Exit	; if not, branch
		jsr	SingleObjLoad
		bne.s	Debug_Exit
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	4(a0),0(a1)	; create object
		move.b	1(a0),1(a1)
		move.b	1(a0),$22(a1)
		andi.b	#$7F,$22(a1)
		moveq	#0,d0
		move.b	(Debug_Item).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0.w),$28(a1)
		rts	
; ===========================================================================

Debug_Exit:
		btst	#4,(Ctrl_1_Press).w ; is button B pressed?
		beq.s	Debug_DoNothing	; if not, branch
		moveq	#0,d0
		move.w	d0,(Debug_Placement_Mode).w ; deactivate debug mode
		move.l	#Map_Sonic,(Object_Space_1+4).w
		move.w	#$780,(Object_Space_1+2).w
		bsr.s	ResetSonic
		move.b	#$13,(Object_Space_1+$16).w
		move.b	#9,(Object_Space_1+$17).w
		move.w	(Camera_Min_Y_Pos_Debug_Copy).w,(Camera_Min_Y_Pos).w ; restore level boundaries
		move.w	(Camera_Max_Y_Pos_Debug_Copy).w,(Target_Camera_Max_Y_Pos).w
		
Debug_DoNothing:
		rts	
		
ResetSonic:
		move.b	d0,(Object_Space_1+$1C).w
		move.w	d0,(Object_Space_1+$A).w
		move.w	d0,(Object_Space_1+$E).w
		move.b	d0,(Object_Space_1+$10).w
		move.b	d0,(Object_Space_1+$12).w
		move.b	d0,(Object_Space_1+$14).w
		move.b	#2,(Object_Space_1+$22).w
		move.b	#2,(Object_Space_1+$24).w
		rts
; End of function Debug_Control


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Debug_ShowItem:				; XREF: Debug_Main
		moveq	#0,d0
		move.b	(Debug_Item).w,d0
		lsl.w	#3,d0
		move.l	(a2,d0.w),4(a0)	; load mappings	for item
		move.w	6(a2,d0.w),2(a0) ; load	VRAM setting for item
		move.b	5(a2,d0.w),$1A(a0) ; load frame	number for item
		rts	
; End of function Debug_ShowItem

; ===========================================================================
; ---------------------------------------------------------------------------
; Debug	list pointers
; ---------------------------------------------------------------------------
DebugList:
	dc.w Debug_GHZ-DebugList
	dc.w Debug_LZ-DebugList
	dc.w Debug_MZ-DebugList
	dc.w Debug_SLZ-DebugList
	dc.w Debug_SYZ-DebugList
	dc.w Debug_SBZ-DebugList
	dc.w Debug_Ending-DebugList

; ---------------------------------------------------------------------------
; Debug	list - Green Hill
; ---------------------------------------------------------------------------
Debug_GHZ:
	dc.w $10			; number of items in list
	dc.l Map_obj25+$25000000	; mappings pointer, object type * 10^6
	dc.b 0,	0, $27,	$B2		; subtype, frame, VRAM setting (2 bytes)
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj1F+$1F000000
	dc.b 0,	0, 4, 0
	dc.l Map_obj22+$22000000
	dc.b 0,	0, 4, $44
	dc.l Map_obj2B+$2B000000
	dc.b 0,	0, 4, $7B
	dc.l Map_obj36+$36000000
	dc.b 0,	0, 5, $1B
	dc.l Map_obj18+$18000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj3B+$3B000000
	dc.b 0,	0, $63,	$D0
	dc.l Map_obj40+$40000000
	dc.b 0,	0, 4, $F0
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj42+$42000000
	dc.b 0,	0, $24,	$9B
	dc.l Map_obj44+$44000000
	dc.b 0,	0, $43,	$4C
	dc.l Map_obj48+$19000000
	dc.b 0,	0, $43,	$AA
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	dc.l Map_obj4B+$4B000000
	dc.b 0,	0, $24,	0
	dc.l Map_obj7D+$7D000000
	dc.b 1,	1, $84,	$B6
	even
; ---------------------------------------------------------------------------
; Debug	list - Labyrinth
; ---------------------------------------------------------------------------
Debug_LZ:
	dc.w $27
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj59+$59000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj53+$53000000
	dc.b 0,	2, $44,	$E0
	dc.l Map_obj18b+$18000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj5A+$5A000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj5B+$5B000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj5D+$5D000000
	dc.b 0,	0, $43,	$A0
	dc.l Map_obj5E+$5E000000
	dc.b 0,	0, 3, $74
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj14+$13000000
	dc.b 0,	0, 4, $80
	dc.l Map_obj1C+$1C000000
	dc.b 0,	0, $44,	$D8
	dc.l Map_obj5F+$5F000000
	dc.b 0,	0, 4, 0
	dc.l Map_obj60+$60000000
	dc.b 0,	0, $24,	$29
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj2C+$2C000000
	dc.b 8,	0, $24,	$86
	dc.l Map_obj2D+$2D000000
	dc.b 0,	2, $84,	$A6
	dc.l Map_obj16+$16000000
	dc.b 0,	0, 3, $CC
	dc.l Map_obj16+$16000000
	dc.b 2,	3, 3, $CC
	dc.l Map_obj33+$33000000
	dc.b 0,	0, $43,	$DE
	dc.l Map_obj32+$32000000
	dc.b 0,	0, 5, $13
	dc.l Map_obj36+$36000000
	dc.b 0,	0, 5, $1B
	dc.l Map_obj52a+$52000000
	dc.b 4,	0, $43,	$BC
	dc.l Map_obj61+$61000000
	dc.b 1,	0, $43,	$E6
	dc.l Map_obj61+$61000000
	dc.b $13, 1, $43, $E6
	dc.l Map_obj61+$61000000
	dc.b 5,	0, $43,	$E6
	dc.l Map_obj62+$62000000
	dc.b 0,	0, $44,	$3E
	dc.l Map_obj61+$61000000
	dc.b $27, 2, $43, $E6
	dc.l Map_obj61+$61000000
	dc.b $30, 3, $43, $E6
	dc.l Map_obj60+$60000000
	dc.b 0,	0, 4, $67
	dc.l Map_obj64+$64000000
	dc.b $84, $13, $83, $48
	dc.l Map_obj65+$65000000
	dc.b 2,	2, $C2,	$59
	dc.l Map_obj65+$65000000
	dc.b 9,	9, $C2,	$59
	dc.l Map_obj0B+$B000000
	dc.b 0,	0, $43,	$DE
	dc.l Map_obj0C+$C000000
	dc.b 2,	0, $43,	$28
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	even

; ---------------------------------------------------------------------------
; Debug	list - Marble
; ---------------------------------------------------------------------------
Debug_MZ:
	dc.w $12
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj22+$22000000
	dc.b 0,	0, 4, $44
	dc.l Map_obj36+$36000000
	dc.b 0,	0, 5, $1B
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj14+$13000000
	dc.b 0,	0, 3, $45
	dc.l Map_obj46+$46000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj4C+$4C000000
	dc.b 0,	0, $63,	$A8
	dc.l Map_obj4E+$4E000000
	dc.b 0,	0, $63,	$A8
	dc.l Map_obj33+$33000000
	dc.b 0,	0, $42,	$B8
	dc.l Map_obj50+$50000000
	dc.b 0,	0, $24,	$7B
	dc.l Map_obj51+$51000000
	dc.b 0,	0, $42,	$B8
	dc.l Map_obj52+$52000000
	dc.b 0,	0, 2, $B8
	dc.l Map_obj53+$53000000
	dc.b 0,	0, $62,	$B8
	dc.l Map_obj54+$54000000
	dc.b 0,	0, $86,	$80
	dc.l Map_obj55+$55000000
	dc.b 0,	0, 4, $B8
	dc.l Map_obj78+$78000000
	dc.b 0,	0, $24,	$FF
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	even

; ---------------------------------------------------------------------------
; Debug	list - Star Light
; ---------------------------------------------------------------------------
Debug_SLZ:
	dc.w $F
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj59+$59000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj53+$53000000
	dc.b 0,	2, $44,	$E0
	dc.l Map_obj18b+$18000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj5A+$5A000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj5B+$5B000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj5D+$5D000000
	dc.b 0,	0, $43,	$A0
	dc.l Map_obj5E+$5E000000
	dc.b 0,	0, 3, $74
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj14+$13000000
	dc.b 0,	0, 4, $80
	dc.l Map_obj1C+$1C000000
	dc.b 0,	0, $44,	$D8
	dc.l Map_obj5F+$5F000000
	dc.b 0,	0, 4, 0
	dc.l Map_obj60+$60000000
	dc.b 0,	0, $24,	$29
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	even

; ---------------------------------------------------------------------------
; Debug	list - Spring Yard
; ---------------------------------------------------------------------------
Debug_SYZ:
	dc.w $F
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	dc.l Map_obj36+$36000000
	dc.b 0,	0, 5, $1B
	dc.l Map_obj41+$41000000
	dc.b 0,	0, 5, $23
	dc.l Map_obj43+$43000000
	dc.b 0,	0, 4, $B8
	dc.l Map_obj12+$12000000
	dc.b 0,	0, 0, 0
	dc.l Map_obj47+$47000000
	dc.b 0,	0, 3, $80
	dc.l Map_obj1F+$1F000000
	dc.b 0,	0, 4, 0
	dc.l Map_obj22+$22000000
	dc.b 0,	0, 4, $44
	dc.l Map_obj50+$50000000
	dc.b 0,	0, $24,	$7B
	dc.l Map_obj18a+$18000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj56+$56000000
	dc.b 0,	0, $40,	0
	dc.l Map_obj32+$32000000
	dc.b 0,	0, 5, $13
	dc.l Map_obj78+$78000000
	dc.b 0,	0, $24,	$FF
	dc.l Map_obj79+$79000000
	dc.b 1,	0, 7, $A0
	even

; ---------------------------------------------------------------------------
; Debug	list - Scrap Brain
; ---------------------------------------------------------------------------
Debug_SBZ:
	dc.w 2
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj26+$26000000
	dc.b 0,	0, 6, $80
	even

; ---------------------------------------------------------------------------
; Debug	list - ending sequence / special stage
; ---------------------------------------------------------------------------
Debug_Ending:
	dc.w $D
	dc.l Map_obj25+$25000000
	dc.b 0,	0, $27,	$B2
	dc.l Map_obj47+$47000000
	dc.b 0,	0, 3, $80
	dc.l Map_obj28a+$28000000
	dc.b $A, 0, 5, $A0
	dc.l Map_obj28a+$28000000
	dc.b $B, 0, 5, $A0
	dc.l Map_obj28a+$28000000
	dc.b $C, 0, 5, $A0
	dc.l Map_obj28+$28000000
	dc.b $D, 0, 5, $53
	dc.l Map_obj28+$28000000
	dc.b $E, 0, 5, $53
	dc.l Map_obj28+$28000000
	dc.b $F, 0, 5, $73
	dc.l Map_obj28+$28000000
	dc.b $10, 0, 5,	$73
	dc.l Map_obj28a+$28000000
	dc.b $11, 0, 5,	$85
	dc.l Map_obj28b+$28000000
	dc.b $12, 0, 5,	$93
	dc.l Map_obj28a+$28000000
	dc.b $13, 0, 5,	$65
	dc.l Map_obj28b+$28000000
	dc.b $14, 0, 5,	$B3
	even

; ---------------------------------------------------------------------------
; Main level load blocks
; ---------------------------------------------------------------------------
MainLoadBlocks:
	dc.l Nem_GHZ+$4000000
	dc.l Blk16_GHZ+$5000000
	dc.l Blk256_GHZ
	dc.b 0,	$81, 4,	4
	dc.l Nem_LZ+$6000000
	dc.l Blk16_LZ+$7000000
	dc.l Blk256_LZ
	dc.b 0,	$82, 5,	5
	dc.l Nem_MZ+$8000000
	dc.l Blk16_MZ+$9000000
	dc.l Blk256_MZ
	dc.b 0,	$83, 6,	6
	dc.l Nem_SLZ+$A000000
	dc.l Blk16_SLZ+$B000000
	dc.l Blk256_SLZ
	dc.b 0,	$84, 7,	7
	dc.l Nem_SYZ+$C000000
	dc.l Blk16_SYZ+$D000000
	dc.l Blk256_SYZ
	dc.b 0,	$85, 8,	8
	dc.l Nem_SBZ+$E000000
	dc.l Blk16_SBZ+$F000000
	dc.l Blk256_SBZ
	dc.b 0,	$86, 9,	9
	dc.l Nem_TIT_1st	; main load block for ending
	dc.l Blk16_TS
	dc.l Blk256_TS
	dc.b 0,	$86, $13, $13

; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:
	dc.w PLC_Main-ArtLoadCues, PLC_Main2-ArtLoadCues
	dc.w PLC_Explode-ArtLoadCues, PLC_GameOver-ArtLoadCues
	dc.w PLC_GHZ-ArtLoadCues, PLC_GHZ2-ArtLoadCues
	dc.w PLC_LZ-ArtLoadCues, PLC_LZ2-ArtLoadCues
	dc.w PLC_MZ-ArtLoadCues, PLC_MZ2-ArtLoadCues
	dc.w PLC_SLZ-ArtLoadCues, PLC_SLZ2-ArtLoadCues
	dc.w PLC_SYZ-ArtLoadCues, PLC_SYZ2-ArtLoadCues
	dc.w PLC_SBZ-ArtLoadCues, PLC_SBZ2-ArtLoadCues
	dc.w PLC_TitleCard-ArtLoadCues,	PLC_Boss-ArtLoadCues
	dc.w PLC_Signpost-ArtLoadCues, PLC_Warp-ArtLoadCues
	dc.w PLC_SpeStage-ArtLoadCues, PLC_GHZAnimals-ArtLoadCues
	dc.w PLC_LZAnimals-ArtLoadCues,	PLC_MZAnimals-ArtLoadCues
	dc.w PLC_SLZAnimals-ArtLoadCues, PLC_SYZAnimals-ArtLoadCues
	dc.w PLC_SBZAnimals-ArtLoadCues, PLC_SpeStResult-ArtLoadCues
	dc.w PLC_Ending-ArtLoadCues, PLC_TryAgain-ArtLoadCues
	dc.w PLC_Main-ArtLoadCues, PLC_Main-ArtLoadCues
	dc.w PLC_TimeOver-ArtLoadCues
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	dc.w 5
		dc.l Nem_Lamp		; lamppost
		dc.w $D800
		dc.l Nem_Hud		; HUD
		dc.w $D940
		dc.l Nem_Lives		; lives	counter
		dc.w $FA80
		dc.l Nem_LivesPic	; lives	counter pic
		dc.w $F380
		dc.l Nem_Ring		; rings
		dc.w $F640
		dc.l Nem_Points
		dc.w $AE00
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w 0
		dc.l Nem_Monitors	; monitors
		dc.w $D000
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w 0
		dc.l Nem_Explode	; explosion
		dc.w $B400
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w 0
		dc.l Nem_GameOver	; game/time over
		dc.w $541*$20
; ---------------------------------------------------------------------------
; Pattern load cues - game/time	over
; ---------------------------------------------------------------------------
PLC_TimeOver:	dc.w 0
		dc.l Nem_TimeOver	; game/time over
		dc.w $541*$20
; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------
PLC_GHZ:	dc.w $A
		dc.l Nem_GHZ		; GHZ main patterns
		dc.w 0
		dc.l Nem_Stalk		; flower stalk
		dc.w $6B00
		dc.l Nem_PplRock	; purple rock
		dc.w $7A00
		dc.l Nem_Crabmeat	; crabmeat enemy
		dc.w $8000
		dc.l Nem_Buzz		; buzz bomber enemy
		dc.w $8880
		dc.l Nem_Chopper	; chopper enemy
		dc.w $8F60
		dc.l Nem_Newtron	; newtron enemy
		dc.w $9360
		dc.l Nem_Motobug	; motobug enemy
		dc.w $9E00
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
PLC_GHZ2:	dc.w 5
		dc.l Nem_Swing		; swinging platform
		dc.w $7000
		dc.l Nem_Bridge		; bridge
		dc.w $71C0
		dc.l Nem_SpikePole	; spiked pole
		dc.w $7300
		dc.l Nem_Ball		; giant	ball
		dc.w $7540
		dc.l Nem_GhzWall1	; breakable wall
		dc.w $A1E0
		dc.l Nem_GhzWall2	; normal wall
		dc.w $6980
; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		
		dc.w $B
		dc.l Nem_LZ			; LZ main patterns
		dc.w 0
		dc.l Nem_Bomb		; bomb enemy
		dc.w $8000
		dc.l Nem_Orbinaut	; orbinaut enemy
		dc.w $8520
		dc.l Nem_MzFire		; fireballs
		dc.w $9000
		dc.l Nem_SlzBlock	; block
		dc.w $9C00
		dc.l Nem_SlzWall	; breakable wall
		dc.w $A260
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
		dc.l Nem_Water		; water	surface
		dc.w $6000
		dc.l Nem_BigBubbles	; bubbles and numbers
		dc.w $6900
		dc.l Nem_Bubbles	; bubbles and numbers
		dc.w $7AA0
PLC_LZ2:	dc.w 3
		dc.l Nem_Seesaw		; seesaw
		dc.w $6E80
		dc.l Nem_Fan		; fan
		dc.w $7400
		;dc.l Nem_SlzSwing	; swinging platform
		;dc.w $7B80
		dc.l Nem_SlzCannon	; fireball launcher
		dc.w $9B00
		dc.l Nem_SlzSpike	; spikeball
		dc.w $9E00
; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		dc.w 9
		dc.l Nem_MZ		; MZ main patterns
		dc.w 0
		dc.l Nem_MzMetal	; metal	blocks
		dc.w $6000
		dc.l Nem_MzFire		; fireballs
		dc.w $68A0
		dc.l Nem_Swing		; swinging platform
		dc.w $7000
		dc.l Nem_MzGlass	; green	glassy block
		dc.w $71C0
		dc.l Nem_Lava		; lava
		dc.w $7500
		dc.l Nem_Buzz		; buzz bomber enemy
		dc.w $8880
		dc.l Nem_Yadrin		; yadrin enemy
		dc.w $8F60
		dc.l Nem_Basaran	; basaran enemy
		dc.w $9700
		dc.l Nem_Cater		; caterkiller enemy
		dc.w $9FE0
PLC_MZ2:	dc.w 4
		dc.l Nem_MzSwitch	; switch
		dc.w $A260
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
		dc.l Nem_MzBlock	; green	stone block
		dc.w $5700
; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	dc.w 8
		dc.l Nem_SLZ		; SLZ main patterns
		dc.w 0
		dc.l Nem_Bomb		; bomb enemy
		dc.w $8000
		dc.l Nem_Orbinaut	; orbinaut enemy
		dc.w $8520
		dc.l Nem_MzFire		; fireballs
		dc.w $9000
		dc.l Nem_SlzBlock	; block
		dc.w $9C00
		dc.l Nem_SlzWall	; breakable wall
		dc.w $A260
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
PLC_SLZ2:	dc.w 5
		dc.l Nem_Seesaw		; seesaw
		dc.w $6E80
		dc.l Nem_Fan		; fan
		dc.w $7400
		dc.l Nem_Pylon		; foreground pylon
		dc.w $7980
		dc.l Nem_SlzSwing	; swinging platform
		dc.w $7B80
		dc.l Nem_SlzCannon	; fireball launcher
		dc.w $9B00
		dc.l Nem_SlzSpike	; spikeball
		dc.w $9E00
; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	dc.w 4
		dc.l Nem_SYZ		; SYZ main patterns
		dc.w 0
		dc.l Nem_Crabmeat	; crabmeat enemy
		dc.w $8000
		dc.l Nem_Buzz		; buzz bomber enemy
		dc.w $8880
		dc.l Nem_Yadrin		; yadrin enemy
		dc.w $8F60
		dc.l Nem_Roller		; roller enemy
		dc.w $9700
PLC_SYZ2:	dc.w 7
		dc.l Nem_Bumper		; bumper
		dc.w $7000
		dc.l Nem_SyzSpike1	; large	spikeball
		dc.w $72C0
		dc.l Nem_SyzSpike2	; small	spikeball
		dc.w $7740
		dc.l Nem_Cater		; caterkiller enemy
		dc.w $9FE0
		dc.l Nem_LzSwitch	; switch
		dc.w $A1E0
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	dc.w 0
		dc.l Nem_SBZ		; SBZ main patterns
		dc.w 0
PLC_SBZ2:	dc.w 2
		dc.l Nem_Spikes		; spikes
		dc.w $A360
		dc.l Nem_HSpring	; horizontal spring
		dc.w $A460
		dc.l Nem_VSpring	; vertical spring
		dc.w $A660
; ---------------------------------------------------------------------------
; Pattern load cues - title card
; ---------------------------------------------------------------------------
PLC_TitleCard:	dc.w 1
		dc.l Nem_TitleCard
		dc.w $B000
		dc.l Nem_LoverWentRight
		dc.w $B5A0
; ---------------------------------------------------------------------------
; Pattern load cues - act 3 boss
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w 5
		dc.l Nem_Eggman		; Eggman main patterns
		dc.w $8000
		dc.l Nem_Weapons	; Eggman's weapons
		dc.w $8D80
		dc.l Nem_Prison		; prison capsule
		dc.w $93A0
		dc.l Nem_Bomb		; bomb enemy (gets overwritten)
		dc.w $A300
		dc.l Nem_SlzSpike	; spikeball (SLZ boss)
		dc.w $A300
		dc.l Nem_Exhaust	; exhaust flame
		dc.w $A540
; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 signpost
; ---------------------------------------------------------------------------
PLC_Signpost:	dc.w 2
		dc.l Nem_SignPost	; signpost
		dc.w $680*$20
		dc.l Nem_Bonus		; hidden bonus points
		dc.w $96C0
		dc.l Nem_BigFlash	; giant	ring flash effect
		dc.w $8C40
; ---------------------------------------------------------------------------
; Pattern load cues - beta special stage warp effect
; ---------------------------------------------------------------------------
PLC_Warp:	dc.w 0
		dc.l Nem_Warp
		dc.w $A820
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpeStage:	dc.w $FF
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w 1
		dc.l Nem_Rabbit		; rabbit
		dc.w $B000
		dc.l Nem_Flicky		; flicky
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w 1
		dc.l Nem_BlackBird	; blackbird
		dc.w $B000
		dc.l Nem_Seal		; seal
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w 1
		dc.l Nem_Squirrel	; squirrel
		dc.w $B000
		dc.l Nem_Seal		; seal
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w 1
		dc.l Nem_Pig		; pig
		dc.w $B000
		dc.l Nem_Flicky		; flicky
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w 1
		dc.l Nem_Pig		; pig
		dc.w $B000
		dc.l Nem_Chicken	; chicken
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w 1
		dc.l Nem_Rabbit		; rabbit
		dc.w $B000
		dc.l Nem_Chicken	; chicken
		dc.w $B240
; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SpeStResult:	dc.w $FF
; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w $E
		dc.l Nem_TIT_1st	; Title main patterns
		dc.w 0
		dc.l Nem_TIT_2nd	; Title secondary patterns
		dc.w $39A0
		dc.l Nem_Stalk		; flower stalk
		dc.w $6B00
		dc.l Nem_EndFlower	; flowers
		dc.w $7400
		dc.l Nem_EndEm		; emeralds
		dc.w $78A0
		dc.l Nem_EndSonic	; Sonic
		dc.w $7C20
		dc.l Nem_EndEggman	; Eggman's death (unused)
		dc.w $A480
		dc.l Nem_Rabbit		; rabbit
		dc.w $AA60
		dc.l Nem_Chicken	; chicken
		dc.w $ACA0
		dc.l Nem_BlackBird	; blackbird
		dc.w $AE60
		dc.l Nem_Seal		; seal
		dc.w $B0A0
		dc.l Nem_Pig		; pig
		dc.w $B260
		dc.l Nem_Flicky		; flicky
		dc.w $B4A0
		dc.l Nem_Squirrel	; squirrel
		dc.w $B660
		dc.l Nem_EndStH		; "SONIC THE HEDGEHOG"
		dc.w $B8A0
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w 2
		dc.l Nem_EndEm		; emeralds
		dc.w $78A0
		dc.l Nem_TryAgain	; Eggman
		dc.w $7C20
		dc.l Nem_CreditText	; credits alphabet
		dc.w $B400
; ===========================================================================
Nem_SegaLogo:	incbin	art/nemesis/segalogo.bin	; large Sega logo
		even
Eni_SegaLogo:	incbin	mappings/plane/enigma/segalogo.bin	; large Sega logo (mappings)
		even
Eni_Title:	incbin	mappings/plane/enigma/titlescr.bin	; title screen foreground (mappings)
		even
Nem_TitleFg:	incbin	art/nemesis/titlefor.bin	; title screen foreground
		even
Nem_TitleSonic:	incbin	art/nemesis/titleson.bin	; Sonic on title screen
		even
Nem_TitleTM:	incbin	art/nemesis/titletm.bin	; TM on title screen
		even
Eni_JapNames:	incbin	mappings/plane/enigma/japcreds.bin	; Japanese credits (mappings)
		even
Nem_JapNames:	incbin	art/nemesis/japcreds.bin	; Japanese credits
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_Smoke:	incbin	art/nemesis/xxxsmoke.bin	; unused smoke
		even
Nem_SyzSparkle:	incbin	art/nemesis/xxxstars.bin	; unused stars
		even
Art_Shield:	incbin	art/uncompressed/shield.bin	; shield
		even
Art_Stars:	incbin	art/uncompressed/invstars.bin	; invincibility stars
		even
Nem_LzSonic:	incbin	art/nemesis/xxxlzson.bin	; unused LZ Sonic holding his breath
		even
Nem_UnkFire:	incbin	art/nemesis/xxxfire.bin	; unused fireball
		even
Nem_Warp:	incbin	art/nemesis/xxxflash.bin	; unused entry to special stage flash
		even
Nem_Goggle:	incbin	art/nemesis/xxxgoggl.bin	; unused goggles
		even
; ---------------------------------------------------------------------------
; Compressed graphics - GHZ stuff
; ---------------------------------------------------------------------------
Nem_Stalk:	incbin	art/nemesis/ghzstalk.bin	; GHZ flower stalk
		even
Nem_Swing:	incbin	art/nemesis/ghzswing.bin	; GHZ swinging platform
		even
Nem_Bridge:	incbin	art/nemesis/ghzbridg.bin	; GHZ bridge
		even
Nem_GhzUnkBlock:incbin	art/nemesis/xxxghzbl.bin	; unused GHZ block
		even
Nem_Ball:	incbin	art/nemesis/ghzball.bin	; GHZ giant ball
		even
Nem_Spikes:	incbin	art/nemesis/spikes.bin	; spikes
		even
Nem_GhzLog:	incbin	art/nemesis/xxxghzlo.bin	; unused GHZ log
		even
Nem_SpikePole:	incbin	art/nemesis/ghzlog.bin	; GHZ spiked log
		even
Nem_PplRock:	incbin	art/nemesis/ghzrock.bin	; GHZ purple rock
		even
Nem_GhzWall1:	incbin	art/nemesis/ghzwall1.bin	; GHZ destroyable wall
		even
Nem_GhzWall2:	incbin	art/nemesis/ghzwall2.bin	; GHZ normal wall
		even
; ---------------------------------------------------------------------------
; Compressed graphics - LZ stuff
; ---------------------------------------------------------------------------
Nem_Water:	incbin	art/nemesis/lzwater.bin	; LZ water surface
		even
Nem_Splash:	incbin	art/nemesis/lzsplash.bin	; LZ waterfalls and splashes
		even
Nem_LzSpikeBall:incbin	art/nemesis/lzspball.bin	; LZ spiked ball on chain
		even
Nem_FlapDoor:	incbin	art/nemesis/lzflapdo.bin	; LZ flapping door
		even
Nem_BigBubbles:	incbin	art/nemesis/lzbubble.bin	; LZ bubbles
		even
Nem_Bubbles:	incbin	art/nemesis/lzbubble2.bin	; LZ bubbles
		even
Nem_LzBlock3:	incbin	art/nemesis/lzblock3.bin	; LZ 32x16 block
		even
Nem_LzDoor1:	incbin	art/nemesis/lzvdoor.bin	; LZ vertical door
		even
Nem_Harpoon:	incbin	art/nemesis/lzharpoo.bin	; LZ harpoon
		even
Nem_LzPole:	incbin	art/nemesis/lzpole.bin	; LZ pole that breaks
		even
Nem_LzDoor2:	incbin	art/nemesis/lzhdoor.bin	; LZ large horizontal door
		even
Nem_LzWheel:	incbin	art/nemesis/lzwheel.bin	; LZ wheel from corner of conveyor belt
		even
Nem_Gargoyle:	incbin	art/nemesis/lzgargoy.bin	; LZ gargoyle head and spitting fire
		even
Nem_LzBlock2:	incbin	art/nemesis/lzblock2.bin	; LZ blocks
		even
Nem_LzPlatfm:	incbin	art/nemesis/lzptform.bin	; LZ rising platforms
		even
Nem_Cork:	incbin	art/nemesis/lzcork.bin	; LZ cork block
		even
Nem_LzBlock1:	incbin	art/nemesis/lzblock1.bin	; LZ 32x32 block
		even
; ---------------------------------------------------------------------------
; Compressed graphics - MZ stuff
; ---------------------------------------------------------------------------
Nem_MzMetal:	incbin	art/nemesis/mzmetal.bin	; MZ metal blocks
		even
Nem_MzSwitch:	incbin	art/nemesis/mzswitch.bin	; MZ switch
		even
Nem_MzGlass:	incbin	art/nemesis/mzglassy.bin	; MZ green glassy block
		even
Nem_GhzGrass:	incbin	art/nemesis/xxxgrass.bin	; unused grass (GHZ or MZ?)
		even
Nem_MzFire:	incbin	art/nemesis/mzfire.bin	; MZ fireballs
		even
Nem_Lava:	incbin	art/nemesis/mzlava.bin	; MZ lava
		even
Nem_MzBlock:	incbin	art/nemesis/mzblock.bin	; MZ green pushable block
		even
Nem_MzUnkBlock:	incbin	art/nemesis/xxxmzblo.bin	; MZ unused background block
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SLZ stuff
; ---------------------------------------------------------------------------
Nem_Seesaw:	incbin	art/nemesis/slzseesa.bin	; SLZ seesaw
		even
Nem_SlzSpike:	incbin	art/nemesis/slzspike.bin	; SLZ spikeball that sits on a seesaw
		even
Nem_Fan:	incbin	art/nemesis/slzfan.bin	; SLZ fan
		even
Nem_SlzWall:	incbin	art/nemesis/slzwall.bin	; SLZ smashable wall
		even
Nem_Pylon:	incbin	art/nemesis/slzpylon.bin	; SLZ foreground pylon
		even
Nem_SlzSwing:	incbin	art/nemesis/slzswing.bin	; SLZ swinging platform
		even
Nem_SlzBlock:	incbin	art/nemesis/slzblock.bin	; SLZ 32x32 block
		even
Nem_SlzCannon:	incbin	art/nemesis/slzcanno.bin	; SLZ fireball launcher cannon
		even
; ---------------------------------------------------------------------------
; Compressed graphics - SYZ stuff
; ---------------------------------------------------------------------------
Nem_Bumper:	incbin	art/nemesis/syzbumpe.bin	; SYZ bumper
		even
Nem_SyzSpike2:	incbin	art/nemesis/syzsspik.bin	; SYZ small spikeball
		even
Nem_LzSwitch:	incbin	art/nemesis/switch.bin	; LZ/SYZ/SBZ switch
		even
Nem_SyzSpike1:	incbin	art/nemesis/syzlspik.bin	; SYZ/SBZ large spikeball
		even
; ---------------------------------------------------------------------------
; Compressed graphics - enemies
; ---------------------------------------------------------------------------
Nem_BallHog:	incbin	art/nemesis/ballhog.bin	; ball hog
		even
Nem_Crabmeat:	incbin	art/nemesis/crabmeat.bin	; crabmeat
		even
Nem_Buzz:	incbin	art/nemesis/buzzbomb.bin	; buzz bomber
		even
Nem_UnkExplode:	incbin	art/nemesis/xxxexplo.bin	; unused explosion
		even
Nem_Burrobot:	incbin	art/nemesis/burrobot.bin	; burrobot
		even
Nem_Chopper:	incbin	art/nemesis/chopper.bin	; chopper
		even
Nem_Jaws:	incbin	art/nemesis/jaws.bin		; jaws
		even
Nem_Roller:	incbin	art/nemesis/roller.bin	; roller
		even
Nem_Motobug:	incbin	art/nemesis/motobug.bin	; moto bug
		even
Nem_Newtron:	incbin	art/nemesis/newtron.bin	; newtron
		even
Nem_Yadrin:	incbin	art/nemesis/yadrin.bin	; yadrin
		even
Nem_Basaran:	incbin	art/nemesis/basaran.bin	; basaran
		even
Nem_Splats:	incbin	art/nemesis/splats.bin	; splats
		even
Nem_Bomb:	incbin	art/nemesis/bomb.bin		; bomb
		even
Nem_Orbinaut:	incbin	art/nemesis/orbinaut.bin	; orbinaut
		even
Nem_Cater:	incbin	art/nemesis/caterkil.bin	; caterkiller
		even
; ---------------------------------------------------------------------------
; Compressed graphics - various
; ---------------------------------------------------------------------------
Nem_TitleCard:	incbin	art/nemesis/ttlcards.bin	; title cards
		even
Nem_Hud:	incbin	art/nemesis/hud.bin		; HUD (rings, time, score)
		even
Nem_Lives:	incbin	art/nemesis/lifeicon.bin	; life counter icon
		even
Nem_LivesPic:	incbin	art/nemesis/lifeiconpic.bin	; life counter icon picture
		even
Nem_Ring:	incbin	art/nemesis/rings.bin	; rings
		even
Nem_Monitors:	incbin	art/nemesis/monitors.bin	; monitors
		even
Nem_Explode:	incbin	art/nemesis/explosio.bin	; explosion
		even
Nem_Points:	incbin	art/nemesis/points.bin	; points from destroyed enemy or object
		even
Nem_GameOver:	incbin	art/nemesis/gameover.bin	; game over / time over
		even
Nem_TimeOver:	incbin	art/nemesis/timeover.bin	; game over / time over
		even
Nem_HSpring:	incbin	art/nemesis/springh.bin	; horizontal spring
		even
Nem_VSpring:	incbin	art/nemesis/springv.bin	; vertical spring
		even
Nem_SignPost:	incbin	art/nemesis/signpost.bin	; end of level signpost
		even
Nem_Lamp:	incbin	art/nemesis/lamppost.bin	; lamppost
		even
Nem_BigFlash:	incbin	art/nemesis/rngflash.bin	; flash from giant ring
		even
Nem_Bonus:	incbin	art/nemesis/bonus.bin	; hidden bonuses at end of a level
		even
; ---------------------------------------------------------------------------
; Compressed graphics - continue screen
; ---------------------------------------------------------------------------
Nem_ContSonic:	incbin	art/nemesis/cntsonic.bin	; Sonic on continue screen
		even
Nem_MiniSonic:	incbin	art/nemesis/cntother.bin	; mini Sonic and text on continue screen
		even
; ---------------------------------------------------------------------------
; Compressed graphics - animals
; ---------------------------------------------------------------------------
Nem_Rabbit:	incbin	art/nemesis/rabbit.bin	; rabbit
		even
Nem_Chicken:	incbin	art/nemesis/chicken.bin	; chicken
		even
Nem_BlackBird:	incbin	art/nemesis/blackbrd.bin	; blackbird
		even
Nem_Seal:	incbin	art/nemesis/seal.bin		; seal
		even
Nem_Pig:	incbin	art/nemesis/pig.bin		; pig
		even
Nem_Flicky:	incbin	art/nemesis/flicky.bin	; flicky
		even
Nem_Squirrel:	incbin	art/nemesis/squirrel.bin	; squirrel
		even
; ---------------------------------------------------------------------------
; Compressed graphics - primary patterns and block mappings
; ---------------------------------------------------------------------------

Nem_TIT_1st:	incbin	art/nemesis/8x8tit1.bin	; Title primary patterns
		even
Nem_TIT_2nd:	incbin	art/nemesis/8x8tit2.bin	; Title secondary patterns
		even
Blk16_TS:	incbin	level/blocks/ts.bin
		even
Blk256_TS:	incbin	level/chunks/ts.bin
		even
Blk16_GHZ:	incbin	level/blocks/ghz.bin
		even
Nem_GHZ:	incbin	art/nemesis/8x8ghz.bin	; GHZ primary patterns
		even
Blk256_GHZ:	incbin	level/chunks/ghz.bin
		even
Blk16_LZ:	incbin	level/blocks/lz.bin
		even
Nem_LZ:		incbin	art/nemesis/8x8lz.bin	; LZ primary patterns
		even
Blk256_LZ:	incbin	level/chunks/lz.bin
		even
Blk16_MZ:	incbin	level/blocks/mz.bin
		even
Nem_MZ:		incbin	art/nemesis/8x8mz.bin	; MZ primary patterns
		even
Blk256_MZ:	incbin	level/chunks/mz.bin
		even
Blk16_SLZ:	incbin	level/blocks/slz.bin
		even
Nem_SLZ:	incbin	art/nemesis/8x8slz.bin	; SLZ primary patterns
		even
Blk256_SLZ:	incbin	level/chunks/slz.bin
		even
Blk16_SYZ:	incbin	level/blocks/syz.bin
		even
Nem_SYZ:	incbin	art/nemesis/8x8syz.bin	; SYZ primary patterns
		even
Blk256_SYZ:	incbin	level/chunks/syz.bin
		even
Blk16_SBZ:	incbin	level/blocks/sbz.bin
		even
Nem_SBZ:	incbin	art/nemesis/8x8sbz.bin	; SBZ primary patterns
		even
Blk256_SBZ:	incbin	level/chunks/sbz.bin
		even
; ---------------------------------------------------------------------------
; Compressed graphics - bosses and ending sequence
; ---------------------------------------------------------------------------
Nem_Eggman:	incbin	art/nemesis/bossmain.bin	; boss main patterns
		even
Nem_Weapons:	incbin	art/nemesis/bossxtra.bin	; boss add-ons and weapons
		even
Nem_Prison:	incbin	art/nemesis/prison.bin	; prison capsule
		even
Nem_Sbz2Eggman:	incbin	art/nemesis/sbz2boss.bin	; Eggman in SBZ2 and FZ
		even
Nem_FzBoss:	incbin	art/nemesis/fzboss.bin	; FZ boss
		even
Nem_FzEggman:	incbin	art/nemesis/fzboss2.bin	; Eggman after the FZ boss
		even
Nem_Exhaust:	incbin	art/nemesis/bossflam.bin	; boss exhaust flame
		even
Nem_EndEm:	incbin	art/nemesis/endemera.bin	; ending sequence chaos emeralds
		even
Nem_EndSonic:	incbin	art/nemesis/endsonic.bin	; ending sequence Sonic
		even
Nem_TryAgain:	incbin	art/nemesis/tryagain.bin	; ending "try again" screen
		even
Nem_EndEggman:	incbin	art/nemesis/xxxend.bin	; unused boss sequence on ending
		even
Kos_EndFlowers:	incbin	art/kosinski/flowers.bin	; ending sequence animated flowers
		even
Nem_EndFlower:	incbin	art/nemesis/endflowe.bin	; ending sequence flowers
		even
Nem_CreditText:	incbin	art/nemesis/credits.bin	; credits alphabet
		even
Nem_EndStH:	incbin	art/nemesis/endtext.bin	; ending sequence "Sonic the Hedgehog" text
		even
; ---------------------------------------------------------------------------
; Collision data
; ---------------------------------------------------------------------------
AngleMap:	incbin	level/collision/anglemap.bin	; floor angle map
		even
CollArray1:	incbin	level/collision/carray_n.bin	; normal collision array
		even
CollArray2:	incbin	level/collision/carray_r.bin	; rotated collision array
		even
Col_GHZ_1:	incbin	level/collision/ghz1.bin	; GHZ index 1
		even
Col_GHZ_2:	incbin	level/collision/ghz2.bin	; GHZ index 2
		even
Col_LZ_1:	incbin	level/collision/lz1.bin		; LZ index 1
		even
Col_LZ_2:	incbin	level/collision/lz2.bin		; LZ index 2
		even
Col_MZ_1:	incbin	level/collision/mz1.bin		; MZ index 1
		even
Col_MZ_2:	incbin	level/collision/mz2.bin		; MZ index 2
		even
Col_SLZ_1:	incbin	level/collision/slz1.bin	; SLZ index 1
		even
Col_SLZ_2:	incbin	level/collision/slz2.bin	; SLZ index 2
		even
Col_SYZ_1:	incbin	level/collision/syz1.bin	; SYZ index 1
		even
Col_SYZ_2:	incbin	level/collision/syz2.bin	; SYZ index 2
		even
Col_SBZ_1:	incbin	level/collision/sbz1.bin	; SBZ index 1
		even
Col_SBZ_2:	incbin	level/collision/sbz2.bin	; SBZ index 2
		even
; ---------------------------------------------------------------------------
; Animated uncompressed graphics
; ---------------------------------------------------------------------------
Art_GhzWater:	incbin	art/uncompressed/ghzwater.bin	; GHZ waterfall
		even
Art_GhzFlower1:	incbin	art/uncompressed/ghzflowl.bin	; GHZ large flower
		even
Art_GhzFlower2:	incbin	art/uncompressed/ghzflows.bin	; GHZ small flower
		even
Art_MzLava1:	incbin	art/uncompressed/mzlava1.bin	; MZ lava surface
		even
Art_MzLava2:	incbin	art/uncompressed/mzlava2.bin	; MZ lava
		even
Art_MzTorch:	incbin	art/uncompressed/mztorch.bin	; MZ torch in background
		even
Art_SbzSmoke:	incbin	art/uncompressed/sbzsmoke.bin	; SBZ smoke in background
		even

; ---------------------------------------------------------------------------
; Level	layout index
; ---------------------------------------------------------------------------
Level_Index:	dc.l Level_GHZ1
		dc.l Level_GHZ1
		dc.l Level_GHZ1
		dc.l Level_GHZ1
		dc.l Level_LZ1
		dc.l Level_LZ2
		dc.l Level_LZ1
		dc.l Level_LZ1
		dc.l Level_MZ1
		dc.l Level_MZ2
		dc.l Level_MZ1
		dc.l Level_MZ1
		dc.l Level_SLZ1
		dc.l Level_SLZ2
		dc.l Level_SLZ1
		dc.l Level_SLZ1
		dc.l Level_SYZ1
		dc.l Level_SYZ2
		dc.l Level_SYZ1
		dc.l Level_SYZ1
		dc.l Level_GHZ1
		dc.l Level_GHZ1
		dc.l Level_SBZ2
		dc.l Level_GHZ1
		dc.l Level_End
		dc.l Level_End
		dc.l Level_End
		dc.l Level_End

Level_GHZ1:	incbin	level/layouts/ghz1.bin
		even
Level_LZ1:	incbin	level/layouts/lz1.bin
		even
Level_LZ2:	incbin	level/layouts/lz2.bin
		even
Level_MZ1:	incbin	level/layouts/mz1.bin
		even
Level_MZ2:	incbin	level/layouts/mz2.bin
		even
Level_SLZ1:	incbin	level/layouts/slz1.bin
		even
Level_SLZ2:	incbin	level/layouts/slz2.bin
		even
Level_SYZ1:	incbin	level/layouts/syz1.bin
		even
Level_SYZ2:	incbin	level/layouts/syz2.bin
		even
Level_SBZ2:	incbin	level/layouts/sbz2.bin
		even
Level_End:	incbin	level/layouts/ending.bin
		even
; ---------------------------------------------------------------------------
; Animated uncompressed giant ring graphics
; ---------------------------------------------------------------------------
Art_BigRing:	incbin	art/uncompressed/bigring.bin
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Object locations index
; ---------------------------------------------------------------------------
ObjPos_Index:	dc.l ObjPos_GHZ1
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_LZ1
		dc.l ObjPos_LZ2
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_MZ1
		dc.l ObjPos_MZ2
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_SLZ1
		dc.l ObjPos_SLZ2
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_SYZ1
		dc.l ObjPos_SYZ2
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_Null
		dc.l ObjPos_FZ
		dc.l ObjPos_Null
		dc.l ObjPos_End
		dc.l ObjPos_End
		dc.l ObjPos_End
		dc.l ObjPos_End
		dc.b $FF, $FF, 0, 0, 0,	0
; ===========================================================================
ObjPos_GHZ1:	incbin	level/objpos/ghz1.bin
		even
ObjPos_LZ1:	incbin	level/objpos/lz1.bin
		even
ObjPos_LZ2:	incbin	level/objpos/lz2.bin
		even
ObjPos_MZ1:	incbin	level/objpos/mz1.bin
		even
ObjPos_MZ2:	incbin	level/objpos/mz2.bin
		even
ObjPos_SLZ1:	incbin	level/objpos/slz1.bin
		even
ObjPos_SLZ2:	incbin	level/objpos/slz2.bin
		even
ObjPos_SYZ1:	incbin	level/objpos/syz1.bin
		even
ObjPos_SYZ2:	incbin	level/objpos/syz2.bin
		even
ObjPos_FZ:	incbin	level/objpos/fz.bin
		even
ObjPos_End:	incbin	level/objpos/ending.bin
		even
ObjPos_Null:	dc.b $FF, $FF, 0, 0, 0,	0
; ===========================================================================
; Sound driver
; ===========================================================================
		include "sound/driver.asm"
; ===========================================================================
; ---------------------------------------------------------------------------
; Music	Pointers
; ---------------------------------------------------------------------------
MusicIndex:	dc.l Music81, Music82
		dc.l Music83, Music84
		dc.l Music85, Music86
		dc.l Music87, Music88
		dc.l Music89, Music8A
		dc.l Music8B, Music8C
		dc.l Music8D, Music8E
		dc.l Music8F, Music90
		dc.l Music91, Music92
		dc.l Music93, Music94
		dc.l Music95, Music96
		dc.l Music97
; ===========================================================================
Music81:	incbin	"sound\Music\Mind In The Gutter I.bin"
		even
Music82:	incbin	"sound\Music\I Died On Jeopardy.bin"
		even
Music83:	incbin	"sound\Music\Tutorial With Attitude.bin"
		even
Music84:	incbin	"sound\Music\Welcome to the Alleyway.bin"
		even
Music85:	incbin	"sound\Music\I'm An Edgy Motherfucker.bin"
		even
Music86:	incbin	"sound\Music\Get That Elephant.bin"
		even
Music87:	incbin	"sound\Music\Jeopardyinv.bin"
		even
Music88:	incbin	"sound\Music\Yundong 1UP.bin"
		even
Music89:	incbin	"sound\Music\Aurora Numerique.bin"
		even
Music8A:	incbin	"sound\Music\Jeopardy.bin"
		even
Music8B:	incbin	"sound\Music\Grand Finale.bin"
		even
Music8C:	incbin	"sound\Music\music8C.bin"
		even
Music8D:	incbin	"sound\Music\Crank The Dial To 11.bin"
		even
Music8E:	incbin	"sound\Music\Lover Went Right.bin"
		even
Music8F:	incbin	"sound\Music\music8F.bin"
		even
Music90:	incbin	"sound\Music\Life Or Death.bin"
		even
Music91:	incbin	"sound\Music\Flicky Redux Title.bin"
		even
Music92:	incbin	"sound\Music\I Cannot Breathe.bin"
		even
Music93:	incbin	"sound\Music\music93.bin"
		even
Music94:	incbin	"sound\Music\owarisoft logo.bin"
		even
Music95:	incbin	"sound\Music\Spoony's Hangover.bin"
		even
Music96:	incbin	"sound\Music\Joe The Ho.bin"
		even
Music97:	incbin	"sound\Music\Mind In The Gutter II.bin"
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Sound	effect pointers
; ---------------------------------------------------------------------------
SoundIndex:	
		dc.l SoundA0, SoundA1, SoundA2
		dc.l SoundA3, SoundA4, SoundA5
		dc.l SoundA6, SoundA7, SoundA8
		dc.l SoundA9, SoundAA, SoundAB
		dc.l SoundAC, SoundAD, SoundAE
		dc.l SoundAF, SoundB0, SoundB1
		dc.l SoundB2, SoundB3, SoundB4
		dc.l SoundB5, SoundB6, SoundB7
		dc.l SoundB8, SoundB9, SoundBA
		dc.l SoundBB, SoundBC, SoundBD
		dc.l SoundBE, SoundBF, SoundC0
		dc.l SoundC1, SoundC2, SoundC3
		dc.l SoundC4, SoundC5, SoundC6
		dc.l SoundC7, SoundC8, SoundC9
		dc.l SoundCA, SoundCB, SoundCC
		dc.l SoundCD, SoundCE, SoundCF
SpecSoundIndex:
		dc.l SoundD0
; ===========================================================================
SoundA0:	incbin	"sound\SFX\soundA0.bin"
		even
SoundA1:	incbin	"sound\SFX\soundA1.bin"
		even
SoundA2:	incbin	"sound\SFX\soundA2.bin"
		even
SoundA3:	incbin	"sound\SFX\soundA3.bin"
		even
SoundA4:	incbin	"sound\SFX\soundA4.bin"
		even
SoundA5:	incbin	"sound\SFX\soundA5.bin"
		even
SoundA6:	incbin	"sound\SFX\soundA6.bin"
		even
SoundA7:	incbin	"sound\SFX\soundA7.bin"
		even
SoundA8:	incbin	"sound\SFX\soundA8.bin"
		even
SoundA9:	incbin	"sound\SFX\soundA9.bin"
		even
SoundAA:	incbin	"sound\SFX\soundAA.bin"
		even
SoundAB:	incbin	"sound\SFX\soundAB.bin"
		even
SoundAC:	incbin	"sound\SFX\soundAC.bin"
		even
SoundAD:	incbin	"sound\SFX\soundAD.bin"
		even
SoundAE:	incbin	"sound\SFX\soundAE.bin"
		even
SoundAF:	incbin	"sound\SFX\soundAF.bin"
		even
SoundB0:	incbin	"sound\SFX\soundB0.bin"
		even
SoundB1:	incbin	"sound\SFX\soundB1.bin"
		even
SoundB2:	incbin	"sound\SFX\soundB2.bin"
		even
SoundB3:	incbin	"sound\SFX\soundB3.bin"
		even
SoundB4:	incbin	"sound\SFX\soundB4.bin"
		even
SoundB5:	incbin	"sound\SFX\soundB5.bin"
		even
SoundB6:	incbin	"sound\SFX\soundB6.bin"
		even
SoundB7:	incbin	"sound\SFX\soundB7.bin"
		even
SoundB8:	incbin	"sound\SFX\soundB8.bin"
		even
SoundB9:	incbin	"sound\SFX\soundB9.bin"
		even
SoundBA:	incbin	"sound\SFX\soundBA.bin"
		even
SoundBB:	incbin	"sound\SFX\soundBB.bin"
		even
SoundBC:	incbin	"sound\SFX\soundBC.bin"
		even
SoundBD:	incbin	"sound\SFX\soundBD.bin"
		even
SoundBE:	incbin	"sound\SFX\soundBE.bin"
		even
SoundBF:	incbin	"sound\SFX\soundBF.bin"
		even
SoundC0:	incbin	"sound\SFX\soundC0.bin"
		even
SoundC1:	incbin	"sound\SFX\soundC1.bin"
		even
SoundC2:	incbin	"sound\SFX\soundC2.bin"
		even
SoundC3:	incbin	"sound\SFX\soundC3.bin"
		even
SoundC4:	incbin	"sound\SFX\soundC4.bin"
		even
SoundC5:	incbin	"sound\SFX\soundC5.bin"
		even
SoundC6:	incbin	"sound\SFX\soundC6.bin"
		even
SoundC7:	incbin	"sound\SFX\soundC7.bin"
		even
SoundC8:	incbin	"sound\SFX\soundC8.bin"
		even
SoundC9:	incbin	"sound\SFX\soundC9.bin"
		even
SoundCA:	incbin	"sound\SFX\soundCA.bin"
		even
SoundCB:	incbin	"sound\SFX\soundCB.bin"
		even
SoundCC:	incbin	"sound\SFX\soundCC.bin"
		even
SoundCD:	incbin	"sound\SFX\soundCD.bin"
		even
SoundCE:	incbin	"sound\SFX\soundCE.bin"
		even
SoundCF:	incbin	"sound\SFX\soundCF.bin"
		even
SoundD0:	incbin	"sound\SFX\soundD0.bin"
		even
SoundD1:	incbin	"sound\SFX\soundD1.bin"
		even
SoundD2:	incbin	"sound\SFX\Gen_Jump.bin"
		even
SoundD3:	incbin	"sound\SFX\PeeloutCharge.bin"
		even
SoundD4:	incbin	"sound\SFX\PeeloutStop.bin"
		even
SoundD5:	incbin	"sound\SFX\S3K_Shoot.bin"
		even
SoundD6:	incbin	"sound\SFX\Peelout_Release.bin"
		even
; ===========================================================================
	include "screens/#Owarisoft/main.asm"
;	inform 0,""
; ===========================================================================
Art_Dust:
		incbin	"art/uncompressed/spindust.bin"
		incbin	"art/uncompressed/Skid smoke.bin"
		even
; ===========================================================================
ArtUnc_Countdown:
		incbin	"art/uncompressed/Numbers for drowning countdown.bin"
		even
; ===========================================================================
Nem_TitleCard_Tutorial:		incbin "art/nemesis/Title Cards/Tutorial.bin"
		even
Nem_TitleCard_FuckedUp:		incbin "art/nemesis/Title Cards/OhShitSonYouFuckedUpNow.bin"
		even
Nem_TitleCard_Dzien:		incbin "art/nemesis/Title Cards/DzienDobry.bin"
		even
Nem_TitleCard_Appendicitis:	incbin "art/nemesis/Title Cards/IThinkIHaveAppendicitis.bin"
		even
Nem_TitleCard_Teeth:		incbin "art/nemesis/Title Cards/MyTeethFeelFunny.bin"
		even
Nem_TitleCard_Final:		incbin "art/nemesis/Title Cards/Final.bin"
		even
Nem_LoverWentRight:		incbin "art/nemesis/Title Cards/LoverWentRight.bin"
		even
; ===========================================================================
Nem_TitleBG:
		incbin "art/nemesis/titlebg.bin"
		even

Map_TitleBG:
		incbin "mappings/plane/uncompressed/title.bin"
		even
; ---------------------------------------------------------------------------
; Sprite mappings - Sonic
; ---------------------------------------------------------------------------
Map_Sonic:
	include "mappings/sprite/Sonic.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics	loading	array for Sonic
; ---------------------------------------------------------------------------
SonicDynPLC:
	include "mappings/DPLC/Sonic.asm"

; ---------------------------------------------------------------------------
; Uncompressed graphics	- Sonic
; ---------------------------------------------------------------------------
Art_Sonic:	incbin	art/uncompressed/sonic.bin	; Sonic
		even
; ===========================================================================
		include "screens/soundtest/code.asm"
		include "screens/flicky/code.asm"
; ===========================================================================
; MUST BE AT THE END OF THE ROM
; ===========================================================================
; ---------------------------------------------------------------
; Error handling module
; ---------------------------------------------------------------

BusError:   jsr ErrorHandler(pc)
        dc.b    "BUS ERROR",0           ; text
        dc.b    1               ; extended stack frame
        even

AddressError:   jsr ErrorHandler(pc)
        dc.b    "ADDRESS ERROR",0       ; text
        dc.b    1               ; extended stack frame
        even

IllegalInstr:   jsr ErrorHandler(pc)
        dc.b    "ILLEGAL INSTRUCTION",0     ; text
        dc.b    0               ; extended stack frame
        even

ZeroDivide: jsr ErrorHandler(pc)
        dc.b    "ZERO DIVIDE",0         ; text
        dc.b    0               ; extended stack frame
        even

ChkInstr:   jsr ErrorHandler(pc)
        dc.b    "CHK INSTRUCTION",0         ; text
        dc.b    0               ; extended stack frame
        even

TrapvInstr: jsr ErrorHandler(pc)
        dc.b    "TRAPV INSTRUCTION",0       ; text
        dc.b    0               ; extended stack frame
        even

PrivilegeViol:  jsr ErrorHandler(pc)
        dc.b    "PRIVILEGE VIOLATION",0     ; text
        dc.b    0               ; extended stack frame
        even

Trace:      jsr ErrorHandler(pc)
        dc.b    "TRACE",0           ; text
        dc.b    0               ; extended stack frame
        even

Line1010Emu:    jsr ErrorHandler(pc)
        dc.b    "LINE 1010 EMULATOR",0      ; text
        dc.b    0               ; extended stack frame
        even

Line1111Emu:    jsr ErrorHandler(pc)
        dc.b    "LINE 1111 EMULATOR",0      ; text
        dc.b    0               ; extended stack frame
        even

ErrorExcept:    jsr ErrorHandler(pc)
        dc.b    "ERROR EXCEPTION",0         ; text
        dc.b    0               ; extended stack frame
        even

ErrorHandler:   incbin  "data/error/ErrorHandler.bin"
		even
; ===========================================================================
EndOfRom:
		END
; ===========================================================================
