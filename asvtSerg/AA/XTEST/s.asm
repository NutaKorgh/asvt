.model tiny
.code

org 100h

start:
	jmp	init

my_int:
	push	dword	ptr	cs:[a]
	retf

a	dd	''


init:
	call bbb
	
	db 8Eh,06h,2Ch,00h
	mov ah,49h
	int 21h

	mov bx,2
	mov ah,48h
	int 21h

	db 0A3h,2Ch,00h
	mov es,ax
	xor di,di
	mov si,offset str0
	mov cx,15h
	rep movsb

	
	mov	ah,	035h
	mov	al,	021h
	int	021h
	mov	word ptr a,	bx
	mov	word ptr a+2,	es
	
	push	cs
	pop	ds
	mov	dx,	offset my_int
	mov	ah,	025h
	mov	al,	21h
	int	021h	
	
	mov	dx,	offset init
	int	27h
	ret
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
str0 db 'X',0,0,1,0,'X',0
end start