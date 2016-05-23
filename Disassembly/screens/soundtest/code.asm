; ===========================================================================
; Sound test screen
; ===========================================================================
; Sound test settings
; ===========================================================================
SndTest_Settings:
		dc.l $FFFFFFB1			; RAM address for sound ID
		dc.b $1F				; Maximum ID
		dc.b 1					; ID modifier (is added to ID)
		dc.l Txt_Music			; Sound type text address
		dc.l $429E0003			; VDP value to draw the text and ID number
		dc.b 1					; "Stop" flag (if 1, then it allows for an option to stop)
		dc.b 0					; Sound type (0 = Music, 1 = SFX, 2 = PCM)
		
		dc.l $FFFFFFB2
		dc.b $2F
		dc.b $A0
		dc.l Txt_SFX
		dc.l $439E0003
		dc.b 0
		dc.b 1
		
		dc.l $FFFFFFB3
		dc.b $16
		dc.b $81
		dc.l Txt_PCM
		dc.l $449E0003
		dc.b 1
		dc.b 2
; ===========================================================================
; Equates for the sound test settings
; ===========================================================================
ram_addr			= 0
max_id				= 4
id_mod				= 5
snd_text_addr		= 6
text_vdp_cmd		= $A
stop_flag			= $E
snd_type			= $F
snd_setting_size	= $10
; ===========================================================================
; Sound stop address array
; ===========================================================================
SndTest_StopAddrs:
		dc.l SndTest_StopMusic			; Music
		dc.l SndTest_Null				; SFX
		dc.l SndTest_StopPCM			; PCM
; ===========================================================================
; Sound play address array
; ===========================================================================
SndTest_PlayAddrs:
		dc.l SndTest_PlayMusic			; Music
		dc.l SndTest_PlaySFX			; SFX
		dc.l SndTest_PlayPCM			; PCM
; ===========================================================================
; Main sound test code
; ===========================================================================
SoundTest:
		move.b	#$FF,d0					; Stop music
		jsr	PlaySound_Special
		jsr	ClearPLC					; Clear PLCS
		jsr	Pal_FadeFrom				; Fade palette
		
		move	#$2700,sr				; Stop interrupts
		
		move.w	($FFFFF60C).w,d0		; Disable screen
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		
		jsr	ClearScreen					; Clear screen

		move.l	#$50000000,($C00004).l	; Load BG art
		lea	(Nem_SndTestBG).l,a0
		jsr	NemDec
		
		move.l	#$44200000,($C00004).l	; Load font
		lea	(Nem_SndTestFont).l,a0
		jsr	NemDec
		
		lea	(Map_SndTestBG).l,a1		; Load BG mappings
		move.l	#$60000003,d0
		moveq	#$3F,d1
		moveq	#$1B,d2
		move.w	#$80,d5
		jsr	ShowVDPGraphics2
		
		moveq	#$15,d0					; Load palette
		jsr	PalLoad1
		
		move.l	#0,($FFFFFFA0).w		; Clear scroll variables
		move.l	#0,($FFFFFFB0).w		; Clear variables
		move.b	#1,($FFFFFFB4).w		; Make it so that when the music is stopped in the sound test, PCM isn't affected
		move.b	#0,($FFFFFFB5).w		; Clear the music playing flag
		
		move.l	#$411E0003,($C00004).l	; Draw "SOUND TEST"
		lea	(Txt_SoundTest).l,a0
		move.w	#$2000,d1
		bsr.w	DrawText
		
		bsr.w	DrawSndTestText			; Draw text

		move.w	#$2000,d1
		move.l	#$469C0003,($C00004).l	; Apply VDP command
		lea	(Txt_SongPlaying).l,a0		; Set the text address
		bsr.w	DrawText
		move.w	#$2000,d1
		move.l	#$489A0003,($C00004).l	; Apply VDP command
		lea	(Txt_Artist).l,a0			; Set the text address
		bsr.w	DrawText
		move.w	#$2000,d1
		move.l	#$4A9A0003,($C00004).l	; Apply VDP command
		lea	(Txt_Source).l,a0			; Set the text address
		bsr.w	DrawText

		bsr.w	SndTest_InfoNothing

		move.w	($FFFFF60C).w,d0		; Enable screen
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		
		jsr	Pal_FadeTo					; Fade to palette

