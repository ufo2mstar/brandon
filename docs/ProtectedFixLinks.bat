Cls

@echo off

@echo Disabling Protected mode......

%windir%\system32\Reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1" /v "2500" /t reg_dword /d 00000000 /f

%windir%\system32\Reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2" /v "2500" /t reg_dword /d 00000000 /f

%windir%\system32\Reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /v "2500" /t reg_dword /d 00000000 /f

%windir%\system32\Reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4" /v "2500" /t reg_dword /d 00000000 /f

%windir%\system32\Reg.exe add "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "NoProtectedModeBanner" /t reg_dword /d 00000001 /f

exit