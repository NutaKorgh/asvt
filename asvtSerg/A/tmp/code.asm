model tiny
.code
org 100h
start:
	mov ax, 13h
	int 10h
	push es
		mov ax, 0
		mov es, ax
		
		mov bx, 450h
		mov word ptr es:[bx], 1000h
		xor ax, ax
		int 16h
		mov ah, 9
		lea dx, text
		int 21h
		xor ax, ax
		int 16h
	pop es
	ret
	text db '012345678901234567890123456789012345678901234567890$'
end start