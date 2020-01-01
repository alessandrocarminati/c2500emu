(******************************************************************************)
(* This file conteins definitions, data sructures and the implementations of  *)
(* a two channels 2681 serial device.                                         *)
(* Designed to be interfaced with MC68k Class.                                *)
(*                                                                            *)
(******************************************************************************)
unit Uart;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
uses fifo4bits,ictrl;
const RxRDY = $01;
      FFULL = $02;
      TxRDY = $04;
      TxEMT = $08;
      nRxRDY= $FE;
      nFFULL= $FD;
      nTxRDY= $FB;
      nTxEMT= $F7;
      rdyC  = $400;
      SaveFileName='.\sav\scn2681.sav';

type ReadFun   = function:byte of object;
     WriteFun  = procedure (data:byte) of object;
     channel=record                                                             //Defines the structure of a 2681's channel.
             MRP:byte;                                                          //indicates which MR is accessed reading from addr 0x0
             MR1:byte;                                                          //[(1)RxRTS control|(1)RxINT select|(1)Error mode|(2)Parity mode|(1)parity type|(2)Bits per Character]
             MR2:byte;                                                          //[(2)Channel mode|(1)TxRTS control|(1)CTS Enavle Tx|(4)bitstop length]
             SR:byte;                                                           //Status Register
             RHR:byte;                                                          //Rx Holding Register
             THR:byte;                                                          //Tx Holding Register
             CSR:byte;                                                          //Clock Set Register
             CR:byte;                                                           //Command Register
             TxEnable,RxEnable:boolean;
             Data_available:boolean;
             NoUseButItsAddress:byte;
             RxFIFO:fifo;                                                       //Ingoing buffer.
             end;

type uart2681=class                                                             //2681 serial device class definition.
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
              A,B          : channel;                                           //Channel A, B
              ACR          : byte;                                              //Aux Control Register
              IMR          : byte;                                              //Interrupt Mask Register
              IPCR         : byte;                                              //Input Port Change Register
              ISR          : byte;                                              //Interrupt Status Register
              CT           : word;                                              //Counter Timer Lower value
              counter:word;
              BRG          : byte;                                              //
              OPCR         : byte;                                              //Output Port Configuration Register
              CounterStart : boolean;                                           //Status register.
              LastCH       : byte;
              NoUseButItsAddress:byte;
              ToBecomeReadyTx: longword;
              ToBecomeReadyRx: longword;
              intc         : ^IntrCtrl;
              ReadHandlingRoutines  : array[0..$f] of ReadFun;
              WriteHandlingRoutines : array[0..$f] of WriteFun;
   function  ModeRegisterxARead:byte;
   function  StatusRegisterARead:byte;
   function  BRGRead:byte;
   function  RxHoldingARegister:byte;
   function  InputPortChangeRegister:byte;
   function  InterruptStatusRegister:byte;
   function  CounterTimerUpperValue:byte;
   function  CounterTimerLowerValue:byte;
   function  ModeRegisterxBRead:byte;
   function  StatusRegisterBRead:byte;
   function  RxHoldingBRegister:byte;
   function  reservedRead:byte;
   function  startcounter:byte;
   function  Stopcounter:byte;

   procedure reservedWrite(data:byte);
   procedure ModeRegisterxAWrite(data:byte);
   procedure ClockSelectRegisterA(data:byte);
   procedure CommandRegisterA(data:byte);
   procedure TxHoldingARegister(data:byte);
   procedure AuxControlRegister(data:byte);
   procedure InterruptMaskRegister(data:byte);
   procedure CounterTimerUpperValueSet(data:byte);
   procedure CounterTimerLowerValueSet(data:byte);
   procedure ModeRegisterxBWrite(data:byte);
   procedure ClockSelectRegisterB(data:byte);
   procedure CommandRegisterB(data:byte);
   procedure TxHoldingBRegister(data:byte);
   procedure OutputPortConfigurationRegister(data:byte);
   procedure SetOutputPortBitsCommand(data:byte);
   procedure ResetOutputPortBitsCommand(data:byte);

