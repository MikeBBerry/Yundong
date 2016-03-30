; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
		dc.w byte_CBEA-Map_obj3A
		dc.w byte_CC13-Map_obj3A
		dc.w byte_CC32-Map_obj3A
		dc.w byte_CC51-Map_obj3A
		dc.w byte_CC75-Map_obj3A
	;	dc.w byte_CB47-Map_obj3A
	;	dc.w byte_CB26-Map_obj3A
	;	dc.w byte_CB31-Map_obj3A
	;	dc.w byte_CB3C-Map_obj3A
byte_CBEA:	dc.b 9	;  SONIC HAS | LOUER HAS
		dc.b $F8, 5, 0, $26, $B8	; L
		dc.b $F8, 5, 0, $32, $C8	; O
		dc.b $F8, 5, 0, $46, $D8	; U
		dc.b $F8, 5, 0, $10, $E8	; E
		dc.b $F8, 5, 0, $3A, $F8	; R
		dc.b $F8, 0, 0, $56, $8	; Space
		dc.b $F8, 5, 0, $1C, $18	; H
		dc.b $F8, 5, 0, 0, $28		; A
		dc.b $F8, 5, 0, $3E, $38	; S
byte_CC13:	dc.b 7	;  PASSED | ABORTED
		dc.b $F8, 5, 0, 0, $C8		; A
		dc.b $F8, 5, 0, 4, $D8		; B
		dc.b $F8, 5, 0, $32, $E8	; O
		dc.b $F8, 5, 0, $3A, $F8	; R
		dc.b $F8, 5, 0, $42, $8	; T
		dc.b $F8, 5, 0, $10, $18	; E
		dc.b $F8, 5, 0, $0C, $28	; D
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