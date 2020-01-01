(******************************************************************************)
(* This file contans the implementations of the addressing related functions. *)
(*                                                                            *)
(******************************************************************************)
function cpu68k.add_0x28(Areg:longword):longword;
var d16:word;
begin
 d16:=memoryread16(regs.pc);
 result:=areg+signext16(d16);
 regs.pc:=regs.pc+2;
end;
(******************************************************************************)
function cpu68k.add_0x30(code:word):longword;
var extwordAddr : word;
    bd16    : word;
    bd232   : longword;
    bd32    : longword;
    RegD    : longword;
begin
extwordAddr:=memoryread16(regs.pc);
regs.pc:=regs.pc+2;
if (extwordAddr and $100=0) then
        begin (*Brief extension  68000*)
        if (extwordAddr and $8000=0) then RegD:=regs.d[(extwordAddr and $7000) shr 12]
                                     else RegD:=regs.a[(extwordAddr and $7000) shr 12];
        if (extwordAddr and $800=0)  then begin
                                          if RegD and $00008000<>0 then RegD:=RegD or $ffff0000
                                                                   else RegD:=RegD and $0000ffff;
                                          end;
        result:=regs.a[code and 7]+(RegD shl (extwordAddr and $600 shr 9))+signext8(extwordAddr and $ff);
        end
   else begin (*Full extension >=68020*)
        if (extwordAddr and $8000=0) then RegD:=regs.d[(extwordAddr and $7000) shr 12]
                                     else RegD:=regs.a[(extwordAddr and $7000) shr 12];
        if (extwordAddr and $800=0)  then begin
                                          if RegD and $00008000<>0 then RegD:=RegD or  $ffff0000
                                                                   else RegD:=RegD and $0000ffff;
                                          end;
        if (extwordAddr and $80=0)   then
                begin                        //BS
                case extwordAddr and $30 of
                     $10:begin
                         bd32:=memoryread8(regs.pc);
                         regs.pc:=regs.pc+2;
                         end;
                     $20:begin
                         bd32:=memoryread16(regs.pc);
                         regs.pc:=regs.pc+2;
                         end;
                     $30:begin
                         bd32:=memoryread32(regs.pc);
                         regs.pc:=regs.pc+4;
                         end;
                     end;
                end;
        case extwordAddr and $47 of
             $00:begin                                                    //0 000 000     No Memory Indirection
                 //##move.l  $55555555(a2,a5.l*8),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=regs.a[code and 7]+
                         (RegD shl (extwordAddr and $600 shr 9))+
                         bd32;
                 end;
             $01:begin                                                    //0 000 001     Indirect Preindexed with Null Outer Displacement
                 //move.l  ([$55555555,a2,a5.l*8]),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      (RegD shl (extwordAddr and $600 shr 9))+
                                      bd32
                                     );
                 end;
             $02:begin                                                    //0 000 010     Indirect Preindexed with Word Outer Displacement
                 //move.l  ([bd32,a2,RegD.l*8],$bd16),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 bd16:=memoryread16(regs.pc);
                 regs.pc:=regs.pc+2;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      (RegD shl (extwordAddr and $600 shr 9))+
                                      bd32
                                     )+
                         signext16(bd16);
                 end;
             $03:begin                                                    //0 000 011     Indirect Preindexed with Long Outer Displacement
                 //move.l  ([$55555555,a2,a5.l*8],$55555555),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 bd232:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      (RegD shl (extwordAddr and $600 shr 9))+
                                      bd32
                                     )+
                         bd232;
                 end;
             $05:begin                                                    //0 000 101     Indirect Postindexed with Mull Outer Displacement
                 //move.l  ([$55555555,a2],a5.l*8),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      bd32
                                     )+
                         (RegD shl (extwordAddr and $600 shr 9));
                 end;
             $06:begin                                                    //0 000 110     Indirect Postindexed with Word Outer Displacement
                 //##move.l  ([$55555555,a2],a5.l*8,$5555),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 bd16:=memoryread16(regs.pc);
                 regs.pc:=regs.pc+2;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      bd32
                                     )+
                         (RegD shl (extwordAddr and $600 shr 9))+
                         signext16(bd16);
                 end;
             $07:begin                                                    //0 000 111     Indirect Postindexed with Long Outer Displacement
                 //##move.l  ([$55555555,a2],a5.l*8,$55555555),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 bd232:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      bd32
                                     )+
                         (RegD shl (extwordAddr and $600 shr 9))+
                         bd232;
                 end;
             $40:begin                                                    //1 000 000     No Memory Indirection
                 //##move.l  $55555555(a2),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=regs.a[code and 7]+
                         bd32;
                 end;
             $41:begin                                                    //1 000 001     Memory Indirect with Mull Outer Displacement
                 //##move.l  ([$55555555,a2]),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      bd32
                                     );
                 end;
             $42:begin                                                    //1 000 010     Memory Indirect with Word Outer Displacement
                 //##move.l  ([$55555555,a2],$5555),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 bd16:=memoryread16(regs.pc);
                 regs.pc:=regs.pc+2;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      bd32
                                     )+
                         signext16(bd16);
                 end;
             $43:begin                                                    //1 000 011     Memory Indirect with Long Outer Displacement
                 //##move.l  ([$55555555,a2],$55555555),d3
                 bd32:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 bd232:=memoryread32(regs.pc);
                 regs.pc:=regs.pc+4;
                 result:=memoryRead32(
                                      regs.a[code and 7]+
                                      bd32
                                     )+
                         bd232;
                 end;
             end; //## nested case
           end;  //## else (68020 ijou istr)
