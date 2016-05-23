; ===========================================================================
; Definitions
; ===========================================================================
; RAM
; ===========================================================================
		rsset $FFFF0000
RAM_Start						rs.b 0
General_Buffer					rs.b 0
Chunk_Table						rs.b $A400		; $FFFF0000
Chunk_Table_End					rs.b 0
Level_Layout					rs.b 0
Level_Layout_FG					rs.l 1			; $FFFFA400
Level_Layout_BG					rs.l 1			; $FFFFA404
								rs.b $3F8		; $FFFFA408
TempArray_LayerDef				rs.b $200		; $FFFFA800
Nem_Decomp_Buffer				rs.b $200		; $FFFFAA00
Sprite_Table_Input				rs.b $400		; $FFFFAC00
Sprite_Table_Input_End			rs.b 0
Block_Table						rs.b $1800		; $FFFFB000
Block_Table_End					rs.b 0
DMA_Queue						rs.b $FC		; $FFFFC800
DMA_Queue_Slot					rs.l 1			; $FFFFC8FC
								rs.b $200		; $FFFFC900
Sonic_Pos_Record_Buf			rs.b $100		; $FFFFCB00
Horiz_Scroll_Buf				rs.b $380		; $FFFFCC00
Horiz_Scroll_Buf_End			rs.b 0
								rs.b $80		; $FFFFCF80
