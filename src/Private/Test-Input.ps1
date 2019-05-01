# Ref: https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
$KeyConstants = [PSCustomObject]@{
    VK_RETURN = 0x0D;
    VK_ESCAPE = 0x1B;
    VK_UP     = 0x26;
    VK_DOWN   = 0x28;
    VK_SPACE  = 0x20;
}

function Test-KeyEnter($VKeyCode) {
    Return $VKeyCode -eq $KeyConstants.VK_RETURN
}

function Test-KeyEscape($VKeyCode) {
    Return $VKeyCode -eq $KeyConstants.VK_ESCAPE
}

function Test-KeyUp($VKeyCode) {
    Return $VKeyCode -eq $KeyConstants.VK_UP
}

function Test-KeyDown($VKeyCode) {
    Return $VKeyCode -eq $KeyConstants.VK_DOWN
}

function Test-KeySpace($VKeyCode) {
    Return $VKeyCode -eq $KeyConstants.VK_SPACE
}
