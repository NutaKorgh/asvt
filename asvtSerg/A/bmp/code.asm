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
;открываем файл на чтение
mov ax, 3D00h
lea dx, file
int 21h
jc _err
mov bx,ax

;читаем файл <64К
or cx,0FFFFh
mov ah, 3Fh
lea dx, file
int 21h
mov filesize, ax
jc _err

;закрываем файл
mov ah, 3Eh
int 21h
jc _err

;проверяем сигнатуру
lea bx, file
mov ax, [bx]
cmp ax, 4D42h
jne _err

;проверяем 16 цветов
mov ax, [bx+28]
cmp ax, 4
jne _err

;проверяем компрессию
;mov ax, [bx+30]
;test ax, ax
;jne _err

;получаем ширину и высоту
mov dx, [bx+18]
add dx, 7
and dl, 11111000b
mov iwidth, dx
mov dx, [bx+22]

;получаем адрес картинки в файле
add bx, [bx+10]

;меняем видеорежим на 13h (320*200)
mov ax, 13h
int 10h

;вывод картинки
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

;для продолжения нажмите любую клавишу
xor ax,ax
int 16h

_err:
;возвращаем 3 режим
mov ax,3
int 10h

;выход
ret

iwidth dw 0
filehandle dw 0
filesize dw 0
file db 'test.bmp',0
end start