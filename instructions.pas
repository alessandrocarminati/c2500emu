(******************************************************************************)
(* This file contans the implementations of the MC68k instruction handler     *)
(* procedures.                                                                *)
(******************************************************************************)
(******************************************************************************)
procedure cpu68k.fail;
begin
raise unhandled_instruction.create('unknown 68k instr');
end;
(******************************************************************************)
procedure cpu68k.trapv;
begin
{operands fetch}
{instruction ecxecution}
{update status}
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.stop;
begin
cpuStatus:=1;
end;
(******************************************************************************)
procedure cpu68k.rts;                                               (*verified*)
begin
{$IFDEF debug}
dec(trace_top);
trace_facility[trace_top]:=0;
{$ENDIF}
s32:=SourceOperand32(PopOutStack);                                              // get old PC (a7)+
regs.pc:=s32;                                                                   // old pc -> pc
end;
(******************************************************************************)
procedure cpu68k.rtr;                                               (*verified*)
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.rte;                                               (*verified*)
label again;
begin
if regs.sr and SupervisorFlagMask <>0 then
                              begin
                              again:
                              s16:=SourceOperand16(PopOutStack);                // get old PC (a7)+
                              s32:=SourceOperand32(PopOutStack);                // get old PC (a7)+
                              d16:=SourceOperand16(PopOutStack);                // stack type word format
                              case d16 and $f000 of
                              setFrameStackType0:begin
                                                 asm nop end;
                                                 end;
                              setFrameStackType1:begin
                                                 regs.isp:=regs.a[7];
                                                 regs.a[7]:=regs.msp;
                                                 goto again;
                                                 end;
                              setFrameStackType2:begin
                                                 asm nop end;
                                                 end;
                              setFrameStackTypeA:begin
                                                 SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);
                                                 SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);
                                                 SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);
                                                 SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);SourceOperand16(PopOutStack);
                                                 end;
                              end;
                              regs.pc:=s32;                                     // old pc -> pc
                              regs.sr:=s16;                                     // old pc -> pc
                              if regs.sr and $2000 =0 then begin
                                                           regs.msp:=regs.A[7];
                                                           regs.A[7]:=regs.usp;
                                                           end;
                              end
                         else begin                                             //trap
                              end;
end;
(******************************************************************************)
procedure cpu68k.rtd;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.resetmc68k;
begin
resetio;
end;
(******************************************************************************)
procedure cpu68k.oritosr;                                           (*verified*)
begin
if regs.sr and SupervisorFlagMask <>0 then
                              begin
                              d16:=sourceoperand16(currentopcode and OperandEA);
                              regs.sr:=regs.sr or d16;
                              end
                         else begin                                             //trap
                              end;
end;
(******************************************************************************)
procedure cpu68k.oritoccr;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.nop;                                               (*verified*)
begin
end;
(******************************************************************************)
procedure cpu68k.illegal;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.eoritosr;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.eoritoccr;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cas2_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cas2_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.anditosr;
begin
d16:=memoryRead16(regs.pc);
regs.pc:=regs.pc+2;
regs.sr:=regs.sr and d16;
end;
(******************************************************************************)
procedure cpu68k.anditoccr;
begin {07/12/2005}
//regs.sr:=regs.sr or $c000;
d16:=memoryRead16(regs.pc);
regs.pc:=regs.pc+2;
d16:=d16 or $ffe0;
regs.sr:=regs.sr and d16;

end;
(******************************************************************************)
procedure cpu68k.movec;                                             (*verified*)
begin
extword:=memoryRead16(regs.pc);                                                 //fetch extension word
regs.pc:=regs.pc+2;
if regs.sr and $2000 <>0 then
           begin                                                                //movec instruction core.
            case extword and MovecRegCodeMask of
                 $000:creg:=@regs.sfc;
                 $001:creg:=@regs.dfc;
                 $002:creg:=@regs.cacr;
                 $800:creg:=@regs.usp;
                 $801:creg:=@regs.vbr;
                 $802:creg:=@regs.caar;
                 $803:creg:=@regs.msp;
                 $804:creg:=@regs.isp;
                end;
            if extword and MovecA_DRegister =0
                       then dp32:=@regs.d[(extword and MovecRegNoMask ) shr MovecRegShift]
                       else dp32:=@regs.a[(extword and MovecRegNoMask ) shr MovecRegShift];
            if currentOpcode and MovecDirection=0 then dp32^:=creg^
                                                  else creg^:=dp32^;
           end
      else begin                                              //no right to do this.
           end;
end;
(******************************************************************************)
procedure cpu68k.unlk;                                              (*verified*)
begin
regs.a[SP]:=regs.a[currentOPcode and RegNoMask];                                //     An     -> SP
s32:=SourceOperand32(PopOutStack);                                              // |
regs.a[currentOPcode and RegNoMask]:=s32;                                       // |  (SP)+    -> An
end;
(******************************************************************************)
procedure cpu68k.swap;                                            (*Unverified*)
function sw32(a:longword):longword;assembler;
asm
        mov     eax,a
        ror     eax,16
