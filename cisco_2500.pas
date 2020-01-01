unit Cisco_2500;
(******************************************************************************)
(**)                                                                        (**)
(**)                            interface                                   (**)
(**)                                                                        (**)
(******************************************************************************)

uses sysutils, mc68k,uart, cookie, sysregs, nvram, timer, ictrl, Am79c90;

const  c2501       = $01;                                                       //In create constructor parameters this indicates the Cisco 2501
       c2502       = $02;                                                       //In create constructor parameters this indicates the Cisco 2502
       c2503       = $03;                                                       //In create constructor parameters this indicates the Cisco 2503
       c2504       = $04;                                                       //In create constructor parameters this indicates the Cisco 2504
       c2505       = $05;                                                       //In create constructor parameters this indicates the Cisco 2505
       c2506       = $06;                                                       //In create constructor parameters this indicates the Cisco 2506
       c2507       = $07;                                                       //In create constructor parameters this indicates the Cisco 2507
       c2508       = $08;                                                       //In create constructor parameters this indicates the Cisco 2508
       c2509       = $09;                                                       //In create constructor parameters this indicates the Cisco 2509
       c2510       = $0A;                                                       //In create constructor parameters this indicates the Cisco 2510
       c2511       = $0B;                                                       //In create constructor parameters this indicates the Cisco 2511
       LoadNVR     = $01;                                                       //In create constructor parameters this indicates that you want to load the image of NVRAM
       LoadROM     = $02;                                                       //In create constructor parameters this indicates that you want to load the image of ROM
       LOADIOS     = $04;                                                       //In create constructor parameters this indicates that you want to load the image of IOS
       LOADCOOKIE  = $08;                                                       //In create constructor parameters this indicates that you want to load the image of cookie
       IntCtrlInst = $10;                                                       //In create constructor parameters this indicates that you want to intstall a user defined Interrupt controller
       crypt       = $20;

type C2500Ex = Class(Exception);

type Cisco2500 = Class

(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
     RunThreadHND: longword;
     procedure xbuf(l:longword;var buf);
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
     (* to be moved in the private section!!!!!!!!!!!!!!!! *)
     cpu         : cpu68k;                                                      //By this it's possible to access to MC68ec030 CPU internals.
     console     : uart2681;                                                    //By this it's possible to access to SCN2861 Uart controller.
     cookie      : c2500cookie;                                                 //By this it's possible to access to x24c44 internals.
     sysregs     : c2500sysregs;                                                //By this it's possible to access to C2500 spcific internal registers.
     nvram       : c2500nvram;                                                  //By this it's possible to access to Nvram memory device.
     timer       : c2500timer;                                                  //By this it's possible to access to Timer registers.
     IntCtrl     : IntrCtrl;                                                    //By this it's possible to access to Interrupt controller internals.
     Lance       : C2500Lance;
     Lance2      : C2500Lance;
     debug_speed : longword;                                                    //This controls the CPU speed.
     Breakpoint  : longword;                                                    //By this it's possible to set a cpu breakpoint.

     procedure Run;                                                             //This is the procedure executed by cpu fetch-execute thread.
     procedure execution_thread;                                                //This procedure sets a new main cpu thread.
     constructor intit(type_:byte;nvram_file_name,Rom_file_name,IOS_file_name,COOKIE_file_name:string;Ramsize,flags:byte);  //This create an object Cisco2500.
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)

(******************************************************************************)
(**)                                                                        (**)
(*                                  c2500                                     *)
(**)                                                                        (**)
(******************************************************************************)
procedure Cisco2500.xbuf(l:longword;var buf);assembler;
asm
        push    ebx
        push    esi
        push    edi

        mov     esi,buf
        mov     edi,buf
        mov     ecx,l
        mov     dl,$a7
@loop:  mov     al,[esi]
        xor     al,dl
        add     dl,$77
        mov     [edi],al
        inc     esi
        inc     edi
        loop    @loop

        pop     edi
        pop     esi
        pop     ebx
