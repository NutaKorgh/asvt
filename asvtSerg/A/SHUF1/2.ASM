model tiny
.code
org 100h
.486

init:
	xor bx,bx
cikl:
	xor di,di
	mov ax,0B10Ah
	int 1Ah 
	push bx
	cmp ecx,0ffffffffh
	jne _1
	jmp preending
_1:
	mov tmp,bh
	mov tmp2,bl
	mov tmp4,ecx
	mov bx, offset conv
	mov al, tmp 
	
	and al,0f0h
	shr al,4
	xlatb
	mov dl,al
	mov ah,2
	int 21h

	mov al, tmp 
	and al, 0fh
	xlatb
	mov dl, al
	mov ah, 2
	int 21h

	mov ah,2
	mov dl, ' '
	int 21h

	mov al, tmp2 
	shr al, 3
	and al, 0f0h	
	shr al, 4
	
	xlatb
	mov dl, al
	mov ah, 2
	int 21h
	
	mov al, tmp2 
	shr al, 3	
	and al, 0fh
	
	xlatb
	mov dl, al
	mov ah, 2
	int 21h

	mov ah, 2
	mov dl,' '
	int 21h
	
	mov al, tmp2
	and al, 00000111b
	xlatb
	mov dl, al
	mov ah, 2
	int 21h
	mov dl, ' '
	int 21h

	mov edi, tmp4
	mov cx, 0
cikl_print_d:	
	rol edi, 4
	mov ax, di
	and ax, 0fh
	 
	xlatb
	push bx
	mov bx, offset tmp6
	add bx, cx
	mov byte ptr ds:[bx], al
	pop bx
	mov dl, al
	mov ah, 2
	int 21h
	inc cx
	cmp cx, 4
	jne cikl_print_d
	
	mov cx, 0
cikl_print_v:

	rol edi, 4

	mov ax, di
	and ax, 0fh
	 
	xlatb
	push bx
	mov bx, offset tmp3
	add bx, cx	
	mov byte ptr ds:[bx], al
	pop bx
	mov dl, al
	mov ah, 2
	int 21h
	inc cx
	cmp cx, 4
	jne cikl_print_v

	mov ah, 2
	mov dl, 0dh
	int 21h
	mov dl, 0ah
	int 21h

	pop bx
	inc bx
	cmp bx, 0
	jmp searching
preending:
	and dl, 00000111b
	cmp dl, 0
	je cancan
	pop bx
	inc bx
	cmp bx, 0
	je ending
	jmp cikl
cancan:	
	pop bx
	or bl, 00000111b
	inc bx
	cmp bx, 0
	je ending
	jmp cikl

ending:
	ret

searching:
	push bx
	mov numb_end, 1100h
	mov ah, 03dh
	mov al, 00000010b
	mov dx, offset filename
	int 21h
	push ax
 
cikl_s_v:
	cmp numb_end, 1100h
	je gogogo
	jmp end_prog
gogogo:
	mov head, 0
	mov head3, 0
	pop bx
	mov ah, 3fh
	mov cx, 1000h
	mov dx, offset buffer
	push bx
	int 21h
	cmp ax, 1000h
	jne compare_end
	jmp compare

compare_end:
	mov numb_end, ax
compare:
	mov bx, head
	cmp bx, 1000h
	ja cikl_s_v
	cmp bx, numb_end
	jbe gogogo2
	jmp end_prog
gogogo2:
	add bx, head1
	cmp bx, 1000h
	ja cikl_s_v
	cmp bx, numb_end
	jbe gogogo3
	jmp end_prog
gogogo3:
	mov bx, offset tmp2_5 
	add bx, head1

	mov dx, head
	add dx, offset buffer
	add dx, head3
	mov cl, byte ptr ds:[bx]
gogogo4:
	mov bx, dx
	cmp cl, byte ptr ds:[bx]
	je comp_cont
	inc head
	mov head1, 0
	mov head3, 0 
	jmp compare
comp_cont: 
	inc head1
	inc head3
	cmp head1, 8
	je return
	jmp compare





return:
	mov ax, head3
	add head,ax
	mov bx, offset buffer
	add bx, head
	mov ah,2
	mov dl, byte ptr ds:[bx]
