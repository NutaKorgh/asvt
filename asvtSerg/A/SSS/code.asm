model tiny
.386
.code
org 100h

start:
cld
mov ah, 10
mov dx, offset bufmax
int 21h
cmp bufread,0
je error
mov ah,2
mov dl,10
int 21h

mov ax, 3D00h
mov dx, offset filename
int 21h
jc error
mov filehandle, ax

cikl:
mov cx, hcx
mov dx, hdx
mov ax,4200h
mov bx, filehandle
int 21h
add hdx,1
adc hcx,0

mov bx,filehandle
mov ah,3Fh
xor cx,cx
mov cl,bufread
mov dx,offset fileread
int 21h
jc error
cmp al,bufread
jb EOF

mov si,offset buf
mov di,offset fileread
mov cl, bufread
rep cmpsb
jz found

jmp cikl

found:
mov al,byte ptr hcx+1
call printal
mov al,byte ptr hcx
call printal
mov al,byte ptr hdx+1
call printal
mov al,byte ptr hdx
call printal
mov dl,13
int 21h
mov dl, 10
int 21h
jmp cikl

printal:
push ax
shr al,4	
call printh
pop ax
and al,15
call printh
ret
printh:
cmp al,10
sbb al,69h
das
mov ah,2
mov dl,al
int 21h
ret

error:
mov ah,9
mov dx,offset errm
int 21h
EOF:
mov ah,3Eh
mov bx, filehandle
int 21h
ret

errm db 'error!',13,10,18h
hcx dw 0
hdx dw 0
filehandle dw 0
filename db 'pcidevs0.txt',0
bufmax db 20
bufread db 0
buf db '$$$$$$$$$$$$$$$$$$$$$$';22
fileread:
end start