SndTest_MainLoop:
		move.b	#2,($FFFFF62A).w		; V-INT routine #2
		jsr	DelayProgram				; Wait for that to run...

		bsr.w	SndTest_Deform
		tst.w	($FFFFFFA2).w
		beq.s	@NoCap
		addq.w	#1,($FFFFFFA0).w
		cmpi.w	#53,($FFFFFFA0).w
		ble.s	@NoCap
		move.w	#0,($FFFFFFA0).w

@NoCap:
		btst	#0,($FFFFF605).w		; Is the up button pressed?
		beq.s	@NotUp					; If not, branch
		tst.b	($FFFFFFB0).w			; Is the sound test selection 0?
		beq.s	@NotUp					; If so, skip
		subq.b	#1,($FFFFFFB0).w		; Decrement sound test selection
		
@NotUp:
		btst	#1,($FFFFF605).w		; Is the down button pressed?
		beq.s	@NotDown				; If not, branch
		cmpi.b	#2,($FFFFFFB0).w		; Is the sound test selection at the max?
		beq.s	@NotDown				; If so, skip
		addq.b	#1,($FFFFFFB0).w		; Increment sound test selection
		
@NotDown:
		bsr.w	SndTest_GetAddrs		; Get settings address for current sound test selection

		btst	#2,($FFFFF605).w		; Is the left button pressed?
		beq.s	@NotLeft				; If not, branch

		subq.b	#1,(a6)					; Decrement the ID
		move.b	(a6),d1					; Get the ID
		move.b	#$FF,d0					; Check if beyond 0
		tst.b	stop_flag(a5)			; Is the stop ID enabled?
		beq.s	@NoStopFlag				; If not, branch
		move.b	#$FE,d0					; Check if beyond the stop ID

@NoStopFlag:
		cmp.b	d1,d0					; Is the new ID beyond the limit?
		bne.s	@NotMin					; If not, branch
		move.b	max_id(a5),(a6)			; Set to the maximum ID
		
@NotMin:
@NotLeft:
		btst	#3,($FFFFF605).w		; Is the right button pressed?
		beq.s	@NotRight				; If not, branch
		addq.b	#1,(a6)					; Increment the ID
		move.b	max_id(a5),d0			; Get the maximum ID
		move.b	(a6),d1					; Get the current ID
		
		cmp.b	d0,d1					; Is the current ID beyond the maximum ID?
		bls.s	@NotMax					; If not, skip
		
		move.b	#0,d0					; Set to 0
		tst.b	stop_flag(a5)			; Is the stop ID enabled?
		beq.s	@NoStopFlag2			; If not, branch
		move.b	#$FF,d0					; Set to the stop ID
		
@NoStopFlag2:
		move.b	d0,(a6)					; Set ID

@NotMax:
@NotRight:
		btst	#6,($FFFFF605).w		; Is the A button pressed?
		beq.s	@NotA					; If not, branch

		moveq	#0,d0					; Set up for an array of addresses according to the sound type
		move.b	snd_type(a5),d0
		add.w	d0,d0
		add.w	d0,d0

		tst.b	stop_flag(a5)			; Is the stop ID enabled?
		beq.s	@NoStopFlag4			; If not, branch

		cmpi.b	#$FF,(a6)				; Is the current ID the stop ID?
		bne.s	@NoStopFlag4			; If not, branch

		lea	(SndTest_StopAddrs).l,a0	; Go to the appropiate address for stopping sound and jump there
		movea.l	(a0,d0.w),a0
		jsr	(a0)

		bra.s	@Continue				; Continue on to check for the B button
		
@NoStopFlag4:
		lea	(SndTest_PlayAddrs).l,a0	; Go to the appropiate address for playing sound and jump there
		movea.l	(a0,d0.w),a0
		jsr	(a0)
	
@Continue:	
@NotA:
		btst	#4,($FFFFF605).w		; Is the B button pressed?
		beq.s	@NotB					; If not, branch
		jmp	StartLvlSelect				; Go back to the level select
		
@NotB:
		bsr.w	DrawSndTestText			; Redraw the text
		bra.w	SndTest_MainLoop		; Loop
