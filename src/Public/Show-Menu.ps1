function Show-Menu {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, Position = 0)][Array] $MenuItems,
        [Switch]$ReturnIndex, 
        [Switch]$MultiSelect, 
        [ConsoleColor] $ItemFocusColor = [ConsoleColor]::Green,
        [ScriptBlock] $MenuItemFormatter = { Param($M) Format-MenuItemDefault $M }
    )

    Test-HostSupported

    $VKeyCode = 0
    $Position = 0

    $CurrentSelection = @()
    $CursorPosition = [System.Console]::CursorTop
    
    try {
        [System.Console]::CursorVisible = $false #prevents cursor flickering

        # Body
        $WriteMenu = { 
            Write-Menu -MenuItems $MenuItems `
                -MenuPosition $Position `
                -MultiSelect:$MultiSelect `
                -ItemFocusColor $ItemFocusColor `
                -MenuItemFormatter $MenuItemFormatter
        }

        if ($MenuItems.Length -gt 0) {
            & $WriteMenu
            While ($True) {
                If (Test-KeyEscape $VKeyCode) {
                    Return $null
                }

                if (Test-KeyEnter $VKeyCode) {
                    Break
                }

                $CurrentPress = Read-VKey

                $VKeyCode = $CurrentPress.VirtualKeyCode

                If (Test-KeyUp $VKeyCode) { 
                    $Position--
                }

                If (Test-KeyDown $VKeyCode) {
                    $Position++
                }

                If (Test-KeySpace $VKeyCode) {
                    $CurrentSelection = Toggle-Selection $Position $CurrentSelection
                }

                $Position = Get-WrappedPosition $MenuItems $Position

                If (!$(Test-KeyEscape $VKeyCode)) {
                    [System.Console]::SetCursorPosition(0, $CursorPosition)
                    & $WriteMenu
                }
            }
        }
        else {
            $Position = $null
        }
    }
    finally {
        [System.Console]::CursorVisible = $true
    }

    if ($ReturnIndex -eq $false -and $null -ne $Position) {
        if ($MultiSelect) {
            Return $MenuItems[$CurrentSelection]
        }
        else {
            Return $MenuItems[$Position]
        }
    }
    else {
        if ($MultiSelect) {
            Return $CurrentSelection
        }
        else {
            Return $Position
        }
    }
}