Object_RAM						rs.b 0
Normal_Object_RAM				rs.b 0
Object_Space_1					rs.b $40		; $FFFFD000
Object_Space_2					rs.b $40		; $FFFFD040
Object_Space_3					rs.b $40		; $FFFFD080
Object_Space_4					rs.b $40		; $FFFFD0C0
Object_Space_5					rs.b $40		; $FFFFD100
Object_Space_6					rs.b $40		; $FFFFD140
Object_Space_7					rs.b $40		; $FFFFD180
Object_Space_8					rs.b $40		; $FFFFD1C0
Object_Space_9					rs.b $40		; $FFFFD200
Object_Space_10					rs.b $40		; $FFFFD240
Object_Space_11					rs.b $40		; $FFFFD280
Object_Space_12					rs.b $40		; $FFFFD2C0
Object_Space_13					rs.b $40		; $FFFFD300
Object_Space_14					rs.b $40		; $FFFFD340
Object_Space_15					rs.b $40		; $FFFFD380
Object_Space_16					rs.b $40		; $FFFFD3C0
Object_Space_17					rs.b $40		; $FFFFD400
Object_Space_18					rs.b $40		; $FFFFD440
Object_Space_19					rs.b $40		; $FFFFD480
Object_Space_20					rs.b $40		; $FFFFD4C0
Object_Space_21					rs.b $40		; $FFFFD500
Object_Space_22					rs.b $40		; $FFFFD540
Object_Space_23					rs.b $40		; $FFFFD580
Object_Space_24					rs.b $40		; $FFFFD5C0
Object_Space_25					rs.b $40		; $FFFFD600
Object_Space_26					rs.b $40		; $FFFFD640
Object_Space_27					rs.b $40		; $FFFFD680
Object_Space_28					rs.b $40		; $FFFFD6C0
Object_Space_29					rs.b $40		; $FFFFD700
Object_Space_30					rs.b $40		; $FFFFD740
Object_Space_31					rs.b $40		; $FFFFD780
Object_Space_32					rs.b $40		; $FFFFD7C0
Normal_Object_RAM_End			rs.b 0
Dynamic_Object_RAM				rs.b 0
Object_Space_33					rs.b $40		; $FFFFD800
Object_Space_34					rs.b $40		; $FFFFD840
Object_Space_35					rs.b $40		; $FFFFD880
Object_Space_36					rs.b $40		; $FFFFD8C0
Object_Space_37					rs.b $40		; $FFFFD900
Object_Space_38					rs.b $40		; $FFFFD940
Object_Space_39					rs.b $40		; $FFFFD980
Object_Space_40					rs.b $40		; $FFFFD9C0
Object_Space_41					rs.b $40		; $FFFFDA00
Object_Space_42					rs.b $40		; $FFFFDA40
Object_Space_43					rs.b $40		; $FFFFDA80
Object_Space_44					rs.b $40		; $FFFFDAC0
Object_Space_45					rs.b $40		; $FFFFDB00
Object_Space_46					rs.b $40		; $FFFFDB40
Object_Space_47					rs.b $40		; $FFFFDB80
Object_Space_48					rs.b $40		; $FFFFDBC0
Object_Space_49					rs.b $40		; $FFFFDC00
Object_Space_50					rs.b $40		; $FFFFDC40
Object_Space_51					rs.b $40		; $FFFFDC80
Object_Space_52					rs.b $40		; $FFFFDCC0
Object_Space_53					rs.b $40		; $FFFFDD00
Object_Space_54					rs.b $40		; $FFFFDD40
Object_Space_55					rs.b $40		; $FFFFDD80
Object_Space_56					rs.b $40		; $FFFFDDC0
Object_Space_57					rs.b $40		; $FFFFDE00
Object_Space_58					rs.b $40		; $FFFFDE40
Object_Space_59					rs.b $40		; $FFFFDE80
Object_Space_60					rs.b $40		; $FFFFDEC0
Object_Space_61					rs.b $40		; $FFFFDF00
Object_Space_62					rs.b $40		; $FFFFDF40
Object_Space_63					rs.b $40		; $FFFFDF80
Object_Space_64					rs.b $40		; $FFFFDFC0
Object_Space_65					rs.b $40		; $FFFFE000
Object_Space_66					rs.b $40		; $FFFFE040
Object_Space_67					rs.b $40		; $FFFFE080
Object_Space_68					rs.b $40		; $FFFFE0C0
Object_Space_69					rs.b $40		; $FFFFE100
Object_Space_70					rs.b $40		; $FFFFE140
Object_Space_71					rs.b $40		; $FFFFE180
Object_Space_72					rs.b $40		; $FFFFE1C0
Object_Space_73					rs.b $40		; $FFFFE200
Object_Space_74					rs.b $40		; $FFFFE240
Object_Space_75					rs.b $40		; $FFFFE280
Object_Space_76					rs.b $40		; $FFFFE2C0
Object_Space_77					rs.b $40		; $FFFFE300
Object_Space_78					rs.b $40		; $FFFFE340
Object_Space_79					rs.b $40		; $FFFFE380
Object_Space_80					rs.b $40		; $FFFFE3C0
Object_Space_81					rs.b $40		; $FFFFE400
Object_Space_82					rs.b $40		; $FFFFE440
Object_Space_83					rs.b $40		; $FFFFE480
Object_Space_84					rs.b $40		; $FFFFE4C0
Object_Space_85					rs.b $40		; $FFFFE500
Object_Space_86					rs.b $40		; $FFFFE540
Object_Space_87					rs.b $40		; $FFFFE580
Object_Space_88					rs.b $40		; $FFFFE5C0
Object_Space_89					rs.b $40		; $FFFFE600
Object_Space_90					rs.b $40		; $FFFFE640
Object_Space_91					rs.b $40		; $FFFFE680
Object_Space_92					rs.b $40		; $FFFFE6C0
Object_Space_93					rs.b $40		; $FFFFE700
Object_Space_94					rs.b $40		; $FFFFE740
Object_Space_95					rs.b $40		; $FFFFE780
Object_Space_96					rs.b $40		; $FFFFE7C0
Object_Space_97					rs.b $40		; $FFFFE800
Object_Space_98					rs.b $40		; $FFFFE840
Object_Space_99					rs.b $40		; $FFFFE880
Object_Space_100				rs.b $40		; $FFFFE8C0
Object_Space_101				rs.b $40		; $FFFFE900
Object_Space_102				rs.b $40		; $FFFFE940
Object_Space_103				rs.b $40		; $FFFFE980
Object_Space_104				rs.b $40		; $FFFFE9C0
Object_Space_105				rs.b $40		; $FFFFEA00
Object_Space_106				rs.b $40		; $FFFFEA40
Object_Space_107				rs.b $40		; $FFFFEA80
Object_Space_108				rs.b $40		; $FFFFEAC0
Object_Space_109				rs.b $40		; $FFFFEB00
Object_Space_110				rs.b $40		; $FFFFEB40
Object_Space_111				rs.b $40		; $FFFFEB80
Object_Space_112				rs.b $40		; $FFFFEBC0
Object_Space_113				rs.b $40		; $FFFFEC00
Object_Space_114				rs.b $40		; $FFFFEC40
Object_Space_115				rs.b $40		; $FFFFEC80
Object_Space_116				rs.b $40		; $FFFFECC0
Object_Space_117				rs.b $40		; $FFFFED00
Object_Space_118				rs.b $40		; $FFFFED40
Object_Space_119				rs.b $40		; $FFFFED80
Object_Space_120				rs.b $40		; $FFFFEDC0
Object_Space_121				rs.b $40		; $FFFFEE00
Object_Space_122				rs.b $40		; $FFFFEE40
Object_Space_123				rs.b $40		; $FFFFEE80
Object_Space_124				rs.b $40		; $FFFFEEC0
Object_Space_125				rs.b $40		; $FFFFEF00
Object_Space_126				rs.b $40		; $FFFFEF40
Object_Space_127				rs.b $40		; $FFFFEF80
Object_Space_128				rs.b $40		; $FFFFEFC0
Dynamic_Object_RAM_End			rs.b 0
Object_RAM_End					rs.b 0
Sound_Driver_RAM				rs.b $600		; $FFFFF000
Game_Mode						rs.b 1			; $FFFFF600
								rs.b 1			; $FFFFF601
