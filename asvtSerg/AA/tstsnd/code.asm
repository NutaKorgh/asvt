.model tiny

.286
.code
org 100h
la0 equ 2200
se0 equ 2470
do equ 2616
re equ 2937
mi equ 3296
fa equ 3492
so equ 3920
la equ 4400
se equ 4939
do2 equ 5233
re2 equ 5873
mi2 equ 6593

d8 equ 200
d4 equ 400
start:
mov cx,16
mov di,100
mov si,0
mtk:
mov di,pirat[si]
mov bx,pirat_d[si]
inc si
inc si
call sound
mov bx,5
mov di,65535
call sound
loop mtk
ret

fokt dw 262, 294, 330, 349, 392, 440, 494, 523

tree dw re,se,se,la,se,so,re,re,re,se,se,do2,mi2,re2

pirat dw la0,do,re,re,re,mi,fa,fa,fa,so,mi,mi,re,do,do,re
pirat_d dw d8,d8,d4,d4,d8,d8,d4,d4,d8,d8,d4,d4,d8,d8,d8,d4

sound:
pusha
mov al,0B6h ; 3аписать в регистр режим таймера
out 43h, al
mov dx, 0B6h ; Делитель времени =
mov ax, 10A2h ; 1331000/частота
div di
out 42h, al ; Записать младший байт счетчика таймера 2
mov al, ah
out 42h, al ; 3аписать старший байт счетчика таймера 2
in al, 61h ; Считать текущую установку порта В
mov ah, al ; и сохранить ее в регистре АН
or al, 3 ; Включить динамик
out 61h, al
rp:
mov cx, 2801 ; Выждать 10 мс
on:
loop on
dec bx ; Счетчик длительности исчерпан?
jnz rp ; Нет. Продолжить звучание
mov al, ah ; Да. Восстановить исходную установку порта
out 61h, al
popa
ret
end start