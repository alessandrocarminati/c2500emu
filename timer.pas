(******************************************************************************)
(* This file conteins definitions, data sructures and the implementations of   *)
(* a two channels 2681 serial device.                                         *)
(* Designed to be interfaced with MC68k Class.                                *)
(*                                                                            *)
(******************************************************************************)
unit timer;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
uses ictrl,sysutils;
const SaveFileName='.\sav\timer.sav';
type ETimerEx=class(exception);
type c2500timer=class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
       TimerControl   : byte; //0x02120040
       TimerRegister0 : word; //0x02120050
       TimerRegister1 : word; //0x02120060
       TimerRegister2 : word; //0x02120070
       TimerCount0    : word; //0x02120050
       TimerCount1    : word; //0x02120060
       TimerCount2    : word; //0x02120070
       fakeCpuCycles  : int64;
       precCpuCycles  : int64;
       NoUseButItsAddress:byte;
       intc           : ^IntrCtrl;
       Cpucycles      : ^int64;
//       function lbendian(a:word):word;
(***********************************************************)
(**)                     protected                       (**)
(***********************************************************)
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
     function  InterfaceRead8   (address:word):     byte;                       //By this function cpu access in reading mode to 8 bit memory mapped registers.
     procedure InterfaceWrite8  (address:word;data:byte);                       //By this function cpu access in writing mode to 8 bit memory mapped registers.
     function  InterfaceRead16  (address:word):     word;                       //By this function cpu access in reading mode to 16 bit memory mapped registers.
     procedure InterfaceWrite16 (address:word;data:word);                       //By this function cpu access in writing mode to 16 bit memory mapped registers.
     procedure SetCPUCyclescCounter(CPUCycl:pointer);                           //Links timer counters to cpu cyles couter.
     procedure SetInterruptController(ic:pointer);                              //Assigns an interrupt controller to the device.
     procedure StatusSave;
     procedure StatusRestore;
     procedure reset;
     procedure tick;                                                            //Updates status of the device.
     constructor create;
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
procedure c2500timer.InterfaceWrite8 (address:word;data:byte);
begin
case address of
     $00:begin    //Timer Control
         timercontrol:=data;
         end;
     $10:begin    //Timer Register 0
         end;
     $20:begin    //Timer Register 1
         end;
     $30:begin    //Timer Register 2
         end;
   end;
end;
(******************************************************************************)
function  c2500timer.InterfaceRead8  (address:word):     byte;
begin
case address of
     $00:begin    //Timer Control
         result:=timercontrol;
         end;
     $10:begin    //Timer Register 0
         end;
     $20:begin    //Timer Register 1
         end;
     $30:begin    //Timer Register 2
         end;
   end;
end;
(******************************************************************************)
procedure c2500timer.InterfaceWrite16 (address:word;data:word);
begin
case address of
     $00:begin    //Timer Control
         end;
     $10:begin    //Timer Register 0
         TimerRegister0:=data;
         timercount0:=0;
         end;
     $20:begin    //Timer Register 1
         TimerRegister1:=data;
         timercount1:=0;
         end;
     $30:begin    //Timer Register 2
         TimerRegister2:=data;
         timercount2:=0;
         end;
   end;
end;
(******************************************************************************)
function  c2500timer.InterfaceRead16 (address:word):word;
begin
case address of
     $00:begin    //Timer Control
         end;
     $10:begin    //Timer Register 0
         result:=timercount0;
         end;
     $20:begin    //Timer Register 1
         result:=timercount1;
         end;
     $30:begin    //Timer Register 2
         result:=timercount2;
         end;
   end;
end;
(******************************************************************************)
constructor c2500timer.create;
begin
cpucycles:=@fakecpucycles;
end;
(******************************************************************************)
procedure c2500timer.SetCPUCyclescCounter(CPUCycl:pointer);
begin
cpucycles:=CPUCycl;
end;
(******************************************************************************)
procedure c2500timer.SetInterruptController(ic:pointer);
begin
intc:=ic;
end;
(******************************************************************************)
procedure c2500timer.tick;
var app:int64;
begin
app:=Cpucycles^-preccpucycles;
if timerregister0<>0 then
                          TimerCount0:=TimerCount0+app;
if timerregister1<>0 then
                          TimerCount1:=TimerCount1+app;
if timerregister2<>0 then
                          TimerCount2:=TimerCount2+app;
preccpucycles:=Cpucycles^;
if TimerCount0>timerregister0 then begin
                                   TimerCount0:=0;
                                   timerregister0:=0;
                                   if timercontrol and $40<>0 then raise ETimerEx.Create('Watchdog is barking: Bau bau.');
                                   end;
if TimerCount1>timerregister1 then begin
                                   if timerregister1<>1 then intc^.irq($1f);    //autovectored 7
                                   TimerCount1:=0;
                                   timerregister1:=0;
                                   end;
if TimerCount2>timerregister2 then begin
                                   if timerregister2<>1 then begin
                                                             //timerregister2:=0;
                                                             intc^.irq($1f);    //autovectored 7
                                                             end
                                                        else asm
                                                             nop
                                                             end;
                                   TimerCount2:=0;
                                   end;
end;
(******************************************************************************)
procedure c2500timer.reset;
begin
TimerControl   := 0;
TimerRegister0 := 0;
TimerRegister1 := 0;
TimerRegister2 := 0;
TimerCount0    := 0;
TimerCount1    := 0;
TimerCount2    := 0;
end;
(******************************************************************************)
procedure c2500timer.StatusSave;
var f:file;
function addrcalc(addr1,addr2:pointer):longword;   assembler;
asm
        push    ebx
        mov     eax,addr1
        mov     ebx,addr2
        sub     eax,ebx
        pop     ebx
end;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,TimerControl,addrcalc(@NoUseButItsAddress,@TimerControl));//29);
closefile(f);
end;
(******************************************************************************)
procedure c2500timer.StatusRestore;
var f:file;
function addrcalc(addr1,addr2:pointer):longword;   assembler;
asm
        push    ebx
        mov     eax,addr1
        mov     ebx,addr2
        sub     eax,ebx
        pop     ebx
end;
begin
assignfile(f,SaveFileName);
system.Reset(f,1);
blockread(f,TimerControl,addrcalc(@NoUseButItsAddress,@TimerControl));//29);
closefile(f);
end;
end.
