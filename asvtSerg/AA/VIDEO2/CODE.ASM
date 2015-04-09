model tiny
.286
.code
org 100h
start:
mov ah,0Fh
int 10h
mov page_number,bh
mov ah,3
mov cur_pl,dx

mov bh,7
xor cx,cx
mov dh,16h
mov dl,4Fh
mov ax,0600h
int 10h

mov cx,1
mov bh,page_number
xor dx,dx
xor ax,ax
next:
mov ah,2
int 10h

mov ah,10
int 10h

inc ax
inc dx
test dl,10h
jz next
inc dh
xor dl,dl
cmp dx,1000h
je fin
jmp next
fin:
mov ah,2
mov dx,cur_pl
;int 10h
ret
page_number db ?
cur_pl dw ?
end start