; ---------------------------------------------------------------------------
Go_SoundPriorities:	dc.l SoundPriorities
Go_SpecSoundIndex:	dc.l SpecSoundIndex
Go_MusicIndex:		dc.l MusicIndex
Go_SoundIndex:		dc.l SoundIndex
Go_SpeedUpIndex:	dc.l SpeedUpIndex
Go_PSGIndex:		dc.l PSG_Index
; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------
PSG_Index:
		dc.l PSG1, PSG2, PSG3
		dc.l PSG4, PSG5, PSG6
		dc.l PSG7, PSG8, PSG9
		dc.l PSGA, PSGB, PSGC
		dc.l PSGD, PSGE, PSGF
		dc.l PSG10, PSG11, PSG12
		dc.l PSG13, PSG14, PSG15
		dc.l PSG16, PSG17, PSG18
		dc.l PSG19, PSG1A, PSG1B
		dc.l PSG1C, PSG1D, PSG1E
		dc.l PSG1F, PSG20, PSG21
		dc.l PSG22, PSG23, PSG24
		dc.l PSG25, PSG26, PSG27
		dc.l PSG28, PSG29, PSG2A
		dc.l PSG2B, PSG2C, PSG2D
		dc.l PSG2E
PSG1:		incbin	"sound\PSG\S1 and S2\PSG 1.bin"
PSG2:		incbin	"sound\PSG\S1 and S2\PSG 2.bin"
PSG3:		incbin	"sound\PSG\S1 and S2\PSG 3.bin"
PSG4:		incbin	"sound\PSG\S1 and S2\PSG 4.bin"
PSG5:		incbin	"sound\PSG\S1 and S2\PSG 5.bin"
PSG6:		incbin	"sound\PSG\S1 and S2\PSG 6.bin"
PSG7:		incbin	"sound\PSG\S1 and S2\PSG 7.bin"
PSG8:		incbin	"sound\PSG\S1 and S2\PSG 8.bin"
PSG9:		incbin	"sound\PSG\S1 and S2\PSG 9.bin"
PSGA:		incbin	"sound\PSG\S1 and S2\PSG A (S2).bin"
PSGB:		incbin	"sound\PSG\S1 and S2\PSG B (S2).bin"
PSGC:		incbin	"sound\PSG\S1 and S2\PSG C (S2).bin"
PSGD:		incbin	"sound\PSG\S1 and S2\PSG D (S2).bin"
PSGE:		incbin	"sound\PSG\S3K\PSG 1.bin"
PSGF:		incbin	"sound\PSG\S3K\PSG 2.bin"
PSG10:		incbin	"sound\PSG\S3K\PSG 3.bin"
PSG11:		incbin	"sound\PSG\S3K\PSG 4 (S3, SK).bin"
PSG12:		incbin	"sound\PSG\S3K\PSG 4 (S3D).bin"
PSG13:		incbin	"sound\PSG\S3K\PSG 5.bin"
PSG14:		incbin	"sound\PSG\S3K\PSG 6.bin"
PSG15:		incbin	"sound\PSG\S3K\PSG 7.bin"
PSG16:		incbin	"sound\PSG\S3K\PSG 8.bin"
PSG17:		incbin	"sound\PSG\S3K\PSG 9.bin"
PSG18:		incbin	"sound\PSG\S3K\PSG A.bin"
PSG19:		incbin	"sound\PSG\S3K\PSG B.bin"
PSG1A:		incbin	"sound\PSG\S3K\PSG C.bin"
PSG1B:		incbin	"sound\PSG\S3K\PSG D.bin"
PSG1C:		incbin	"sound\PSG\S3K\PSG 10.bin"
PSG1D:		incbin	"sound\PSG\S3K\PSG 11.bin"
PSG1E:		incbin	"sound\PSG\S3K\PSG 14.bin"
PSG1F:		incbin	"sound\PSG\S3K\PSG 18.bin"
PSG20:		incbin	"sound\PSG\S3K\PSG 1A.bin"
PSG21:		incbin	"sound\PSG\S3K\PSG 1C.bin"
PSG22:		incbin	"sound\PSG\S3K\PSG 1D.bin"
PSG23:		incbin	"sound\PSG\S3K\PSG 1E.bin"
PSG24:		incbin	"sound\PSG\S3K\PSG 1F.bin"
PSG25:		incbin	"sound\PSG\S3K\PSG 20.bin"
PSG26:		incbin	"sound\PSG\S3K\PSG 21.bin"
PSG27:		incbin	"sound\PSG\S3K\PSG 22.bin"
PSG28:		incbin	"sound\PSG\S3K\PSG 23.bin"
PSG29:		incbin	"sound\PSG\S3K\PSG 24.bin"
PSG2A:		incbin	"sound\PSG\S3K\PSG 25.bin"
PSG2B:		incbin	"sound\PSG\S3K\PSG 26 (S3).bin"
PSG2C:		incbin	"sound\PSG\S3K\PSG 26 (SK, S3D).bin"
PSG2D:		incbin	"sound\PSG\S3K\PSG 27.bin"
PSG2E:		incbin	"sound\PSG\S3K\PSG 28 (S3D).bin"
; ---------------------------------------------------------------------------
SpeedUpIndex:
		dc.b 7			; 1
		dc.b $72		; 2
		dc.b $73		; 3
		dc.b $26		; 4
		dc.b $15		; 5
		dc.b 8			; 6
		dc.b $FF		; 7
		dc.b 5			; 8
		dc.b $FF		; 9
		dc.b $FF		; A
		dc.b $FF		; B
		dc.b $FF		; C
		dc.b $FF		; D
		dc.b $FF		; E
		dc.b $FF		; F
		dc.b $FF		; 10
		dc.b $FF		; 11
		dc.b $FF		; 12
		dc.b $FF		; 13
		dc.b $FF		; 14
		dc.b $FF		; 15
		dc.b $FF		; 16
		dc.b 7			; 17
; ---------------------------------------------------------------------------
; Type of sound	being played ($90 = music; $70 = normal	sound effect)
; ---------------------------------------------------------------------------
SoundPriorities:
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $10
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $20
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $30
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $40
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $50
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $60
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $70
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $80
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $90
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$80 ; $A0
		dc.b $70, $70, $70, $70, $70, $70, $70,	$70, $70, $68, $70, $70, $70, $60, $70,	$70 ; $B0
		dc.b $60, $70, $60, $70, $70, $70, $70,	$70, $70, $70, $70, $70, $70, $70, $7F,	$60 ; $C0
		dc.b $70, $70, $70, $70, $70, $70, $70,	$70, $70, $70, $70, $70, $70, $70, $70,	$80 ; $D0
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $E0
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $90, $90, $90, $90,	$90 ; $F0
		dc.b $90, $90, $90, $90, $90, $90, $90,	$90, $90, $90, $90, $80, $80, $80, $80      ; $FF
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


UpdateMusic:				; XREF: loc_B10; PalToCRAM
		cmpi.b	#$10,($FFFFF600).w
		bne.s	@NotSS
		rts
		
@NotSS:
		lea	($FFF000).l,a6
		clr.b	$E(a6)
		tst.b	3(a6)		; is music paused?
		bne.w	PauseMusic	; if yes, branch
		subq.b	#1,1(a6)
		bne.s	@SkipDelay
		jsr	TempoWait(pc)

@SkipDelay:
		move.b	4(a6),d0
		beq.s	@SkipFadeOut
		jsr	DoFadeOut(pc)

@SkipFadeOut:
		tst.b	$24(a6)
		beq.s	@SkipFadeIn
		jsr	DoFadeIn(pc)

@SkipFadeIn:
		tst.w	$A(a6)		; is music or sound being played?
		beq.s	@NoSndInput	; if not, branch
		jsr	Sound_Play(pc)

@NoSndInput:
		tst.b	9(a6)
		beq.s	@NoNewSound
		jsr	Sound_ChkValue(pc)

@NoNewSound:
		lea	$40(a6),a5
		tst.b	(a5)
		bpl.s	@DACDone
		jsr	UpdateDAC(pc)

@DACDone:
		clr.b	8(a6)
		moveq	#5,d7

@BGMFMLoop:
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	@BGMFMNext
		jsr	FMUpdateTrack(pc)

@BGMFMNext:
		dbf	d7,@BGMFMLoop

		moveq	#2,d7

@BGMPSGLoop:
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	@BGMPSGNext
		jsr	PSGUpdateTrack(pc)

@BGMPSGNext:
		dbf	d7,@BGMPSGLoop

		move.b	#$80,$E(a6)
		moveq	#2,d7

