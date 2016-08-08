Import-Module -Name .\DSCResources\xDSCSEPVIE\xDSCSEPVIE.psm1

$Global:DSCModuleName      = 'xDSCSEPVIE' 
$Global:DSCResourceName    = 'xDSCSEPVIE'

InModuleScope -ModuleName xDSCSEPVIE -ScriptBlock {
  $VIELocation = 'C:\Temp\doesntmatter.exe'

  $global:mockedVolume = [pscustomobject] @{
    FileSystemLabel = 'myLabel'
    DriveLetter     = 'C'
  }
  $global:mockedCSVSuccess = [pscustomobject] @{
    DriveLetter = 'C'
    DateScanned = (Get-Date -Format dd/MM/yyyy)
  }
  $global:mockedCSVFailure = @()
  $global:mockedCSVFailure += [pscustomobject] @{
    DriveLetter = 'C'
    DateScanned = (Get-Date -Format dd/MM/yyyy)
  }
  $global:mockedCSVFailure += [pscustomobject] @{
    DriveLetter = 'D'
    DateScanned = (Get-Date -Format dd/MM/yyyy)
  }

  Describe -Name 'Testing mocks' -Fixture {
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSVSuccess
    }
    Mock -CommandName Get-Volume -MockWith {
      $global:mockedVolume
    }
    Mock -CommandName Test-Path -MockWith {
      return $true
    }
    It -name 'import-csv' -test {
      (Import-Csv).driveletter | Should Be 'C'
    }
    It -name 'get-volume' -test {
      (Get-Volume).driveletter  | Should Be 'C'
    }
    It -name 'test-path' -test {
      Test-Path -Path C:\windows\temp\VIEDrives.csv  | Should Be 'true'
    }
  }
  Describe -Name 'Testing if functions return correct objects' -Fixture {
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSVSuccess
    }
    Mock -CommandName Get-Volume -MockWith {
      $global:mockedVolume
    }
    Mock -CommandName Test-Path -MockWith {
      return $true
    }
    It -name 'Get-TargetResource returns a hashtable' -test {
      Get-TargetResource -VIELocation $VIELocation | Should Be 'System.Collections.Hashtable'
    }

    It -name 'Test-TargetResource returns true or false' -test {
      (Test-TargetResource -VIELocation $VIELocation -Ensure Present).GetType() -as [string] | Should Be 'bool'
    }
  }

  Describe -Name "Testing $($Global:DSCResourceName)\Get-TargetResource present/absent logic" -Fixture {
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSVSuccess
    }
    Mock -CommandName Get-Volume -MockWith {
      $global:mockedVolume
    }
    Mock -CommandName Test-Path -MockWith {
      return $true
    }
    It -name 'Get-TargetResource should return present' -test {
      (Get-TargetResource -VIELocation $VIELocation).Values | Should Be 'Present'
    }
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSVFailure
    }
    It -name 'Get-TargetResource should return absent' -test {
      (Get-TargetResource -VIELocation $VIELocation).Values | Should Be 'Absent'
    }
  }
  
  
  
  Describe -Name "Testing $($Global:DSCResourceName)\Test-TargetResource logic" -Fixture {
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSVSuccess
    }
    Mock -CommandName Get-Volume -MockWith {
      $global:mockedVolume
    }
    Mock -CommandName Test-Path -MockWith {
      return $true
    }
    It -name 'Test-TargetResource should return true' -test {
      Test-TargetResource -VIELocation $VIELocation -Ensure Present | Should Be 'True'
    }
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSVFailure
    }    
    It -name 'Test-TargetResource should return false' -test {
      Test-TargetResource -VIELocation $VIELocation -Ensure Absent | Should Be 'True'
    }
  }
}
