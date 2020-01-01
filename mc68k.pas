(******************************************************************************)
(* This file contans the definitions of the interfaces of the MC68k class     *)
(* and the definitions of the constants needed.                               *)
(*                                                                            *)
(*                                                                            *)
(*                                                                            *)
(*                                                                            *)
(*                                                                            *)
(******************************************************************************)
{$DEFINE debug}
unit mc68k;
interface
uses sysutils;
const   nopcodes            =      $104;                                        //Represents the number of MC68k instructions class
        ndevices            =        30;                                        //Represents the max number of devices connected to MC68k
(*exceptions table*)
        Reset_Initial_SSP   =       $00;                                        //Reset Initial stack pionter.
        Reset_Initial_PC    =       $01;                                        //Reset Initial PC.
        BusError            =       $02;                                        //BusError
        AddressError        =       $03;                                        //AddressError
        IllegalInstruction  =       $04;                                        //IllegalInstruction
        ZeroDivide          =       $05;                                        //ZeroDivide
        CHKInstruction      =       $06;                                        //CHKInstruction
        TRAPVInstruction    =       $07;                                        //TRAPVInstruction
        PrivilegeViolation  =       $08;                                        //PrivilegeViolation
        Trace               =       $09;                                        //Trace
        Line1010Emulator    =       $0A;                                        //Line1010Emulator
        Line1111Emulator    =       $0B;                                        //Line1111Emulator
        SpuriousInterrupt   =       $18;                                        //SpuriousInterrupt
        Level1              =       $19;                                        //Level1
        Level2              =       $1A;                                        //Level2
        Level3              =       $1B;                                        //Level3
        Level4              =       $1C;                                        //Level4
        Level5              =       $1D;                                        //Level5
        Level6              =       $1E;                                        //Level6
        Level7              =       $1F;                                        //Level7
        Trap0               =       $20;                                        //Trap0
        Trap1               =       $21;                                        //Trap1
        Trap2               =       $22;                                        //Trap2
        Trap3               =       $23;                                        //Trap3
        Trap4               =       $24;                                        //Trap4
        Trap5               =       $25;                                        //Trap5
        Trap6               =       $26;                                        //Trap6
        Trap7               =       $27;                                        //Trap7
        Trap8               =       $28;                                        //Trap8
        Trap9               =       $29;                                        //Trap9
        TrapA               =       $2A;                                        //TrapA
        TrapB               =       $2B;                                        //TrapB
        TrapC               =       $2C;                                        //TrapC
        TrapD               =       $2D;                                        //TrapD
        TrapE               =       $2E;                                        //TrapE
        TrapF               =       $2F;                                        //TrapF
        TrapEx              =       $01;
        InterruptEx         =       $02;
        SWfaultEx           =       $04;
        BusFaultEx          =       $08;
        TrapOthersEx        =       $10;
        breakONaddress      =      $274;                                        //
        OperandEA           =       $3F;                                        //
        SourceEA            =       $3F;                                        //
        SourceAddrModeMask  =       $38;                                        //
        RegNoMask           =        $7;                                        //
        setFrameStackType0  =     $0000;
        setFrameStackType1  =     $1000;
        setFrameStackType2  =     $2000;
        setFrameStackTypeA  =     $A000;
        PopOutStack         =       $1F;                                        //
        PushInStack         =       $27;                                        //
        TraceSet            =     $C000;                                        //
        SupervisorFlagMask  =     $2000;                                        //
        MovecA_DRegister    =     $8000;                                        //
        MovecRegCodeMask    =      $FFF;                                        //
        MovecRegNoMask      =     $7000;                                        //
        MovecRegShift       =        $C;                                        //
        MovecDirection      =        $1;                                        //
        ImmediateValCode    =       $3C;                                        //
        High16bitMask       = $FFFF0000;                                        //
        Low16bitMask        =     $FFFF;                                        //
        SetSImmediate       =     $2000;                                        //
        ResetTTImmediate    =     $3FFF;
        ResetSImmediate     =     $DFFF;
        LongSizeConvertShift=         2;                                        //
        ResetNImmediate     =     $FFF7;                                        //
        SetNImmediate       =        $8;                                        //
        ResetCVImmediate    =     $FFFC;                                        //
        ResetCXImmediate    =     $FFEE;                                        //
        ResetCVZNImmediate  =     $FFF0;                                        //
        ResetVImmediate     =     $FFFD;                                        //
        ResetZImmediate     =     $FFFB;                                        //
        ResetCImmediate     =     $FFFE;
        SetZImmediate       =         4;                                        //
        SetCXImmediate      =       $11;                                        //
        SetVImmediate       =        $2;                                        //
        SetMImmediate       =     $1000;
        ResetMImmediate     =     $EFFF;
        ZFlagMask           =         4;                                        //
        ByteOperation       =         1;                                        //
        WordOperation       =         2;                                        //
        LongOperation       =         4;                                        //
        SP                  =         7;                                        //
        TrapValMask         =        $f;                                        //
        TrapValShift        =         2;                                        //
        MoveUSPDirection    =         8;                                        //
        DataReg_n           =       $00;                                        //
	AddressReg_n        =       $08;                                        //
	Indirect            =       $10;                                        //
	PostIncrIndirect    =       $18;                                        //
	PreDecrIndirect     =       $20;                                        //
	IndexedIndirect     =       $28;                                        //
	IndexedBaseIndirect =       $30;                                        //
	ImmediateVal        =       $38;                                        //
	MulDivSignMask      =      $800;                                        //
	MulDivSizeMask      =      $400;                                        //
        BtstShiftCount      =       $1F;                                        //
        BFopsCoutRegMask1   =      $800;
        BFopsCoutRegMask2   =       $20;
        BFopsDestEA         =     $7000;
        BFopsDestShift      =        $C;
        BFopsSource1EA      =      $7c0;
        BFopsSource1Shift   =         6;
        BFopsSource2EA      =       $1f;
        ShiftOpsImmVal      =      $e00;
        ShiftOpsImmshift    =         9;
        na                  =        $0;
        set0                =        $1;
        gen                 =        $2;
        bcd                 =        $3;
        _add                =        $4;
        _sub                =        $5;
        _asl                =        $6;
        set2x               =        $7;
        set1                =        $9;
        SaveFileName        = '.\sav\cpu.sav';
        MemoryFName         = '.\sav\memory.sav';
   cmpopcodes:array[0..nopcodes] of word=
  ($4E76,$4E72,$4E75,$4E77,$4E73,$4E74,$4E70,$007C,$003C,$4E71,$4AFC,$0A7C,$0A3C,$0CFC,$0EFC,
   $027C,$023C,$5FFA,$5FFB,$5FFC,$4E7B,$4E5F,$4847,$4E57,$480F,$48C7,$4887,$49C7,$484F,$4E4F,
   $4E6F,$4A7F,$4ABF,$4A3F,$4AFF,$047F,$04BF,$043F,$E4FF,$E5FF,$E6FF,$E7FF,$F03F,$F03F,$F03F,
   $F03F,$487F,$007F,$00BF,$003F,$467F,$46BF,$463F,$407F,$40BF,$403F,$447F,$44BF,$443F,$483F,
   $4C3F,$4C3F,$46FF,$44FF,$0E7F,$0EBF,$0E3F,$4CBF,$48BF,$4CFF,$48FF,$40FF,$42FF,$E2FF,$E3FF,
   $4EBF,$4EFF,$0A7F,$0ABF,$0A3F,$4C7F,$4C7F,$0C7F,$0CBF,$0C3F,$02FF,$04FF,$00FF,$427F,$42BF,
   $423F,$02FF,$04FF,$00FF,$0CFF,$0EFF,$0AFF,$083F,$08FF,$E8FF,$EEFF,$EFFF,$EDFF,$E9FF,$EBFF,
   $ECFF,$EAFF,$08BF,$087F,$027F,$02BF,$023F,$067F,$06BF,$063F,$E1FF,$E0FF,$09CF,$0DCF,$0BCF,
   $0FCF,$9F47,$9F4F,$9F87,$9F8F,$9F07,$9F0F,$EE77,$EEB7,$EE37,$EE57,$EE97,$EE17,$EF77,$EFB7,
   $EF37,$EF57,$EF97,$EF17,$EE7F,$EEBF,$EE3F,$EE5F,$EE9F,$EE1F,$EF7F,$EFBF,$EF3F,$EF5F,$EF9F,
   $EF1F,$EE6F,$EEAF,$EE2F,$EE4F,$EE8F,$EE0F,$EF6F,$EFAF,$EF2F,$EF4F,$EF8F,$EF0F,$CF47,$CF8F,
   $CF4F,$FE7F,$FE4F,$BF4F,$BF8F,$BF0F,$EE67,$EEA7,$EE27,$EE47,$EE87,$EE07,$EF67,$EFA7,$EF27,
   $EF47,$EF87,$EF07,$DF47,$DF87,$DF07,$DF4F,$DF0F,$DF8F,$5FCF,$8F8F,$8F0F,$8F4F,$CF0F,$61FF,
   $60FF,$5F7F,$5FBF,$5F3F,$9E7F,$9EFF,$9F7F,$9EBF,$9FFF,$9FBF,$9E3F,$9F3F,$8E7F,$8F7F,$8EBF,
   $8FBF,$8E3F,$8F3F,$CEFF,$CFFF,$4FFF,$8EFF,$8FFF,$FE7F,$FF3F,$FF7F,$FE3F,$FEFF,$FEBF,$BE7F,
   $BEFF,$BEBF,$BFFF,$BE3F,$4FBF,$4F3F,$0F3F,$0FFF,$0FBF,$0F7F,$CE7F,$CF7F,$CEBF,$CFBF,$CE3F,
   $CF3F,$5E7F,$5EBF,$5E3F,$DE7F,$DEFF,$DF7F,$DEBF,$DFFF,$DFBF,$DE3F,$DF3F,$5FFF,$7EFF,$3FFF,
   $2FFF,$1FFF,$BF7F,$BFBF,$BF3F,$6FFF);//Instruction pattern constants.
   mskopcodes:array[0..nopcodes] of word=
  ($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,
   $0000,$0000,$0F00,$0F00,$0F00,$0001,$0007,$0007,$0007,$0007,$0007,$0007,$0007,$0007,$000F,
   $000F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,
   $003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,
   $003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,
   $003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,
   $003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,
   $003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$003F,$01C7,$01C7,$01C7,
   $01C7,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,
   $0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,
   $0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,
   $0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,
   $0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0E07,$0F07,$0E0F,$0E0F,$0E0F,$0E0F,$00FF,
   $00FF,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,
   $0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,
   $0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,
   $0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0E3F,$0F3F,$0EFF,$0FFF,
   $0FFF,$0FFF,$0E3F,$0E3F,$0E3F,$0FFF);//Instruction mask constants.
{$IFDEF debug}
{   opcodNames:array[0..nopcodes] of string[25]=
(
'0x000 stop','0x001 rts','0x002 rtr','0x003 rte','0x004 rtd','0x005 resetmc68k','0x006 oritosr',
'0x007 oritoccr','0x008 nop','0x009 illegal','0x00A eoritosr','0x00B eoritoccr','0x00C cas2_w',
'0x00D cas2_l','0x00E anditosr','0x00F anditoccr','0x010 movec','0x011 unlk','0x012 swap',
'0x013 linkw','0x014 linkl','0x015 ext_w_to_l','0x016 ext_b_to_w','0x017 ext_b_to_l','0x018 bkpt',
'0x019 trap','0x01A moveusp','0x01B tst_w','0x01C tst_l','0x01D tst_b','0x01E tas','0x01F subi_w',
'0x020 subi_l','0x021 subi_b','0x022 roxr_ea','0x023 roxl_ea','0x024 ror_ea','0x025 rol_ea',
'0x026 ptest','0x027 pmove','0x028 pload','0x029 pflush','0x02A pea','0x02B ori_w','0x02C ori_l',
'0x02D ori_b','0x02E not_w','0x02F not_l','0x030 not_b','0x031 negx_w','0x032 negx_l','0x033 negx_b',
'0x034 neg_w','0x035 neg_l','0x036 neg_b','0x037 nbcd','0x038 mulul','0x039 mulsl','0x03A movetosr',
'0x03B movetoccr','0x03C moves_w','0x03D moves_l','0x03E moves_b','0x03F movem_w_to_regs','0x040 movem_w_to_mem',
'0x041 movem_l_to_regs','0x042 movem_l_to_mem','0x043 movefromsr','0x044 movefromccr','0x045 lsr_ea',
'0x046 lsl_ea','0x047 jsr','0x048 jmp','0x049 eori_w','0x04A eori_l','0x04B eori_b','0x04C divul',
'0x04D divl','0x04E cmpi_w','0x04F cmpi_l','0x050 cmpi_b','0x051 cmp2_w','0x052 cmp2_l','0x053 cmp2_b',
'0x054 clr_w','0x055 clr_l','0x056 clr_b','0x057 chk2_w','0x058 chk2_l','0x059 chk2_b','0x05A cas_w',
'0x05B cas_l','0x05C cas_b','0x05D btsti','0x05E bseti','0x05F bftst','0x060 bfset','0x061 bfins',
'0x062 bfffo','0x063 bfextu','0x064 bfexts','0x065 bfclr','0x066 bfchg','0x067 bclri','0x068 bchgi',
'0x069 andi_w','0x06A andi_l','0x06B andi_b','0x06C addi_w','0x06D addi_l','0x06E addi_b','0x06F asl_ea',
'0x070 asr_ea','0x071 movep_w_to_regs','0x072 movep_w_to_mem','0x073 movep_l_to_regs','0x074 movep_l_to_mem',
'0x075 subx_w_regs','0x076 subx_w_mem','0x077 subx_l_regs','0x078 subx_l_mem','0x079 subx_b_regs',
'0x07A subx_b_mem','0x07B roxri_w','0x07C roxri_l','0x07D roxri_b','0x07E roxr_w','0x07F roxr_l',
'0x080 roxr_b','0x081 roxli_w','0x082 roxli_l','0x083 roxli_b','0x084 roxl_w','0x085 roxl_l',
'0x086 roxl_b','0x087 rori_w','0x088 rori_l','0x089 rori_b','0x08A ror_w','0x08B ror_l','0x08C ror_b',
'0x08D rol_w','0x08E rol_l','0x08F rol_b','0x090 roli_w','0x091 roli_l','0x092 roli_b','0x093 lsr_w_Dn_Dm',
'0x094 lsr_l_Dn_Dm','0x095 lsr_b_Dn_Dm','0x096 lsri_w','0x097 lsri_l','0x098 lsri_b','0x099 lsl_w_Dn_Dm','0x09A lsl_l_Dn_Dm',
'0x09B lsl_b_Dn_Dm','0x09C lsli_w','0x09D lsli_l','0x09E lsli_b','0x09F exg_Dn_Dm','0x0A0 exg_An_Dm','0x0A1 exg_An_Am',
'0x0A2 cptrapcc','0x0A3 cpdbcc','0x0A4 cmpm_w','0x0A5 cmpm_l','0x0A6 cmpm_b','0x0A7 asr_w','0x0A8 asr_l',
'0x0A9 asr_b','0x0AA asri_w','0x0AB asri_l','0x0AC asri_b','0x0AD asl_w','0x0AE asl_l','0x0AF asl_b',
'0x0B0 asli_w','0x0B1 asli_l','0x0B2 asli_b','0x0B3 addx_b_regs','0x0B4 addx_b_regs','0x0B5 addx_b_regs','0x0B6 addx_b_mem',
'0x0B7 addx_b_mem','0x0B8 addx_b_mem','0x0B9 trapcc','0x0BA dbcc','0x0BB unpk','0x0BC sbcd','0x0BD pack',
'0x0BE abcd','0x0BF bsr','0x0C0 bra','0x0C1 subq_w','0x0C2 subq_l','0x0C3 subq_b','0x0C4 sub_w_ea_Dn',
'0x0C5 sub_w_ea_An','0x0C6 sub_w_Dn_ea','0x0C7 sub_l_ea_Dn','0x0C8 sub_l_ea_An','0x0C9 sub_l_Dn_ea','0x0CA sub_b_ea_Dn','0x0CB sub_b_Dn_ea',
'0x0CC or_w_ea_Dn','0x0CD or_w_Dn_ea','0x0CE or_l_ea_Dn','0x0CF or_l_Dn_ea','0x0D0 or_b_ea_Dn','0x0D1 or_b_Dn_ea','0x0D2 muluw',
'0x0D3 mulsw','0x0D4 lea','0x0D5 divu','0x0D6 divs','0x0D7 cpscc','0x0D8 cpsave','0x0D9 cprestore',
'0x0DA cpgen','0x0DB cpbcc_32','0x0DC cpbcc_16','0x0DD cmp_w_ea_Dn','0x0DE cmp_w_ea_An','0x0DF cmp_l_ea_Dn','0x0E0 cmp_l_ea_An',
'0x0E1 cmp_b_ea_Dn','0x0E2 chk_w','0x0E3 chk_l','0x0E4 btst','0x0E5 bset','0x0E6 bclr','0x0E7 bchg',
'0x0E8 and_w_ea_Dn','0x0E9 and_w_Dn_ea','0x0EA and_l_ea_Dn','0x0EB and_l_Dn_ea','0x0EC and_b_ea_Dn','0x0ED and_b_Dn_ea','0x0EE addq_w',
'0x0EF addq_l','0x0F0 addq_b','0x0F1 add_w_ea_Dn','0x0F2 add_w_ea_An','0x0F3 add_w_Dn_ea','0x0F4 add_l_ea_Dn','0x0F5 add_l_ea_An',
'0x0F6 add_l_Dn_ea','0x0F7 add_b_ea_Dn','0x0F8 add_b_Dn_ea','0x0F9 scc','0x0FA moveq','0x0FB move_w','0x0FC move_l',
'0x0FD move_b','0x0FE eor_w_Dn_ea','0x0FF eor_l_Dn_ea','0x100 eor_b_Dn_ea','0x101 bcc');}        //Instruction names constant.
{$ENDIF}
type unhandled_instruction = Class(Exception);
type regs68k=record                                                             //MC68k Registers definition.
              d           : array[0..7]of longword;                             //The 8 D registers.
              a           : array[0..7]of longword;                             //The 8 A registers.
              usp         : Longword;                                           //User Stack pointer register.              msp         : Longword;                                           //Master Stack pointer register.
              isp         : Longword;                                           //Interrupt Stack pointer register.
              msp         : Longword;                                           //master Stack pointer register.
              pc          : Longword;                                           //Program Counter.
              cacr        : Longword;                                           //Cache control register.
              caar        : Longword;                                           //Cache address register.
              dfc         : Longword;                                           //Destination Function Code register.
              sfc         : Longword;                                           //Source Function Code register.
              tt1         : Longword;                                           //Transparent Translation register 1
              tt0         : Longword;                                           //Transparent Translation register 0
              vbr         : longword;                                           //Vectors Base regiser
              sr          : word;                                               //Status register.
              endtag      : longword;
            end;
            DeviceReadFun8   = function  (address:word):byte of object;         //This is the type of the 8 bits reading functions.
            DeviceWriteFun8  = procedure (address:word;data:byte) of object;         //This is the type of the 8 bits writing functions.
            DeviceReadFun16  = function  (address:word):word of object;         //This is the type of the 16 bits reading functions.
            DeviceWriteFun16 = procedure (address:word;data:word) of object;         //This is the type of the 16 bits writing functions.
            DeviceReadFun32  = function  (address:word):longword of object; //This is the type of the 32 bits reading functions.
            DeviceWriteFun32 = procedure (address:word;data:longword) of object;     //This is the type of the 32 bits writing functions.
            vfun             = function  (address:longword):byte of object;
            resproc          = procedure of object;
            ExcStack         = class(exception);

