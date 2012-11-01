.386
.model flat, stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\masm32.lib

.data
Command db "WindowsInstaller-KB893803-v2-x86.exe",0
Params db "/norestart /passive",0
Verb db "open",0

.data?
lpExecInfo SHELLEXECUTEINFO <?>
hInstance HINSTANCE ?
processExitCode DWORD ?
path CHAR MAX_PATH dup (?);
path2 CHAR MAX_PATH dup (?);

.code
start:
  ;ustalamy œcie¿kê wzglêdem tego, gdzie znajduje siê ten program
  invoke GetModuleHandle, NULL;
  invoke GetModuleFileName, eax, offset path, MAX_PATH

  invoke StrLen, offset path
  sub eax, 10   ;ta liczba to dlugosc "\runWI.exe"
  invoke szLeft, offset path, offset path2, eax

  mov lpExecInfo.cbSize,sizeof SHELLEXECUTEINFO
  mov lpExecInfo.lpFile, offset Command
  mov lpExecInfo.fMask, SEE_MASK_NOCLOSEPROCESS
  mov lpExecInfo.hwnd, NULL
  mov lpExecInfo.lpVerb, offset Verb
  mov lpExecInfo.lpParameters, offset Params
  mov lpExecInfo.lpDirectory, offset path2
  mov lpExecInfo.nShow, SW_SHOW
  mov lpExecInfo.hInstApp, offset hInstance
  invoke ShellExecuteEx, offset lpExecInfo

  .if lpExecInfo.hProcess != NULL
    invoke WaitForSingleObject, lpExecInfo.hProcess, INFINITE;

    invoke GetExitCodeProcess, lpExecInfo.hProcess, offset processExitCode;
    invoke CloseHandle, lpExecInfo.hProcess;

    invoke ExitProcess,processExitCode   ;exit ok
  .endif

  invoke ExitProcess,1   ;exit error
end start
