model tiny
.code
org 100h
start:
mov ah,0Fh
int 10h
mov pagenumber,bh
shl ax,1
mov swidth, ah


mov bx,0B800h
mov es,bx
xor di,di

mov dx,07CDh
mov ax, 07C9h
stosw
xchg dx,ax
stosw
xchg dx,ax
mov al,0D1h
stosw
xchg dx,ax
mov cx,33
rep stosw
mov al,0BBh
stosw

mov cl,swidth
add newline,cx
mov di,newline
dec ax
stosw

mov al,20h
stosw
xchg ax,dx
mov al,0B3h
stosw
xchg ax,dx
stosw
mov cx,10
mov dl,30h
call func
mov cx,6
mov dl,41h
call func
ret

func:
xchg ax,dx
stosw
inc ax
xchg ax,dx
stosw
loop func
ret

pagenumber db ?
swidth db ?
newline dw 0
end start