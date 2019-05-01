function DrawMenu {
    param ([array]$MenuItems, $MenuPosition, $MultiSelect, $CurrentSelection, [array]$Commands)
    $l = $MenuItems.length
    $wh = (Get-Host).UI.RawUI.WindowSize.Height - 2;
    $ww = (Get-Host).UI.RawUI.WindowSize.Width;
    $idx = 0;

    if ($l -gt $wh) {
        $l = $wh;
        if ($MenuPosition -gt $l) {
            $idx = $MenuPosition - $l;
        }
    }
    for ($i = 0; $i -le $l; $i++) {
        if ($MenuItems[$idx] -ne $null) {
            $Item = $MenuItems[$idx].ToString()
            if ($MultiSelect) {
                if ($CurrentSelection -contains $idx) {
                    $Item = '[x] ' + $Item
                }
                else {
                    $Item = '[ ] ' + $Item
                }
            }
            #pad the text to ensure no artifacts when scrolling list
            $MenuText = $Item.PadRight($ww - ($Item.Length + 2), ' ');
            if ($idx -eq $MenuPosition) {
                Write-Host "> $MenuText" -ForegroundColor Green
            }
            else {
                Write-Host "  $MenuText"
            }
        }
        $idx++;
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
    Param ([Parameter(Mandatory, Position = 0)][Array]$MenuItems, [Switch]$ReturnIndex, [Switch]$MultiSelect, [Array]$Commands)

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
        DrawMenu $MenuItems $Position $MultiSelect $CurrentSelection $CommandText
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
                DrawMenu $MenuItems $Position $MultiSelect $CurrentSelection $CommandText
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
