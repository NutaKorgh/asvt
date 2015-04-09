	.model tiny
	.code
	org 100h
	.386

entry:
	jmp start
	
start:
mov ax, 0b800h
mov es, ax
mov ax, 3
int 10h
mov ax, 1E01h
mov cx, 255
@1:
stosw
inc al
loop @1
xor ax, ax
int 16h
ret
end entry