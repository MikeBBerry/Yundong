; ===========================================================================
; Flicky Special Stage
; Currently unoptimized and incomplete
; ===========================================================================
FlickySS:
		move.b	#CmdID_Stop,d0			; Stop music
		jsr	PlaySound_Special
		jsr	ClearPLC					; Clear PLCS
		jsr	Pal_FadeFrom				; Fade palette
		
		bsr.w	Flicky_LoadSoundDriver
		
		move	#$2700,sr				; Stop interrupts
		
		move.w	(VDP_Reg_1_Value).w,d0		; Disable screen
		andi.b	#$BF,d0
		move.w	d0,($C00004).l
		
		jsr	ClearScreen					; Clear screen
		
		lea	($C00004).l,a6
		move.w	#$9000,(a6)
		move.w	#$8C00,(a6)
		move.w	#$8B00,(a6)
		
		move.l	#$72400002,($C00004).l
		lea	(Nem_FlickyPlayer).l,a0
		jsr	NemDec
		
		lea	(Object_RAM).w,a0			; Clear object RAM
		move.w	#(Object_RAM_End-Object_RAM)>>2-1,d1
		
@ClearObj:
		move.l	#0,(a0)+
		dbf	d1,@ClearObj
		
		move.l	#0,(Camera_X_Pos).w		; Clear camera RAM
		move.l	#0,(Camera_Y_Pos).w
		
		move.b	#0,(Flicky_Door_Flag).w
		
		move.b	#$8D,(Object_Space_1).w		; Load flicky object
		move.b	#$90,(Object_Space_2).w
		move.w	#128,(Object_Space_2+8).w
		move.w	#192,(Object_Space_2+$C).w
		
		bsr.w	Flicky_LoadObjects
		jsr	ObjectsLoad					; Run objects
		jsr	BuildSprites				; Render sprites
		
		move.l	#$40000001,($C00004).l
		lea	(Nem_FlickyLevel).l,a0
		jsr	NemDec
		
		lea	(Map_FlickyLevel1).l,a1
		bsr.w	Flicky_LoadLevelMap
		
		lea	(Pal_Flicky).l,a0 
		lea	(Target_Palette).w,a1
		moveq  #$F,d0

@PalLoop:
		move.l (a0)+,(a1)+
		move.l (a0)+,(a1)+
		dbf    d0,@PalLoop
		
		move.w	(Camera_X_Pos).w,d0
		andi.w	#$FF,d0
		move.w	d0,(Camera_X_Pos).w
		neg.w	d0
		move.w	d0,(Horiz_Scroll_Buf+2).w
		
		move.w	#$83,d0
		bsr.w	Flicky_PlaySound
		
		move.w	(VDP_Reg_1_Value).w,d0		; Enable screen
		ori.b	#$40,d0
		move.w	d0,($C00004).l
		
		jsr	Pal_FadeTo					; Fade to palette

@Loop:
		move.b	#2,(V_Int_Routine).w		; Run V-INT subroutine 2
		jsr	DelayProgram
		
		tst.w	(Flicky_Chicks_Following).w
		bne.s	@ChickFollow
		move.b	#0,(Flicky_Door_Flag).w
		
@ChickFollow:
		jsr	ObjectsLoad					; Run objects
		jsr	BuildSprites				; Render sprites
		
		jsr	HandleChicks
		
		move.w	(Camera_X_Pos).w,d0
		andi.w	#$FF,d0
		move.w	d0,(Camera_X_Pos).w
		neg.w	d0
		move.w	d0,(Horiz_Scroll_Buf+2).w
		
		tst.w	(Flicky_Chicks_Left).w
		beq.s	@End
		cmpi.b	#$10,(Game_Mode).w
		beq.s	@Loop
		
@End:
		move.b	#$C,(Game_Mode).w
		jsr	ClearScreen
		
		move.w	#$9001,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8C81,(a6)
		
		bsr.w	ClearZ80RAM
		jsr	InitMegaPCM
		
		rts
; ===========================================================================
; Handle the chicks
; ===========================================================================
HandleChicks:
		moveq	#0,d3
		moveq	#0,d4
		lea	(Dynamic_Object_RAM).w,a1
		move.w	#((Dynamic_Object_RAM_End-Dynamic_Object_RAM)/$40)-1,d1
		move.w	#$1C,d0
		
