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
cmp      dx,bx     ;���� bx < 18��, �� �����
jnb      done      ;����� �������� ������������
div      bx        ;ax=(dx,ax)/bx
mov      bx,ax     ;������� �������
in       al,61h    ;���� ��
or       al,3      ;���������� ���� 0-1
out      61h,al
mov      al,00001011b   ;����������� ����� �������:
mov      dx,43h
out      dx,al     ;����� � ������� ������
dec      dx
mov      al,bl
out      dx,al     ;������� ���� ��������
mov      al,bh
out      dx,al     ;������� ���� ��������
done:
ret

No_Sound:
push     ax
in       al,61h    ;���� ��
and      al,not 3  ;����� ����� 0-1
out      61h,al
pop      ax
ret

end start