Unit cookie;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
const SaveFileName='.\sav\cookie.sav';
type c2500cookie=class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)

(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
     locations     : array[0..$1f] of byte;                                     //Those locations contains the cookie informations in a not x24c44 based cookie. (not used)
     temp          : array[0..$f] of word;                                      //This is the working Ram of the x24c44.
     stored        : array[0..$f] of word;                                      //This is the stored data area of the x24c44.
     command       : byte;                                                      //This register keeps the value of the last x24c44 given command.
     BitNo         : byte;                                                      //This is the actual processing bit number.
     Clock         : byte;                                                      //This is the clock latch.
     reg           : byte;                                                      //This keeps the address mapped value.
     ce            : byte;                                                      //This bit selects the x24c44 for working.
     nvramRaddr    : byte;                                                      //This keeps the last memory read address.
     nvramWaddr    : byte;                                                      //This keeps the last memory write address.
     data_command  : byte;                                                      //This keeps data when x24c44 is in data mode.
     decodecommand : boolean;                                                   //This indicates the state of x24c44.
     procedure setcookie(var f:file);                                           //This method allow to load cookie data from opened file.
     function  InterfaceRead8  (address:word):     byte;                        //By this function cpu access in reading mode to 8 bit memory mapped registers.
     procedure InterfaceWrite8 (address:word;data:byte);                        //By this function cpu access in writing mode to 8 bit memory mapped registers.
     procedure reset;
     procedure StatusSave;
     procedure StatusRestore;
     constructor create;                                                        //Initialize and create a new object.
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
function  c2500cookie.InterfaceRead8  (address:word):     byte;
begin
if address<$20 then result:=locations[address]
               else result:=reg;
end;
(******************************************************************************)
procedure c2500cookie.InterfaceWrite8 (address:word;data:byte);
var i:byte;
begin
{ CE SK DI DO}
if address=$20 then
   begin
   if data and 8 <>0 then ce:=1
                     else begin
                          ce:=0;
                          bitno:=0;
                          clock:=0;
                          nvramWaddr:=$ff;
                          nvramRaddr:=$ff;
                          end;

   reg:=data;
   if ce<>1 then exit;
   if data_command =0 then
      begin
       If (Clock=1) and (data and 4=0) then begin
                                            clock:=0;
                                            end;
       If (Clock=0) and (data and 4=4) then begin
                                            clock:=1;
                                            if (data and 2) = 0 then command :=command and not(1 shl (bitno))
                                                                else command :=command or ( 1 shl (bitno));
                                            bitno:=(bitno + 1) and 7;
                                            if bitno=0 then
                                                            decodecommand:=true;
                                            end;
       if decodecommand then
          begin
          case command and $e1 of
               $01: begin end;
               $81: begin
                    for i:=0 to $f do stored[i]:=temp[i];
                    end;
               $c1: begin
                    nvramWaddr:=(command and $1e) shr 1;
                    data_command:=1;
                    end;
               $21: begin end;
               $a1: begin
                    for i:=0 to $f do temp[i]:=stored[i];
                    end;
               $61: begin end;
               $e1: begin
                    nvramRaddr:=(command and $1e) shr 1;
                    if temp[nvramRaddr] and $1=0 then reg:=reg and $fe
                                                 else reg:=reg or 1;
                    bitNo:=1;
                    data_command:=1;
                    end;
               end;
          decodecommand:=false;
          end;
      end
   else  begin
         if nvramRaddr<>$ff then begin
                                 If (Clock=1) and (data and 4=0) then begin
                                                                      clock:=0;
                                                                      end;
                                 If (Clock=0) and (data and 4=4) then begin
                                                                      clock:=1;
                                                                      if temp[nvramRaddr] and (1 shl (bitNo))=0 then reg:=reg and $fe
                                                                                                                   else reg:=reg or 1;
                                                                      bitno:=(bitno + 1) and $F;
                                                                      if bitno=0 then begin
                                                                                      nvramRaddr:=$ff;
                                                                                      data_command:=0;
                                                                                      end;
                                                                      end;
                                 end;
         if nvramWaddr<>$ff then begin
                                 If (Clock=1) and (data and 4=0) then begin
                                                                      clock:=0;
                                                                      end;
                                 If (Clock=0) and (data and 4=4) then begin
                                                                      clock:=1;
                                                                      if (data and 2) = 0 then temp[nvramRaddr] :=temp[nvramRaddr] and not(1 shl ($f-bitno))
                                                                                          else temp[nvramRaddr] :=temp[nvramRaddr] or (1 shl ($f-bitno));
                                                                      bitno:=(bitno + 1) and $F;
                                                                      if bitno=0 then begin
                                                                                      nvramWaddr:=$ff;
                                                                                      data_command:=0;
                                                                                      end;
                                                                      end;
                                 end;
         end;
   end;
end;
(******************************************************************************)
procedure c2500cookie.setcookie(var f:file);
var i:byte;
function xchgw(a:word):word;assembler;
asm
        mov ax,a
        xchg al,ah
end;
begin
blockread(f,stored,sizeof(stored));
for i:=0 to $f do stored[i]:=xchgw(stored[i]);
end;
(******************************************************************************)
constructor c2500cookie.create;
var i:byte;
begin
reg:=0;
command:=$0;
for i:=0 to $1f do locations[i]:=$ff;
nvramWaddr:=$ff;
nvramRaddr:=$ff;
end;
(******************************************************************************)
procedure c2500cookie.reset;
var i:byte;
begin
reg:=0;
clock:=0;
bitno:=0;
command:=$0;
nvramWaddr:=$ff;
nvramRaddr:=$ff;
end;
(******************************************************************************)
procedure c2500cookie.StatusSave;
var f:file;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,locations[0],73);
closefile(f);
end;
(******************************************************************************)
procedure c2500cookie.StatusRestore;
var f:file;
begin
assignfile(f,SaveFileName);
system.reset(f,1);
blockread(f,locations[0],73);
closefile(f);
end;
end.