@Check:
		cmpi.b	#$8F,(a1)
		bne.s	@Skip2
		addq.w	#1,d3
		cmpi.b	#4,$24(a1)
		bne.s	@Skip2
		addq.w	#1,d4
		tst.b	(Flicky_Door_Flag).w
		bne.s	@Skip2
		move.w	(Sonic_Pos_Record_Index).w,d2
		sub.w	d0,d2
		bpl.s	@Skip
		add.w	#$100,d2
		
@Skip:
		lea	(Sonic_Pos_Record_Buf).w,a0
		lea	(a0,d2.w),a0
		move.w	(a0)+,8(a1)
		move.w	(a0)+,$C(a1)
		addi.w	#$1C,d0
		
@Skip2:
		lea	$40(a1),a1
		dbf	d1,@Check
		move.w	d3,(Flicky_Chicks_Left).w
		move.w	d4,(Flicky_Chicks_Following).w
		rts
; ===========================================================================
; Load mappings
; ===========================================================================
Flicky_LoadLevelMap:
		move.l	#$60000003,($C00004).l
		move.w	#$37F,d3

@Load:
		move.w	(a1)+,($C00000).l
		dbf	d3,@Load
		rts
; ===========================================================================
; Load objects
; ===========================================================================
Flicky_LoadObjects:
		lea	(Dynamic_Object_RAM).w,a0
		lea	(Flicky_Objects).l,a1
		move.w	#(Flicky_Objects_End-Flicky_Objects)/6-1,d1
		
@Load:
		move.w	(a1)+,d0
		move.b	d0,(a0)
		move.w	(a1)+,8(a0)
		move.w	(a1)+,$C(a0)
		lea	$40(a0),a0
		dbf	d1,@Load
		rts
; ===========================================================================		
Flicky_Objects:
		dc.w $8F, 95, 81
		dc.w $8F, 95+48, 81
Flicky_Objects_End:
; ===========================================================================
; Collision response routine for the player
; ===========================================================================
Flicky_ColResponse:
		lea	(Object_Space_2).w,a1
		move.w	#(Object_RAM_End-Object_Space_2)/$40-1,d6
		
@Loop:
		move.w	8(a0),d0
		add.w	$20(a0),d0
		move.w	8(a1),d1
		cmp.w	d0,d1
		bgt.s	@DoLoop
		sub.w	$20(a0),d0
		add.w	$20(a1),d1
		cmp.w	d0,d1
		blt.s	@DoLoop
		move.w	$C(a0),d0
		add.w	$22(a0),d0
		move.w	$C(a1),d1
		cmp.w	d0,d1
		bgt.s	@DoLoop
		sub.w	$22(a0),d0
		add.w	$22(a1),d1
		cmp.w	d0,d1
		blt.s	@DoLoop
		
		cmpi.b	#$8E,(a1)
		beq.s	@Cat
		cmpi.b	#$8F,(a1)
		beq.s	@Chick
		cmpi.b	#$90,(a1)
		beq.s	@Door
		
@DoLoop:
		lea	$40(a1),a1
		dbf	d6,@Loop
		rts
		
@Cat:
		cmpi.b	#$8F,(a0)
		beq.s	@Cat_Chick
		move.b	#4,$24(a0)
		move.w	#0,$10(a0)
		bra.s	@DoLoop
		
@Cat_Chick:
		move.b	#6,$24(a0)
		bra.s	@DoLoop
		
@Chick:
		cmpi.b	#$8F,(a0)
		beq.s	@DoLoop
		cmpi.b	#4,$24(a1)
		beq.s	@DoLoop
		move.b	#4,$24(a1)
		bra.s	@DoLoop
		
@Door:
		cmpi.b	#$8F,(a0)
		beq.s	@Door_Chick
		move.b	#1,(Flicky_Door_Flag).w
		bra.s	@DoLoop
		
@Door_Chick:
		move.b	#8,$24(a0)
		
@Skip:
		bra.s	@DoLoop
; ===========================================================================
; Chick object
; ===========================================================================
ObjChick:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjChick_Index(pc,d0.w),d0
		jmp	ObjChick_Index(pc,d0.w)
