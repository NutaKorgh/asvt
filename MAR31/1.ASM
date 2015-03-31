	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	save_mode db 0		
	video_mode db 0
	video_page db 0
	error_read db 0
	toprint_seg1 dw 0b800h
	toprint_seg2 dw 0b000h
	toprint_off1 dw 80 * 24 + 70	
	toprint_off2 dw 160 * 24 + 150		
	msg_err db 'wrong mode or page$'
start:		
	call	consoleRead
	cmp 	error_read, 1
	je 		exitErr	
	mov 	ah, 00h 
	mov 	al, video_mode
	int 	10h		
	; mov 	ah, 05h 
	; mov 	al, video_page
	; int 	10h	
			
	push 	toprint_seg1
	pop 	es
	mov 	bx, toprint_off2
	
	cmp 	video_mode, 0
	je 		width40
	cmp 	video_mode, 1
	je 		width40
	cmp 	video_mode, 7
	je 		changeSeg
	jmp 	print

changeSeg:
	push 	toprint_seg2
	pop 	es	
	jmp 	print
	
width40:		
	mov 	bx, toprint_off1

print:			
	mov 	al, video_mode
	add 	al, 30h
	mov		es:[bx], al
	add 	bx, 4
	mov 	al, video_page
	add 	al, 30h
	mov		es:[bx], al
	jmp 	exit

exitErr:
	mov		ax, 0900h
	lea		dx, msg_err
	int 	21h
exit:	
	ret
	
consoleRead proc	
	mov		bx, 80h
skipWhitespaces:
	inc 	bx
	mov 	dl, [bx]
	cmp 	dl, 20h
	je 		skipWhitespaces
	
	call	changeMode ;dl		
	
	add 	bx, 2	
	mov		dl, [bx]
	
	call 	changePage ;dl

	ret
consoleRead endp

changeMode proc
	sub		dl, 30h
	mov 	video_mode, dl
	cmp		dl, 0h
	je 		changeModeEnd
	cmp		dl, 1h
	je 		changeModeEnd
	cmp		dl, 2h
	je 		changeModeEnd
	cmp		dl, 3h
	je 		changeModeEnd
	cmp		dl, 7h
	je 		changeModeEnd
	mov		video_mode, 0h
	mov 	error_read, 1
changeModeEnd:
	ret
changeMode endp

changePage proc
	sub		dl, 30h
	mov 	video_page, dl
	cmp 	video_mode, 2
	je 		chagePage0_3
	cmp 	video_mode, 3
	je 		chagePage0_3
	
	add 	dl, 7
	cmp 	dl, 14
	jle		changePageEnd
	
chagePage0_3:
	add 	dl, 3
	cmp 	dl, 6
	jle		changePageEnd
		
	mov 	error_read, 1
changePageEnd:
	ret
changePage endp


end entry