@SFXFMLoop:
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	@SFXFMNext
		jsr	FMUpdateTrack(pc)

@SFXFMNext:
		dbf	d7,@SFXFMLoop

		moveq	#2,d7

@SFXPSGLoop:
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	@SFXPSGNext
		jsr	PSGUpdateTrack(pc)

@SFXPSGNext:
		dbf	d7,@SFXPSGLoop
		
		move.b	#$40,$E(a6)
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	@SpecFMDone
		jsr	FMUpdateTrack(pc)

@SpecFMDone:
		adda.w	#$30,a5
		tst.b	(a5)
		bpl.s	CheckSoundPAL
		jsr	PSGUpdateTrack(pc)

CheckSoundPAL:
		btst	#6,($FFFFFFF8).w	   	; is Megadrive PAL?
		beq.s	@End		 			; if not, branch
		subq.b	#1,($FFFFFFBF).w		; decrement timer
		bpl.s	@End					; if it's not 0, return
		move.b  #5,($FFFFFFBF).w	   	; reset counter
		bra.w	UpdateMusic		  		; run sound driver again
		
@End:
		rts
; End of function UpdateMusic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


UpdateDAC:				; XREF: UpdateMusic
		subq.b	#1,$E(a5)
		bne.s	locret_71CAA
		move.b	#$80,8(a6)
		movea.l	4(a5),a4

loc_71C5E:
		moveq	#0,d5
		move.b	(a4)+,d5
		cmpi.b	#-$20,d5
		bcs.s	loc_71C6E
		jsr	CoordFlag(pc)
		bra.s	loc_71C5E
; ===========================================================================

loc_71C6E:
		tst.b	d5
		bpl.s	loc_71C84
		move.b	d5,$10(a5)
		move.b	(a4)+,d5
		bpl.s	loc_71C84
		subq.w	#1,a4
		move.b	$F(a5),$E(a5)
		bra.s	loc_71C88
; ===========================================================================

loc_71C84:
		jsr	SetDuration(pc)

loc_71C88:
		move.l	a4,4(a5)
		btst	#2,(a5)
		bne.s	locret_71CAA
		moveq	#0,d0
		move.b	$10(a5),d0
		cmpi.b	#$80,d0
		beq.s	locret_71CAA
		stopZ80
		move.b    d0,($A01FFF).l
		startZ80

locret_71CAA:
		rts	
; ===========================================================================

loc_71CAC:
		subi.b	#$88,d0
		move.b	DAC_SampleRates(pc,d0.w),d0
		move.b	d0,($A000EA).l
		move.b	#$83,($A01FFF).l
		rts	
; End of function UpdateDAC

; ===========================================================================
DAC_SampleRates:	dc.b $12, $15, $1C, $1D, $FF, $FF

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMUpdateTrack:				; XREF: UpdateMusic
		subq.b	#1,$E(a5)
		bne.s	loc_71CE0
		bclr	#4,(a5)
		jsr	FMDoNext(pc)
		jsr	FMPrepareNote(pc)
		bra.w	FMNoteOn
; ===========================================================================

loc_71CE0:
		jsr	NoteFillUpdate(pc)
		jsr	DoModulation(pc)
		bra.w	FMUpdateFreq
; End of function FMUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMDoNext:				; XREF: FMUpdateTrack
		movea.l	4(a5),a4
		bclr	#1,(a5)

loc_71CF4:
		moveq	#0,d5
		move.b	(a4)+,d5
		cmpi.b	#-$20,d5
		bcs.s	loc_71D04
		jsr	CoordFlag(pc)
		bra.s	loc_71CF4
; ===========================================================================

loc_71D04:
		jsr	FMNoteOff(pc)
		tst.b	d5
		bpl.s	loc_71D1A
		jsr	FMSetFreq(pc)
		move.b	(a4)+,d5
		bpl.s	loc_71D1A
		subq.w	#1,a4
		bra.w	FinishTrackUpdate
; ===========================================================================

loc_71D1A:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function FMDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMSetFreq:				; XREF: FMDoNext
		subi.b	#$80,d5
		beq.s	TrackSetRest
		add.b	8(a5),d5
		andi.w	#$7F,d5
		lsl.w	#1,d5
		lea	FM_Notes(pc),a0
		move.w	(a0,d5.w),d6
		move.w	d6,$10(a5)
		rts	
; End of function FMSetFreq


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetDuration:				; XREF: UpdateDAC; FMDoNext; PSGDoNext
		move.b	d5,d0
		move.b	2(a5),d1

loc_71D46:
		subq.b	#1,d1
		beq.s	loc_71D4E
		add.b	d5,d0
		bra.s	loc_71D46
; ===========================================================================

loc_71D4E:
		move.b	d0,$F(a5)
		move.b	d0,$E(a5)
		rts	
; End of function SetDuration

; ===========================================================================

TrackSetRest:				; XREF: FMSetFreq
		bset	#1,(a5)
		clr.w	$10(a5)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FinishTrackUpdate:				; XREF: FMDoNext; PSGDoNext; PSGSetFreq
		move.l	a4,4(a5)
		move.b	$F(a5),$E(a5)
		btst	#4,(a5)
		bne.s	locret_71D9C
		move.b	$13(a5),$12(a5)
		clr.b	$C(a5)
		btst	#3,(a5)
		beq.s	locret_71D9C
		movea.l	$14(a5),a0
		move.b	(a0)+,$18(a5)
		move.b	(a0)+,$19(a5)
		move.b	(a0)+,$1A(a5)
		move.b	(a0)+,d0
		lsr.b	#1,d0
		move.b	d0,$1B(a5)
		clr.w	$1C(a5)

locret_71D9C:
		rts	
; End of function FinishTrackUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


NoteFillUpdate:				; XREF: FMUpdateTrack; PSGUpdateTrack
		tst.b	$12(a5)
		beq.s	locret_71DC4
		subq.b	#1,$12(a5)
		bne.s	locret_71DC4
		bset	#1,(a5)
		tst.b	1(a5)
		bmi.w	loc_71DBE
		jsr	FMNoteOff(pc)
		addq.w	#4,sp
		rts	
; ===========================================================================

loc_71DBE:
		jsr	PSGNoteOff(pc)
		addq.w	#4,sp

locret_71DC4:
		rts	
; End of function NoteFillUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoModulation:				; XREF: FMUpdateTrack; PSGUpdateTrack
		addq.w	#4,sp
		btst	#1,(a5)
		bne.s	locret_71E16
		btst	#3,(a5)
		beq.s	locret_71E16
		tst.b	$18(a5)
		beq.s	loc_71DDA
		subq.b	#1,$18(a5)
		rts	
; ===========================================================================

loc_71DDA:
		subq.b	#1,$19(a5)
		beq.s	loc_71DE2
		rts	
; ===========================================================================

loc_71DE2:
		movea.l	$14(a5),a0
		move.b	1(a0),$19(a5)
		tst.b	$1B(a5)
		bne.s	loc_71DFE
		move.b	3(a0),$1B(a5)
		neg.b	$1A(a5)
		rts	
; ===========================================================================

loc_71DFE:
		subq.b	#1,$1B(a5)
		move.b	$1A(a5),d6
		ext.w	d6
		add.w	$1C(a5),d6
		move.w	d6,$1C(a5)
		add.w	$10(a5),d6
		subq.w	#4,sp

locret_71E16:
		rts	
; End of function DoModulation


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMPrepareNote:				; XREF: FMUpdateTrack
		btst	#1,(a5)
		bne.s	locret_71E48
		move.w	$10(a5),d6
		beq.s	FMSetRest

FMUpdateFreq:				; XREF: FMUpdateTrack
		move.b	$1E(a5),d0
		ext.w	d0
		add.w	d0,d6
		btst	#2,(a5)
		bne.s	locret_71E48
		move.w	d6,d1
		lsr.w	#8,d1
		move.b	#-$5C,d0
		jsr	WriteFMIorII(pc)
		move.b	d6,d1
		move.b	#-$60,d0
		jsr	WriteFMIorII(pc)

locret_71E48:
		rts	
; ===========================================================================

FMSetRest:
		bset	#1,(a5)
		rts	
; End of function FMPrepareNote

; ===========================================================================

PauseMusic:				; XREF: UpdateMusic
		bmi.s	loc_71E94
		cmpi.b	#2,3(a6)
		beq.w	loc_71EFE
		move.b	#2,3(a6)
		moveq	#2,d3
		move.b	#-$4C,d0
		moveq	#0,d1

loc_71E6A:
		jsr	WriteFMI(pc)
		jsr	WriteFMII(pc)
		addq.b	#1,d0
		dbf	d3,loc_71E6A

		moveq	#2,d3
		moveq	#$28,d0

