	.model tiny
	.286
	.code
	org 100h
start:
	mov 	ah, 0Fh
	int 	10h
	mov page_number,bh
	shr ax,1
	sub ah,8
	mov _left,ah

	xor cx,cx
	mov es,cx
	mov al,es:[484h]
	sub al,16
	shr ax,1
	mov _top,al

	mov bh,7
	mov dx, 314Fh
	mov ax,0600h
	int 10h

	inc cx
	mov bh,page_number
	mov dh,_top
	mov dl, _left
	xor ax,ax

	next:
	mov ah,2
	int 10h

	mov bl,14h
	mov ah,9
	int 10h

	inc ax
	inc dx
	test al,0Fh
	jnz next
	inc dh
	sub dl,16
	cmp ah,10
	jne next
	ret
	page_number db ?
	_left db ?
	_top db 0
end start