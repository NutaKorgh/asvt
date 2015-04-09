model tiny
.386
.code
org 100h
start:
cld
mov si,80h
lodsb
cmp al,0
je _ret
mov cx,9
lodsb
lea di,mynick
_back:
dec cx
jcxz _next
lodsb
stosb
cmp al,13
jne _back
_next:
call Ser_Ini

mov ax,3
int 10h

call sendmsg
mov myformat,'m'

_testtest:
	mov ah,1
	int 16h
	jnz to_out

	call getmsg
	jc _testtest
	lea si,packet
	mov ah,6
	call printmsg
	push cx
	mov ah,7
	lea si, mybuf
	call print
	pop cx
	jmp _testtest
	
	to_out:
		xor ax,ax
		int 16h
		cmp ah,1;escape
		je finish
		cmp ah,1Ch;enter
		jne ne_send
		lea si,mypacket
		mov ah,9
		call printmsg
		call sendmsg

		jmp _testtest
		ne_send:
			cmp cx,255
			je Sound
			stosb
			inc cx
			mov ah,2
			mov dl,al
			int 21h
		jmp _testtest
finish:
mov myformat,'d'
call sendmsg
call Ser_Rst
_ret:
ret

Sound:
pusha
mov bx,4400
mov      ax,10A2h;34DDh
mov      dx,0B6h;12h    ;(dx,ax)=1193181
cmp      dx,bx     ;���� bx < 18��, �� �����
jnb      done      ;����� �������� ������������
div      bx        ;ax=(dx,ax)/bx
mov      bx,ax     ;������� �������
in       al,61h    ;���� ��
or       al,3      ;���������� ���� 0-1
out      61h,al
mov      al,00001011b   ;����������� ����� �������:
mov      dx,43h
out      dx,al     ;����� � ������� ������
dec      dx
mov      al,bl
out      dx,al     ;������� ���� ��������
mov      al,bh
out      dx,al     ;������� ���� ��������
done:
xor cx,cx
dec cx
loop $
popa

No_Sound:
push     ax
in       al,61h    ;���� ��
and      al,not 3  ;����� ����� 0-1
out      61h,al
pop      ax
jmp _testtest

getmsg proc near
	call Get_Chr
	jc _ret
	push di
	push cx
	lea di,packet
	stosb
	mov cx,265
	@1:
	call Get_Chr
	jc @1
	stosb
	loop @1
	pop cx
	pop di
	ret
getmsg endp

printmsg proc near ;from si, nickcolor ah
	push cx
	push ax
	push ax
	push es
	xor bx,bx
	mov es,bx
	mov bx,450h
	mov ax,curpos
	mov word ptr es:[bx],ax
	mov ah,9
	lea dx,spaces
	int 21h
	mov ax,curpos
	mov word ptr es:[bx],ax
	pop es
	
	pop ax
	mov bx,si
	inc si
	mov cx,8
	call print
	
	cmp byte ptr[bx],'m'
	jne _choeto
	
	call gettime
	mov cx,24
	pop ax
	push ax
	push si
		lea si,time
		call print
		mov ah,2
		mov dl,13
		int 21h
		mov dl,10
		int 21h
	pop si
	mov cx,255
	mov ah,7
	call print
printdiv:
	mov ah,9
	lea dx,divider
	int 21h
	pop ax
	pop cx
	push es
	xor bx,bx
	mov es,bx
	mov bx,450h
	mov bx,word ptr es:[bx]
	mov curpos,bx
	pop es	
	ret
_choeto:
	mov ah,9
	cmp byte ptr[bx],'c'
	jne _etodisconect
	lea dx,cmess
	int 21h
	jmp printdiv
_etodisconect:
	lea dx,dmess
	int 21h
	jmp printdiv
printmsg endp

gettime proc near
	push di
	push cx
	lea di,[time+2]
	mov ah,2Ch
	int 21h
	mov al,ch
	call printnum
	mov al,cl
	call printnum
	mov al,dh
	call printnum
	mov ah,2Ah
	int 21h
	mov al,dl
	call printnum
	mov al,dh
	call printnum
	pop cx
	pop di
	ret
gettime endp

print proc near ; cx from si, color ah
	push bx
	push es
	push di
		push si
		push cx
			push ax
				xor bx,bx
				mov es,bx
				mov bx,450h
				mov bx,es:[bx]
				mov al,80
				mul bh
				mov bh,0
				add ax,bx
				shl ax,1
				mov di,ax
				mov bx,0B800h
				mov es,bx
			pop ax 
				@5:
				lodsb
				cmp al,13
				je @6
				stosw
				loop @5
			@6:
			rep lodsb
		pop cx
		pop si
		mov ah,2
		@2:
		mov dl,[si]
		cmp dl,13
		je @4
		int 21h
		inc si
		loop @2
		@4:
		inc si
		loop @4
	pop di
	pop es
	pop bx
	ret
