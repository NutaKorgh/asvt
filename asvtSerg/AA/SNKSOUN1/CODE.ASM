model tiny
.286
.code
org 100h

c0 equ 1305
cis0 equ 1383
d0 equ 1465
ees0 equ 1552
e0 equ 1644
f0 equ 1742
fis0 equ 1846
g0 equ 1955
as0 equ 2072
a0 equ 2195
b0 equ 2325
h0 equ 2464
 
c equ 2610
cis equ 2765
d equ 2930
ees equ 3104
e equ 3288
f equ 3484
fis equ 3691
g equ 3911
as equ 4143
a equ 4389
b equ 4650
h equ 4927

c1 equ 5220
cis1 equ 5530
d1 equ 5859
ees1 equ 6208
e1 equ 6577
f1 equ 6968
fis1 equ 7382
g1 equ 7821
as1 equ 8286
a1 equ 8779
b1 equ 9301
h1 equ 9854

start:
jmp init

;hex_table db '0123456789ABCDEF'
int_08h:
push ax
push bx
push bp
push di
cmp sound_cont,1
jne neodin
call No_Sound
neodin:
cmp play_music,0
je hui2
cmp sound_cont,0
jne dontstopsnd
add sound_point,2
mov bx,sound_point
cmp bx,musicl
jne dontreset
xor bx,bx
mov sound_point,bx
dontreset:
mov di,musicd_offset
mov bp,[bx+di]
mov sound_cont,bp
mov di,music_offset
mov bx,[bx+di]
cmp eat_flag,0
jne hui
call Sound
;jmp dontdec
dontstopsnd:
dec sound_cont
nothingtodo:
inc timef
mov al,speed
cmp al,timef
jg _jmp08
sub timef,al
inc hod
_jmp08:
pop di
pop bp
pop bx
pop ax
db 0eah
a08 dw ?
b08 dw ?

hui:
dec eat_flag
mov bx,1000
call Sound
jmp dontstopsnd

hui2:
call No_Sound
jmp nothingtodo

play_music dw 0
music_offset dw offset fokt
musicd_offset dw offset fokt_d
musicl dw 32
sound_cont dw 0 ; длительность
sound_point dw -2 ; указатель на ноту
eat_flag dw 0

Int_09h:
push dx
push ax
push bx
in al,60h
mov dx,ax      
in al,61h
mov ah,al
or al,80h
out 61h,al
xchg ah,al
out 61h,al
mov al,20h
out 20h,al
cmp dl,81h
jne _justtest
mov bx,offset _testtest
mov [bx],9090h
_justtest:
cmp dl,93h;разворот
jne _next1
_rotrot:
call rotate
jmp _iret
_next1:
cmp dl,50h;вниз
jne _next2
mov bx,vertmov
neg bx
cmp direction,bx
je _rotrot
neg bx
mov direction,bx
mov speed2,2
_next2:
cmp dl ,4Dh;вправо
jne _next3
cmp direction,-2
je _rotrot
mov direction,2
mov speed2,2
_next3:
cmp dl ,4Bh;влево
jne _next4
cmp direction,2
je _rotrot
mov direction,-2
mov speed2,2
_next4:
cmp dl ,48h;вверх
jne _next5
mov bx, vertmov
cmp direction,bx
je _rotrot
neg bx
mov direction,bx
mov speed2,2
_next5:
cmp dl ,19h;пауза
jne _next6
mov speed2,0
_next6:
cmp dl ,4Ah;замедление
jne _next7
cmp speed,127
je _next7
inc speed
_next7:
cmp dl ,4Eh;ускорение
jne _next8
cmp speed,1
je _next8
dec speed
_next8:
cmp dl ,1Eh;удлинение
jne _next9
call unshrink
_next9:
cmp dl ,2Ch;обрезание
jne _next10
call shrink


_next10:
cmp dl ,15h;включить звук
jne _next11
mov play_music,1
_next11:
cmp dl ,31h;выключить звук
jne _nextA
mov play_music,0
_nextA:
cmp dl ,82h;первая мелодия
jne _nextB
mov bx,fokt_l
mov ax,offset fokt_l
call resetmusic
_nextB:
cmp dl ,84h;вторая мелодия
jne _nextC
mov bx,tree_l
mov ax,offset tree_l
call resetmusic
_nextC:
cmp dl ,85h;вторая мелодия
jne _nextD
mov bx,pirat_l
mov ax,offset pirat_l
call resetmusic
_nextD:
cmp dl ,86h;вторая мелодия
jne _iret
mov bx,march_l
mov ax,offset march_l
call resetmusic
_iret:
pop bx
pop ax
pop dx
iret
videomodetable db 78,78,158,158,0,0,0,158

