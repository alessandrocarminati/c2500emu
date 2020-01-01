(******************************************************************************)
(* This file contans the implementations of the low level procedures and      *)
(* functions. Those includes Little-Big endian converter, sign extension      *)
(* Bit swappers and low level memory access.                                  *)
(******************************************************************************)
//## 8086 FLAGS LAYOUT
//## F E D C B A 9 8 7 6 5 4 3 2 1 0
//##|_|_|_|_|O|D|I|T|S|Z|_|A|_|P|_|C|
//## 68030 FLAGS LAYOUT
//##                      |X|N|Z|V|C|
(******************************************************************************)
function cpu68k.lo16(data:longword):word;   assembler;
asm
        mov     eax,data
end;
(******************************************************************************)
function cpu68k.bfGETu(data:longword;offs,dep:byte):longword;   assembler;
asm
        mov     eax,data
        mov     cl,offs
        shl     eax,cl

        mov     ch,$20
        sub     ch,cl
        sub     ch,dep
        add     cl,ch

        shr     eax,cl
end;
(******************************************************************************)
function cpu68k.bfGETs(data:longword;offs,dep:byte):longword;   assembler;
asm
        mov     eax,data
        mov     cl,offs
        shl     eax,cl

        mov     ch,$20
        sub     ch,cl
        sub     ch,dep
        add     cl,ch

        sar     eax,cl
end;
function cpu68k.addrcalc(addr1,addr2:pointer):longword;   assembler;
asm
        push    ebx
        mov     eax,addr1
        mov     ebx,addr2
        sub     eax,ebx
        pop     ebx
end;
Procedure cpu68k.divu64(op1hig,op1low,op2low,op2hig:longword;var reslow,reshig:longword);assembler;
asm
                 push    ebx
                 push    esi
                 push    edi
                 push    ebp
                 mov     ebx, op2low
                 mov     ebp, op2hig
                 mov     ecx, 40h
                 xor     edi, edi
                 xor     esi, esi
@loc_4:          shl     eax, 1
                 rcl     edx, 1
                 rcl     esi, 1
                 rcl     edi, 1
                 cmp     edi, ebp
                 jb      @loc_2
                 ja      @loc_1
                 cmp     esi, ebx
                 jb      @loc_2
@loc_1:          sub     esi, ebx
                 sbb     edi, ebp
                 inc     eax
@loc_2:          loop    @loc_4
@loc_3:          pop     ebp
                 mov     edi,reslow
                 mov     longword ptr[edi], eax
                 mov     edi,reshig
                 mov     longword ptr[edi], edx
                 pop     edi
                 pop     esi
                 pop     ebx

end;
(******************************************************************************)
function cpu68k.ror8(var b:byte;count:byte):boolean;assembler;
asm
          push	 cx
          mov    al,byte ptr [b]
          mov	 cl,count
          ror    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.ror16(var b:word;count:byte):boolean;assembler;
asm
          push	 cx
          mov    ax,word ptr [b]
          mov	 cl,count
          ror    ax,cl
          mov    word ptr[b],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.ror32(var b:longword;count:byte):boolean;assembler;
asm
          push	 cx
          mov    eax,longword ptr [b]
          mov	 cl,count
          ror    eax,cl
          mov    longword ptr[b],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;

(******************************************************************************)
function cpu68k.rol8(var b:byte;count:byte):boolean;assembler;
asm
          push	 cx
          mov    al,byte ptr [b]
          mov	 cl,count
          rol    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rol16(var b:word;count:byte):boolean;assembler;
asm
          push	 cx
          mov    ax,word ptr [b]
          mov	 cl,count
          rol    ax,cl
          mov    word ptr[b],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rol32(var b:longword;count:byte):boolean;assembler;
asm
          push	 cx
          mov    eax,longword ptr [b]
          mov	 cl,count
          rol    eax,cl
          mov    longword ptr[b],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;