; ===========================================================================
ObjChick_Index:
		dc.w ObjChick_Init-ObjChick_Index
		dc.w ObjChick_Main-ObjChick_Index
		dc.w ObjChick_Follow-ObjChick_Index
		dc.w ObjChick_Unfollow-ObjChick_Index
		dc.w ObjChick_Delete-ObjChick_Index
; ===========================================================================
ObjChick_Init:
		addq.b	#2,$24(a0)
		move.b	#12,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_Flicky,4(a0)
		move.w	#$592,2(a0)
		move.b	#2,$18(a0)
		move.b	#4,1(a0)
		move.w	#$F,$20(a0)
		move.w	#$F,$22(a0)
		move.w	#$10,$32(a0)
; ===========================================================================
ObjChick_Main:
		andi.w	#$FF,8(a0)
		jmp	DisplaySprite
; ===========================================================================
ObjChick_Follow:
		jsr	Flicky_ColResponse
		
		tst.b	(Flicky_Door_Flag).w
		bne.s	ObjChick_Door
		cmpi.b	#4,(Object_Space_1+$24).w
		bne.s	@Skip
		move.b	#6,$24(a0)
		
	@Skip:
		andi.w	#$FF,8(a0)
		jmp	DisplaySprite
; ===========================================================================
ObjChick_Door:
		move.w	8(a0),d0
		move.w	(Object_Space_2+8).w,d1
		move.w	#$100,d2
		cmp.w	d1,d0
		blt.s	@Skip
		neg.w	d2
		
@Skip:
		move.w	d2,$10(a0)
; ===========================================================================
ObjChick_Unfollow:
		jsr	ObjectMove
		jsr	Flicky_DoCollision
		andi.w	#$FF,8(a0)
		jmp	DisplaySprite
; ===========================================================================
ObjChick_Delete:
		move.w	#$94,d0
		bsr.w	Flicky_PlaySound
		jmp	DeleteObject
; ===========================================================================
; Cat object
; ===========================================================================
ObjCat:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjCat_Index(pc,d0.w),d0
		jmp	ObjCat_Index(pc,d0.w)
; ===========================================================================
ObjCat_Index:
		dc.w ObjCat_Init-ObjCat_Index
		dc.w ObjCat_Main-ObjCat_Index
; ===========================================================================
ObjCat_Init:
		addq.b	#2,$24(a0)
		move.b	#12,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_Flicky,4(a0)
		move.w	#$592,2(a0)
		move.b	#2,$18(a0)
		move.b	#4,1(a0)
		move.w	#$D,$20(a0)
		move.w	#$F,$22(a0)
		move.w	#$18,$32(a0)
		move.w	#-$100,$10(a0)
; ===========================================================================
ObjCat_Main:
		tst.b	(Flicky_Door_Flag).w
		bne.s	@Skip
		jsr	ObjectMove
		jsr	Flicky_DoCollision
		bsr.s	ObjCat_Movement
		
@Skip:
		andi.w	#$FF,8(a0)
		jmp	DisplaySprite
; ===========================================================================
ObjCat_Movement:
		tst.b	$2E(a0)
		bne.s	@SkipClr
		move.b	#0,$2F(a0)
		
