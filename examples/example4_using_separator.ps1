Import-module "$($PSScriptRoot)\PSMenu"

Show-Menu @("Option A", "Option B", $(Get-MenuSeparator), "Quit")