type cpu68k =class                                                              (******************************************************************************)
                                                                                (* MC68k emulator core.                                                       *)
                                                                                (* The decode routine uses this constant to identify the current instruction. *)
                                                                                (* The algorithm uses mask constants on current opcode and then match with    *)
                                                                                (* instruction pattern.                                                       *)
                                                                                (* For the interfacing with devices is meant that each device has a function  *)
                                                                                (* for readings and a procedure for writings.                                 *)
                                                                                (******************************************************************************)
(***********************************************************)
(**)                     private                         (**)
(***********************************************************)

   InternalCopySR   : word;
   ExcTypeSP        : byte;
   s32              : longword;                                                 //This coneins 32 bits source operand data.
   d32              : longword;                                                 //This coneins 32 bits destination operand data.
   ris32            : longword;                                                 //This coneins 32 bits result operand data.
   s16              : word;                                                     //This coneins 16 bits source operand data.
   d16              : word;                                                     //This coneins 16 bits destination operand data.
   ris16            : word;                                                     //This coneins 16 bits result operand data.
   s8               : byte;                                                     //This coneins 8 bits source operand data.
   d8               : byte;                                                     //This coneins 8 bits destination operand data.
   ris8             : byte;                                                     //This coneins 8 bits result operand data.
   deviceNOW8       : byte;                                                     //Indicates the actual number of 8 bits devices mapped in IOspace.
   deviceNOW16      : byte;                                                     //Indicates the actual number of 16 bits devices mapped in IOspace.
   deviceNOW32      : byte;                                                     //Indicates the actual number of 32 bits devices mapped in IOspace.
   extword          : word;
   data             : longword;
   addpc            : longword;
   NoUseButItsAddress1: byte;
