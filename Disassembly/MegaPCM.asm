
; ===============================================================
; Mega PCM Driver Include File
; (c) 2012, Vladikcomper
; ===============================================================

; ---------------------------------------------------------------
; Variables used in DAC table
; ---------------------------------------------------------------

; flags
panLR	= $C0
panL	= $80
panR	= $40
pcm	= 0
dpcm	= 4
loop	= 2
pri	= 1

; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------

z80word macro Value
	dc.w	((\Value)&$FF)<<8|((\Value)&$FF00)>>8
	endm

DAC_Entry macro Pitch,Offset,Flags
	dc.b	\Flags			; 00h	- Flags
	dc.b	\Pitch			; 01h	- Pitch
	dc.b	(\Offset>>15)&$FF	; 02h	- Start Bank
	dc.b	(\Offset\_End>>15)&$FF	; 03h	- End Bank
	z80word	(\Offset)|$8000		; 04h	- Start Offset (in Start bank)
	z80word	(\Offset\_End-1)|$8000	; 06h	- End Offset (in End bank)
	endm
	
IncludeDAC macro Name,Extension
\Name:
	if strcmp('\extension','wav')
		incbin	'dac/\Name\.\Extension\',$3A
	else
		incbin	'dac/\Name\.\Extension\'
	endc
\Name\_End:
	endm

; ---------------------------------------------------------------
; Driver's code
; ---------------------------------------------------------------

MegaPCM:
	incbin	'MegaPCM.z80'

; ---------------------------------------------------------------
; DAC Samples Table
; ---------------------------------------------------------------

	DAC_Entry	$08, Kick, dpcm			; $81	- Kick
	DAC_Entry	$08, Snare, dpcm		; $82	- Snare
	DAC_Entry	$1B, Timpani, dpcm		; $83	- Timpani
	DAC_Entry	$08, eh, dpcm			; $84	- Streets Of Rage "Eh!"
	DAC_Entry	$01, cymbcrash, dpcm	; $85	- Cymbal Crash
	DAC_Entry	$05, nowthatsfresh, dpcm; $86	- President BPM "Now that's fresh!"
	DAC_Entry	$01, goodnight, dpcm	; $87	- Wario Ware Inc. Jimmy T. "Good Night"
	DAC_Entry	$12, Timpani, dpcm		; $88	- Hi-Timpani
	DAC_Entry	$15, Timpani, dpcm		; $89	- Mid-Timpani
	DAC_Entry	$1B, Timpani, dpcm		; $8A	- Mid-Low-Timpani
	DAC_Entry	$1D, Timpani, dpcm		; $8B	- Low-Timpani
	DAC_Entry	$03, sega, pcm			; $8C   - Sega
	DAC_Entry	$09, laughing, dpcm		; $8D	- SegaSonic Robotnik Laughing
	DAC_Entry	$09, go, dpcm			; $8E	- Andrew Hockenberg "Go"
	DAC_Entry	$1B, knockhimout, dpcm	; $8F	- Punch Out Arcade "Knock Him Out"
	DAC_Entry	$09, sa2robovoice, dpcm	; $90	- Sonic Adventure 2 "Hip Hop, House, Techno"
	DAC_Entry	$09, joholoop1, dpcm	; $91	- Joe The Ho Drum Loop 1
	DAC_Entry	$09, joholoop2, dpcm	; $92	- Joe The Ho Drum Loop 2
	DAC_Entry	$09, johorap1, dpcm		; $93	- Joe The Ho Rap 1
	DAC_Entry	$09, johorap2, dpcm		; $94	- Joe The Ho Rap 2
	DAC_Entry	$09, johorap3, dpcm		; $95	- Joe The Ho Rap 3
	DAC_Entry	$09, johorap4, dpcm		; $96	- Joe The Ho Rap 4
	DAC_Entry	$09, johocmon, dpcm		; $97	- Joe The Ho Drum Loop Vada Break
	DAC_Entry	$08, EggmanScream, pcm+pri	; $98	- Eggman screaming

MegaPCM_End:

; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

	IncludeDAC	Kick, bin
	IncludeDAC	Snare, bin
	IncludeDAC	Timpani, bin
	IncludeDAC	eh, bin
	IncludeDAC	cymbcrash, bin
	IncludeDAC	nowthatsfresh, bin
	IncludeDAC	goodnight, bin
	IncludeDAC	laughing, bin
	IncludeDAC	go, bin
	IncludeDAC	knockhimout, bin
	IncludeDAC  sega, raw
	IncludeDAC  sa2robovoice, bin
	IncludeDAC  joholoop1, bin
	IncludeDAC  joholoop2, bin
	IncludeDAC  johorap1, bin
	IncludeDAC  johorap2, bin
	IncludeDAC  johorap3, bin
	IncludeDAC  johorap4, bin
	IncludeDAC  johocmon, bin
	IncludeDAC  EggmanScream, wav
	even

