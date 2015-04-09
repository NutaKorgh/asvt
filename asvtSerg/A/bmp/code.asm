model tiny
.code
org 100h
start:
;
cld
mov si, 80h
mov cl,[si]
test cl, cl
jz def
inc cl
_s:
inc si
dec cl
mov al,[si]
cmp al,20h
jz _s
lea di, file
rep movsb
mov [di], cl

def:
;��������� ���� �� ������
mov ax, 3D00h
lea dx, file
int 21h
jc _err
mov bx,ax

;������ ���� <64�
or cx,0FFFFh
mov ah, 3Fh
lea dx, file
int 21h
mov filesize, ax
jc _err

;��������� ����
mov ah, 3Eh
int 21h
jc _err

;��������� ���������
lea bx, file
mov ax, [bx]
cmp ax, 4D42h
jne _err

;��������� 16 ������
mov ax, [bx+28]
cmp ax, 4
jne _err

;��������� ����������
;mov ax, [bx+30]
;test ax, ax
;jne _err

;�������� ������ � ������
mov dx, [bx+18]
add dx, 7
and dl, 11111000b
mov iwidth, dx
mov dx, [bx+22]

;�������� ����� �������� � �����
add bx, [bx+10]

;������ ���������� �� 13h (320*200)
mov ax, 13h
int 10h

;����� ��������
@2:
	dec dx
	xor cx,cx
	@1:
		cmp dx, 200
		jge _OOR
		cmp cx, 320
		jge _OOR
		mov al, [bx]
		shr al, 4
		mov ah, 0Ch
		int 10h
		inc cx
		mov al, [bx]
		and al, 1111b
		mov ah, 0Ch
		int 10h
		dec cx
	_OOR:
		add cx, 2
		inc bx
		cmp cx,iwidth
		jl @1
	test dx,dx
	jne @2

;��� ����������� ������� ����� �������
xor ax,ax
int 16h

_err:
;���������� 3 �����
mov ax,3
int 10h

;�����
ret

iwidth dw 0
filehandle dw 0
filesize dw 0
file db 'test.bmp',0
end start