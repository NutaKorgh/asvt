.model tiny

.386

.code

org 100h

Start:

jmp Begin

Flag DB 0 ;0, ���� ���������� ����������� � 1 ���

ScrBuf DB 32 dup(0) ;����� ��� ���������� ������

Xpos DW (10*80+36)*2+1-60 ;������� ��������� �� ������

DB 'XOBR' ;����� ���������(��� �������� �����������)

old_int DD 0 ;������ ������� �����������

Resident:

pushf ;��������� �����

pusha ;� ��� �������� ������ ����������

push es

push ds

push cs

pop ds ;DS = CS

mov ax, 40h ;ES->������� ������ BIOS

mov es, ax

cmp byte ptr es:[49h], 3 ;����� ����� 3?

jnz ExitTSR ;���� ��� - �����

mov ax, 0b800h ;����� �������

mov es, ax

cmp Flag, 0

jz FirstStart

;��������������� ���������� �������

mov di, XPos ;ES:BX->����� ���� � ����� ������

mov si, offset ScrBuf

mov cx, 4

RestoreRow:

push cx

mov cx, 8

RestoreCol:

mov al, [si]

inc si

mov es:[di], al

add di, 2

loop RestoreCol

add di, 144

pop cx

loop RestoreRow

;���������� '����' ������

mov ax, XPos

add ax, 2

cmp ax, (10*80+36)*2+1+60 ;���� �������� ���� - ����������

jne @F ;�� ������

mov ax, (10*80+36)*2+1-60

@F:

mov XPos, ax

FirstStart:

mov Flag, 1

;��������� ������� ������ � ������ � ��� �������

mov di, XPos

mov si, offset ScrBuf

mov cx, 4 ;4 ������

NextRow:

push cx ;��������� CX

mov cx, 8 ;8 ��������

NextCol:

mov al, es:[di] ;

mov [si], al ;��������� �������, � ������� ����� ��������

inc si ;

mov byte ptr es:[di], 0 ;������� "������ ������ �� ������� ����"

add di, 2 ;���������� ������

loop NextCol ;��������� �������

add di, 144 ;������ ����

pop cx ;��������������� CX

loop NextRow ;��������� ������

ExitTSR:

pop ds

pop es ;��������������� ��������

popa

popf ;��������������� �����

jmp dword ptr cs:[old_int] ;��������� �� ������ ����������

EndResident EQU $

Begin:

lea dx, sMsg1

mov bx, 81h ;CS:[BX] = ��������� ������

ReadCMD:

mov al, ds:[bx] ;������ ��������� ������

inc bx

cmp al, 'i'

jz InstallTSR

cmp al, 'u'

jz UninstallTSR

cmp al, 32

jz ReadCMD

jmp ExitProg

InstallTSR:

lea dx, sMsg3

mov ax, 351ch ;�������� ������ �� 1ch ����������

int 21h

cmp dword ptr es:[bx-4-4], 'RBOX' ;��������� ������� ��������� � ������

jz ExitProg ;�������, ���� ��� ���������� �����

mov word ptr [old_int], bx ;��������� ������ ������

mov word ptr [old_int+2], es ;

mov dx, offset Resident ;DS:DX = ����� ������ �����������

mov ax, 251ch ;������������� ����� ������

int 21h

lea dx, sMsg2 ;������� ��������� �� �������� ���������

mov ah, 9

int 21h

lea dx, EndResident ;�������� ���������� � ����� �� ���������

int 27h

UninstallTSR:

lea dx, sMsg5

mov ax, 351ch

int 21h ;ES:BX = ������ 1ch ����������

cmp dword ptr es:[bx-4-4], 'RBOX' ;��������� ����������� ��������� � ������

jnz ExitProg ;�������, ���� �� ����������

push ds

lds dx, es:[bx-4] ;DS:DX = old_int

mov ax, 251ch

int 21h ;����������� ������ ������

pop ds

mov ah, 49h ;���������� ������, ���������� TSR

int 21h

lea dx, sMsg4

ExitProg:

mov ah, 9 ;����� ��������� �� �����

int 21h

ret ;����� �� ���������

sMsg1 DB "��������� ��������� ������:",13,10

DB "i - ���������� ��������",13,10

DB "u - ������� ��������",13,10,"$"

sMsg2 DB "Succes.","$"

sMsg3 DB "already there.","$"

sMsg4 DB "������� ��� ��������.","$"

sMsg5 DB "�������� �� ����������.","$"

END Start