; --------------------------------------------------------------------------------
; Sprite mappings - output from SonMapEd - Sonic 1 format
; --------------------------------------------------------------------------------

SME_Cnfhc:	
		dc.w SME_Cnfhc_10-SME_Cnfhc, SME_Cnfhc_3E-SME_Cnfhc	
		dc.w SME_Cnfhc_58-SME_Cnfhc, SME_Cnfhc_68-SME_Cnfhc	
		dc.w SME_Cnfhc_78-SME_Cnfhc, SME_Cnfhc_88-SME_Cnfhc	
		dc.w SME_Cnfhc_CA-SME_Cnfhc, SME_Cnfhc_D5-SME_Cnfhc	
SME_Cnfhc_10:	dc.b 9	
		dc.b $FB, 5, 0, $E, $B4	
		dc.b $FB, 5, 0, $16, $C4	
		dc.b $FB, 5, 0, $22, $D4	
		dc.b $FB, 5, 0, 0, $E4	
		dc.b $FB, 5, 0, $1A, $F4	
		dc.b $FB, 5, 0, 0, $24	
		dc.b $FB, 5, 0, $12, $34	
		dc.b $FB, 5, 0, $1E, $44	
		dc.b $FB, 5, 0, $26, $13	
SME_Cnfhc_3E:	dc.b 5	
		dc.b $F8, 5, 0, $1A, $E0	
		dc.b $F8, 1, 0, $C, $F0	
		dc.b $F8, 5, 0, 4, $F8	
		dc.b $F8, 5, 0, 8, 8	
		dc.b $F8, 5, 0, $1E, $18	
SME_Cnfhc_58:	dc.b 3	
		dc.b $F8, $D, 1, $4A, $B0	
		dc.b $F8, 9, 1, $64, $18	
		dc.b $F8, $D, 1, $6A, $30	
SME_Cnfhc_68:	dc.b 3	
		dc.b $F8, $D, 1, $5A, $B0	
		dc.b $F8, $D, $FF, $F0, $28	
		dc.b $F8, 1, 1, $70, $48	
SME_Cnfhc_78:	dc.b 3	
		dc.b $F8, $D, 1, $52, $B0	
		dc.b $F8, $D, $FF, $F8, $28	
		dc.b $F8, 1, 1, $70, $48	
SME_Cnfhc_88:	dc.b $D	
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
SME_Cnfhc_CA:	dc.b 2	
		dc.b 4, $C, 0, 0, $EC	
		dc.b $F4, 6, 0, 7, 8	
SME_Cnfhc_D5:	dc.b 2	
		dc.b 4, $C, 0, 0, $EC	
		dc.b $F4, 6, 0, $D, 8	
		even