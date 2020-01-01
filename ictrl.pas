Unit ictrl;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
const SaveFileName='.\sav\intrctrl.sav';
type          ResetProcs  = procedure of object;
type IntrCtrl=class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
         resets   : array [0..20] of resetProcs;
         Ndevices : byte;
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
           PendingIntr:boolean;                                                 //This indicates which interrupt number is pending. Note by this you may specify any interrupt in VB.
           pendingIntNo:byte;                                                   //This indicates if interrupt is pending.
           interfaces_int:word;
  procedure irq(channel:byte);                                                  //By this you may request an interruption.
  procedure AddResets(r:resetProcs);
  procedure StatusSave;
  procedure StatusRestore;
  constructor create;                                                           //Initialize and creates a new object.
  procedure reset;
end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
Procedure IntrCtrl.irq(channel:byte);
begin
pendingintno:=channel;
pendingintr:=true;
end;
(******************************************************************************)
constructor IntrCtrl.create;
begin
PendingIntr:=false;
Ndevices:=0;
end;
(******************************************************************************)
procedure IntrCtrl.AddResets(r:resetProcs);
begin
resets[Ndevices]:=r;
inc(Ndevices);
end;
(******************************************************************************)
procedure IntrCtrl.reset;
var i:byte;
begin
for i:=0 to Ndevices-1 do resets[i];
end;
(******************************************************************************)
procedure IntrCtrl.StatusSave;
var f:file;
begin
assignfile(f,SaveFileName);
rewrite(f,1);
blockwrite(f,ndevices,1);
blockwrite(f,PendingIntr,4);
closefile(f);
end;
(******************************************************************************)
procedure IntrCtrl.StatusRestore;
var f:file;
begin
assignfile(f,SaveFileName);
system.reset(f,1);
blockread(f,ndevices,1);
blockread(f,PendingIntr,4);
closefile(f);
end;
end.
