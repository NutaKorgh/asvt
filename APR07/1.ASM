	.model tiny
	.code
	org 100h
	.386

entry:
	jmp		start		
	OurFont	db	00000000b
			db	00000000b
			db	00011011b
			db	00110011b
			db	01100011b
			db	01100011b
			db	01100011b
			db	01100011b
			db	01100011b
			db	00100010b
			db	00011100b
			db	00001000b
			db	00000000b
			db	00000000b
start:		
	push	ds			
	pop		es			
	mov		bp, offset OurFont
	mov		cx, 01		
	mov		dx, 56h
	mov		bh, 14
	xor		bl, bl
	mov		ax, 1100h
	int		10h	
exit:	
	ret
	
end entry