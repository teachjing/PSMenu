Import-module "$($PSScriptRoot)\..\PSMenu" -Force

Show-Menu @("Option A", "Option B", $(Get-MenuSeparator), "Quit")