loc_71E7C:
		move.b	d3,d1
		jsr	WriteFMI(pc)
		addq.b	#4,d1
		jsr	WriteFMI(pc)
		dbf	d3,loc_71E7C

		jsr	PSGSilenceAll(pc)
		stopZ80
		move.b	#$7F,($A01FFF).l ; pause DAC
		startZ80
		bra.w	CheckSoundPAL
; ===========================================================================

loc_71E94:				; XREF: PauseMusic
		clr.b	3(a6)
		moveq	#$30,d3
		lea	$40(a6),a5
		moveq	#6,d4

loc_71EA0:
		btst	#7,(a5)
		beq.s	loc_71EB8
		btst	#2,(a5)
		bne.s	loc_71EB8
		move.b	#-$4C,d0
		move.b	$A(a5),d1
		jsr	WriteFMIorII(pc)

loc_71EB8:
		adda.w	d3,a5
		dbf	d4,loc_71EA0

		lea	$220(a6),a5
		moveq	#2,d4

loc_71EC4:
		btst	#7,(a5)
		beq.s	loc_71EDC
		btst	#2,(a5)
		bne.s	loc_71EDC
		move.b	#-$4C,d0
		move.b	$A(a5),d1
		jsr	WriteFMIorII(pc)

loc_71EDC:
		adda.w  d3,a5
		dbf     d4,loc_71EC4

		lea     $340(a6),a5
		btst    #7,(a5)
		beq.s   @UnpauseDAC
		btst    #2,(a5)
		bne.s   @UnpauseDAC
		move.b  #-$4C,d0
		move.b  $A(a5),d1
		jsr     WriteFMIorII(pc)
@UnpauseDAC:
		stopZ80
		move.b  #0,($A01FFF).l  ; unpause DAC
		startZ80

loc_71EFE:
		bra.w	CheckSoundPAL

; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sound_Play:				; XREF: UpdateMusic
		movea.l	(Go_SoundPriorities).l,a0
		lea	$A(a6),a1	; load music track number
		move.b	0(a6),d3
		moveq	#2,d4

loc_71F12:
		move.b	(a1),d0		; move track number to d0
		move.b	d0,d1
		clr.b	(a1)+
		tst.b	d0
		beq.s	loc_71F3E
		cmpi.b	#$D1,d0
		bhs.s	@MusicOrFlag
		subi.b	#$A0,d0
		blo.s	@MusicOrFlag
		tst.b	9(a6)
		beq.s	loc_71F2C
		move.b	d1,$A(a6)
		bra.s	loc_71F3E
		
@MusicOrFlag:
		tst.b	9(a6)
		beq.s	loc_71F3A
		move.b	d1,$A(a6)
		bra.s	loc_71F3E
; ===========================================================================

loc_71F2C:
		andi.w	#$FF,d0
		move.b	(a0,d0.w),d2
		cmp.b	d3,d2
		bcs.s	loc_71F3E
		move.b	d2,d3
		
loc_71F3A:
		move.b	d1,9(a6)	; set music flag

loc_71F3E:
		dbf	d4,loc_71F12

		tst.b	d3
		bmi.s	locret_71F4A
		move.b	d3,0(a6)

locret_71F4A:
		rts	
; End of function Sound_Play


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sound_ChkValue:				; XREF: UpdateMusic
		moveq	#0,d7
		move.b	9(a6),d7
		beq.w	StopSoundAndMusic
		move.b	#0,9(a6)	; reset	music flag
		cmpi.b	#$9F,d7
		bls.w	Sound_PlayBGM	; music	$81-$9F
		cmpi.b	#$CF,d7
		bls.w	Sound_PlaySFX	; sound	$A0-$CF
		cmpi.b	#$D0,d7
		bls.w	Sound_PlaySpecial	; sound	$D0
		cmpi.b	#$FB,d7
		bls.w	Sound_PlayBGM	; sound	$D1-$FB
		cmpi.b	#$FF,d7
		bls.s	Sound_E0toE4	; sound	$FC-$FF

locret_71F8C:
		rts	
; ===========================================================================

Sound_E0toE4:				; XREF: Sound_ChkValue
		subi.b	#$FC,d7
		lsl.w	#2,d7
		jmp	Sound_ExIndex(pc,d7.w)
; ===========================================================================

Sound_ExIndex:
		bra.w	FadeOutMusic
; ===========================================================================
		bra.w	SpeedUpMusic
; ===========================================================================
		bra.w	SlowDownMusic
; ===========================================================================
		bra.w	StopSoundAndMusic
; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------

Sound_PlayBGM:				; XREF: Sound_ChkValue
		cmpi.b	#8,d7		; is "extra life" music	played?
		bne.s	loc_72024	; if not, branch
		tst.b	$27(a6)
		bne.w	loc_721B6
		lea	$40(a6),a5
		moveq	#9,d0

loc_71FE6:
		bclr	#2,(a5)
		adda.w	#$30,a5
		dbf	d0,loc_71FE6

		lea	$220(a6),a5
		moveq	#5,d0

loc_71FF8:
		bclr	#7,(a5)
		adda.w	#$30,a5
		dbf	d0,loc_71FF8
		clr.b	0(a6)
		movea.l	a6,a0
		lea	$3A0(a6),a1
		move.w	#$87,d0

loc_72012:
		move.l	(a0)+,(a1)+
		dbf	d0,loc_72012

		move.b	#$80,$27(a6)
		clr.b	0(a6)
		bra.s	loc_7202C
; ===========================================================================

loc_72024:
		clr.b	$27(a6)
		clr.b	$26(a6)

loc_7202C:
		jsr	InitMusicPlayback(pc)
		
		subq.b	#1,d7
		cmpi.b	#$D0,d7
		bcs.s	@Normal
		subi.b	#$B1,d7
		
@Normal:
		
		movea.l	(Go_SpeedUpIndex).l,a4
		move.b	(a4,d7.w),$29(a6)
		movea.l	(Go_MusicIndex).l,a4
		add.w	d7,d7
		add.w	d7,d7
		movea.l	(a4,d7.w),a4
		moveq	#0,d0
		move.w	(a4),d0
		add.l	a4,d0
		move.l	d0,$18(a6)
		move.b	5(a4),d0
		move.b	d0,$28(a6)
		tst.b	$2A(a6)
		beq.s	loc_72068
		move.b	$29(a6),d0

loc_72068:
		move.b	d0,2(a6)
		move.b	d0,1(a6)
		moveq	#0,d1
		movea.l	a4,a3
		addq.w	#6,a4
		move.b	4(a3),d4
		moveq	#$30,d6
		move.b	#1,d5
		moveq	#0,d7
		move.b	2(a3),d7
		beq.w	loc_72114
		subq.b	#1,d7
		move.b	#$C0,d1
		lea	$40(a6),a1
		;lea	FMDACInitBytes(pc),a2

loc_72098:
		move.b	#$82,(a1)
		;move.b	(a2)+,1(a1)
		move.b	d4,2(a1)
		move.b	d6,$D(a1)
		move.b	d1,$A(a1)
		move.b	d5,$E(a1)
		moveq	#0,d0
		move.w	(a4)+,d0
		ext.l	d0
		add.l	a3,d0
		move.l	d0,4(a1)
		move.w	(a4)+,8(a1)
		adda.w	d6,a1
		dbf	d7,loc_72098
		
		cmpi.b	#7,2(a3)
		beq.s	loc_72114

		moveq	#$42,d0
		move.b	#$FF,d1
		moveq	#3,d2
		
@SilenceLoop:
		bsr.w	WriteFMII
		addq.b	#4,d0
		dbf	d2,@SilenceLoop
		
		move.b	#$B6,d0
		move.b	#$C0,d1
		jsr	WriteFMII(pc)

loc_72114:
		moveq	#0,d7
		move.b	3(a3),d7
		beq.s	loc_72154
		subq.b	#1,d7
		lea	$190(a6),a1
		;lea	PSGInitBytes(pc),a2

loc_72126:
		move.b	#$82,(a1)
		;move.b	(a2)+,1(a1)
		move.b	d4,2(a1)
		move.b	d6,$D(a1)
		move.b	d5,$E(a1)
		moveq	#0,d0
		move.w	(a4)+,d0
		ext.l	d0
		add.l	a3,d0
		move.l	d0,4(a1)
		move.w	(a4)+,8(a1)
		addq.w	#1,a4
		move.b	(a4)+,$B(a1)
		adda.w	d6,a1
		dbf	d7,loc_72126

