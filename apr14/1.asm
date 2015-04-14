	model tiny
	.code
	org 100h

start:
	mov 	ax, 3509h
	int 	21h
	mov 	tes, es
	mov 	tbx, bx
	mov 	ah, 25h
	mov 	dx, offset Int_09h
	int 	21h

inf:
	mov 	bx, hvost
	cmp 	golova, bx
	jz 		inf
	cli
	inc 	hvost
	and 	hvost, 7
	sti
	add 	bx, offset buffer
	mov 	al, byte ptr [bx]
	call 	print
	cmp 	al, 81h
	je 		_out
	cmp 	al, 0B9h
	jne 	inf
	mov 	dx, offset lines
	mov 	ah, 9
	int 	21h
	jmp 	inf

_out:
	mov 	ax, 2509h
	mov 	dx, tbx
	push 	ds
	mov 	ds, tes
	int 	21h
	pop 	ds
	ret

print:
	push 	ax
	push 	ax
	shr 	al, 4
	call 	printh
	
	pop		ax
	and 	al, 0fh
	call 	printh
	
	mov 	dl, 13
	int 	21h
	mov		dl, 10
	int 	21h
	pop 	ax
	ret
	
printh:
	cmp		al, 10
	sbb		al, 69h
	das
	mov 	ah, 2
	mov		dl, al	
	int 	21h	
	ret
	
Int_09h:
    push	ax
    mov 	ax, golova
    inc 	ax
    and 	ax, 7
    cmp 	ax, hvost
    je 		_iret

    push    bx
    in      al, 60h        
    mov  	bx, offset buffer
    add 	bx, golova
    mov 	byte ptr [bx], al
    pop     bx

    inc 	golova
    and 	golova, 7

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

golova dw 0
hvost dw 0
lines db '---------',13,10,'$'
tes dw ?
tbx dw ?
buffer db 8 dup(?)
end start