function Get-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $VIELocation
  )

  $volumes = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.FileSystemLabel -ne 'System Reserved' } | Sort-Object DriveLetter
  if (Test-Path -LiteralPath 'C:\Windows\Temp\VIEdrives.csv') {
    #Write-Host "exists"
    $csv = Import-Csv 'C:\Windows\Temp\VIEdrives.csv'
    foreach ($drive in $csv) {
      if ($drive.driveletter -in $volumes.driveletter) {
        return @{
          Ensure = 'Present';
        }
      }
    }
  }
  else {
    return @{
      Ensure = 'Absent';
    }
  }
  else {
    return @{
      Ensure = 'Absent';
    }
  }
}

function Set-TargetResource
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $VIELocation,

    [ValidateSet('Present','Absent')]
    [System.String]
    $Ensure
  )

  $volumes = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.FileSystemLabel -ne 'System Reserved' } | Sort-Object DriveLetter

  if ($Ensure -eq 'Present') {
    if (Test-Path -LiteralPath 'C:\Windows\Temp\VIEdrives.csv') {
      $csv = Import-Csv 'C:\Windows\Temp\VIEdrives.csv'
      foreach ($volume in $volumes) {
        if ($volume.driveletter -notin $csv.driveletter) {
          #Write-Host "Starting VIE tool for drive" $volume.driveletter
          & $VIELocation ($volume.driveletter + ':') --generate
          $driveletter = $volume.driveletter
          New-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -ErrorAction SilentlyContinue
          Write-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -EventId 3001 -EntryType Information -Message "Executed VIE against $driveletter drive"
          $volume | Select-Object Driveletter,@{ n = 'Datescanned'; e = { Get-Date } } | Export-Csv -nti 'C:\Windows\Temp\VIEdrives.csv' -Append
        }
        else {
        }
      }
    }
    else {
      foreach ($volume in $volumes) {
        #Write-Host "Starting VIE tool for drive" $volume.driveletter
        & $VIELocation ($volume.driveletter + ':') --generate
        $driveletter = $volume.driveletter
        New-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -ErrorAction SilentlyContinue
        Write-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -EventId 3001 -EntryType Information -Message "Executed VIE against $driveletter drive"
        $volume | Select-Object Driveletter,@{ n = 'Datescanned'; e = { Get-Date } } | Export-Csv -nti 'C:\Windows\Temp\VIEdrives.csv' -Append
      }
    }
  }
  elseif ($Ensure -eq 'Absent') {
    if (Test-Path -LiteralPath 'C:\Windows\Temp\VIEdrives.csv') {
      foreach ($volume in $volumes) {
        #Write-Host "Removing VIE tool for drive" $volume.driveletter
        & $VIELocation ($volume.driveletter + ':') --clear
        $driveletter = $volume.driveletter
        New-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -ErrorAction SilentlyContinue
        Write-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -EventId 3001 -EntryType Information -Message "Cleared VIE against $driveletter drive"
        Remove-Item -LiteralPath 'C:\Windows\Temp\VIEdrives.csv' -Confirm:$false -ErrorAction SilentlyContinue
      }
    }
    else {
      #Write-Host "Removing VIE tool for drive" $volume.driveletter
      & $VIELocation ($volume.driveletter + ':') --clear
      $driveletter = $volume.driveletter
      New-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -ErrorAction SilentlyContinue
      Write-EventLog -LogName 'Microsoft-Windows-DSC/Operational' -Source 'xDSCSEPVIE' -EventId 3001 -EntryType Information -Message "Cleared VIE against $driveletter drive"
      Remove-Item -LiteralPath 'C:\Windows\Temp\VIEdrives.csv' -Confirm:$false -ErrorAction SilentlyContinue
    }
  }
}

function Test-TargetResource
{
  [CmdletBinding()]
  [OutputType([System.Boolean])]
  param
  (
    [Parameter(Mandatory = $true)]
    [System.String]
    $VIELocation,

    [ValidateSet('Present','Absent')]
    [System.String]
    $Ensure
  )

  $volumes = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.FileSystemLabel -ne 'System Reserved' } | Sort-Object DriveLetter
  if ($Ensure -eq 'Present') {
    if (Test-Path -LiteralPath 'C:\Windows\Temp\VIEdrives.csv') {
      $csv = Import-Csv 'C:\Windows\Temp\VIEdrives.csv'
      foreach ($volume in $volumes) {
        if ($volume.driveletter -in $csv.driveletter) {
          $driveletter = $volume.driveletter
          #Write-Host "$driveletter exists"
          $result = $true
        }
        else {
          $driveletter = $volume.driveletter
          #Write-Host "$driveletter doesn't exist"
          $result = $false
        }
      }
    }
    else {
      $result = $false
    }
  }
  elseif ($Ensure -eq 'Absent') {
    if (Test-Path -LiteralPath 'C:\Windows\Temp\VIEdrives.csv') {
      $csv = Import-Csv 'C:\Windows\Temp\VIEdrives.csv'
      foreach ($volume in $volumes) {
        if ($volume.driveletter -notin $csv.driveletter) {
          #Write-Host "$driveletter doesn't exist"
          $result = $true
        }
        else {
          $driveletter = $volume.driveletter
          #Write-Host "$driveletter exists"
          $result = $false
        }
      }
    }
    else {
      $result = $true
    }
  }

  if ($result -eq $true) {
    return $true
  }
  else {
    return $false
  }
}

Export-ModuleMember -Function *-TargetResource
