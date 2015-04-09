model tiny
.code
org 100h
start:
mov ax, 3D00h
mov dx, offset filename
int 21h
;jc _err
mov filehandle, ax
mov bx,ax
mov cx,16500
mov ah,3Fh
mov dx, offset filebuf
int 21h
;jc _err
mov ah,3Eh
mov bx, filehandle
int 21h

mov ax,3509h
int 21h
mov tes,es
mov tbx,bx
mov ah,25h
mov dx,offset Int_09h
int 21h

mov ax,13h
int 10h

xor bx,bx
xor cx,cx
mov dx,150
mov cur_offset,offset filebuf

huj1:
	mov bp,cur_offset
	mov al, [bp]
	shr al,4
	mov ah,0Ch
	int 10h
	inc cx
	mov bp,cur_offset
	mov al, [bp]
	and al,1111b
	mov ah,0Ch
	int 10h
	inc cx
	inc cur_offset
	cmp cx,220
	jl huj1
	dec dx
	xor cx,cx
	test dx,dx
	jne huj1

inf:
cmp byte ptr flag, 1
je _out
mov bx,hvost
cmp golova,bx
jz inf
cli
inc hvost
and hvost,7
sti
add bx,offset buffer
mov al,byte ptr [bx]
cmp al,81h
je _out
jmp inf
_out:
mov ax,2509h
mov dx,tbx
push ds
mov ds, tes
int 21h
pop ds
mov ax,3
int 10h
_err:
ret

Int_09h:
     push  ax
     mov ax,golova
     inc ax
     and ax,7
     cmp ax,hvost
     je _iret
     push      bx
     in        al,60h        
     mov  bx,offset buffer
     add bx,golova
     mov byte ptr [bx],al
     pop       bx
     inc golova
     and golova,7
     in        al,61h
     mov       ah,al
     or        al,80h
     out       61h,al
     xchg      ah,al 
     out       61h,al
     mov       al,20h
     out       20h,al
_iret:
     pop ax
     iret

color db 0FFh
cur_color db 3
cur_offset dw 0
flag db 0
filename db 'PIC2.PIC',0
filehandle dw ?
buffer db ?,?,?,?,?,?,?,?
golova dw 0
hvost dw 0
tes dw ?
tbx dw ?
filebuf db ?
end start