Sonic_Ctrl						rs.b 0
Sonic_Ctrl_Held					rs.b 1			; $FFFFF602
Sonic_Ctrl_Press				rs.b 1			; $FFFFF603
Ctrl_1							rs.b 0
Ctrl_1_Held						rs.b 1			; $FFFFF604
Ctrl_1_Press					rs.b 1			; $FFFFF605
Ctrl_2							rs.b 0
Ctrl_2_Held						rs.b 1			; $FFFFF606
Ctrl_2_Press					rs.b 1			; $FFFFF607
								rs.b 4			; $FFFFF608
VDP_Reg_1_Value					rs.w 1			; $FFFFF60C
								rs.b 6			; $FFFFF60E
Universal_Timer					rs.w 1			; $FFFFF614
V_Scroll_Value					rs.b 0
V_Scroll_Value_FG				rs.w 1			; $FFFFF616
V_Scroll_Value_BG				rs.w 1			; $FFFFF618
H_Scroll_Value					rs.b 0
H_Scroll_Value_FG				rs.w 1			; $FFFFF61A
H_Scroll_Value_BG				rs.w 1			; $FFFFF61C
Camera_BG3_Y_Pos_Prev			rs.w 1			; $FFFFF61E
Camera_BG3_X_Pos_Prev			rs.w 1			; $FFFFF620
								rs.b 2			; $FFFFF622
H_Int_Counter					rs.w 1			; $FFFFF624
Palette_Fade_Range				rs.b 0
Palette_Fade_Start				rs.b 1			; $FFFFF626
Palette_Fade_Length				rs.b 1			; $FFFFF627
Misc_Variables					rs.b 0
V_Int_E_Run_Count				rs.b 1			; $FFFFF628
								rs.b 1			; $FFFFF629
V_Int_Routine					rs.b 1			; $FFFFF62A
								rs.b 1			; $FFFFF62B
Sprite_Count					rs.b 1			; $FFFFF62C
								rs.b 5			; $FFFFF62D
Pal_Cycle_Frame					rs.w 1			; $FFFFF632
Pal_Cycle_Timer					rs.w 1			; $FFFFF634
Random_Seed						rs.l 1			; $FFFFF636
Pause_Flag						rs.w 1			; $FFFFF63A
								rs.b 4			; $FFFFF63C
DMA_Data_Thunk					rs.w 1			; $FFFFF640
								rs.b 2			; $FFFFF642
H_Int_Flag						rs.w 1			; $FFFFF644
Water_Height					rs.w 1			; $FFFFF646
Water_Height_No_Sway			rs.w 1			; $FFFFF648
Water_Height_Target				rs.w 1			; $FFFFF64A
Water_On						rs.b 1			; $FFFFF64C
Water_Routine					rs.b 1			; $FFFFF64D
Water_Fullscreen_Flag			rs.b 1			; $FFFFF64E
Do_Updates_In_H_Int				rs.b 1			; $FFFFF64F
Pal_Cycle_Buffer				rs.b $12		; $FFFFF650
								rs.b $1E		; $FFFFF662
Misc_Variables_End				rs.b 0
PLC_Buffer						rs.b $60		; $FFFFF680
PLC_Buffer_Only_End				rs.b 0
PLC_Buffer_Reg_0				rs.l 1			; $FFFFF6E0
PLC_Buffer_Reg_4				rs.l 1			; $FFFFF6E4
PLC_Buffer_Reg_8				rs.l 1			; $FFFFF6E8
PLC_Buffer_Reg_C				rs.l 1			; $FFFFF6EC
PLC_Buffer_Reg_10				rs.l 1			; $FFFFF6F0
PLC_Buffer_Reg_14				rs.l 1			; $FFFFF6F4
PLC_Buffer_Reg_18				rs.w 1			; $FFFFF6F8
PLC_Buffer_Reg_1A				rs.w 1			; $FFFFF6FA
								rs.b 4			; $FFFFF6FC
