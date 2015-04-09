model tiny
.286
.code
org 100h
start:
	mov si,80h
	cld
	mov ax,8
	mov bx,ax
	mov di,ax
	lodsb
	mov cx,ax
read:
	jcxz check
	lodsb
	dec cx
	cmp al,' '
	je read
	sub al,'0'
	test al,11111000b
	jnz wrong_args
	cmp bx,8
	jne wrong_args
	cmp di,8
	jne page_number
video_mode:	
	xchg ax,di
	jmp read
page_number:
	xchg ax,bx
	jmp read
wrong_args:
	mov ah,9
	mov dx,offset errmsg
	int 21h
	ret
check:
	cmp bx,8
	je wrong_args
	mov ax,di
	shl di,3
	test byte ptr allowed[bx][di],1
	jz wrong_args
main:
	int 10h
	
	mov ah,5
	mov  al,bl
	int 10h

	;mov ah,3
	;mov bh,bl	
	;int 10h
	;push dx
	
	;mov ah, 0Fh
	;int 10h
	
	;mov dh,18h
	;mov dl,ah
	;dec dx
	;mov ah,2
	;int 10h

	;mov ah,0Ah
	;push ax
	;mov al,bh
	;add al,'0'
	;mov cx,1	
	;int 10h

	;dec dx
	;dec dx
	;mov ah,2
	;int 10h

	;pop ax
	;add al,'0'	
	;int 10h
	
	;mov ah,2
	;pop dx
	;int 10h

ret
errmsg db 'Wrong arguments!',13,10,'$'
allowed:
db 1,1,1,1,1,1,1,1
db 1,1,1,1,1,1,1,1
db 1,1,1,1,0,0,0,0
db 1,1,1,1,0,0,0,0
db 0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0
db 1,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0
end start