loc_72154:
		lea	$220(a6),a1
		moveq	#5,d7

loc_7215A:
		tst.b	(a1)
		bpl.w	loc_7217C
		moveq	#0,d0
		move.b	1(a1),d0
		bmi.s	loc_7216E
		subq.b	#2,d0
		lsl.b	#2,d0
		bra.s	loc_72170
; ===========================================================================

loc_7216E:
		lsr.b	#3,d0

loc_72170:
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d0.w),a0
		bset	#2,(a0)

loc_7217C:
		adda.w	d6,a1
		dbf	d7,loc_7215A

		tst.w	$340(a6)
		bpl.s	loc_7218E
		bset	#2,$100(a6)

loc_7218E:
		tst.w	$370(a6)
		bpl.s	loc_7219A
		bset	#2,$1F0(a6)

loc_7219A:
		lea	$70(a6),a5
		moveq	#5,d4

loc_721A0:
		jsr	FMNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,loc_721A0
		moveq	#2,d4

loc_721AC:
		jsr	PSGNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,loc_721AC

loc_721B6:
		addq.w	#4,sp
		rts	
; ===========================================================================
ChannelInitBytes:
FMDACInitBytes:
		dc.b 6,	0, 1, 2, 4, 5, 6
PSGInitBytes:
		dc.b $80, $A0, $C0
		even
; ===========================================================================
; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------

Sound_PlaySFX_2:
		tst.b	$27(a6)
		bne.w	loc_722C6
		tst.b	4(a6)
		bne.w	loc_722C6
		tst.b	$24(a6)
		bne.w	loc_722C6
		movea.l	(Go_SoundIndex).l,a0
		subi.b	#$A1,d7
		bra.s	SoundEffects_Common

Sound_PlaySFX:				; XREF: Sound_ChkValue
		tst.b	$27(a6)
		bne.w	loc_722C6
		tst.b	4(a6)
		bne.w	loc_722C6
		tst.b	$24(a6)
		bne.w	loc_722C6
		cmpi.b	#$B5,d7		; is ring sound	effect played?
		bne.s	Sound_notB5	; if not, branch
		tst.b	$2B(a6)
		bne.s	loc_721EE
		move.b	#$CE,d7		; play ring sound in left speaker

loc_721EE:
		bchg	#0,$2B(a6)	; change speaker

Sound_notB5:
		cmpi.b	#$A7,d7		; is "pushing" sound played?
		bne.s	Sound_notA7	; if not, branch
		tst.b	$2C(a6)
		bne.w	locret_722C4
		move.b	#$80,$2C(a6)

Sound_notA7:
		movea.l	(Go_SoundIndex).l,a0
		subi.b	#$A0,d7

SoundEffects_Common:
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d1
		move.w	(a1)+,d1
		add.l	a3,d1
		move.b	(a1)+,d5
		moveq	#0,d7
		move.b	(a1)+,d7
		subq.b	#1,d7
		moveq	#$30,d6

loc_72228:
		moveq	#0,d3
		move.b	1(a1),d3
		move.b	d3,d4
		bmi.s	loc_72244
		subq.w	#2,d3
		lsl.w	#2,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,(a5)
		bra.s	loc_7226E
; ===========================================================================

loc_72244:
		lsr.w	#3,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,(a5)
		cmpi.b	#$C0,d4
		bne.s	loc_7226E
		move.b	d4,d0
		ori.b	#$1F,d0
		move.b	d0,($C00011).l
		bchg	#5,d0
		move.b	d0,($C00011).l

loc_7226E:
		movea.l	SFX_SFXChannelRAM(pc,d3.w),a5
		movea.l	a5,a2
		moveq	#$B,d0

loc_72276:
		clr.l	(a2)+
		dbf	d0,loc_72276

		move.w	(a1)+,(a5)
		move.b	d5,2(a5)
		moveq	#0,d0
		move.w	(a1)+,d0
		add.l	a3,d0
		move.l	d0,4(a5)
		move.w	(a1)+,8(a5)
		move.b	#1,$E(a5)
		move.b	d6,$D(a5)
		tst.b	d4
		bmi.s	loc_722A8
		move.b	#$C0,$A(a5)
		move.l	d1,$20(a5)

loc_722A8:
		dbf	d7,loc_72228

		tst.b	$250(a6)
		bpl.s	loc_722B8
		bset	#2,$340(a6)

loc_722B8:
		tst.b	$310(a6)
		bpl.s	locret_722C4
		bset	#2,$370(a6)

locret_722C4:
		rts	
; ===========================================================================

loc_722C6:
		clr.b	0(a6)
		rts	
; ===========================================================================
SFX_BGMChannelRAM:
		dc.l $FFF0D0
		dc.l 0
		dc.l $FFF100
		dc.l $FFF130
		dc.l $FFF190
		dc.l $FFF1C0
		dc.l $FFF1F0
		dc.l $FFF1F0
		
SFX_SFXChannelRAM:
		dc.l $FFF220
		dc.l 0
		dc.l $FFF250
		dc.l $FFF280
		dc.l $FFF2B0
		dc.l $FFF2E0
		dc.l $FFF310
		dc.l $FFF310
; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------

Sound_PlaySpecial:				; XREF: Sound_ChkValue
		tst.b	$27(a6)
		bne.w	locret_723C6
		tst.b	4(a6)
		bne.w	locret_723C6
		tst.b	$24(a6)
		bne.w	locret_723C6
		movea.l	(Go_SpecSoundIndex).l,a0
		subi.b	#$D0,d7
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0
		add.l	a3,d0
		move.l	d0,$20(a6)
		move.b	(a1)+,d5
		moveq	#0,d7
		move.b	(a1)+,d7
		subq.b	#1,d7
		moveq	#$30,d6

loc_72348:
		move.b	1(a1),d4
		bmi.s	loc_7235A
		bset	#2,$100(a6)
		lea	$340(a6),a5
		bra.s	loc_72364
; ===========================================================================

loc_7235A:
		bset	#2,$1F0(a6)
		lea	$370(a6),a5

loc_72364:
		movea.l	a5,a2
		moveq	#$B,d0

loc_72368:
		clr.l	(a2)+
		dbf	d0,loc_72368

		move.w	(a1)+,(a5)
		move.b	d5,2(a5)
		moveq	#0,d0
		move.w	(a1)+,d0
		add.l	a3,d0
		move.l	d0,4(a5)
		move.w	(a1)+,8(a5)
		move.b	#1,$E(a5)
		move.b	d6,$D(a5)
		tst.b	d4
		bmi.s	loc_72396
		move.b	#$C0,$A(a5)

loc_72396:
		dbf	d7,loc_72348

		tst.b	$250(a6)
		bpl.s	loc_723A6
		bset	#2,$340(a6)

loc_723A6:
		tst.b	$310(a6)
		bpl.s	locret_723C6
		bset	#2,$370(a6)
		ori.b	#$1F,d4
		move.b	d4,($C00011).l
		bchg	#5,d4
		move.b	d4,($C00011).l

locret_723C6:
		rts	
; End of function Sound_ChkValue

; ===========================================================================
SpecSFX_BGMChannelRAM:
		dc.l $FFF100
		dc.l $FFF1F0
		
SpecSFX_SFXChannelRAM:
		dc.l $FFF250
		dc.l $FFF310
		
SpecSFX_SpecSFXChannelRAM:
		dc.l $FFF340
		dc.l $FFF370

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


StopSFX:				; XREF: FadeOutMusic
		clr.b	0(a6)
		lea	$220(a6),a5
		moveq	#5,d7

loc_723EA:
		tst.b	(a5)
		bpl.w	loc_72472
		bclr	#7,(a5)
		moveq	#0,d3
		move.b	1(a5),d3
		bmi.s	loc_7243C
		jsr	FMNoteOff(pc)
		cmpi.b	#4,d3
		bne.s	loc_72416
		tst.b	$340(a6)
		bpl.s	loc_72416
		movea.l	a5,a3
		lea	$340(a6),a5
		movea.l	$20(a6),a1
		bra.s	loc_72428
; ===========================================================================

loc_72416:
		subq.b	#2,d3
		lsl.b	#2,d3
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		movea.l	(a0,d3.w),a5
		movea.l	$18(a6),a1

loc_72428:
		bclr	#2,(a5)
		bset	#1,(a5)
		move.b	$B(a5),d0
		jsr	SetVoice(pc)
		movea.l	a3,a5
		bra.s	loc_72472
; ===========================================================================

loc_7243C:
		jsr	PSGNoteOff(pc)
		lea	$370(a6),a0
		cmpi.b	#$E0,d3
		beq.s	loc_7245A
		cmpi.b	#$C0,d3
		beq.s	loc_7245A
		lsr.b	#3,d3
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d3.w),a0