(*-----------------------------------------------------------------------------*)
   dp32             : ^longword;
   creg             : ^longword;
   handlingRoutines : array[0..nopcodes]       of procedure of object;          //Each element of this vector contains a pointer to an instruction handling routine.
   MemoryMap        : array[0..4095]           of pointer;                      //1Mb paged Memory map
   MemMapDevR8      : array[0..ndevices]       of deviceReadFun8;               //Each element of this vector contains a pointer to the correspective device 8 bits reading routine.
   MemMapDevW8      : array[0..ndevices]       of deviceWriteFun8;              //Each element of this vector contains a pointer to the correspective device 8 bits writing routine.
   MemMapDevR16     : array[0..ndevices]       of deviceReadFun16;              //Each element of this vector contains a pointer to the correspective device 16 bits reading routine.
   MemMapDevW16     : array[0..ndevices]       of deviceWriteFun16;             //Each element of this vector contains a pointer to the correspective device 16 bits writing routine.
   MemMapDevR32     : array[0..ndevices]       of deviceReadFun32;              //Each element of this vector contains a pointer to the correspective device 32 bits reading routine.
   MemMapDevW32     : array[0..ndevices]       of deviceWriteFun32;             //Each element of this vector contains a pointer to the correspective device 32 bits writing routine.
   MemMapIO8        : array [0..ndevices,0..1] of longword;                     //This represents the map of the devices mapped in the 8 bits IOspace. The first element is the Base Address, the second, the memory space length.
   MemMapIO16       : array [0..ndevices,0..1] of longword;                     //This represents the map of the devices mapped in the 16 bits IOspace. The first element is the Base Address, the second, the memory space length.
   MemMapIO32       : array [0..ndevices,0..1] of longword;                     //This represents the map of the devices mapped in the 32 bits IOspace. The first element is the Base Address, the second, the memory space length.
   DecodeTable      :  array[0..$FFFF] of procedure of object;
{$IFDEF debug}
   instrStat        : array [0..nopcodes,0..3]of int64;
{$ENDIF}
   ResetIO          : resproc;
   function  warpround(address:longword)            : longword;
   function  RegModSwap(n:byte)                     : byte;                     //This is meant to be used internally. It swaps the first 3 bits and the second 3 bits of the 6 bits addressing identifier.
   function  Signext8(w:byte)                       : longword;                 //Extend a byte to longword type maintaining thi sign.
   function  Signext16(w:word)                      : longword;                 //Extend a word to longword type maintaining thi sign.
   function  LBW(l:longword)                        : longword;                 //Operate a conversion little-big endian for word types.
   function  LBL(l:longword)                        : longword;                 //Operate a conversion little-big endian for word types.
   function  Getbyte(address:longword;var page)     : byte;                     //This is meant to be used internally. Perform a low level readings with little-big endian conversion for byte types.
   function  Getword(address:longword;var page)     : word;                     //This is meant to be used internally. Perform a low level readings with little-big endian conversion for word types.
   function  Getlongword(address:longword;var page) : longword;                 //This is meant to be used internally. Perform a low level readings with little-big endian conversion for byte types.Perform a low level readings with little-big endian conversion for longword types.
   function  ConditionTest(b:byte):boolean;                                     //This is meant to be used internally. Perform a test on MC68k's CR using native MC68k codes as input.
   function  SourceOperand8(code:byte):byte;                                    //This is meant to be used internally. Addressing decode routine for 8 bits readings.
   function  SourceOperand16(code:byte):word;                                   //This is meant to be used internally. Addressing decode routine for 16 bits readings.
   function  SourceOperand32(code:byte):longword;                               //This is meant to be used internally. Addressing decode routine for 32 bits readings.
   function  jmpOperand(code:byte):longword;                                    //This is meant to be used internally. Addressing decode routine for jump instructions.
   function  add_0x28(Areg:longword):longword;                                  //This is meant to be used internally. Addressing decode for extend word 0x28.
   function  add_0x30(code:word):longword;                                      //This is meant to be used internally. Addressing decode for extend word 0x30.
   function  add_0x38(code,size:word):longword;                                 //This is meant to be used internally. Addressing decode for extend word 0x38.
   function  validatefake(address:longword):byte;
   function  addrcalc(addr1,addr2:pointer):longword;
   function  bfGETu(data:longword;offs,dep:byte):longword;
   function  bfGETs(data:longword;offs,dep:byte):longword;
   function  lo16(data:longword):word;   
   function sar8 (var b:byte;    count:byte):boolean;
   function sar16(var b:word;    count:byte):boolean;
   function sar32(var b:longword;count:byte):boolean;
   function sal8 (var b:byte;    count:byte):boolean;
   function sal16(var b:word;    count:byte):boolean;
   function sal32(var b:longword;count:byte):boolean;
   function shr8 (var b:byte;    count:byte):boolean;
   function shr16(var b:word;    count:byte):boolean;
   function shr32(var b:longword;count:byte):boolean;
   function shl8 (var b:byte;    count:byte):boolean;
   function shl16(var b:word;    count:byte):boolean;                           //This is meant to be used internally.
   function shl32(var b:longword;count:byte):boolean;                           //This is meant to be used internally.

   function ror8 (var b:byte;    count:byte):boolean;
   function ror16(var b:word;    count:byte):boolean;
   function ror32(var b:longword;count:byte):boolean;
   function rol8 (var b:byte;    count:byte):boolean;
   function rol16(var b:word;    count:byte):boolean;
   function rol32(var b:longword;count:byte):boolean;

   function rcr8 (var b:byte;    count,carry:byte):boolean;
   function rcr16(var w:word;    count,carry:byte):boolean;
   function rcr32(var l:longword;count,carry:byte):boolean;
   function rcl8 (var b:byte;    count,carry:byte):boolean;
   function rcl16(var w:word;    count,carry:byte):boolean;
   function rcl32(var l:longword;count,carry:byte):boolean;

   procedure fakeResetIO;
   procedure except_exec(vector:longword;Ex_type:byte);
   Procedure divu64(op1hig,op1low,op2low,op2hig:longword;var reslow,reshig:longword);
   procedure DestinationOperand8(code:byte;data:byte);                          //This is meant to be used internally. Addressing decode routine for 8 bits writings.
   procedure DestinationOperand16(code:byte;data:word);                         //This is meant to be used internally. Addressing decode routine for 16 bits writings.
   procedure DestinationOperand32(code:byte;data:longword);                     //This is meant to be used internally. Addressing decode routine for 32 bits writings.
   procedure Putbyte(address:longword;val:byte;var page);                       //This is meant to be used internally. Perform a low level writings with little-big endian conversion for byte types.
   procedure Putword(address:longword;val:word;var page);                       //This is meant to be used internally. Perform a low level writings with little-big endian conversion for byte types.
   procedure Putlongword(address,val:longword;var page);                        //This is meant to be used internally. Perform a low level writings with little-big endian conversion for byte types.
   procedure update_ccr(x,n,z,v,c:byte;source,destination,res:longword;size:byte);
   //##                                 instrictions
   procedure fail;
   procedure trapv;
   procedure stop;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rts;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rtr;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rte;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rtd;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure resetmc68k;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure oritosr;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure oritoccr;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure nop;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure illegal;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eoritosr;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eoritoccr;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cas2_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cas2_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure anditosr;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure anditoccr;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movec;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure unlk;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure swap;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure linkw;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure linkl;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ext_w_to_l;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ext_b_to_w;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ext_b_to_l;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bkpt;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure trap;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure moveusp;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure tst_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure tst_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure tst_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure tas;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subi_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subi_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subi_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxr_ea;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxl_ea;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ror_ea;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rol_ea;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ptest;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure pmove;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure pload;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure pflush;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure pea;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ori_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ori_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ori_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure not_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure not_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure not_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure negx_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure negx_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure negx_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure neg_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure neg_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure neg_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure nbcd;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure mulul;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure mulsl;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movetosr;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movetoccr;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure moves_w;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure moves_l;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure moves_b;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movem_w_to_regs;                                                   //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movem_w_to_mem;                                                    //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movem_l_to_regs;                                                   //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movem_l_to_mem;                                                    //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movefromsr;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movefromccr;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsr_ea;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsl_ea;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure jsr;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure jmp;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eori_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eori_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eori_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure divul;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure divl;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmpi_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmpi_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmpi_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp2_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp2_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp2_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure clr_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure clr_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure clr_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure chk2_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure chk2_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure chk2_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cas_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cas_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cas_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure btsti;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bseti;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bftst;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfset;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfins;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfffo;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfextu;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfexts;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfclr;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bfchg;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bclri;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bchgi;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure andi_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure andi_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure andi_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addi_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addi_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addi_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asr_ea;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asl_ea;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movep_w_to_regs;                                                   //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movep_w_to_mem;                                                    //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movep_l_to_regs;                                                   //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure movep_l_to_mem;                                                    //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxri_w;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxri_l;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxri_b;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxr_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxr_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxr_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxli_w;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxli_l;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxli_b;                                                           //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxl_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxl_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roxl_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rori_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rori_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rori_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ror_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ror_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure ror_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roli_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roli_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure roli_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rol_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rol_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure rol_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsri_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsri_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsri_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsr_w_Dn_Dm;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsr_l_Dn_Dm;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsr_b_Dn_Dm;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsli_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsli_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsli_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsl_w_Dn_Dm;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsl_l_Dn_Dm;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lsl_b_Dn_Dm;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure exg_Dn_Dm;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure exg_An_Dm;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure exg_An_Am;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cptrapcc;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cpdbcc;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmpm_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmpm_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmpm_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asri_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asri_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asri_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asr_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asr_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asr_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asli_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asli_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asli_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asl_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asl_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure asl_b;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addx_w_regs;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addx_l_regs;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addx_b_regs;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addx_w_mem;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addx_b_mem;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addx_l_mem;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure trapcc;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure trapcc_w;
   procedure trapcc_l;
   procedure dbcc;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure unpk;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sbcd;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure pack;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure abcd;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bsr;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bra;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subx_w_regs;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subx_w_mem;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subx_l_regs;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subx_l_mem;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subx_b_regs;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subx_b_mem;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subq_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subq_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure subq_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_w_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_w_ea_An;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_w_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_l_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_l_ea_An;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_l_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_b_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure sub_b_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure or_w_ea_Dn;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure or_w_Dn_ea;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure or_l_ea_Dn;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure or_l_Dn_ea;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure or_b_ea_Dn;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure or_b_Dn_ea;                                                        //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure muluw;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure mulsw;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure lea;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure divu;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure divs;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cpscc;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cpsave;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cprestore;                                                         //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cpgen;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cpbcc_32;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cpbcc_16;                                                          //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp_w_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp_w_ea_An;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp_l_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp_l_ea_An;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure cmp_b_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure chk_w;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure chk_l;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure btst;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bset;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bclr;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bchg;                                                              //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure and_w_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure and_w_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure and_l_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure and_l_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure and_b_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure and_b_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addq_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addq_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure addq_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_w_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_w_ea_An;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_w_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_l_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_l_ea_An;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_l_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_b_ea_Dn;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure add_b_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure scc;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure moveq;                                                             //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure move_w;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure move_l;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure move_b;                                                            //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eor_w_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eor_l_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure eor_b_Dn_ea;                                                       //this is meant to be used internally. It's function is to handle the [...] class instructions.
   procedure bcc;                                                               //this is meant to be used internally. It's function is to handle the [...] class instructions.
