.model tiny
.486
.code
org 100h
start:
	call init
		
	try:
	call getmsg
	cmp fsecflag, 1
	je _sad;пичалька
_K:	cmp Aoutflag, 1
	jl _nosec
	mov Aoutflag, 0
	mov al, 'A'
	call Out_Chr
_nosec:
	
	mov ah, 1
	int 16h
	jz try
	xor ax, ax
	int 16h
	cmp ah, 1
	jz _exit
	cmp ah, 58h
	jz try_new_game
	cmp ah, 1Ch
	jz sendchat
_printchar:
	cmp meslen, 20
	jge try
	push es
	push bx
		mov dl, al
		mov ax, 0
		mov es, ax
		mov bx, 450h
		mov ax, 1200h
		add ax, meslen
		mov word ptr es:[bx], ax
		mov bx, meslen
		mov mytext[bx], dl
		mov ah, 2
		int 21h
		inc meslen
	pop bx
	pop es
	jmp try
	meslen dw 0
	
try_new_game:
	mov al, 'E'
	call Out_Chr
	mov my_new_game_sig, 1
	cmp op_new_game_sig, 1
	jne try
	call newgame
	jmp try
	
sendchat:
	mov cx, 10
	mov ax, meslen
	div cl
	add ax, 3030h
	mov byte1, al
	mov byte2, ah
	xor si, si
	mov cx, meslen
	add cx, 9
_tr:mov al, mynick[si]
	call Out_Chr
	inc si
	loop _tr
	mov meslen, 0
	lea dx, spaces
	push es
	push bx
		mov ax, 0
		mov es, ax
		mov bx, 450h
		mov word ptr es:[bx], 1200h
		mov ah, 9
		int 21h
	pop bx
	pop es
	jmp try
	mynick db 'N03SUPG'
	byte1 db ?
	byte2 db ?
	mytext db 24 dup (0)
_exit:
	call reset
	ret
	
_sad:
	mov fsecflag, 0
	lea dx, nobodyheretext
	call print 
	mov myB, -1
	mov opB, -1
	jmp _K
op_new_game_sig db 0
my_new_game_sig db 0
stopgame db 0

print proc near
	;dx - ссылка на текст
	push es
	push bx
		mov ax, 0
		mov es, ax
		mov bx, 450h
		mov word ptr es:[bx], 1000h
		mov ah, 9
		int 21h
		lea dx, spaces
		int 21h
	pop bx
	pop es
	ret
;	text db 100 dup(' '), '$'
	nobodyheretext db 'Nobody here :($'
	youwin db 'Game over! You win!$'
	youlose db 'Game over! You lose!$'
	whitemove db 'White turn$'
	blackmove db 'Black turn$'
	newgametext db 'Press E to start New Game.$'
	vsehuevo db 'Protocol error$'
	spaces db 35 dup (' '), '$'
print endp

printchat proc near
	;dx - ссылка на текст
	push es
	push bx
		mov ax, 0
		mov es, ax
		mov bx, 450h
		mov ah, 9
		mov word ptr es:[bx], 10h
		lea dx, space24
		int 21h
		mov word ptr es:[bx], 10h
		lea dx, nick
		int 21h
		mov word ptr es:[bx], 110h
		lea dx, space24
		int 21h
		lea dx, text
		mov word ptr es:[bx], 110h
		int 21h
	pop bx
	pop es
	ret
	text db 20 dup(' '), '$'
	nick db	'Player1$' ;24 dup(' '), '$'
	space24 db 23 dup (' '), '$'
printchat endp

newgame proc near
	xor rotate_flag, 1
	mov op_new_game_sig, 0
	mov my_new_game_sig, 0
	mov stopgame, 0
	mov al, rotate_flag
	inc ax
	mov turn, al
	lea dx, whitemove
	call print
	call board
	mov curPlayer, 1
	call get_posible
	call repaint
	ret
newgame endp

