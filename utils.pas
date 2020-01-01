(******************************************************************************)
(* This file contans the implementations of the internal behaviour of MC68k   *)
(*                                                                            *)
(******************************************************************************)
procedure cpu68k.interrupt(intr:byte);
begin
pending_interrupt^:=true;
pending_interruptNo^:=intr and 7;
end;
(***********************************************************)
procedure cpu68k.fetch;
begin
{$IFDEF debug}
if (regs.pc>=$00106AFB) and (regs.pc<=$01000000)
                       then asm
                            nop
                            end;
{$ENDIF}
if pending_interrupt^ then begin
                          if DebugNoCount then inc(CPUCycles,8);
                          if (pending_interruptNo^>=24) and (pending_interruptNo^<32 )then
                             begin
                             if  (pending_interruptNo^-24 > hi(regs.sr and $700)) or (pending_interruptNo^-24=7) then
                                                                                         begin
                                                                                         except_exec(pending_interruptNo^ shl 2,InterruptEx);
                                                                                         end;
                             //pending_interrupt^:=false;
                             end
                           else
                             begin
                             except_exec(pending_interruptNo^ shl 2,InterruptEx);
                             //pending_interrupt^:=false;
                             end;
                          end;
if regs.a[7]>$1800 then begin
                        asm nop end;
                        end;
currentOPcode:=memoryRead16(regs.pc);
{$IFDEF debug}
MOpc:=doldpc;
doldpc:=regs.pc;
prevflags:=regs.sr;
{$ENDIF}
regs.pc:=regs.pc+2;
end;
(***********************************************************)
procedure cpu68k.SetPC(addrpc:longword);
begin
regs.pc:=addrpc;
end;
(***********************************************************)
procedure cpu68k.execute;
var i:word;
{$IFDEF debug}
    j:word;
    prevopcode:word;
{$ENDIF}
begin
{i:=0;
while (currentOPcode or mskopcodes[i] <> cmpopcodes[i])and (i<=nopcodes) do inc(i);
if i<=nopcodes then begin}
decodetable[currentopcode];
                    //begin
                    //handlingRoutines[i];
                    {$IFDEF debug}
                    {currentINSTR:=opcodNames[i];
                    //if instrStat[i,0]=0 then regs.sr:=regs.sr or $c000;
                    inc(instrStat[i,0]);
                    instrStat[i,1]:=CPUCycles;
                    instrStat[i,3]:=instrStat[i,3] or (regs.sr xor prevflags);
                    if currentopcode or mskopcodes[$101] = cmpopcodes[$101] then
                       begin
                       DebugNoCount:=false;
                       prevopcode:=memoryRead16(mopc);
                       DebugNoCount:=true;
                       j:=0;
                       while (prevopcode or mskopcodes[j] <> cmpopcodes[j]) and (j<=nopcodes) do inc(j);
                       if j<=nopcodes then inc(instrStat[j,2]);
                       end;}
                    {$ENDIF}
                    //end else raise unhandled_instruction.create('unknown 68k instr');

end;
(***********************************************************)
function cpu68k.opcod:string;
var i:word;
begin
end;
(***********************************************************)
procedure cpu68k.update_ccr(x,n,z,v,c:byte;source,destination,res:longword;size:byte);
var xf,nf,zf,vf,cf,r_sign,s_sign,d_sign:boolean;
begin
case size of
longOperation:begin
              r_sign:=(res         and $80000000)<>0;
              s_sign:=(source      and $80000000)<>0;
              d_sign:=(destination and $80000000)<>0;
              end;
wordOperation:begin
              r_sign:=(res         and $8000)<>0;
              s_sign:=(source      and $8000)<>0;
              d_sign:=(destination and $8000)<>0;
              end;
byteOperation:begin
              r_sign:=(res         and $80)<>0;
              s_sign:=(source      and $80)<>0;
              d_sign:=(destination and $80)<>0;
              end;
end;

{processing n flag}

case n of
na:   begin end;
set0: regs.sr:=regs.sr and $fff7;
gen:  if r_sign then regs.sr:=regs.sr or  $0008
                else regs.sr:=regs.sr and $fff7;
end;

{processing z flag}

case z of
na:  begin end;
set0:regs.sr:=regs.sr and $fffb;
gen: if res=0 then regs.sr:=regs.sr or  $0004
              else regs.sr:=regs.sr and $fffb;
bcd: if (res=0) and ((regs.sr and $0004)<>0) then regs.sr:=regs.sr or  $0004
                                             else regs.sr:=regs.sr and $fffb;
end;

{processing v flag}

case v of
na:   begin end;
set0: regs.sr:=regs.sr and $fffd;
_add: if (    s_sign and     d_sign and not r_sign) or
         (not s_sign and not d_sign and     r_sign) then regs.sr:=regs.sr or 2
                                                    else regs.sr:=regs.sr and $fffd;
