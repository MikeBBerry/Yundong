; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_CbLRC:	
		dc.w SME_CbLRC_22-SME_CbLRC, SME_CbLRC_28-SME_CbLRC	
		dc.w SME_CbLRC_2E-SME_CbLRC, SME_CbLRC_34-SME_CbLRC	
		dc.w SME_CbLRC_3A-SME_CbLRC, SME_CbLRC_40-SME_CbLRC	
		dc.w SME_CbLRC_46-SME_CbLRC, SME_CbLRC_4C-SME_CbLRC	
		dc.w SME_CbLRC_61-SME_CbLRC, SME_CbLRC_67-SME_CbLRC	
		dc.w SME_CbLRC_6D-SME_CbLRC, SME_CbLRC_73-SME_CbLRC	
		dc.w SME_CbLRC_79-SME_CbLRC, SME_CbLRC_7F-SME_CbLRC	
		dc.w SME_CbLRC_85-SME_CbLRC, SME_CbLRC_8B-SME_CbLRC	
		dc.w SME_CbLRC_91-SME_CbLRC	
SME_CbLRC_22:	dc.b 1	
		dc.b $FC, 0, 0, $8D, $FC	
SME_CbLRC_28:	dc.b 1	
		dc.b $FC, 0, 0, $8E, $FC	
SME_CbLRC_2E:	dc.b 1	
		dc.b $FC, 0, 0, $8E, $FC	
SME_CbLRC_34:	dc.b 1	
		dc.b $F8, 5, 0, $8F, $F8	
SME_CbLRC_3A:	dc.b 1	
		dc.b $F8, 5, 0, $93, $F8	
SME_CbLRC_40:	dc.b 1	
		dc.b $F4, $A, 0, $1C, $F4	
SME_CbLRC_46:	dc.b 1	
		dc.b $F0, $F, 0, 8, $F0	
SME_CbLRC_4C:	dc.b 4	
		dc.b $F0, 5, 0, $18, $F0	
		dc.b $F0, 5, 8, $18, 0	
		dc.b 0, 5, $10, $18, $F0	
		dc.b 0, 5, $18, $18, 0	
SME_CbLRC_61:	dc.b 1	
		dc.b $F4, 6, $24, $58, $F8	
SME_CbLRC_67:	dc.b 1	
		dc.b $F4, 6, $24, $58, $F8	
SME_CbLRC_6D:	dc.b 1	
		dc.b $F4, 6, $24, $58, $F8	
SME_CbLRC_73:	dc.b 1	
		dc.b $F4, 6, $24, $58, $F8	
SME_CbLRC_79:	dc.b 1	
		dc.b $F4, 6, $24, $58, $F8	
SME_CbLRC_7F:	dc.b 1	
		dc.b $F4, 6, $24, $58, $F8	
SME_CbLRC_85:	dc.b 1	
		dc.b $F8, 5, 0, 0, $F8	
SME_CbLRC_8B:	dc.b 1	
		dc.b $F8, 5, 0, 4, $F8	
SME_CbLRC_91:	dc.b 0	
		even