REM ##########################################
REM # Post Configuration Installation
REM ##########################################

@ECHO OFF
for %%i in ("%~dp0..") do set "folder=%%~fi"

ECHO [LOG] - Activation du Framework .Net 3.5...
DISM.exe /online /enable-feature /featurename:NetFx3
ECHO [LOG] - Activation du Framework .Net 3.5 : OK

ECHO [LOG] - Installation de Microsoft Visual C++ 2005 (x86 et x64)...
"%folder%\Sources\Microsoft_VisualC++2005_8.0.61000_En\vcredist_x64.exe" /q
"%folder%\Sources\Microsoft_VisualC++2005_8.0.61000_En\vcredist_x86.exe" /q
ECHO [LOG] - Installation de Microsoft Visual C++ 2005 (x86 et x64) : OK

ECHO [LOG] - Installation de Microsoft Visual C++ 2008 (x86 et x64)...
"%folder%\Sources\Microsoft_VisualC++2008_9.0.30729_En\vcredist_x64.exe" /q /norestart
"%folder%\Sources\Microsoft_VisualC++2008_9.0.30729_En\vcredist_x86.exe" /q /norestart
ECHO [LOG] - Installation de Microsoft Visual C++ 2008 (x86 et x64) : OK


ECHO [LOG] - Installation de Microsoft Visual C++ 2010 (x86 et x64)...
"%folder%\Sources\Microsoft_VisualC++2010_10.0.40219_En\vcredist_x64.exe" /q /norestart
"%folder%\Sources\Microsoft_VisualC++2010_10.0.40219_En\vcredist_x86.exe" /q /norestart
ECHO [LOG] - Installation de Microsoft Visual C++ 2010 (x86 et x64) : OK


ECHO [LOG] - Installation de Microsoft Visual C++ 2012 (x86 et x64)...
"%folder%\Sources\Microsoft_VisualC++2012_11.0.61030_En\vcredist_x64.exe" /q /norestart
"%folder%\Sources\Microsoft_VisualC++2012_11.0.61030_En\vcredist_x86.exe" /q /norestart
ECHO [LOG] - Installation de Microsoft Visual C++ 2012 (x86 et x64) : OK


ECHO [LOG] - Installation de Microsoft Visual C++ 2013 (x86 et x64)...
"%folder%\Sources\Microsoft_VisualC++2013_12.0.21005_En\vcredist_x64.exe" /q /norestart
"%folder%\Sources\Microsoft_VisualC++2013_12.0.21005_En\vcredist_x86.exe" /q /norestart
ECHO [LOG] - Installation de Microsoft Visual C++ 2013 (x86 et x64) : OK

ECHO [LOG] - Installation de .NET 4.5.1 SP1...
"%folder%\Sources\Microsoft_DotNet_4.5.1SP1_En\NDP451-KB2858728-x86-x64-AllOS-ENU" /q /norestart
ECHO [LOG] - Installation de .NET 4.5.1 SP1 : OK

ECHO [LOG] - Installation de Microsoft Windows Management Framework v3.0...
wusa.exe "%folder%\Sources\Microsoft_WindowManagementFramework_3.0_En\Windows6.1-KB2506143-x64.msu" /quiet /norestart
ECHO [LOG] - Installation de Microsoft Windows Management Framework v3.0 : OK

ECHO [LOG] - Installation terminee. Pressez une touche pour clore la console.
PAUSE
