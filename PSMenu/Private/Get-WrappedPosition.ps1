function Get-WrappedPosition([Array]$MenuItems, [int]$Position) {
    If ($Position -lt 0) {
        Return $MenuItems.Count - 1
    }

    if ($Position -ge $MenuItems.Count) {
        Return 0
    }

    Return $Position
}
