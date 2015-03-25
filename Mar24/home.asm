	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	
	msg_incorrectKey db 'incorrect key, try /h to show help$'
	msg_help db 'Help:', 10, 13, '	/h - for help', 10, 13, '	/i - for install', 10, 13, '	/u - for soft uninstall', 10, 13, '	/k - for hard uninstall', '$'
	msg_installed db 'installed$'
	msg_alreadyin db 'already installed$'
	msg_uninstalled db 'uninstalled$'
	msg_alreadyun db 'nothing to remove$'
	msg_nouninstalled db 'can not uninstall, cause one of handlers not on the top$'
	msg_killed db 'killed$'
	
	oldint2f label dword
		int2f_off dw 0000h
		int2f_seg dw 0000h
	
	oldint08 label dword
		int08_off dw 0000h
		int08_seg dw 0000h
	
	oldint10 label dword
		int10_off dw 0000h
		int10_seg dw 0000h
		
	oldint21 label dword
		int21_off dw 0000h
		int21_seg dw 0000h
	
newint21 proc	
	jmp 	dword ptr cs:[oldint21]
newint21 endp

newint08 proc	
	jmp 	dword ptr cs:[oldint08]
newint08 endp

newint10 proc	
	jmp 	dword ptr cs:[oldint10]
newint10 endp

newint2f proc
	cmp 	ax, 0AC2fh
	jne 	iExit
	cmp 	bx, 0BC2fh
	jne 	iExit

checked:
	mov 	ax, 02fACh
	mov 	bx, 02fBCh
	push 	cs
	pop 	es	
	iret

iExit: 
	jmp 	dword ptr cs:[oldint2f]
newint2f endp

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
	mov 	ax, 0AC2fh
	mov 	bx, 0BC2fh
	int 	2fh
	cmp 	ax, 02fACh
	jne		tsr
	cmp 	bx, 02fBCh
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
		
		mov		ax, 3510h
		int		21h
		mov		word ptr cs:[int10_off], bx
		mov		word ptr cs:[int10_seg], es
		
		mov 	ax, 2510h	
		mov		dx, offset newint10
		int		21h	
		
		mov		ax, 3508h
		int		21h
		mov		word ptr cs:[int08_off], bx
		mov		word ptr cs:[int08_seg], es
		
		mov 	ax, 2508h	
		mov		dx, offset newint08
		int		21h	
		
		mov 	ax, 0900h
		mov 	dx, offset msg_installed
		int 	21h
		
		mov 	dx, offset start + 1
		int 	27h
		jmp 	exit
	
	already:
		mov 	ax, 0900h
		mov 	dx, offset msg_alreadyin
		int 	21h

uninstall:
	jmp 	exit
kill:
	jmp 	exit
		
exit:
	ret
end entry