; ===========================================================================
; Subroutines for stopping sound
; ===========================================================================
; Stop music
; ===========================================================================
SndTest_StopMusic:
		tst.b	($FFFFFFB5).w			; Is music playing?
		beq.s	SndTest_Null			; If not, skip
		move.w	#0,($FFFFFFA2).w

		bsr.w	SndTest_InfoNothing

		move.b	#$FF,d0					; Stop sound
		jmp	PlaySound_Special
; ===========================================================================
; Stopping SFX subroutine doesn't exist
; ===========================================================================
SndTest_Null:
		rts
; ===========================================================================
; Stop PCM
; ===========================================================================
SndTest_StopPCM:
		tst.b	($FFFFFFB5).w			; Is music playing?
		bne.s	@End					; If so, skip
		stopZ80							; Stop PCM
		move.b	#$80,($A01FFF).l
		startZ80
		nop
		nop
		nop
		
@End:
		rts
; ===========================================================================
; Subroutines for playing sound
; ===========================================================================
; Play music
; ===========================================================================
SndTest_PlayMusic:
		stopZ80							; Stop PCM so it doesn't get in the way of the music
		move.b	#$80,($A01FFF).l
		startZ80
		nop
		nop
		nop

		move.b	#1,($FFFFFFB5).w		; Set the music playing flag
		move.w	#1,($FFFFFFA2).w

		move.w	#$4000,d1
		move.l	#$47800003,($C00004).l	; Apply VDP command
		lea	(SndTest_SongNames).l,a0	; Set the text address
		moveq	#0,d0
		move.b	(a6),d0
		mulu.w	#(42*3),d0
		adda.l	d0,a0
		move.l	a0,a4
		bsr.w	DrawText				; Draw the text

		move.l	a4,a0
		adda.w	#42,a0
		move.l	#$49800003,($C00004).l	; Apply VDP command
		bsr.w	DrawText				; Draw the text

		move.l	a4,a0
		adda.w	#(42*2),a0
		move.l	#$4B800003,($C00004).l	; Apply VDP command
		bsr.w	DrawText				; Draw the text

		moveq	#0,d0					; Get the current ID and apply the modifier
		move.b	(a6),d0
		add.b	id_mod(a5),d0
		
		cmpi.b	#$A0,d0					; Is the ID $A0 or greater
		bcs.s	@Normal					; If not, branch
		
		addi.b	#$31,d0					; Modify the ID to use the other music IDs
		
@Normal:
		jmp	PlaySound					; Play the music
; ===========================================================================
; Play SFX
; ===========================================================================
SndTest_PlaySFX:
		moveq	#0,d0					; Get the current ID and apply the modifier
		move.b	(a6),d0
		add.b	id_mod(a5),d0

		jmp	PlaySound_Special			; Play the sound
; ===========================================================================
; Play PCM
; ===========================================================================
SndTest_PlayPCM:
		move.b	#$FF,d0
		jsr	PlaySound_Special
		
		bsr.w	SndTest_InfoNothing

		moveq	#0,d0					; Get the current ID and apply the modifier
		move.b	(a6),d0
		add.b	id_mod(a5),d0
		
		move.b	#0,($FFFFFFB5).w		; Clear the music playing flag
		move.w	#0,($FFFFFFA2).w

		jmp	PlaySample					; Play the PCM
; ===========================================================================
SndTest_GetAddrs:
		moveq	#0,d0
		move.b	($FFFFFFB0).w,d0		; Get current sound test selection
		
SndTest_GetSettingsAddr:
		mulu.w	#snd_setting_size,d0	; Multiply it by the size of one set of settings
		lea	(SndTest_Settings).l,a5		; Base address for settings
		adda.l	d0,a5					; a5 = Address for settings
		movea.l	ram_addr(a5),a6			; a6 = RAM address for sound ID
		rts								; Return
; ===========================================================================
; Draw the sound test text
; ===========================================================================
DrawSndTestText:
		moveq	#2,d5					; Draw 3 lines
		
@Draw:
		moveq	#0,d0					; Get the settings address for the current line
		move.b	d5,d0
		bsr.s	SndTest_GetSettingsAddr

		move.w	#$2000,d1				; If not highlighted, use the 2nd palette line
		move.b	($FFFFFFB0).w,d6
		cmp.b	d5,d6					; Is the current line highlighted?
		bne.s	@NotHighlight			; If not, branch
		move.w	#$4000,d1				; If so, use the 3rd palette line
		
