model tiny
.code
org 100h
start:
mov dx,offset filename
mov ax,3D00h
int 21h
xchg bx,ax

mov ah,3Fh
mov cx,07FFFh
mov dx,offset readbyte
int 21h
mov filelength,ax

mov ah,3Eh
int 21h

xor bx,bx
mov ah,0Fh
int 10h
;mov videomode,al
;mov pagenumber,bh
shl ax,1
mov columnnumber,ah
shr ax,1

mov cx,100h
cmp al,7
jne next1
mov ts,0B000h

next1:
cmp al,0
je nn
cmp al,1
je nn
jmp next2
nn:mov cx,80h

next2:
mov bl,bh
mov bh,0
xchg ax,cx
mul bx
add ts,ax

mov cx,filelength

xor bx,bx
mov es,ts
xor si,si
mov ah,7
xor dx,dx
mov dl,columnnumber

cikl:
mov al,readbyte[si]
inc si
cmp al,10
jne next4
add bx,dx
mov dl,columnnumber
jmp next3
next4:
cmp al,13
je next3
mov es:[bx],ax
inc bx
inc bx
dec dx
dec dx
cmp al,10
jne next3
add bx,dx
mov dl,columnnumber
next3:
loop cikl

ret
columnnumber db ?
ko dw 1000h
ts dw 0B800h
pagenumber db 0
videomode db ?
filename db 'c:\dos\aa\ship\k1.txt'
filehandle dw ?
filelength dw ?
readbyte db 7FFFh dup(0)
end start