init proc near
	call Ser_Ini
	cld
	mov ax,13h
	int 10h
	
	mov ax, 3508h
	int 21h
	mov b08, es
	mov a08, bx
	mov ax, 2508h
	mov dx, offset int_08h
	int 21h
	
	xor ax,ax
	int 33h
	inc ax
	inc ax
	int 33h
	mov cx,0000000000000010b
	push cs
	pop es
	mov dx,offset mouse
	mov ax,0Ch
	int 33h
	
	ret
init endp 

repaint proc near
	lea bx, black_fields
	mov cx, 32
	mov colors, 0
@9:	mov dl, byte ptr [bx]
	inc bx
	push cx
	call light
	pop cx
	loop @9
	ret
	black_fields db 1, 3, 5, 7, 8, 10, 12, 14, 17, 19, 21, 23, 24, 26, 28, 30, 33, 35, 37, 39, 40, 42, 44, 46, 49, 51, 53, 55, 56, 58, 60, 62
repaint endp

board proc near
	mov ax,2
	int 33h
	push es
		mov ax, 0A000h
		mov es, ax
		xor di, di
		xor eax, eax
		mov dx, 128
	@2:
		mov cx, 8
	@1:
		xor eax, 07070707h
		stosd
		stosd
		stosd
		stosd
		loop @1
		add di, 192
		dec dx
		test dx, 15
		jne @2
		xor eax, 07070707h
		test dx, dx
		jne @2
	pop es
	mov ax, 1
	int 33h
	mov cx, 16
	lea si, scb
	lea di, tcb
	rep movsd
	mov cx, 16
	lea si, scb
	lea di, cb
	rep movsd
	ret
scb:
	db 0, 2, 0, 2, 0, 2, 0, 2
	db 2, 0, 2, 0, 2, 0, 2, 0
	db 0, 2, 0, 2, 0, 2, 0, 2
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 1, 0, 1, 0, 1, 0, 1, 0
	db 0, 1, 0, 1, 0, 1, 0, 1
	db 1, 0, 1, 0, 1, 0, 1, 0
board endp

piece proc near ;dx - (00yyyxxx), ah - фон, al - цвет
	push es
		push ax
			push ax
				mov ax, 2
				int 33h
				
				push dx
					cmp rotate_flag, 0
					je _I
					neg dx
					add dx, 63
					
				_I:	mov ax, dx
					shl ax, 5
					shr al, 5
					mov dh, ah
					shl ax, 2
					add ah, dh
					shl ax, 2
					mov di, ax
				pop dx
				
				mov ax, 0A000h
				mov es, ax
			pop ax
			push di
				mov al, ah
				push ax
				shl eax, 16
				pop ax
				mov cl, 16
			@3:
				stosd
				stosd
				stosd
				stosd
				add di, 304
				loop @3
			pop di
		pop ax
		mov ah, al
		xor si, si
		add di, 967
	next:
		mov cx, len[si]
		rep stosw
		add di, 320
		sub di, len[si]
		inc si
		inc si
		sub di, len[si]
		cmp si, 20
		jl next	
	pop es
	mov ax, 1
	int 33h
	ret
	len dw 1, 3, 4, 4, 5, 5, 4, 4, 3, 1,-952	
piece endp

reset proc near
	push es
	mov cx, 0
	mov ax, 0Ch
	mov es, cx
	int 33h
	pop es
	
	mov ax, 2508h
	mov dx, a08
	push ds
	mov ds, b08
	int 21h
	pop ds
	
	mov ax, 3
	int 10h
	
	call Ser_Rst
	ret
reset endp

get_posible proc near ;si=[bx]=i-длина пути, bx[si] - предпоследняя клетка пути, dx=bx[si+2] - последняя клетка пути
	xor ax, ax
	mov cx, 16
	lea di, posible
	rep stosb
	mov cl, curPlayer
	lea di, posible
	cmp byte ptr [i], 0
	jne _not_initial
	
	mov goodrez, 2