@SkipClr:
		cmpi.b	#1,$2F(a0)
		beq.w	@DoDelay
		tst.b	$2F(a0)
		bne.w	@Skip2
		tst.b	$2E(a0)
		beq.w	@Skip
		
		cmpi.w	#172,$C(a0)
		blt.w	@Normal
		cmpi.w	#190,(Object_Space_1+$C).w
		bge.w	@Skip
		tst.w	$10(a0)
		bmi.s	@ChkLeft2
		cmpi.w	#180,8(a0)
		blt.w	@Skip
		move.b	#1,$2F(a0)
		move.b	#30,$30(a0)
		bra.w	@Skip
		
	@ChkLeft2:
		cmpi.w	#80,8(a0)
		bgt.w	@Skip
		move.b	#1,$2F(a0)
		move.b	#30,$30(a0)
		bra.w	@Skip
		
	@Normal:
		tst.w	$10(a0)
		bmi.s	@ChkLeft
		move.w	8(a0),d0
		add.w	$20(a0),d0
		addq.w	#1,d1
		move.w	$C(a0),d1
		addq.w	#2,d1
		move.w	#1,d2
		move.w	$22(a0),d3
		bsr.w	Flicky_ChkCollision
		bne.s	@Skip
		move.b	#1,$2F(a0)
		move.b	#30,$30(a0)
		bra.s	@Skip
		
	@ChkLeft:
		move.w	8(a0),d0
		subq.w	#1,d0
		move.w	$C(a0),d1
		addq.w	#2,d1
		move.w	#1,d2
		move.w	$22(a0),d3
		bsr.w	Flicky_ChkCollision
		bne.s	@Skip
		move.b	#1,$2F(a0)
		move.b	#30,$30(a0)
		
	@Skip:
		tst.b	$2F(a0)
		beq.s	@Skip2
		
	@DoDelay:
		move.w	#0,$10(a0)
		subq.b	#1,$30(a0)
		bpl.s	@Skip2
		move.w	#-$260,d0
		move.w	$C(a0),d1
		move.w	(Object_Space_1+$C).w,d2
		cmp.w	d2,d1
		bge.s	@Apply
		move.w	#0,d0
		
	@Apply:
		move.w	d0,$12(a0)
		move.w	#-$100,$10(a0)
		move.b	#2,$2F(a0)
		
	@Skip2:
		rts
; ===========================================================================
; Flicky object
; ===========================================================================
ObjFlicky:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjFlicky_Index(pc,d0.w),d0
		jmp	ObjFlicky_Index(pc,d0.w)
; ===========================================================================
ObjFlicky_Index:
		dc.w ObjFlicky_Init-ObjFlicky_Index
		dc.w ObjFlicky_Main-ObjFlicky_Index
		dc.w ObjFlicky_Dead-ObjFlicky_Index
; ===========================================================================
ObjFlicky_Init:
		addq.b	#2,$24(a0)
		move.b	#12,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_Flicky,4(a0)
		move.w	#$592,2(a0)
		move.b	#2,$18(a0)
		move.b	#4,1(a0)
		
		move.w	#9,$20(a0)
		move.w	#$F,$22(a0)
		move.w	#$10,$32(a0)
		
		move.w	#128,8(a0)
		move.w	#192,$C(a0)
		
		move.w	#$180,(Sonic_Top_Speed).w
		move.w	#$18,(Sonic_Acceleration).w
		move.w	#6,(Sonic_Deceleration).w
; ===========================================================================
ObjFlicky_Main:
		tst.b	(Flicky_Door_Flag).w
		bne.s	@Skip
		jsr	ObjectMove
		jsr	Sonic_RecordPos
		jsr	Flicky_DoCollision
		jsr	ObjFlicky_Jump
		jsr	ObjFlicky_Move
		jsr	Flicky_ColResponse
		
@Skip:
		andi.w	#$FF,8(a0)
		
		move.w	8(a0),d0
		subi.w	#128,d0
		move.w	d0,(Camera_X_Pos).w
		
		jmp	DisplaySprite
; ===========================================================================
ObjFlicky_Jump:
		tst.b	$2E(a0)
		beq.s	@NoJump
		tst.b	$2D(a0)
		bne.s	@NoJump
		move.b	(Ctrl_1_Press).w,d0
		andi.b	#$70,d0
		beq.w	@NoJump
		
		move.w	#$91,d0
		bsr.w	Flicky_PlaySound
		
		move.w	#-$2A0,$12(a0)
		move.b	#1,$2D(a0)
		
@NoJump:
		rts
; ===========================================================================	
ObjFlicky_Move:
		move.w	(Sonic_Top_Speed).w,d6
		move.w	(Sonic_Acceleration).w,d5
		move.w	(Sonic_Deceleration).w,d4
		btst	#2,(Ctrl_1_Held).w
		beq.s	ObjFlicky_NotLeft
		;bset	#0,1(a0)
		bra.w	ObjFlicky_MoveLeft

ObjFlicky_NotLeft:
		btst	#3,(Ctrl_1_Held).w
		beq.s	ObjFlicky_NotRight
		;bclr	#0,1(a0)
		bra.w	ObjFlicky_MoveRight
; ===========================================================================
ObjFlicky_NotRight:
		tst.b	$2E(a0)
		beq.s	@End
		move.w	$10(a0),d0
		bpl.s	@NotNeg
		neg.w	d0
		
