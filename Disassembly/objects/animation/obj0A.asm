; ---------------------------------------------------------------------------
; Animation script - countdown numbers and bubbles (LZ)
; ---------------------------------------------------------------------------
		dc.w byte_140D6-Ani_obj0A
		dc.w byte_140E0-Ani_obj0A
		dc.w byte_140EA-Ani_obj0A
		dc.w byte_140F4-Ani_obj0A
		dc.w byte_140FE-Ani_obj0A
		dc.w byte_14108-Ani_obj0A
		dc.w byte_14112-Ani_obj0A
		dc.w byte_14118-Ani_obj0A
		dc.w byte_14120-Ani_obj0A
		dc.w byte_14128-Ani_obj0A
		dc.w byte_14130-Ani_obj0A
		dc.w byte_14138-Ani_obj0A
		dc.w byte_14140-Ani_obj0A
		dc.w byte_14148-Ani_obj0A
		dc.w byte_1414A-Ani_obj0A
byte_140D6:	dc.b 5,  0,  1,  2,  3,  4,  8,  8,$FC
byte_140E0:	dc.b 5,  0,  1,  2,  3,  4,  9,  9,$FC
byte_140EA:	dc.b 5,  0,  1,  2,  3,  4, $A, $A,$FC
byte_140F4:	dc.b 5,  0,  1,  2,  3,  4, $B, $B,$FC
byte_140FE:	dc.b 5,  0,  1,  2,  3,  4, $C, $C,$FC
byte_14108:	dc.b 5,  0,  1,  2,  3,  4, $D, $D,$FC
byte_14112:	dc.b $E,  0,  1,  2,$FC
byte_14118:	dc.b 7,$10,  8,$10,  8,$10,  8,$FC
byte_14120:	dc.b 7,$10,  9,$10,  9,$10,  9,$FC
byte_14128:	dc.b 7,$10, $A,$10, $A,$10, $A,$FC
byte_14130:	dc.b 7,$10, $B,$10, $B,$10, $B,$FC
byte_14138:	dc.b 7,$10, $C,$10, $C,$10, $C,$FC
byte_14140:	dc.b 7,$10, $D,$10, $D,$10, $D,$FC
byte_14148:	dc.b $E, $FC
byte_1414A:	dc.b $E, 1, 2, 3, 4, $FC
		even