_scan_board:
	xor bx, bx
	_next_field:
		and cl, 3
		inc bx
		cmp bx, 64
		je _end_of_scan
		test cl, byte ptr tcb[bx]
		je _next_field
		
		test byte ptr tcb[bx], 4
		je _ne_damka
		or cl, 4
		xor si, si
	_9:	cmp si, 4
		je _next_field
		push bx
		push si
			movsx si, byte ptr directions[si]
			call can_capture
			cmp al, 1
			jne _7
		_8:	add bx, si
			call can_capture
			cmp al, 2
			je _7
			cmp al, 1
			je _8
			mov al, 1
	_7:	pop si
		pop bx
		inc si
		cmp al, goodrez
		je _found
	jmp _9		
_ne_damka:
		xor si, si
	_1:	cmp si, 4
		je _next_field
		push si
			movsx si, byte ptr directions[si]
			call can_capture
		pop si
		inc si
		cmp al, goodrez
		je _found
	jmp _1
_end_of_scan:
	cmp di, offset posible
	jg _ret
	dec goodrez
	cmp goodrez, 0
	jne _scan_board
	ret
_found:
	mov ax, bx
	stosb
	jmp _next_field
	
_not_initial:
	mov bx, dx
	
	test byte ptr tcb[bx], 4
	je _ne_damka1
	or cl, 4
	xor si, si
	cmp goodrez, 1
	jne _damka_rubit
	
_6:	mov bx, dx
	push si
		movsx si, byte ptr directions[si]
	_A:	call can_capture
		cmp al, 1
		jne _B
		mov ax, bp
		stosb
		add bx, si
		jmp _A
_B:	pop si
	inc si
	cmp si, 4
	jne _6
	ret
	
_damka_rubit:
_0:	mov bx, dx
	push si
		movsx si, byte ptr directions[si]
	_D:	call can_capture
		add bx, si
		cmp al, 1
		je _D
		cmp al, 2
		jne _E
		
	_C:	call can_capture
		add bx, si
		cmp al, 1
		jne _E
		mov ax, bp
		stosb
		jmp _C
_E:	pop si
	inc si
	cmp si, 4
	jne _0
	ret

_ne_damka1:
	xor si, si
_2:	cmp si, 4
	je _3
	push si
		movsx si, byte ptr directions[si]
		call can_capture ;bp
	pop si
	inc si
	cmp al, goodrez
	jne _2
	mov ax, bp
	stosb
	jmp _2
_3:	ret
	
	directions db -7, -9, 7, 9
	posible db 16 dup (0)
	tcb:
	db 0, 2, 0, 2, 0, 2, 0, 2
	db 2, 0, 2, 0, 2, 0, 2, 0
	db 0, 2, 0, 2, 0, 2, 0, 2
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 1, 0, 1, 0, 1, 0, 1, 0
	db 0, 1, 0, 1, 0, 1, 0, 1
	db 1, 0, 1, 0, 1, 0, 1, 0
get_posible endp

click proc near ;dx - (00000000 00yyyxxx), x+y - нечетное
	lea bx, i
	movzx si, byte ptr [bx]
	cmp byte ptr bx[si], dl
	;je _backspace

	lea di, posible
	mov al, dl
	mov cl, 16
	repne scasb
	jnz _ret
		
	add byte ptr [bx], 1
	mov byte ptr bx[si+1], dl
	;si=[bx]-длина пути, bx[si] - предпоследняя клетка пути, dx=bx[si+2] - последняя клетка пути
	cmp byte ptr [bx], 2
	jl _no_mov_yet
	cmp goodrez, 1
	je _moving
	;вот здесь будет код, обрабатывающий рубку, а сейчас спать пора
	
	push bx
		movzx bx, byte ptr bx[si]
		test byte ptr tcb[bx], 4 
	pop bx
	jne _damka_srubila
	
	push bx
		movzx bx, byte ptr bx[si]
		xor ax, ax
		mov al, byte ptr tcb[bx]
		mov byte ptr tcb[bx], ah
		add bx, dx
		shr bx, 1
		mov byte ptr tcb[bx], ah
		mov bx, dx
		mov byte ptr tcb[bx], al
	pop bx
	
