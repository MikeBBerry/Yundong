; ===========================================================================
; Sound test screen
; ===========================================================================
SndTest_Settings:
		dc.l $FFFFFFB1			; RAM address for sound ID (0)
		dc.w $17				; Maximum ID (4)
		dc.w $80				; ID modifier (is added to ID) (6)
		dc.l PlaySound			; Subroutine for the value to be processed through (8)
		dc.l Txt_Music			; Sound type text address ($C)
		dc.l $411A0003			; VDP value to draw the text and ID number ($10)
		dc.b 1					; "Stop" flag (if 1, then it allows for an option to stop) ($14)
		dc.b 0					; Sound type (0 = Music, 1 = SFX, 2 = PCM)
; ===========================================================================
ram_addr			= 0
max_id				= 4
id_mod				= 6
subroutine			= 8
snd_text_addr		= $C
text_vdp_addr		= $10
stop_flag			= $14
snd_type			= $15
snd_setting_size	= $16
; ===========================================================================
SoundTest:
		move.b	#$E4,d0
		jsr	PlaySound_Special

		jsr	ClearPLC
		jsr	Pal_FadeFrom

		move	#$2700,sr

		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

		jsr	ClearScreen
		
		move.l	#$46600000,($C00004).l
		lea	(Nem_SndTestFont).l,a0
		jsr	NemDec
		
		;lea	($FF0000).l,a1
		;move.l	#$40000003,d0
		;moveq	#$27,d1
		;moveq	#$1B,d2
		;jsr	ShowVDPGraphics
		
		moveq	#$15,d0
		jsr	PalLoad1
		
		move.l	#0,($FFFFFFB0).w
		move.b	#1,($FFFFFFB4).w				; If this flag is set, then when the music stop ID is played, then the PCM 

		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		
		jsr	Pal_FadeTo

SndTest_MainLoop:
		move.b	#2,($FFFFF62A).w
		jsr	DelayProgram

		btst	#0,($FFFFF605).w
		beq.s	@NotUp
		tst.b	($FFFFFFB0).w
		beq.s	@NotUp
		subq.b	#1,($FFFFFFB0).w
		
@NotUp:
		btst	#1,($FFFFF605).w
		beq.s	@NotDown
		cmpi.b	#2,($FFFFFFB0).w
		beq.s	@NotDown
		addq.b	#1,($FFFFFFB0).w
		
@NotDown:
		moveq	#0,d0
		move.b	($FFFFFFB0).w,d0
		mulu.w	#snd_setting_size,d0
		lea	(SndTest_Addresses).l,a0
		movea.l	(a0,d0.w),a0					; a0 = Address for settings
		movea.l	ram_addr(a0),a1					; a1 = RAM address for sound ID

		btst	#2,($FFFFF605).w
		beq.s	@NotLeft

		move.b	#0,d0
		tst.b	stop_flag(a0)
		beq.s	@NoStopFlag
		move.b	#$FF,d0

@NoStopFlag:
		subq.b	#1,(a1)
		move.b	(a1),d1
		cmp.b	d1,d0
		bmi.s	@NotMin
		move.b	max_id(a0),(a1)
		
@NotMin:
@NotLeft:
		btst	#3,($FFFFF605).w
		beq.s	@NotRight
		addq.b	#1,(a1)
		move.b	max_id(a0),d0
		move.b	(a1),d1
		cmp.b	d0,d1
		beq.s	@NotMax
		move.b	#0,d0
		tst.b	stop_flag(a0)
		beq.s	@NoStopFlag2
		move.b	#$FF,d0

@NoStopFlag2:
		move.b	d0,(a1)

@NotMax:
@NotRight:
		btst	#6,($FFFFF605).w
		beq.w	@NotA

		move.b	(a1),d0

		tst.b	stop_flag(a0)
		beq.s	@NoStopFlag3

		cmpi.b	#$FF,d0
		bne.s	@NoStopFlag3

		cmpi.b	#2,snd_type(a0)
		bne.s	@NotDAC

		stopZ80
		move.b	#$80,($A01FFF).l
		startZ80
		nop
		nop
		nop
		bra.s	@Continue