(***********************************************************)
(**)                     protected                       (**)
(***********************************************************)
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
   imr_copy :byte;
   timedivisor:longword;
   procedure reset                       ;                                              //Resets the status of the selected channel.
   procedure interfaceWrite8  (address:word;data:byte)        ;                       //Interface to CPU Routine. Simulates a CPU reading from selected Address.
   procedure SendBreakConsole;
   procedure SendBreakAux;
   function  InterfaceRead8   (address:word):     byte;                          //Interface to CPU Routine. Simulates a CPU writing from selected Address.
   function  UserReadConsole  (var data:byte):    boolean;                       //Interface to others Routine. Simulates a user reading from A channel fifo (console).
   function  UserWriteConsole (data:byte):        boolean;                       //Interface to others Routine. Simulates a user writing from A channel fifo (console).
   function  UserReadAux      (var data:byte):    boolean;                       //Interface to others Routine. Simulates a user reading from B channel fifo (aux aux).
   function  UserWriteAux     (data:byte):        boolean;                       //Interface to others Routine. Simulates a user writing from B channel fifo (aux port).
   procedure tick;
   procedure intrq;
   procedure switchTxRDY;
   constructor uart2681;                                                        //Default Constructor for this class.
   procedure StatusSave;
   procedure StatusRestore;
   procedure SetInterruptController(ic:pointer);
   function sra:byte;
  end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
(******************************************************************************)
function  uart2681.sra:byte;
begin
result:=a.SR;
end;
(******************************************************************************)
procedure uart2681.reset;
begin
a.MRP:=0; a.MR1:=0; a.MR2:=0; a.SR:=0; a.RHR:=0; a.THR:=0; a.CSR:=0; a.CR:=0;
a.RxFIFO.clear;
b.MRP:=0; b.MR1:=0; b.MR2:=0; b.SR:=0; b.RHR:=0; b.THR:=0; b.CSR:=0; b.CR:=0;
b.RxFIFO.clear;
ReadHandlingRoutines[$0] := self.ModeRegisterxARead;
ReadHandlingRoutines[$1] := self.StatusRegisterARead;
ReadHandlingRoutines[$2] := self.reservedread;
ReadHandlingRoutines[$3] := self.RxHoldingARegister;
ReadHandlingRoutines[$4] := self.InputPortChangeRegister;
ReadHandlingRoutines[$5] := self.InterruptStatusRegister;
ReadHandlingRoutines[$6] := self.CounterTimerUpperValue;
ReadHandlingRoutines[$7] := self.CounterTimerLowerValue;
ReadHandlingRoutines[$8] := self.ModeRegisterxBRead;
ReadHandlingRoutines[$9] := self.StatusRegisterBRead;
ReadHandlingRoutines[$A] := self.reservedread;
ReadHandlingRoutines[$B] := self.RxHoldingBRegister;
ReadHandlingRoutines[$C] := self.reservedread;
ReadHandlingRoutines[$D] := self.reservedread;
ReadHandlingRoutines[$E] := self.startcounter;
ReadHandlingRoutines[$F] := self.stopcounter;