resetmusic:
mov musicl,bx
add ax,2
mov music_offset,ax
mov musicd_offset,ax
add musicd_offset,bx
mov play_music,1
mov sound_cont, 0
mov sound_point, -2
ret

init:
mov ah,15
int 10h
xor dx,dx
mov dl,bh
cmp al,7
jne wtfwtf2
mov pageofs,0B000h
wtfwtf2:
mov bx, offset videomodetable
xlat
mov byte ptr strlen,al
mov bx,100h
cmp ah,40
jne wtfwtf
mov bx, 80h
wtfwtf:
shl ah,1
mov byte ptr vertmov,ah
mov al,25
mul ah
mov rightdown,ax
xchg ax,dx
mul bx
add pageofs,ax
xor ax,ax
mov es,ax
mov bx,484h
mov al,es:[bx]
cmp al,24
je normscreen
shl rightdown,1
normscreen:



mov ax,3508h
int 21h
mov b08,es
mov a08,bx
mov ax, 2508h
mov dx,offset int_08h
int 21h

mov ax,3509h
int 21h
mov tes,es
mov tbx,bx
mov ax,2509h
mov dx,offset Int_09h
int 21h

mov ax,pageofs
mov es,ax

mov bh,7
xor cx,cx
mov dx,164Fh
mov ax,0600h
int 10h

cld
mov bx,strlen
mov cx,12 ;длина стены
mov di,bx
mov ax,wall_right ; пиксель стены
testx:
stosw
add di,bx
loop testx

mov di, 24*160
mov cx, 40
mov ax, wall_down
rep stosw

call new_imba_proc

_inf:
hlt
cmp hod,0
je _inf
dec hod

mov ax, head
call get_next_step
mov di, ax
mov ax, es:[di]
cmp ax, wall_right
je _is_direction_left1

cmp ax, wall_down
je _is_direction_up1
jmp _move_it

_is_direction_left1:
cmp direction, -2
jne _inf
jmp _move_it

_is_direction_up1:
cmp direction, -160
jne _inf
jmp _move_it

_move_it:
mov bx,speed2
add hvost,bx
add head,bx
call paint_head
call new_imba_proc

_testtest:
jmp _inf



mov ax,2509h
mov dx,tbx
push ds
mov ds, tes
int 21h
pop ds

mov ax,2508h
mov dx,a08
push ds
mov ds, b08
int 21h
pop ds

call No_Sound
ret

shrink:
cmp leng,2
je _ret
add hvost,2
dec leng
ret

unshrink:
push di
	mov ax, head
	call get_next_step
	mov di, ax
	mov ax, es:[di]
	cmp ax, wall_right
	je _is_direction_left
	cmp ax, wall_down
	je _is_direction_up
	jmp _unshrink
_is_direction_left:
	cmp direction, -2
	jne _return_unshrink
	jmp _unshrink
_is_direction_up:
	cmp direction, -160
	jne _return_unshrink
_unshrink:
	add head,2
	inc leng
_return_unshrink:
pop di
call paint_head
call new_imba_proc
ret

new_imba_proc:
mov bx,oldhvost
_remove_hvost:
cmp bx,hvost
je _hvost_removed
mov di, the_snake[bx]
inc bx
inc bx
mov ax,0720h
stosw
jmp _remove_hvost
_hvost_removed:
mov oldhvost,bx
_up:
cmp bx,head
jg _ret
mov di,the_snake[bx]
mov ax,0730h
stosw
inc bx
inc bx
jmp _up
_ret:
ret