(******************************************************************************)
function cpu68k.shr8(var b:byte;count:byte):boolean;assembler;
asm
          push	 cx
          mov    al,byte ptr [b]
          mov	 cl,count
          shr    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.shr16(var b:word;count:byte):boolean;assembler;
asm
          push	 cx
          mov    ax,word ptr [b]
          mov	 cl,count
          shr    ax,cl
          mov    word ptr[b],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.shr32(var b:longword;count:byte):boolean;assembler;
asm
          push	 cx
          mov    eax,longword ptr [b]
          mov	 cl,count
          shr    eax,cl
          mov    longword ptr[b],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.shl8(var b:byte;count:byte):boolean;assembler;
asm
          push	 cx
          mov    al,byte ptr [b]
          mov	 cl,count
          shl    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.shl16(var b:word;count:byte):boolean;assembler;
asm
          push	 cx
          mov    ax,word ptr [b]
          mov	 cl,count
          shl    ax,cl
          mov    word ptr[b],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.shl32(var b:longword;count:byte):boolean;assembler;
asm
          push	 cx
          mov    eax,longword ptr [b]
          mov	 cl,count
          shl    eax,cl
          mov    longword ptr[b],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;

(******************************************************************************)
function cpu68k.sar8(var b:byte;count:byte):boolean;assembler;
asm
          push	 cx
          mov    al,byte ptr [b]
          mov	 cl,count
          sar    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.sar16(var b:word;count:byte):boolean;assembler;
asm
          push	 cx
          mov    ax,word ptr [b]
          mov	 cl,count
          sar    ax,cl
          mov    word ptr[b],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.sar32(var b:longword;count:byte):boolean;assembler;
asm
          push	 cx
          mov    eax,longword ptr [b]
          mov	 cl,count
          sar    eax,cl
          mov    longword ptr[b],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.sal8(var b:byte;count:byte):boolean;assembler;
asm
          push	 cx
          mov    al,byte ptr [b]
          mov	 cl,count
          sal    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.sal16(var b:word;count:byte):boolean;assembler;
asm
          push	 cx
          mov    ax,word ptr [b]
          mov	 cl,count
          sal    ax,cl
          mov    word ptr[b],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.sal32(var b:longword;count:byte):boolean;assembler;
asm
          push	 cx
          mov    eax,longword ptr [b]
          mov	 cl,count
          sal    eax,cl
          mov    longword ptr[b],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rcr8(var b:byte;count,carry:byte):boolean;assembler;
asm
          push	 cx
          mov    al,carry
          or     al,al
          clc
          jnz    @NoCarry
          stc
@NoCarry: mov    al,byte ptr [b]
          mov	 cl,count
          rcr    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rcr16(var w:word;count,carry:byte):boolean;assembler;
asm
          push	 cx
          mov    al,carry
          or     al,al
          clc
          jnz    @NoCarry
          stc
@NoCarry: mov    ax,word ptr [w]
          mov	 cl,count
          rcr    al,cl
          mov    word ptr[w],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rcr32(var l:longword;count,carry:byte):boolean;assembler;
asm
          push	 cx
          mov    al,carry
          or     al,al
          clc
          jnz    @NoCarry   
          stc
@NoCarry: mov    eax,longword ptr [l]
          mov	 cl,count
          rcr    al,cl
          mov    longword ptr[l],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rcl8(var b:byte;count,carry:byte):boolean;assembler;
asm
          push	 cx
          mov    al,carry
          or     al,al
          clc
          jnz    @NoCarry
          stc
@NoCarry: mov    al,byte ptr [b]
          mov	 cl,count
          rcl    al,cl
          mov    byte ptr[b],al
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rcl16(var w:word;count,carry:byte):boolean;assembler;
asm
          push	 cx
          mov    al,carry
          or     al,al
          clc
          jnz    @NoCarry
          stc
@NoCarry: mov    ax,word ptr [w]
          mov	 cl,count
          rcl    al,cl
          mov    word ptr[w],ax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;