_sub: if (not s_sign and     d_sign and not r_sign) or
         (    s_sign and not d_sign and     r_sign) then regs.sr:=regs.sr or 2
                                                    else regs.sr:=regs.sr and $fffd;
_asl: if d_sign xor r_sign then regs.sr:=regs.sr or 2
                           else regs.sr:=regs.sr and $fffd; 
end;

{processing c flag}

case c of
na:     begin end;
set0:   regs.sr:=regs.sr and $fffe;
set1:   regs.sr:=regs.sr or  $0001;
set2x:  if ((regs.sr and $0010)<>0) then regs.sr:=regs.sr or  $0001
                                    else regs.sr:=regs.sr and $fffe;
_add:   if (    s_sign and     d_sign               ) or
           (                   d_sign and not r_sign) or
           (    s_sign and                not r_sign) then regs.sr:=regs.sr or 1
                                                      else regs.sr:=regs.sr and $fffe; 
_sub:   if (    s_sign and not d_sign               ) or
           (               not d_sign and     r_sign) or
           (    s_sign and                    r_sign) then regs.sr:=regs.sr or 1
                                                      else regs.sr:=regs.sr and $fffe; 
end;

{processing x flag}

case x of
na: begin end;
gen:if ((regs.sr and $0001)<>0) then regs.sr:=regs.sr or  $0010
                                else regs.sr:=regs.sr and $ffef;
end;

end;
(***********************************************************)
function cpu68k.ConditionTest(b:byte):boolean;
begin
 result:=false;
case b of
$0:begin //True
   result:=true;
   end;
$1:begin //False
   end;
$2:begin //High
   if regs.sr and 5 =0 then result:=true;
   end;
$3:begin //Low or Same
   if (regs.sr and 1 =1)or (regs.sr and 4 =4) then result:=true;
   end;
$4:begin //Carry Clear
   if regs.sr and 1 =0 then result:=true;
   end;
$5:begin //Carry Set
   if regs.sr and 1 =1 then result:=true;
   end;
$6:begin //Not Equal
   if regs.sr and 4 =0 then result:=true;
   end;
$7:begin //Equal
   if regs.sr and 4 =4 then result:=true;
   end;
$8:begin //Overflow Clear
   if regs.sr and 2 =0 then result:=true;
   end;
$9:begin //Overflow Set
   if regs.sr and 2 =2 then result:=true;
   end;
$A:begin //Plus
   if regs.sr and 8 =0 then result:=true;
   end;
$B:begin //Minus
   if regs.sr and 8 =8 then result:=true;
   end;
$C:begin //Greater or Equal
   if (regs.sr and $A = $A)or(regs.sr and $A = 0) then result:=true;
   end;
$D:begin //Less Than
   if (regs.sr and $A = 8)or(regs.sr and $A = 2) then result:=true;
   end;
$E:begin //Greater Than
   if (regs.sr and $E = $A)or(regs.sr and $E = 0) then result:=true;
   end;
$F:begin //Less or Equal
   if (regs.sr and $A = 8)or(regs.sr and $A = 2)or(regs.sr and 4 =4) then result:=true;
   end;
end;
end;
(***********************************************************)
procedure cpu68k.addDevice8(address,addrDepth:longword;r:deviceReadFun8;w:devicewriteFun8);
begin
inc(DeviceNOW8);
MemMapIO8[deviceNOW8,0]:=address;
MemMapIO8[deviceNOW8,1]:=addrDepth;
MemMapDevR8[deviceNOW8]:=r;
MemMapDevW8[deviceNOW8]:=w;
end;
(***********************************************************)
procedure cpu68k.addDevice16(address,addrDepth:longword;r:deviceReadFun16;w:devicewriteFun16);
begin
inc(DeviceNOW16);
MemMapIO16[deviceNOW16,0]:=address;
MemMapIO16[deviceNOW16,1]:=addrDepth;
MemMapDevR16[deviceNOW16]:=r;
MemMapDevW16[deviceNOW16]:=w;
end;
(***********************************************************)
procedure cpu68k.addDevice32(address,addrDepth:longword;r:deviceReadFun32;w:devicewriteFun32);
begin
inc(DeviceNOW32);
MemMapIO32[deviceNOW32,0]:=address;
MemMapIO32[deviceNOW32,1]:=addrDepth;
MemMapDevR32[deviceNOW32]:=r;
MemMapDevW32[deviceNOW32]:=w;
end;
(***********************************************************)
function  cpu68k.validatefake(address:longword):byte;
begin
result:=3;
end;
(***********************************************************)
function  cpu68k.warpround(address:longword)            : longword;
begin
result:=address and warproundwrite;
end;
(***********************************************************)
Procedure cpu68k.InstallIntCtrl(PInt,PIntNo:pointer);
begin
pending_interrupt:=PInt;
pending_interruptNo:=PIntNo;
end;
(***********************************************************)
procedure cpu68k.except_exec(vector:longword;Ex_type:byte);
begin
//PushExType(flags);
if vector=8 then ex_type:=BusFaultEx;
InternalCopySR:=regs.sr;
if regs.sr and $2000 =0 then begin
                             regs.usp:=regs.A[7];
                             regs.A[7]:=regs.msp;
                             end;
