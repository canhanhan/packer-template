Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Expand-ZIPFile($file, $destination)
{
  $shell = new-object -com shell.application
  $zip = $shell.NameSpace($file)
  foreach($item in $zip.items())
  {
    $shell.Namespace($destination).copyhere($item)
  }
}

try
{
  if (-not (Test-Path -Path "C:\temp")) { New-Item -Path "C:\temp" -ItemType Directory | Out-Null }
  $webClient = New-Object System.Net.WebClient

  if (-not (Test-Path -Path "C:\temp\dotnet.exe")) {
    $webClient.DownloadFile("https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe","C:\temp\dotnet.exe")
  }
  $process = Start-Process -FilePath "C:\temp\dotnet" -ArgumentList ("/q", "/norestart") -Wait -PassThru
  if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) { throw ".Net 4.5.2 installation failed with $($process.ExitCode)" }
  Remove-Item -Path "C:\temp\dotnet.exe"

  if ($PSVersionTable.PSVersion -ge "5.1") 
  {
    Write-Output "$($PSVersionTable.PSVersion) is already installed."
    return
  }  
  
  $OsVersion = New-Object -TypeName System.Version -ArgumentList ([Environment]::OSVersion.Version.Major, [Environment]::OSVersion.Version.Minor)
  if ($OsVersion -eq "6.1")
  {
    if (-not (Test-Path -Path "C:\temp\Win7AndW2K8R2-KB3191566-x64.zip")) {
      $webClient.DownloadFile("https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win7AndW2K8R2-KB3191566-x64.zip", "C:\temp\Win7AndW2K8R2-KB3191566-x64.zip")
    }
    if (-not (Test-Path -Path "C:\temp\Win7AndW2K8R2-KB3191566-x64.msu")) {
      Expand-ZIPFile "C:\temp\Win7AndW2K8R2-KB3191566-x64.zip" "C:\temp\"
    }	
    $process = Start-Process -FilePath wusa -ArgumentList ("C:\temp\Win7AndW2K8R2-KB3191566-x64.msu", "/quiet", "/norestart") -Wait -PassThru
    if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) { throw "WMF 5.1 installation failed with $($process.ExitCode)" }
    Remove-Item -Path "C:\temp\Win7AndW2K8R2-KB3191566-x64.zip"
    Remove-Item -Path "C:\temp\Win7AndW2K8R2-KB3191566-x64.msu"
  }
  elseif ($OsVersion -eq "6.3")
  {
    if (-not (Test-Path -Path "C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu")) {
      $webClient.DownloadFile("https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu", "C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu")
    }
    $process = Start-Process -FilePath wusa -ArgumentList ("C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu", "/quiet", "/norestart") -Wait -PassThru
    if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) { throw "WMF 5.1 installation failed with $($process.ExitCode)" }
    Remove-Item -Path "C:\temp\Win8.1AndW2K12R2-KB3191564-x64.msu"
  }
}
catch
{
  throw
}