_after_capture:
	call get_posible
	cmp di, offset posible
	jne _no_mov_yet
	
	
	lea si, tcb
	lea di, cb
	mov cx, 16
	rep movsd
_prepare_next_move:
	xor curPlayer, 3
	cmp turn, 1
	jne _L
	call sendmoving
_L:	xor turn, 3
	mov byte ptr [i], 0
	call repaint
	call get_posible
	cmp di, offset posible
	je happyend
	lea dx, whitemove
	cmp curPlayer, 1
	je _wp
	lea dx, blackmove
_wp:call print
	ret
happyend:
	lea dx, youwin
	cmp turn, 1
	je _iwin
	lea dx, youlose
	_iwin:
	call print
	ret

_damka_srubila:
	movzx ax, byte ptr bx[si]
	sub ax, dx
	mov cl, 7
	idiv cl
	test ah, ah
	mov cx, 7
	je _5
	mov cx, 9
_5:	test al, 128
	jne _F
	neg cx
_F:	push bx
		movzx bx, byte ptr bx[si]
		xor ax, ax
		mov al, byte ptr tcb[bx]

	_H:	mov byte ptr tcb[bx], ah
		add bx, cx
		cmp bx, dx
		jne _H
		mov byte ptr tcb[bx], al
	pop bx
	jmp _after_capture
	
_no_mov_yet:
	call get_posible
	mov byte ptr colors, 5
	call light
;		mov byte ptr colors, 10
;		lea si, posible
;	_t:	lodsb
;		cmp al, 0
;		je _ret
;		mov dl, al
;		call light
;		jmp _t
	jmp _ret
_backspace:
	;mov byte ptr bx[si], 0 ;наверно не нужно
	sub byte ptr [bx], 1
	mov byte ptr colors, 0
	call light
	mov dl, byte ptr bx[si-1]
	call get_posible
	jmp _ret
_ret:
	ret
_moving:
	mov byte ptr [colors], 0
	push bx
		movzx bx, byte ptr bx[si]
		xor ax, ax
		mov al, byte ptr cb[bx]
		mov byte ptr cb[bx], ah
		mov bx, dx
		test dx, 111000b
		je @4
		cmp dx, 56
		jl @5
	@4:	or al, 4
	@5:	mov byte ptr cb[bx], al
		call light
	pop bx
	mov dl, byte ptr bx[si]
	call light
	lea si, cb
	lea di, tcb
	mov cx, 16
	rep movsd
	jmp _prepare_next_move
	i db 0
	way db 31 dup (0)
cb:
	db 0, 2, 0, 2, 0, 2, 0, 2
	db 2, 0, 2, 0, 2, 0, 2, 0
	db 0, 2, 0, 2, 0, 2, 0, 2
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 0, 0, 0, 0, 0, 0, 0, 0
	db 1, 0, 1, 0, 1, 0, 1, 0
	db 0, 1, 0, 1, 0, 1, 0, 1
	db 1, 0, 1, 0, 1, 0, 1, 0
	curPlayer db 1
	goodrez db 0 ;2 - нужно рубить, 1 - нужно ходить, 0 - ходов нет
	turn db 0
click endp

sendmoving proc near
	push ax
	push si
	push cx
		mov al, 'C'
		call Out_Chr
		movzx ax, byte ptr [i]
		shl ax, 1
		mov cx, 10
		div cl
		add ax, 3030h
		call Out_Chr
		mov al, ah
		call Out_Chr
		lea si, way
		mov cl, byte ptr [i]
	sendfield:
		xor ax, ax
		lodsb
		shl ax, 5
		shr al, 5
		add ax, 3141h
		call Out_Chr
		mov al, ah
		call Out_Chr
		loop sendfield
	pop cx
	pop si
	pop ax
	ret