PLC_Buffer_End					rs.b 0
Camera_And_Misc_RAM				rs.b 0
Camera_RAM						rs.b 0
Camera_X_Pos					rs.l 1			; $FFFFF700
Camera_Y_Pos					rs.l 1			; $FFFFF704
Camera_BG_X_Pos					rs.l 1			; $FFFFF708
Camera_BG_Y_Pos					rs.l 1			; $FFFFF70C
Camera_BG2_X_Pos				rs.l 1			; $FFFFF710
Camera_BG2_Y_Pos				rs.l 1			; $FFFFF714
Camera_BG3_X_Pos				rs.l 1			; $FFFFF718
Camera_BG3_Y_Pos				rs.l 1			; $FFFFF71C
Target_Camera_Min_X_Pos			rs.w 1			; $FFFFF720
Target_Camera_Max_X_Pos			rs.w 1			; $FFFFF722
Target_Camera_Min_Y_Pos			rs.w 1			; $FFFFF724
Target_Camera_Max_Y_Pos			rs.w 1			; $FFFFF726
Camera_Min_X_Pos				rs.w 1			; $FFFFF728
Camera_Max_X_Pos				rs.w 1			; $FFFFF72A
Camera_Min_Y_Pos				rs.w 1			; $FFFFF72C
Camera_Max_Y_Pos				rs.w 1			; $FFFFF72E
								rs.b $A			; $FFFFF730
Camera_X_Pos_Diff				rs.w 1			; $FFFFF73A
Camera_Y_Pos_Diff				rs.w 1			; $FFFFF73C
Camera_Y_Pos_Bias				rs.w 1			; $FFFFF73E
								rs.b 2			; $FFFFF740
Dynamic_Resize_Routine			rs.b 1			; $FFFFF742
								rs.b 1			; $FFFFF743
Deform_Lock						rs.b 1			; $FFFFF744
								rs.b 5			; $FFFFF745
Horiz_Block_Crossed_Flag		rs.b 1			; $FFFFF74A
Verti_Block_Crossed_Flag		rs.b 1			; $FFFFF74B
Horiz_Block_Crossed_Flag_BG		rs.b 1			; $FFFFF74C
Verti_Block_Crossed_Flag_BG		rs.b 1			; $FFFFF74D
Horiz_Block_Crossed_Flag_BG2	rs.b 1			; $FFFFF74E
								rs.b 5			; $FFFFF74F
Scroll_Flags					rs.w 1			; $FFFFF754
Scroll_Flags_BG					rs.w 1			; $FFFFF756
Scroll_Flags_BG2				rs.w 1			; $FFFFF758
Scroll_Flags_BG3				rs.w 1			; $FFFFF75A
V_Scroll_BG_Flag				rs.b 1			; $FFFFF75C
								rs.b 3			; $FFFFF75D
Sonic_Top_Speed					rs.w 1			; $FFFFF760
Sonic_Acceleration				rs.w 1			; $FFFFF762
Sonic_Deceleration				rs.w 1			; $FFFFF764
Sonic_Last_DPLC_Frame			rs.b 1			; $FFFFF766
								rs.b 1			; $FFFFF767
Primary_Angle					rs.b 1			; $FFFFF768
								rs.b 1			; $FFFFF769
Secondary_Angle					rs.b 1			; $FFFFF76A
								rs.b 1			; $FFFFF76B
Obj_Manager_Routine				rs.b 1			; $FFFFF76C
								rs.b 1			; $FFFFF76D
Camera_X_Pos_Last				rs.w 1			; $FFFFF76E
Obj_Load_Addr_Right				rs.l 1			; $FFFFF770
Obj_Load_Addr_Left				rs.l 1			; $FFFFF774
Obj_Load_Addr_2					rs.l 1			; $FFFFF778
Obj_Load_Addr_3					rs.l 1			; $FFFFF77C
								rs.b $10		; $FFFFF780
Demo_Button_Index				rs.w 1			; $FFFFF790
Demo_Press_Counter				rs.b 1			; $FFFFF792
								rs.b 1			; $FFFFF793
Demo_Pal_Fade_Delay				rs.w 1			; $FFFFF794
Collision_Addr					rs.l 1			; $FFFFF796
								rs.b $B			; $FFFFF79A
