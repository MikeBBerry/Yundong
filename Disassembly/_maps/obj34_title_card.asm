; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_D3SvB:	
		dc.w SME_D3SvB_8-SME_D3SvB, SME_D3SvB_13-SME_D3SvB	
		dc.w SME_D3SvB_1E-SME_D3SvB, SME_D3SvB_29-SME_D3SvB	
SME_D3SvB_8:	dc.b 2	
		dc.b 4, $C, 0, 0, $EC	
		dc.b $F4, 2, 0, 4, $C	
SME_D3SvB_13:	dc.b 2	
		dc.b 4, $C, 0, 0, $EC	
		dc.b $F4, 6, 0, 7, 8	
SME_D3SvB_1E:	dc.b 2	
		dc.b 4, $C, 0, 0, $EC	
		dc.b $F4, 6, 0, $D, 8	
SME_D3SvB_29:	dc.b $D	
		dc.b $E4, $C, 0, $1D, $F4	
		dc.b $E4, 2, 0, $21, $14	
		dc.b $EC, 4, 0, $24, $EC	
		dc.b $F4, 5, 0, $26, $E4	
		dc.b $14, $C, $18, $1D, $EC	
		dc.b 4, 2, $18, $21, $E4	
		dc.b $C, 4, $18, $24, 4	
		dc.b $FC, 5, $18, $26, $C	
		dc.b $EC, 8, 0, $2A, $FC	
		dc.b $F4, $C, 0, $29, $F4	
		dc.b $FC, 8, 0, $29, $F4	
		dc.b 4, $C, 0, $29, $EC	
		dc.b $C, 8, 0, $29, $EC	
		even