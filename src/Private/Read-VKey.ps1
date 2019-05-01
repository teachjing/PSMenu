function Read-VKey() {
    $CurrentHost = Get-Host
    $ErrMsg = "Current host '$CurrentHost' does not support operation 'ReadKey'"

    try {
        Return $CurrentHost.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    catch [System.NotSupportedException] {
        Write-Error -Exception $_.Exception -Message $ErrMsg
    }
    catch [System.NotImplementedException] {
        Write-Error -Exception $_.Exception -Message $ErrMsg
    }
}