loc_7245A:
		bclr	#2,(a0)
		bset	#1,(a0)
		cmpi.b	#$E0,1(a0)
		bne.s	loc_72472
		move.b	$1F(a0),($C00011).l

loc_72472:
		adda.w	#$30,a5
		dbf	d7,loc_723EA

		rts	
; End of function StopSFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


StopSpecialSFX:				; XREF: FadeOutMusic
		lea	$340(a6),a5
		tst.b	(a5)
		bpl.s	loc_724AE
		bclr	#7,(a5)
		btst	#2,(a5)
		bne.s	loc_724AE
		jsr	SendFMNoteOff(pc)
		lea	$100(a6),a5
		bclr	#2,(a5)
		bset	#1,(a5)
		tst.b	(a5)
		bpl.s	loc_724AE
		movea.l	$18(a6),a1
		move.b	$B(a5),d0
		jsr	SetVoice(pc)

loc_724AE:
		lea	$370(a6),a5
		tst.b	(a5)
		bpl.s	locret_724E4
		bclr	#7,(a5)
		btst	#2,(a5)
		bne.s	locret_724E4
		jsr	SendPSGNoteOff(pc)
		lea	$1F0(a6),a5
		bclr	#2,(a5)
		bset	#1,(a5)
		tst.b	(a5)
		bpl.s	locret_724E4
		cmpi.b	#-$20,1(a5)
		bne.s	locret_724E4
		move.b	$1F(a5),($C00011).l

locret_724E4:
		rts	
; End of function StopSpecialSFX

; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------

FadeOutMusic:				; XREF: Sound_ExIndex
		jsr	StopSFX(pc)
		jsr	StopSpecialSFX(pc)
		move.b	#3,6(a6)
		move.b	#$28,4(a6)
		clr.b	$40(a6)
		clr.b	$2A(a6)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoFadeOut:				; XREF: UpdateMusic
		move.b	6(a6),d0
		beq.s	loc_72510
		subq.b	#1,6(a6)
		rts	
; ===========================================================================

loc_72510:
		subq.b	#1,4(a6)
		beq.w	StopSoundAndMusic
		move.b	#3,6(a6)
		lea	$70(a6),a5
		moveq	#5,d7

loc_72524:
		tst.b	(a5)
		bpl.s	loc_72538
		addq.b	#1,9(a5)
		bpl.s	loc_72534
		bclr	#7,(a5)
		bra.s	loc_72538
; ===========================================================================

loc_72534:
		jsr	SendVoiceTL(pc)

loc_72538:
		adda.w	#$30,a5
		dbf	d7,loc_72524

		moveq	#2,d7

loc_72542:
		tst.b	(a5)
		bpl.s	loc_72560
		addq.b	#1,9(a5)
		cmpi.b	#$10,9(a5)
		bcs.s	loc_72558
		bclr	#7,(a5)
		bra.s	loc_72560
; ===========================================================================

loc_72558:
		move.b	9(a5),d6
		jsr	SetPSGVolume(pc)

loc_72560:
		adda.w	#$30,a5
		dbf	d7,loc_72542

		rts	
; End of function DoFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMSilenceAll:				; XREF: StopSoundAndMusic; InitMusicPlayback
		moveq	#2,d3
		moveq	#$28,d0

loc_7256E:
		move.b	d3,d1
		jsr	WriteFMI(pc)
		addq.b	#4,d1
		jsr	WriteFMI(pc)
		dbf	d3,loc_7256E

		moveq	#$40,d0
		moveq	#$7F,d1
		moveq	#2,d4

loc_72584:
		moveq	#3,d3

loc_72586:
		jsr	WriteFMI(pc)
		jsr	WriteFMII(pc)
		addq.w	#4,d0
		dbf	d3,loc_72586

		subi.b	#$F,d0
		dbf	d4,loc_72584

		rts	
; End of function FMSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------

StopSoundAndMusic:				; XREF: Sound_ChkValue; Sound_ExIndex; DoFadeOut
		moveq	#$2B,d0
		move.b	#$80,d1
		jsr	WriteFMI(pc)
		moveq	#$27,d0
		moveq	#0,d1
		jsr	WriteFMI(pc)
		movea.l	a6,a0
		move.w	#$E7,d0

loc_725B6:
		clr.l	(a0)+
		dbf	d0,loc_725B6

		move.b	#0,9(a6)	; set music to 0 (silence)
		jsr	FMSilenceAll(pc)

		tst.b	($FFFFFFB4).w
		bne.s	@Skip
		stopZ80
		move.b	#$80,($A01FFF).l ; stop DAC playback
		startZ80

@Skip:
		bra.w	PSGSilenceAll

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


InitMusicPlayback:				; XREF: Sound_ChkValue
		movea.l	a6,a0
		move.b	0(a6),d1
		move.b	$27(a6),d2
		move.b	$2A(a6),d3
		move.b	$26(a6),d4
		move.w	$A(a6),d5
		move.w	#$87,d0

loc_725E4:
		clr.l	(a0)+
		dbf	d0,loc_725E4

		move.b	d1,0(a6)
		move.b	d2,$27(a6)
		move.b	d3,$2A(a6)
		move.b	d4,$26(a6)
		move.w	d5,$A(a6)
		move.b	#0,9(a6)
		
		lea	$41(a6),a1
		lea	ChannelInitBytes(pc),a2
		moveq	#9,d1
		
@WriteLoop:
		move.b	(a2)+,(a1)
		lea	$30(a1),a1
		dbf	d1,@WriteLoop
		
		rts
		
		jsr	FMSilenceAll(pc)
		bra.w	PSGSilenceAll
; End of function InitMusicPlayback


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


TempoWait:				; XREF: UpdateMusic
		move.b	2(a6),1(a6)
		lea	$4E(a6),a0
		moveq	#$30,d0
		moveq	#9,d1

loc_7261A:
		addq.b	#1,(a0)
		adda.w	d0,a0
		dbf	d1,loc_7261A

		rts	
; End of function TempoWait

; ===========================================================================
; ---------------------------------------------------------------------------
; Speed	up music
; ---------------------------------------------------------------------------

SpeedUpMusic:				; XREF: Sound_ExIndex
		tst.b	$27(a6)
		bne.s	loc_7263E
		move.b	$29(a6),2(a6)
		move.b	$29(a6),1(a6)
		move.b	#$80,$2A(a6)
		rts	
; ===========================================================================

loc_7263E:
		move.b	$3C9(a6),$3A2(a6)
		move.b	$3C9(a6),$3A1(a6)
		move.b	#$80,$3CA(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change music back to normal speed
; ---------------------------------------------------------------------------

SlowDownMusic:				; XREF: Sound_ExIndex
		tst.b	$27(a6)
		bne.s	loc_7266A
		move.b	$28(a6),2(a6)
		move.b	$28(a6),1(a6)
		clr.b	$2A(a6)
		rts	
; ===========================================================================

loc_7266A:
		move.b	$3C8(a6),$3A2(a6)
		move.b	$3C8(a6),$3A1(a6)
		clr.b	$3CA(a6)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DoFadeIn:				; XREF: UpdateMusic
		tst.b	$25(a6)
		beq.s	loc_72688
		subq.b	#1,$25(a6)
		rts	
; ===========================================================================

loc_72688:
		tst.b	$26(a6)
		beq.s	loc_726D6
		subq.b	#1,$26(a6)
		move.b	#2,$25(a6)
		lea	$70(a6),a5
		moveq	#5,d7

loc_7269E:
		tst.b	(a5)
		bpl.s	loc_726AA
		subq.b	#1,9(a5)
		jsr	SendVoiceTL(pc)

loc_726AA:
		adda.w	#$30,a5
		dbf	d7,loc_7269E
		moveq	#2,d7

loc_726B4:
		tst.b	(a5)
		bpl.s	loc_726CC
		subq.b	#1,9(a5)
		move.b	9(a5),d6
		jsr	SetPSGVolume(pc)

loc_726CC:
		adda.w	#$30,a5
		dbf	d7,loc_726B4
		rts	
; ===========================================================================

loc_726D6:
		bclr	#2,$40(a6)
		clr.b	$24(a6)

		tst.b	$40(a6)					; is the DAC channel running?
		bpl.s	Resume_NoDAC				; if not, branch

		moveq	#$FFFFFFB6,d0				; prepare FM channel 3/6 L/R/AMS/FMS address
		move.b	$4A(a6),d1				; load DAC channel's L/R/AMS/FMS value
		jmp	WriteFMII(pc)				; write to FM 6

