.model      tiny
        .code
        org         100h         ; ���-����
        .186                     ; ��� ������� shr cx,3
start:
        mov         ax,12h
        int         10h          ; ���������� 640x480
        mov         ax,0         ; ���������������� ����
        int         33h
        mov         ax,1         ; �������� ������ ����
        int         33h
        mov         ax,000Ch     ; ���������� ���������� ������� ����
        mov         cx,0002h     ; ������� - ������� ����� ������
        mov         dx,offset handler ; ES:DX - ����� �����������
        int         33h
        mov         ah,0         ; �������� ������� ����� �������
        int         16h
        mov         ax,000Ch
        mov         cx,0000h     ; ������� ���������� ������� ����
        int         33h
        mov         ax,3         ; ��������� �����
        int         10h
        ret                      ; ����� ���������

; ���������� ������� ����: ��� ������ ������� ������� ����� �� �����,
; ��� ������ ���������� ������ �������� ������ ����� �� ����������
; ����� � �������

handler:
        push        0A000h
        pop         es           ; ES - ������ �����������
        push        cs
        pop         ds           ; DS - ������� ���� � ������ ���� ���������
        push        cx           ; �� (�-����������) �
        push        dx           ; DX (Y-����������) ����������� � �����

        mov         ax, 2        ; �������� ������ ���� ����� ������� �� �����
        int         33h
        cmp         word ptr previous_X,-1  ; ���� ��� ������ �����,
        je          first_point             ; ������ ������� �����,

        call        line_bresenham          ; ����� - �������� ������
exit_handler:
        pop         dx                      ; ������������ �� � DX
        pop         cx
        mov         previous_X,cx           ; � ��������� �� ��� ����������
        mov         previous_Y,dx           ; ����������

        mov         ax,1         ; �������� ������ ����
        int         33h
        retf                     ; ����� �� ����������� - ������� RETF

first_point:
        call        putpixel1b   ; ����� ����� ����� (��� ������ ������)
        jmp         short exit_handler

; ��������� ��������� ������ ����� � �������������� ��������� ����������
; ����: ��, DX - X, Y �������� �����
; previous_X,previous_Y - X, Y ��������� �����

line_bresenham:
        mov         ax, cx
        sub         ax,previous_X             ; AX = ����� �������� ������ �� ��� X
        jns         dx_pos                    ; ���� �� ������������� -
        neg         ax                        ; ������� ��� ����, ������
        mov         word ptr X_increment,1    ; ���������� X ��� ������
        jmp         short dx_neg              ; ������ ����� �����,
dx_pos: mov         word ptr X_increment,-1   ; � ����� - �����������

dx_neg: mov         bx,dx
        sub         bx,previous_Y             ; BX = ����� �������� ������ �� ��� Y
        jns         dy_pos                    ; ���� �� ������������� -
        neg         bx                        ; ������� ��� ����, ������
        mov         word ptr Y_increment,1    ; ���������� Y ��� ������
        jmp         short dy_neg              ; ������ ����� �����,
dy_pos: mov         word ptr Y_increment,-1   ; � ����� - �����������

dy_neg: shl         ax,1            ; ������� �������� ��������,
        shl         bx,1            ; ����� �������� ������ � ���������� �������

        call        putpixel1b      ; ������� ������ ����� (������ �������� ��
                                    ; CX,DX � previous_X,previous_Y)
        cmp         ax,bx           ; ���� �������� �� ��� X ������, ��� �� Y:
        jna         dx_le_dy
        mov         di,ax           ; DI ����� ���������, � ����� ������� ��
        shr         di,1            ; ����������� �� ��������� ������
        neg         di              ; ����������� ��������� �������� DI:
        add         di,bx           ; DI = 2 * dy - dx
cycle:
        cmp         cx ,word ptr previous_X    ; �������� ���� �����������,
        je          exit_bres                 ; ���� � �� ������ ����� previous_X
        cmp         di,0                      ; ���� DI > 0,
        jl          fractlt0
        add         dx,word ptr Y_increment   ; ������� � ���������� Y
        sub         di,ax                     ; � ��������� DI �� 2 * dx
fractlt0:
        add         cx,word ptr X_increment   ; ��������� � (�� ������ ����)
        add         di,bx                     ; ��������� DI �� 2 * dy
        call        putpixel1b                ; ������� �����
        jmp         short cycle               ; ���������� ����
dx_le_dy:                                ; ���� �������� �� ��� Y ������, ��� �� X
        mov         di,bx
        shr         di,1
        neg         di                        ; ����������� ��������� �������� DI:
        add         di,ax                     ; DI = 2 * dx - dy
cycle2:
        cmp         dx,word ptr previous_Y    ; �������� ���� �����������,
        je          exit_bres                 ; ���� Y �� ������ ������ previous_Y,
        cmp         di,0                      ; ���� DI > 0,
        jl          fractlt02
        add         cx,word ptr X_increment   ; ������� � ���������� X
        sub         di,bx                     ; � ��������� DI �� 2 * dy
fractlt02:
        add         dx,word ptr Y_increment   ; ��������� Y (�� ������ ����)
        add         di,ax                     ; ��������� DI �� 2 * dy
        call        putpixel1b                ; ������� �����
        jmp         short cycle2              ; ���������� ����
exit_bres:
        ret                                   ; ����� ���������

; ��������� ������ ����� �� ����� � ������, ������������ ���� ��� ���
; �������� ������ �������.
; D� = ������, �� = �������
; ��� �������� �����������

putpixel1b:
        pusha                            ; ��������� ��������
        xor        bx,bx
        mov        ax,dx                 ; AX = ����� ������
        imul       ax,ax,80              ; �� = ����� ������ * ����� ���� � ������
        push       cx
        shr        cx,3                  ; �� = ����� ����� � ������
        add        ax,cx                 ; �� = ����� ����� � �����������
        mov        di,ax                 ; ��������� ��� � SI � DI ��� ������
        mov        si,di                 ; ��������� ���������

        pop        cx                    ; �� ����� �������� ����� �������
        mov        bx,0080h
        and        cx,07h                ; ��������� ��� ���� �� =
; ������� �� ������� �� 8 = ����� ���� � �����, ������ ������ ������
        shr        bx,cl                    ; ������ � BL ���������� � 1 ������ ���
        lods       es:byte ptr some_label   ; AL = ���� �� �����������
        or         ax,bx                    ; ���������� ��������� ��� � 1,
; ����� ������� ������� � ������, ��� ������� OR ����� �������� �� 
; not bx
; and ax,bx
; ��� ����� ���������������� �� �� ������ 0080h, � ������ FF7Fh � ������������
; ������ and
        stosb                           ; � ������� ���� �� �����
        ����                            ; ������������ ��������
        ret                             ; �����

previous_X         dw       -1          ; ���������� �-����������
previous_Y         dw       -1          ; ���������� Y-����������
Y_increment        dw       -1          ; ����������� ��������� Y
X_increment        dw       -1          ; ����������� ��������� X
some_label:                             ; �����, ������������ ��� ���������������
                                        ; ��������-��������� ��� lods � DS �� ES
        end        start