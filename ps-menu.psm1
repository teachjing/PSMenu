function DrawMenu {
    param ([array]$menuItems, $menuPosition, $Multiselect, $selection, [array]$commands)
    $l = $menuItems.length
    $wh = (Get-Host).UI.RawUI.WindowSize.Height - 2;
    $ww = (Get-Host).UI.RawUI.WindowSize.Width;
    $idx = 0;

    if($l -gt $wh) {
       $l = $wh;
       if($menuPosition -gt $l) {
           $idx = $menuPosition - $l;
       }
    }
    for ($i = 0;$i -le $l;$i++) {
		if ($menuItems[$idx] -ne $null){
			$item = $menuItems[$idx]
			if ($Multiselect)
			{
				if ($selection -contains $idx){
					$item = '[x] ' + $item
				}
				else {
					$item = '[ ] ' + $item
				}
			}
            #pad the text to ensure no artifacts when scrolling list
            $menuText = $item.PadRight($ww - ($item.Length + 2), ' ');
			if ($idx -eq $menuPosition) {
				Write-Host "> $menuText" -ForegroundColor Green
			} else {
				Write-Host "  $menuText"
			}
		}
        $idx++;
    }
	if($commands.Count -ne 0) {
		Write-Host ($commands -join ", ")
	}
}

function Toggle-Selection {
	param ($pos, [array]$selection)
	if ($selection -contains $pos){ 
		$result = $selection | where {$_ -ne $pos}
	}
	else {
		$selection += $pos
		$result = $selection
	}
	$result
}

function Menu {
    param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect, [array]$commands)
    $vkeycode = 0
    $pos = 0
	$cmd = ''
	$cmdHash = @{} 
	if($commands.Count -ne 0) {
		#$commands| Foreach-Object { $cmdHash[$_[0]] = $_ }
		for($i = 0; $commands.Count -1; $i++){
			$c = $commands[$i];
			if($c -eq $null){
				break;
			}		
			$k = $c[0];
			$cmdHash[$k] = $c;
			$commands[$i] = '[' + $k + ']' + $c.Substring(1);		
		}
	}
    $selection = @()
    $cur_pos = [System.Console]::CursorTop
    [console]::CursorVisible=$false #prevents cursor flickering
    if ($menuItems.Length -gt 0)
	{
        DrawMenu $menuItems $pos $Multiselect $selection $commands
		While ($vkeycode -ne 13 -and $vkeycode -ne 27 -and $cmd -eq '') {
			$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
			$vkeycode = $press.virtualkeycode
			If ($vkeycode -eq 38 -or $press.Character -eq 'k') {$pos--}
			If ($vkeycode -eq 40 -or $press.Character -eq 'j') {$pos++}			
			If ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
			if ($pos -lt 0) {$pos = 0}
			If ($vkeycode -eq 27) {$pos = $null }
			if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
			#dg
			if($commands.Count -ne 0) {
				foreach($key in $cmdHash.keys) {
					If ($press.Character -eq $key) { 
						$val = $cmdHash[$key];
						if($Multiselect) {
							$cmd = $val;
						} else {
							$cmd = $val
						}
						break; 
					}
				}
			}
			#/dg
			if ($vkeycode -ne 27)
			{
				[System.Console]::SetCursorPosition(0,$cur_pos)
				DrawMenu $menuItems $pos $Multiselect $selection $commands
			}
		}
	}
	else 
	{
		$pos = $null
	}
    [console]::CursorVisible=$true

	if ($ReturnIndex -eq $false -and $pos -ne $null)
	{
		if ($Multiselect){
			return get-SelectedValue -cmd $cmd -value $menuItems[$selection]
			
		}
		else {
			return get-SelectedValue -cmd $cmd -value $menuItems[$pos]
		}
	}
	else 
	{
		if ($Multiselect){
			return get-SelectedValue -cmd $cmd -value $selection
		}
		else {
			return get-SelectedValue -cmd $cmd -value $pos
		}
	}
}

function get-SelectedValue {
	Param($cmd, $value)
	if($cmd -ne '') {
		return @($cmd, @($value));
	}else {
		return $value;
	}
}