Resume_NoDAC:
		rts

; ===========================================================================

FMNoteOn:				; XREF: FMUpdateTrack
		btst	#1,(a5)
		bne.s	locret_726FC
		btst	#2,(a5)
		bne.s	locret_726FC
		moveq	#$28,d0
		move.b	1(a5),d1
		ori.b	#-$10,d1
		bra.w	WriteFMI
; ===========================================================================

locret_726FC:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FMNoteOff:				; XREF: FMDoNext; NoteFillUpdate; Sound_ChkValue; StopSFX
		btst	#4,(a5)
		bne.s	locret_72714
		btst	#2,(a5)
		bne.s	locret_72714

SendFMNoteOff:				; XREF: StopSpecialSFX
		moveq	#$28,d0
		move.b	1(a5),d1
		bra.w	WriteFMI
; ===========================================================================

locret_72714:
		rts	
; End of function FMNoteOff

; ===========================================================================

WriteFMIorIIMain:				; XREF: CoordFlag
		btst	#2,(a5)
		bne.s	locret_72720
		bra.w	WriteFMIorII
; ===========================================================================

locret_72720:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WriteFMIorII:				; XREF: FMPrepareNote; SetVoice; SendVoiceTL
		btst	#2,1(a5)
		bne.s	WriteFMIIPart
		add.b	1(a5),d0
; End of function WriteFMIorII


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WriteFMI:		 ; XREF: loc_71E6A
		stopZ80
		lea	($A04000).l,a0
		waitYM
		move.b	d0,(a0)
		waitYM
		move.b	d1,1(a0)
		waitYM
		move.b	#$2A,(a0)
		startZ80
		rts
; End of function WriteFMI

; ===========================================================================

WriteFMIIPart:				; XREF: WriteFMIorII
		move.b	1(a5),d2
		bclr	#2,d2
		add.b	d2,d0

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WriteFMII:		 ; XREF: loc_71E6A; Sound_ChkValue; FMSilenceAll; WriteFMII
		stopZ80
		lea	($A04000).l,a0
		waitYM
		move.b	d0,2(a0)
		waitYM
		move.b	d1,3(a0)
		waitYM
		move.b	#$2A,(a0)
		startZ80
		rts
; End of function WriteFMII

; ===========================================================================
FM_Notes:
		dc.w $25E, $284, $2AB, $2D3, $2FE, $32D, $35C, $38F, $3C5
		dc.w $3FF, $43C, $47C, $A5E, $A84, $AAB, $AD3, $AFE, $B2D
		dc.w $B5C, $B8F, $BC5, $BFF, $C3C, $C7C, $125E,	$1284
		dc.w $12AB, $12D3, $12FE, $132D, $135C,	$138F, $13C5, $13FF
		dc.w $143C, $147C, $1A5E, $1A84, $1AAB,	$1AD3, $1AFE, $1B2D
		dc.w $1B5C, $1B8F, $1BC5, $1BFF, $1C3C,	$1C7C, $225E, $2284
		dc.w $22AB, $22D3, $22FE, $232D, $235C,	$238F, $23C5, $23FF
		dc.w $243C, $247C, $2A5E, $2A84, $2AAB,	$2AD3, $2AFE, $2B2D
		dc.w $2B5C, $2B8F, $2BC5, $2BFF, $2C3C,	$2C7C, $325E, $3284
		dc.w $32AB, $32D3, $32FE, $332D, $335C,	$338F, $33C5, $33FF
		dc.w $343C, $347C, $3A5E, $3A84, $3AAB,	$3AD3, $3AFE, $3B2D
		dc.w $3B5C, $3B8F, $3BC5, $3BFF, $3C3C,	$3C7C

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateTrack:				; XREF: UpdateMusic
		subq.b	#1,$E(a5)
		bne.s	loc_72866
		bclr	#4,(a5)
		bsr.w	PSGDoNext
		bsr.w	PSGDoNoteOn
		bsr.w	PSGDoVolFX
		bsr.w	DoModulation
		bra.w	PSGUpdateFreq
; ===========================================================================

loc_72866:
		bsr.w	NoteFillUpdate
		bsr.w	PSGUpdateVolFX
		bsr.w	DoModulation
		bra.w	PSGUpdateFreq
; End of function PSGUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGDoNext:				; XREF: PSGUpdateTrack
		bclr	#1,(a5)
		movea.l	4(a5),a4

loc_72880:
		moveq	#0,d5
		move.b	(a4)+,d5
		cmpi.b	#$E0,d5
		bcs.s	loc_72890
		jsr	CoordFlag(pc)
		bra.s	loc_72880
; ===========================================================================

loc_72890:
		tst.b	d5
		bpl.s	loc_728A4
		jsr	PSGSetFreq(pc)
		move.b	(a4)+,d5
		tst.b	d5
		bpl.s	loc_728A4
		subq.w	#1,a4
		bra.w	FinishTrackUpdate
; ===========================================================================

loc_728A4:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function PSGDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGSetFreq:				; XREF: PSGDoNext
		subi.b	#$81,d5
		bcs.s	loc_728CA
		add.b	8(a5),d5
		andi.w	#$7F,d5
		lsl.w	#1,d5
		lea	PSGFrequencies(pc),a0
		move.w	(a0,d5.w),$10(a5)
		bra.w	FinishTrackUpdate
; ===========================================================================

loc_728CA:
		bset	#1,(a5)
		move.w	#-1,$10(a5)
		jsr	FinishTrackUpdate(pc)
		bra.w	PSGNoteOff
; End of function PSGSetFreq


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGDoNoteOn:				; XREF: PSGUpdateTrack
		move.w	$10(a5),d6
		bmi.s	PSGSetRest
; End of function PSGDoNoteOn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateFreq:				; XREF: PSGUpdateTrack
		move.b	$1E(a5),d0
		ext.w	d0
		add.w	d0,d6
		btst	#2,(a5)
		bne.s	locret_7291E
		btst	#1,(a5)
		bne.s	locret_7291E
		move.b	1(a5),d0
		cmpi.b	#$E0,d0
		bne.s	loc_72904
		move.b	#$C0,d0

loc_72904:
		move.w	d6,d1
		andi.b	#$F,d1
		or.b	d1,d0
		lsr.w	#4,d6
		andi.b	#$3F,d6
		move.b	d0,($C00011).l
		move.b	d6,($C00011).l

locret_7291E:
		rts	
; End of function PSGUpdateFreq

; ===========================================================================

PSGSetRest:				; XREF: PSGDoNoteOn
		bset	#1,(a5)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGUpdateVolFX:				; XREF: PSGUpdateTrack
		tst.b	$B(a5)
		beq.w	locret_7298A

PSGDoVolFX:				; XREF: PSGUpdateTrack
		move.b	9(a5),d6
		moveq	#0,d0
		move.b	$B(a5),d0
		beq.s	SetPSGVolume
		movea.l	(Go_PSGIndex).l,a0
		subq.w	#1,d0
		add.w	d0,d0
		add.w	d0,d0
		movea.l	(a0,d0.w),a0
		
PSGDoVolFX_Loop:
		moveq	#0,d0
		move.b	$C(a5),d0
		addq.b	#1,$C(a5)
		move.b	(a0,d0.w),d0
		bpl.s	loc_72960
		cmpi.b	#$81,d0
		beq.s	VolEnv_Hold
		cmpi.b	#$83,d0
		beq.s	VolEnv_Off
		cmpi.b	#$80,d0
		beq.s	VolEnv_Reset
		cmpi.b	#$82,d0
		beq.s	VolEnv_Jump2Idx

loc_72960:
		add.w	d0,d6
; End of function PSGUpdateVolFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetPSGVolume:				; XREF: DoFadeOut; DoFadeIn; PSGUpdateVolFX
		btst	#1,(a5)
		bne.s	locret_7298A
		btst	#2,(a5)
		bne.s	locret_7298A
		btst	#4,(a5)
		bne.s	PSGCheckNoteFill

PSGSendVolume:
		cmpi.b	#$10,d6 		; Is volume $10 or higher?
		blo.s	@psgsendvol 	; Branch if not
		moveq	#$F,d6 			; Limit to silence and fall through

@psgsendvol:
		or.b	1(a5),d6
		addi.b	#$10,d6
		move.b	d6,($C00011).l

locret_7298A:
		rts	
; ===========================================================================

PSGCheckNoteFill:
		tst.b	$13(a5)
		beq.s	PSGSendVolume
		tst.b	$12(a5)
		bne.s	PSGSendVolume
		rts	
; End of function SetPSGVolume
; ===========================================================================