Obj31_Y_Pos						rs.w 1			; $FFFFF7A4
Boss_Defeated_Flags				rs.b 1			; $FFFFF7A7
Sonic_Pos_Record_Index			rs.w 1			; $FFFFF7A8
Right_Boundary_Lock				rs.b 1			; $FFFFF7AA
								rs.b 5			; $FFFFF7AB
Level_Ani0_Frame				rs.b 1			; $FFFFF7B0
Level_Ani0_Timer				rs.b 1			; $FFFFF7B1
Level_Ani1_Frame				rs.b 1			; $FFFFF7B2
Level_Ani1_Timer				rs.b 1			; $FFFFF7B3
Level_Ani2_Frame				rs.b 1			; $FFFFF7B4
Level_Ani2_Timer				rs.b 1			; $FFFFF7B5
Level_Ani3_Frame				rs.b 1			; $FFFFF7B6
Level_Ani3_Timer				rs.b 1			; $FFFFF7B7
Level_Ani4_Frame				rs.b 1			; $FFFFF7B8
Level_Ani4_Timer				rs.b 1			; $FFFFF7B9
Level_Ani5_Frame				rs.b 1			; $FFFFF7BA
Level_Ani5_Timer				rs.b 1			; $FFFFF7BB
								rs.b 2			; $FFFFF7BC
Big_Ring_GFX_Offset				rs.w 1			; $FFFFF7BE
Reverse_Converyor_Flag			rs.b 1			; $FFFFF7C0
Conveyor_Ptfm_Variables			rs.b 6			; $FFFFF7C1
Wind_Tunnel_Mode				rs.b 1			; $FFFFF7C7
No_Player_Physics_Flag			rs.b 1			; $FFFFF7C8
Wind_Tunnel_Flag				rs.b 1			; $FFFFF7C9
Jump_Only_Flag					rs.b 1			; $FFFFF7CA
Obj6B_Flag						rs.b 1			; $FFFFF7CB
Lock_Controls_Flag				rs.b 1			; $FFFFF7CC
Jumped_In_Big_Ring_Flag			rs.b 1			; $FFFFF7CD
								rs.b 2			; $FFFFF7CE
Chain_Bonus_Counter				rs.w 1			; $FFFFF7D0
Time_Bonus						rs.w 1			; $FFFFF7D2
Ring_Bonus						rs.w 1			; $FFFFF7D4
Update_Bonus_Flag				rs.b 1			; $FFFFF7D6
Sonic_Ending_Routine			rs.b 1			; $FFFFF7D7
								rs.b 8			; $FFFFF7D8
Switch_Statuses					rs.b $10		; $FFFFF7E0
Unk_Scroll_Values				rs.b 8			; $FFFFF7F0
								rs.b 8			; $FFFFF7F8
Camera_And_Misc_RAM_End			rs.b 0
Sprite_Table					rs.b $280		; $FFFFF800
Sprite_Table_End				rs.b 0
Target_Underwater_Palette		= __rs-$80		; $FFFFFA00
Underwater_Palette				rs.b $80		; $FFFFFA80
Normal_Palette					rs.b $80		; $FFFFFB00
Target_Palette					rs.b $80		; $FFFFFB80
Object_Respawn_Table			rs.b $180		; $FFFFFC00
Object_Respawn_Table_End		rs.b 0
Stack							rs.b $80		; $FFFFFD80
Stack_Base						rs.b 0
								rs.b 2			; $FFFFFE00
Level_Inactive_Flag				rs.w 1			; $FFFFFE02
Level_Timer						rs.w 1			; $FFFFFE04
Debug_Item						rs.b 1			; $FFFFFE06
								rs.b 1			; $FFFFFE07
Debug_Placement_Mode			rs.w 1			; $FFFFFE08
Debug_Accel_Timer				rs.b 1			; $FFFFFE0A
Debug_Speed						rs.b 1			; $FFFFFE0B
V_Int_Counter					rs.l 1			; $FFFFFE0C
Current_Zone_And_Act			rs.b 0
Current_Zone					rs.b 1			; $FFFFFE10
Current_Act						rs.b 1			; $FFFFFE11
Life_Count						rs.b 1			; $FFFFFE12
								rs.b 1			; $FFFFFE13
Air_Remaining					rs.w 1			; $FFFFFE14
Current_Special_Stage			rs.b 1			; $FFFFFE16
								rs.b 1			; $FFFFFE17
Continue_Count					rs.b 1			; $FFFFFE18
								rs.b 1			; $FFFFFE19