@NotHighlight:
		move.l	text_vdp_cmd(a5),($C00004).l	; Apply VDP command
		movea.l	snd_text_addr(a5),a0	; Set the text address
		bsr.s	DrawText				; Draw the text

		move.b	(a6),d0					; Get the current ID
		tst.b	stop_flag(a5)			; Is the stop ID enabled?
		beq.s	@Number					; If not, draw the ID number
		cmpi.b	#$FF,d0					; Is the current ID the stop ID?
		bne.s	@Number					; If not, branch
		lea	(Txt_Stop).l,a0				; Draw the stop text
		bsr.w	DrawText
		bra.s	@Loop					; Draw the next line

@Number:
		addq.b	#1,d0
		move.b	d0,d2					; Save ID into d2
		lsr.b	#4,d0					; Get high nibble
		bsr.s	DrawHexNumber			; Draw that
		move.b	d2,d0					; Restore ID from d2
		bsr.s	DrawHexNumber			; Draw the lower nibble
		move.l	#0,($C00000).l			; Draw 2 blank spaces (so that the stop text doesn't remain drawn)

@Loop:
		dbf	d5,@Draw					; Loop until finished
		rts								; Return
; ===========================================================================
; Draw a line of text
; ARGUMENTS:
; a0 - Address of text
; d1 - Tile modifier
; ===========================================================================
DrawText:
		moveq	#0,d0					; Clear d0
		move.b	(a0)+,d0				; Get the current character
		cmpi.b	#$20,d0					; Is it a space?
		beq.s	@DrawSpace				; If so, draw a blank tile
		tst.b	d0						; Is it the terminate character?
		beq.s	@End					; If so, stop drawing text
		
@Draw:
		ext.w	d0						; Extend d0 into a word
		add.w	d1,d0					; Apply any modifiers to d0
		move.w	d0,($C00000).l			; Draw that
		bra.s	DrawText				; Loop until the current character is the terminate character
		
@DrawSpace:
		moveq	#0,d0					; Blank tile ID
		bra.s	@Draw					; Draw that
		
@End:
		rts								; Return
; ===========================================================================
; Draw a number
; ARGUMENTS:
; d0 - Value
; d1 - Tile modifier
; ===========================================================================
DrawHexNumber:
		andi.w	#$F,d0					; Only get lower nibble
		cmpi.w	#$A,d0					; Is it greater or equal to $A?
		bcs.s	@NotAtoF				; If not, branch
		addi.w	#7,d0					; Modify the value to draw A, B, C, D, E, or F

@NotAtoF:
		addi.w	#$30,d0					; Modify it to use the correct tiles
		or.w	d1,d0					; Apply any modifiers to d0
		move.w	d0,($C00000).l			; Draw that
		rts								; Return
; ===========================================================================
; Do deform
; ===========================================================================
SndTest_Deform:
		lea	($FFFFCC00).w,a0
		move.w	#1,d4
		move.w	#31,d5
		move.w	#6,d6
		
@Deform:
		move.w	($FFFFFFA0).w,d0
		muls.w	d4,d0
		bmi.s	@Pos
		subi.w	#54,d0
		
@Pos:
		move.w	#0,(a0)+
		move.w	d0,(a0)+
		dbf	d5,@Deform
		neg.w	d4
		move.w	#31,d5
		dbf	d6,@Deform
		rts
; ===========================================================================
; Replace song info with "Nothing"
; ===========================================================================
SndTest_InfoNothing:
		move.w	#$4000,d1
		move.l	#$47800003,($C00004).l	; Apply VDP command
		lea	(SndTest_SongNothing).l,a0	; Set the text address
		bsr.w	DrawText
		move.l	#$49800003,($C00004).l	; Apply VDP command
		lea	(SndTest_SongNothing).l,a0	; Set the text address
		bsr.w	DrawText
		move.l	#$4B800003,($C00004).l	; Apply VDP command
		lea	(SndTest_SongNothing).l,a0	; Set the text address
		bra.w	DrawText
