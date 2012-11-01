;*********************************************************************
; .NET Framework 2.0.50727
; 
; Runs the Microsoft .NET Framework 2.0.50727 Redistributable if the user does not have the correct version.
;*********************************************************************

!define DOTNET_VERSION "2.0.50727" ; required .net runtime version

Function IsRequiredDotNetVersionAvailable
  ;Save the variables in case something else is using them
  Push $0		; Registry key enumerator index
  Push $1		; Registry value

  StrCpy $R0 "false"
  StrCpy $0 0

  loop:
    ; Get each sub key under "SOFTWARE\Microsoft\NET Framework Setup\NDP"
    EnumRegKey $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP" $0
    StrCmp $1 "" clean 	; if no more registry keys
	StrCmp $1 "v${DOTNET_VERSION}" dotnet_found
    IntOp $0 $0 + 1 	; Increase registry key index
	Goto loop

  dotnet_found:
    StrCpy $R0 "true"

  clean:
    ; Pop the variables we pushed earlier
    Pop $1
    Pop $0

  ; $R0 contains "true" or "false"
FunctionEnd

!macro CheckDotNET
DetailPrint "Sprawdzanie istniejącej wersji .NET Framework..."
StrCpy $8 ""
CheckBegin:
  Call IsRequiredDotNetVersionAvailable

  ${If} $R0 == "true"
    Goto ValidDotNET
  ${Else}
    DetailPrint "Nie znaleziono .NET Framework ${DOTNET_VERSION}"
    ${If} $8 == ""
      Goto InvalidDotNET
    ${Else}
      Goto InvalidDotNetAfterInstall
    ${EndIf}
  ${EndIf}

InvalidDotNET:
  MessageBox MB_YESNO|MB_ICONQUESTION \
    "Program ${PRODUCT_NAME} wymaga pakietu Microsoft .NET Framework ${DOTNET_VERSION}, który nie jest obecnie zainstalowany na Twoim komputerze.$\r$\n$\r$\nCzy zainstalować?" \
  IDYES Install IDNO AbortMe

AbortMe:
  DetailPrint "Instalacja przerwana z powodu braku .NET Framework"
  MessageBox MB_OK "Pakiet .NET Framework ${DOTNET_VERSION} jest wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

Install:
  DetailPrint "Instalowanie .NET Framework ${DOTNET_VERSION}..."
  ExecWait 'additional/runDotNet.exe' $R1

  ; 1641 - Instalator rozpoczął ponowny rozruch.
  ; 3010 - Ukończenie instalacji wymaga ponownego uruchomienia
  ${If} $R1 == 3010
    DetailPrint "Będzie wymagane ponowne uruchomienie komputera."
    SetRebootFlag true
  ${EndIf}

  DetailPrint "Instalacja .NET Framework ${DOTNET_VERSION} zakończona (kod wyjścia: $R1). Sprawdzanie..."
  StrCpy $8 "AfterInstall"
  Goto CheckBegin

InvalidDotNetAfterInstall:
  DetailPrint "Instalacja przerwana po nieprawidłowej instalacji .NET Framework"
  MessageBox MB_OK "Instalacja pakietu .NET Framework ${DOTNET_VERSION} nie powiodła się. Jest to element wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

ValidDotNET:
  DetailPrint "Znaleziono .NET Framework ${DOTNET_VERSION}."
!macroend