regs.sr:=regs.sr or    SetSImmediate ;
regs.sr:=regs.sr and ResetTTImmediate;
case Ex_type of
InterruptEx: begin
             regs.sr:=regs.sr and $f8ff;
             regs.sr:=regs.sr or ((pending_interruptNo^-24) shl 8);
             DestinationOperand16($27,vector);//vector shr 2);
             DestinationOperand32($27,regs.pc);
             DestinationOperand16($27,internalCopySR);
             if regs.sr and SetMImmediate<>0 then begin
                                                  regs.msp:=regs.a[7];
                                                  regs.a[7]:=regs.isp;
                                                  regs.sr:=regs.sr and resetMImmediate;
                                                  DestinationOperand16($27,vector or setFrameStackType1);//(vector shr 2) or setFrameStackType1);
                                                  DestinationOperand32($27,regs.pc);
                                                  DestinationOperand16($27,regs.sr);
                                                  end;
             end;
TrapEx:      begin
             DestinationOperand16($27,vector);//vector shr 2);
             DestinationOperand32($27,regs.pc);
             DestinationOperand16($27,internalCopySR);
             end;
BusFaultEx:  begin
             DestinationOperand16($27,0);  (* need padding 4 bus fault*)
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,0);
             DestinationOperand16($27,vector or setFrameStackTypeA);//(vector shr 2)or setFrameStackTypeA);
             DestinationOperand32($27,regs.pc);
             DestinationOperand16($27,internalCopySR);
             end;
end;
regs.pc:=memoryRead32(regs.vbr+vector );
pending_interrupt^:=false;
end;
(***********************************************************)
procedure cpu68k.fakeResetIO;
begin
end;
(***********************************************************)
procedure cpu68k.setResetio(r:resproc);
begin
resetio:=r;
end;
(***********************************************************)
{$IFDEF debug}
procedure cpu68k.savestat;
var    f: textfile;
       i:word;
       s:string;
begin
assignfile(f,'MC68Stat.txt');
rewrite(f);
for i:=0 to nopcodes do if instrStat[i,0]<>0 then
                        begin
                        s:=inttohex(CPUCycles-instrStat[i,1],8)+
                                  ' cycles ago, last of '+
                                  inttohex(instrStat[i,0],8)+
                                  ' of which '+inttohex(instrStat[i,2],8)+
                                  ' before a Bcc -> [';
                        if instrStat[i,3] and 1     <>0 then s:=s+'C' else s:=s+#32;
                        if instrStat[i,3] and 2     <>0 then s:=s+'V' else s:=s+#32;
                        if instrStat[i,3] and 4     <>0 then s:=s+'Z' else s:=s+#32;
                        if instrStat[i,3] and 8     <>0 then s:=s+'N' else s:=s+#32;
                        if instrStat[i,3] and $10   <>0 then s:=s+'X' else s:=s+#32;
                        if instrStat[i,3] and $1000 <>0 then s:=s+'M' else s:=s+#32;
                        if instrStat[i,3] and $2000 <>0 then s:=s+'S' else s:=s+#32;
                        s:=s+'] ';//+opcodNames[i];
                        writeln(f,s);
                        end;
writeln(f,'tracing');
for i:=0 to trace_top do writeln(f,inttohex(trace_facility[i],8));
closefile(f);
end;
{$ENDIF}
(***********************************************************)
procedure cpu68k.dump;
var f:file;
    i:word;
begin
assignfile(f,MemoryFName);
rewrite(f,1);
i:=0;
while MemoryMap[i]<>nil do begin
                           blockwrite(f,MemoryMap[i]^,$100000);
                           inc(i);
                           end;
closefile(f);
end;
(***********************************************************)
procedure cpu68k.CPUStatusSave;
var f:file;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,internalcopysr,addrcalc(@NoUseButItsAddress1,@internalcopysr));    //37);
blockwrite(f,oldpc,addrcalc(@NoUseButItsAddress2,@oldpc));              //136);
closefile(f);
end;
(***********************************************************)
procedure cpu68k.CPUStatusRestore;
var f:file;
begin
assignfile(f,SaveFileName);
reset(f,1);
blockread(f,internalcopysr,addrcalc(@NoUseButItsAddress1,@internalcopysr));
blockread(f,oldpc,addrcalc(@NoUseButItsAddress2,@oldpc));
closefile(f);
end;
(***********************************************************)
procedure cpu68k.RestoreMemory;
var f:file;
    i:word;
begin
assignfile(f,MemoryFName);
reset(f,1);
i:=0;
while MemoryMap[i]<>nil do begin
                           blockread(f,MemoryMap[i]^,$100000);
                           inc(i);              
                           end;
closefile(f);
end;



