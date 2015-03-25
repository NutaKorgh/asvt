	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	msg_incorrectKey db 'incorrect key, try /h to show help$'
	msg_help db 'Help:', 10, 13, '	/h - for help', 10, 13, '	/i - for install', 10, 13, '	/u - for soft uninstall', 10, 13, '	/k - for hard uninstall', '$'
	msg_installed db 'installed$'
	msg_alreadyIn db 'already installed$'
	msg_uninstalled db 'uninstalled$'
	msg_alreadyOut db 'nothing to remove$'
	msg_nouninstalled db 'can not uninstall, cause some of handlers not on the top$'
	msg_killed db 'killed$'
	
	tsr_seg dw 0
	onTheTop dw 0
	isLaunched dw 0
	hardRemove dw 0
	
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
	cmp 	ax, 0AD2fh
	jne 	i2fExit
	cmp 	bx, 0BD2fh
	jne 	i2fExit

checked:
	mov 	ax, 02fADh
	mov 	bx, 02fBDh
	push 	cs
	pop 	es	
	iret

i2fExit: 
	jmp 	dword ptr cs:[oldint2f]
newint2f endp

start:			
	call 	consoleRead
	cmp 	ax, 0 ;help
	je 		help
	cmp 	ax, 1 ;install
	je 		install
	cmp 	ax, 2 ;uninstall
	je		uninstall
	cmp 	ax, 3 ;kill
	je 		kill
	jmp 	wrongKey
	
help:
	mov 	ax, 0900h
	lea 	dx, msg_help
	int 	21h
	jmp 	exit
wrongKey:
	mov 	ax, 0900h
	lea 	dx, msg_incorrectKey
	int 	21h
	jmp 	exit	

install:	
	call 	checkLaunched
	cmp 	isLaunched, 1
	je 		alreadyIn

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
	
	alreadyIn:
		mov 	ax, 0900h
		mov 	dx, offset msg_alreadyIn
		int 	21h
		jmp 	exit

uninstall:	
	call 	checkLaunched
	cmp 	isLaunched, 1
	jne		alreadyOut
	cmp 	hardRemove, 1
	je 		killTsr	
	mov 	onTheTop, 0
	mov 	ah, 35h
	mov 	al, 2fh
	mov 	dx, offset newint2f
	call 	checkTop	
	mov 	al, 21h
	mov 	dx, offset newint21
	call 	checkTop
	
	cmp 	onTheTop, 2
	jne 	noUninstalled	
	killTsr:	
		push	tsr_seg
		pop		es
		push 	ds
		call 	returnHandlers	
		pop		ds
			
		mov 	ax, 0900h
		mov 	dx, offset msg_uninstalled
		cmp 	hardRemove, 1
		jne		uninstallPrint
		mov 	dx, offset msg_killed
	uninstallPrint:	
		int 	21h
	
	push	tsr_seg
	pop		es	
	mov 	ax, es:[2ch]
	push 	ax
	pop 	es
	mov 	ax, 4900h
	int 	21h
	
	push	tsr_seg
	pop		es	
	mov 	ax, 4900h
	int 	21h		
	jmp 	exit
	
	noUninstalled:
		mov 	ax, 0900h
		mov 	dx, offset msg_nouninstalled
		int 	21h
		jmp 	exit
	alreadyOut:
		mov 	ax, 0900h
		mov 	dx, offset msg_alreadyOut
		int 	21h	
		jmp 	exit
kill:
	mov		hardRemove, 1
	jmp 	uninstall		
exit:
	ret

returnHandlers proc	
	mov 	ax, 252fh		
	mov		dx, word ptr es:[int2f_off]
	mov		ds, word ptr es:[int2f_seg]
	int		21h
	
	mov 	ax, 2521h	
	mov		dx, word ptr es:[int21_off]
	mov		ds, word ptr es:[int21_seg]
	int		21h
returnHandlers endp	

consoleRead proc
	mov 	ax, 0
	mov 	cl, ds:[80h]
	cmp 	cl, 3
	jl		readFail
	inc 	cl
	mov		bx, 80h
skipWhitespaces:
	inc 	bx
	dec		cl 
	cmp 	cl, 2
	jl		readFail
	mov 	dl, [bx]
	cmp 	dl, 20h
	je 		skipWhitespaces
	
	cmp 	dl, 2fh ;'/'
	jne 	readFail
	inc 	bx
	mov		dl, [bx]
	dec		cl 
	cmp 	cl, 1
	jl		readFail
	cmp 	dl, 68h ;'h'
	je 		readEnd
	inc		ax
	cmp 	dl, 69h ;'i'
	je 		readEnd
	inc		ax
	cmp 	dl, 75h ;'u'
	je 		readEnd
	inc		ax
	cmp 	dl, 6Bh ;'k'
	jne		readFail	

readEnd: 	
	dec		cl	
	cmp 	cl, 0
	je		readRet
readFail: 
	mov		ax, 4
readRet:
	ret
consoleRead endp

checkLaunched proc
	mov 	isLaunched, 0
	mov 	ax, 0AD2fh
	mov 	bx, 0BD2fh
	int 	2fh
	cmp 	ax, 02fADh
	jne		checkLaunchedExit
	cmp 	bx, 02fBDh
	jne 	checkLaunchedExit
	mov		isLaunched, 1
	push 	es
	pop		tsr_seg	
checkLaunchedExit:
	ret
checkLaunched endp

checkTop proc	
	mov 	cx, tsr_seg
	int 	21h
	cmp 	bx, dx
	jne 	checkTopExit
	push 	es
	pop 	dx
	cmp 	cx, dx
	jne 	checkTopExit
	inc 	onThetop 
checkTopExit:
	ret
checkTop endp

end entry