get_next_step: ;on_ax
; координаты головы the_snake[ax]
; направление direction
	push bx
	push di
		mov bx, ax
		mov di, the_snake[bx] 
		add di, direction

		cmp di,-2 ; когда мы шли по самой верхней строке влево и вышли за границу экрана
		jne _else11
		add di,vertmov
		jmp _return_get_next_step
	_else11:
		cmp di, rightdown
		jne _else1
		sub di, vertmov
		jmp _return_get_next_step
	_else1:
		cmp di, 0 ; выход вверх
		jge _else2
		add di,rightdown
		jmp _return_get_next_step
	_else2:
		cmp di,rightdown ; выход вниз
		jl _else3
		sub di,rightdown
		jmp _return_get_next_step
	_else3:
		mov ax,di
		mov dx,vertmov
		div dl ; if (ah == 0) был выход вправо и надо вычесть строку
				; if (ah == 158) был выход влево и надо добавить строку
		cmp ah,byte ptr strlen
		jne _else31
		cmp direction, -2
		jne _else31
		add di,vertmov ; вышли за границу экрана влево
	_else31:
		cmp ah, 0
		jne _else4
		cmp direction, 2
		jne _else4
		sub di, vertmov
	_else4:
_return_get_next_step:
	mov ax, di
	pop di
	pop bx
ret

paint_head:
	mov bx,oldhead
	_paint_head:
	cmp bx,head
	je _head_painted

	mov ax, bx
	call get_next_step
	inc bx
	inc bx
	mov the_snake[bx],ax
	call checkegg

	jmp _paint_head
	_head_painted:
	mov oldhead,bx
ret

checkegg:
ret
push bx
mov cx,es:[di]
sub cl,30h
jz _ret1
sub ch,20h
jne _onemore
mov ax,offset unshrink
mov bx,20000
call Sound
jmp _mloop
_onemore:
sub ch,20h
jne _ret1
mov ax,offset shrink
mov bx,40000
call Sound
_mloop:
call ax
loop _mloop
_ret1:
pop bx
ret

rotate:
mov si,head
mov di,hvost
mov cx,the_snake[di]
sub cx,the_snake[di+2]
mov direction,cx
mov cx,leng
shr cx,1
_y:
xchg ax,the_snake[si]
xchg ax,the_snake[di]
xchg ax,the_snake[si]
sub si,2
add di,2
loop _y
mov speed2,2
ret

Sound:
pusha
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
popa
ret

No_Sound:
push     ax
in       al,61h    ;порт РВ
and      al,not 3  ;сброс битов 0-1
out      61h,al
pop      ax
ret

fokt_l dw 32
fokt dw c,d,ees,f,g,as,h,c1,h,as,g,f,ees,d,c,c
fokt_d dw 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5

tree_l dw 56
tree dw d,h,h,a,h,g,d,d,d,h,h,c1,e1,d1,d1,e,e,c1,c1,h,a,g,d,h,h,a,h,g
tree_d dw 5,5,5,5,5,5,5,5,5,5,5,5,5,13,5,5,5,5,5,5,5,5,5,5,5,5,5,13

pirat_l dw 132
pirat dw a0,c,d,d,d,e,f,f,f,g,e,e,d,c,c,d,0,a0,c,d,d,d,e,f,f,f,g,e,e,d,c,d,0,a0,c,d,d,d,f,g,g,g,a,b,b,a,g,a,d,0,d,e,f,f,g,a,d,0,d,f,e,e,f,d,e,0
pirat_d dw 3,3,5,5,3,3,5,5,3,3,5,5,3,3,3,3,5,3,3,5,5,3,3,5,5,3,3,5,5,3,3,5,5,3,3,5,5,3,3,5,5,3,3,5,5,3,3,3,3,5,3,3,5,5,5,3,3,5,3,3,5,5,3,3,5,5

march_l dw 88
march dw g,g,g,ees,b,g,ees,b,g,d1,d1,d1,ees1,b,fis,ees,b,g,g1,g,g,g,fis1,f1,e1,ees1,e1,0,as,cis1,c1,h,b,a,b,0,ees,fis,ees,b,g,ees,b,g
march_d dw 9,9,9,7,3,9,7,3,17,9,9,9,7,3,9,7,3,17,9,7,3,9,7,3,3,3,5,5,5,9,7,3,3,3,5,5,5,9,7,3,9,7,3,17

pageofs dw 0B800h
strlen dw 158
vertmov dw 160
rightdown dw 160*25

wall_right dw 3420h
wall_down dw 4020h

tes dw ?
tbx dw ?
hod dw 0
leng dw 3
direction dw 2
timef db 0
pausef db 0
speed db 8
speed2 dw 2
head dw 4
hvost dw 0
oldhead dw 4
oldhvost dw 0
the_snake dw 0,2,4
end start