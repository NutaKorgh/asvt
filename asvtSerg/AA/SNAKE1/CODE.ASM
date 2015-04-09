model tiny
.code
org 100h
start:
jmp init

;hex_table db '0123456789ABCDEF'
int_08h:
push ax
inc timef
mov al,speed
cmp al,timef
jg _jmp08
sub timef,al
inc hod
_jmp08:
pop ax
db 0eah
a08 dw ?
b08 dw ?

Int_09h:
push dx
push ax
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
pop ax
push bx
;do smth
cmp dl,81h
jne _justtest
mov bx,offset _testtest
mov [bx],9090h
;mov byte ptr[bx+2],90h
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
cmp speed,20
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
jne _iret
call shrink
_iret:
pop bx
pop dx
iret
videomodetable db 78,78,158,158,0,0,0,158
init:
mov ah,15
int 10h   ; Get video mode (al = mode, ah = width, bh = page number)
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
int 10h ; очистка экрана

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
mov cx,es:[di]
sub cl,30h
jz _ret1
sub ch,20h
jne _onemore
mov ax,offset unshrink
jmp _mloop
_onemore:
sub ch,20h
jne _ret1
mov ax,offset shrink
_mloop:
call ax
loop _mloop
_ret1:
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