sendmoving endp

light proc near ;dx - (00yyyxxx)
	push si
	push bx
		mov bx, dx
		movzx si, byte ptr cb[bx]
		mov al, byte ptr colors[si]
		mov ah, byte ptr colors[0]
		call piece
	pop bx
	pop si
	ret
	colors db 0, 15, 8, 0, 0, 14, 9
light endp

can_capture proc near; bx - откуда, si - в какую сторону, cl - цвет
	lea bp, bx[si]
	mov ax, bp
	test al, 11000000b
	jne _ret0
	and ax, 9
	shl ax, 5
	shr al, 5
	xor al, ah
	je _ret;0
	mov ah, byte ptr tcb[bp]
	test ah, cl
	jne _ret0
	cmp ah, ch
	jne _4
	mov al, 1
	test cl, 4
	jne _ret
	mov ax, si
	shr ax, 15
	xor ax, cx
	test ax, 1
	jne _ret0
	mov al, 1
	jmp _ret
_4:	lea bp, bp[si]
	mov ax, bp
	test al, 11000000b
	jne _ret0
	and ax, 9
	shl ax, 5
	shr al, 5
	xor al, ah
	je _ret;0
	mov al, 2
	cmp byte ptr tcb[bp], ch
	je _ret
_ret0:
	mov al, 0
	ret;al (0 - нельзя ходить, 1 - можно ходить, 2 - можно рубить), в ah лежит говно
can_capture endp

mouse:
	push cs
	pop ds
	cmp turn, 1
	jne _retf
	shr dx, 4
	shr cx, 5
	cmp dx, 8
	jge _retf
	cmp cx, 8
	jge _retf
	mov ax, dx
	add ax, cx
	test ax, 1
	je _retf
	shl dx, 3
	add dx, cx
	cmp rotate_flag, 0
	je _J
	neg dx
	add dx, 63
_J:	call click
_retf:
	retf
rotate_flag db 0
	
int_08h:
	inc timef
	cmp timef, 18
	jl _jmp08
	
	sub timef, 18
	inc secflag
	mov Aoutflag, 1
	
	cmp secflag, 5
	jl _jmp08
	
	mov fsecflag, 1
	sub secflag, 5
_jmp08:
	db 0eah
	a08 dw ?
	b08 dw ?
	timef dw 0
	secflag db 0
	fsecflag db 0
	Aoutflag db 0
	

getmsg proc near
	xor ax, ax
	call Get_Chr
	jc _ret
	cmp al, 'A'
	jne nA
	mov secflag, 0
	mov fsecflag, 0
	
	cmp myB, -1
	jne _ret
	
	mov ah, byte ptr [timef]
	mov al, 'B'
	call Out_Chr
	mov al, byte ptr [timef]
	and ax, 0101h
	add al, ah
	mov myB, al
	add al, '0'
	call Out_Chr
	
	cmp opB, -1
	je _ret
	
WDL:movzx bx, byte ptr myB
	shl bx, 2
	add bl, opB
	cmp byte ptr KNBT[bx], 0
	jne WL
	mov myB, -1
	mov opB, -1
	ret
WL:	
	mov al, byte ptr KNBT[bx]
	mov turn, al
	dec ax
	mov rotate_flag, al
	lea dx, whitemove
	call print
	call board
	call get_posible
	call repaint
	ret
	
nA:	cmp al, 'G'
	jne nG
	;stosb
	
	call Wait_Chr
	;stosb
	sub al, 30h
	cmp al, 9
	;ja _sendError
	mov cx, ax
	shl cx, 3
	add cx, ax
	add cx, ax
	call Wait_Chr
	;stosb
	sub al, 30h
	cmp al, 9
	;ja _sendError
	add cx, ax
	xor di, di
