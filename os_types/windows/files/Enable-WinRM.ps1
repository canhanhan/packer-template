Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

try
{
  Write-Debug "Trying to create a new self-signed certificate"
  $certificate = New-SelfSignedCertificate -DnsName "$env:COMPUTERNAME" -CertStoreLocation cert:\LocalMachine\My
  $certificateThumbprint = $certificate.Thumbprint

  Write-Debug "Enabling WinRM"
  Enable-PSRemoting -Force | Out-Null

  Write-Debug "Enabling CredSSP"
  Enable-WSManCredSSP -Role Server -Force | Out-Null

  Write-Debug "Configuring TLS 1.2"
  $tlsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2"
  New-Item -Path $tlsPath -Type Container -Force | Out-Null 
  New-Item -Path "$tlsPath\Server" -Type Container -Force | Out-Null 
  New-Item -Path "$tlsPath\Client" -Type Container -Force | Out-Null 
  New-ItemProperty -Path "$tlsPath\Server" -Name "DisabledByDefault" -Value 0 -PropertyType "DWORD" -Force | Out-Null
  New-ItemProperty -Path "$tlsPath\Client" -Name "DisabledByDefault" -Value 0 -PropertyType "DWORD" -Force | Out-Null

  $httpListener =  Get-ChildItem -Path WSMan:\localhost\Listener | Where-Object { $_.Keys -icontains "Transport=HTTP" }
  if ($null -eq $httpListener)
  {
    Write-Debug "Creating HTTP listener"
    New-Item -Path "WSMan:\LocalHost\Listener" -Transport "HTTP" -Address "*" -Force | Out-Null
  }

  $httpsListener =  Get-ChildItem -Path "WSMan:\localhost\Listener" | Where-Object { $_.Keys -icontains "Transport=HTTPS" }
  if ($null -eq $httpsListener)
  {
    Write-Debug "Creating HTTPS listener"
    New-Item -Path "WSMan:\LocalHost\Listener" -Transport "HTTPS" -Address "*" -CertificateThumbPrint $certificateThumbprint -Force | Out-Null
  }

  Write-Debug "Restarting WinRM service"
  Restart-Service -Name WinRM -Force | Out-Null

  $fw = New-Object -ComObject hnetcfg.fwpolicy2
  if ($null -eq $fw.Rules.Count)
  {
    Write-Debug "Firewall is disabled."
  }
  else
  {
    $rules = @($fw.Rules | Where-Object { $_.Name -ieq "Windows Remote Management (HTTP-In)" })
    if ($rules.Length -eq 0)
    {
      Write-Debug "Creating HTTP firewall exception"
      $rule = New-Object -ComObject HNetCfg.FWRule
      $rule.Name = "Windows Remote Management (HTTP-In)"
      $rule.ApplicationName = "System"
      $rule.Protocol = 6 #NET_FW_IP_PROTOCOL_TCP
      $rule.LocalPorts = 5985
      $rule.Enabled = $true
      $rule.Grouping = "@firewallapi.dll,-30252"
      $rule.Profiles = 7 # all
      $rule.Action = 1 # NET_FW_ACTION_ALLOW
      $rule.EdgeTraversal = $false
      [void]$fw.Rules.Add($rule)
    }
    else
    {
      Write-Debug "Enabling HTTP firewall exception"
      $rules | ForEach-Object { $_.Enabled = $true }
    }
    
    $rules = @($fw.Rules | Where-Object { $_.Name -ieq "Windows Remote Management (HTTPS-In)" })
    if ($rules.Length -eq 0)
    {
      Write-Debug "Creating HTTPS firewall exception"
      $rule = New-Object -ComObject HNetCfg.FWRule
      $rule.Name = "Windows Remote Management (HTTPS-In)"
      $rule.ApplicationName = "System"
      $rule.Protocol = 6 #NET_FW_IP_PROTOCOL_TCP
      $rule.LocalPorts = 5986
      $rule.Enabled = $true
      $rule.Grouping = "@firewallapi.dll,-30252"
      $rule.Profiles = 7 # all
      $rule.Action = 1 # NET_FW_ACTION_ALLOW
      $rule.EdgeTraversal = $false
      [void]$fw.Rules.Add($rule)
    }
    else
    {
      Write-Debug "Enabling HTTPS firewall exception"
      $rules | ForEach-Object { $_.Enabled = $true }
    }
  }
}
catch
{
  throw
}