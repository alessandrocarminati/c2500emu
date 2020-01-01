Unit Am79c90;

(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
uses ictrl, SysUtils;
const csr0eq=0;
      csr1eq=1;
      csr2eq=2;
      csr3eq=3;
      SaveFileName='.\sav\lance.sav';
type CMR8 = function  (address:longword):byte      of object;                   //cpu memory acces 4 DMA ctrl
     CMR16= function  (address:longword):word      of object;                   //cpu memory acces 4 DMA ctrl
     CMW8 = procedure (address:longword;data:byte) of object;                   //cpu memory acces 4 DMA ctrl
     CMW16= procedure (address:longword;data:word) of object;                   //cpu memory acces 4 DMA ctrl
type C2500Lance=class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
     CpuMemoryRead8:  CMR8;                                                     //cpu memory acces 4 DMA ctrl
     CpuMemoryWrite8: CMW8;                                                     //cpu memory acces 4 DMA ctrl
     CpuMemoryRead16: CMR16;                                                    //cpu memory acces 4 DMA ctrl
     CpuMemoryWrite16:CMW16;                                                    //cpu memory acces 4 DMA ctrl
     csr0,csr1,csr2,csr3:word;
     readPosition:longword;
     rap:byte;
     (*fake*)
    {$IFDEF debug}
     f:text;
    {$ENDIF}
     intc         : ^IntrCtrl;
{
                                   0 1 0 0 1 0 1 0
                  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
                  |F|E|D|C|B|A|9|8|7|6|5|4|3|2|1|0|
                  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
             ERR  -+ | | | | | | | | | | | | | | +- INIT
             BABL ---+ | | | | | | | | | | | | +--- STRT
             CERR -----+ | | | | | | | | | | +----- STOP
             MISS -------+ | | | | | | | | +------- TDMD
             MERR ---------+ | | | | | | +--------- TXON
             RINT -----------+ | | | | +----------- RXON
             TINT -------------+ | | +------------- INEA
             IDON ---------------+ + -------------- INTR
}
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
     initCount:word;
     function  InterfaceRead8  (address:word):     byte;                        //By this function cpu access in reading mode to 8 bit memory mapped registers.
     procedure InterfaceWrite8 (address:word;data:byte);                        //By this function cpu access in Writing mode to 8 bit memory mapped registers.
     function  InterfaceRead16 (address:word):     word;                        //By this function cpu access in reading mode to 16 bit memory mapped registers.
     procedure InterfaceWrite16(address:word;data:word);                        //By this function cpu access in Writing mode to 16 bit memory mapped registers.
     constructor create(R8:CMR8;R16:CMR16;W8:CMW8;W16:CMW16);
     destructor destroy;
     procedure SetInterruptController(ic:pointer);                              //Assigns an interrupt controller to the device.
     procedure SingleStetp;
     procedure reset;
     procedure StatusSave;
     procedure StatusRestore;
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
function  C2500Lance.InterfaceRead8  (address:word):     byte;
begin
end;
(******************************************************************************)
procedure C2500Lance.InterfaceWrite8 (address:word;data:byte);
begin
end;
(******************************************************************************)
function  C2500Lance.InterfaceRead16 (address:word):     word;
begin
{$IFDEF debug}
writeln(f,inttohex(address,8)+' -> ');
{$ENDIF}
if address = 2 then result:=rap;
if address = 0 then begin
                    case rap of
                    csr0eq:begin
                           result:=csr0;
                           //csr0:=csr0 and $FFFE;
                           end;
                    csr1eq:result:=csr1;
                    csr2eq:result:=csr2;
                    csr3eq:result:=csr3;
                    end;
                    end;
end;
(******************************************************************************)
procedure C2500Lance.InterfaceWrite16(address:word;data:word);
begin
{$IFDEF debug}
writeln(f,inttohex(address,8)+' <- ',inttohex(data,4));
{$ENDIF}
if address = 2 then rap:=data;
if address = 0 then begin
                    case rap of
                    csr0eq: begin
                            csr0:=csr0 or data;
                            if data and 1 =1 then begin
                                                  csr0:=csr0 or $100;
                                                  initcount:=50;
                                                  end;

                            end;
                    csr1eq:csr1:=data;
                    csr2eq:csr2:=data;
                    csr3eq:csr3:=data;
                    end;
                    end;
end;
(******************************************************************************)
procedure C2500Lance.SingleStetp;
begin
if csr0 and 4 <>0 then csr0:=csr0 and $fffa;
if csr0 and 8 <>0 then csr0:=(csr0 or $0030) and $fff7;
if initcount <>0 then begin
                       dec(initCount);
                       if initcount=0 then begin
                                           //intc^.interfaces_int:=intc^.interfaces_int or $06;
                                           //intc^.irq($1c);
                                           csr0:=csr0 and $feff;
                                           end;
                       end;
end;
(******************************************************************************)
constructor C2500Lance.create(R8:CMR8;R16:CMR16;W8:CMW8;W16:CMW16);
begin
{$IFDEF debug}
assignfile(f,'lancelog.txt');
rewrite(f);
{$ENDIF}
CpuMemoryRead8:=  r8;
CpuMemoryRead16:= r16;
CpuMemoryWrite8:= w8;
CpuMemoryWrite16:=w16;
end;
(******************************************************************************)
destructor C2500Lance.destroy;
begin
{$IFDEF debug}
closefile(f);
{$ENDIF}
end;
(******************************************************************************)
procedure C2500Lance.SetInterruptController(ic:pointer);
begin
intc:=ic;
end;
(******************************************************************************)
procedure C2500Lance.reset;
begin
end;
(******************************************************************************)
procedure C2500Lance.StatusSave;
var f:file;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,csr0,13);
closefile(f);
end;
(******************************************************************************)
procedure C2500Lance.StatusRestore;
var f:file;
begin
assignfile(f,SaveFileName);
System.reset(f,1);
blockread(f,csr0,13);
closefile(f);
end;
end.
