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
	_jmp:
		db 0eah
		a dw ?
		b dw ?
	;sign db "ABCD1234EFGH5678"

init:
	cld
	xor ax,ax
	mov si,81h
read1:	
	lodsb
	cmp al,' '
	je read1
	cmp al,'-'
	jne help
read2:
	lodsb
	mov key,al
	mov cx,3
	mov di,offset luk
	repne scasb
	jz next
help:
	mov dx,offset str_help
	jmp print

ne_load:
	cmp key,'k'
	jz kill
	mov ax, 352Fh
	int 21h
	cmp 	bx,	offset obr
	jne try_kill
	mov bx,es
	cmp	bx,	dx
	jne try_kill
	kill:
	mov bp,offset _jmp+1
	mov dx, es:[bp]
	mov ds, es:[bp+2]
	mov ax,252Fh
	int 21h
	mov ah,49h
	int 21h
	ret



ne_load2:
	mov dx,offset noresmsg
print:
	mov ah,9
	int 21h
	ret
try_kill:
	mov dx,offset trykill
	jmp print



next:
	mov ax, 0F123h
	mov bx, 7890h
	int 2fh
	cmp ax, 7890h
	jnz no
	cmp bx, 0F123h
	mov es,dx
	;mov si, offset sign
	mov di,si
	mov cx,16
	repne cmpsb
	jnz no
	cmp key,'l'
	jne ne_load
	mov dx,offset strs
	jmp print

no:
	cmp key,'l'
	jne ne_load2
	mov ax, 352Fh
	int 21h
	mov	a,	bx
	mov	b,	es
	mov dx,offset obr
	mov ax,252Fh
	int 21h
	mov dx, offset init
	int 27h
key db ?
res_segm dw ?
res_offset dw ?
luk db "luk"
trykill db "Cannot unload.",13,10,"$"
noresmsg db "No resident loaded!",13,10,"$"
strs db "Duplicate resident!",13,10,"$"
str_help db "	Usage: code parametr",13,10
db	"Parametres:",13,10
db	"	-h		","Show this help.",13,10
db	"	-l		","Load resident.",13,10
db	"	-u		","Unload resident.",13,10
db	"	-k		", "Kill resident.",13,10,13,10,"$"

end start