end;
begin
regs.d[currentOPcode and RegNoMask]:=sw32(regs.d[currentOPcode and RegNoMask]);
update_ccr(na, gen, gen, set0, set0, 0, 0,regs.d[currentOPcode and RegNoMask], longOperation);
end;
(******************************************************************************)
procedure cpu68k.linkw;                                             (*verified*)
begin
s32:=regs.a[currentOPcode and RegNoMask];                                       //gettin An
DestinationOperand32(PushInStack,s32);                                          //     An      -> -(SP)
regs.a[currentOPcode and RegNoMask]:=regs.a[SP];                                //     SP      ->   An
s16:=SourceOperand16(ImmediateValCode);                                         //getting immediate 16 bits
s32:=signext16(s16);                                                            //Extend to 32 bits signed.
regs.a[SP]:=regs.a[SP]+s32;                                                     //     SP + dn ->   SP
end;
(******************************************************************************)
procedure cpu68k.linkl;                                           (*Unverified*)
begin
s32:=regs.a[currentOPcode and RegNoMask];                                       //gettin An
DestinationOperand32(PushInStack,s32);                                          //     An      -> -(SP)
regs.a[currentOPcode and RegNoMask]:=regs.a[SP];                                //     SP      ->   An
s32:=SourceOperand32(ImmediateValCode);                                         //getting immediate 32 bits
regs.a[SP]:=regs.a[SP]+s32;                                                     //     SP + dn ->   SP
end;
(******************************************************************************)
procedure cpu68k.ext_w_to_l;                                        (*verified*)
begin
s16:=sourceOperand16(currentOpcode and RegNoMask);
s32:=signext16(s16);
destinationoperand32(currentOpcode and RegNoMask,s32);
update_ccr(na, gen, gen, set0, set0, s16, 0, s32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.ext_b_to_w;                                        (*verified*)
begin
d32:=sourceOperand32(currentOpcode and RegNoMask);
s8:=sourceOperand8(currentOpcode and RegNoMask);
s32:=(signext8(s8)and Low16bitMask) or (d32 and High16bitMask);
destinationoperand32(currentOpcode and RegNoMask,s32);
update_ccr(na, gen, gen, set0, set0, s8, 0, s32 and $ffff, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.ext_b_to_l;                                        (*verified*)
begin
s8:=sourceOperand8(currentOpcode and RegNoMask);
s32:=signext8(s8);
destinationoperand32(currentOpcode and RegNoMask,s32);
update_ccr(na, gen, gen, set0, set0, s8, 0, s32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.bkpt;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.trap;                                            (*Unverified*)
begin
except_exec(((currentOpcode and $f)+Trap0) shl 2,TrapEx);
end;
(******************************************************************************)
procedure cpu68k.moveusp;                                           (*verified*)
begin
if currentopcode and MoveUSPDirection =0 then begin //Transfer the address register to the user stack pointer.
                                              regs.usp:=regs.a[currentopcode and RegNoMask];
                                              end
                                         else begin //Transfer the user stack pointer to the address register.
                                              regs.a[currentopcode and RegNoMask]:=regs.usp;
                                              end;
end;
(******************************************************************************)
procedure cpu68k.tst_w;                                             (*verified*)
begin
s16:=SourceOperand16(currentOPcode and OperandEA);
update_ccr(na, gen, gen, set0, set0, s16, 0, s16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.tst_l;                                             (*verified*)
begin
s32:=SourceOperand32(currentOPcode and OperandEA);
update_ccr(na, gen, gen, set0, set0, s32, 0, s32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.tst_b;                                             (*verified*)
begin
s8:=SourceOperand8(currentOPcode and OperandEA);
update_ccr(na, gen, gen, set0, set0, s8, 0, s8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.tas;
begin  {11/12/2005}
//regs.sr:=regs.sr or $c000;
oldpc:=regs.pc;
s8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
DestinationOperand8(currentOPcode and OperandEA,s8 or $80);
update_ccr(na, gen, gen, set0, set0, s8, 0, s8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.subi_w;                                          (*Unverified*)
begin
s16:=SourceOperand16(ImmediateValCode);
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris16:=d16 - s16;
DestinationOperand16(currentOPcode and OperandEA,ris16);
update_ccr(gen, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.subi_l;                                          (*Unverified*)
begin
s32:=SourceOperand32(ImmediateValCode);
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris32:=d32 - s32;
DestinationOperand32(currentOPcode and OperandEA,ris32);
update_ccr(gen, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.subi_b;                                          (*Unverified*)
begin
s8:=SourceOperand8(ImmediateValCode);
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris8:=d8 - s8;
DestinationOperand8(currentOPcode and OperandEA,ris8);
update_ccr(gen, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.roxr_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxl_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.ror_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.rol_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.ptest;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.pmove;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.pload;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.pflush;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.pea;                                               (*verified*)
begin
s32:=jmpOperand(currentOpcode and OperandEA);
DestinationOperand32(PushInStack,s32);
end;
(******************************************************************************)
procedure cpu68k.ori_w;                                             (*verified*)
begin
s16:=SourceOperand16(ImmediateValCode);
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris16:=d16 or s16;
DestinationOperand16(currentOPcode and OperandEA,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.ori_l;                                           (*Unverified*)
begin
s32:=SourceOperand32(ImmediateValCode);
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris32:=d32 or s32;
DestinationOperand32(currentOPcode and OperandEA,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.ori_b;                                             (*verified*)
begin
s8:=SourceOperand8(ImmediateValCode);
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris8:=d8 or s8;
DestinationOperand8(currentOPcode and OperandEA,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.not_w;                                             (*verified*)
begin
oldpc:=regs.pc;
s16:=SourceOperand16(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect   then regs.pc:=oldpc;
ris16:=not s16;
DestinationOperand16(currentOPcode and OperandEA,ris16);
update_ccr(na, gen, gen, set0, set0, s16, 0, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.not_l;                                             (*verified*)
begin
oldpc:=regs.pc;
s32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris32:=not s32;
DestinationOperand32(currentOPcode and OperandEA,ris32);
update_ccr(na, gen, gen, set0, set0, s32, 0, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.not_b;                                           (*Unverified*)
begin
oldpc:=regs.pc;
s8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris8:=not s8;
DestinationOperand8(currentOPcode and OperandEA,ris8);
update_ccr(na, gen, gen, set0, set0, s8, 0, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.negx_w;
begin                {11/12/2005}
//regs.sr:=regs.sr or $c000;
oldpc:=regs.pc;
s16:=sourceoperand16(currentopcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris16:=0-s16;
if regs.sr and $10<>0 then dec(ris16);
DestinationOperand16(currentopcode and OperandEA,ris16);
update_ccr(gen, gen, gen, _sub, _sub, s16, 0, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.negx_l;
begin                {11/12/2005}
//regs.sr:=regs.sr or $c000;
oldpc:=regs.pc;
s32:=sourceoperand32(currentopcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris32:=0-s32;
if regs.sr and $10<>0 then dec(ris32);
DestinationOperand32(currentopcode and OperandEA,ris32);
update_ccr(gen, gen, gen, _sub, _sub, s32, 0, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.negx_b;
begin                            {11/12/2005}
//regs.sr:=regs.sr or $c000;
oldpc:=regs.pc;
s8:=sourceoperand8(currentopcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris8:=0-s8;
if regs.sr and $10<>0 then dec(ris8);
DestinationOperand8(currentopcode and OperandEA,ris8);
update_ccr(gen, gen, gen, _sub, _sub, s8, 0, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.neg_w;                                           (*Unverified*)
begin
oldpc:=regs.pc;
s16:=sourceoperand16(currentopcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris16:=0-s16;
DestinationOperand16(currentopcode and OperandEA,ris16);
update_ccr(gen, gen, gen, _sub, _sub, s16, 0, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.neg_l;                                             (*verified*)
begin
oldpc:=regs.pc;
s32:=sourceoperand32(currentopcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris32:=0-s32;
DestinationOperand32(currentopcode and OperandEA,ris32);
update_ccr(gen, gen, gen, _sub, _sub, s32, 0, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.neg_b;                                           (*Unverified*)
begin
oldpc:=regs.pc;
s8:=sourceoperand8(currentopcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect  then regs.pc:=oldpc;
ris8:=0-s8;
DestinationOperand8(currentopcode and OperandEA,ris8);
update_ccr(gen, gen, gen, _sub, _sub, s8, 0, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.nbcd;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.mulul;                                                 (*fast*)
var res64:int64;
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
s32:=sourceOperand32(currentopcode and OperandEA); //load multiplier
d32:=sourceOperand32((extword and $7000) shr $c);
if extword and $400 =0 then begin //result is 32bit wide
                            ris32:=d32*s32;
                            DestinationOperand32((extword and $7000) shr $c,ris32);
                            update_ccr(na, gen, gen, set0, set0, s32, 0, ris32, longOperation);
                            end
                       else begin //result is 64bit wide
                            ris32:=sourceOperand32((extword and $7));
                            res64:=((ris32 shl 31)shl 1) + d32;
                            res64:=res64*s32;
                            ris32:=res64 and $ffffffff;
                            DestinationOperand32((extword and $7000) shr $c,ris32);
                            ris32:=(res64 shr 31)shr 1;
                            DestinationOperand32((extword and $7),ris32);
                            update_ccr(na, gen, gen, set0, set0, s32, 0, ris32, longOperation);
                            end;
end;
(******************************************************************************)
procedure cpu68k.mulsl;
var res64:int64;
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
s32:=sourceOperand32(currentopcode and OperandEA); //load multiplier
d32:=sourceOperand32((extword and $7000) shr $c);
if extword and $400 =0 then begin //result is 32bit wide
                            ris32:=d32*s32;
                            DestinationOperand32((extword and $7000) shr $c,ris32);
                            update_ccr(na, gen, gen, _add, set0, s32, 0, ris32, longOperation);
                            end
                       else begin //result is 64bit wide
                            ris32:=sourceOperand32((extword and $7));
                            res64:=((ris32 shl 31)shl 1) + d32;
                            res64:=res64*s32;
                            ris32:=res64 and $ffffffff;
                            DestinationOperand32((extword and $7000) shr $c,ris32);
                            ris32:=(res64 shl 31)shl 1;
                            DestinationOperand32((extword and $7),ris32);
                            update_ccr(na, gen, gen, _add, set0, s32, 0, ris32, longOperation);
                            end;
end;
(******************************************************************************)
procedure cpu68k.movetosr;                                          (*verified*)
begin
if regs.sr and SupervisorFlagMask <>0 then begin
                                           regs.sr:=sourceOperand16(currentOPcode and OperandEA);
                                           end
                                      else begin                                //trap
                                           end;
end;
(******************************************************************************)
procedure cpu68k.movetoccr;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.moves_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.moves_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.moves_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.movem_w_to_regs;                                 (*Unverified*)
var i:byte;
begin
extword:=memoryRead16(regs.pc);
regs.pc:=regs.pc+2;
d32:=jmpOperand(currentOpcode and SourceEA);
s8:=0; for i:=0 to $f do s8:=s8+((extword shr i)and 1);
if currentOpcode and SourceAddrModeMask=PostIncrIndirect then
                 regs.a[currentOpcode and RegNoMask]:=d32+(2*s8)+2;
//                 destinationoperand32((currentOpcode and $7)+8,d32+(2*s8)+2);
for i:=0 to $f do
               begin
                if ((extword shr i)and 1) =1  then
                    begin
                     s32:=signext16(memoryread16(d32));
                     if not((currentOpcode and SourceAddrModeMask=PostIncrIndirect ) and
                            (i=(currentOpcode and RegNoMask)+8)) then
                                              destinationOperand32(i,s32);
                     d32:=d32+2;
                    end;
               end;
end;
(******************************************************************************)
procedure cpu68k.movem_w_to_mem;                                  (*Unverified*)(*warning*)
var i:byte;
begin
extword:=memoryRead16(regs.pc);
regs.pc:=regs.pc+2;
d32:=jmpOperand(currentOpcode and RegNoMask);
s8:=0; for i:=0 to $f do s8:=s8+((extword shr i)and 1);
if currentOpcode and SourceAddrModeMask = PreDecrIndirect then
     begin
     regs.a[currentOpcode and RegNoMask]:=d32-(2*s8);
//     destinationoperand32((currentOpcode and $7)+8,d32-(2*s8));
     for i:=0 to $f do
               begin
                if ((extword shr i)and 1) =1  then
                    begin
                     s32:=sourceoperand16($f-i);
                     memorywrite16(d32,s32);
                     d32:=d32-2;
                    end;
               end;
     end
else begin
     destinationoperand32((currentOpcode and $7)+8,d32+(2*s8));
     for i:=$f downto 0 do
               begin
                if ((extword shr i)and 1) =1  then
                    begin
                     s32:=sourceoperand16($f-i);
                     memorywrite16(d32,s32);
                     d32:=d32+2;
                    end;
               end;
     end;
end;
(******************************************************************************)
procedure cpu68k.movem_l_to_regs;                                   (*verified*)
var i:byte;
begin
extword:=memoryRead16(regs.pc);
regs.pc:=regs.pc+2;
d32:=jmpOperand(currentOpcode and SourceEA);
s8:=0; for i:=0 to $f do s8:=s8+((extword shr i)and 1);
if currentOpcode and SourceAddrModeMask=PostIncrIndirect then
     regs.a[currentOpcode and RegNoMask]:=d32+(4*s8);
for i:=0 to $f do
               begin
                if ((extword shr i)and 1) =1  then
                    begin
                     s32:=memoryread32(d32);
                     if not((currentOpcode and SourceAddrModeMask=PostIncrIndirect) and
                            (i=(currentOpcode and RegNoMask)+8)) then
                                        destinationOperand32(i,s32);
                     d32:=d32+4;
                    end;
               end;
end;
(******************************************************************************)
procedure cpu68k.movem_l_to_mem;                                    (*verified*)
var i:byte;
    x:integer;
begin
extword:=memoryRead16(regs.pc);
regs.pc:=regs.pc+2;
d32:=jmpOperand(currentOpcode and SourceEA);
s8:=0; for i:=0 to $f do s8:=s8+((extword shr i)and 1);
if (currentOpcode and SourceAddrModeMask) = PreDecrIndirect then
     begin
     regs.a[currentOpcode and RegNoMask]:=d32-(4*(s8-1));
     for i:=0 to $f do
               begin
                if ((extword shr i)and 1) =1  then
                    begin
                     s32:=sourceoperand32($f-i);
                     memorywrite32(d32,s32);
                     d32:=d32-4;
                    end;
               end;
     end
else begin
     for i:=$f downto 0 do
               begin
                if ((extword shr ($f-i))and 1) =1  then
                    begin
                     s32:=sourceoperand32($f-i);
                     memorywrite32(d32,s32);
                     d32:=d32+4;
                    end;
               end;
     end;
end;
(******************************************************************************)
procedure cpu68k.movefromsr;                                        (*verified*)
begin
destinationOperand16(currentOpcode and OperandEA,regs.sr);
end;
(******************************************************************************)
procedure cpu68k.movefromccr;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.lsr_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.lsl_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.jsr;                                               (*verified*)
begin
s32:=jmpOperand(currentOPcode and OperandEA);                                   // get <ea> in co
DestinationOperand32(PushInStack,regs.pc);                                      // mode+reg  010 111 -(a7) | pc -> (a7)
regs.pc:=s32;                                                                   // <ea> -> pc
{$IFDEF debug}
trace_facility[trace_top]:=regs.pc;
inc(trace_top);
{$ENDIF}
end;
(******************************************************************************)
procedure cpu68k.jmp;                                               (*verified*)
begin
s32:=jmpOperand(currentOPcode and OperandEA);
regs.pc:=s32;
end;
(******************************************************************************)
procedure cpu68k.eori_w;                                          (*Unverified*)
begin
s16:=SourceOperand16(ImmediateValCode);
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris16:=d16 xor s16;
DestinationOperand16(currentOPcode and OperandEA,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.eori_l;                                          (*Unverified*)
begin
s32:=SourceOperand32(ImmediateValCode);
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris32:=d32 xor s32;
DestinationOperand32(currentOPcode and OperandEA,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.eori_b;                                          (*Unverified*)
begin
s8:=SourceOperand8(ImmediateValCode);
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris8:=d8 xor s8;
DestinationOperand8(currentOPcode and OperandEA,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.divul;                                             (*verified*)
var  op1h,op1l,op2:longword;
     op1sh,op1sl,op2s:longint;
     op164:int64;
begin
//regs.sr:=regs.sr or $c000;
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
if extword and MulDivSignMask <> 0 then
           begin  //signed
           if extword and MulDivSizeMask = 0 then
                      begin //32bits operands
                      op2s:=sourceoperand32(currentOpcode and SourceEA);
                      op1sl:=sourceoperand32((extword shr MovecRegShift) and RegNoMask);
                      destinationOperand32(extword and RegNoMask,op1sl mod op2s);
                      ris32:=op1sl div op2s;
                      destinationOperand32((extword shr MovecRegShift) and RegNoMask,ris32);
                      update_ccr(na, gen, gen, na, set0, op2s, op1sl, ris32, longOperation);
                      end
                 else begin //64bits operands
                      op2s:=sourceoperand32(currentOpcode and SourceEA);
                      op1l:=sourceoperand32((extword shr MovecRegShift) and RegNoMask);
                      op1h:=sourceoperand32(extword and RegNoMask);
                      op164:=((op1h shl 31)shl 1) + op1l;
                      destinationOperand32(extword and RegNoMask,op164 mod op2s);
                      ris32:=op164 div op2s;
                      destinationOperand32((extword shr MovecRegShift) and RegNoMask,ris32);
                      update_ccr(na, gen, gen, na, set0, op2s, op1sl, ris32, longOperation);
                      end;
           end
      else begin  //unsigned
           if extword and MulDivSizeMask = 0 then
                      begin //32bits operands
                      op2:=sourceoperand32(currentOpcode and SourceEA);
                      op1l:=sourceoperand32((extword shr MovecRegShift) and RegNoMask);
                      destinationOperand32(extword and RegNoMask,op1l mod op2);
                      ris32:=op1l div op2;
                      destinationOperand32((extword shr MovecRegShift) and RegNoMask,ris32);
                      update_ccr(na, gen, gen, na, set0, op2s, op1sl, ris32, longOperation);
                      end
                 else begin //64bits operands
                      op2s:=sourceoperand32(currentOpcode and SourceEA);
                      op1l:=sourceoperand32((extword shr MovecRegShift) and RegNoMask);
                      op1h:=sourceoperand32(extword and RegNoMask);
                      op164:=((op1h shl 32)shl 1) + op1l;
                      destinationOperand32(extword and RegNoMask,op164 mod op2s);
                      destinationOperand32((extword shr MovecRegShift) and RegNoMask,op164 div op2s);
                      end;
           end;
end;
(******************************************************************************)
procedure cpu68k.divl;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cmpi_w;                                            (*verified*)
begin
s16:=SourceOperand16(ImmediateValCode);
d16:=SourceOperand16(currentOPcode and OperandEA);
ris16:=d16 - s16;
update_ccr(na, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.cmpi_l;                                            (*verified*)
begin
s32:=SourceOperand32(ImmediateValCode);
d32:=SourceOperand32(currentOPcode and OperandEA);
ris32:=d32 - s32;
update_ccr(na, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.cmpi_b;                                            (*verified*)
begin
s8:=SourceOperand8(ImmediateValCode);
d8:=SourceOperand8(currentOPcode and OperandEA);
ris8:=d8 - s8;
update_ccr(na, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.cmp2_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cmp2_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cmp2_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.clr_w;                                             (*verified*)
begin
DestinationOperand16(currentOPcode and OperandEA,0);
update_ccr(na, set0, gen, set0, set0, 0, 0, 0, WordOperation);
//regs.sr:=(regs.sr and ResetCVZNImmediate) or SetZImmediate;
end;
(******************************************************************************)
procedure cpu68k.clr_l;                                             (*verified*)
begin
DestinationOperand32(currentOPcode and OperandEA,0);
update_ccr(na, set0, gen, set0, set0, 0, 0, 0, LongOperation);
//regs.sr:=(regs.sr and ResetCVZNImmediate) or SetZImmediate;
end;
(******************************************************************************)
procedure cpu68k.clr_b;                                             (*verified*)
begin
DestinationOperand8(currentOPcode and OperandEA,0);
update_ccr(na, set0, gen, set0, set0, 0, 0, 0, WordOperation);
//regs.sr:=(regs.sr and ResetCVZNImmediate) or SetZImmediate;
end;
(******************************************************************************)
procedure cpu68k.chk2_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.chk2_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.chk2_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cas_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cas_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cas_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.btsti;                                             (*@*)
var shiftcnt:longword;
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
if (currentOPcode and SourceAddrModeMask)<AddressReg_n then
                                     begin
                                     s32:=SourceOperand32(currentOPcode and OperandEA);
                                     if extword<$10 then
                                        shiftcnt:=1 shl (extword and BtstShiftCount)
                                     else
                                        begin
                                         shiftcnt:=1 shl ((extword-$f) and BtstShiftCount);
                                         shiftcnt:=shiftcnt shl $f;
                                        end;
                                     end
                                else begin
                                     s32:=SourceOperand8(currentOPcode and OperandEA);
                                     shiftcnt:=1 shl (extword and RegNoMask);
                                     end;
s32:=s32 and shiftcnt;
update_ccr(na, na, gen, na, na, 0, 0, s32, longOperation);
//if s32 =0 then regs.sr:=regs.sr or SetZImmediate
//          else regs.sr:=regs.sr and ResetZImmediate;
end;
(******************************************************************************)
procedure cpu68k.bseti;                                                 (*fast*)
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
oldpc:=regs.pc;
if (currentOPcode and SourceAddrModeMask)<AddressReg_n then
                                     begin
                                     s32:=SourceOperand32(currentOPcode and OperandEA);
                                     extword:=1 shl (extword and BtstShiftCount);
                                     s32:=s32 and extword;
                                     //if s32 =0 then regs.sr:=regs.sr or SetZImmediate
                                     //          else regs.sr:=regs.sr and ResetZImmediate;
                                     update_ccr(na, na, gen, na, na, 0, 0, s32, longOperation);
                                     s32:=s32 or extword;
                                     if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
                                     destinationOperand32(currentOPcode and OperandEA,s32);
                                     end
                                else begin
                                     s8:=SourceOperand8(currentOPcode and OperandEA);
                                     extword:=1 shl (extword and RegNoMask);
                                     s8:=s8 and extword;
                                     //if s8 =0 then regs.sr:=regs.sr or SetZImmediate
                                     //         else regs.sr:=regs.sr and ResetZImmediate;
                                     update_ccr(na, na, gen, na, na, 0, 0, s32, longOperation);
                                     s8:=s8 or extword;
                                     if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
                                     destinationOperand8(currentOPcode and OperandEA,s8);
                                     end;
end;
(******************************************************************************)
procedure cpu68k.bftst;
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
oldpc:=regs.pc;
if (extword and $800)=0 then begin
                             s32:=SourceOperand32(currentOPcode and OperandEA);
                             extword:=extword and $f7ff;
                             s32:=bfgets(s32,(extword and $7c0) shr 6,(extword and $1f));
//                             s32:= s32 shl (32-((extword and $1f)+((extword and $7c0) shr 6)));
                             if s32<0 then regs.sr := regs.sr or    setNimmediate
                                      else regs.sr := regs.sr and resetNimmediate;
//                             s32:= s32 shr (extword shr 6);
                             if s32=0 then regs.sr:=regs.sr or SetZImmediate
                                      else regs.sr:=regs.sr and ResetZImmediate;
                             regs.sr:=regs.sr and ResetCVImmediate;
                             end
                        else begin
                             end;
end;
(******************************************************************************)
procedure cpu68k.bfset;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.bfins;
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
if extword and $800 =0 then s8:=(extword and $7c0) shr 6
                       else s8:=regs.d[(extword and $7c0) shr 6];
if extword and $20 = 0 then d8:=(extword and $1f)
                       else d8:=regs.d[extword and $1f];
ris32:=($ffffffff shl s8);  {11/12/2005}
ris32:=ris32 shr (32-d8);
ris32:=ris32 shl (32-d8-s8);
ris32:=not ris32;
d32:= d32 and ris32;


//not((($ffffffff shl s8) shr (32-s8-d8))shl d8);
s32:=((regs.d[(extword and $7000) shr 12] and ($ffffffff shr (32-d8) )) shl (32-s8-d8));
d32:=d32 or s32;
//s32:=(regs.d[(extword and $7000) shr 12] and ris32) shl (32-s8);
//ris32:=not ris32 shl (32-s8);
//d32:=(d32 and ris32) or s32;
destinationOperand32(currentOPcode and OperandEA, d32);
update_ccr(na, gen, gen, set0, set0, s32, d32, d32, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.bfffo;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.bfextu;                                            (*verified*)
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
s32:=sourceoperand32(currentopcode and SourceEA);
if extword  and BFopsCoutRegMask1 =0
            then s8:=(extword and BFopsSource1EA) shr BFopsSource1Shift
            else s8:=sourceoperand8((extword and BFopsSource1EA) shr BFopsSource1Shift);
if extword  and BFopsCoutRegMask2  =0 then d8:=extword and BFopsSource2EA
                                      else d8:=sourceoperand8(extword and BFopsSource2EA);
s32:=bfGETu(s32,s8,d8);
{ris32:=($ffffffff shl ($20-d8)) shr s8;
s32:=(s32 and ris32) shr ($20-d8-s8);}
destinationoperand32((extword and BFopsDestEA) shr BFopsDestShift,s32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.bfexts;
begin                          {05/12/2005}
//regs.sr:=regs.sr or $c000;
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
s32:=sourceoperand32(currentopcode and SourceEA);
if extword  and BFopsCoutRegMask1 =0
            then s8:=(extword and BFopsSource1EA) shr BFopsSource1Shift
            else s8:=sourceoperand8((extword and BFopsSource1EA) shr BFopsSource1Shift);
if extword  and BFopsCoutRegMask2  =0 then d8:=extword and BFopsSource2EA
                                      else d8:=sourceoperand8(extword and BFopsSource2EA);
//ris32:=($ffffffff shl ($20-d8)) shr s8;
//s32:=(s32 and ris32);// shr ($20-d8-s8);
s32:=bfGETs(s32,s8,d8);
destinationoperand32((extword and BFopsDestEA) shr BFopsDestShift,s32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.bfclr;
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
if extword  and BFopsCoutRegMask1 =0
            then s8:=(extword and BFopsSource1EA) shr BFopsSource1Shift
            else s8:=sourceoperand8((extword and BFopsSource1EA) shr BFopsSource1Shift);
if extword  and BFopsCoutRegMask2  =0 then d8:=extword and BFopsSource2EA
                                      else d8:=sourceoperand8(extword and BFopsSource2EA);
ris32:=not(($ffffffff shl ($20-d8)) shr s8);
s32:=(s32 and ris32);
destinationoperand32(currentopcode and SourceEA,s32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.bfchg;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.bclri;     //btsti    {04/12/2005}
begin
extword:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
if currentopcode and OperandEA>=$10 then
            begin
             oldpc:=regs.pc;
             d8:=SourceOperand8(currentOPcode and OperandEA);
             if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
             s8:=(d8 shr extword) and 1;
             if s8 =0 then regs.sr:=regs.sr or SetZImmediate
                      else regs.sr:=regs.sr and ResetZImmediate;
             s8:=not(1 shl extword);
             d8:=d8 and s8;
             destinationOperand8(currentOPcode and OperandEA,d8);
            end
       else begin
             d32:=SourceOperand32(currentOPcode and OperandEA);
             s32:=(d32 shr extword) and 1;
             if s32 =0 then regs.sr:=regs.sr or SetZImmediate
                       else regs.sr:=regs.sr and ResetZImmediate;
             s32:=not(1 shl extword);
             d32:=d32 and s32;
             destinationOperand32(currentOPcode and OperandEA,d32);
            end;

end;
(******************************************************************************)
procedure cpu68k.bchgi;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.andi_w;                                            (*verified*)
begin
s16:=SourceOperand16(ImmediateValCode);
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris16:=d16 and s16;
DestinationOperand16(currentOPcode and OperandEA,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.andi_l;                                            (*verified*)
begin
s32:=SourceOperand32(ImmediateValCode);
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris32:=d32 and s32;
DestinationOperand32(currentOPcode and OperandEA,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.andi_b;                                            (*verified*)
begin
s8:=SourceOperand8(ImmediateValCode);
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris8:=d8 and s8;
DestinationOperand8(currentOPcode and OperandEA,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.addi_w;                                          (*Unverified*)
begin
s16:=SourceOperand16(ImmediateValCode);                                             //3C =>111 100 immediate value.
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris16:=d16 + s16;
DestinationOperand16(currentOPcode and OperandEA,ris16);
update_ccr(gen, gen, gen, _add, _add, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.addi_l;                                            (*verified*)
begin
s32:=SourceOperand32(ImmediateValCode);                                             //3C =>111 100 immediate value.
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and OperandEA);                           //look@ the and statement: it gets the Dregister number, and because the addressing 4 D is 000, that's all
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris32:=d32 + s32;
DestinationOperand32(currentOPcode and OperandEA,ris32);
update_ccr(gen, gen, gen, _add, _add, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.addi_b;                                          (*Unverified*)
begin
s8:=SourceOperand8(ImmediateValCode);
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
ris8:=d8 + s8;
DestinationOperand8(currentOPcode and OperandEA,ris8);
update_ccr(gen, gen, gen, _add, _add, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.asl_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.asr_ea;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.movep_w_to_regs;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.movep_w_to_mem;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.movep_l_to_regs;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.movep_l_to_mem;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
{logic}
(******************************************************************************)
procedure cpu68k.roxri_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxri_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxri_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxr_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxr_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxr_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxli_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxli_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxli_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxl_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxl_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.roxl_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.rori_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.rori_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.rori_b;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.ror_w;
begin {21/01/06}
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if ror16(ris16,s8) then update_ccr(na, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(na, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.ror_l;
begin {21/01/06}
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if ror32(ris32,s8) then update_ccr(na, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                   else update_ccr(na, gen, gen, set0, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.ror_b;
begin {21/01/06}
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if ror8(ris8,s8) then update_ccr(na, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.roli_w;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if rol16(ris16,s8) then update_ccr(na, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(na, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.roli_l;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if rol32(ris32,s8) then update_ccr(na, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                   else update_ccr(na, gen, gen, set0, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.roli_b;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if rol8(ris8,s8) then update_ccr(na, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.rol_w;
begin
//regs.sr:=regs.sr or $c000;
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=regs.d[(currentOPcode and $e00) shr 9] and $3f;
if rol16(ris16,s8) then update_ccr(na, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(na, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.rol_l;
begin
//regs.sr:=regs.sr or $c000;
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=regs.d[(currentOPcode and $e00) shr 9] and $3f;
if rol32(ris32,s8) then update_ccr(na, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                   else update_ccr(na, gen, gen, set0, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.rol_b;
begin
//regs.sr:=regs.sr or $c000;
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=regs.d[(currentOPcode and $e00) shr 9] and $3f;
if rol8(ris8,s8) then update_ccr(na, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.lsri_w;                                            (*verified*)
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if shr16(ris16,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(gen, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.lsri_l;                                          (*Unverified*)
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if shr32(ris32,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                   else update_ccr(gen, gen, gen, set0, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.lsri_b;                                          (*Unverified*)
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if shr8(ris8,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(gen, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.lsr_w_Dn_Dm;                                     (*Unverified*)
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=SourceOperand16((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if shr16(ris16,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                                   else update_ccr(gen, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
                destinationOperand16(currentOPcode and 7,ris16);
                end
           else update_ccr(na, na, na, na, set0, s8, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.lsr_l_Dn_Dm;                                       (*verified*)
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=SourceOperand32((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if shr32(ris32,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                                   else update_ccr(gen, gen, gen, set0, set0, s8, d32, ris32, longOperation);
                destinationOperand32(currentOPcode and 7,ris32);
                end
           else update_ccr(na, na, na, na, set0, s8, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.lsr_b_Dn_Dm;                                     (*Unverified*)
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=SourceOperand8((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if shr8(ris8,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                                 else update_ccr(gen, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
                destinationOperand8(currentOPcode and 7,ris8);
                end
           else update_ccr(na, na, na, na, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.lsli_w;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if shl16(ris16,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(gen, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.lsli_l;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if shl32(ris32,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                   else update_ccr(gen, gen, gen, set0, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.lsli_b;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if shl8(ris8,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(gen, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.lsl_w_Dn_Dm;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=SourceOperand16((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if shl16(ris16,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d16, ris16, wordOperation)
                                   else update_ccr(gen, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
                destinationOperand16(currentOPcode and 7,ris16);
                end
           else update_ccr(na, na, na, na, set0, s8, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.lsl_l_Dn_Dm;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=SourceOperand32((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if shl32(ris32,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d32, ris32, longOperation)
                                   else update_ccr(gen, gen, gen, set0, set0, s8, d32, ris32, longOperation);
                destinationOperand32(currentOPcode and 7,ris32);
                end
           else update_ccr(na, na, na, na, set0, s8, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.lsl_b_Dn_Dm;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=SourceOperand8((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if shl8(ris8,s8) then update_ccr(gen, gen, gen, set0, set1, s8, d8, ris8, byteOperation)
                                 else update_ccr(gen, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
                destinationOperand8(currentOPcode and 7,ris8);
                end
           else update_ccr(na, na, na, na, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.exg_Dn_Dm;
var temp:longword;
begin
temp:=regs.d[currentOpcode and $7];
regs.d[currentOpcode and $7]:=regs.d[(currentOpcode and $e)shr 9];
regs.d[(currentOpcode and $e)shr 9]:=temp;
end;
(******************************************************************************)
procedure cpu68k.exg_An_Dm;
var temp:longword;
begin
temp:=regs.a[currentOpcode and $7];
regs.a[currentOpcode and $7]:=regs.d[(currentOpcode and $e)shr 9];
regs.d[(currentOpcode and $e)shr 9]:=temp;
end;
(******************************************************************************)
procedure cpu68k.exg_An_Am;
var temp:longword;
begin
temp:=regs.a[currentOpcode and $7];
regs.a[currentOpcode and $7]:=regs.a[(currentOpcode and $e)shr 9];
regs.a[(currentOpcode and $e)shr 9]:=temp;
end;
(******************************************************************************)
procedure cpu68k.cptrapcc;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cpdbcc;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cmpm_w;
begin
//regs.sr:=regs.sr or $c000;
s16:=SourceOperand16((currentOPcode and $3)+$18);
d16:=SourceOperand16(((currentOPcode and $e00) shr 9)+$18);                  //look@ the and statement: it gets the Dregister number, and because the addressing 4 D is 000, that's all
ris16:=d16 - s16;
update_ccr(na, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.cmpm_l;
begin
//regs.sr:=regs.sr or $c000;
s32:=SourceOperand32((currentOPcode and $3)+$18);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)+$18);                  //look@ the and statement: it gets the Dregister number, and because the addressing 4 D is 000, that's all
ris32:=d32 - s32;
update_ccr(na, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.cmpm_b;
begin
//regs.sr:=regs.sr or $c000;
s8:=SourceOperand8((currentOPcode and $3)+$18);
d8:=SourceOperand8(((currentOPcode and $e00) shr 9)+$18);
ris8:=d8 - s8;
update_ccr(na, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.asri_w;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if sar16(ris16,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(gen, gen, gen, _asl, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.asri_l;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if sar32(ris32,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d32, ris32, longOperation)
                   else update_ccr(gen, gen, gen, _asl, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.asri_b;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if sar8(ris8,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(gen, gen, gen, _asl, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.asr_w;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=SourceOperand16((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if sar16(ris16,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d16, ris16, wordOperation)
                                   else update_ccr(gen, gen, gen, _asl, set0, s8, d16, ris16, wordOperation);
                destinationOperand16(currentOPcode and 7,ris16);
                end
           else update_ccr(na, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.asr_l;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=SourceOperand32((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if sar32(ris32,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d32, ris32, longOperation)
                                   else update_ccr(gen, gen, gen, _asl, set0, s8, d32, ris32, longOperation);
                destinationOperand32(currentOPcode and 7,ris32);
                end
           else update_ccr(na, gen, gen, set0, set0, s8, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.asr_b;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=SourceOperand8((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if sar8(ris8,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d8, ris8, byteOperation)
                                 else update_ccr(gen, gen, gen, _asl, set0, s8, d8, ris8, byteOperation);
                destinationOperand8(currentOPcode and 7,ris8);
                end
           else update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(*vv*****************************************************************************)
procedure cpu68k.asli_w;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if sal16(ris16,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d16, ris16, wordOperation)
                   else update_ccr(gen, gen, gen, _asl, set0, s8, d16, ris16, wordOperation);
destinationOperand16(currentOPcode and 7,ris16);
end;
(******************************************************************************)
procedure cpu68k.asli_l;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if sal32(ris32,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d32, ris32, longOperation)
                   else update_ccr(gen, gen, gen, _asl, set0, s8, d32, ris32, longOperation);
destinationOperand32(currentOPcode and 7,ris32);
end;
(******************************************************************************)
procedure cpu68k.asli_b;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=(currentOPcode and $e00) shr 9;
if s8=0 then s8:=8;
if sal8(ris8,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d8, ris8, byteOperation)
                 else update_ccr(gen, gen, gen, _asl, set0, s8, d8, ris8, byteOperation);
destinationOperand8(currentOPcode and 7,ris8);
end;
(******************************************************************************)
procedure cpu68k.asl_w;
begin
ris16:=sourceoperand16(currentOPcode and 7);
d16:=ris16;
s8:=SourceOperand16((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if sal16(ris16,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d16, ris16, wordOperation)
                                   else update_ccr(gen, gen, gen, _asl, set0, s8, d16, ris16, wordOperation);
                destinationOperand16(currentOPcode and 7,ris16);
                end
           else update_ccr(na, gen, gen, set0, set0, s8, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.asl_l;
begin
ris32:=sourceoperand32(currentOPcode and 7);
d32:=ris32;
s8:=SourceOperand32((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if sal32(ris32,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d32, ris32, longOperation)
                                   else update_ccr(gen, gen, gen, _asl, set0, s8, d32, ris32, longOperation);
                destinationOperand32(currentOPcode and 7,ris32);
                end
           else update_ccr(na, gen, gen, set0, set0, s8, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.asl_b;
begin
ris8:=sourceoperand8(currentOPcode and 7);
d8:=ris8;
s8:=SourceOperand8((currentOPcode and ShiftOpsImmVal) shr ShiftOpsImmshift);(*no error*)
if s8 <> 0 then begin
                if sal8(ris8,s8) then update_ccr(gen, gen, gen, _asl, set1, s8, d8, ris8, byteOperation)
                                 else update_ccr(gen, gen, gen, _asl, set0, s8, d8, ris8, byteOperation);
                destinationOperand8(currentOPcode and 7,ris8);
                end
           else update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.addx_w_regs;
begin
s16:=SourceOperand16(currentOPcode and $7);
d16:=SourceOperand16((currentOPcode and $0e00) shr 9);
ris16:=d16 + s16 + (regs.sr and $10) shr 4;
DestinationOperand16((currentOPcode and $0e00) shr 9,ris16);
update_ccr(gen, gen, bcd, _add, _add, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.addx_l_regs;
begin
s32:=SourceOperand32(currentOPcode and $7);
d32:=SourceOperand32((currentOPcode and $0e00) shr 9);
ris32:=d32 + s32 + (regs.sr and $10) shr 4;
DestinationOperand32((currentOPcode and $0e00) shr 9,ris32);
update_ccr(gen, gen, bcd, _add, _add, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.addx_b_regs;
begin
s8:=SourceOperand8(currentOPcode and $7);
d8:=SourceOperand8((currentOPcode and $0e00) shr 9);
ris8:=d8 + s8 + (regs.sr and $10) shr 4;
DestinationOperand8((currentOPcode and $0e00) shr 9,ris8);
update_ccr(gen, gen, bcd, _add, _add, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.addx_w_mem;
begin
s16:=SourceOperand16((currentOPcode and $7)+$20);
d16:=SourceOperand16(((currentOPcode and $0e00) shr 9)+$20);
ris16:=d16 + s16 + (regs.sr and $10) shr 4;
DestinationOperand16((currentOPcode and $7)+$10,ris16); // -(Ax) + -(Ay) ->(Ax)
update_ccr(gen, gen, bcd, _add, _add, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.addx_b_mem;
begin
s8:=SourceOperand8((currentOPcode and $7)+$20);
d8:=SourceOperand8(((currentOPcode and $0e00) shr 9)+$20);
ris8:=d8 + s8 + (regs.sr and $10) shr 4;
DestinationOperand8((currentOPcode and $7)+$10,ris8); // -(Ax) + -(Ay) ->(Ax)
update_ccr(gen, gen, bcd, _add, _add, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.addx_l_mem;
begin
s32:=SourceOperand32((currentOPcode and $7)+$20);
d32:=SourceOperand32(((currentOPcode and $0e00) shr 9)+$20);
ris32:=d32 + s32 + (regs.sr and $10) shr 4;
DestinationOperand32((currentOPcode and $7)+$10,ris32); // -(Ax) + -(Ay) ->(Ax)
update_ccr(gen, gen, bcd, _add, _add, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.trapcc;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.dbcc;
begin
data:=memoryread16(regs.pc);
data:=signext16(data);
addpc:=2;
if not conditionTest((currentOPcode and $0f00)shr 8) then begin
                                                          s16:=sourceoperand16(CurrentOPcode and 7);
                                                          s16:=s16 -1;
                                                          destinationoperand16(CurrentOPcode and 7,s16);
                                                          if s16<>$ffff then addpc:=data; {07/12/2005}
                                                          end;
regs.pc:=regs.pc+addpc;
end;
(******************************************************************************)
procedure cpu68k.unpk;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.sbcd;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.pack;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.abcd;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.bsr;
begin
addpc:=0;
case currentOPcode and $ff of
$00:begin
    data:=memoryread16(regs.pc);
    data:=signext16(data);
    addpc:=2;
    end;
$ff:begin
    data:=memoryread32(regs.pc);
    addpc:=4;
    end;
else
    begin
    data:=currentOPcode and $ff;
    data:=signext8(data);
    end;
end;
DestinationOperand32($27,regs.pc+addpc);                                        // mode+reg  010 111 -(a7) | pc -> (a7)
regs.pc:=regs.pc+data;
{$IFDEF debug}
trace_facility[trace_top]:=regs.pc;
inc(trace_top);
{$ENDIF}
end;
(******************************************************************************)
procedure cpu68k.bra;
begin
case currentOPcode and $ff of
$00:begin
    data:=memoryread16(regs.pc);
    data:=signext16(data);
    end;
$ff:begin
    data:=memoryread32(regs.pc);
    end;
else
    begin
    data:=currentOPcode and $ff;
    data:=signext8(data);
    end;
end;
regs.pc:=regs.pc+data;
end;
(******************************************************************************)
procedure cpu68k.subx_w_regs;
begin
s16:=SourceOperand16(currentOPcode and $7);
d16:=SourceOperand16((currentOPcode and $0e00) shr 9);
ris16:=d16 - s16 - (regs.sr and $10) shr 4;
DestinationOperand16(currentOPcode and $7,ris16);
update_ccr(gen, gen, bcd, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.subx_w_mem;
begin
s16:=SourceOperand16((currentOPcode and $7)+$20);
d16:=SourceOperand16(((currentOPcode and $0e00) shr 9)+$20);
ris16:=d16 - s16 - (regs.sr and $10) shr 4;
DestinationOperand16((currentOPcode and $7)+$10,ris16); // -(Ax) + -(Ay) ->(Ax)
update_ccr(gen, gen, bcd, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.subx_l_regs;
begin
s32:=SourceOperand32(currentOPcode and $7);
d32:=SourceOperand32((currentOPcode and $0e00) shr 9);
ris32:=d32 - s32 - (regs.sr and $10) shr 4;
DestinationOperand32(currentOPcode and $7,ris32);
update_ccr(gen, gen, bcd, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.subx_l_mem;
begin
s32:=SourceOperand32((currentOPcode and $7)+$20);
d32:=SourceOperand32(((currentOPcode and $0e00) shr 9)+$20);
ris32:=d32 - s32 - (regs.sr and $10) shr 4;
DestinationOperand32((currentOPcode and $7)+$10,ris32); // -(Ax) + -(Ay) ->(Ax)
update_ccr(gen, gen, bcd, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.subx_b_regs;
begin
s8:=SourceOperand8(currentOPcode and $7);
d8:=SourceOperand8((currentOPcode and $0e00) shr 9);
ris8:=d8 - s8 - (regs.sr and $10) shr 4;
DestinationOperand8(currentOPcode and $7,ris8);
update_ccr(gen, gen, bcd, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.subx_b_mem;
begin
s8:=SourceOperand8((currentOPcode and $7)+$20);
d8:=SourceOperand8(((currentOPcode and $0e00) shr 9)+$20);
ris8:=d8 - s8 - (regs.sr and $10) shr 4;
DestinationOperand8((currentOPcode and $7)+$10,ris8); // -(Ax) + -(Ay) ->(Ax)
update_ccr(gen, gen, bcd, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.subq_w;
begin
s16:=(currentOPcode and $e00)shr 9;
if s16=0 then s16:=8;
if (currentOPcode and $38<>AddressReg_n) then
        begin
        oldpc:=regs.pc;
        d16:=SourceOperand16(currentOPcode and $3f);
        if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
        ris16:=d16 - s16;
        DestinationOperand16(currentOPcode and $3f,ris16);
        update_ccr(gen, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
        end
   else begin
        d32:=SourceOperand32(currentOPcode and $3f);
        ris32:= d32-s16;
        DestinationOperand32(currentOPcode and $3f,ris32);
        end;
end;
(******************************************************************************)
procedure cpu68k.subq_l;
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=(currentOPcode and $e00)shr 9;
if s32=0 then s32:=8;
ris32:=d32 - s32;
DestinationOperand32(currentOPcode and $3f,ris32);
if (currentOPcode and $38<>AddressReg_n) then
   update_ccr(gen, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.subq_b;
begin
s8:=(currentOPcode and $e00)shr 9;
if s8=0 then s8:=8;
if (currentOPcode and $38<>AddressReg_n) then
        begin
        oldpc:=regs.pc;
        d8:=SourceOperand8(currentOPcode and $3f);
        if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
        ris8:=d8 - s8;
        DestinationOperand8(currentOPcode and $3f,ris8);
        update_ccr(gen, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
        end
   else begin
        d32:=SourceOperand32(currentOPcode and $3f);
        ris32:= d32-s8;
        DestinationOperand32(currentOPcode and $3f,ris32);
        end;

{oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=(currentOPcode and $e00)shr 9;
if s8=0 then s8:=8;
ris8:=d8 - s8;
DestinationOperand8(currentOPcode and $3f,ris8);
if (currentOPcode and $38<>AddressReg_n) then
   update_ccr(gen, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);}
end;
(******************************************************************************)
procedure cpu68k.sub_w_ea_Dn;
begin
s16:=SourceOperand16(currentOPcode and $3f);
d16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 - s16;
DestinationOperand16((currentOPcode and $e00) shr 9,ris16);
update_ccr(gen, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.sub_w_ea_An;
begin
s16:=SourceOperand16(currentOPcode and $3f);
s32:=signext16(s16);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)or 8);
DestinationOperand32(((currentOPcode and $e00) shr 9)or 8,d32 - s32);
end;
(******************************************************************************)
procedure cpu68k.sub_w_Dn_ea;
begin
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:= d16 - s16;
DestinationOperand16(currentOPcode and $3f,ris16);
update_ccr(gen, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.sub_l_ea_Dn;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 - s32;
DestinationOperand32((currentOPcode and $e00) shr 9,ris32);
update_ccr(gen, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.sub_l_ea_An;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)or 8);
DestinationOperand32(((currentOPcode and $e00) shr 9)or 8,d32 - s32);
end;
(******************************************************************************)
procedure cpu68k.sub_l_Dn_ea;                                       (*daichuui*)
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 - s32;
DestinationOperand32(currentOPcode and $3f,ris32);
update_ccr(gen, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.sub_b_ea_Dn;
begin
s8:=SourceOperand8(currentOPcode and $3f);
d8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 - s8;
DestinationOperand8((currentOPcode and $e00) shr 9,ris8);
update_ccr(gen, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.sub_b_Dn_ea;
begin
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 - s8;
DestinationOperand8(currentOPcode and $3f,ris8);
update_ccr(gen, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.or_w_ea_Dn;
begin
s16:=SourceOperand16(currentOPcode and $3f);
d16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 or s16;
DestinationOperand16((currentOPcode and $e00) shr 9,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.or_w_Dn_ea;
begin
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 or s16;
DestinationOperand16(currentOPcode and $3f,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.or_l_ea_Dn;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 or s32;
DestinationOperand32((currentOPcode and $e00) shr 9,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.or_l_Dn_ea;
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 or s32;
DestinationOperand32(currentOPcode and $3f,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.or_b_ea_Dn;
begin
s8:=SourceOperand8(currentOPcode and $3f);
d8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 or s8;
DestinationOperand8((currentOPcode and $e00) shr 9,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.or_b_Dn_ea;
begin
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 or s8;
DestinationOperand8(currentOPcode and $3f,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.muluw;
begin
s16:=sourceoperand16(currentOPcode and $3f);
d16:=sourceoperand16((currentOPcode and $e00) shr 9);
ris32:=d16 * s16;
//DestinationOperand8((currentOPcode and $e00) shr 9,ris32);
DestinationOperand32((currentOPcode and $e00) shr 9,ris32);
update_ccr(na, gen, gen, _add, set0, s16, d16, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.mulsw;                          (*warning sign missing*)
begin
s16:=sourceoperand16(currentOPcode and $3f);
d16:=sourceoperand16((currentOPcode and $e00) shr 9);
ris32:=d16 * s16;
DestinationOperand8((currentOPcode and $e00) shr 9,ris32);
update_ccr(na, gen, gen, _add, set0, s16, d16, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.lea;
begin
regs.a[(currentOpcode and $0e00) shr 9]:=jmpOperand(currentOpcode and $3f);
end;
(******************************************************************************)
procedure cpu68k.divu;//kore
begin
//regs.sr:=regs.sr or $c000;
s16:=sourceoperand16(currentOpcode and SourceEA);  {04/12/2005}
d16:=sourceoperand16((currentOpcode and $0e00) shr 9);
ris16:=d16 div s16;
destinationOperand16((currentOpcode and $0e00) shr 9,ris16);
update_ccr(na, gen, gen, gen, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.divs;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cpscc;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cpsave;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cprestore;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cpgen;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cpbcc_32;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cpbcc_16;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.cmp_w_ea_Dn;
begin
s16:=SourceOperand16(currentOPcode and $3f);
d16:=SourceOperand16((currentOPcode and $e00) shr 9);                  //look@ the and statement: it gets the Dregister number, and because the addressing 4 D is 000, that's all
ris16:=d16 - s16;
update_ccr(na, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.cmp_w_ea_An;
begin
s16:=SourceOperand16(currentOPcode and $3f);
s32:=signext16(s16);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)or 8);
ris32:=d32 - s32;
update_ccr(na, gen, gen, _sub, _sub, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.cmp_l_ea_Dn;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32((currentOPcode and $e00) shr 9);                  //look@ the and statement: it gets the Dregister number, and because the addressing 4 D is 000, that's all
ris32:=d32 - s32;
update_ccr(na, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.cmp_l_ea_An;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)or 8);            //in this case, getting the reg number is not enough, I need also to set the 4th bit
ris32:=d32 - s32;
update_ccr(na, gen, gen, _sub, _sub, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.cmp_b_ea_Dn;
begin
s8:=SourceOperand8(currentOPcode and $3f);
d8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 - s8;
update_ccr(na, gen, gen, _sub, _sub, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.chk_w;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.chk_l;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.btst;
var shiftcnt:longword;
begin {21/01/06}
s32:=SourceOperand32(currentOPcode and OperandEA);
shiftcnt:=1 shl (regs.d[(currentopcode and $0e00)shr 9]);
s32:=s32 and shiftcnt;
update_ccr(na, na, gen, na, na, 0, 0, s32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.bset;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.bclr;
begin
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.bchg;
var shiftcnt:longword;
begin {21/01/06}
oldpc:=regs.pc;
s32:=SourceOperand32(currentOPcode and OperandEA);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
shiftcnt:=1 shl (regs.d[(currentopcode and $0e00)shr 9]);
d32:=s32 and shiftcnt;
s32:=s32 xor shiftcnt;
destinationOperand32(currentOPcode and OperandEA,s32);
update_ccr(na, na, gen, na, na, 0, 0, d32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.and_w_ea_Dn;
begin
s16:=SourceOperand16(currentOPcode and $3f);
d16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 and s16;
DestinationOperand16((currentOPcode and $e00) shr 9,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.and_w_Dn_ea;
begin
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 and s16;
DestinationOperand16(currentOPcode and $3f,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.and_l_ea_Dn;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 and s32;
DestinationOperand32((currentOPcode and $e00) shr 9,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.and_l_Dn_ea;
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 and s32;
DestinationOperand32(currentOPcode and $3f,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.and_b_ea_Dn;
begin
s8:=SourceOperand8(currentOPcode and $3f);
d8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 and s8;
DestinationOperand8((currentOPcode and $e00) shr 9,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.and_b_Dn_ea;
begin
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 and s8;
DestinationOperand8(currentOPcode and $3f,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.addq_w;
begin
s16:=(currentOPcode and $e00)shr 9;
if s16=0 then s16:=8;
if (currentOPcode and $38<>AddressReg_n) then
        begin
        oldpc:=regs.pc;
        d16:=SourceOperand16(currentOPcode and $3f);
        if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
        ris16:=d16 + s16;
        DestinationOperand16(currentOPcode and $3f,ris16);
        update_ccr(gen, gen, gen, _add, _add, s16, d16, ris16, wordOperation);
        end
   else begin
        d32:=SourceOperand32(currentOPcode and $3f);
        ris32:=d32 + s16;
        DestinationOperand32(currentOPcode and $3f,ris32);
        end;
end;
(******************************************************************************)
procedure cpu68k.addq_l;
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=(currentOPcode and $e00)shr 9;
if s32=0 then s32:=8;
ris32:=d32 + s32;
DestinationOperand32(currentOPcode and $3f,ris32);
if (currentOPcode and $38<>AddressReg_n) then
   update_ccr(gen, gen, gen, _add, _add, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.addq_b;
begin
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=(currentOPcode and $e00)shr 9;
if s8=0 then s8:=8;
ris8:=d8 + s8;
DestinationOperand8(currentOPcode and $3f,ris8);
if (currentOPcode and $38<>AddressReg_n) then
   update_ccr(gen, gen, gen, _add, _add, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.add_w_ea_Dn;
begin
s16:=SourceOperand16(currentOPcode and $3f);
d16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 + s16;
DestinationOperand16((currentOPcode and $e00) shr 9,ris16);
update_ccr(gen, gen, gen, _add, _add, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.add_w_ea_An;
begin
s16:=SourceOperand16(currentOPcode and $3f);
s32:=signext16(s16);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)or 8);
DestinationOperand32(((currentOPcode and $e00) shr 9)or 8,d32 + s32);
end;
(******************************************************************************)
procedure cpu68k.add_w_Dn_ea;
begin
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 + s16;
DestinationOperand16(currentOPcode and $3f,ris16);
update_ccr(gen, gen, gen, _add, _add, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.add_l_ea_Dn;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 + s32;
DestinationOperand32((currentOPcode and $e00) shr 9,ris32);
update_ccr(gen, gen, gen, _add, _add, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.add_l_ea_An;
begin
s32:=SourceOperand32(currentOPcode and $3f);
d32:=SourceOperand32(((currentOPcode and $e00) shr 9)or 8);
DestinationOperand32(((currentOPcode and $e00) shr 9)or 8,d32 + s32);
end;
(******************************************************************************)
procedure cpu68k.add_l_Dn_ea;
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 + s32;
DestinationOperand32(currentOPcode and $3f,ris32);
update_ccr(gen, gen, gen, _add, _add, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.add_b_ea_Dn;
begin
s8:=SourceOperand8(currentOPcode and $3f);
d8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 + s8;
DestinationOperand8((currentOPcode and $e00) shr 9,ris8);
update_ccr(gen, gen, gen, _add, _add, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.add_b_Dn_ea;
begin
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 + s8;
DestinationOperand8(currentOPcode and $3f,ris8);
update_ccr(gen, gen, gen, _add, _add, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.scc;
begin
if conditionTest((currentOPcode and $0f00)shr 8) then begin
                                                          DestinationOperand8(currentOPcode and $3f,$ff);
                                                          end
                                                     else begin
                                                          DestinationOperand8(currentOPcode and $3f,$00);
                                                          end;
//regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.moveq;
begin
ris32:=signext8(currentOPcode and $ff);
DestinationOperand32((currentOPcode and $0e00)shr 9,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.move_w;
begin
d16:=SourceOperand16(currentOPcode and $3f);                                    //in this statement is needed to swap the 3 bits mode and the 3 bits regnum
if (currentOPcode and $1c0=$40)  then begin
                                       d32:=signext16(d16);
                                       {if d16 and $8000<>0 then d32:=$ffff0000+d16
                                                           else d32:=d16;}
                                       DestinationOperand32(regModSwap((currentOpcode and $fc0)shr 6), d32);
                                       end
                                  else begin
                                       DestinationOperand16(regModSwap((currentOpcode and $fc0)shr 6), d16);
                                       update_ccr(na, gen, gen, set0, set0, s16, d16, d16, wordOperation);
                                       end;
end;
(******************************************************************************)
procedure cpu68k.move_l;
begin
d32:=SourceOperand32(currentOPcode and $3f);                                    //in this statement is needed to swap the 3 bits mode and the 3 bits regnum
DestinationOperand32(regModSwap((currentOpcode and $fc0)shr 6), d32);
if (currentOPcode and $1c0<>$40) then
           update_ccr(na, gen, gen, set0, set0, s32, d32, d32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.move_b;
begin
d8:=SourceOperand8( currentOPcode and $3f);                                     //Note: this is not an error. MC68k's PC can't be odd. therefore in case of immediate 8 bit it has toread 2 bytes insted just one.
DestinationOperand8(regModSwap((currentOpcode and $fc0)shr 6), d8);
if (currentOPcode and $1c0<>$40) then
           update_ccr(na, gen, gen, set0, set0, s8, d8, d8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.eor_w_Dn_ea;
begin
oldpc:=regs.pc;
d16:=SourceOperand16(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s16:=SourceOperand16((currentOPcode and $e00) shr 9);
ris16:=d16 xor s16;
DestinationOperand16(currentOPcode and $3f,ris16);
update_ccr(na, gen, gen, set0, set0, s16, d16, ris16, wordOperation);
end;
(******************************************************************************)
procedure cpu68k.eor_l_Dn_ea;
begin
oldpc:=regs.pc;
d32:=SourceOperand32(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s32:=SourceOperand32((currentOPcode and $e00) shr 9);
ris32:=d32 xor s32;
DestinationOperand32(currentOPcode and $3f,ris32);
update_ccr(na, gen, gen, set0, set0, s32, d32, ris32, longOperation);
end;
(******************************************************************************)
procedure cpu68k.eor_b_Dn_ea;
begin
oldpc:=regs.pc;
d8:=SourceOperand8(currentOPcode and $3f);
if currentopcode and OperandEA>=IndexedIndirect then regs.pc:=oldpc;
s8:=SourceOperand8((currentOPcode and $e00) shr 9);
ris8:=d8 xor s8;
DestinationOperand8(currentOPcode and $3f,ris8);
update_ccr(na, gen, gen, set0, set0, s8, d8, ris8, byteOperation);
end;
(******************************************************************************)
procedure cpu68k.bcc;
begin
addpc:=0;
case currentOPcode and $ff of
$00:begin
    data:=memoryread16(regs.pc);
    data:=signext16(data);
    addpc:=2;
    end;
$ff:begin
    data:=memoryread32(regs.pc);
    addpc:=4;
    end;
else
    begin
    data:=currentOPcode and $ff;
    data:=signext8(data);
    end;
end;
if conditionTest((currentOPcode and $0f00)shr 8) then regs.pc:=regs.pc+data
                                                 else regs.pc:=regs.pc+addpc;
end;
(******************************************************************************)
procedure cpu68k.trapcc_w;
begin
{operands fetch}
{instruction ecxecution}
{update status}
regs.sr:=regs.sr or $c000;
end;
(******************************************************************************)
procedure cpu68k.trapcc_l;
begin
{operands fetch}
{instruction ecxecution}
{update status}
regs.sr:=regs.sr or $c000;
end;

