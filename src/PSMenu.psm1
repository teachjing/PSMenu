function Format-MenuItem(
    [Parameter(Mandatory)] $MenuItem, 
    [Switch] $MultiSelect, 
    [Parameter(Mandatory)][bool] $IsItemSelected, 
    [Parameter(Mandatory)][bool] $IsItemFocused) {
    $SelectionPrefix = ''
    if ($MultiSelect) {
        $SelectionPrefix = if ($SelectionPrefix) { '[x] ' } else { '[ ] ' }
    }

    $WindowWidth = (Get-Host).UI.RawUI.WindowSize.Width
    $ItemText = $MenuItem.ToString().PadRight($WindowWidth - ($Item.Length + 2), ' ')
    $FocusPrefix = if ($IsItemFocused) { '> ' } else { '  ' }

    $Text = "{0}{1}{2}" -f $FocusPrefix, $SelectionPrefix, $ItemText

    Return $Text
}

function Write-MenuItem(
    [Parameter(Mandatory)][String] $MenuItem,
    [Switch]$IsFocused,
    [ConsoleColor]$FocusColor) {
    if ($IsFocused) {
        Write-Host $MenuItem -ForegroundColor $FocusColor
    }
    else {
        Write-Host $MenuItem
    }
}

function Write-Menu {
    param ([array]$MenuItems, $MenuPosition, $MultiSelect, $CurrentSelection, [array]$Commands, [ConsoleColor]$ItemFocusColor)
    $MenuItemCount = $MenuItems.length
    $WindowHeight = (Get-Host).UI.RawUI.WindowSize.Height - 2;

    $CurrentIndex = 0;

    if ($MenuItemCount -gt $WindowHeight) {
        $MenuItemCount = $WindowHeight;
        if ($MenuPosition -gt $MenuItemCount) {
            $CurrentIndex = $MenuPosition - $MenuItemCount;
        }
    }

    for ($i = 0; $i -le $MenuItemCount; $i++) {
        if ($MenuItems[$CurrentIndex] -ne $null) {
            $MenuItemStr = $MenuItems[$CurrentIndex].ToString()
            $IsItemSelected = $CurrentSelection -contains $CurrentIndex
            $IsItemFocused = $CurrentIndex -eq $MenuPosition

            $DisplayText = Format-MenuItem -MenuItem $MenuItemStr -MultiSelect:$MultiSelect -IsItemSelected:$IsItemSelected -IsItemFocused:$IsItemFocused
            Write-MenuItem -MenuItem $DisplayText -IsFocused:$IsItemFocused -FocusColor $ItemFocusColor
        }
        $CurrentIndex++;
    }

    if ($Commands.Count -ne 0) {
        Write-Host ($Commands -join ", ")
    }
}

function Toggle-Selection {
    param ($Position, [array]$CurrentSelection)
    if ($CurrentSelection -contains $Position) { 
        $result = $CurrentSelection | where { $_ -ne $Position }
    }
    else {
        $CurrentSelection += $Position
        $result = $CurrentSelection
    }
    $result
}

function Show-Menu {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, Position = 0)][Array] $MenuItems,
        [Switch]$ReturnIndex, 
        [Switch]$MultiSelect, 
        [ConsoleColor] $ItemFocusColor = [ConsoleColor]::Green,
        [Array]$Commands
    )

    if ($Host.Name -ine "ConsoleHost") {
        Throw "This host is $($Host.Name) and does not support an interactive menu."
    }

    $VKeyCode = 0
    $Position = 0
    $Command = ''
    $CommandHash = @{ }
    $CommandText = @(0) * $Commands.Count
    if ($Commands.Count -ne 0) {
        for ($i = 0; $Commands.Count - 1; $i++) {
            $c = $Commands[$i];
            if ($c -eq $null) {
                break;
            }		
            $k = $c[0];
            $CommandHash[$k] = $c;
            $CommandText[$i] = '[' + $k + ']' + $c.Substring(1);		
        }
    }
    $CurrentSelection = @()
    $CursorPosition = [System.Console]::CursorTop
    [console]::CursorVisible = $false #prevents cursor flickering
    
    if ($MenuItems.Length -gt 0) {
        Write-Menu $MenuItems $Position $MultiSelect $CurrentSelection $CommandText $ItemFocusColor
        While ($VKeyCode -ne 13 -and $VKeyCode -ne 27 -and $Command -eq '') {
            $CurrentPress = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
            $VKeyCode = $CurrentPress.virtualkeycode
            If ($VKeyCode -eq 38 -or $CurrentPress.Character -eq 'k') { $Position-- }
            If ($VKeyCode -eq 40 -or $CurrentPress.Character -eq 'j') { $Position++ }			
            If ($CurrentPress.Character -eq ' ') { $CurrentSelection = Toggle-Selection $Position $CurrentSelection }
            If ($Position -lt 0) { $Position = 0 }
            If ($VKeyCode -eq 27) { $Position = $null }
            If ($Position -ge $MenuItems.length) { $Position = $MenuItems.length - 1 }
            If ($Commands.Count -ne 0) {
                foreach ($key in $CommandHash.keys) {
                    If ($CurrentPress.Character -eq $key) { 
                        $val = $CommandHash[$key];
                        $Command = $val;
                        break; 
                    }
                }
            }
            If ($VKeyCode -ne 27) {
                [System.Console]::SetCursorPosition(0, $CursorPosition)
                Write-Menu $MenuItems $Position $MultiSelect $CurrentSelection $CommandText $ItemFocusColor
            }
        }
    }
    else {
        $Position = $null
    }
    [console]::CursorVisible = $true

    if ($ReturnIndex -eq $false -and $Position -ne $null) {
        if ($MultiSelect) {
            Return Get-CurrentSelectedValue -Command $Command -Value $MenuItems[$CurrentSelection]
			
        }
        else {
            Return Get-CurrentSelectedValue -Command $Command -Value $MenuItems[$Position]
        }
    }
    else {
        if ($MultiSelect) {
            Return Get-CurrentSelectedValue -Command $Command -Value $CurrentSelection
        }
        else {
            Return Get-CurrentSelectedValue -Command $Command -Value $Position
        }
    }
}

function Get-CurrentSelectedValue {
    Param($Command, $Value)
    if ($Command -ne '') {
        Return @($Command, @($Value));
    }
    else {
        Return $Value;
    }
}

# Exports
Export-ModuleMember -Function Show-Menu
