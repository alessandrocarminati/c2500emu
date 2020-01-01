(******************************************************************************)
(* This file contans the implementations of the initializzation routines.     *)
(*                                                                            *)
(******************************************************************************)
constructor cpu68k.create;
begin
regs.sr:=$4000;
end;
(***********************************************************)
procedure cpu68k.reset68k;
begin
resetmc68k;
end;
(***********************************************************)
procedure cpu68k.buildTables;
var j,i:word;
    (*p:pointer;*)
begin

{Build decode table}
handlingRoutines[$000]:=self.trapv;
handlingRoutines[$001]:=self.stop;
handlingRoutines[$002]:=self.rts;
handlingRoutines[$003]:=self.rtr;
handlingRoutines[$004]:=self.rte;
handlingRoutines[$005]:=self.rtd;
handlingRoutines[$006]:=self.resetmc68k;
handlingRoutines[$007]:=self.oritosr;
handlingRoutines[$008]:=self.oritoccr;
handlingRoutines[$009]:=self.nop;
handlingRoutines[$00A]:=self.illegal;
handlingRoutines[$00B]:=self.eoritosr;
handlingRoutines[$00C]:=self.eoritoccr;
handlingRoutines[$00D]:=self.cas2_w;
handlingRoutines[$00E]:=self.cas2_l;
handlingRoutines[$00F]:=self.anditosr;
handlingRoutines[$010]:=self.anditoccr;
handlingRoutines[$011]:=self.trapcc_w;
handlingRoutines[$012]:=self.trapcc_l;
handlingRoutines[$013]:=self.trapcc;
handlingRoutines[$014]:=self.movec;
handlingRoutines[$015]:=self.unlk;
handlingRoutines[$016]:=self.swap;
handlingRoutines[$017]:=self.linkw;
handlingRoutines[$018]:=self.linkl;
handlingRoutines[$019]:=self.ext_w_to_l;
handlingRoutines[$01A]:=self.ext_b_to_w;
handlingRoutines[$01B]:=self.ext_b_to_l;
handlingRoutines[$01C]:=self.bkpt;
handlingRoutines[$01D]:=self.trap;
handlingRoutines[$01E]:=self.moveusp;
handlingRoutines[$01F]:=self.tst_w;
handlingRoutines[$020]:=self.tst_l;
handlingRoutines[$021]:=self.tst_b;
handlingRoutines[$022]:=self.tas;
handlingRoutines[$023]:=self.subi_w;
handlingRoutines[$024]:=self.subi_l;
handlingRoutines[$025]:=self.subi_b;
handlingRoutines[$026]:=self.roxr_ea;
handlingRoutines[$027]:=self.roxl_ea;
handlingRoutines[$028]:=self.ror_ea;
handlingRoutines[$029]:=self.rol_ea;
handlingRoutines[$02A]:=self.ptest;
handlingRoutines[$02B]:=self.pmove;
handlingRoutines[$02C]:=self.pload;
handlingRoutines[$02D]:=self.pflush;
handlingRoutines[$02E]:=self.pea;
handlingRoutines[$02F]:=self.ori_w;
handlingRoutines[$030]:=self.ori_l;
handlingRoutines[$031]:=self.ori_b;
handlingRoutines[$032]:=self.not_w;
handlingRoutines[$033]:=self.not_l;
handlingRoutines[$034]:=self.not_b;
handlingRoutines[$035]:=self.negx_w;
handlingRoutines[$036]:=self.negx_l;
handlingRoutines[$037]:=self.negx_b;
handlingRoutines[$038]:=self.neg_w;
handlingRoutines[$039]:=self.neg_l;
handlingRoutines[$03A]:=self.neg_b;
handlingRoutines[$03B]:=self.nbcd;
handlingRoutines[$03C]:=self.mulul;
handlingRoutines[$03D]:=self.mulsl;
handlingRoutines[$03E]:=self.movetosr;
handlingRoutines[$03F]:=self.movetoccr;
handlingRoutines[$040]:=self.moves_w;
handlingRoutines[$041]:=self.moves_l;
handlingRoutines[$042]:=self.moves_b;
handlingRoutines[$043]:=self.movem_w_to_regs;
handlingRoutines[$044]:=self.movem_w_to_mem;
handlingRoutines[$045]:=self.movem_l_to_regs;
handlingRoutines[$046]:=self.movem_l_to_mem;
handlingRoutines[$047]:=self.movefromsr;
handlingRoutines[$048]:=self.movefromccr;
handlingRoutines[$049]:=self.lsr_ea;
handlingRoutines[$04A]:=self.lsl_ea;
handlingRoutines[$04B]:=self.jsr;
handlingRoutines[$04C]:=self.jmp;
handlingRoutines[$04D]:=self.eori_w;
handlingRoutines[$04E]:=self.eori_l;
handlingRoutines[$04F]:=self.eori_b;
handlingRoutines[$050]:=self.divul;
handlingRoutines[$051]:=self.divl;
handlingRoutines[$052]:=self.cmpi_w;
handlingRoutines[$053]:=self.cmpi_l;
handlingRoutines[$054]:=self.cmpi_b;
handlingRoutines[$055]:=self.cmp2_w;
handlingRoutines[$056]:=self.cmp2_l;
handlingRoutines[$057]:=self.cmp2_b;
handlingRoutines[$058]:=self.clr_w;
handlingRoutines[$059]:=self.clr_l;
handlingRoutines[$05A]:=self.clr_b;
handlingRoutines[$05B]:=self.chk2_w;
handlingRoutines[$05C]:=self.chk2_l;
handlingRoutines[$05D]:=self.chk2_b;
handlingRoutines[$05E]:=self.cas_w;
handlingRoutines[$05F]:=self.cas_l;
handlingRoutines[$060]:=self.cas_b;
handlingRoutines[$061]:=self.btsti;
handlingRoutines[$062]:=self.bseti;
handlingRoutines[$063]:=self.bftst;
handlingRoutines[$064]:=self.bfset;
handlingRoutines[$065]:=self.bfins;
handlingRoutines[$066]:=self.bfffo;
handlingRoutines[$067]:=self.bfextu;
handlingRoutines[$068]:=self.bfexts;
handlingRoutines[$069]:=self.bfclr;
handlingRoutines[$06A]:=self.bfchg;
handlingRoutines[$06B]:=self.bclri;
handlingRoutines[$06C]:=self.bchgi;
handlingRoutines[$06D]:=self.andi_w;
handlingRoutines[$06E]:=self.andi_l;
handlingRoutines[$06F]:=self.andi_b;
handlingRoutines[$070]:=self.addi_w;
handlingRoutines[$071]:=self.addi_l;
handlingRoutines[$072]:=self.addi_b;
handlingRoutines[$073]:=self.asl_ea;
handlingRoutines[$074]:=self.asr_ea;
handlingRoutines[$075]:=self.movep_w_to_regs;
handlingRoutines[$076]:=self.movep_w_to_mem;
handlingRoutines[$077]:=self.movep_l_to_regs;
handlingRoutines[$078]:=self.movep_l_to_mem;
handlingRoutines[$079]:=self.subx_w_regs;
handlingRoutines[$07A]:=self.subx_w_mem;
handlingRoutines[$07B]:=self.subx_l_regs;
handlingRoutines[$07C]:=self.subx_l_mem;
handlingRoutines[$07D]:=self.subx_b_regs;
handlingRoutines[$07E]:=self.subx_b_mem;
handlingRoutines[$07F]:=self.roxri_w;
handlingRoutines[$080]:=self.roxri_l;
handlingRoutines[$081]:=self.roxri_b;
handlingRoutines[$082]:=self.roxr_w;
handlingRoutines[$083]:=self.roxr_l;
handlingRoutines[$084]:=self.roxr_b;
handlingRoutines[$085]:=self.roxli_w;
handlingRoutines[$086]:=self.roxli_l;
handlingRoutines[$087]:=self.roxli_b;
handlingRoutines[$088]:=self.roxl_w;
handlingRoutines[$089]:=self.roxl_l;
handlingRoutines[$08A]:=self.roxl_b;
handlingRoutines[$08B]:=self.rori_w;
handlingRoutines[$08C]:=self.rori_l;
handlingRoutines[$08D]:=self.rori_b;
handlingRoutines[$08E]:=self.ror_w;
handlingRoutines[$08F]:=self.ror_l;
handlingRoutines[$090]:=self.ror_b;
handlingRoutines[$091]:=self.rol_w;
handlingRoutines[$092]:=self.rol_l;
handlingRoutines[$093]:=self.rol_b;
handlingRoutines[$094]:=self.roli_w;
handlingRoutines[$095]:=self.roli_l;
handlingRoutines[$096]:=self.roli_b;