print endp

printnum proc near
	push bx
	mov ah,0
	mov bx,10
	div bl
	add ax,3030h
	stosb
	mov al,ah
	stosb
	inc di
	pop bx
	ret
printnum endp

sendmsg proc near
		mov cx,266
		lea si, mypacket
		@3:
		lodsb
		call Out_Chr
		loop @3
		mov cx,255
		lea di,mybuf
		mov al,13
		rep stosb
		lea di,mybuf
		ret
sendmsg endp

Get_Chr   proc near
          cmp  Count,0   ; ����p ����?
          jne  loc_1729  ; ���
          stc            ; ��, ����p�� �� ������
          ret
loc_1729:
          push si
          cli            ; ���p���� �p�p������
          mov  si,Src_ptr
          sub  si,Count
          cmp  si,offset Source
          jae  loc_1730
          add  si,Buf_Size
loc_1730:
          mov  al,[si]   ; ����p�� ������
          dec  Count     ; � �������� �������
          sti            ; p��p������ �p�p������
          pop  si
          clc            ; � ��p������� ����p��
          ret
Get_Chr   endp

Out_Chr   proc near
          push ax
          push cx
          push dx
          mov  ah,al
          sub  cx,cx
Wait_Line:
          mov  dx,2FDh   ; p�����p ��������� �����
          in   al,dx
          test al,20h    ; ���� ����� � ��p�����?
          jnz  Output    ; ��
          jmp  short $+2
          jmp  short $+2
          loop Wait_Line ; ���, ����
          pop  dx
          pop  cx
          pop  ax
          stc            ; ��� ���������� ��p��
          ret
Output:
          mov  al,ah
          mov  dx,2F8h   ; p�����p ������
          jmp  short $+2
          out  dx,al     ; ������� ������
          pop  dx
          pop  cx
          pop  ax
          clc            ; ��p������� ����p��
          ret
Out_Chr   endp

Ser_Ini   proc near
          push ax        ; ���p����� p�����p�
          push dx
          push bx
          push es
          in   al,21h    ; IMR 1-�� ����p���p� �p�p������
          or   al,8h    ; ���p����� �p�p������ IRQ4 �� COM2
          out  21h,al
          mov  al,0Bh
          mov  ah,35h
          int  21h       ; ����� �����p Int 0Ch � es:bx
          mov  cs:Ser_ip,bx ; � ���p����� ���
          mov  cs:Ser_cs,es
          mov  al,0Bh
          mov  dx,offset Ser_int
          push ds
          mov  bx,cs
          mov  ds,bx
          mov  ah,25h
          int  21h       ; ���������� Int 0Ch = ds:dx
          pop  ds
          pop  es
          pop  bx
          cli            ; ���p����� �p�p������
          in   al,21h    ; IMR 1-�� ����p����p� �p�p������
          and  al,0F7h
          out  21h,al    ; p��p����� �p�p������ �� COM1
          mov  dx,2FBh   ; p�����p ��p������� ������
          in   al,dx
          or   al,80h    ; ���������� ��� DLAB
          out  dx,al
          mov  dx,2F8h
          mov  al,60h
          out  dx,al     ; ������� ���� ��� ���p���� 1200 ���
          inc  dx
          mov  al,0
          out  dx,al     ; ���p��� ���� ���p����
          mov  dx,2FBh   ; p�����p ��p������� ������
          mov  al,00000011b ; 8 ���, 2 ����-����, ��� ��������
          out  dx,al
          mov  dx,2F9h   ; p�����p p��p������ �p�p������
          mov  al,1      ; p��p����� �p�p������ �� �p����
          out  dx,al
          nop            ; � ����-���� ���������
          nop
          mov  dx,2FCh   ; p�����p ��p������� �������
          mov  al,0Bh;00001011b ; ���������� DTR, RTS � OUT2
          out  dx,al
          sti            ; p��p����� �p�p������
          mov  dx,2F8h   ; p�����p ������
          in   al,dx     ; ��p����� ����p �p����
          pop  dx
          pop  ax
          ret
Ser_Ini   endp

Ser_Rst   proc near
          push ax        ; ���p����� p�����p�
          push dx