@NotDAC:
		move.b	#$E4,d0
		jsr	PlaySound_Special

		bra.s	@Continue

@NoStopFlag3:
		cmpi.b	#2,snd_type(a0)
		beq.s	@IsDAC

		tst.b	snd_type(a0)
		bne.s	@Play

		stopZ80									; Before playing music, stop PCM
		move.b	#$80,($A01FFF).l
		startZ80
		nop
		nop
		nop

		bra.s	@Play

@IsDAC:
		move.b	#$E4,d0							; Before playing PCM, stop music
		jsr	PlaySound_Special
		
@Play:
		moveq	#0,d0
		move.b	(a1),d0
		add.w	id_mod(a0),d0

		jsr	subroutine(a0)
	
@Continue:	
@NotA:
		btst	#4,($FFFFF605).w
		beq.s	@NotB
		jmp	StartLvlSelect
		
@NotB:
		jsr	DrawSndTestText
		bra.w	SndTest_MainLoop
; ===========================================================================
DrawSndTestText:
		moveq	#2,d5
		
@Draw:
		moveq	#0,d6
		move.b	#2,d6
		move.b	($FFFFFFB0).w,d7
		sub.b	d5,d6
		
		move.w	#$2000,d1
		cmp.b	d6,d7
		bne.s	@NotHighlight
		move.w	#$4000,d1
		
@NotHighlight:
		move.w	d6,d7
		add.w	d6,d6
		add.w	d6,d6
		add.w	d6,d6
		movea.l	SndTest_Text(pc,d6.w),a0
		addq.w	#4,d6
		move.l	SndTest_Text(pc,d6.w),($C00004).l
		bsr.s	DrawText
		move.w	d7,d6
		add.w	d6,d6
		add.w	d6,d6
		movea.l	SndTest_Addresses(pc,d6.w),a0
		move.b	(a0),d0
		cmpa.w	#$FFB2,a0
		beq.s	@Number
		tst.b	d0
		bne.s	@Number
		lea	(Txt_Stop).l,a0
		bsr.w	DrawText
		bra.s	@Loop

@Number:
		cmpa.w	#$FFB2,a0
		beq.s	@SFX
		subq.b	#1,d0

@SFX:
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.s	DrawHexNumber
		move.b	d2,d0
		bsr.s	DrawHexNumber
		move.l	#0,($C00000).l

@Loop:
		dbf	d5,@Draw
		rts
; ===========================================================================
DrawText:
		moveq	#0,d0
		move.b	(a0)+,d0
		cmpi.b	#$20,d0
		beq.s	@DrawSpace
		tst.b	d0
		beq.s	@End
		
@Draw:
		ext.w	d0
		or.w	d1,d0
		move.w	d0,($C00000).l
		bra.s	DrawText
		
@DrawSpace:
		moveq	#0,d0
		bra.s	@Draw
		
@End:
		rts
; ===========================================================================
DrawHexNumber:
		andi.w	#$F,d0
		cmpi.w	#$A,d0
		bcs.s	@NotAtoF
		addi.w	#4,d0

@NotAtoF:
		addi.w	#$33,d0
		or.w	d1,d0
		move.w	d0,($C00000).l
		rts
; ===========================================================================
Txt_Music:
		dc.b "MUSIC? ",0
		even
		
Txt_SFX:
		dc.b "SFX? ",0
		even

Txt_PCM:
		dc.b "PCM? ",0
		even

Txt_Stop:
		dc.b "STOP",0
		even
; ===========================================================================
Nem_SndTestFont:
		incbin "art/nemesis/font.bin"
		even
; ===========================================================================
Pal_SndTest:
		incbin "palette/sndtest.bin"
		even
; ===========================================================================
