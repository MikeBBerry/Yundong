; ---------------------------------------------------------------------------
; Animation script - bubbles (LZ)
; ---------------------------------------------------------------------------
		dc.w byte_129AA-Ani_obj64
		dc.w byte_129B0-Ani_obj64
		dc.w byte_129B6-Ani_obj64
		dc.w byte_129BE-Ani_obj64
		dc.w byte_129BE-Ani_obj64
		dc.w byte_129C0-Ani_obj64
		dc.w byte_129C6-Ani_obj64
byte_129AA:	dc.b $E, 0, 1, 2, $FC
		even
byte_129B0:	dc.b $E, 1, 2, 3, 4, $FC
		even
byte_129B6:	dc.b $E, 2, 3, 4, 5, 6,	$FC
		even
byte_129BE:	dc.b 4,	$FC
		even
byte_129C0:	dc.b 4,	6, 7, $FC
		even
byte_129C6:	dc.b $F, $E, $F, $FF
		even