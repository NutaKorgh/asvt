	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	saveMode db 0
	ticks dw 0
	unbalancedSecs dw 0
	sec1 dw 0035h
	sec2 dw 0035h
	min1 dw 0039h
	min2 dw 0035h
	toprint_sec1 dw 160 * 15 + 88
	toprint_sec2 dw 160 * 15 + 86
	toprint_div	dw 160 * 15 + 84
	toprint_min1 dw 160 * 15 + 82
	toprint_min2 dw 160 * 15 + 80
	toprint_seg dw 0b800h
	oldint08 label dword
		int08_off dw 0000h
		int08_seg dw 0000h
	
newint08 proc
	add		ticks, 1	
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
	
	mov		es, toprint_seg	
	mov		bx, toprint_div
	mov 	al, 3Ah
	mov		es:[bx], al
waiting:
	mov 	ah, 01h
	int 	16h	
	jnz		exit	
continueWaiting:
	cmp 	unbalancedSecs, 5
	je 		longerWait
	cmp 	ticks, 18
	je		print
	jmp		waiting
longerWait:	
	cmp 	ticks, 19
	je		balancePrint
	jmp		waiting

balancePrint:	
	mov 	unbalancedSecs, 0
	jmp 	print

print:
	mov		ticks, 0
	inc 	unbalancedSecs

	mov		ax, sec1	
	mov 	bx, toprint_sec1
	mov 	es:[bx], al
	
	mov		ax, sec2
	mov 	bx, toprint_sec2
	mov 	es:[bx], al
	
	mov		ax, min1
	mov 	bx, toprint_min1
	mov 	es:[bx], al
	
	mov		ax, min2
	mov 	bx, toprint_min2
	mov 	es:[bx], al
		
	mov 	ax, sec1
	mov 	dl, 0Ah	
	call 	incPart
	mov		sec1, ax	
	cmp 	al, 30h
	jne		waiting
	
	mov 	ax, sec2
	mov 	dl, 06h	
	call 	incPart
	mov		sec2, ax
	cmp 	al, 30h
	jne		waiting
	
	mov 	ax, min1
	mov 	dl, 0Ah	
	call 	incPart
	mov		min1, ax
	cmp 	al, 30h
	jne		waiting
	
	mov 	ax, min2
	mov 	dl, 06h	
	call 	incPart
	mov		min2, ax	
	jmp		waiting

incPart proc		
	inc 	al
	sub 	al, 30h	
	div 	dl
	xchg	al, ah
	xor 	ah, ah
	add		al, 30h	
	ret
incPart	endp
	
exit:	
	mov 	ah, 00h
	int 	16h	
	cmp 	ah, 1
	jne 	continueWaiting
	; возврат в преждний режим
	mov 	ah, 0
	mov 	al, saveMode
	int 	10h
	
	mov 	ax, 2508h	
	mov		dx, word ptr cs:[int08_off]
	mov		ds, word ptr cs:[int08_seg]
	int		21h
	ret
end entry