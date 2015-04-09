model tiny
.486
.code
org 100h
start:
	str0 db 0BBh
	;jmp short init
	a	dw	0000h
	b	dw	09EBh
	db 'X',0
obr:	
	;les bx,dword ptr a
	;jmp  es:bx
	;push b
	;push a
	push dword	ptr	cs:[a]
	retf
init:
	call bbb
	inc bx
	mov si,offset str0
	mov [si+3],bx
	xor di,di
	mov cx,7
	
	;mov bx,2Ch
	;mov ax,[bx]
	;push ax
	;pop es
	;mov es,[2Ch]
	db 8Eh,06h,2Ch,00h
	mov ah,49h
	int 21h
	
	mov ah,48h
	int 21h

	;mov bx,2Ch
	;mov [bx],ax
	;mov [2Ch],ax
	db 0A3h,2Ch,00h
	mov es,ax

	rep movsb
	
	mov ax, 3521h
	int 21h
	mov	[si-6],	bx
	mov	[si-4],	es

	mov dx, si
	mov ah,25h
	int 21h
	
	mov dx,offset init
	int 27h
	
bbb:
	mov ax,cs
	xchg ah,al
	call tst
	mov ax,cs
tst:
	push ax
	shr al,	4
	call _1
	pop ax
	and al,	0Fh
_1:	cmp al,	0Ah
	sbb al,	69h
	das
	xchg dx, ax
	mov ah, 2
	int 21h
	ret
end start	