end;




constructor Cisco2500.intit(type_:byte;nvram_file_name,Rom_file_name,IOS_file_name,COOKIE_file_name:string;Ramsize,flags:byte);
var nvram_file,rom_file,IOS_file,cookie_file:file;
    i:byte;
    p:pointer;
    r:longword;
begin
(* Parameter check*)

if type_<>11 then begin
                  raise C2500Ex.create('Unknown c2500 type.');

                  end;
assignfile(Rom_file  , Rom_file_name);
assignfile(nvram_file, nvram_file_name);
assignfile(IOS_file  , IOS_file_name);
assignfile(cookie_file  , COOKIE_file_name);
{$I-}
if flags and loadROM<>0 then begin
                             reset(Rom_file,1);
                             if IOResult <> 0 then begin
                                                   raise C2500Ex.create('ROM image file not found.');
                                                   exit;
                                                   end;
                             end;
if flags and loadNVR<>0  then begin
                              reset(nvram_file,1);
                              if IOResult <> 0 then begin
                                                    raise C2500Ex.create('NVRAM image file not found.');
                                                    exit;
                                                    end;
                              end;
if flags and loadIOS<>0  then begin
                              reset(IOS_file,1);
                              if IOResult <> 0 then begin
                                                    raise C2500Ex.create('IOS image file not found.');
                                                    exit;
                                                    end;
                              end;
if flags and loadcookie<>0  then begin
                                 reset(cookie_file,1);
                                 if IOResult <> 0 then begin
                                                       raise C2500Ex.create('cookie file not found.');
                                                       exit;
                                                       end;
                              end;
{$I+}
case ramsize of
     4:begin end;
     8:begin end;
     16:begin end;
     else C2500Ex.create('Iproper Ramsize.');
     end;

cpu:=cpu68k.create;
console:=uart2681.uart2681;
cookie:=c2500cookie.Create;
sysregs:=c2500sysRegs.create;
nvram:=c2500nvram.create;
timer:=c2500timer.create;
intCtrl:=intrctrl.create;
lance:=C2500Lance.create(cpu.MemoryRead8,cpu.MemoryRead16,cpu.MemoryWrite8,cpu.MemoryWrite16);
lance2:=C2500Lance.create(cpu.MemoryRead8,cpu.MemoryRead16,cpu.MemoryWrite8,cpu.MemoryWrite16);
for i:= 0 to ramsize do begin
                        getmem(p,$100000);
                        cpu.addMemorypage(i,p);
                        end;
if flags and loadROM<>0 then begin
                             i:=$10;
                             repeat
                             getmem(p,$100000);
                             cpu.addMemorypage(i,p); (* Warning *)
                             if filesize(Rom_file)-$100000*(i-$10)<=$100000 then r:=filesize(Rom_file)-$100000*(i-$10)
                                                                  else r:=$100000;
                             blockread(Rom_file,p^,r);                                                            //load program binary image into memory
                             if flags and crypt =0 then xbuf(r,p^);
                             inc(i);
                             until r<>$100000;
                             closefile(Rom_file);
                             end;

if flags and loadIOS<>0 then begin
                             i:=$30;
                             repeat
                             getmem(p,$100000);
                             cpu.addMemorypage(i,p); (* Warning *)
                             if filesize(ios_file)-$100000*(i-$30)<=$100000 then r:=filesize(ios_file)-$100000*(i-$30)
                                                                  else r:=$100000;
                             blockread(ios_file,p^,r);                                                            //load program binary image into memory
                             inc(i);
                             until r<>$100000;
                             closefile(IOS_file);
                             end;
if flags and loadcookie<>0 then begin
                                 cookie.setcookie(cookie_file);
                                 closefile(cookie_file);
                                 end;