end;
(******************************************************************************)
function cpu68k.add_0x38(code,size:word):longword;
var ExtWord : word;
    bd16    : word;
    bd232   : longword;
    bd32    : longword;
    RegD    : longword;
begin
case code and 7 of
0:begin //(xxxx).w
  bd16:=memoryread16(regs.pc);
  //result:=bd16;
  result:=signext16(bd16);
  regs.pc:=regs.pc+2;
  end;
1:begin //(xxxx).l
  bd32:=memoryread32(regs.pc);
  result:=bd32;
  regs.pc:=regs.pc+4;
  end;
2:begin  //(d16,PC)
  bd16:=memoryread16(regs.pc);
  result:=regs.PC+signext16(bd16);
  regs.pc:=regs.pc+2;
  end;
3:begin  //(d8,PC,Xn)    brief word
  ExtWord:=memoryread16(regs.pc);
  regs.pc:=regs.pc+2;
  if (ExtWord and $100=0) then begin (*Brief extension  68000*)
                               if (ExtWord and $8000=0) then RegD:=regs.d[(ExtWord and $7000) shr 12]
                                                        else RegD:=regs.a[(ExtWord and $7000) shr 12];
                               if (ExtWord and $800=0)  then begin
                                                             if RegD and $00008000<>0 then RegD:=RegD or $ffff0000
                                                                                      else RegD:=RegD and $0000ffff;
                                                             end;
                               result:=regs.PC-2+
                                       (RegD shl (ExtWord and $600 shr 9))+
                                       signext8(ExtWord and $ff);
                               end
                          else begin (*Full extension >=68020*)
                               if (ExtWord and $8000=0) then RegD:=signext16(lo16(regs.d[(ExtWord and $7000) shr 12]))
                                                        else RegD:=signext16(lo16(regs.a[(ExtWord and $7000) shr 12]));
                               if (ExtWord and $800=0)  then begin
                                                             if RegD and $00008000<>0 then RegD:=RegD or $ffff0000
                                                                                      else RegD:=RegD and $0000ffff;
                                                             end;
                               if (ExtWord and $80=0)   then begin                        //BS
                                                             case ExtWord and $30 of
                                                              $10:begin
                                                                  bd32:=memoryread8(regs.pc);
                                                                  regs.pc:=regs.pc+2;
                                                                  end;
                                                              $20:begin
                                                                  bd32:=memoryread16(regs.pc);
                                                                  regs.pc:=regs.pc+2;
                                                                  end;
                                                              $30:begin
                                                                  bd32:=memoryread32(regs.pc);
                                                                  regs.pc:=regs.pc+4;
                                                                  end;
                                                              end;
                                                             end;
                               case ExtWord and $47 of
                                 $00:begin                                                    //0 000 000     No Memory Indirection
                                     //##move.l  $55555555(a2,a5.l*8),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=regs.PC-6+
                                             (RegD shl (ExtWord and $600 shr 9))+
                                             bd32;
                                     end;
                                 $01:begin                                                    //0 000 001     Indirect Preindexed with Null Outer Displacement
                                     //move.l  ([$55555555,a2,a5.l*8]),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=memoryRead32(
                                                          regs.PC-6+
                                                          (RegD shl (ExtWord and $600 shr 9))+
                                                          bd32
                                                         );
                                     end;
                                 $02:begin                                                    //0 000 010     Indirect Preindexed with Word Outer Displacement
                                     //move.l  ([bd32,a2,RegD.l*8],$bd16),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     bd16:=memoryread16(regs.pc);
                                     regs.pc:=regs.pc+2;
                                     result:=memoryRead32(
                                                          regs.PC-8+
                                                          (RegD shl (ExtWord and $600 shr 9))+
                                                          bd32
                                                         )+
                                             signext16(bd16);
                                     end;
                                 $03:begin                                                    //0 000 011     Indirect Preindexed with Long Outer Displacement
                                     //move.l  ([$55555555,a2,a5.l*8],$55555555),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     bd232:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=memoryRead32(
                                                          regs.PC-10+
                                                          (RegD shl (ExtWord and $600 shr 9))+
                                                          bd32
                                                         )+
                                             bd232;
                                     end;
                                 $05:begin                                                    //0 000 101     Indirect Postindexed with Mull Outer Displacement
                                     //move.l  ([$55555555,a2],a5.l*8),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=memoryRead32(
                                                          regs.PC-6+
                                                          bd32
                                                         )+
                                             (RegD shl (ExtWord and $600 shr 9));
                                     end;
                                 $06:begin                                                    //0 000 110     Indirect Postindexed with Word Outer Displacement
                                     //##move.l  ([$55555555,a2],a5.l*8,$5555),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     bd16:=memoryread16(regs.pc);
                                     regs.pc:=regs.pc+2;
                                     result:=memoryRead32(
                                                          regs.PC-8+
                                                          bd32
                                                         )+
                                             (RegD shl (ExtWord and $600 shr 9))+
                                             signext16(bd16);
                                     end;
                                 $07:begin                                                    //0 000 111     Indirect Postindexed with Long Outer Displacement
                                     //##move.l  ([$55555555,a2],a5.l*8,$55555555),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     bd232:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=memoryRead32(
                                                          regs.PC-10+
                                                          bd32
                                                         )+
                                             (RegD shl (ExtWord and $600 shr 9))+
                                             bd232;
                                     end;
                                 $40:begin                                                    //1 000 000     No Memory Indirection
                                     //##move.l  $55555555(a2),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=regs.pc-6+
                                             bd32;
                                     end;
                                 $41:begin                                                    //1 000 001     Memory Indirect with Mull Outer Displacement
                                     //##move.l  ([$55555555,a2]),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=memoryRead32(
                                                          regs.PC-6+
                                                          bd32
                                                         );
                                     end;
                                 $42:begin                                                    //1 000 010     Memory Indirect with Word Outer Displacement
                                     //##move.l  ([$55555555,a2],$5555),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     bd16:=memoryread16(regs.pc);
                                     regs.pc:=regs.pc+2;
                                     result:=memoryRead32(
                                                          regs.PC-8+
                                                          bd32
                                                         )+
                                             signext16(bd16);
                                     end;
                                 $43:begin                                                    //1 000 011     Memory Indirect with Long Outer Displacement
                                     //##move.l  ([$55555555,a2],$55555555),d3
                                     bd32:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     bd232:=memoryread32(regs.pc);
                                     regs.pc:=regs.pc+4;
                                     result:=memoryRead32(
                                                          regs.PC-10+
                                                          bd32
                                                         )+
                                             bd232;
                                     end;
                                 end;
                               end;
  end;
