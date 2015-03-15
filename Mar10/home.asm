	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start	
	string db 'lol$'
	oldint21 label dword
	int21_off dw    0000h
    int21_seg dw    0000h

printHex proc
	mov		bx, cs		
	mov		cx, 4
@loop:
	rol		bx, 4
	mov 	al, bl
	and 	al, 0fh
	cmp		al, 0Ah
	sbb		al, 105
	das
	mov		dh, 02h
	xchg	ax, dx
	int		21h
	loop	@loop
printHex endp
	
newint21 proc
	jmp 	dword ptr cs:[oldint21]
newint21 endp

start:	
	mov		ax, 3521h
	int		21h
	mov		word ptr cs:[int21_off], bx
	mov		word ptr cs:[int21_seg], es

	mov 	ax, 2521h	
	mov		dx, offset newint21
	int		21h
	
	mov 	dx, offset start+1
	int 	27h
	ret
	
end entry