(******************************************************************************)
function cpu68k.rcl32(var l:longword;count,carry:byte):boolean;assembler;
asm
          push	 cx
          mov    al,carry
          or     al,al
          clc
          jnz    @NoCarry
          stc
@NoCarry: mov    eax,longword ptr [l]
          mov	 cl,count
          rcl    al,cl
          mov    longword ptr[l],eax
          mov    al,0
          jnc    @fin
          inc	 al
@fin:     pop	 cx
end;

(***********************************************************)
function cpu68k.signext16(w:word):longword;assembler;
asm
        push    edx
        and     edx,$0000ffff
        or      dx,dx
        jns     @no
        or      edx,$ffff0000
@no:    mov     eax,edx
        pop     edx
end;
(***********************************************************)
function cpu68k.signext8(w:byte):longword;assembler;
asm
        push    edx
        and     edx,$000000ff
        or      dl,dl
        jns     @no
        or      edx,$ffffff00
@no:    mov     eax,edx
        pop     edx
end;
(***********************************************************)
function cpu68k.LBW(l:longword):longword;assembler;
asm
        mov   eax,l
        xchg  al,ah
end;
(***********************************************************)
function cpu68k.LBL(l:longword):longword;assembler;
asm
        push    ecx
        mov     eax,l
        mov     ecx,eax
        xchg    al,ah
        shl     eax,16
        shr     ecx,16
        xchg    cl,ch
        add     eax,ecx
        pop     ecx
end;
(***********************************************************)
function cpu68k.regModSwap(n:byte):byte;assembler;
asm
        mov     al,n
        mov     ah,al
        and     al,$7
        and     ah,$38
        shl     al,3
        shr     ah,3
        or      al,ah
end;
(***********************************************************)
function cpu68k.getbyte(address:longword;var page):byte;assembler;
asm
        push   esi
        push   ecx
        mov    esi,page
        mov    ecx,address
        add    esi,ecx
        lodsb
        pop    ecx
        pop    esi
end;
(***********************************************************)
function cpu68k.getword(address:longword;var page):word;assembler;
asm
        push   esi
        push   ecx
        cld
        mov    esi,page
        mov    ecx,address
        add    esi,ecx
        lodsw
        xchg   al,ah
        pop    ecx
        pop    esi
end;
(***********************************************************)
function cpu68k.getlongword(address:longword;var page):longword;assembler;
asm
        push   esi
        push   ecx
        cld
        mov    esi,page
        mov    ecx,address
        add    esi,ecx
        lodsw
        xchg   al,ah
        mov    cx,ax
        shl    ecx,16
        lodsw
        xchg   al,ah
        and    eax,$ffff
        add    eax,ecx
        pop    ecx
        pop    esi
end;
(***********************************************************)
procedure cpu68k.putbyte(address:longword;val:byte;var page);assembler;
asm
        push   edi
        push   ecx
        push   eax
        mov    al,val
        mov    edi,page
        mov    ecx,address
        add    edi,ecx
        stosb
        pop    eax
        pop    ecx
        pop    edi
end;
(***********************************************************)
procedure cpu68k.putword(address:longword;val:word;var page);assembler;
asm
        push   edi
        push   ecx
        push   eax
        mov    ax,val
        mov    edi,page
        mov    ecx,address
        add    edi,ecx
        xchg   al,ah
        stosw
        pop    eax
        pop    ecx
        pop    edi
end;
(***********************************************************)
procedure cpu68k.putlongword(address,val:longword;var page);assembler;
asm
        push   edi
        push   ecx
        push   eax
        mov    eax,val
        mov    edi,page
        mov    ecx,address
        add    edi,ecx
        mov    cx,ax
        xchg   cl,ch
        shl    ecx,16
        shr    eax,16
        xchg   al,ah
        add    eax,ecx
        stosd
        pop    eax
        pop    ecx
        pop    edi
end;
