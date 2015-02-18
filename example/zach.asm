.model tiny
.code
.386
org 100h
@entry: 
	jmp @start
	FINIT
	saveMode db 0
	currentX dw 100
	currentY dw 100
	color db 0
	white db 15
	blue db 11
	scale dw 20
	gr dw drawYX2, drawSin, drawLn, draw10x
	len dw 0
	
@start: 
	; текущий видеорежим 
	mov ah, 0fh
	int 10h
	mov saveMode, al
	
	lea ax, gr
	push ax
@startDraw:
	; Переключиться в графический режим	
	mov ah, 0 
	mov al, 12h ; 640x480 16col
	int 10h
	
	; Рисуем оси	
	call drawOX
	call drawOY
	call drawOXscale	
	call drawOYscale
	; Графики
	pop ax
	mov bx, ax
	push ax
	mov ax, [bx]
	call ax
	
	
	; ждем клавишу
	mov ah, 00h
	int 16h
	cmp al, 3dh
	je @plus
	cmp al, 2dh
	je @minus
	cmp al, 1bh
	je @exit
	cmp al, 20h
	je @next
	jmp @startDraw
@plus:	
	call scaleInc
	jmp @startDraw
@minus:
	call scaleDec
	jmp @startdraw
@next:
	pop ax
	add ax, 02h
	mov bx, offset len
	cmp ax, bx
	jne @neq
	lea ax, gr
@neq:	
	push ax
	jmp @startdraw
	
@exit:	
	; возврат в преждний режим
	mov ah, 0
	mov al, saveMode
	int 10h
	
	mov ax, 4c00h
	int 21h
	
	ret

scaleInc proc
	push ax bx
	mov ax, scale
	mov bx, 10
	add ax, bx
	mov scale, ax
	pop bx ax
	ret
scaleInc endp	

scaleDec proc
	push ax bx
	mov ax, scale
	mov bx, 10
	sub ax, bx
	cmp ax, 0
	jne @cntn
	mov ax, 10
@cntn:	
	mov scale, ax
	pop bx ax
	ret
scaleDec endp	
	
drawPixel proc
	push cx
	mov ah, 0ch	
	mov bh, 0
	mov cx, currentX
	mov dx, currentY
	int 10h	
	pop cx
	ret
drawPixel endp	
	
drawOX proc	
	mov currentY, 240
	mov currentX, 0
	mov cx, 640
@loopOX:	
	mov al, white
	call drawPixel
	inc currentX
	loop @loopOX
		
	ret
drawOX endp

drawOY proc
	mov currentY, 0
	mov currentX, 320
	mov cx, 480
@loopOY:
	mov al, white
	call drawPixel
	inc currentY	
	
	loop @loopOY
	ret
drawOY endp

drawOXscale proc	
	push ax bx dx
	mov currentY, 237
	mov currentX, -1

@OXstart:
	inc currentX
	mov bx, currentX	
	mov ax, 320
	sub ax, bx
	mov bx, scale
	div bl
	cmp ah, 0h
	jne @OXstart
	
	mov ax, 640
	mov bx, scale
	div bl
	mov ah, 0h
	mov cx, ax
@loopOXscale:
	push cx
	mov ah, 0ch
	mov al, white
	mov bh, 0	
	mov cx, currentX	
	mov dx, currentY
@OXscale:
	inc dx
	int 10h		
	cmp dx, 242
	jne @OXscale
	pop cx
	
	push bx
	mov bx, scale
	add currentX, bx
	pop bx
	
	loop @loopOXscale
	pop dx bx ax
	ret
drawOXscale endp

drawOYscale proc	
	push ax bx dx
	mov currentY, -1
	mov currentX, 317

@OYstart:
	inc currentY
	mov bx, currentY
	mov ax, 240
	sub ax, bx
	mov bx, scale
	div bl
	cmp ah, 0h
	jne @OYstart
	
	mov ax, 480
	mov bx, scale
	div bl
	mov ah, 0h
	mov cx, ax
@loopOYscale:	
	push cx
	mov ah, 0ch
	mov al, white
	mov bh, 0	
	mov cx, currentX	
	mov dx, currentY
@OYscale:
	inc cx
	int 10h		
	cmp cx, 322
	jne @OYscale
	pop cx
	
	push bx
	mov bx, scale
	add currentY, bx
	pop bx
	
	loop @loopOYscale
	pop dx bx ax
	ret
drawOYscale endp

draw proc
	mov currentY, bx	
	add currentX, 320	
	mov al, blue
	call drawPixel
	sub currentX, 320
	ret
draw endp

check proc
	mov bx, 240
	mov ax, currentY
	sub bx, ax
	cmp bx, 0
	ret
check endp

pushfloat proc ; need ax
	push bp
	push ax
	mov bp, sp
	fild word ptr [bp]
	pop ax
	pop bp
	ret
pushfloat endp

drawYX2 proc
	mov currentX, 0
	sub currentX, 320
	mov cx, 640
@countYX2:		
	mov ax, currentX	
	call pushfloat	
	mov ax, scale
	call pushfloat
	fdiv
	fld st(0)
	fmul
	mov ax, scale
	call pushfloat
	fmul
	fistp currentY
		
	call check
	jl @continueYX2
	
	call draw	
	
@continueyx2:
	inc currentX
	loop @countYX2
	ret
	
drawYX2 endp

drawSin proc
	mov currentX, 0
	sub currentX, 320
	mov cx, 640
@countSin:
	mov ax, currentX	
	call pushfloat	
	mov ax, scale
	call pushfloat
	fdiv
	fsin
	mov ax, scale
	call pushfloat
	fmul
	fistp currentY
	
	call check
	jl @continueSin
	
	mov currentY, bx
	
	call draw

@continueSin:
	inc currentX
	loop @countSin
	ret	
drawSin endp

drawLn proc
	mov currentX, 0
	sub currentX, 320
	mov cx, 640
@countLn:
	fld1
	mov ax, currentX
	call pushfloat
	mov ax, scale
	call pushfloat
	fdiv
	fyl2x
	fldl2e
	fdiv
	mov ax, scale
	call pushfloat
	fmul
	fistp currentY
	
	call check
	jl @continueLn
	
	call draw

@continueLn:
	inc currentX
	loop @countLn
	ret	
drawLn endp

draw10x proc
	mov currentX, 0
	sub currentX, 320
	mov cx, 640
@count10x:
	mov ax, 10
	call pushfloat
	mov ax, currentX
	call pushfloat
	mov ax, scale
	call pushfloat
	fdiv
	fdiv	
	mov ax, scale
	call pushfloat
	fmul
	fistp currentY
	
	call check
	jl @continue10x
	
	call draw

@continue10x:
	inc currentX
	loop @count10x
	ret	
draw10x endp

end @entry