# xDSCSEPVIE #

## Overview  ##

This custom resource runs the Symentec VIE tool to scan current drives along with newly added drives. The scan result of a drive is outputted to C:\Windows\temp and used to identify if a drive has already been scanned or not.

### Parameters ###

**Ensure**

*Note: This is a required parameter*

- Present - Runs the SEP VIe tool against any drives
- Absent - Removes the CSV file from C:\Windows\Temp


**VIELocation**

*Note: This is a required parameter*

- The physical path on the file system where the Symantec VIE tool is located

### Example ###

    File Copytools
    {
      Ensure = "Present"
      Type = "Directory"
      Recurse = $true
      Sourcepath = "\\fileshare\setups$\Tools"
      Destinationpath = "C:\Tools"
      MatchSource = $true
      Force = $true
    }
    xDSCSEPVIE RunVIE
    {
      VIELocation = "C:\Tools\VIE\vietool.exe"
      Ensure = "Present"
      Dependson = "[File]Copytools"
    }
