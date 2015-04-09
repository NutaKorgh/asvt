.model tiny
.code
org 100h

start:

mov ax,0003h
int 10h


mov ax,1100h
mov cx,1
mov dx, 65
mov bx,0E00h
mov bp,offset letter
int 10h

ret

letter db 0,0,0,112,80,16,16,28,18,22,28,0,0,0
end start