WriteHandlingRoutines[$0]:= self.ModeRegisterxAWrite;
WriteHandlingRoutines[$1]:= self.ClockSelectRegisterA;
WriteHandlingRoutines[$2]:= self.CommandRegisterA;
WriteHandlingRoutines[$3]:= self.TxHoldingARegister;
WriteHandlingRoutines[$4]:= self.AuxControlRegister;
WriteHandlingRoutines[$5]:= self.InterruptMaskRegister;
WriteHandlingRoutines[$6]:= self.CounterTimerUpperValueSet;
WriteHandlingRoutines[$7]:= self.CounterTimerLowerValueSet;
WriteHandlingRoutines[$8]:= self.ModeRegisterxBWrite;
WriteHandlingRoutines[$9]:= self.ClockSelectRegisterB;
WriteHandlingRoutines[$A]:= self.CommandRegisterB;
WriteHandlingRoutines[$B]:= self.TxHoldingBRegister;
WriteHandlingRoutines[$C]:= self.reservedWrite;
WriteHandlingRoutines[$D]:= self.OutputPortConfigurationRegister;
WriteHandlingRoutines[$E]:= self.SetOutputPortBitsCommand;
WriteHandlingRoutines[$F]:= self.ResetOutputPortBitsCommand;
end;
(******************************************************************************)
procedure uart2681.interfaceWrite8(address:word;data:byte);
begin
WriteHandlingRoutines[address](data);
end;
(******************************************************************************)
function  uart2681.InterfaceRead8(address:word):byte;
begin
result:=ReadHandlingRoutines[address];
end;
(******************************************************************************)
function uart2681.UserwriteConsole(data:byte):boolean;
begin
if not a.RxFIFO.full then begin
                          a.RxFIFO.put(data);a.SR:=a.SR and nFFULL;
                          if a.RxFIFO.full then a.SR:=a.SR or   FFULL;
                                           //else a.SR:=a.SR and nFFULL;
                          result:=true;
                          end
                     else begin
                          if a.MR1 and $40<>0 then isr:=isr or  2;
                          result:=false;
                          end;
if a.MR1 and $40=0 then isr:=isr or  2;
a.SR:=a.SR or RxRDY;
end;
(******************************************************************************)
function  uart2681.UserreadConsole(var data:byte):boolean;
begin
result:=a.Data_available;
data:=a.THR;
a.SR:= a.SR or TxRDY;
a.sr:= a.sr or TXEMT;
a.Data_available:=false;
end;
(******************************************************************************)
procedure uart2681.intrq;
begin
end;
(******************************************************************************)
function uart2681.UserwriteAux(data:byte):boolean;
begin
end;
(******************************************************************************)
function  uart2681.UserreadAux(var data:byte):boolean;
begin
b.SR:= b.SR or 4;
end;
(******************************************************************************)
constructor uart2681.uart2681;
begin
a.RxFIFO:=fifo.Create;
b.RxFIFO:=fifo.Create;
reset;
end;
(******************************************************************************)
procedure uart2681.SendBreakConsole;
begin
end;
(******************************************************************************)
procedure uart2681.SendBreakAux;
begin
end;
(******************************************************************************)
procedure uart2681.SetInterruptController(ic:pointer);
begin
intc:=ic;
end;
(******************************************************************************)
procedure uart2681.StatusSave;
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
blockwrite(f,a.MRP,addrcalc(@a.NoUseButItsAddress,@a.mrp));  //channel A
blockwrite(f,b.MRP,addrcalc(@b.NoUseButItsAddress,@b.mrp));  //channel B
blockwrite(f,acr,addrcalc(@NoUseButItsAddress,@ACR));  //others
closefile(f);
end;
(******************************************************************************)
procedure uart2681.StatusRestore;
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
blockread (f,a.MRP,addrcalc(@a.NoUseButItsAddress,@a.mrp));       //11);  //channel A
blockread (f,b.MRP,addrcalc(@b.NoUseButItsAddress,@b.mrp));//11);  //channel B
blockread (f,acr,addrcalc(@NoUseButItsAddress,@ACR));   //12);  //others
closefile(f);
end;
(******************************************************************************)
procedure uart2681.tick;
begin
if tobecomereadytx>0 then begin
                        dec(tobecomereadytx);
                        if tobecomereadytx=0 then a.SR:=a.SR and nTxRDY;
                        end;
if tobecomereadyRx>0 then begin
                        dec(tobecomereadyrx);
                        if tobecomereadyrx=0 then a.sr:=a.sr or   RxRDY;
                        end;