an:	call Wait_Chr
	cmp di, 20
	je _chat_overflow
	mov text[di], al
	inc di
	_chat_overflow:
	loop an
	mov text[di], '$'
	call printchat
	ret
	
nG:	cmp al, 'N'
	jne nN
	;stosb
	call Wait_Chr
	;stosb
	sub al, 30h
	cmp al, 9
	;ja _sendError
	mov cx, ax
	shl cx, 3
	add cx, ax
	add cx, ax
	call Wait_Chr
	;stosb
	sub al, 30h
	cmp al, 9
	;ja _sendError
	add cx, ax
	xor di, di
aNN:call Wait_Chr
	cmp di, 20
	je _nick_overflow
	mov nick[di], al
	inc di
	_nick_overflow:
	loop aNN
	mov nick[di],':'
	mov nick[di+1], '$'
	ret
	
nN: cmp al, 'E'
	jne xE
	;stosb
	mov op_new_game_sig, 1
	cmp my_new_game_sig, 1
	jne _ret
	call newgame
	ret

xE:	

	cmp al, 'B'
	jne nB
	;stosb
	cmp opB, -1
	;jne _sendError
	call Wait_Chr
	;stosb
	sub al, '0'
	cmp al, 2
	;ja _sendError
	cmp opB, -1
	;jne _sendError
	mov opB, al
	cmp myB, -1
	jne WDL
	ret
	
nB:	cmp al, 'C'
	jne nC
	cmp turn, 1
	;je _sendError
	;stosb
	call Wait_Chr
	;stosb
	sub al, 30h
	cmp al, 9
	;ja _sendError
	mov cx, ax
	shl cx, 2
	add cx, ax
	call Wait_Chr
	;stosb
	sub al, 30h
	cmp al, 9
	;ja _sendError
	shr ax, 1
	;jc _sendError
	add cx, ax
am:	call Wait_Chr
	;stosb
	sub al, 41h
	cmp al, 7
	;ja _sendError
	movzx dx, al
	call Wait_Chr
	;stosb
	sub al, 31h
	cmp al, 7
	;ja _sendError
	shl ax, 3
	add dx, ax
	push cx
		call click
	pop cx
	loop am
	mov al, 'D'
	call Out_Chr
	mov al, '0'
	call Out_Chr
	ret
	
nC:	cmp al, 'D'
	jne nD
	;stosb
	call Wait_Chr
	;stosb
	cmp al, '0'
	;jne _sendError
	ret
	
nD:	
_sendError:
ret
	
	mov al, 'D'
	call Out_Chr
	mov al, '1'
	call Out_Chr
	mov stopgame, 1
	lea dx, vsehuevo
	call print
	ret
	
	xz dw 0
	myB db -1
	opB db -1
	;msgbuf db 256 dup(0)
	;bufpos db 0
	KNBT:
	db 0, 1, 2, 0
	db 2, 0, 1, 0
	db 1, 2, 0, 0
getmsg endp

Wait_Chr proc near
	call Get_Chr
	jnc _ret
	jmp Wait_Chr
Wait_Chr endp
	
Debug proc near
	push es
	push bx
	push ax
	push dx
		mov dl, al
		mov ax, 0
		mov es, ax
		mov bx, 450h
		mov ax, 1200h
		add ax, xz
		mov word ptr es:[bx], ax
		mov ah, 2
		int 21h
		inc xz
	pop dx
	pop ax
	pop bx
	pop es
	ret
Debug endp

Debug1 proc near
	push es
	push bx
	push ax
	push dx
		mov dl, al
		mov ax, 0
		mov es, ax
		mov bx, 450h
		mov ax, 1400h
		add ax, xz
		mov word ptr es:[bx], ax
		mov ah, 2
		int 21h
		inc xz
	pop dx
	pop ax
	pop bx
	pop es
	ret
