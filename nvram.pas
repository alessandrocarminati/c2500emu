Unit nvram;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
const SaveFileName='.\sav\nvram.sav';
type c2500nvram=class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
     locations : array[0..$7fff] of byte;
     WP        : boolean;
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
     function    InterfaceRead8  (address:word):    byte;
     function    InterfaceRead16 (address:word):   word;
     procedure   Load_NVRAMImage (var NVRAMFile:file);
     procedure   InterfaceWrite8 (address:word;data:byte);
     procedure   InterfaceWrite16(address:word;data:word);
     procedure   unlockNVRAM;
     procedure   StatusSave;
     procedure   StatusRestore;
     procedure   reset;
     constructor create;
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
function  c2500nvram.InterfaceRead8 (address:word):byte;
begin
if address<$8000 then result:=locations[address];
end;
(******************************************************************************)
procedure c2500nvram.InterfaceWrite8(address:word;data:byte);
begin
if not wp then if address<$8000 then locations[address]:=data;
end;
(******************************************************************************)
function  c2500nvram.InterfaceRead16 (address:word):word;
begin
if address<$8000 then result:=locations[address] shl 8 + locations[address+1];
end;
(******************************************************************************)
procedure c2500nvram.InterfaceWrite16(address:word;data:word);
begin
if not wp then if address<$8000 then begin
                                     locations[address  ]:=(data and $ff00) shr 8;
                                     locations[address+1]:= data and $ff;
                                     end;
end;
(******************************************************************************)
constructor c2500nvram.create;
begin
wp:=true;
end;
(******************************************************************************)
procedure c2500nvram.Load_NVRAMImage (var NVRAMFile:file);
begin
blockread(NVRAMFile,locations[0],filesize(NVRAMFile));
end;
(******************************************************************************)
procedure c2500nvram.reset;
begin
wp:=true;
end;
(******************************************************************************)
procedure c2500nvram.unlockNVRAM;
begin
wp:=false;
end;
(******************************************************************************)
procedure c2500nvram.StatusSave;
var f:file;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,locations,$8001);
closefile(f);
end;
(******************************************************************************)
procedure c2500nvram.StatusRestore;
var f:file;
begin
assignfile(f,SaveFileName);
system.reset(f,1);
blockread(f,locations,$8001);
closefile(f);
end;
end.