timedivisor:=(timedivisor +1) and $ff;
if timedivisor=0 then begin
                      //a.SR:= a.SR or TxRDY;
                      //a.sr:= a.sr or TXEMT;
                      if counterstart then begin
                                           dec(counter);
                                           if counter=0 then begin
                                                             counter:=ct;
                                                             isr:=isr or $8;
                                                             end;
                      end;

                      end;

if isr and imr <>0 then
                         intc^.irq($1d);
isr:=0;
imr_copy:=imr;
end;
(******************************************************************************)
procedure uart2681.switchTxRDY;
begin
  {  a.SR:=a.SR or RxRDY;
    isr:=1;              }
end;
(******************************************************************************)
function  uart2681.ModeRegisterxARead;
begin
if a.MRP=0 then begin
                result:=a.MR1;
                a.MRP:=1;
                end
           else result:=a.MR2;
end;
(******************************************************************************)
function  uart2681.StatusRegisterARead;
begin
result:=a.SR;
end;
(******************************************************************************)
function  uart2681.BRGRead;
begin
result:=$ff;
end;
(******************************************************************************)
function  uart2681.RxHoldingARegister;
begin
a.SR:=a.SR and nFFULL; // dopo una lettura sicuramente la fifo non è + piena.
a.sr:=a.sr or   RxRDY; // lo metto a 1 in previsione che ci siano altri caratteri in attesa.
a.RHR:=a.RxFIFO.get;   //leggo il carattere dalla fifo
if a.RxFIFO.empty then a.SR:=a.SR and nRxRDY; //se dopo la lettura la fifo risultasse vuota metto il ricevitore in NON pronto
result:=a.RHR;  //returns read caracter
end;
(******************************************************************************)
function  uart2681.InputPortChangeRegister;
begin
result:=IPCR;
ipcr:=ipcr and $0f;                                                     //When reading occurs IL clears IPCR[7:4]
isr:=isr and $7f;                                                       //and ISR[7]
end;
(******************************************************************************)
function  uart2681.InterruptStatusRegister;
begin
result:=ISR;
end;
(******************************************************************************)
function  uart2681.CounterTimerUpperValue;
begin
result:=hi(ct);
end;
(******************************************************************************)
function  uart2681.CounterTimerLowerValue;
begin
result:=lo(ct);
end;
(******************************************************************************)
function  uart2681.ModeRegisterxBRead;
begin
if b.MRP=0 then begin
                result:=b.MR1;
                b.MRP:=1;
                end
           else result:=b.MR2;
end;
(******************************************************************************)
function  uart2681.StatusRegisterBRead;
begin
result:=b.SR;
end;
(******************************************************************************)
function  uart2681.RxHoldingBRegister;
begin
b.SR:=b.SR and nFFULL; // dopo una lettura sicuramente la fifo non è + piena.
b.sr:=b.sr or   RxRDY; // lo metto a 1 in previsione che ci siano altri caratteri in attesa.
b.RHR:=b.RxFIFO.get;   //leggo il carattere dalla fifo
if b.RxFIFO.empty then b.SR:=b.SR and nRxRDY; //se dopo la lettura la fifo risultasse vuota metto il ricevitore in NON pronto
result:=b.RHR;  //returns read caracter
end;
(******************************************************************************)
function  uart2681.reservedRead;
begin
result:=$ff;
end;
(******************************************************************************)
function  uart2681.startcounter;
begin
result:=$ff;
counterStart:=true;
counter:=ct;
end;
(******************************************************************************)
function  uart2681.Stopcounter;
begin
result:=$ff;
counterStart:=false;
end;
(******************************************************************************)
procedure uart2681.ModeRegisterxAWrite(data:byte);
begin
if a.MRP=0 then begin
                a.MR1:=data;
                a.MRP:=1;
                end
           else a.MR2:=data;
end;
(******************************************************************************)
procedure uart2681.reservedWrite(data:byte);
begin
end;
(******************************************************************************)
procedure uart2681.ClockSelectRegisterA(data:byte);
begin
a.CSR:=data;
end;
(******************************************************************************)
procedure uart2681.CommandRegisterA(data:byte);
begin
if data and 1<>0 then Begin //enable  Rx
                      a.RxEnable:=true;
                      end;