VolEnv_Jump2Idx:
		move.b	1(a0,d0.w),$C(a5)
		bra.s	PSGDoVolFX_Loop
; ===========================================================================

VolEnv_Reset:
		clr.b	$C(a5)
		bra.s	PSGDoVolFX_Loop
; ===========================================================================

VolEnv_Hold:				; XREF: PSGUpdateVolFX
		subq.b	#1,$C(a5)
		rts	
; ===========================================================================
	
VolEnv_Off:
		subq.b	#1,$C(a5)
		bset	#1,(a5)

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGNoteOff:				; XREF: NoteFillUpdate; Sound_ChkValue; StopSFX; PSGSetFreq
		btst	#2,(a5)
		bne.s	locret_729B4

SendPSGNoteOff:				; XREF: StopSpecialSFX
		move.b	1(a5),d0
		ori.b	#$1F,d0
		move.b	d0,($C00011).l

		cmpi.b	#$DF,d0
		bne.s	locret_729B4
		move.b	#$FF,($C00011).l

locret_729B4:
		rts	
; End of function PSGNoteOff


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PSGSilenceAll:				; XREF: loc_71E7C
		lea	($C00011).l,a0
		move.b	#$9F,(a0)
		move.b	#$BF,(a0)
		move.b	#$DF,(a0)
		move.b	#$FF,(a0)
		rts	
; End of function PSGSilenceAll

; ===========================================================================
PSGFrequencies:
		dc.w $356, $326, $2F9, $2CE, $2A5, $280, $25C, $23A, $21A
		dc.w $1FB, $1DF, $1C4, $1AB, $193, $17D, $167, $153, $140
		dc.w $12E, $11D, $10D, $FE, $EF, $E2, $D6, $C9,	$BE, $B4
		dc.w $A9, $A0, $97, $8F, $87, $7F, $78,	$71, $6B, $65
		dc.w $5F, $5A, $55, $50, $4B, $47, $43,	$40, $3C, $39
		dc.w $36, $33, $30, $2D, $2B, $28, $26,	$24, $22, $20
		dc.w $1F, $1D, $1B, $1A, $18, $17, $16,	$15, $13, $12
		dc.w $11, 0

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CoordFlag:				; XREF: UpdateDAC; FMDoNext; PSGDoNext
		subi.w	#$E0,d5
		lsl.w	#2,d5
		jmp	coordflagLookup(pc,d5.w)
; End of function CoordFlag

; ===========================================================================

coordflagLookup:
		bra.w	cfPanningAMSFMS
; ===========================================================================
		bra.w	cfDetune
; ===========================================================================
		bra.w	cfSetCommunication
; ===========================================================================
		bra.w	cfJumpReturn
; ===========================================================================
		bra.w	cfFadeInToPrevious
; ===========================================================================
		bra.w	cfSetTempoDivider
; ===========================================================================
		bra.w	cfChangeFMVolume
; ===========================================================================
		bra.w	cfPreventAttack
; ===========================================================================
		bra.w	cfNoteFill
; ===========================================================================
		bra.w	cfChangeTransposition
; ===========================================================================
		bra.w	cfSetTempo
; ===========================================================================
		bra.w	cfSetTempoMod
; ===========================================================================
		bra.w	cfChangePSGVolume
; ===========================================================================
		bra.w	cfClearPush
; ===========================================================================
		bra.w	cfStopSpecialFM4
; ===========================================================================
		bra.w	cfSetVoice
; ===========================================================================
		bra.w	cfModulation
; ===========================================================================
		bra.w	cfEnableModulation
; ===========================================================================
		bra.w	cfStopTrack
; ===========================================================================
		bra.w	cfSetPSGNoise
; ===========================================================================
		bra.w	cfDisableModulation
; ===========================================================================
		bra.w	cfSetPSGTone
; ===========================================================================
		bra.w	cfJumpTo
; ===========================================================================
		bra.w	cfRepeatAtPos
; ===========================================================================
		bra.w	cfJumpToGosub
; ===========================================================================
		bra.w	cfOpF9
; ===========================================================================

cfPanningAMSFMS:				; XREF: coordflagLookup
		move.b	(a4)+,d1
		tst.b	1(a5)
		bmi.s	locret_72AEA
		move.b	$A(a5),d0
		andi.b	#$37,d0
		or.b	d0,d1
		move.b	d1,$A(a5)
		move.b	#$B4,d0
		bra.w	WriteFMIorIIMain
; ===========================================================================

locret_72AEA:
		rts	
; ===========================================================================

cfDetune:				; XREF: coordflagLookup
		move.b	(a4)+,$1E(a5)
		rts	
; ===========================================================================

cfSetCommunication:				; XREF: coordflagLookup
		move.b	(a4)+,7(a6)
		rts	
; ===========================================================================

cfJumpReturn:				; XREF: coordflagLookup
		moveq	#0,d0
		move.b	$D(a5),d0
		movea.l	(a5,d0.w),a4
		move.l	#0,(a5,d0.w)
		addq.w	#2,a4
		addq.b	#4,d0
		move.b	d0,$D(a5)
		rts	
; ===========================================================================

cfFadeInToPrevious:				; XREF: coordflagLookup
		movea.l	a6,a0
		lea	$3A0(a6),a1
		move.w	#$87,d0

loc_72B1E:
		move.l	(a1)+,(a0)+
		dbf	d0,loc_72B1E

		bset	#2,$40(a6)
		movea.l	a5,a3
		move.b	#$28,d6
		sub.b	$26(a6),d6
		moveq	#5,d7
		lea	$70(a6),a5

loc_72B3A:
		btst	#7,(a5)
		beq.s	loc_72B5C
		bset	#1,(a5)
		add.b	d6,9(a5)
		btst	#2,(a5)
		bne.s	loc_72B5C
		moveq	#0,d0
		move.b	$B(a5),d0
		movea.l	$18(a6),a1
		jsr	SetVoice(pc)

loc_72B5C:
		adda.w	#$30,a5
		dbf	d7,loc_72B3A

		moveq	#2,d7

loc_72B66:
		btst	#7,(a5)
		beq.s	loc_72B78
		bset	#1,(a5)
		jsr	PSGNoteOff(pc)
		add.b	d6,9(a5)
		cmpi.b	#$E0,1(a5)				; is this the Noise Channel?
		bne.s	loc_72B78				; no - skip
		move.b	$1F(a5),($C00011).l		; restore Noise setting

loc_72B78:
		adda.w	#$30,a5
		dbf	d7,loc_72B66
		movea.l	a3,a5
		tst.b	$40(a6)			; is the DAC channel running?
		bmi.s	Restore_NoFM6		; if it is, branch

		moveq	#$2B,d0			; DAC enable/disable register
		moveq	#0,d1			; Disable DAC
		jsr	WriteFMI(pc)

Restore_NoFM6
		move.b	#$80,$24(a6)
		move.b	#$28,$26(a6)
		clr.b	$27(a6)
		move.w	#0,($A11100).l
		addq.w	#8,sp
		rts	
; ===========================================================================

cfSetTempoDivider:				; XREF: coordflagLookup
		move.b	(a4)+,2(a5)
		rts	
; ===========================================================================

cfChangeFMVolume:				; XREF: coordflagLookup
		move.b	(a4)+,d0
		add.b	d0,9(a5)
		bra.w	SendVoiceTL
; ===========================================================================

cfPreventAttack:				; XREF: coordflagLookup
		bset	#4,(a5)
		rts	
; ===========================================================================

cfNoteFill:				; XREF: coordflagLookup
		move.b	(a4),$12(a5)
		move.b	(a4)+,$13(a5)
		rts	
; ===========================================================================

cfChangeTransposition:				; XREF: coordflagLookup
		move.b	(a4)+,d0
		add.b	d0,8(a5)
		rts	
; ===========================================================================

cfSetTempo:				; XREF: coordflagLookup
		move.b	(a4),2(a6)
		move.b	(a4)+,1(a6)
		rts	
; ===========================================================================

cfSetTempoMod:				; XREF: coordflagLookup
		lea	$40(a6),a0
		move.b	(a4)+,d0
		moveq	#$30,d1
		moveq	#9,d2

loc_72BDA:
		move.b	d0,2(a0)
		adda.w	d1,a0
		dbf	d2,loc_72BDA

		rts	
; ===========================================================================

cfChangePSGVolume:				; XREF: coordflagLookup
		move.b	(a4)+,d0
		add.b	d0,9(a5)
		rts	
; ===========================================================================

cfClearPush:				; XREF: coordflagLookup
		clr.b	$2C(a6)
		rts	
