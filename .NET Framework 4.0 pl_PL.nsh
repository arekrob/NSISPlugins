# Runs the Microsoft .NET Framework version 4.0 Redistributable if the user does not have the correct version.

Function GetLatestDotNETVersion
  ;Save the variables in case something else is using them

  Push $0		; Registry key enumerator index
  Push $1		; Registry value
  Push $2		; Temp var
; Push $R0	; Max version number
  Push $R1	; Looping version number

  StrCpy $R0 "0.0.0"
  StrCpy $0 0

  loop:
    ; Get each sub key under "SOFTWARE\Microsoft\NET Framework Setup\NDP"
    EnumRegKey $1 HKLM "SOFTWARE\Microsoft\NET Framework Setup\NDP" $0

    StrCmp $1 "" done 	; jump to end if no more registry keys

    IntOp $0 $0 + 1 	; Increase registry key index
    StrCpy $R1 $1 "" 1 	; Looping version number, cut of leading 'v'

    ${VersionCompare} $R1 $R0 $2
    ; $2=0  Versions are equal, ignore
    ; $2=1  Looping version $R1 is newer
    ; $2=2  Looping version $R1 is older, ignore

    IntCmp $2 1 newer_version loop loop

  newer_version:
    StrCpy $R0 $R1
    goto loop

  done:
    ; If the latest version is 0.0.0, there is no .NET installed ?!
    ${VersionCompare} $R0 "0.0.0" $2
    IntCmp $2 0 no_dotnet clean clean

  no_dotnet:
    StrCpy $R0 ""

  clean:
    ; Pop the variables we pushed earlier
    Pop $R1
    Pop $2
    Pop $1
    Pop $0

  ; $R0 contains the latest .NET version or empty string if no .NET is available
FunctionEnd

!macro CheckDotNET

!define DOTNET_VERSION "4.0" ; minimum .net runtime version

DetailPrint "Sprawdzanie istniejącej wersji .NET Framework..."
StrCpy $8 ""
CheckBegin:
  Call GetLatestDotNETVersion
;  Pop $R0

  ${VersionCompare} $R0 ${DOTNET_VERSION} $1
  ${If} $1 == 2
    DetailPrint "Znaleziono .NET Framework w wersji $R0, ale wymagana jest ${DOTNET_VERSION}"
    ${If} $8 == ""
      Goto InvalidDotNET
    ${Else}
      Goto InvalidDotNetAfterInstall
    ${EndIf}
  ${EndIf}

  Goto ValidDotNET

InvalidDotNET:
  MessageBox MB_YESNO|MB_ICONQUESTION \
    "Program ${PRODUCT_NAME} wymaga pakietu Microsoft .NET Framework 4 Client Profile, który nie jest obecnie zainstalowany na Twoim komputerze.$\r$\n$\r$\nCzy zainstalować?" \
  IDYES Install IDNO AbortMe

AbortMe:
  DetailPrint "Instalacja przerwana z powodu braku .NET Framework"
  MessageBox MB_OK "Pakiet Microsoft .NET Framework 4 Client Profile jest wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

Install:
  DetailPrint "Instalowanie Microsoft .NET Framework 4 Client Profile."
  ExecWait '"additional/dotNetFx40_Client_x86_x64.exe" /passive /showfinalerror /norestart /x86 /x64' $R1

  ; 1641 - Instalator rozpoczął ponowny rozruch.
  ; 3010 - Ukończenie instalacji wymaga ponownego uruchomienia
  ${If} $R1 == 3010
    DetailPrint "Będzie wymagane ponowne uruchomienie komputera."
    SetRebootFlag true
  ${EndIf}

  DetailPrint "Instalacja Microsoft .NET Framework 4 Client Profile zakończona (kod wyjścia: $R1). Sprawdzanie..."
  StrCpy $8 "AfterInstall"
  Goto CheckBegin

InvalidDotNetAfterInstall:
  DetailPrint "Instalacja przerwana po nieprawidłowej instalacji .NET Framework"
  MessageBox MB_OK "Instalacja pakietu Microsoft .NET Framework 4 Client Profile nie powiodła się. Jest to element wymagany do uruchomienia programu ${PRODUCT_NAME}. Instalacja zostanie przerwana."
  Quit

ValidDotNET:
  DetailPrint ".NET Framework 4 jest zainstalowany."
!macroend