unit Unit1;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, cisco_2500, ScktComp ;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    Memo1: TMemo;
    Button3: TButton;
    Button4: TButton;
    ListBox1: TListBox;
    Memo2: TMemo;
    Memo3: TMemo;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo4: TMemo;
    Label5: TLabel;
    Timer2: TTimer;
    Button6: TButton;
    Label6: TLabel;
    Label7: TLabel;
    Button7: TButton;
    Button8: TButton;
    Edit3: TEdit;
    Button5: TButton;
    Edit4: TEdit;
    Button9: TButton;
    Button10: TButton;
    Edit5: TEdit;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Label8: TLabel;
    Label9: TLabel;
    Memo5: TMemo;
    Memo6: TMemo;
    Label10: TLabel;
    Label11: TLabel;
    Timer3: TTimer;
    Label12: TLabel;
    Edit6: TEdit;
    Label13: TLabel;
    Button11: TButton;
    Button20: TButton;
    Label14: TLabel;
    Label15: TLabel;
    Button21: TButton;
    Button22: TButton;
    Edit7: TEdit;
    Label16: TLabel;
    ServerSocket1: TServerSocket;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Edit2Exit(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
//    procedure Timer3Timer(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Memo4KeyPress(Sender: TObject; var Key: Char);
    procedure Timer3Timer(Sender: TObject);
    procedure Edit6Exit(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Edit5Exit(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

//  cpu:cpu68k;
//  console:uart2681;
//  cookie2500:c2500cookie;
//  sysregs2500:c2500sysregs;
  Router: cisco2500;

  view1addr,view2addr:longword;
  breakpoint:longword;
  thread:integer;
  tid:longword;
//  speed:longword;
  ch:char;

implementation

{$R *.dfm}

procedure memoAddChar(memo:TMemo;c:char);
var  l:word;
     s:string;
begin
case c of
#$a: memo.lines.Add('');
#$8: begin
     s:=memo.Lines[memo.Lines.Count-1];
     l:=length(s)-1;
     setlength(s,l);
     memo.Lines[memo.Lines.Count-1]:=s;
     end;
#$7: asm nop end;
else memo.Lines[memo.Lines.Count-1]:=memo.Lines[memo.Lines.Count-1]+c;
end;

{if ord(c)=$a then memo.lines.Add('')
             else if ord(c)=8 then begin
                                    s:=memo.Lines[memo.Lines.Count-1];
                                    l:=length(s)-1;
                                    setlength(s,l);
                                    memo.Lines[memo.Lines.Count-1]:=s;
                                    end
                               else memo.Lines[memo.Lines.Count-1]:=memo.Lines[memo.Lines.Count-1]+c;}

{if ord(c)=$a then memo.lines.Add('')
             else memo.Lines.Text:=concat(memo.Lines.Text,c);}
end;
procedure tick(Sender: TObject);  //TForm1.Timer3Timer
var b:longword;
var c:byte;
begin
b:=0;
while true do begin
              if b and router.debug_speed =0 then begin
                                 if router.cpu.regs.pc=breakpoint then router.cpu.regs.sr:=router.cpu.regs.sr or $c000;
                                 //if router.cpu.regs.sr and $2000=0 then router.cpu.regs.sr:=router.cpu.regs.sr or $c000;
                                 if router.cpu.regs.sr and $C000=0 then  begin
                                                                  router.cpu.fetch;
                                                                  router.cpu.execute;
                                                                  router.console.tick;
                                                                  router.timer.tick;
                                                                  router.Lance.SingleStetp;
                                                                  router.Lance2.SingleStetp;
                                                                  end;
                                 if router.console.UserReadConsole(c) then begin
                                                                           memoaddchar(form1.memo4,chr(c));
                                                                           if form1.serversocket1.Socket.ActiveConnections>0 then form1.serversocket1.Socket.Connections[0].SendText(chr(c));
                                                                           end;
                                 ch:=#0;
                                 end;
              inc(b);
              if router.cpu.regs.sr and $c000 =$c000 then sleep(10);
              end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
button1.Enabled:=false;
listbox1.Items.LoadFromFile('C2500ROM64k.txt');
button3.Enabled:=true;
button7.Enabled:=true;
listbox1.Visible:=true;
edit6.Enabled:=true;
edit6.Text:=inttohex(router.cpu.MemoryRead16($2000002),4);
end;

function look4(a:longword):integer;
var s1,s2:string[8];
    i:integer;
begin
result:=$ffff;
for i:=0 to form1.listbox1.Items.Count-1 do
    begin
      s1:=form1.listbox1.Items[i];
      setlength(s1,8);
      s2:=inttohex(a,8);
      if s1=s2 then result:=i;
    end;

end;
procedure TForm1.Timer1Timer(Sender: TObject);
var i,j:byte;
    l:longword;
    s,s2:string[80];
begin
router.cpu.DebugNoCount:=false;
memo6.Clear;
memo6.Lines.Add('confreg:  '+inttohex(router.cpu.memoryread16($02000002),4));
memo6.Lines.Add('control1: '+inttohex(router.cpu.memoryread16($02110000),4));
memo6.Lines.Add('control2: '+inttohex(router.cpu.memoryread16($02110002),4));
memo6.Lines.Add('reset:    '+inttohex(router.cpu.memoryread16($02110004),4));
memo6.Lines.Add('interrupt:'+inttohex(router.cpu.memoryread16($02110006),4));
memo6.Lines.Add('unk:      '+inttohex(router.cpu.memoryread16($02110008),4));
memo6.Lines.Add('NVRAM:      '+inttohex(router.cpu.memoryread8($02110060),2));
memo6.Lines.Add('ce:          '+inttohex(router.cookie.ce,1));
memo6.Lines.Add('clock:       '+inttohex(router.cookie.clock,1));
memo6.Lines.Add('Bitno:      '+inttohex(router.cookie.bitno,2));
memo6.Lines.Add('command:    '+inttohex(router.cookie.command,2));
memo6.Lines.Add('read Addr:  '+inttohex(router.cookie.nvramRaddr,2));
memo6.Lines.Add('DO:          '+inttohex((router.cpu.memoryread8($02110060)and 2) shr 1 ,1));
memo6.Lines.Add('DI:          '+inttohex(router.cpu.memoryread8($02110060)and 1,1));
memo6.Lines.Add('T0counter:'+inttohex(router.cpu.memoryread16($02120050),4));
memo6.Lines.Add('T2counter:'+inttohex(router.cpu.memoryread16($02120070),4));
memo6.Lines.Add('InitCount:'+inttohex(router.Lance.initCount,4));
memo6.Lines.Add('imr:        '+inttohex(router.console.imr_copy,2));
memo6.Lines.Add('SrA:        '+inttohex(router.console.sra,2));

//01007CC2
label11.Caption:=inttohex(router.cpu.CPUCycles,16);


if router.cpu.regs.pc and 1 <>0 then memo1.Font.Color:=3;
memo1.Lines.Clear;
for i:=0 to listbox1.Items.Count-1 do listbox1.Selected[i]:=false;
//memo1.Lines.add('--------------------------');
For i:=0 to 3 do begin
                 memo1.Lines.add('|A'+inttostr(i)+'='+inttohex(router.cpu.regs.a[i],8)+'  A'+inttostr(i+4)+'='+inttohex(router.cpu.regs.a[i+4],8)+' |');
                 end;
memo1.Lines.add('--------------------------');
For i:=0 to 3 do begin
                 memo1.Lines.add('|D'+inttostr(i)+'='+inttohex(router.cpu.regs.d[i],8)+'  D'+inttostr(i+4)+'='+inttohex(router.cpu.regs.d[i+4],8)+' |');
                 end;
memo1.Lines.add('PC ='+inttohex(router.cpu.regs.pc,8)+' prv='+inttohex(router.cpu.DoldPc,8)+', '+inttohex(router.cpu.mopc,8));
//memo1.Lines.add('OP='+inttohex(cpu.currentOPcode,4));
memo1.Lines.add('VBR='+inttohex(router.cpu.regs.VBR,8));
//memo1.Lines.add('OP='+inttohex(cpu.currentOPcode,4));

s:='Flags=';
if router.cpu.regs.sr and 1   <>0 then s:=s+'C' else s:=s+'c';
if router.cpu.regs.sr and 2   <>0 then s:=s+'V' else s:=s+'v';
if router.cpu.regs.sr and 4   <>0 then s:=s+'Z' else s:=s+'z';
if router.cpu.regs.sr and 8   <>0 then s:=s+'N' else s:=s+'n';
if router.cpu.regs.sr and $10 <>0 then s:=s+'X' else s:=s+'x';
if router.cpu.regs.sr and $1000 <>0 then s:=s+'M' else s:=s+'m';
if router.cpu.regs.sr and $2000 <>0 then s:=s+'S' else s:=s+'s';
s:=s+' int mask'+inttohex((router.cpu.regs.sr and $0700)shr 8,1);


memo1.Lines.Add(s);
if look4(router.cpu.regs.pc)<>$ffff then listbox1.Selected[look4(router.cpu.regs.pc)]:=true;
memo2.Lines.Clear;
memo3.Lines.Clear;
memo5.Lines.Clear;
for j:=0 to 4 do
        begin
        s:=inttohex(view1addr+16*j,8)+' ';
        s2:=inttohex(view1addr+16*j,8)+' ';
        for i:=0 to $f do begin
                          s:=s+inttohex(router.cpu.memoryRead8(view1addr+16*j+i),2)+' ';
                          s2:=s2+chr(router.cpu.memoryRead8(view1addr+16*j+i));
                          if i and 3 =3 then s:=s+' ';
                          end;
        memo2.Lines.Add(s);
        memo5.Lines.Add(s2);
        end;
        for j:=0 to 5 do
        begin
        s:=inttohex(view2addr+16*j,8)+' ';
        for i:=0 to $f do begin
                          s:=s+inttohex(router.cpu.memoryRead8(view2addr+16*j+i),2)+' ';
                          if i and 3 =3 then s:=s+' ';
                          end;
        memo3.Lines.Add(s);
        end;
//listbox2.Clear;
l:=router.cpu.regs.a[7];
{for i:=1 to 6 do begin
                listbox2.items.add(inttohex(cpu.memoryread32(l+4),8));
                l:=l+4;
                end;}
//clock2500.tick;
router.cpu.DebugNoCount:=true;
end;

procedure TForm1.FormCreate(Sender: TObject);
var error:string;
begin
error:='';
try
//router:=cisco2500.intit(c2511,'nvram.bin','rom.xin','ios.bin','cookie.bin',4,LoadIOS or LoadNVR or LoadROM or Loadcookie or IntCtrlInst);
router:=cisco2500.intit(c2511,'nvram.bin','rom.xin','ios11.1.24.bin','cookie.bin',8,LoadIOS or LoadNVR or LoadROM or Loadcookie or IntCtrlInst);
//router:=cisco2500.intit(c2511,'nvram.bin','bios.bin','linux.bin','cookie.bin',8,LoadIOS or LoadNVR or LoadROM or Loadcookie or IntCtrlInst or crypt);
//router:=cisco2500.intit(c2511,'nvram.bin','c2514.bin','ios11.1.24.bin','cookie.bin',8,LoadIOS or LoadNVR or LoadROM or Loadcookie or IntCtrlInst or crypt);
except
on e: C2500Ex do error:=e.Message;
   end;

if error<>'' then begin
                  messagebox(0,PChar(error),PChar('Error notification'),2);
                  halt;
                  end;
router.debug_Speed:=$ffffff;

memo4.Lines.Add('');
//SetPriorityClass(thread, IDLE_PRIORITY_CLASS);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
router.cpu.regs.sr:=router.cpu.regs.sr and $3fff;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
//router.cpu.regs.sr:=router.cpu.regs.sr or $c000;
router.cpu.fetch;
router.cpu.execute;
router.timer.tick;
router.console.tick;
end;

procedure TForm1.Button4Click(Sender: TObject);
var i:byte;
begin
router.cpu.regs.pc:=$1000134;
memo4.Clear;
for i:=0 to 7 do router.cpu.regs.a[i]:=0;
for i:=0 to 6 do router.cpu.regs.d[i]:=0;
router.cpu.regs.a[7]:=$1000;
router.IntCtrl.reset;
//button4.Enabled:=false;
end;

procedure TForm1.Edit2Exit(Sender: TObject);
begin
if edit2.text[1]='$' then View2addr:=strtoint(edit2.text);
if edit7.Text[1]='$' then View2addr:=View2addr+strtoint(edit7.text);
if upcase(edit2.text[1])='A' then View2addr:=router.cpu.regs.a[ord(edit2.text[2])-48];
if upcase(edit2.text[1])='D' then View2addr:=router.cpu.regs.d[ord(edit2.text[2])-48];
end;

procedure TForm1.Edit1Exit(Sender: TObject);
begin
if edit1.text[1]='$' then View1addr:=strtoint(edit1.text);
if upcase(edit1.text[1])='A' then View1addr:=router.cpu.regs.a[ord(edit1.text[2])-48];
if upcase(edit1.text[1])='D' then View1addr:=router.cpu.regs.d[ord(edit1.text[2])-48];
end;
procedure TForm1.Timer2Timer(Sender: TObject);
//var b:byte;
begin
//if router.console.UserReadConsole(b) then memoaddchar(memo4,chr(b));
//ch:=#0;
//router.console.UserWriteConsole($ff);
//router.console.intrq;
router.console.switchTxRDY;
label14.Caption:=inttohex(router.cpu.regs.pc,8);
label15.Caption:=router.cpu.currentINSTR;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
memoaddchar(memo4,chr(65));
memoaddchar(memo4,chr(66));
memoaddchar(memo4,chr($a));
memoaddchar(memo4,chr($d));
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
timer2.Enabled:= not timer2.Enabled;
if timer2.Enabled then begin
                       label7.Caption:='on';
                       button6.Caption:='Console &Off';
                       end
                  else begin
                       label7.Caption:='off';
                       button6.Caption:='Console &On';
                       end;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
if tid=0 then begin
                 thread := BeginThread(nil,
                                       0,
                                       @tick,
                                       nil,
                                       0,
                                       tid);
                 tid:=1;
                 end;
router.cpu.regs.sr:=router.cpu.regs.sr and $3fff;
timer2.Enabled:= true;
label7.Caption:='on';
button6.Caption:='Console &off';
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
//router.cpu.regs.sr:=router.cpu.regs.sr or $4000;
router.debug_speed:=$ffffff;
if tid=1 then begin
//              CloseHandle(thread);
              TerminateThread(thread,0);
              tid:=0;
              end;
timer1.Enabled:=true;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
router.cpu.Interrupt(strtoint(edit4.Text));
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
timer1.Enabled:=not timer1.Enabled;
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
breakpoint:=strtoint(edit5.Text);
label9.Caption:=edit5.Text;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
router.cpu.regs.sr:=router.cpu.regs.sr xor 1;
end;

procedure TForm1.Button16Click(Sender: TObject);
begin
router.cpu.regs.sr:=router.cpu.regs.sr xor 8;
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
router.cpu.regs.sr:=router.cpu.regs.sr xor 2;
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
router.cpu.regs.sr:=router.cpu.regs.sr xor 4;
end;

procedure TForm1.Button19Click(Sender: TObject);
begin
router.debug_speed:=$ffffff;
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
router.debug_speed:=$fffff;
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
router.debug_speed:=$1;
timer1.Enabled:=false;
end;

procedure TForm1.Memo4KeyPress(Sender: TObject; var Key: Char);
begin
router.console.UserWriteConsole(ord(key));
end;

procedure TForm1.Timer3Timer(Sender: TObject);
begin
if router.cpu.regs.sr and $c000 =$c000 then label12.caption:='Cpu Status: Stopped'
                                       else label12.caption:='Cpu Status: Running';
end;

procedure TForm1.Edit6Exit(Sender: TObject);
begin
try
router.cpu.MemoryWrite16($2000002,strtoint(edit6.Text));
except
on EConvertError do application.MessageBox('bla','bla',MB_OK);
end;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
router.cpu.savestat;
end;

procedure TForm1.Button20Click(Sender: TObject);
begin
router.cpu.dump;
router.cpu.CPUStatusSave;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
router.Lance.destroy;
end;

procedure TForm1.Edit5Exit(Sender: TObject);
begin
breakpoint:=strtoint(edit5.Text);
label9.Caption:=edit5.Text;

end;

procedure TForm1.Button21Click(Sender: TObject);
begin
router.cpu.dump;
router.cpu.CPUStatusSave;
router.Lance.StatusSave;
router.cookie.StatusSave;
router.IntCtrl.StatusSave;
router.nvram.StatusSave;
router.sysregs.StatusSave;
router.timer.StatusSave;
router.console.StatusSave;
memo4.Lines.SaveToFile('.\sav\screen.txt');
end;

procedure TForm1.Button22Click(Sender: TObject);
begin
router.cpu.RestoreMemory;
router.cpu.CPUStatusRestore;
router.Lance.StatusRestore;
router.cookie.StatusRestore;
router.IntCtrl.StatusRestore;
router.nvram.StatusRestore;
router.sysregs.StatusRestore;
router.timer.StatusRestore;
router.console.StatusRestore;
memo4.Lines.LoadFromFile('.\sav\screen.txt');
end;


procedure TForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var s:string;
    i:byte;
begin
s:=Socket.ReceiveText;
for i:=1 to length(s) do router.console.UserWriteConsole(ord(s[i]));
end;



end.