cikl_printing_vendor_name:
	int 21h
	inc bx
	inc head
	cmp head, 1000h
	ja too_large_v_name
	mov dx, numb_end
	cmp head, dx
	jbe cont_pr_v_n
	jmp end_prog
cont_pr_v_n:
	mov dl, byte ptr ds:[bx]
	cmp dl, 0ah
	jne cikl_printing_vendor_name
	int 21h
	mov dl, 0dh
	int 21h
		
	jmp compare_d
	
too_large_v_name:	
	cmp numb_end, 1100h
	je gogogo_large_v_n
	jmp end_prog
gogogo_large_v_n:
	mov head, 0
	mov head3, 0
	pop bx
	mov ah, 3fh
	mov cx, 1000h
	mov dx, offset buffer
	push bx
	int 21h
	cmp ax, 1000h
	je return
	mov numb_end, ax
	jmp return


cikl_s_d:
	cmp numb_end, 1100h
	je gogogo_d
	jmp end_prog
gogogo_d:
	mov head, 0
	mov head3, 0
	pop bx
	mov ah, 3fh
	mov cx, 1000h
	mov dx, offset buffer
	push bx
	int 21h
	cmp ax, 1000h
	jne compare_end_d
	jmp compare_d

compare_end_d:
	mov numb_end, ax
compare_d:
	mov bx, head
	cmp bx, 1000h
	ja cikl_s_d
	cmp bx, numb_end
	jbe gogogo2_d
	jmp end_prog
gogogo2_d:
	add bx, head1
	cmp bx, 1000h
	ja cikl_s_d
	cmp bx, numb_end
	jbe gogogo3_d
	jmp end_prog
gogogo3_d:
	mov dx, offset tmp5 
	add dx, head1

	mov bx, head
	add bx, offset buffer
	add bx, head3
	mov cl, byte ptr ds:[bx]
	cmp head1, 3
	jne gogogo4_d
	cmp cl, 'v'
	jne gogogo4_d
	jmp end_prog
gogogo4_d:
	mov bx, dx
	cmp cl, byte ptr ds:[bx]
	je comp_cont_d
	inc head
	mov head1, 0
	mov head3, 0 
	jmp compare_d
comp_cont_d: 
	inc head1
	inc head3
	cmp head1, 8
	je return_d
	jmp compare_d



return_d:
	mov ax, head3
	add head, ax
	mov bx, offset buffer
	add bx, head
	mov ah, 2
	mov dl, byte ptr ds:[bx]
cikl_printing_device_name:
	int 21h
	inc bx
	inc head
	cmp head, 1000h
	ja too_large_d_name
	mov dx, numb_end
	cmp head, dx
	jbe cont_pr_d_n
	jmp end_prog
cont_pr_d_n:
	mov dl, byte ptr ds:[bx]
	cmp dl, 0ah
	jne cikl_printing_device_name
	int 21h
	mov dl, 0dh
	int 21h

	pop bx
	mov ah, 3Eh
	int 21h
	pop bx	
	jmp cikl
	
too_large_d_name:	
	cmp numb_end, 1100h
	je gogogo_large_d_n
	jmp end_prog
gogogo_large_d_n:
	mov head, 0
	mov head3, 0
	pop bx
	mov ah, 3fh
	mov cx, 1000h
	mov dx, offset buffer
	push bx
	int 21h
	cmp ax, 1000h
	je return_d
	mov numb_end, ax
	jmp return_d

end_prog:

	pop bx
	mov ah, 3Eh
	int 21h

	mov ah, 02h
	mov dx, '!'
	int 21h
	mov dl, 0dh
	int 21h
	mov dl, 0ah
	int 21h
	pop bx
	jmp cikl

tmp db 0
tmp2 db 0
tmp2_5 db 0Dh, 0Ah, 56h, 09h
tmp3 db 0,0,0,0
tmp4 dd 0
tmp5 db 0Dh, 0Ah, 'D', 09h
tmp6 db 0,0,0,0
conv db "0123456789ABCDEF"
numb_end dw 1100h
head1 dw 0
head dw 0
head3 dw 0
filename db 'pcidevs0.txt', 0
buffer db ?
end init