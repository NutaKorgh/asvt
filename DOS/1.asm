.model tiny
.code
org 100h
@entry: jmp @start
	hw db 'Hello, World!$'
@start: mov ah, 09h
		mov dx, offset hw
		int 21h
		ret
end @entry