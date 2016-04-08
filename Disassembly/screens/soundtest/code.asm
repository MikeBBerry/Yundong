; ===========================================================================
; Sound test screen
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
		;lea	(Eni_SegaLogo).l,a0
		;move.w	#0,d0
		;jsr	EniDec
		
		;lea	($FF0000).l,a1
		;move.l	#$40000003,d0
		;moveq	#$27,d1
		;moveq	#$1B,d2
		;jsr	ShowVDPGraphics
		
		bsr.w	DrawSndTestText
		
		moveq	#$15,d0
		jsr	PalLoad1
		
		move.l	#0,($FFFFFFB0).w
		
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		
		jsr	DrawSndTestText
		
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
		add.w	d0,d0
		move.w	d0,d2
		add.w	d0,d0
		movea.l	SndTest_Addresses(pc,d0.w),a0

		btst	#2,($FFFFF605).w
		beq.s	@NotLeft
		subq.b	#1,(a0)
		bmi.s	@Neg
		bra.s	@NotLeft
		
@Neg:
		move.w	SndTest_Maxes(pc,d2.w),d1
		move.b	d1,(a0)
		
@NotLeft:
		btst	#3,($FFFFF605).w
		beq.s	@NotRight
		addq.b	#1,(a0)
		move.w	SndTest_Maxes(pc,d2.w),d0
		move.b	(a0),d1
		cmp.b	d0,d1
		ble.s	@NotRight
		move.b	#0,(a0)

@NotRight:
		btst	#6,($FFFFF605).w
		beq.s	@NotA
		moveq	#0,d0
		move.w	d2,d0
		add.w	d0,d0
		movea.l	SndTest_Addresses(pc,d0.w),a0
		movea.l	SndTest_Subroutines(pc,d0.w),a1
		moveq	#0,d0
		move.b	(a0),d0
		add.w	SndTest_Add(pc,d2.w),d0
		jsr	(a1)
		
@NotA:
		btst	#4,($FFFFF605).w
		beq.s	@NotB
		jmp	StartLvlSelect
		
@NotB:
		jsr	DrawSndTestText
		bra.w	SndTest_MainLoop
; ===========================================================================
SndTest_Addresses:
		dc.l $FFFFFFB1
		dc.l $FFFFFFB2
		dc.l $FFFFFFB3
; ===========================================================================
SndTest_Maxes:
		dc.w $16
		dc.w $2F
		dc.w $16
; ===========================================================================
SndTest_Add:
		dc.w $81, $A0, $81
; ===========================================================================
SndTest_Subroutines:
		dc.l PlaySound
		dc.l PlaySound_Special
		dc.l PlaySample
; ===========================================================================
SndTest_Text:
		dc.l Txt_Music
		dc.l $40200003
		dc.l Txt_SFX
		dc.l $41A20003
		dc.l Txt_PCM
		dc.l $43220003
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
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.s	DrawHexNumber
		move.b	d2,d0
		bsr.s	DrawHexNumber

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
; ===========================================================================
Nem_SndTestFont:
		incbin "art/nemesis/font.bin"
		even
; ===========================================================================
Pal_SndTest:
		incbin "palette/sndtest.bin"
		even
; ===========================================================================
