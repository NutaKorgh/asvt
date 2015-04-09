model tiny
.code
org 100h
start:
mov bx,4389
call Sound
mov ax,0
int 16h
call No_Sound
ret

Sound:
mov      ax,10A2h;34DDh
mov      dx,0B6h;12h    ;(dx,ax)=1193181
cmp      dx,bx     ;если bx < 18Гц, то выход
jnb      done      ;чтобы избежать переполнения
div      bx        ;ax=(dx,ax)/bx
mov      bx,ax     ;счетчик таймера
in       al,61h    ;порт РВ
or       al,3      ;установить биты 0-1
out      61h,al
mov      al,00001011b   ;управляющее слово таймера:
mov      dx,43h
out      dx,al     ;вывод в регистр режима
dec      dx
mov      al,bl
out      dx,al     ;младший байт счетчика
mov      al,bh
out      dx,al     ;старший байт счетчика
done:
ret

No_Sound:
push     ax
in       al,61h    ;порт РВ
and      al,not 3  ;сброс битов 0-1
out      61h,al
pop      ax
ret

end start