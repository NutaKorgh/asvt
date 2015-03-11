	.model 	tiny
	.code
	org 	100h

_1: 
	jmp 	start	
msg db 'Hello, TSR', 0dh, 0ah, 24h

start:
	mov 	ah, 9
	mov 	dx, offset msg
	int 	21h
; clean
	mov 	ax, cs:[2ch]
	push 	ax
	pop 	es	
	mov 	ah, 49h
	int 	21h
; write	
	mov 	bx, 1
	mov 	ah, 48h
	int 	21h
	mov 	cs:[2ch], ax
	push 	ax
	pop 	es
	mov 	es:[0], '1'
	mov 	es:[1], '2'
	mov 	es:[2], 00h
	mov 	es:[3], 00h
	mov 	es:[4], 01h
	mov 	es:[5], 00h
	mov 	es:[6], 'n'
	mov 	es:[7], 'a'
	mov 	es:[8], 'm'
	mov 	es:[9], 'e'
	mov 	es:[10], '.'
	mov 	es:[11], 'c'
	mov 	es:[12], 'o'
	mov 	es:[13], 'm'
	mov 	es:[14], 0h	
;	
	mov 	ah, 31h
	mov 	dx, 11h
	int 	21h

end _1