Debug1 endp
	
Ser_Ini proc near
	push ax								; сохpанить pегистpы
	push dx
		push bx
		push es
			in al, 21h					; IMR 1-го контpолеpа пpеpываний
			or al, 10h					; запpетить пpеpывание IRQ4 от COM1
			out 21h, al
			mov al, 0Ch
			mov ah, 35h
			int 21h						; взять вектоp Int 0Ch в es:bx
			mov Ser_ip, bx				; и сохpанить его
			mov Ser_cs, es
			mov al, 0Ch
			mov dx, offset Ser_int
			push ds
				mov bx, cs
				mov ds, bx
				mov ah, 25h
				int 21h					; установить Int 0Ch = ds:dx
			pop ds
		pop es
		pop bx
		cli								; запpетить пpеpывания
		in al, 21h						; IMR 1-го контpоллеpа пpеpываний
		and al, not 10h
		out 21h, al						; pазpешить пpеpывания от COM1
		mov dx, 3FBh					; pегистp упpавления линией
		in al, dx
		or al, 80h						; установить бит DLAB
		out dx, al
		mov dx, 3F8h
		mov al, 60h
		out dx, al						; младший байт для скоpости 1200 бод
		inc dx
		mov al, 0
		out dx, al						; стаpший байт скоpости
		mov dx, 3FBh					; pегистp упpавления линией
		mov al, 00000011b				; 8 бит, 2 стоп-бита, без четности
		out dx, al
		mov dx, 3F9h					; pегистp pазpешения пpеpываний
		mov al, 1						; pазpешить пpеpывания по пpиему
		out dx, al
		nop								; и чуть-чуть подождать
		nop
		mov dx, 3FCh					; pегистp упpавления модемом
		mov al, 00001011b				; установить DTR, RTS и OUT2
		out dx, al
		sti								; pазpешить пpеpывания
		mov dx, 3F8h					; pегистp данных
		in al, dx						; сбpосить буфеp пpиема
	pop dx
	pop ax
	ret
Ser_Ini endp

Source db 1026 dup(0)					; буфеp пpиема символов
Src_ptr dw Source						; указатель позиции в буфеpе
Count dw 0								; количество символов в буфеpе
Ser_ip dw 0								; стаpый адpес Int 0Ch
Ser_cs dw 0
Save_ds dw 0							; служебные пеpеменные
Int_sts db 0
Overrun db 0

Ser_Rst proc near
	push ax								; сохpанить pегистpы
	push dx
	push ds
	
	Wait_Free:
		mov ax, cs
		mov ds, ax
		mov dx, 3FDh					; pегистp состояния линии
		in al, dx
		jmp short $+2					; коpоткая задеpжка
		test al, 60h					; пеpедача окончена?
		jz Wait_Free					; ждем, если нет
		mov dx, 3F9h					; pегистp pазpешения пpеpываний
		mov al, 0						; запpетить пpеpывания
		out dx, al
		jmp short $+2					; еще подождем...
		jmp short $+2
		mov dx, 3FCh					; pегистp упpавления модемом
		mov al, 00000011b				; активиpовать DTR и RTS
		out dx, al
		jmp short $+2
		jmp short $+2
		push bx
			mov al, 0Ch
			mov dx, Ser_ip
			push ds
				mov bx, Ser_cs
				mov ds, bx
				mov ah, 25h
				int 21h					; восстановить вектоp Int 0Ch
			pop ds
		pop bx
		cli								; запpет пpеpываний
		in al, 21h						; читать маску пpеpываний
		jmp short $+2
		or al, 10h						; запpетить IRQ4
		out 21h, al
		sti								; pазpешение пpеpываний
	pop ds
	pop dx
	pop ax
	ret
Ser_Rst endp

