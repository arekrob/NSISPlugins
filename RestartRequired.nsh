Function RestartRequired
	Exch $R1         ;Original Variable
	Push $R2
	Push $R3         ;Counter Variable
 
	StrCpy $R1 "0" 1     ;initialize variable with 0
	StrCpy $R3 "0" 0    ;Counter Variable
 
	;First Check Current User RunOnce Key
	EnumRegValue $R2 HKCU "Software\Microsoft\Windows\CurrentVersion\RunOnce" $R3
	StrCmp $R2 "" 0 FoundRestart
 
	;Next Check Local Machine Key
	EnumRegValue $R2 HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnce" $R3
	StrCmp $R2 "" ExitFunc 0
 
	FoundRestart:
		StrCpy $R1 "1" 1
 
	ExitFunc:
		Pop $R3
		Pop $R2
		Exch $R1
FunctionEnd