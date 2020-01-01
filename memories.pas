(******************************************************************************)
(* This file contans the implementations of the high level bridge memory      *)
(* access procedure and function.                                             *)
(******************************************************************************)
function cpu68k.memoryRead8(address:longword):byte;
var i:byte;                                                                     //General use counter.
begin
{$IFDEF debug}
if address=$3d724b then asm
                        nop
                        end;
{$ENDIF}
if DebugNoCount then inc(CPUCycles,2);
i:=1;
while (not((address>=MemMapIO8[i,0])and (address<MemMapIO8[i,0] + MemMapIO8[i,1]))and(i<=deviceNOW8)) do inc(i);
if (i<=deviceNOW8) and (deviceNOW8<>$08) then
                                              memoryRead8:=MemMapDevR8[i](address-MemMapIO8[i,0])
                                         else begin
                                              memoryRead8:=$0;
                                              if validateFun(address)>0 then
                                                 begin
                                                 if memorymap[address shr 20]<>nil then
                                                    memoryRead8:=getbyte(address and $FFFFF,memorymap[address shr 20]^);
                                                 end
                                                 else Interrupt(Buserror);
                                              end;
end;
(***********************************************************)
function cpu68k.memoryRead16(address:longword):word;                            //Perform a Word reading from memory
var i:byte;
begin
{$IFDEF debug}
if (address>=$01000000)and(address<=$01800000)then asm
                        nop
                        end;
{$ENDIF}
if DebugNoCount then inc(CPUCycles,2);
i:=1;
while (not((address>=MemMapIO16[i,0])and (address<MemMapIO16[i,0] + MemMapIO16[i,1]))and(i<=deviceNOW16)) do inc(i);
if (i<=deviceNOW16) and (deviceNOW16<>$08) then
                                                memoryRead16:=MemMapDevR16[i](address-MemMapIO16[i,0])
                                           else begin
                                                memoryRead16:=$0;
                                                if validateFun(address)>0 then
                                                   begin
                                                   if memorymap[address shr 20]<>nil then
                                                      memoryRead16:=getword(address and $FFFFF,memorymap[address shr 20]^)
                                                   end;
                                                end;
end;
(***********************************************************)
function cpu68k.memoryRead32(address:longword):longword;                        //Perform a Word reading from memory
begin
if DebugNoCount then inc(CPUCycles,4);
{$IFDEF debug}
if (address>=$01000000)and(address<=$01800000)then asm
                        nop
                        end;
{$ENDIF}
memoryRead32:=$0;
if validateFun(address)>0 then
   begin
   if memorymap[address shr 20]<>nil then
      memoryRead32:=getlongword(address and $FFFFF,memorymap[address shr 20]^);
   end;
end;
(***********************************************************)
procedure cpu68k.memoryWrite8(address:longword;data:byte);
var i:byte;
begin
if DebugNoCount then inc(CPUCycles,2);
i:=0;
{$IFDEF debug}
if (address>=$02130000) then asm        //0009CE7C   2d7a4
                        nop
                        end;
{$ENDIF}
while (not((address>=MemMapIO8[i,0])and (address<MemMapIO8[i,0] + MemMapIO8[i,1]))and(i<=deviceNOW8)) do inc(i);
if (i<=deviceNOW8) and (deviceNOW8<>0) then MemMapDevW8[i](address-MemMapIO8[i,0],data)
                                       else begin
                                            if validateFun(address)>1 then
                                                  begin
                                                   if address<$01000000 then address:=warpround(address);
                                                   if memorymap[address shr 20]<>nil then
                                                      putbyte(address and $FFFFF,data,memorymap[address shr 20]^);
                                                  end
                                             else if validateFun(address)=0 then Interrupt(Buserror);
                                            end;
end;
(***********************************************************)
procedure cpu68k.memoryWrite16(address:longword;data:word);
var i:byte;
begin
if DebugNoCount then inc(CPUCycles,2);
i:=1;
{$IFDEF debug}
if (address>=$02130000) then asm
                        nop
                        end;
{$ENDIF}
while (not((address>=MemMapIO16[i,0])and (address<MemMapIO16[i,0] + MemMapIO16[i,1]))and(i<=deviceNOW16)) do inc(i);
if (i<=deviceNOW16) and (deviceNOW16<>$08) then MemMapDevW16[i](address-MemMapIO16[i,0],data)
                                           else begin
                                                if validateFun(address)>1 then
                                                      begin
                                                      if address<$01000000 then address:=warpround(address);
                                                      if memorymap[address shr 20]<>nil then
                                                         putword(address and $FFFFF,data,memorymap[address shr 20]^);
                                                      end
                                                else if validateFun(address)=0 then Interrupt(Buserror);
                                                end;
end;
(***********************************************************)
procedure cpu68k.memoryWrite32(address:longword;data:longword);
var i:byte;
begin
if DebugNoCount then inc(CPUCycles,4);
i:=1;
{$IFDEF debug}
if (address>=$02130000) then asm
                        nop
                        end;
{$ENDIF}
while (not((address>=MemMapIO32[i,0])and (address<MemMapIO32[i,0] + MemMapIO32[i,1]))and(i<=deviceNOW32)) do inc(i);
if (i<=deviceNOW32) and (deviceNOW32<>$08) then MemMapDevW32[i](address-MemMapIO32[i,0],data)
                                           else begin
                                                if validateFun(address)>1 then
                                                      begin
                                                      if address<$01000000 then address:=warpround(address);
                                                      if memorymap[address shr 20]<>nil then
                                                         putlongword(address and $FFFFF,data,memorymap[address shr 20]^);
                                                      end
                                                else if validateFun(address)=0 then Interrupt(Buserror);
                                                end;
end;
(***********************************************************)
procedure cpu68k.addMemorypage(No:word;page:pointer);
begin
memorymap[No]:=page;
end;
