.model tiny
.code
org 100h
start:
mov ax,0003h
int 10h

mov ax,1112h
mov bl,0
int 10h

mov ax, 1130h
mov bh,3
int 10h

mov cx,256*8
push cs
push es
pop ds
pop es
mov si,bp
mov di,offset letter
cld
rep movsb

push cs
pop ds
mov bp, offset letter
add bp,33*8
mov cx,144
huj:
shr byte ptr [bp],1
shr byte ptr [bp+1],1
shr byte ptr [bp+2],1
;shr byte ptr [bp+3],1
;shl byte ptr [bp+6],1
shl byte ptr [bp+7],1
add bp,8
loop huj

push cs
pop es
mov ax,1100h
mov cx,255
mov dx, 0
mov bx,0800h
mov bp,offset letter
;add bp,48*8
int 10h

ret
														
lette db 112,80,16,16,28,18,22,28
letter db 255*8 dup (55h);0,0,0,112,80,16,16,28,18,22,28,0,0,0

end start