model tiny
.code
org 100h
locals
_1:
	jmp start
hhh db 'Hello, TSR',24h
str0 db 'PATH=C:\',0,0,1,0, 'C:\test.com',0
start:
	mov ah,9h
	mov dx,offset hhh
	int 21h

	mov bx,2ch
	mov ax,[bx]
	push ax
	pop es
	mov ah,49h
	int 21h
	
	mov bx,3
	mov ah,48h
	int 21h
	mov bx,2ch
	mov [bx],ax
	push ax
	pop es
	mov di,0
	mov si,offset str0
	mov cx,18h
	rep movsb
	
	mov ax,3100h
	mov dx, 17
	int 21h

end  _1