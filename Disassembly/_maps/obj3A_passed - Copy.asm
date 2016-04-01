; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
		dc.w byte_CBEA-Map_obj3A
		dc.w byte_CC13-Map_obj3A
		dc.w byte_CC32-Map_obj3A
		dc.w byte_CC51-Map_obj3A
		dc.w byte_CC75-Map_obj3A
		dc.w byte_CB47-Map_obj3A
		dc.w byte_CB26-Map_obj3A
		dc.w byte_CB31-Map_obj3A
		dc.w byte_CB3C-Map_obj3A
byte_CBEA:	dc.b $A	;  SONIC HAS | LOUER MENT
		dc.b $F8, 5, 0, $26, $B4	; L
		dc.b $F8, 5, 0, $32, $C4	; O
		dc.b $F8, 5, 0, $46, $D4	; U
		dc.b $F8, 5, 0, $10, $E4	; E
		dc.b $F8, 5, 0, $3A, $F4	; R
		dc.b $F8, 0, 0, $56, $4	; Space
		dc.b $F8, 5, 0, $2A, $14	; M
		dc.b $F8, 5, 0, $10, $24	; E
		dc.b $F8, 5, 0, $2E, $34	; N
		dc.b $F8, 5, 0, $42, $44	; T
byte_CC13:	dc.b 5	;  PASSED | RIGHT
		dc.b $F8, 5, 0, $3A, $D0	; R
		dc.b $F8, 1, 0, $20, $E0	; I
		dc.b $F8, 5, 0, $18, $E8	; G
		dc.b $F8, 5, 0, $1C, $F8	; H
		dc.b $F8, 5, 0, $42, $8	; T
byte_CC32:	dc.b 6			; SCORE
		dc.b $F8, $D, 1, $4A, $B0
		dc.b $F8, 1, 1,	$62, $D0
		dc.b $F8, 9, 1,	$64, $18
		dc.b $F8, $D, 1, $6A, $30
		dc.b $F7, 4, 0,	$6E, $CD
		dc.b $FF, 4, $18, $6E, $CD
byte_CC51:	dc.b 7			; TIME BONUS
		dc.b $F8, $D, 1, $5A, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F0,	$28
		dc.b $F8, 1, 1,	$70, $48
byte_CC75:	dc.b 7			; RING BONUS
		dc.b $F8, $D, 1, $52, $B0
		dc.b $F8, $D, 0, $66, $D9
		dc.b $F8, 1, 1,	$4A, $F9
		dc.b $F7, 4, 0,	$6E, $F6
		dc.b $FF, 4, $18, $6E, $F6
		dc.b $F8, $D, $FF, $F8,	$28
		dc.b $F8, 1, 1,	$70, $48
		even
byte_CB47:	dc.b $D			; Oval
		dc.b $E4, $C, 0, $70, $F4
		dc.b $E4, 2, 0,	$74, $14
		dc.b $EC, 4, 0,	$77, $EC
		dc.b $F4, 5, 0,	$79, $E4
		dc.b $14, $C, $18, $70,	$EC
		dc.b 4,	2, $18,	$74, $E4
		dc.b $C, 4, $18, $77, 4
		dc.b $FC, 5, $18, $79, $C
		dc.b $EC, 8, 0,	$7D, $FC
		dc.b $F4, $C, 0, $7C, $F4
		dc.b $FC, 8, 0,	$7C, $F4
		dc.b 4,	$C, 0, $7C, $EC
		dc.b $C, 8, 0, $7C, $EC
		dc.b 0
byte_CB26:	dc.b 2			; ACT 1
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 2, 0,	$57, $C
byte_CB31:	dc.b 2			; ACT 2
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 6, 0,	$5A, 8
byte_CB3C:	dc.b 2			; ACT 3
		dc.b 4,	$C, 0, $53, $EC
		dc.b $F4, 6, 0,	$60, 8