	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	msg_installed db 'installed$'
	msg_already db 'already installed$'
	
	oldint2f label dword
		int2f_off dw 0000h
		int2f_seg dw 0000h
		
	oldint21 label dword
		int21_off dw 0000h
		int21_seg dw 0000h
	
newint21 proc	
	jmp 	dword ptr cs:[oldint21]
newint21 endp

newint2f proc
	cmp 	ax, 0AC21h
	jne 	iExit
	cmp 	bx, 0BC21h
	jne 	iExit

checked:
	mov 	ax, 021ACh
	mov 	bx, 021BCh
	push 	cs
	pop 	es
	mov 	dx, offset newint2f
	iret

iExit: 
	jmp 	dword ptr cs:[oldint2f]
newint2f endp

start:				
	mov 	ax, 0AC21h
	mov 	bx, 0BC21h
	int 	2fh
	cmp 	ax, 021ACh
	jne		tsr
	cmp 	bx, 021BCh
	je 		already

tsr:	
	mov		ax, 352fh
	int		21h
	mov		word ptr cs:[int2f_off], bx
	mov		word ptr cs:[int2f_seg], es
	
	mov 	ax, 252fh	
	mov		dx, offset newint2f
	int		21h	
	
	mov		ax, 3521h
	int		21h
	mov		word ptr cs:[int21_off], bx
	mov		word ptr cs:[int21_seg], es
	
	mov 	ax, 2521h	
	mov		dx, offset newint21
	int		21h	
	
	mov 	ax, 0900h
	mov 	dx, offset msg_installed
	int 	21h
	
	mov 	dx, offset start + 1
	int 	27h
	jmp 	exit
	
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

already:
	mov 	ax, 0900h
	mov 	dx, offset msg_already
	int 	21h
	
exit:
	ret
end entry