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
cmp dl,93h;��������
jne _next1
_rotrot:
call rotate
jmp _iret
_next1:
cmp dl,50h;����
jne _next2
mov bx,vertmov
neg bx
cmp direction,bx
je _rotrot
neg bx
mov direction,bx
mov speed2,2
_next2:
cmp dl ,4Dh;������
jne _next3
cmp direction,-2
je _rotrot
mov direction,2
mov speed2,2
_next3:
cmp dl ,4Bh;�����
jne _next4
cmp direction,2
je _rotrot
mov direction,-2
mov speed2,2
_next4:
cmp dl ,48h;�����
jne _next5
mov bx, vertmov
cmp direction,bx
je _rotrot
neg bx
mov direction,bx
mov speed2,2
_next5:
cmp dl ,19h;�����
jne _next6
mov speed2,0
_next6:
cmp dl ,4Ah;����������
jne _next7
cmp speed,127
je _next7
inc speed
_next7:
cmp dl ,4Eh;���������
jne _next8
cmp speed,1
je _next8
dec speed
_next8:
cmp dl ,1Eh;���������
jne _next9
call unshrink
_next9:
cmp dl ,2Ch;���������
jne _iret
call shrink
_iret:
pop bx
pop dx
iret
videomodetable db 78,78,158,158,0,0,0,158
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
mov cx,50
mov di,bx
mov ax,0731h
testx:
stosw
add di,bx
loop testx

call new_imba_proc

_inf:
hlt
cmp hod,0
je _inf
mov bx,speed2
add hvost,bx
add head,bx
call paint_head
call new_imba_proc
dec hod
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
add head,2
inc leng
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

paint_head:
push dx
mov bx,oldhead
_paint_head:
cmp bx,head
je _head_painted
mov dx,strlen
mov di, the_snake[bx]
add di, direction
cmp di,-2
jne _noname4
add di,dx
_noname4:
;add dx,pageofs
cmp di,dx
jne _noname5
cmp direction,2
jne _noname5
mov di,rightdown
;add di, pageofs
sub di,4
mov dx,vertmov
neg dx
mov direction,dx
_noname5:
cmp di,0
jge _noname2
add di,rightdown
jmp _noname1
_noname2:
cmp di,rightdown
jl _noname3
sub di,rightdown
_noname3:
mov ax,di
mov dx,vertmov
div dl
cmp ah,byte ptr strlen
jne _noname1
add di,strlen
cmp direction,2
jne _noname1
mov dx,vertmov
sub di,dx
sub di,dx
neg dx
mov direction,dx
_noname1:
inc bx
inc bx
mov the_snake[bx],di
call checkegg
jmp _paint_head
_head_painted:
mov oldhead,bx
pop dx
ret

checkegg:
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