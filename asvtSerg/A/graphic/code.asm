model tiny
.code
org 100h
start:

mov ax,3509h
int 21h
mov tes,es
mov tbx,bx
mov ah,25h
mov dx,offset Int_09h
int 21h

mov ax,4
int 10h
mov ax,0
int 33h
mov ax,1
int 33h

mov cx,8
mov dx,offset mouse_obr
mov ax,0Ch
int 33h

inf:
cmp byte ptr flag, 1
je _out
mov bx,hvost
cmp golova,bx
jz inf
cli
inc hvost
and hvost,7
sti
add bx,offset buffer
mov al,byte ptr [bx]
cmp al,81h
je _out
cmp al,0B9h
jne inf
mov dx,offset lines
mov ah,9
int 21h
jmp inf

_out:
mov ax,2509h
mov dx,tbx
push ds
mov ds, tes
int 21h
pop ds

mov cx,0
mov ax,0Ch
mov dx,0
push dx
pop es
int 33h
mov ax,3
int 10h
ret

mouse_obr:
mov byte ptr flag,1
retf

Int_09h:
     push  ax
     mov ax,golova
     inc ax
     and ax,7
     cmp ax,hvost
     je _iret

     push      bx
     in        al,60h        
     mov  bx,offset buffer
     add bx,golova
     mov byte ptr [bx],al
     pop       bx

     inc golova
     and golova,7

     in        al,61h
     mov       ah,al
     or        al,80h
     out       61h,al
     xchg      ah,al 
     out       61h,al
     mov       al,20h
     out       20h,al
_iret:
     pop ax
     iret

flag db 0
buffer db ?,?,?,?,?,?,?,?
golova dw 0
hvost dw 0
tes dw ?
tbx dw ?
lines db '_________',13,10,'$'
end start