; ===========================================================================

cfStopSpecialFM4:				; XREF: coordflagLookup
		bclr	#7,(a5)
		bclr	#4,(a5)
		jsr	FMNoteOff(pc)
		tst.b	$250(a6)
		bmi.s	loc_72C22
		movea.l	a5,a3
		lea	$100(a6),a5
		movea.l	$18(a6),a1
		bclr	#2,(a5)
		bset	#1,(a5)
		move.b	$B(a5),d0
		jsr	SetVoice(pc)
		movea.l	a3,a5

loc_72C22:
		addq.w	#8,sp
		rts	
; ===========================================================================

cfSetVoice:				; XREF: coordflagLookup
		moveq	#0,d0
		move.b	(a4)+,d0
		move.b	d0,$B(a5)
		btst	#2,(a5)
		bne.w	locret_72CAA
		movea.l	$18(a6),a1
		tst.b	$E(a6)
		beq.s	SetVoice
		movea.l	$20(a5),a1
		tst.b	$E(a6)
		bmi.s	SetVoice
		movea.l	$20(a6),a1

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SetVoice:				; XREF: StopSFX; et al
		subq.w	#1,d0
		bmi.s	loc_72C5C
		move.w	#$19,d1

loc_72C56:
		adda.w	d1,a1
		dbf	d0,loc_72C56

loc_72C5C:
		move.b	(a1)+,d1
		move.b	d1,$1F(a5)
		move.b	d1,d4
		move.b	#$B0,d0
		jsr	WriteFMIorII(pc)
		lea	FMInstrumentOperatorTable(pc),a2
		moveq	#$13,d3

loc_72C72:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		jsr	WriteFMIorII(pc)
		dbf	d3,loc_72C72
		moveq	#3,d5
		andi.w	#7,d4
		move.b	FMSlotMask(pc,d4.w),d4
		move.b	9(a5),d3

loc_72C8C:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4
		bcc.s	loc_72C96
		add.b	d3,d1

loc_72C96:
		jsr	WriteFMIorII(pc)
		dbf	d5,loc_72C8C
		move.b	#$B4,d0
		move.b	$A(a5),d1
		jsr	WriteFMIorII(pc)

locret_72CAA:
		rts	
; End of function SetVoice

; ===========================================================================
FMSlotMask:		dc.b 8,	8, 8, 8, $A, $E, $E, $F

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SendVoiceTL:				; XREF: DoFadeOut; DoFadeIn; cfChangeFMVolume
		btst	#2,(a5)
		bne.s	locret_72D16
		moveq	#0,d0
		move.b	$B(a5),d0
		movea.l	$18(a6),a1
		tst.b	$E(a6)
		beq.s	loc_72CD8
		movea.l	$20(a5),a1
		tst.b	$E(a6)
		bmi.s	loc_72CD8
		movea.l	$20(a6),a1

loc_72CD8:
		subq.w	#1,d0
		bmi.s	loc_72CE6
		move.w	#$19,d1

loc_72CE0:
		adda.w	d1,a1
		dbf	d0,loc_72CE0

loc_72CE6:
		adda.w	#$15,a1
		lea	FMInstrumentTLTable(pc),a2
		move.b	$1F(a5),d0
		andi.w	#7,d0
		move.b	FMSlotMask(pc,d0.w),d4
		move.b	9(a5),d3
		bmi.s	locret_72D16
		moveq	#3,d5

loc_72D02:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4
		bcc.s	loc_72D12
		add.b	d3,d1
		bcs.s	loc_72D12
		jsr	WriteFMIorII(pc)

loc_72D12:
		dbf	d5,loc_72D02

locret_72D16:
		rts	
; End of function SendVoiceTL

; ===========================================================================
FMInstrumentOperatorTable:
		dc.b $30, $38, $34, $3C, $50, $58, $54,	$5C, $60, $68
		dc.b $64, $6C, $70, $78, $74, $7C, $80,	$88, $84, $8C
FMInstrumentTLTable:
		dc.b $40, $48, $44, $4C
; ===========================================================================

cfModulation:				; XREF: coordflagLookup
		bset	#3,(a5)
		move.l	a4,$14(a5)
		move.b	(a4)+,$18(a5)
		move.b	(a4)+,$19(a5)
		move.b	(a4)+,$1A(a5)
		move.b	(a4)+,d0
		lsr.b	#1,d0
		move.b	d0,$1B(a5)
		clr.w	$1C(a5)
		rts	
; ===========================================================================

cfEnableModulation:				; XREF: coordflagLookup
		bset	#3,(a5)
		rts	
; ===========================================================================

cfStopTrack:				; XREF: coordflagLookup
		bclr	#7,(a5)
		bclr	#4,(a5)
		tst.b	1(a5)
		bmi.s	loc_72D74
		tst.b	8(a6)
		bmi.w	loc_72E02
		jsr	FMNoteOff(pc)
		bra.s	loc_72D78
; ===========================================================================

loc_72D74:
		jsr	PSGNoteOff(pc)

loc_72D78:
		tst.b	$E(a6)
		bpl.w	loc_72E02
		clr.b	0(a6)
		moveq	#0,d0
		move.b	1(a5),d0
		bmi.s	loc_72DCC
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		cmpi.b	#4,d0
		bne.s	loc_72DA8
		tst.b	$340(a6)
		bpl.s	loc_72DA8
		lea	$340(a6),a5
		movea.l	$20(a6),a1
		bra.s	loc_72DB8
; ===========================================================================

loc_72DA8:
		subq.b	#2,d0
		lsl.b	#2,d0
		movea.l	(a0,d0.w),a5
		tst.b	(a5)
		bpl.s	loc_72DC8
		movea.l	$18(a6),a1

loc_72DB8:
		bclr	#2,(a5)
		bset	#1,(a5)
		move.b	$B(a5),d0
		jsr	SetVoice(pc)

loc_72DC8:
		movea.l	a3,a5
		bra.s	loc_72E02
; ===========================================================================

loc_72DCC:
		lea	$370(a6),a0
		tst.b	(a0)
		bpl.s	loc_72DE0
		cmpi.b	#$E0,d0
		beq.s	loc_72DEA
		cmpi.b	#$C0,d0
		beq.s	loc_72DEA

loc_72DE0:
		lea	SFX_BGMChannelRAM(pc),a0
		lsr.b	#3,d0
		movea.l	(a0,d0.w),a0

loc_72DEA:
		bclr	#2,(a0)
		bset	#1,(a0)
		cmpi.b	#$E0,1(a0)
		bne.s	loc_72E02
		move.b	$1F(a0),($C00011).l

loc_72E02:
		addq.w	#8,sp
		rts	
; ===========================================================================

cfSetPSGNoise:				; XREF: coordflagLookup
		move.b	#$E0,1(a5)
		move.b	(a4)+,$1F(a5)
		btst	#2,(a5)
		bne.s	locret_72E1E
		move.b	-1(a4),($C00011).l

locret_72E1E:
		rts	
; ===========================================================================

cfDisableModulation:				; XREF: coordflagLookup
		bclr	#3,(a5)
		rts	
; ===========================================================================

cfSetPSGTone:				; XREF: coordflagLookup
		move.b	(a4)+,$B(a5)
		rts	
; ===========================================================================

cfJumpTo:				; XREF: coordflagLookup
		move.b	(a4)+,d0
		lsl.w	#8,d0
		move.b	(a4)+,d0
		adda.w	d0,a4
		subq.w	#1,a4
		rts	
; ===========================================================================

cfRepeatAtPos:				; XREF: coordflagLookup
		moveq	#0,d0
		move.b	(a4)+,d0
		move.b	(a4)+,d1
		tst.b	$24(a5,d0.w)
		bne.s	loc_72E48
		move.b	d1,$24(a5,d0.w)

loc_72E48:
		subq.b	#1,$24(a5,d0.w)
		bne.s	cfJumpTo
		addq.w	#2,a4
		rts	
; ===========================================================================

cfJumpToGosub:				; XREF: coordflagLookup
		moveq	#0,d0
		move.b	$D(a5),d0
		subq.b	#4,d0
		move.l	a4,(a5,d0.w)
		move.b	d0,$D(a5)
		bra.s	cfJumpTo
; ===========================================================================

cfOpF9:				; XREF: coordflagLookup
		move.b	#$88,d0
		move.b	#$F,d1
		jsr	WriteFMI(pc)
		move.b	#$8C,d0
		move.b	#$F,d1
		bra.w	WriteFMI
; ===========================================================================
; MegaPCM
; ===========================================================================
Kos_Z80:	include    'MegaPCM.asm'
; ===========================================================================
