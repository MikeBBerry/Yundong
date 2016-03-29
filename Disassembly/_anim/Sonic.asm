; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
		dc.w SonAni_Walk-SonicAniData ;0
		dc.w SonAni_Run-SonicAniData ;1
		dc.w SonAni_Blank-SonicAniData ;2
		dc.w SonAni_Blank-SonicAniData ;3
		dc.w SonAni_Push-SonicAniData ;4
		dc.w SonAni_Wait-SonicAniData ;5
		dc.w SonAni_Balance-SonicAniData ;6
		dc.w SonAni_LookUp-SonicAniData ;7
		dc.w SonAni_Duck-SonicAniData ;8
		dc.w SonAni_Bite-SonicAniData ;9
		dc.w SonAni_Blank-SonicAniData ;A
		dc.w SonAni_Blank-SonicAniData ;B
		dc.w SonAni_Blank-SonicAniData ;C
		dc.w SonAni_Stop-SonicAniData ;D
		dc.w SonAni_Float1-SonicAniData ;E
		dc.w SonAni_Float2-SonicAniData ;F
		dc.w SonAni_Spring-SonicAniData ;10
		dc.w SonAni_LZHang-SonicAniData ;11
		dc.w SonAni_Blank-SonicAniData ;12
		dc.w SonAni_Blank-SonicAniData ;13
		dc.w SonAni_Blank-SonicAniData ;14
		dc.w SonAni_Bubble-SonicAniData ;15
		dc.w SonAni_Blank-SonicAniData ;16
		dc.w SonAni_Drown-SonicAniData ;17
		dc.w SonAni_Death-SonicAniData ;18
		dc.w SonAni_Blank-SonicAniData ;19
		dc.w SonAni_Hurt-SonicAniData ;1A
		dc.w SonAni_LZSlide-SonicAniData ;1B
		dc.w SonAni_Blank-SonicAniData ;1C
		dc.w SonAni_Float3-SonicAniData ;1D
		dc.w SonAni_Float4-SonicAniData ;1E
		dc.w SonAni_Jump1-SonicAniData ;1F
		dc.w SonAni_Jump2-SonicAniData ;20
SonAni_Blank:	dc.b $77, 0, $FD, 0 ;Unused
SonAni_Walk:	dc.b $FF, 8, 9,	$A, $B,	6, 7, $FF
SonAni_Run:	dc.b $FF, $1E, $1F, $20, $21, $FF, $FF,	$FF
SonAni_Push:	dc.b $FD, $3C, $3D, $3E, $3F, $FF, $FF,	$FF
SonAni_Wait:	dc.b $17, 1, 1,	1, 1, 1, 1, 1, 1, 1, 1,	1, 1, 3, 2, 2, 2, 3, 4, $FE, 2, 0
SonAni_Balance:	dc.b $1F, $34, $35, $FF
SonAni_LookUp:	dc.b $3F, 5, $FF, 0
SonAni_Duck:	dc.b $3F, $33, $FF, 0
SonAni_Bite:	dc.b 2, 1, $2E, $2F, $30, $FD, 0
SonAni_Stop:	dc.b 7,	$31, $32, $FF
SonAni_Float1:	dc.b 7,	$36, $FF
SonAni_Float2:	dc.b 7,	$36, $37, $42, $38, $43, $FF, 0
SonAni_Spring:	dc.b $2F, $39, $FD, 0
SonAni_LZHang:	dc.b 4,	$3A, $3B, $FF
SonAni_Bubble:	dc.b $B, $46, $46, $A, $B, $FD,	0, 0
SonAni_Drown:	dc.b $2F, $40, $FF, 0
SonAni_Death:	dc.b 3,	$41, $FF, 0
SonAni_Hurt:	dc.b 7, $44, $45, $FF
SonAni_LZSlide:	dc.b 7, $44, $45, $FF
SonAni_Float3:	dc.b 3,	$36, $37, $42, $38, $43, $FF, 0
SonAni_Float4:	dc.b 3,	$36, $FD, 0 ;Unused?
SonAni_Jump1:	dc.b $C, $47, $48, $FE, 1, 0
SonAni_Jump2:	dc.b $2F, $49, $FD, 0
		even
