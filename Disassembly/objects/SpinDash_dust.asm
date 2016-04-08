; ===========================================================================
Obj05:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	Obj05_Index(pc,d0.w),d1
		jmp	Obj05_Index(pc,d1.w)
; ===========================================================================
Obj05_Index:
		dc.w Obj05_Init-Obj05_Index
		dc.w Obj05_Main-Obj05_Index
		dc.w Obj05_Delete-Obj05_Index
		dc.w Obj05_CheckSkid-Obj05_Index
; ===========================================================================
Obj05_Init:
		addq.b	#2,$24(a0)
		move.l	#Map_obj05,4(a0)
		ori.b	#4,1(a0)
		move.b	#1,$18(a0)
		move.b	#$10,$19(a0)
		move.w	#$7A0,2(a0)
; ===========================================================================
Obj05_Main:
		lea	($FFFFD000).w,a2
		moveq	#0,d0
		move.b	$1C(a0),d0
		add.w	d0,d0
		move.w	Obj05_DisplayModes(pc,d0.w),d1
		jmp	Obj05_DisplayModes(pc,d1.w)
; ===========================================================================
Obj05_DisplayModes:
		dc.w Obj05_Display-Obj05_DisplayModes
		dc.w Obj05_MdSplash-Obj05_DisplayModes
		dc.w Obj05_MdSpindashDust-Obj05_DisplayModes
		dc.w Obj05_MdSkidDust-Obj05_DisplayModes
; ===========================================================================
Obj05_MdSplash:
		move.w	($FFFFF646).w,$C(a0)
		tst.b	$1D(a0)
		bne.s	Obj05_Display
		move.w	8(a2),8(a0)
		move.b	#0,$22(a0)
		andi.w	#$7FFF,2(a0)
		bra.s	Obj05_Display
; ===========================================================================
Obj05_MdSpindashDust:
		cmpi.b	#4,$24(a2)
		bhs.s	Obj05_ResetDisplayMode
		tst.b	$39(a2)
		beq.s	Obj05_ResetDisplayMode
		move.w	8(a2),8(a0)
		move.w	$C(a2),$C(a0)
		move.b	$22(a2),$22(a0)
		andi.b	#1,$22(a0)
		tst.b	$34(a0)
		beq.s	loc_1DE06
		subi.w	#4,$C(a0)

loc_1DE06:
		tst.b	$1D(a0)
		bne.s	Obj05_Display
		andi.w	#$7FFF,2(a0)
		tst.w	2(a2)
		bpl.s	Obj05_Display
		ori.w	#$8000,2(a0)
; ===========================================================================
Obj05_MdSkidDust:
; ===========================================================================
Obj05_Display:
		lea	(Ani_obj05).l,a1
		jsr	AnimateSprite
		bsr.w	Obj05_LoadDustOrSplashArt
		jmp	DisplaySprite
; ===========================================================================
Obj05_ResetDisplayMode:
		move.b	#0,$1C(a0)
		rts	
; ===========================================================================
Obj05_Delete:
		bra.w	DeleteObject
; ===========================================================================
Obj05_CheckSkid:
		lea	($FFFFD000).w,a2
		cmpi.b	#$D,$1C(a2)
		beq.s	Obj05_SkidDust
		move.b	#2,$24(a0)
		move.b	#0,$32(a0)
		rts
; ===========================================================================
Obj05_SkidDust:
		subq.b	#1,$32(a0)
		bpl.s	Obj05_LoadDustOrSplashArt
		move.b	#3,$32(a0)
		jsr	SingleObjLoad
		bne.s	Obj05_LoadDustOrSplashArt
		move.b	0(a0),0(a1)
		move.w	8(a2),8(a1)
		move.w	$C(a2),$C(a1)
		addi.w	#$10,$C(a1)
		tst.b	$34(a0)
		beq.s	loc_1DE9A
		subi.w	#4,$C(a1)

loc_1DE9A:
		move.b	#0,$22(a1)
		move.b	#3,$1C(a1)
		addq.b	#2,$24(a1)
		move.l	4(a0),4(a1)
		move.b	1(a0),1(a1)
		move.b	#1,$18(a1)
		move.b	#4,$19(a1)
		move.w	2(a0),2(a1)
		andi.w	#$7FFF,2(a1)
		tst.w	2(a2)
		bpl.s	Obj05_LoadDustOrSplashArt
		ori.w	#$8000,2(a1)
; ===========================================================================
Obj05_LoadDustOrSplashArt:
		lea	(DPLC_obj05).l,a2
		move.w	#$F400,d4
		move.l	#Art_Dust,d6
		jmp	LoadDPLC
; ===========================================================================
Ani_obj05:
		dc.w Obj05Ani_Null-Ani_obj05
		dc.w Obj05Ani_Splash-Ani_obj05
		dc.w Obj05Ani_Dash-Ani_obj05
		dc.w Obj05Ani_Skid-Ani_obj05
Obj05Ani_Null:		dc.b $1F,  0,$FF
		even
Obj05Ani_Splash:	dc.b   3,  1,  2,  3,  4,  5,  6,  7,  8,  9,$FD,  0
		even
Obj05Ani_Dash:		dc.b   1, $A, $B, $C, $D, $E, $F,$10,$FF
		even
Obj05Ani_Skid:		dc.b   3,$11,$12,$13,$14,$FC
		even
; ===========================================================================
Map_obj05:
	include "mappings/sprite/obj05.asm"
; ===========================================================================
DPLC_obj05:
	include "mappings/DPLC/obj05.asm"
; ===========================================================================
