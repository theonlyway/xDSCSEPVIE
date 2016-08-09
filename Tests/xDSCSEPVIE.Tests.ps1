Import-Module -Name .\DSCResources\xDSCSEPVIE\xDSCSEPVIE.psm1

$Global:DSCModuleName      = 'xDSCSEPVIE' 
$Global:DSCResourceName    = 'xDSCSEPVIE'

InModuleScope -ModuleName xDSCSEPVIE -ScriptBlock {
  $VIELocation = 'C:\Temp\doesntmatter.exe'

  $global:mockedVolume = [pscustomobject] @{
    FileSystemLabel = 'myLabel'
    DriveLetter     = 'C'
    DriveType       = 'Fixed'
  }
  $global:mockedCSV = @()
  $global:mockedCSV += [pscustomobject] @{
    DriveLetter = 'C'
    DateScanned = (Get-Date -Format dd/MM/yyyy)
  }
  $global:mockedCSV += [pscustomobject] @{
    DriveLetter = 'GG'
    DateScanned = (Get-Date -Format dd/MM/yyyy)
  }

  Describe -Name 'Testing if functions return correct objects' -Fixture {
    Mock -CommandName Import-CSV -MockWith {
      $global:mockedCSV
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
    foreach ($drivetest in $global:mockedCSV ) 
    {
      if ($drivetest.driveLetter -in $global:mockedVolume.driveLetter) 
      {
        Mock -CommandName Import-CSV -MockWith {
          $drivetest
        }
        Mock -CommandName Get-Volume -MockWith {
          $global:mockedVolume
        }
        Mock -CommandName Test-Path -MockWith {
          return $true
        }
        It -name "Get-TargetResource should return present for drive letter ($($drivetest.driveletter))" -test {
          (Get-TargetResource -VIELocation $VIELocation).Values | Should Be 'Present'
        }    
      }
      else 
      {
        Mock -CommandName Import-CSV -MockWith {
          $drivetest
        }
        Mock -CommandName Get-Volume -MockWith {
          $global:mockedVolume
        }
        Mock -CommandName Test-Path -MockWith {
          return $true
        }
        It -name "Get-TargetResource should return absent for drive letter ($($drivetest.driveletter))" -test {
          (Get-TargetResource -VIELocation $VIELocation).Values | Should Be 'absent'
        }  
      }
    }
  }
  
  Describe -Name "Testing $($Global:DSCResourceName)\Test-TargetResource present/absent logic" -Fixture {
    foreach ($drivetest in $global:mockedCSV ) 
    {
      if ($drivetest.driveLetter -in $global:mockedVolume.driveLetter) 
      {
        Mock -CommandName Import-CSV -MockWith {
          $drivetest
        }
        Mock -CommandName Get-Volume -MockWith {
          $global:mockedVolume
        }
        Mock -CommandName Test-Path -MockWith {
          return $true
        }
        It -name "Test-TargetResource should return true for drive letter ($($drivetest.driveletter))" -test {
          Test-TargetResource -VIELocation $VIELocation -Ensure Present | Should Be 'True'
        }     
      }
      else 
      {
        Mock -CommandName Import-CSV -MockWith {
          $drivetest
        }
        Mock -CommandName Get-Volume -MockWith {
          $global:mockedVolume
        }
        Mock -CommandName Test-Path -MockWith {
          return $true
        }
        It -name "Test-TargetResource should return false for drive letter ($($drivetest.driveletter))" -test {
          Test-TargetResource -VIELocation $VIELocation -Ensure Absent | Should Be 'True'
        }
      }
    }
  } 
}