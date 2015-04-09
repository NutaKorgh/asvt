	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start				
	video_mode db 0
	video_page db 0
	error_read db 0	
	toprint_seg1 dw 0b800h
	toprint_seg2 dw 0b000h	
	length1 dw 80 
	length2 dw 160	
	cur_length dw 0
	start_table1 dw 80 * 2 + 4
	start_table2 dw 160 * 2 + 44
	start_table dw 0
	id db 30h
	msg_err db 'wrong mode or page$'
start:		
	call	consoleRead
	cmp 	error_read, 1
	je 		exitErr	
	mov 	ah, 00h 
	mov 	al, video_mode
	int 	10h		
	mov 	ah, 05h 
	mov 	al, video_page
	int 	10h	
			
	push 	toprint_seg1
	pop 	es
	mov 	ax, start_table2
	mov 	start_table, ax
	mov 	cur_length, ax
	mov 	ax, length2	
	mov 	cur_length, ax
	mov 	bx, 24
	mul 	bx
	add 	ax, 154
	mov 	bx, ax
	
	cmp 	video_mode, 0
	je 		width40
	cmp 	video_mode, 1
	je 		width40
	cmp 	video_mode, 7
	je 		changeSeg
	jmp 	printModeAndPage

changeSeg:
	push 	toprint_seg2
	pop 	es	
	jmp 	printModeAndPage
	
width40:		
	mov 	ax, start_table1
	mov 	start_table, ax
	mov 	ax, length1	
	mov 	cur_length, ax
	mov 	bx, 24
	mul 	bx
	add 	ax, 74
	mov 	bx, ax

printModeAndPage:			
	push 	es
	push 	0
	pop 	es
	mov 	ax, es:[44ch]
	pop 	es	
	xor 	cx, cx
	mov 	cl, video_page	
loopp:
	add		bx, ax
	loop 	loopp
	mov 	al, video_mode
	add 	al, 30h
	mov		es:[bx], al
	add 	bx, 4
	mov 	al, video_page
	add 	al, 30h
	mov		es:[bx], al	
	call 	printTable
	call 	printTail
	jmp 	exit

exitErr:
	mov		ax, 0900h
	lea		dx, msg_err
	int 	21h
exit:	
	ret
	
printTable proc	
	mov 	di, start_table
	push 	es
	push 	0
	pop 	es
	mov 	ax, es:[44ch]
	pop 	es	
	xor 	cx, cx
	mov 	cl, video_page	
loopp2:
	add		di, ax
	loop 	loopp2	
	call 	printFirstLine
	call 	printSecondLine
	call 	printThirdLine
	mov 	cx, 0010h 
	mov 	ax, 1E00h
	mov 	id, 30h
	printLine:
		push 	cx
		mov		cx, 010h
		call 	putDoubleVertLine
		call 	putID
		call 	putVertLine
		call 	putWhitespace
		printRow: 			
			stosw
			inc		al			
			call 	putWhitespace
			loop 	printRow
		call 	putDoubleVertLine
		add 	di, cur_length
		sub 	di, 004Ah
		pop		cx						
		loop 	printLine
	ret
printTable endp

printFirstLine proc
	mov 	ax, 1EC9h
	stosw
	mov 	ax, 1ECDh
	stosw
	mov 	ax, 1ED1h	
	stosw
	mov 	ax, 1ECDh
	xor 	cx, cx
	mov 	cx, 21h
printFirstLineLoop:
	stosw
	loop 	printFirstLineLoop
	mov 	ax, 1EBBh	
	stosw
	add 	di, cur_length
	sub 	di, 004Ah
	ret
printFirstLine endp

printSecondLine proc
	call 	putDoubleVertLine
	call 	putWhitespace
	call 	putVertLine
	mov 	cx, 10h
printSrcondLineLoop:
	call 	putWhitespace
	call 	putID
	loop 	printSrcondLineLoop
	call 	putWhitespace
	call 	putDoubleVertLine
	add 	di, cur_length
	sub 	di, 004Ah
	ret
printSecondLine endp

printThirdLine proc
	mov 	ax, 1EC7h
	stosw
	mov 	ax, 1EC4h
	stosw
	mov 	ax, 1EC5h	
	stosw
	mov 	ax, 1EC4h
	xor 	cx, cx
	mov 	cx, 21h
printThirdLineLoop:
	stosw
	loop 	printThirdLineLoop
	mov 	ax, 1EB6h
	stosw
	add 	di, cur_length
	sub 	di, 004Ah
	ret
printThirdLine endp

printTail proc
	mov 	ax, 1EC8h
	stosw
	mov 	ax, 1ECDh
	stosw
	mov 	ax, 1ECFh	
	stosw
	mov 	ax, 1ECDh
	xor 	cx, cx
	mov 	cx, 21h
printTailLoop:
	stosw
	loop 	printTailLoop
	mov 	ax, 1EBCh	
	stosw
	ret
printTail endp

putID proc
	push 	ax
	mov		ah, 1Eh
	mov 	al, id
	inc 	id
	cmp 	id, 3Ah
	jne 	contPutID
	mov 	id, 41h
contPutID:
	stosw
	pop 	ax
	ret
putID endp

putDoubleVertLine proc
	push 	ax
	mov		ax, 1EBAh
	stosw
	pop 	ax
	ret
putDoubleVertLine endp

putVertLine proc
	push 	ax
	mov		ax, 1EB3h
	stosw
	pop 	ax
	ret
putVertLine endp

putWhitespace proc
	push 	ax
	mov 	ax, 1E20h
	stosw
	pop 	ax
	ret
putWhitespace endp
	
consoleRead proc
	mov		bx, 80h
	mov 	dl, [bx]
	cmp 	dl, 4
	jl		readFail
skipWhitespaces:
	inc 	bx
	mov 	dl, [bx]
	cmp 	dl, 20h
	je 		skipWhitespaces
	
	call	changeMode ;dl		
	
	add 	bx, 2	
	mov		dl, [bx]
	
	call 	changePage ;dl
	jmp 	readEnd
readFail:
	mov 	error_read, 1
readEnd:
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