4:begin
  result:=regs.pc;                                            //!!!!!!!!!!!!
  regs.pc:=regs.pc+size;
  end;
5:begin end;
6:begin end;
7:begin end;
end;
end;
(******************************************************************************)
function cpu68k.SourceOperand8(code:byte):byte;
begin
case (code and $38) of
     $00:result:=regs.d[code and 7] and $ff;
     $08:result:=regs.a[code and 7] and $ff;
     $10:result:=memoryRead8(regs.a[code and 7]);
     $18:begin
         result:=memoryRead8(regs.a[code and 7]);
         regs.a[code and 7]:=regs.a[code and 7]+1;
         end;
     $20:begin
         regs.a[code and 7]:=regs.a[code and 7]-1;
         result:=memoryRead8(regs.a[code and 7]);
         end;
     $28:result:=memoryRead8(add_0x28(regs.a[code and 7]));
     $30:result:=memoryRead8(add_0x30(code));
     $38:if code =$3c then result:=memoryRead8(add_0x38(code,2)+1)
                      else result:=memoryRead8(add_0x38(code,2));
     end;
end;
(******************************************************************************)
function cpu68k.SourceOperand16(code:byte):word;
begin
case (code and $38) of
     $00:result:=regs.d[code and 7] and $ffff;
     $08:result:=regs.a[code and 7] and $ffff;
     $10:result:=memoryRead16(regs.a[code and 7]);
     $18:begin
         result:=memoryRead16(regs.a[code and 7]);
         regs.a[code and 7]:=regs.a[code and 7]+2;
         end;
     $20:begin
         regs.a[code and 7]:=regs.a[code and 7]-2;
         result:=memoryRead16(regs.a[code and 7]);
         end;
     $28:result:=memoryRead16(add_0x28(regs.a[code and 7]));
     $30:result:=memoryRead16(add_0x30(code));
     $38:result:=memoryRead16(add_0x38(code,2));
     end;
