model tiny
.code

org 100h
start:
	mov ah,9
	mov dx,offset str0
	int 21h
	ret
str0 db 'Hello, world!!',13,10,'$'
end start