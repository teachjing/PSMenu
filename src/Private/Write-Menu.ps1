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
    param (
        [array] $MenuItems, 
        $MenuPosition,
        [Switch] $MultiSelect, 
        $CurrentSelection, 
        [array]$Commands, 
        [ConsoleColor] $ItemFocusColor,
        [ScriptBlock] $MenuItemFormatter)
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
        if ($null -eq $MenuItems[$CurrentIndex]) {
            Continue
        }

        $MenuItemStr = & $MenuItemFormatter $($MenuItems[$CurrentIndex])
        if (!$MenuItemStr) {
            Throw "'MenuItemFormatter' returned an empty string for item #$CurrentIndex"
        }

        $IsItemSelected = $CurrentSelection -contains $CurrentIndex
        $IsItemFocused = $CurrentIndex -eq $MenuPosition

        $DisplayText = Format-MenuItem -MenuItem $MenuItemStr -MultiSelect:$MultiSelect -IsItemSelected:$IsItemSelected -IsItemFocused:$IsItemFocused
        Write-MenuItem -MenuItem $DisplayText -IsFocused:$IsItemFocused -FocusColor $ItemFocusColor

        $CurrentIndex++;
    }

    if ($Commands.Count -ne 0) {
        Write-Host ($Commands -join ", ")
    }
}