Time_Over_Flag					rs.b 1			; $FFFFFE1A
Extra_Life_Flags				rs.b 1			; $FFFFFE1B
Update_HUD_Lives				rs.b 1			; $FFFFFE1C
Update_HUD_Rings				rs.b 1			; $FFFFFE1D
Update_HUD_Timer				rs.b 1			; $FFFFFE1E
Update_HUD_Score				rs.b 1			; $FFFFFE1F
Ring_Count						rs.w 1			; $FFFFFE20
Timer							rs.b 0
Timer_Minute_Word				rs.b 1			; $FFFFFE22
Timer_Minute					rs.b 1			; $FFFFFE23
Timer_Second					rs.b 1			; $FFFFFE24
Timer_Frame						rs.b 1			; $FFFFFE25
Score							rs.l 1			; $FFFFFE26
								rs.b 2			; $FFFFFE2A
Shield_Flag						rs.b 1			; $FFFFFE2C
Invincibility_Flag				rs.b 1			; $FFFFFE2D
Speed_Shoes_Flag				rs.b 1			; $FFFFFE2E
								rs.b 1			; $FFFFFE2F
Last_Checkpoint_Hit				rs.b 1			; $FFFFFE30
Saved_Last_Checkpoint_Hit		rs.b 1			; $FFFFFE31
Saved_X_Pos						rs.w 1			; $FFFFFE32
Saved_Y_Pos						rs.w 1			; $FFFFFE34
Saved_Ring_Count				rs.w 1			; $FFFFFE36
Saved_Timer						rs.l 1			; $FFFFFE38
Saved_Resize_Routine			rs.w 1			; $FFFFFE3C
Saved_Camera_Max_Y_Pos			rs.w 1			; $FFFFFE3E
Saved_Camera_X_Pos				rs.w 1			; $FFFFFE40
Saved_Camera_Y_Pos				rs.w 1			; $FFFFFE42
Saved_Camera_BG_X_Pos			rs.w 1			; $FFFFFE44
Saved_Camera_BG_Y_Pos			rs.w 1			; $FFFFFE46
Saved_Camera_BG2_X_Pos			rs.w 1			; $FFFFFE48
Saved_Camera_BG2_Y_Pos			rs.w 1			; $FFFFFE4A
Saved_Camera_BG3_X_Pos			rs.w 1			; $FFFFFE4C
Saved_Camera_BG3_Y_Pos			rs.w 1			; $FFFFFE4E
Saved_Water_Height				rs.w 1			; $FFFFFE50
Saved_Water_Routine				rs.b 1			; $FFFFFE52
Saved_Water_Fullscreen_Flag		rs.b 1			; $FFFFFE53
Saved_Extra_Life_Flags			rs.b 1			; $FFFFFE54
								rs.b 2			; $FFFFFE55
Emerald_Count					rs.b 1			; $FFFFFE57
Got_Emeralds_Array				rs.b 6			; $FFFFFE58
Oscillation_Control				rs.w 1			; $FFFFFE5E
Osc_And_Misc_RAM				rs.b 0
Oscillation_Data				rs.w $20		; $FFFFFE60
								rs.b $20		; $FFFFFEA0
Logspike_Anim_Counter			rs.b 1			; $FFFFFEC0
Logspike_Anim_Frame				rs.b 1			; $FFFFFEC1
Rings_Anim_Counter				rs.b 1			; $FFFFFEC2
Rings_Anim_Frame				rs.b 1			; $FFFFFEC3
Unknown_Anim_Counter			rs.b 1			; $FFFFFEC4
Unknown_Anim_Frame				rs.b 1			; $FFFFFEC5
Ring_Spill_Anim_Counter			rs.b 1			; $FFFFFEC6
Ring_Spill_Anim_Frame			rs.b 1			; $FFFFFEC7
Ring_Spill_Anim_Accum			rs.w 1			; $FFFFFEC8
								rs.b $26		; $FFFFFECA
Camera_Min_Y_Pos_Debug_Copy		rs.w 1			; $FFFFFEF0
Camera_Max_Y_Pos_Debug_Copy		rs.w 1			; $FFFFFEF2
								rs.b $1C		; $FFFFFEF4
