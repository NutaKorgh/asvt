model tiny
.code
org 100h
locals
_1:
	xor dx,dx
	xor ax,ax
	mov si, 80h
	lodsb
	cmp ax,5
	jne err
	mov cx,4
	lodsb
h:	lodsb
	sub al,30h
	js err
	cmp al,10
	jl n
	sub al,7
	cmp al,10
	jl err
	cmp al,15
	jg err
n:
	shl dx,4
	or dl,al
	loop h
	push dx
	pop es
	mov ah,49h
	int 21h
	ret
err:
	mov dx, offset st
	mov ah,9
	int 21h
	ret
st db 'err',13,10,24h
end  _1