; ===========================================================================
; Song names
; ===========================================================================
SndTest_SongNames:
		dc.b "        MIND IN THE GUTTER PART I       ",0,0		; 81
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "            I DIED ON JEOPARDY          ",0,0		; 82
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "          TUTORIAL WITH ATTITUDE        ",0,0		; 83
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "  THIS SONG HAS NO TITLE AND IS UNUSED  ",0,0		; 84
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "                BAKASONIC               ",0,0
		dc.b "         IM AN EDGY MOTHERFUCKER        ",0,0		; 85
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "            GET THAT ELEPHANT           ",0,0		; 86
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "      INVINCIBILITY JEOPARDY THEME      ",0,0		; 87
		dc.b "               MERV GRIFFIN             ",0,0
		dc.b "                 JEOPARDY               ",0,0
		dc.b "             RAT TATA TAT TAT           ",0,0		; 88
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "             AURORA NUMERIQUE           ",0,0		; 89
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "              JEOPARDY THEME            ",0,0		; 8A
		dc.b "               MERV GRIFFIN             ",0,0
		dc.b "                 JEOPARDY               ",0,0
		dc.b "          PICK AN OPTION ALREADY        ",0,0		; 8B
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "               DEATH MARCH              ",0,0		; 8C
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "           CRANK THE DIAL TO 11         ",0,0		; 8D
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "             LOVER WENT RIGHT           ",0,0		; 8E
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "              DEATH SEGMENT             ",0,0		; 8F
		dc.b "               SEIJI MOMOI              ",0,0
		dc.b "            DAIKAIJUU DEBURAS           ",0,0
		dc.b "           WILT THOU CONTINUE           ",0,0		; 90
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "                BAKASONIC               ",0,0
		dc.b "     FLICKY TITLE (BAKAYOTE ARGMT.)     ",0,0		; 91
		dc.b "                TS MUSIC                ",0,0
		dc.b "                 FLICKY                 ",0,0
		dc.b "            I CANNOT BREATHE            ",0,0		; 92
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "                BAKASONIC               ",0,0
		dc.b "              CHAOS EMERALD             ",0,0		; 93
		dc.b "             MASATO NAKAMURA            ",0,0
		dc.b "           SONIC THE HEDGEHOG           ",0,0
		dc.b "            OWARISOFT JINGLE            ",0,0		; 94
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "                OWARISOFT               ",0,0
		dc.b "            SPOONYS HANGOVER            ",0,0		; 95
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "    JOE THE HOE PART 2  FT VADAPEGA     ",0,0		; 96
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		dc.b "        MIND IN THE GUTTER PART II      ",0,0		; 97
		dc.b "       THROCKMORTON JAY 'BAKAYOTE'      ",0,0
		dc.b "            YUNDONG ZIXINGCHE           ",0,0
		even
; ===========================================================================
SndTest_SongNothing:
		dc.b "                 NOTHING                ",0
		even
; ===========================================================================
; Music text
; ===========================================================================
Txt_Music:
		dc.b "MUSIC:  ",0
		even
; ===========================================================================
; SFX text
; ===========================================================================
Txt_SFX:
		dc.b "SFX:    ",0
		even
; ===========================================================================
; PCM text
; ===========================================================================
Txt_PCM:
		dc.b "PCM:    ",0
		even
; ===========================================================================
; Stop text
; ===========================================================================
Txt_Stop:
		dc.b "XX",0
		even
; ===========================================================================
; Sound test text
; ===========================================================================
Txt_SoundTest:
		dc.b "SOUND TEST",0
		even
; ===========================================================================
; Song playing text
; ===========================================================================
Txt_SongPlaying:
		dc.b "SONG PLAYING:",0
		even
; ===========================================================================
; Artist text
; ===========================================================================
Txt_Artist:
		dc.b "ORIGINAL ARTIST:",0
		even
; ===========================================================================
; Source text
; ===========================================================================
Txt_Source:
		dc.b "ORIGINAL SOURCE:",0
		even
; ===========================================================================
; Font art
; ===========================================================================
Nem_SndTestFont:
		incbin "art/nemesis/font.bin"
		even
; ===========================================================================
; Sound test BG art
; ===========================================================================
Nem_SndTestBG:
		incbin "art/nemesis/sndtest.bin"
		even
; ===========================================================================
; Sound test BG mappings
; ===========================================================================
Map_SndTestBG:
		incbin "mappings/plane/uncompressed/sndtest.bin"
		even
; ===========================================================================
; Sound test palette
; ===========================================================================
Pal_SndTest:
		incbin "palette/sndtest.bin"
		even
; ===========================================================================
