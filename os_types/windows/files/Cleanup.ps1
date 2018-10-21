$WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
Remove-ItemProperty -Path $WinlogonPath -Name "AutoAdminLogon"
Remove-ItemProperty -Path $WinlogonPath -Name "DefaultUserName"

Get-WindowsFeature | Where-Object { -not $_.Installed } | Uninstall-WindowsFeature
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

wget http://download.sysinternals.com/files/SDelete.zip -OutFile sdelete.zip
[System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory("sdelete.zip", ".") 
./sdelete.exe /accepteula -z c: