;*********************************************************************
; Windows Imaging Component
;
; Usage
; !insertmacro CheckWICINST
;*********************************************************************

Function CheckWIC
  IfFileExists "$SYSDIR\PhotoMetadataHandler.dll" WICExists WICMissing32 

  WICMissing32:
	IfFileExists "$WINDIR\SysWOW64\PhotoMetadataHandler.dll" WICExists WICMissing64
  
  WICMissing64:
    Push 0
    Goto ExitFunction

  WICExists:
    Push 1
    Goto ExitFunction
 
  ExitFunction: 
FunctionEnd

!macro CheckWICINST

DetailPrint "Sprawdzanie istniejącej wersji Windows Imaging Component..."
StrCpy $8 ""
CheckBeginWICINST:
  Call CheckWIC
  Pop $R0

  ${If} $R0 == 0
    DetailPrint "Nie znaleziono Windows Imaging Component."
    ${If} $8 == ""
      Goto InvalidWICINST
    ${Else}
      Goto InvalidWICINSTAfterInstall
    ${EndIf}
  ${EndIf}

  Goto ValidWICINST

InvalidWICINST:
  MessageBox MB_YESNO|MB_ICONQUESTION \
    "Program ${PRODUCT_NAME} wymaga pakietu Windows Imaging Component, który nie jest obecnie zainstalowany na Twoim komputerze.$\r$\n$\r$\nCzy zainstalować?" \
  IDYES InstallWICINST IDNO AbortWICINST

AbortWICINST:
  DetailPrint "Instalacja przerwana z powodu braku Windows Imaging Component"
  MessageBox MB_OK "Pakiet Windows Imaging Component jest wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

InstallWICINST:
  DetailPrint "Instalowanie Windows Imaging Component."
  ${If} ${RunningX64}
    ExecWait '"additional/wic_x64_enu.exe" /quiet /norestart' $R1
  ${Else}
    ExecWait '"additional/wic_x86_enu.exe" /quiet /norestart' $R1
  ${EndIf}
  DetailPrint "Instalacja Windows Imaging Component zakończona (kod wyjścia: $R1). Sprawdzanie..."
  
  ; 1641 - Instalator rozpoczął ponowny rozruch.
  ; 3010 - Ukończenie instalacji wymaga ponownego uruchomienia
  ${If} $R1 == 3010
    StrCpy $7 "NeedsRestart"
  ${Else}
    StrCpy $7 "NoNeedToRestart"
  ${EndIf}
  
  StrCpy $8 "AfterInstall"
  Goto CheckBeginWICINST

InvalidWICINSTAfterInstall:
  DetailPrint "Instalacja przerwana po nieprawidłowej instalacji Windows Imaging Component"
  MessageBox MB_OK "Instalacja pakietu Windows Imaging Component nie powiodła się. Jest to element wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

ValidWICINST:
  DetailPrint "Windows Imaging Component jest zainstalowany."
  
!macroend