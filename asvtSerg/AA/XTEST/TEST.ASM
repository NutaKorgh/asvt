model tiny
.code
org 100h

start:
mov bx,1
mov di,hui
mov al,[bx+di]
ret
tmp db 0,1,3,5
hui dw offset tmp
end start