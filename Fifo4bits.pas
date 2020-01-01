(******************************************************************************)
(* This file contans the implementations of a class for handling a 3 bytes    *)
(* FIFO data structure.                                                       *)
(******************************************************************************)
unit Fifo4bits;
(***********************************************************)
(**)                      interface                      (**)
(***********************************************************)
type Fifo=   class
(***********************************************************)
(**)                      private                        (**)
(***********************************************************)
             buffer:array[0..4] of byte;                                        //Data Buffer
             Head:byte;                                                         //Head pointer.
             Tail:byte;                                                         //Tail Pointer.
(***********************************************************)
(**)                      public                         (**)
(***********************************************************)
             function  empty:boolean;                                     //Indicates if there's available space for store data.
             function  full:boolean;                                    //Indicates if there's available data for readings.
             function  get  :byte;                       //Extracts data from FIFO.
             procedure put  (data:byte);                       //Store data in FIFO.
             procedure clear;                                                   //Resets FIFO status.
             constructor create;                                                //Default constructor for this class.
             end;
(******************************************************************************)
(**)                                                                        (**)
(**)                            implementation                              (**)
(**)                                                                        (**)
(******************************************************************************)
(******************************************************************************)
function  Fifo.empty:boolean;
begin
result:=not(head=((tail-1) and 3));
end;
(******************************************************************************)
function  Fifo.full:boolean;
begin
result:=not(head=tail);
end;
(******************************************************************************)
procedure Fifo.put   (data:byte);
begin
if empty then begin
                    head:=(head+1) and 3;
                    buffer[head]:=data;
                    end;
end;
(******************************************************************************)
function  Fifo.get   :byte;
begin
get:=$80;
if full then begin
             result:=buffer[(tail+1)and 3];
             tail:=(tail+1) and 3;
             end
        else result:=(buffer[(tail+1) and 3]) and $80;
end;
(******************************************************************************)
procedure Fifo.clear;
begin
head:=0;tail:=0;
end;
(******************************************************************************)
constructor Fifo.create;
begin
head:=0;tail:=0;
end;
end.