cpu.buildTables;                                                                //68k istr vec init.
intctrl.AddResets(cookie.reset);
intctrl.AddResets(timer.reset);
intctrl.AddResets(sysregs.reset);
intctrl.AddResets(nvram.reset);
intctrl.AddResets(console.reset);
cpu.setresetio(intctrl.reset);



if flags and IntCtrlInst<>0 then begin
                                 cpu.InstallIntCtrl(@IntCtrl.PendingIntr,@IntCtrl.pendingIntNo);
                                 end;

nvram.Load_NVRAMImage(nvram_file);
closefile(nvram_file);
nvram.unlockNVRAM;


cpu.addDevice8 ($2120100,$000F,console.InterfaceRead8, console.interfaceWrite8);           //add uart device in address space.
cpu.addDevice8 ($2110040,$0021,cookie.InterfaceRead8,  cookie.interfaceWrite8);
cpu.addDevice8 ($2000000,$7FFF,nvram.InterfaceRead8,   nvram.interfaceWrite8);
cpu.addDevice16($2000000,$7FFF,nvram.InterfaceRead16,  nvram.interfaceWrite16);
cpu.addDevice8 ($2110000,$000C,sysregs.InterfaceRead8, sysregs.interfaceWrite8);
cpu.addDevice16($2110000,$000C,sysregs.InterfaceRead16,sysregs.interfaceWrite16);
cpu.addDevice8 ($2120040,$0040,timer.InterfaceRead8,   timer.interfaceWrite8);
cpu.addDevice16($2120040,$0040,timer.InterfaceRead16,  timer.interfaceWrite16);
cpu.addDevice16($2130000,$0006,lance.InterfaceRead16,  lance.interfaceWrite16);
cpu.addDevice16($2130040,$0006,lance2.InterfaceRead16,  lance2.interfaceWrite16);


timer.SetCPUCyclescCounter(@cpu.CPUCycles);
timer.SetInterruptController(@IntCtrl);
sysregs.SetInterruptController(@IntCtrl);
console.SetInterruptController(@IntCtrl);
lance.SetInterruptController(@IntCtrl);
lance2.SetInterruptController(@IntCtrl);
sysregs.setint(@intctrl.interfaces_int);
cpu.validateFun:=sysregs.validate;
sysregs.MemoryMapZone($01000000,$01FFFFFF,1);
sysregs.MemoryMapZone($02000000,$02008000,3);

sysregs.MemoryMapZone($02010000,$023FFFFF,3);
//sysregs.MemoryMapZone($02400000,$02FFFFFF,0);
sysregs.MemoryMapZone($03000000,$03FFFFFF,3);
sysregs.MemoryMapZone($04000000,$04FFFFFF,3);
sysregs.MemoryMapZone($05000000,$FFFFFFFF,1);
cpu.regs.a[7] := cpu.memoryread32($1000000);
cpu.regs.pc   := cpu.memoryread32($1000004);
//cpu.regs.isp  := $800;
cpu.regs.sr:=$2700;//cpu.regs.sr or $f000;
Breakpoint:=$ffffff;
debug_Speed:=$ffffff;
cpu.warproundwrite:=(1024*1024*ramsize)-1 ;
end;
(******************************************************************************)
procedure Cisco2500.execution_thread;
var b:longword;
begin
b:=0;
while true do begin
              if b and debug_speed =0 then begin
                                           if cpu.regs.pc=breakpoint then cpu.regs.sr:=cpu.regs.sr or $c000;
                                           if cpu.regs.sr and $C000=0 then  begin
                                                                            cpu.fetch;
                                                                            cpu.execute;
                                                                            end;
                                           end;
              inc(b);
              if cpu.regs.sr and $c000 =$c000 then sleep(10);
              end;
end;
(******************************************************************************)
procedure Cisco2500.run;
var thread: longword;
begin
//thread := BeginThread(nil, 0, @self.execution_thread, nil, 0, RunThreadHND);
end;
(******************************************************************************)
end.                         