@NotNeg:
		sub.w	d4,d0
		bpl.s	@Not0OrNeg
		move.w	#0,d0
		
@Not0OrNeg:
		tst.w	$10(a0)
		bpl.s	@NotNeg2
		neg.w	d0
		
@NotNeg2:
		move.w	d0,$10(a0)
		
@End:
		rts
; ===========================================================================
ObjFlicky_MoveLeft:
		move.w	$10(a0),d0
		sub.w	d5,$10(a0)
		neg.w	d6
		cmp.w	d6,d0
		bge.s	@NotMax
		move.w	d6,$10(a0)
		
@NotMax:
		neg.w	d6
		rts
; ===========================================================================
ObjFlicky_MoveRight:
		move.w	$10(a0),d0
		add.w	d5,$10(a0)
		cmp.w	d6,d0
		ble.s	@NotMax
		move.w	d6,$10(a0)
		
@NotMax:
		rts
; ===========================================================================
ObjFlicky_Dead:
		jsr	ObjectMove
		jsr	Flicky_DoCollision
		
		andi.w	#$FF,8(a0)
		
		move.w	8(a0),d0
		subi.w	#128,d0
		move.w	d0,(Camera_X_Pos).w
		
		tst.b	$2E(a0)
		beq.s	@Skip
		move.b	#$C,(Game_Mode).w
		
@Skip:
		jmp	DisplaySprite
; ===========================================================================
Flicky_DoCollision:
		tst.w	$12(a0)
		beq.s	@ChkDown
		bmi.s	@ChkUp
		
@ChkDown:
		move.w	8(a0),d0
		addq.w	#1,d1
		move.w	$C(a0),d1
		addq.w	#1,d1
		move.w	$20(a0),d2
		subq.w	#2,d2
		move.w	$22(a0),d3
		bsr.w	Flicky_ChkCollision
		move.b	d0,$2C(a0)
		beq.s	@End
		move.w	#0,$12(a0)
		andi.w	#$FFF8,$C(a0)
		subq.w	#1,$C(a0)
		move.b	#0,$2D(a0)
		bra.s	@End

@ChkUp:
		move.w	8(a0),d0
		addq.w	#1,d1
		move.w	$C(a0),d1
		subq.w	#1,d1
		move.w	$20(a0),d2
		subq.w	#2,d2
		move.w	$22(a0),d3
		bsr.w	Flicky_ChkCollision
		move.b	d0,$2C(a0)
		beq.s	@End
		move.w	#0,$12(a0)
		addq.w	#1,$C(a0)

@End:
		move.w	8(a0),d0
		addq.w	#1,d1
		move.w	$C(a0),d1
		addq.w	#2,d1
		move.w	$20(a0),d2
		subq.w	#2,d2
		move.w	$22(a0),d3
		bsr.w	Flicky_ChkCollision
		move.b	d0,$2E(a0)
		
		tst.b	$2E(a0)
		bne.s	@Cont
		cmpi.w	#$300,$12(a0)
		blt.s	@Add
		move.w	#$300,$12(a0)
		bra.s	@Cont
		
@Add:
		move.w	$32(a0),d0
		add.w	d0,$12(a0)

@Cont:
		rts
; ===========================================================================
; d0 = Starting x
; d1 = Starting y
; d2 = Width
; d3 = Height
; ===========================================================================
Flicky_ChkCollision:
		move.w	d0,d4
		add.w	d2,d4
		move.w	d1,d5
		add.w	d3,d5
		andi.w	#$FFF8,d0
		move.w	d0,d2
		andi.w	#$FFF8,d1
		sub.w	d0,d4
		sub.w	d1,d5
		lsr.w	#3,d4
		move.w	d4,d3
		lsr.w	#3,d5
		
@Chk:
		movem.l	d0-d1,-(sp)
		bsr.w	Flicky_GetCollisionFlag
		bne.s	@End
		movem.l	(sp)+,d0-d1
		addq.w	#8,d0
		dbf	d4,@Chk
		move.w	d2,d0
		move.w	d3,d4
		addq.w	#8,d1
		dbf	d5,@Chk
		moveq	#0,d0
		rts
		
@End:
		movem.l	(sp)+,d0-d1
		moveq	#1,d0
		rts
