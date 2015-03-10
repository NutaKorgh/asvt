.model tiny

.386

.code

org 100h

Start:

jmp Begin

Flag DB 0 ;0, если обработчик выполняется в 1 раз

ScrBuf DB 32 dup(0) ;Буфер для сохранения экрана

Xpos DW (10*80+36)*2+1-60 ;Текущее положение на экране

DB 'XOBR' ;Метка резидента(для проверки присутствия)

old_int DD 0 ;Вектор старого обработчика

Resident:

pushf ;Сохраняем флаги

pusha ;и все регистра общего назначения

push es

push ds

push cs

pop ds ;DS = CS

mov ax, 40h ;ES->область данных BIOS

mov es, ax

cmp byte ptr es:[49h], 3 ;Видео режим 3?

jnz ExitTSR ;Если нет - выход

mov ax, 0b800h ;Видео сегмент

mov es, ax

cmp Flag, 0

jz FirstStart

;Восстанавливаем предыдущую область

mov di, XPos ;ES:BX->адрес дыры в видео памяти

mov si, offset ScrBuf

mov cx, 4

RestoreRow:

push cx

mov cx, 8

RestoreCol:

mov al, [si]

inc si

mov es:[di], al

add di, 2

loop RestoreCol

add di, 144

pop cx

loop RestoreRow

;Перемещаем 'дыру' вправо

mov ax, XPos

add ax, 2

cmp ax, (10*80+36)*2+1+60 ;Если достигла края - возвращаем

jne @F ;на начало

mov ax, (10*80+36)*2+1-60

@F:

mov XPos, ax

FirstStart:

mov Flag, 1

;Сохраняем область экрана и рисуем в ней квадрат

mov di, XPos

mov si, offset ScrBuf

mov cx, 4 ;4 строки

NextRow:

push cx ;Сохраняем CX

mov cx, 8 ;8 столбцов

NextCol:

mov al, es:[di] ;

mov [si], al ;Сохраняем область, в которую будем рисовать

inc si ;

mov byte ptr es:[di], 0 ;Атрибут "черный символ на красном фоне"

add di, 2 ;Пропускаем символ

loop NextCol ;Следующий столбец

add di, 144 ;Строка ниже

pop cx ;Восстанавливаем CX

loop NextRow ;Следующая строка

ExitTSR:

pop ds

pop es ;Восстанавливаем регистры

popa

popf ;Восстанавливаем флаги

jmp dword ptr cs:[old_int] ;Переходим на старый обработчик

EndResident EQU $

Begin:

lea dx, sMsg1

mov bx, 81h ;CS:[BX] = командная строка

ReadCMD:

mov al, ds:[bx] ;Читаем командную строку

inc bx

cmp al, 'i'

jz InstallTSR

cmp al, 'u'

jz UninstallTSR

cmp al, 32

jz ReadCMD

jmp ExitProg

InstallTSR:

lea dx, sMsg3

mov ax, 351ch ;Получаем вектор на 1ch прерывание

int 21h

cmp dword ptr es:[bx-4-4], 'RBOX' ;Проверяем наличие резидента в памяти

jz ExitProg ;Выходим, если был установлен ранее

mov word ptr [old_int], bx ;Сохраняем старый вектор

mov word ptr [old_int+2], es ;

mov dx, offset Resident ;DS:DX = адрес нового обработчика

mov ax, 251ch ;Устанавливаем новый вектор

int 21h

lea dx, sMsg2 ;Выводим сообщение об успешной установке

mov ah, 9

int 21h

lea dx, EndResident ;Оставить обработчик и выйти из программы

int 27h

UninstallTSR:

lea dx, sMsg5

mov ax, 351ch

int 21h ;ES:BX = вектор 1ch прерывания

cmp dword ptr es:[bx-4-4], 'RBOX' ;Проверяем присутствие резидента в памяти

jnz ExitProg ;Выходим, если не установлен

push ds

lds dx, es:[bx-4] ;DS:DX = old_int

mov ax, 251ch

int 21h ;Восстановим старый вектор

pop ds

mov ah, 49h ;Освободить память, занимаемую TSR

int 21h

lea dx, sMsg4

ExitProg:

mov ah, 9 ;Вывод сообщения на экран

int 21h

ret ;Выход из программы

sMsg1 DB "Параметры командной строки:",13,10

DB "i - установить резидент",13,10

DB "u - удалить резидент",13,10,"$"

sMsg2 DB "Succes.","$"

sMsg3 DB "already there.","$"

sMsg4 DB "Резиден был выгружен.","$"

sMsg5 DB "Резидент не установлен.","$"

END Start