Wait_Free:
          mov  dx,2FDh   ; p�����p ��������� �����
          in   al,dx
         jmp  short $+2 ; ��p����� ����p���
          test al,60h    ; ��p����� ��������?
          jz   Wait_Free ; ����, ���� ���
          mov  dx,2F9h   ; p�����p p��p������ �p�p������
          mov  al,0      ; ���p����� �p�p������
          out  dx,al
          jmp  short $+2 ; ��� ��������...
          jmp  short $+2

          mov  dx,2FCh   ; p�����p ��p������� �������
          mov  al,00000011b ; ������p����� DTR � RTS
          out  dx,al
          jmp  short $+2
          jmp  short $+2

          push bx
		  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;mov  al,0Bh
          ;mov  dx,cs:Ser_ip
          ;push ds
          ;mov  bx,cs:Ser_cs
          ;mov  ds,bx
          ;mov  ah,25h
          ;int  21h       ; ������������ �����p Int 0Ch
          ;pop  ds
		  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          pop  bx

          cli            ; ���p�� �p�p������
          in   al,21h    ; ������ ����� �p�p������
          jmp  short $+2
          or   al,8h    ; ���p����� IRQ4
          out  21h,al
          sti            ; p��p������ �p�p������
          pop  dx
          pop  ax
          ret
Ser_Rst   endp

Ser_Int   proc far
          push ax
          push dx
          push ds
          mov  dx,2FAh   ; p�����p ������������� �p�p������
          in   al,dx
          mov  Int_Sts,al; ���p���� ��� ����p�����
          test al,1      ; ���� ���������� �p�p������?
          jz   Is_Int    ; ��
          pop  Save_ds   ; ���, ��p����� ��p�������
          pop  dx        ; ���p��� ��p�������� Int 0Ch
          pop  ax
          push Ser_cs
          push Ser_ip
          push Save_ds
          pop  ds
          ret            ; ������� ��p����
Is_Int:
          mov  al,63h    ; ������� EOI ��� IRQ4
          out  20h,al    ; � 1-� ����p����p �p�p������
          test Int_Sts,4 ; �p�p������ �� �p����?
          jnz  Read_Char ; ��
No_Char:
          sti            ; ���, p��p����� �p�p������
          jmp  Int_Ret   ; � ��������� ��p������ Int 0Ch
Read_Char:
          mov  dx,2FDh   ; p�����p ��������� �����
          in   al,dx
          and  al,2
          mov  Overrun,al; ovvrrun<>0, ���� ���� ����p� �������
          mov  dx,2F8h   ; p�����p ������
          in   al,dx     ; ������ ������
          or   al,al     ; ���� �p���� ����,
          jz   No_Char   ; �� ����p�p��� ���
          push bx
          mov  ah,Overrun
          or   ah,ah     ; �p�������� ������ ����p��?
          jz   Save_Char ; ���
          mov  ah,al     ; ��,
          mov  al,7      ; �������� ��� �� ������ (07h)
Save_Char:
          mov  bx,Src_ptr; ������� ������ � ����p
          mov  [bx],al
          inc  Src_ptr   ; � ��������� ��������
          inc  bx
          cmp  bx,offset Src_ptr-2 ; ���� ����� ����p�
          jb   Ser_Int_1
          mov  Src_ptr,offset Source ; �� "�����������" �� ������
Ser_Int_1:
          cmp  Count,Buf_Size ; ����p �����?
          jae  Ser_Int_2 ; ��
          inc  Count     ; ���, ������ ������
Ser_Int_2:
          or   ah,ah     ; ���� ���� ����p� �������
          jz   Ser_Int_3
          mov  al,ah     ; �� ������� � ����p ��� ������
          xor  ah,ah
          jmp  short Save_Char
Ser_Int_3:
          pop  bx
          sti            ; p��p����� �p�p������
Int_Ret:
          pop  ds
          pop  dx
          pop  ax
          iret
Ser_Int   endp

time db ' (00:00:00 00/00/2012)  '
cmess db ' has joined.$',13,10,'$'
dmess db ' leaves.$',13,10,'$'
divider db 13,10,80 dup('_'),'$'
curpos dw ?
spaces db 400 dup(' '),'$'

packet:
format db 'x'
nick db  8 dup (13)
buf db 255 dup (13),13,10,'$'

mypacket:
myformat db 'c'
mynick db  8 dup (13)
mybuf db 255 dup (13),13,10,'$'

Buf_Size  equ  1024           ; p����p ����p�
Source    db   Buf_Size+2 dup (0) ; ����p �p���� ��������
Src_ptr   dw   Source         ; ��������� ������� � ����p�
Count     dw   0              ; ���������� �������� � ����p�
Ser_ip    dw   0              ; ���p�� ��p�� Int 0Ch
Ser_cs    dw   0
Save_ds   dw   0              ; ��������� ��p�������
Int_sts   db   0
Overrun   db   0
end start