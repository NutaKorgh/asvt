model tiny
.code
.286
org 100h
start:
	mov cx,cs
	mov dh,ch
	call tst
	mov dh, cl
	call tst

ret	
tst proc near	
	mov al,	dh
	shr al,	4
	
	call _1

	xor al,	al
	mov al,	dh
	and al,	0Fh
_1:	cmp al,	10
	sbb al,	069h
	das
	
	mov ah,	2
	mov dl,	al
	int 021h
	ret
tst endp
end start	
