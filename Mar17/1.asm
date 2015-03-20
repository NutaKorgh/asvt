	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	saveMode db 0
	count dw 0
	number dw 0230h	
	toprint label dword
		toprint_off dw 160 * 15 + 80
		toprint_seg dw 0b800h
	oldint08 label dword
		int08_off dw 0000h
		int08_seg dw 0000h
	
newint08 proc
	add		count, 1	
	jmp 	dword ptr cs:[oldint08]
newint08 endp

start:	
	mov 	ah, 0fh
	int 	10h
	mov 	saveMode, al
	
	mov 	ah, 00h 
	mov 	al, 03h
	int 	10h
	
	mov		ax, 3508h
	int		21h
	mov		word ptr cs:[int08_off], bx
	mov		word ptr cs:[int08_seg], es

	mov 	ax, 2508h	
	mov		dx, offset newint08
	int		21h	
	
waiting:
	mov 	ah, 01h
	int 	16h	
	jnz		exit	
	cmp 	count, 18
	je		print
	; jmp 	print
	jmp		waiting

exit:	
	mov 	ah, 00h
	int 	16h	
	cmp 	ah, 1
	jne 	waiting
	; возврат в преждний режим
	mov 	ah, 0
	mov 	al, saveMode
	int 	10h
	
	mov 	ax, 2508h	
	mov		dx, word ptr cs:[int08_off]
	mov		ds, word ptr cs:[int08_seg]
	int		21h
	ret
	
print:
	mov		count, 0
	mov		ax, number
	push 	0b800h
	pop		es
	mov 	bx, toprint_off
	mov 	es:[bx], al
	add 	ax, 1
	sub 	ax, 230h
	mov 	dl, 0Ah
	div 	dl
	xchg	al, ah
	add		al, 30h
	mov 	ah, 02h
	mov 	number, ax
	jmp 	waiting
end entry