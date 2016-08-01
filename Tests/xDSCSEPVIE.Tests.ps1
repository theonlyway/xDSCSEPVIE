Import-Module -Name .\DSCResources\xDSCSEPVIE\xDSCSEPVIE.psm1

InModuleScope -ModuleName xDSCSEPVIE -ScriptBlock {
  $VIELocation = 'C:\Temp\vie.exe'

  Describe -Name 'Testing if functions return correct objects' -Fixture {
    Mock -CommandName Test-Path -MockWith {
      {
        return $true
      }
    }
    Mock -CommandName Import-CSV -MockWith {
      [PSCustomObject]@{
        DriveLetter = 'C'
        DateScanned = (Get-Date)
      }
    }
    It -name 'Get-TargetResource returns a hashtable' -test {
      Get-TargetResource -VIELocation $VIELocation | Should Be 'System.Collections.Hashtable'
    }

    It -name 'Test-TargetResource returns true or false' -test {
      (Test-TargetResource -VIELocation $VIELocation -Ensure Present).GetType() -as [string] | Should Be 'bool'
    }
  }

  Describe -Name 'Testing Get-TargetResource present/absent logic' -Fixture {
    Mock -CommandName Test-Path -MockWith {
      {
        return $true
      }
    }
    Mock -CommandName Import-CSV -MockWith {
      [PSCustomObject]@{
        DriveLetter = 'C'
        DateScanned = (Get-Date)
      }
    }

    It -name 'Get-TargetResource should return present' -test {
      (Get-TargetResource -VIELocation $VIELocation).Values | Should Be 'Present'
    }
    Mock -CommandName Import-CSV -MockWith {
      [PSCustomObject]@{
        DriveLetter = 'GG'
        DateScanned = (Get-Date)
      }
    }
    It -name 'Get-TargetResource should return absent' -test {
      (Get-TargetResource -VIELocation $VIELocation).Values | Should Be 'Absent'
    }

  }
}
