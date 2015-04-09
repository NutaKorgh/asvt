.286
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

		
counter dw 0
XX db 10h
;fl db 1
buf db '     '

int_08h:
pusha
push es
push ds

push cs
pop es
mov di,offset buf+4
std
mov bx,10

mov dx,cs:counter
mov cx,5
pr:
xchg ax,dx
xor dx,dx
div bx
xchg ax,dx
add al,30h
stosb
loop pr

mov ah,7
push 0B800h
pop es
push cs
pop ds
mov si, offset buf
xor di,di
cld
mov cx,5
pr2:
lodsb
stosw
loop pr2

pop ds	
pop es
popa

_jmp08:
	db 0eah
	a08 dw ?
	b08 dw ?	
		
int_XXh:
	inc cs:counter
_jmpXX:
	db 0eah
	a10 dw ?
	b10 dw ?

	
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
	;mov bp,offset _jmp+1
	;mov dx, es:[bp]
	;mov ds, es:[bp+2]
	
	mov dx, es:[a10]
	mov ds, es:[b10]
	mov ah,25h
	mov al,XX
	int 21h
	mov dx, es:[a08]
	mov ds, es:[b08]
	mov al,08h
	int 21h
	mov dx, es:[a]
	mov ds, es:[b]
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
	jnz no
	mov es,dx
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
	mov al,08h
	int 21h
	mov b08,es
	mov a08,bx
	mov al,XX
	int 21h
	mov b10,es
	mov a10,bx
	
	mov dx,offset obr
	mov ax,252Fh
	int 21h
	mov al, 08h
	mov dx,offset int_08h
	int 21h
	mov al,XX
	mov dx,offset int_XXh
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