Camera_RAM_Copy					rs.b 0
Camera_X_Pos_Copy				rs.l 1			; $FFFFFF10
Camera_Y_Pos_Copy				rs.l 1			; $FFFFFF14
Camera_BG_X_Pos_Copy			rs.l 1			; $FFFFFF18
Camera_BG_Y_Pos_Copy			rs.l 1			; $FFFFFF1C
Camera_BG2_X_Pos_Copy			rs.l 1			; $FFFFFF20
Camera_BG2_Y_Pos_Copy			rs.l 1			; $FFFFFF24
Camera_BG3_X_Pos_Copy			rs.l 1			; $FFFFFF28
Camera_BG3_Y_Pos_Copy			rs.l 1			; $FFFFFF2C
Scroll_Flags_Copy				rs.w 1			; $FFFFFF30
Scroll_Flags_BG_Copy			rs.w 1			; $FFFFFF32
Scroll_Flags_BG2_Copy			rs.w 1			; $FFFFFF34
Scroll_Flags_BG3_Copy			rs.w 1			; $FFFFFF36
								rs.b $48		; $FFFFFF38
Osc_And_Misc_RAM_End			rs.b 0
Level_Sel_Move_Timer			rs.w 1			; $FFFFFF80
Level_Sel_Selection				rs.w 1			; $FFFFFF82
Level_Sel_Sound_ID				rs.w 1			; $FFFFFF84
								rs.b $15		; $FFFFFF86
Flicky_Door_Flag				rs.b 1			; $FFFFFF9B
Flicky_Chicks_Following			rs.w 1			; $FFFFFF9C
Flicky_Chicks_Left				rs.w 1			; $FFFFFF9E
Tutorial_Boss_Flags				rs.w 1			; $FFFFFFA0
Sonic_Look_Delay_Counter		rs.w 1			; $FFFFFFA2
Snd_Test_Deform_Modifier		rs.w 1			; $FFFFFFA4
Bite_Flag						rs.b 1			; $FFFFFFA6
Snd_Driver_PAL_Counter			rs.b 1			; $FFFFFFA7
Snd_Test_Music_Playing_Flag		rs.b 1			; $FFFFFFA8
Snd_Test_PCM_Flag				rs.b 1			; $FFFFFFA9
Snd_Test_Selection				rs.b 1			; $FFFFFFAA
Snd_Test_Music_ID				rs.b 1			; $FFFFFFAB
Snd_Test_SFX_ID					rs.b 1			; $FFFFFFAC
Snd_Test_PCM_ID					rs.b 1			; $FFFFFFAD
Sega_H_Int_First_Color_Index	rs.w 1			; $FFFFFFAE
Sega_H_Int_Sine_Index			rs.w 1			; $FFFFFFB0
Sega_H_Int_Sine_Address			rs.l 1			; $FFFFFFB2
Sega_Deform_Sine_Index			rs.w 1			; $FFFFFFB6
Sega_Effect_Modifier			rs.w 1			; $FFFFFFB8
Sega_H_Int_Curr_Color_Index		rs.w 1			; $FFFFFFBA
Sega_H_Int_Color_Modifier		rs.l 1			; $FFFFFFBC
Score_Copy						rs.l 1			; $FFFFFFC0
								rs.b $C			; $FFFFFFC4
First_Collision_Addr			rs.l 1			; $FFFFFFD0
Second_Collision_Addr			rs.l 1			; $FFFFFFD4
								rs.b 8			; $FFFFFFD8
Cheat_Flags						rs.b 0
Level_Sel_Cheat_Flag			rs.b 1			; $FFFFFFE0
Debug_Cheat_Flag				rs.b 1			; $FFFFFFE1
Slow_Motion_Cheat_Flag			rs.b 1			; $FFFFFFE2
Jap_Credits_Cheat_Flag			rs.b 1 			; $FFFFFFE3
Cheat_Btn_Press_Count			rs.w 1			; $FFFFFFE4
C_Press_Counter					rs.w 1			; $FFFFFFE6
								rs.b 8			; $FFFFFFE8
Demo_Mode						rs.w 1			; $FFFFFFF0
Demo_Number						rs.w 1			; $FFFFFFF2
Credits_Index					rs.w 1			; $FFFFFFF4
								rs.b 1			; $FFFFFFF6
Sonic_Current_Coll_Layer		rs.b 1			; $FFFFFFF7
Console_Version					rs.b 1			; $FFFFFFF8
								rs.b 1			; $FFFFFFF9
Debug_Cheat_On					rs.w 1			; $FFFFFFFA
Current_Music_ID				rs.b 1			; $FFFFFFFC
Bad_Ending_Flag					rs.b 1			; $FFFFFFFD
Level_Music_ID					rs.b 1			; $FFFFFFFE
Boss_Flag						rs.b 1			; $FFFFFFFF
RAM_End							= __rs-1
		rsreset
