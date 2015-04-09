.model tiny
.386
.code
org	0100h
start:
	mov	si,	80h
	lodsb
	mov	len,	al
	xor	bx,	bx
	xor	bp,	bp
	xor	dx,	dx
	jmp	psp_r_param
	
obrabot proc near
	push	cx
	push	dx
	lea	dx,	dop_simb
	mov	di,	dx
	mov	cx,	13
	repne	scasb
	sub	di,	dx
	dec	di
	pop	dx
	pop	cx
	ret
obrabot ENDP
_1:
	mov	mas[bp],	0
	inc	bp
	inc	bp
	jmp	psp_r_param
_2:
	inc	z
	jmp	psp_r_param
_3:
	sub	al,	'0'
	push	ax
	xchg	ax,	dx
	mul	ten
	jo	pe
	pop	dx
	add	ax,	dx
	jo	pe
	xchg	ax,	dx
	jmp	psp_r_param
_5:
	mov	mas[bp],	dx
	xor	dx,	dx
	inc	bp
	inc	bp
	cmp	z,	0
	jz	psp_r_param
	neg	mas[bp-2]
	mov	z,	0
	jmp	psp_r_param
psp_r_param:
	mov al,	len
	test	al,	al;al=0 to prigaem
	jz	end_read
	dec	len
	lodsb
	call	obrabot
	shl	bx,	4
	mov	bl,	byte	ptr	trt[bx][di]
	cmp	bx,	1
	je	_1
	cmp	bx,2
	je	_2
	cmp	bx,	3
	je	_3
	cmp	bx,	5
	je	_5
	jmp	psp_r_param
end_read:
	cmp	bx,	4
	je	pe
	cmp	bx,	2
	je	pe
	cmp	bx,	3
    jne next
	mov	mas[bp],	dx
	inc	bp
	inc	bp
	cmp	z,	0
	je	next
	neg	mas[bp-2]
	jmp	next
;fail:
;	mov ah,	9h
;	lea	dx,	msg_pe
;	int	21h
ret

next:
	finit	
	mov	ax,	mas[0]
	mov	a,	ax
;	fild	a	
	xor	ax,	ax
	
	mov	ax,	mas[2]	
	mov	b,	ax
	xor	ax,	ax

	mov	ax,	mas[4]
	mov	c,	ax
	xor	ax,	ax
	mov ax,	mas[6]
	mov	d,	ax
	xor	ax,	ax
;	finit
	fild	a
	fcomp	zero
	fstsw	ax
	sahf
	je	pe	;a=0

	fild	d
	fcomp	zero
	fstsw	ax
	sahf
	ja	pe
;	je	pe
	jl	pe
	;discrimanant
	fild	b
	fld	ST(0)
	fmul	
	fild	ffor
	fild	a
	fild	c
	fmul	
	fmul
	fsub

	fcom	zero	
	fstsw	ax
	sahf
	ja	_gg ;discrim>0 resheniy net
	je	_disz ;diskr = 0
	
	mov	ah,	09h
	lea dx,	msg_n
	int 21h
;	mov	ah,	09h
	lea	dx,	strd
	int 21h
;	mov	ah,	09h
	lea	dx,	stra
	int 21h	
	ret

_disz:
	fsqrt
	fild	b
	fchs
	fadd
	
	fild	two
	fild	a
	fmul
	fdiv
	fstp	x1
	call vivod
	mov	ah,	09h
	lea	dx,	strd
	int	21h
;	mov	ah,	09h
	lea	dx,	stra
	int	21h
	jmp finish
	
_gg:
	fsqrt
	fld ST(0)
	fild	b
	fchs
	fadd
	fxch
	fchs
	fild	b
	fchs
	fadd
	
	fild	two
	fild	a
	fmul
	fst	osn
	fdiv
	fstp	x1
	fstp	x2
	call vivod

	mov ah, 09h
	lea dx, prob
	int 21h

	fld	x2
	fld	osn
	fdiv
	fstp	x1
	call vivod
	mov	ah,	09h
	lea	dx,	strd
	int	21h
	lea	dx,	stra
	int	21h
	jmp	finish	

;_2:	
;	fild	c
;	fchs
;	fild	b
;	fdiv
;	fstp	x1
;	call vivod
	jmp	finish
p_fin:
	mov	ah,	9h
	lea	dx,	msg_n
	int 21h
	lea	dx,	strd
	int 21h
	lea	dx,	stra
	int 21h
	jmp	finish
pe:
	mov	ah,	9h
	lea	dx,	msg_pe
	int 21h
	lea	dx,	strd
	int 21h
	lea	dx,	stra
	int 21h
finish:
ret
	
vivod	proc near
norm:
	mov cx, 0
	 
	fld	x1
	fcom	zero
	fstsw	status_word
	mov	ax,	status_word
	sahf
	jae	met1		
	
	mov	cx, 	1
	fabs
met1:	
	fld	ST(0)
	fstcw	control_word	;za orim	rc
	mov	ax,	control_word
	sahf
	or	ah,	000Ch
	mov	control_word,	ax
	fldcw	control_word		

	frndint	;okryglenie k 0
	
	fist	rez_c
	mov	ax,	rez_c
	jcxz meta3
	mov	ah,	02h
	mov	dx,	'-'
	int	21h

meta3:
	mov	ax,	rez_c
	call	vivod_ch
			
	mov	ah,	02h
	mov	dx,	'.'
	int	21h

	fsub	ST(1), ST(0)
	fxch
;	ffree ST(1)
	fstp
	mov cx, 3
ckl:
	fild	t
	fmul
	fld ST(0)
	frndint
	fist	f
	fsub
;	fstp f
	mov ax, f
	call vivod_ch
	loop ckl
	
	fstcw	control_word
	mov	ax,	control_word
	sahf
	xor	ah,	000Ch
	mov	control_word,	ax
	fldcw	control_word
	
	fild		t
	fmul
	frndint
	fist	f
	mov	ax,	f	
	call vivod_ch;opopopopopopop
fin:
	ret
vivod ENDP

vivod_ch proc near

	mov	bp, offset e
c1:
	dec	bp
	mov	dx, 0
	mov	bx, 10
	div	bx
	add 	dl, '0'
	mov	[bp], dl
	cmp	ax, 0
	jne	c1
	mov	ah, 9
	mov	dx, bp
	int	21h
ret
vivod_ch ENDP

status_word	dw	?
control_word	dw	?

trt:
	db	0h,	2h,	1h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	4h,	0h,	0h,	0h 
	db	0h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	0h,	0h,	0h 
	db	4h,	4h,	4h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	4h,	0h,	0h,	0h
	db	5h,	4h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	4h,	0h,	0h,	0h 
	db	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	4h,	0h,	0h,	0h
	db	0h,	2h,	1h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	3h,	4h,	0h,	0h,	0h 
	db	'          $'
dop_simb	db	' -0123456789'	

;str_end = $-2


ffor	dw	4
two	dw	2

a	dw	?
b	dw	?
c	dw	?
d	dw	?

t	dw	10
f	dw	?
rez_c	dw	?

ten	db	10
zero	dd	0
z	db	0
osn	dd	?
dop	dd	?
x1	dd	?
x2	dd	?

len	db	?
prob	db	20h,'$'
stra	db	0Ah,'$'
strd	db	0Dh,'$'
buf	db	8 dup (' ')
e	db	'$'
msg_pe	db	'pe$'
msg_y	db	'yes$'
msg_n	db	'no$'
mas dw 64 dup (0)
end start