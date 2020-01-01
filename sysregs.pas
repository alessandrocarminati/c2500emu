Unit sysregs;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
uses ictrl;
const Ram_size_16MB = $00;                                                      //predefined value for 16Mb of ram.
      Ram_size_04MB = $10;                                                      //predefined value for 4Mb of ram.
      Ram_size_01MB = $20;                                                      //predefined value for 1Mb of ram.
      Ram_size_08MB = $30;                                                      //predefined value for 8Mb of ram.
      ROM_size_04MB = $C;                                                       //predefined value for 4Mb of rom.
      ROM_size_02MB = $0;                                                       //predefined value for 2Mb of rom.
      ROM_size_01MB = $8;                                                       //predefined value for 1Mb of rom.
      ROM_size_512KB= $4;                                                       //predefined value for 512Kb of rom.
      Flash_size_4MB= $0;                                                       //predefined value for 4Mb of Flash.
      Flash_size_2MB= $1;                                                       //predefined value for 2Mb of Flash.
      Flash_size_1MB= $2;                                                       //predefined value for 1Mb of Flash.
      Flash_size_8MB= $3;                                                       //predefined value for 8Mb of Flash.
      numzones      = 15;                                                       //maxium number of memory zones.
      Nomemory      = 0;
      R_able        = 1;
      W_able        = 2;
      RW_able       = 3;
      SaveFileName  = '.\sav\sysregs.sav';
type c2500sysregs=class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
       registers      : array[0..5] of word;
       MemoryMAP      : array [0..2,0..numzones] of longword;
       MemoryMAPItems : byte;
       intc           : ^IntrCtrl;
       maxram         : ^longword;
       interfInt      : ^word;
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
     function  InterfaceRead8  (address:word):     byte;                        //By this function cpu access in reading mode to 8 bit memory mapped registers.
     procedure InterfaceWrite8 (address:word;data:byte);                        //By this function cpu access in Writing mode to 8 bit memory mapped registers.
     function  InterfaceRead16 (address:word):     word;                        //By this function cpu access in reading mode to 16 bit memory mapped registers.
     procedure InterfaceWrite16(address:word;data:word);                        //By this function cpu access in Writing mode to 16 bit memory mapped registers.
     Procedure deepswitch      (data:word);
     procedure setint(addr:pointer);
     procedure update_status;                                                   //Updates status of the device.
     constructor create;
     function  validate(address:longword):byte;                              //Validate an adrres for the Busfault mechanism.
     procedure SetInterruptController(ic:pointer);                              //Assigns an interrupt controller to the device.
     procedure MemoryMapZone(Bp,Ep,mode:longword);
     procedure reset;
     procedure StatusSave;
     procedure StatusRestore;
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
procedure c2500sysregs.MemoryMapZone(Bp,Ep,mode:longword);
begin
MemoryMAP[0,MemoryMAPItems]:=bp;
MemoryMAP[1,MemoryMAPItems]:=ep;
MemoryMAP[2,MemoryMAPItems]:=mode;
inc(MemoryMAPItems);
end;
procedure c2500sysregs.update_status;
begin
if registers[0] and $c =$c then begin
                                registers[0]:=$c200;
                                intc^.irq($02);                                 //hardware exception bus error
                                end;

case registers[1] and $30 of
     $00: maxram^:=16*1024*1024;
     $10: maxram^:= 4*1024*1024;
     $20: maxram^:= 2*1024*1024;
     $30: maxram^:= 8*1024*1024;
     end;
end;
(******************************************************************************)
function c2500sysregs.validate(address:longword):byte;
var i:byte;
begin
result:=0;
for i:=0 to MemoryMAPItems do
    begin
    if (address>=memorymap[0,i]) and (address<memorymap[1,i]) then
       begin
       result:=memorymap[2,i];
       if memorymap[2,i]=0 then begin
                                registers[0]:=registers[0] or $0100;
                                registers[0]:=registers[0] and $01ff;
                                end;
       end;
    end;
end;
(******************************************************************************)
function  c2500sysregs.InterfaceRead8  (address:word):     byte;
begin
if address and 1 = 0 then  result:=registers[address shr 1] and $ff
                     else  result:=(registers[address shr 1] and $ff00) shr 8;

end;
(******************************************************************************)
procedure c2500sysregs.InterfaceWrite8 (address:word;data:byte);
begin
end;
(******************************************************************************)
function  c2500sysregs.InterfaceRead16 (address:word):     word;
begin
result:=registers[address shr 1];
if address=0 then registers[0]:=registers[0]and $00ff;
if address=6 then result:=interfInt^;
end;
(******************************************************************************)
procedure c2500sysregs.InterfaceWrite16(address:word;data:word);
begin
registers[address shr 1]:=data;
registers[1]:=$300+ (registers[1]and $ff);
if address=6 then interfInt^:=data;
update_status;
end;
(******************************************************************************)
Procedure c2500sysregs.deepswitch(data:word);
begin
registers[1]:=data;
end;
(******************************************************************************)
constructor c2500sysregs.create;
var i:byte;
begin
//maxram:=16*1024*1024;
reset;
end;
(******************************************************************************)
procedure c2500sysregs.SetInterruptController(ic:pointer);
begin
intc:=ic;
end;
(******************************************************************************)
procedure c2500sysregs.reset;
begin
registers[0]:=0;registers[1]:=$0300;registers[2]:=0;registers[3]:=0;registers[4]:=0;
registers[5]:=$6f48;
// 0110 1101 0100 1000  >>6D48
// 0000 0110 0000 0000
// 0110 1111 0100 1000  >>6f48
//maxram:=16*1024*1024;
MemoryMAPItems:=0;
MemoryMapZone(0,16*1024*1024,RW_able);
maxram:=@memorymap[1,0];
end;
(******************************************************************************)
procedure c2500sysregs.setint(addr:pointer);
begin
interfInt:=addr;
end;
(******************************************************************************)
procedure c2500sysregs.StatusSave;
var f:file;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,registers[0],13+3*(numzones+1)*4);
closefile(f);
end;
(******************************************************************************)
procedure c2500sysregs.StatusRestore;
var f:file;
begin
assignfile(f,SaveFileName);
system.Reset(f,1);
blockread(f,registers[0],13+3*(numzones+1)*4);
closefile(f);
end;
end.