; ===========================================================================
; Sound constansts
; ===========================================================================
MusicID_Start					= 1				; First music ID (part 1)
MusicID_End						= $BF			; Last music ID (part 1)
SFXID_Start						= $C0			; First SFX ID
SFXID_End						= $FA			; Last SFX ID
SpecSFXID_Start					= $FB			; First special SFX ID
SpecSFXID_End					= $FB			; Last special SFX ID
CmdID_Start						= $FC			; First command ID
CmdID_End						= $FF			; Last command ID
; ===========================================================================
; Music IDs
; ===========================================================================
MusID_DzienDobry				= MusicID_Start+0
MusID_FuckedUp					= MusicID_Start+1
MusID_Tutorial					= MusicID_Start+2
MusID_Unused					= MusicID_Start+3
MusID_TeethFunny				= MusicID_Start+4
MusID_Dendy						= MusicID_Start+5
MusID_Invincibility				= MusicID_Start+6
MusID_1UP						= MusicID_Start+7
MusID_Appendicitis				= MusicID_Start+8
MusID_Title						= MusicID_Start+9
MusID_Options					= MusicID_Start+10
MusID_Boss						= MusicID_Start+11
MusID_FinalBoss					= MusicID_Start+12
MusID_EndOfAct					= MusicID_Start+13
MusID_GameOver					= MusicID_Start+14
MusID_Continue					= MusicID_Start+15
MusID_Credits					= MusicID_Start+16
MusID_Drowning					= MusicID_Start+17
MusID_Emerald					= MusicID_Start+18
MusID_Owarisoft					= MusicID_Start+19
MusID_Spoony					= MusicID_Start+20
MusID_JoeTheHoe					= MusicID_Start+21
MusID_DzienDobry2				= MusicID_Start+22
; ===========================================================================
; Sound IDs
; ===========================================================================
SndID_Jump						= SFXID_Start+0
SndID_Checkpoint				= SFXID_Start+1
SndID_02						= SFXID_Start+2
SndID_Death						= SFXID_Start+3
SndID_Skid						= SFXID_Start+4
SndID_05						= SFXID_Start+5
SndID_HitSpike					= SFXID_Start+6
SndID_Push						= SFXID_Start+7
SndID_SSGoal					= SFXID_Start+8
SndID_SSItem					= SFXID_Start+9
SndID_Splash					= SFXID_Start+10
SndID_0B						= SFXID_Start+11
SndID_HitBoss					= SFXID_Start+12
SndID_GetBubble					= SFXID_Start+13
SndID_Fireball					= SFXID_Start+14
SndID_Shield					= SFXID_Start+15
SndID_Saw						= SFXID_Start+16
SndID_Electric					= SFXID_Start+17
SndID_Drown						= SFXID_Start+18
SndID_Flamethrower				= SFXID_Start+19
SndID_Bumper					= SFXID_Start+20
SndID_Ring						= SFXID_Start+21
SndID_SpikeMove					= SFXID_Start+22
SndID_Rumble					= SFXID_Start+23
SndID_18						= SFXID_Start+24
SndID_Collapse					= SFXID_Start+25
SndID_SSGlass					= SFXID_Start+26
SndID_Door						= SFXID_Start+27
SndID_Teleport					= SFXID_Start+28
SndID_ChainStomp				= SFXID_Start+29
SndID_Roll						= SFXID_Start+30
SndID_GetContinue				= SFXID_Start+31
SndID_BasaranFlap				= SFXID_Start+32
SndID_BreakItem					= SFXID_Start+33
SndID_DrownWarn					= SFXID_Start+34
SndID_GiantRing					= SFXID_Start+35
SndID_Bomb						= SFXID_Start+36
SndID_KaChing					= SFXID_Start+37
SndID_RingLoss					= SFXID_Start+38
SndID_ChainRise					= SFXID_Start+39
SndID_Burn						= SFXID_Start+40
SndID_HiddenBonus				= SFXID_Start+41
SndID_EnterSS					= SFXID_Start+42
SndID_WallSmash					= SFXID_Start+43
SndID_Spring					= SFXID_Start+44
SndID_Switch					= SFXID_Start+45
SndID_RingLeft					= SFXID_Start+46
SndID_Signpost					= SFXID_Start+47
; ===========================================================================
; Special SFX IDs
; ===========================================================================
SndID_Waterfall					= SpecSFXID_Start+0
; ===========================================================================
; Command IDs
; ===========================================================================
CmdID_FadeOut					= CmdID_Start+0
CmdID_SpeedUp					= CmdID_Start+1
CmdID_SlowDown					= CmdID_Start+2
CmdID_Stop						= CmdID_Start+3
; ===========================================================================