if data and 2<>0 then Begin //disable Rx
                      a.RxEnable:=false;
                      end;
if data and 4<>0 then Begin //enable  Tx
                      a.TxEnable:=true;
                      end;
if data and 8<>0 then Begin //disable Tx
                      a.TxEnable:=false;
                      end;
case data and $70 of
     $10:begin
         a.MRP:=0;
         end;
     $20:begin
         a.RxFIFO.clear;
         end;
     $30:begin

         end;
     $40:begin
         a.SR:=a.SR and $0f;
         end;
     $50:begin
         isr:=isr and $fb;
         end;
     $60:begin  // elettrical status command Force TxD(A/B) pin low. Not emulated
         end;
     $70:begin // elettrical status command Force TxD(A/B) pin high. Not emulated
         end;
     end;
end;
(******************************************************************************)
procedure uart2681.TxHoldingARegister(data:byte);
begin
if a.TxEnable then begin
                   a.THR:=data;
                   a.sr:=a.sr and nTxEMT;
                   a.SR:=a.SR and nTxRDY;
                   a.Data_available:=true;
                   end;
end;
(******************************************************************************)
procedure uart2681.AuxControlRegister(data:byte);
begin
acr:=data;
end;
(******************************************************************************)
procedure uart2681.InterruptMaskRegister(data:byte);
begin
imr:=data;
end;
(******************************************************************************)
procedure uart2681.CounterTimerUpperValueSet(data:byte);
type x=array[0..1]of byte;
var a:^x;
begin
a:=@ct;
a^[1]:=data;
end;
(******************************************************************************)
procedure uart2681.CounterTimerLowerValueSet(data:byte);
var a:^byte;
begin
a:=@ct;
a^:=data;
end;
(******************************************************************************)
procedure uart2681.ModeRegisterxBWrite(data:byte);
begin
if b.MRP=0 then begin
                b.MR1:=data;
                b.MRP:=1;
                end
           else b.MR2:=data;
end;
(******************************************************************************)
procedure uart2681.ClockSelectRegisterB(data:byte);
begin
b.CSR:=data;
end;
(******************************************************************************)
procedure uart2681.CommandRegisterB(data:byte);
begin
if data and 1<>0 then Begin //enable  Rx
                      b.RxEnable:=true;
                      end;
if data and 2<>0 then Begin //disable Rx
                      b.RxEnable:=false;
                      end;
if data and 4<>0 then Begin //enable  Tx
                      b.TxEnable:=true;
                      end;
if data and 8<>0 then Begin //disable Tx
                      b.TxEnable:=false;
                      end;
case data and $70 of
     $10:begin
         b.MRP:=0;
         end;
     $20:begin
         b.RxFIFO.clear;
         end;
     $30:begin

         end;
     $40:begin
         b.SR:=b.SR and $0f;
         end;
     $50:begin
         isr:=isr and $fb;
         end;
     $60:begin  // elettrical status command Force TxD(A/B) pin low. Not emulated
         end;
     $70:begin // elettrical status command Force TxD(A/B) pin high. Not emulated
         end;
     end;
end;
(******************************************************************************)
procedure uart2681.TxHoldingBRegister(data:byte);
begin
if b.TxEnable then begin
                   b.THR:=data;
                   b.sr:=b.sr and nTxEMT;
                   b.SR:=b.SR and nTxRDY;
                   b.Data_available:=true;
                   end;
end;
(******************************************************************************)
procedure uart2681.OutputPortConfigurationRegister(data:byte);
begin
end;
(******************************************************************************)
procedure uart2681.SetOutputPortBitsCommand(data:byte);
begin
end;
(******************************************************************************)
procedure uart2681.ResetOutputPortBitsCommand(data:byte);
begin
end;
end.