end;
(******************************************************************************)
function cpu68k.SourceOperand32(code:byte):longword;
begin
{$IFDEF debug}
if data = $FB1CC then asm
                       nop
                      end;
{$ENDIF}
case (code and $38) of
     $00:result:=regs.d[code and 7];
     $08:result:=regs.a[code and 7];
     $10:result:=memoryRead32(regs.a[code and 7]);
     $18:begin
         result:=memoryRead32(regs.a[code and 7]);
         regs.a[code and 7]:=regs.a[code and 7]+4;
         end;
     $20:begin
         regs.a[code and 7]:=regs.a[code and 7]-4;
         result:=memoryRead32(regs.a[code and 7]);
         end;
     $28:result:=memoryRead32(add_0x28(regs.a[code and 7]));
     $30:result:=memoryRead32(add_0x30(code));
     $38:result:=memoryRead32(add_0x38(code,4));
     end;
end;
(******************************************************************************)
procedure cpu68k.DestinationOperand8(code:byte;data:byte);
begin
case (code and $38) of
     $00:regs.d[code and 7]:=regs.d[code and 7]and $ffffff00 or data;
     $08:regs.a[code and 7]:=regs.a[code and 7]and $ffffff00 or data;
     $10:memoryWrite8(regs.a[code and 7],data);
     $18:begin
         memoryWrite8(regs.a[code and 7],data);
         regs.a[code and 7]:=regs.a[code and 7]+1;
         end;
     $20:begin
         regs.a[code and 7]:=regs.a[code and 7]-1;
         memoryWrite8(regs.a[code and 7],data);
         end;
     $28:memoryWrite8(add_0x28(regs.a[code and 7]),data);
     $30:memoryWrite8(add_0x30(code),data);
     $38:memoryWrite8(add_0x38(code,2),data);
     end;
end;
(******************************************************************************)
procedure cpu68k.DestinationOperand16(code:byte;data:word);
begin
case (code and $38) of
     $00:regs.d[code and 7]:=regs.d[code and 7]and $ffff0000 or data;
     $08:regs.a[code and 7]:=regs.a[code and 7]and $ffff0000 or data;
     $10:memoryWrite16(regs.a[code and 7],data);
     $18:begin
         memoryWrite16(regs.a[code and 7],data);
         regs.a[code and 7]:=regs.a[code and 7]+2;
         end;
     $20:begin
         regs.a[code and 7]:=regs.a[code and 7]-2;
         memoryWrite16(regs.a[code and 7],data);
         end;
     $28:memoryWrite16(add_0x28(regs.a[code and 7]),data);
     $30:memoryWrite16(add_0x30(code),data);
     $38:memoryWrite16(add_0x38(code,2),data);
     end;
end;
(******************************************************************************)
procedure cpu68k.DestinationOperand32(code:byte;data:longword);
begin
{$IFDEF debug}
if data = $FB1CC then asm
                       nop
                      end;
{$ENDIF}
case (code and $38) of
     $00:regs.d[code and 7]:=data;
     $08:regs.a[code and 7]:=data;
     $10:memoryWrite32(regs.a[code and 7],data);
     $18:begin
         memoryWrite32(regs.a[code and 7],data);
         regs.a[code and 7]:=regs.a[code and 7]+4;
         end;
     $20:begin
         regs.a[code and 7]:=regs.a[code and 7]-4;
         memoryWrite32(regs.a[code and 7],data);
         end;
     $28:memoryWrite32(add_0x28(regs.a[code and 7]),data);
     $30:memoryWrite32(add_0x30(code),data);
     $38:memoryWrite32(add_0x38(code,4),data);
     end;
end;
(******************************************************************************)
function cpu68k.jmpOperand(code:byte):longword;
begin
case (code and $38) of
     $10:result:=regs.a[code and 7];
     $18:result:=regs.a[code and 7];
     $20:result:=regs.a[code and 7]-4;
     $28:result:=add_0x28(regs.a[code and 7]);
     $30:result:=add_0x30(code);
     $38:result:=add_0x38(code,4);
     end;
end;