Ser_Int proc far
	push ax
	push dx
	push ds
		mov ax, cs
		mov ds, ax
		mov dx, 3FAh					; pегистp идентификации пpеpываний
		in al, dx
		mov Int_Sts, al					; сохpаним его содеpжимое
		test al, 1						; есть отложенные пpеpывания?
		jz Is_Int						; да
	pop Save_ds							; нет, пеpедаем упpавление
	pop dx								; стаpому обpаботчику Int 0Ch
	pop ax
	push Ser_cs
	push Ser_ip
		push Save_ds
		pop  ds
	ret									; длинный пеpеход

	Is_Int:
		mov al, 64h						; послать EOI для IRQ4
		out 20h, al						; в 1-й контpоллеp пpеpываний
		test Int_Sts, 4					; пpеpывание по пpиему?
		jnz Read_Char					; да
	No_Char:
		sti								; нет, pазpешить пpеpывания
		jmp Int_Ret						; и закончить обpаботку Int 0Ch

	Read_Char:
		mov dx, 3FDh					; pегистp состояния линии
		in al, dx
		and al, 2
		mov Overrun, al					; ovvrrun<>0, если была потеpя символа
		mov dx, 3F8h					; pегистp данных
		in al, dx						; вводим символ
		or al, al						; если пpинят нуль,
		jz No_Char						; то игноpиpуем его
		push bx
			mov ah, Overrun
			or ah, ah					; пpедыдущий символ потеpян?
			jz Save_Char				; нет
			mov ah, al					; да,
			mov al, 7					; заменяем его на звонок (07h)
		Save_Char:
			mov bx, Src_ptr				; заносим символ в буфеp
			mov [bx], al
			inc Src_ptr					; и обновляем счетчики
			inc bx
			cmp bx, offset Src_ptr-2	; если конец буфеpа
			jb Ser_Int_1
			mov Src_ptr, offset Source	; то "зацикливаем" на начало
		Ser_Int_1:
			cmp Count, 1024			; буфеp полон?
			jae Ser_Int_2				; да
			inc Count					; нет, учесть символ
		Ser_Int_2:
			or ah, ah					; если была потеpя символа
			jz Ser_Int_3
			mov al, ah					; то занести в буфеp сам символ
			xor ah, ah
			jmp short Save_Char
	Ser_Int_3:
		pop bx
		sti								; pазpешить пpеpывания
Int_Ret:
	pop  ds
	pop  dx
	pop  ax
	iret
Ser_Int endp

Out_Chr proc near ; (al)
	call Debug
	push ax
	push cx
	push dx
		mov ah, al
		sub cx, cx
		
	Wait_Line:
		mov dx, 3FDh					; pегистp состояния линии
		in al, dx
		test al, 20h					; стык готов к пеpедаче?
		jnz Output						; да
		jmp short $+2
		jmp short $+2
		loop Wait_Line					; нет, ждем
	pop dx
	pop cx
	pop ax
	stc									; нет готовности поpта
	ret									; CF = is_error = 1
	
	Output:
		mov al, ah
		mov dx, 3F8h					; pегистp данных
		jmp short $+2
		out dx, al						; вывести символ
	pop dx
	pop cx
	pop ax
	clc									; ноpмальный возвpат
	ret									; CF = is_error = 0
Out_Chr endp

Get_Chr proc near
	cmp Count, 0						; буфеp пуст?
	jne loc_1729						; нет
	stc									; да, возвpат по ошибке
	ret									; CF = buffer_is_empty = 1
loc_1729:
	push si
		cli								; запpетим пpеpывания
		mov si, Src_ptr
		sub si, Count
		cmp si, offset Source
		jae loc_1730
		add si, 1024
	loc_1730:
		mov al, [si]					; выбеpем символ
		dec Count						; и уменьшим счетчик
		sti								; pазpешение пpеpываний
	pop si
	call Debug1
	clc									; и ноpмальный возвpат
	ret									; al = symbol, CF = buffer_is_empty = 0
Get_Chr endp

end start