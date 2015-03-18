	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		

oldint21 label dword
	int21_off dw 0000h
	int21_seg dw 0000h
	
newint21 proc
	jmp 	dword ptr cs:[oldint21]
newint21 endp

printHex proc
	push 	bx cx dx
	mov 	bx, ax
	mov 	cx, 4
@k: 
	rol 	bx, 4 
	mov 	al, bl
	and 	al, 0fh
	cmp 	al, 10
	sbb 	al, 105
	das
	mov 	dh, 02h
	xchg 	ax, dx
	int 	21h
	loop 	@k
	pop 	dx cx bx
	ret
printHex endp

start:	
	mov		ax, 3521h
	int		21h
	mov		word ptr cs:[int21_off], bx
	mov		word ptr cs:[int21_seg], es

	mov 	ax, 2521h	
	mov		dx, offset newint21
	int		21h
	
	mov		ax, cs
	call 	printHex
	mov 	ax, 0200h
	mov 	dx, ':'
	int 	21h
	mov 	ax, offset newint21
	call 	printHex

	mov 	dx, offset printHex+1
	int 	27h
	ret
	
end entry