; ===========================================================================
Flicky_GetCollisionFlag:
		tst.w	d0
		bpl.s	@ChkMaxX
		move.w	#0,d0

@ChkMaxX:
		cmpi.w	#256,d0
		blt.s	@SkipChk
		move.w	#0,d0
		
@SkipChk:
		andi.w	#$FFF8,d1
		lsl.w	#2,d1
		andi.w	#$FFF8,d0
		lsr.w	#3,d0
		add.w	d1,d0
		lea	(Col_FlickyLevel1).l,a1
		adda.w	d0,a1
		move.b	(a1),d0
		rts
; ===========================================================================
; Door
; ===========================================================================
ObjDoor:
		moveq	#0,d0
		move.b	$24(a0),d0
		move.w	ObjDoor_Index(pc,d0.w),d0
		jmp	ObjDoor_Index(pc,d0.w)
; ===========================================================================
ObjDoor_Index:
		dc.w ObjDoor_Init-ObjDoor_Index
		dc.w ObjDoor_Main-ObjDoor_Index
; ===========================================================================
ObjDoor_Init:
		addq.b	#2,$24(a0)
		move.b	#12,$16(a0)
		move.b	#8,$17(a0)
		move.l	#Map_Flicky,4(a0)
		move.w	#$592,2(a0)
		move.b	#2,$18(a0)
		move.b	#4,1(a0)
		
		move.w	#8,$20(a0)
		move.w	#16,$22(a0)
; ===========================================================================
ObjDoor_Main:
		rts
; ===========================================================================
; Level art
; ===========================================================================
Nem_FlickyLevel:
		incbin "art/nemesis/flicky_lvl.bin"
		even
; ===========================================================================
; Player
; ===========================================================================
Nem_FlickyPlayer:
		incbin "art/nemesis/flicky_game.bin"
		even
; ===========================================================================
; Player mappings
; ===========================================================================
Map_Flicky:
		include "mappings/sprite/flicky.asm"
		even
; ===========================================================================
; Palette
; ===========================================================================
Pal_Flicky:
		incbin "palette/flicky.bin"
		even
; ===========================================================================
; Level mappings
; ===========================================================================
Map_FlickyLevel1:
		incbin "mappings/plane/uncompressed/flicky_lvl1.bin"
		even
; ===========================================================================
; Level 1 collision
; ===========================================================================
Col_FlickyLevel1:
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
		even
; ===========================================================================
; Flicky sound driver
; ===========================================================================
Flicky_LoadSoundDriver:
		bsr.w	ClearZ80RAM
		
		nop
		move.w	#$100,d0
		move.w	d0,($A11100).l
		move.w	d0,($A11200).l

		lea	($A00000).l,a0
		lea	(Z80_FlickySndDrv).l,a1
		move.w	#(Z80_FlickySndDrv_End-Z80_FlickySndDrv)-1,d1
		
@Load:
		move.b	(a1)+,(a0)+
		dbf	d1,@Load
		
		lea	($A01C00).l,a0
		lea	(Z80_FlickyCode).l,a1
		move.w	#(Z80_FlickyCode_End-Z80_FlickyCode)-1,d1
		
@Load2:
		move.b	(a1)+,(a0)+
		dbf	d1,@Load2
		
		moveq	#0,d1
		move.w	d1,($A11200).l
		nop
		nop
		nop
		nop
		move.w	d0,($A11200).l
		move.w	d1,($A11100).l
		rts
; ===========================================================================
; Play a sound via the Flicky sound driver
; ===========================================================================	
Flicky_PlaySound:
		stopZ80
		move.b	d0,($A01C09).l
		startZ80
		rts
; ===========================================================================
; Clear Z80 RAM
; ===========================================================================
ClearZ80RAM:
		stopZ80
		lea	($A00000).l,a0
		move.w	#$1FFF,d1
		
@Clear:
		move.b	#0,(a0)+
		dbf	d1,@Clear
		startZ80
		rts
; ===========================================================================
Z80_FlickySndDrv:
		incbin "sound/z80_flicky.bin"
Z80_FlickySndDrv_End:
		even
Z80_FlickyCode:
		dc.b 0, $80, 0, $12, $B4, 0, $E6, $80, $20, 0
Z80_FlickyCode_End:
; ===========================================================================
