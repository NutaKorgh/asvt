	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	chars db 0B3h, 02Fh, 02Dh, 05Ch, 0B3h, 02Fh, 02Dh, 05Ch
	charsEnd db 0
	curChar dw 0h
	curTicks dw 10
	stop dw 0000h
	saveMode db 0
	ticks dw 0
	toprint_off dw 158	
	toprint_seg dw 0b800h
	direction dw 00h
	oldint08 label dword
		int08_off dw 0000h
		int08_seg dw 0000h
	oldint09 label dword
		int09_off dw 0000h
		int09_seg dw 0000h
	head dw 0
	tail dw 0
	buffer db 8 dup(?)
	
newint08 proc
	cmp 	stop, 0001h
	je 		endInt
	add		ticks, 1
endInt:	
	jmp 	dword ptr cs:[oldint08]
newint08 endp

newint09 proc
	push	ax
    mov 	ax, head
    inc 	ax
    and 	ax, 7
    cmp 	ax, tail
    je 		_iret

    push    bx
    in      al, 60h        
    mov  	bx, offset buffer
    add 	bx, head
    mov 	byte ptr [bx], al
    pop     bx

    inc 	head
    and 	head, 7

    in		al, 61h
    mov     ah, al
    or      al, 80h
    out     61h, al
    xchg    ah, al 
    out     61h, al
    mov     al, 20h
    out     20h, al
	
_iret:
    pop		ax
    iret
newint09 endp

start:	
	mov 	bx, offset chars
	mov 	curChar, bx
	
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
	
	mov		ax, 3509h
	int		21h
	mov		word ptr cs:[int09_off], bx
	mov		word ptr cs:[int09_seg], es

	mov 	ax, 2509h	
	mov		dx, offset newint09
	int		21h	
	
	mov		es, toprint_seg		
	jmp 	print

waiting:
	mov 	si, tail
	cmp 	head, si
	jz 		continueWaiting
	cli
	inc 	tail
	and 	tail, 7
	sti
	add 	si, offset buffer
	mov 	al, byte ptr [si]
	jmp 	exit
continueWaiting:
	mov 	dx, curTicks
	cmp 	ticks, dx
	je		print
	jmp		waiting

print:	
	mov		bx, toprint_off	
	mov 	stop, 0001h
	mov		ticks, 0
	push 	bx
	mov 	bx, [curChar]
	mov 	dx, [bx]
	pop 	bx
	mov 	es:[bx], dl
	
	inc 	curChar
	mov 	dx, offset charsEnd
	mov 	stop, 0000h
	cmp 	curChar, dx
	jne 	continueWaiting
	push 	bx
	mov 	bx, offset chars	
	mov 	curChar, bx
	call 	addDirection
	pop 	bx	
	jmp 	continueWaiting

addDirection proc	
	push 	ax bx dx
	cmp 	direction, 00h
	je 		addDirectionExit
	mov 	bx, toprint_off
	mov 	dx, 0020h
	mov 	es:[bx], dl
	cmp 	direction, 01h
	jne 	addDirectionContinue
	add		toprint_off, 2
	mov 	ax, toprint_off	
	mov 	bl, 160
	div 	bl
	cmp 	ah, 0
	jne 	addDirectionExit
	sub 	toprint_off, 160
	jmp		addDirectionExit
addDirectionContinue:
	sub 	toprint_off, 2
	mov 	ax, toprint_off	
	add 	ax, 2
	mov 	bl, 160
	div 	bl
	cmp 	ah, 0
	jne 	addDirectionExit
	add 	toprint_off, 160
addDirectionExit:
	pop 	dx bx ax
	ret
addDirection endp	
		
exit:	
	cmp 	al, 0Dh
	jne 	continueExit1
	call	incCurTicks	
continueExit1:
	cmp 	al, 0Ch
	jne 	continueExit2
	call 	decCurTicks
continueExit2:
	cmp 	al, 4Dh
	jne 	continueExit3
	mov 	direction, 01h
continueExit3:
	cmp 	al, 4Bh
	jne 	continueExit4
	mov 	direction, 02h
continueExit4:
	cmp 	al, 39h
	jne 	continueExit5
	mov 	direction, 00h
continueExit5:
	cmp 	al, 01h
	jne		continueWaiting
	mov 	ah, 0
	mov 	al, saveMode
	int 	10h
	
	mov 	ax, 2508h	
	mov		dx, word ptr cs:[int08_off]
	mov		ds, word ptr cs:[int08_seg]
	int		21h
	
	mov 	ax, 2509h	
	mov		dx, word ptr cs:[int09_off]
	mov		ds, word ptr cs:[int09_seg]
	int		21h
	
	ret

incCurTicks proc	
	cmp     curTicks, 20
	je 		incCurTicksEnd
	inc 	curTicks
incCurTicksEnd:
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