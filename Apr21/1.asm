	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	curChar dw 0B3h
	curTicks dw 10
	stop dw 0000h
	saveMode db 0
	ticks dw 0
	toprint_off dw 160 * 10 + 88	
	toprint_seg dw 0b800h
	oldint08 label dword
		int08_off dw 0000h
		int08_seg dw 0000h
	
newint08 proc
	cmp 	stop, 0001h
	je 		endInt
	add		ticks, 1
endInt:	
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
	mov		bx, toprint_off	
	jmp 	print
waiting:
	mov 	ah, 01h
	int 	16h	
	jnz		exit
continueWaiting:
	mov 	dx, curTicks
	cmp 	ticks, dx
	je		print
	jmp		waiting

print:
	mov 	stop, 0001h
	mov		ticks, 0
	mov 	dx, curChar
	mov 	es:[bx], dl
		
	cmp 	curChar, 0B3h 
	je 		endPrint1
	cmp 	curChar, 02Fh 
	je 		endPrint2
	cmp 	curChar, 02Dh 
	je 		endPrint3
	cmp 	curChar, 05Ch 
	je 		endPrint4
	
endPrint1:
	mov 	curChar, 02Fh
	mov 	stop, 0000h
	jmp 	continueWaiting
endPrint2:
	mov 	curChar, 02Dh
	mov 	stop, 0000h
	jmp 	continueWaiting
endPrint3:
	mov 	curChar, 05Ch
	mov 	stop, 0000h
	jmp 	continueWaiting
endPrint4:
	mov 	curChar, 0B3h
	mov 	stop, 0000h
	jmp 	continueWaiting
	
exit:	
	mov 	ah, 00h
	int 	16h		
	cmp 	al, 2Bh
	jne 	continueExit1
	call	incCurTicks
continueExit1:
	cmp 	al, 2Dh
	jne 	continueExit2
	call 	decCurTicks
continueExit2:
	cmp 	ah, 1
	jne		continueWaiting
	mov 	ah, 0
	mov 	al, saveMode
	int 	10h
	
	mov 	ax, 2508h	
	mov		dx, word ptr cs:[int08_off]
	mov		ds, word ptr cs:[int08_seg]
	int		21h
	ret

incCurTicks proc
	inc 	curTicks
	ret
incCurTicks endp

decCurTicks proc
	cmp     curTicks, 1
	je 		decCurTicksEnd
	dec 	curTicks
decCurTicksEnd:
	ret
decCurTicks endp

end entry