//##                                 instrictions end
(***********************************************************)
(**)                     protected                       (**)
(***********************************************************)
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
   OldPC               : longword;
   DebugNoCount        : boolean;                                               //When this is true, cpu doesn't count cyles.
   CPUCycles           : int64;                                                 //Keeps the number of cpu cycles.
   WarpRoundWrite      : longword;                                              //Adds warp round to memory.
   currentOPcode       : word;                                                  //Holds curret Operation Code.
   regs                : regs68k;                                               //68k registers set.
   cpuStatus           : byte;                                                  //Indicates Processor state.
   fake_intNo          : byte;                                                  //Fake interrupt pending No variable. Added to use an external interrupt controller.
   fake_pending        : boolean;                                               //Fake interrupt pending variable. Added to use an external interrupt controller.
   NoUseButItsAddress2 : byte;
{$IFDEF debug}
   DoldPc           : longword;
   MOpc             : longword;
   prevflags        : word;
   addrcount        : longword;
   trace_facility   : array[0..500] of longword;
   trace_top        : byte;
   currentINSTR :string [30];
{$ENDIF}
   validateFun         : vfun;                                                  //Addresses pass through this function in order to be validated. Default is an iconstant true function.
   pending_interrupt   : ^boolean;                                              //Indicates if an interrupt is pending.
   pending_interruptNo : ^byte;                                                 //Holds pending interrupt number.
   constructor create;                                                          //Default constructor.
   function  Opcod                          : string;                           //Converts a Operation code to correspective mnemonic string.
   function  MemoryRead8(address:longword)  : byte;                             //Perform a Byte reading from memory.
   function  MemoryRead16(address:longword) : word;                             //Perform a Word reading from memory.
   function  MemoryRead32(address:longword) : longword;                         //Perform a Long reading from memory.
   procedure setResetio(r:ResProc);
   procedure BuildTables;                                                       //Fills istruction's handler pointer table.
   procedure AddMemoryPage(No:word;page:pointer);                               //Adds a 1MB page into Memory MAP.
   {$IFdef debug}
   procedure savestat;
   {$ENDIF}
   procedure dump;
   procedure RestoreMemory;
   procedure CPUStatusSave;
   procedure CPUStatusRestore;
   procedure Fetch;                                                             //Fetch the next operation and updates currentOPcode.
   procedure Execute;                                                           //Execute the currentOPcode instruction and updates Memory and machine status.
   procedure SetPC(addrpc:longword);                                            //Sets PC address.
   procedure Reset68k;                                                          //Resets machine status.
   Procedure Interrupt(intr:byte);                                              //Generate Irq specified interrupt.
   procedure MemoryWrite8(address:longword;data:byte);                          //Writes a Byte into memory.
   procedure MemoryWrite16(address:longword;data:word);                         //Writes a Word into memory.
   procedure MemoryWrite32(address:longword;data:longword);                     //Writes a Long into memory.
   procedure AddDevice8(address,addrDepth:longword;
                        r:deviceReadFun8;w:devicewriteFun8);                    //Adds a device in MC68k's memory space..
   procedure AddDevice16(address,addrDepth:longword;
                        r:deviceReadFun16;w:devicewriteFun16);                  //Adds a device in MC68k's memory space..
   procedure AddDevice32(address,addrDepth:longword;
                        r:deviceReadFun32;w:devicewriteFun32);                  //Adds a device in MC68k's memory space..
   Procedure InstallIntCtrl(PInt,PIntNo:pointer);                               //Assigns an interrupt controller to the CPU.
  end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)

{$I assemblers.pas}    //Assmebly routines
{$I init.pas}          //Initializzation routines
{$I instructions.pas}  //instruction's code
{$I memories.pas}      //memory utilities
{$I utils.pas}         //misc utilities
{$I addressing.pas}    //addressing routines

end.
