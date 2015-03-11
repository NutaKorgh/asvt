	.model 	tiny
	.code
	org 	100h
	.386
	
entry:
	jmp 	start
	
start:
	mov		bx, cs		
	mov		cx, 4
@loop:
	rol		bx, 4
	mov 	al, bl
	and 	al, 0fh
	cmp		al, 0Ah
	sbb		al, 105
	das
	mov		dh, 02h
	xchg	ax, dx
	int		21h
	loop	@loop	
	ret
	
end entry
