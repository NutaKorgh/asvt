
; Beer - example of tiny (one section) Win32 program
; Copyright (c) 2001, Tomasz Grysztar
; All rights reserved.

format PE GUI 4.0

include 'include\kernel.inc'
include 'include\user.inc'

include 'include\macro\stdcall.inc'
include 'include\macro\import.inc'

; no section defined - fasm will automatically create .flat section for both
; code and data, and set entry point at the beginning of this section

	stdcall [MessageBox],0,_message,_caption,MB_ICONQUESTION+MB_YESNO
	cmp	eax,IDYES
	jne	exit

	stdcall [mciSendString],_cmd_open,0,0,0
	stdcall [mciSendString],_cmd_eject,0,0,0
	stdcall [mciSendString],_cmd_close,0,0,0

exit:
	stdcall [ExitProcess],0

_message db 'Do you need additional place for the beer?',0
_caption db 'Desktop configuration',0

_cmd_open db 'open cdaudio',0
_cmd_eject db 'set cdaudio door open',0
_cmd_close db 'close cdaudio',0

; import data in the same section

data import

 library kernel,'KERNEL32.DLL',\
	 user,'USER32.DLL',\
	 winmm,'WINMM.DLL'

 kernel:
 import ExitProcess,'ExitProcess'

 user:
 import MessageBox,'MessageBoxA'

 winmm:
 import mciSendString,'mciSendStringA'

end data

data fixups
 ; fasm will automatically insert all the fixups here
 ; this is to prevent fasm from creating separate .reloc section
end data