handlingRoutines[$097]:=self.lsr_w_Dn_Dm;
handlingRoutines[$098]:=self.lsr_l_Dn_Dm;
handlingRoutines[$099]:=self.lsr_b_Dn_Dm;
handlingRoutines[$09A]:=self.lsri_w;
handlingRoutines[$09B]:=self.lsri_l;
handlingRoutines[$09C]:=self.lsri_b;

handlingRoutines[$09D]:=self.lsl_w_Dn_Dm;
handlingRoutines[$09E]:=self.lsl_l_Dn_Dm;
handlingRoutines[$09F]:=self.lsl_b_Dn_Dm;
handlingRoutines[$0A0]:=self.lsli_w;
handlingRoutines[$0A1]:=self.lsli_l;
handlingRoutines[$0A2]:=self.lsli_b;

handlingRoutines[$0A3]:=self.exg_Dn_Dm;
handlingRoutines[$0A4]:=self.exg_An_Dm;
handlingRoutines[$0A5]:=self.exg_An_Am;
handlingRoutines[$0A6]:=self.cptrapcc;
handlingRoutines[$0A7]:=self.cpdbcc;
handlingRoutines[$0A8]:=self.cmpm_w;
handlingRoutines[$0A9]:=self.cmpm_l;
handlingRoutines[$0AA]:=self.cmpm_b;
handlingRoutines[$0AB]:=self.asr_w;
handlingRoutines[$0AC]:=self.asr_l;
handlingRoutines[$0AD]:=self.asr_b;
handlingRoutines[$0AE]:=self.asri_w;
handlingRoutines[$0AF]:=self.asri_l;
handlingRoutines[$0B0]:=self.asri_b;
handlingRoutines[$0B1]:=self.asl_w;
handlingRoutines[$0B2]:=self.asl_l;
handlingRoutines[$0B3]:=self.asl_b;
handlingRoutines[$0B4]:=self.asli_w;
handlingRoutines[$0B5]:=self.asli_l;
handlingRoutines[$0B6]:=self.asli_b;
handlingRoutines[$0B7]:=self.addx_w_regs;
handlingRoutines[$0B8]:=self.addx_l_regs;
handlingRoutines[$0B9]:=self.addx_b_regs;
handlingRoutines[$0BA]:=self.addx_w_mem;
handlingRoutines[$0BB]:=self.addx_l_mem;
handlingRoutines[$0BC]:=self.addx_b_mem;
handlingRoutines[$0BD]:=self.dbcc;
handlingRoutines[$0BE]:=self.unpk;
handlingRoutines[$0BF]:=self.sbcd;
handlingRoutines[$0C0]:=self.pack;
handlingRoutines[$0C1]:=self.abcd;
handlingRoutines[$0C2]:=self.bsr;
handlingRoutines[$0C3]:=self.bra;
handlingRoutines[$0C4]:=self.subq_w;
handlingRoutines[$0C5]:=self.subq_l;
handlingRoutines[$0C6]:=self.subq_b;
handlingRoutines[$0C7]:=self.sub_w_ea_Dn;
handlingRoutines[$0C8]:=self.sub_w_ea_An;
handlingRoutines[$0C9]:=self.sub_w_Dn_ea;
handlingRoutines[$0CA]:=self.sub_l_ea_Dn;
handlingRoutines[$0CB]:=self.sub_l_ea_An;
handlingRoutines[$0CC]:=self.sub_l_Dn_ea;
handlingRoutines[$0CD]:=self.sub_b_ea_Dn;
handlingRoutines[$0CE]:=self.sub_b_Dn_ea;
handlingRoutines[$0CF]:=self.or_w_ea_Dn;
handlingRoutines[$0D0]:=self.or_w_Dn_ea;
handlingRoutines[$0D1]:=self.or_l_ea_Dn;
handlingRoutines[$0D2]:=self.or_l_Dn_ea;
handlingRoutines[$0D3]:=self.or_b_ea_Dn;
handlingRoutines[$0D4]:=self.or_b_Dn_ea;
handlingRoutines[$0D5]:=self.muluw;
handlingRoutines[$0D6]:=self.mulsw;
handlingRoutines[$0D7]:=self.lea;
handlingRoutines[$0D8]:=self.divu;
handlingRoutines[$0D9]:=self.divs;
handlingRoutines[$0DA]:=self.cpscc;
handlingRoutines[$0DB]:=self.cpsave;
handlingRoutines[$0DC]:=self.cprestore;
handlingRoutines[$0DD]:=self.cpgen;
handlingRoutines[$0DE]:=self.cpbcc_32;
handlingRoutines[$0DF]:=self.cpbcc_16;
handlingRoutines[$0E0]:=self.cmp_w_ea_Dn;
handlingRoutines[$0E1]:=self.cmp_w_ea_An;
handlingRoutines[$0E2]:=self.cmp_l_ea_Dn;
handlingRoutines[$0E3]:=self.cmp_l_ea_An;
handlingRoutines[$0E4]:=self.cmp_b_ea_Dn;
handlingRoutines[$0E5]:=self.chk_w;
handlingRoutines[$0E6]:=self.chk_l;
handlingRoutines[$0E7]:=self.btst;
handlingRoutines[$0E8]:=self.bset;
handlingRoutines[$0E9]:=self.bclr;
handlingRoutines[$0EA]:=self.bchg;
handlingRoutines[$0EB]:=self.and_w_ea_Dn;
handlingRoutines[$0EC]:=self.and_w_Dn_ea;
handlingRoutines[$0ED]:=self.and_l_ea_Dn;
handlingRoutines[$0EE]:=self.and_l_Dn_ea;
handlingRoutines[$0EF]:=self.and_b_ea_Dn;
handlingRoutines[$0F0]:=self.and_b_Dn_ea;
handlingRoutines[$0F1]:=self.addq_w;
handlingRoutines[$0F2]:=self.addq_l;
handlingRoutines[$0F3]:=self.addq_b;
handlingRoutines[$0F4]:=self.add_w_ea_Dn;
handlingRoutines[$0F5]:=self.add_w_ea_An;
handlingRoutines[$0F6]:=self.add_w_Dn_ea;
handlingRoutines[$0F7]:=self.add_l_ea_Dn;
handlingRoutines[$0F8]:=self.add_l_ea_An;
handlingRoutines[$0F9]:=self.add_l_Dn_ea;
handlingRoutines[$0FA]:=self.add_b_ea_Dn;
handlingRoutines[$0FB]:=self.add_b_Dn_ea;
handlingRoutines[$0FC]:=self.scc;
handlingRoutines[$0FD]:=self.moveq;
handlingRoutines[$0FE]:=self.move_w;
handlingRoutines[$0FF]:=self.move_l;
handlingRoutines[$100]:=self.move_b;
handlingRoutines[$101]:=self.eor_w_Dn_ea;
handlingRoutines[$102]:=self.eor_l_Dn_ea;
handlingRoutines[$103]:=self.eor_b_Dn_ea;
handlingRoutines[$104]:=self.bcc;

for j:=0 to $ffff do begin
                     i:=0;
                     while (j or mskopcodes[i] <> cmpopcodes[i])and (i<=nopcodes) do inc(i);
                     if i<=nopcodes then decodeTable[j]:=handlingRoutines[i]
                                    else decodeTable[j]:=self.fail;
                     end;





{$IFDEF debug}
for i:=0 to nopcodes do begin
                        instrStat [i,0]:=0; instrStat [i,1]:=0;
                        instrStat [i,2]:=0;
                        end;
trace_top:=0;
{$ENDIF}
DeviceNOW8:=$0;
DeviceNOW16:=$0;
DeviceNOW32:=$0;
warproundwrite:=$ffffffff;
pending_interrupt:=@fake_pending;
pending_interruptNo:=@fake_intNo;
CPUcycles:=0;
DebugNoCount:=true;
resetIO:=fakeResetIO;
exctypeSP:=0;
regs.endtag:=$00efBe00
end;
