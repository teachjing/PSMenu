Import-module "$($PSScriptRoot)\..\PSMenu" -Force

[console]::Clear()
[console]::SetCursorPosition(10,5)

Show-Menu @("option 1", "option 2", "option 3")