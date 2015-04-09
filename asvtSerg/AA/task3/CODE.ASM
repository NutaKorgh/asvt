model tiny
.code
org 100h

start:
jmp short init
obr:
cmp ax,0F123h
jnz _jmp
cmp bx, 7890h
jnz _jmp
xchg bx,ax
mov dx,cs
mov si,offset obr
iret
;sign db "ABCD1234EFGH5678"
_jmp:
	db 0eah
	a dw ?
	b dw ?
init:
mov ax, 0F123h
mov bx, 7890h
int 2fh
cmp ax, 7890h
jnz no
cmp bx, 0F123h
jnz no
cmp si,offset obr
jnz no

mov es,dx
;mov si, offset sign
mov di,si
cld
mov cx,16
repne cmpsb
jnz no


mov dx,offset strs
mov ah,9
int 21h
ret

no:
mov ax, 352Fh
int 21h
mov	a,	bx
mov	b,	es

mov dx,offset obr
mov ax,252Fh
int 21h	
	
mov dx, offset init
int 27h

strs db "Duplicate resident",13,10,"$"
end start