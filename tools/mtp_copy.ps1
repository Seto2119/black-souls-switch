[Console]::OutputEncoding=[Text.Encoding]::UTF8
$ErrorActionPreference = 'Continue'

$sh = New-Object -ComObject Shell.Application
$mtp = $sh.NameSpace(17)
$sw = ($mtp.Items() | Where-Object { $_.Name -eq 'Switch' }).GetFolder
$sd = ($sw.Items() | Where-Object { $_.Name -like '1: SD*' }).GetFolder
$swf = ($sd.Items() | Where-Object { $_.Name -eq 'switch' }).GetFolder
$bs = ($swf.Items() | Where-Object { $_.Name -eq 'black-souls' }).GetFolder
$gd = ($bs.Items() | Where-Object { $_.Name -eq 'gamedata' }).GetFolder

$localRoot = 'C:\Users\user\black-souls-switch\sd\switch\black-souls\gamedata'
$missing = Get-Content 'C:\Users\user\missing_files.txt' -Encoding UTF8

# Build folder cache: map relDir -> folder COM object, and existing-name set per folder
$folderCache = @{ '' = $gd }
function Get-DestFolder($relDir) {
    if ($folderCache.ContainsKey($relDir)) { return $folderCache[$relDir] }
    $cur = $gd
    foreach ($part in ($relDir -split '\\')) {
        if ($part -eq '') { continue }
        $found = $null
        foreach ($it in $cur.Items()) { if ($it.Name -eq $part) { $found = $it.GetFolder; break } }
        if ($null -eq $found) { return $null }
        $cur = $found
    }
    $folderCache[$relDir] = $cur
    return $cur
}

# Group missing files by dir so we enumerate each folder's existing names ONCE
$byDir = @{}
foreach ($rel in $missing) {
    $relWin = $rel -replace '/', '\'
    $d = Split-Path $relWin -Parent
    if (-not $byDir.ContainsKey($d)) { $byDir[$d] = New-Object System.Collections.ArrayList }
    [void]$byDir[$d].Add($relWin)
}

$totalToCopy = 0
$done = 0
$failed = 0
$sw2 = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($dir in ($byDir.Keys | Sort-Object)) {
    $dest = Get-DestFolder $dir
    if ($null -eq $dest) {
        $failed += $byDir[$dir].Count
        continue
    }
    # snapshot existing names once
    $existing = @{}
    foreach ($it in $dest.Items()) { $existing[$it.Name] = $true }

    foreach ($relWin in $byDir[$dir]) {
        $name = Split-Path $relWin -Leaf
        $localPath = Join-Path $localRoot $relWin
        if (-not (Test-Path -LiteralPath $localPath)) { continue }
        if ($existing.ContainsKey($name)) { continue }  # already on device
        $totalToCopy++
        try {
            $dest.CopyHere($localPath, 16)
            # wait for appearance (short, fixed attempts)
            $appeared = $false
            for ($i = 0; $i -lt 20; $i++) {
                Start-Sleep -Milliseconds 150
                foreach ($it in $dest.Items()) { if ($it.Name -eq $name) { $appeared = $true; break } }
                if ($appeared) { break }
            }
            if ($appeared) { $existing[$name] = $true; $done++ }
            else { $failed++ }
        } catch { $failed++ }

        if ($done % 10 -eq 0 -and $done -gt 0) {
            $el = $sw2.Elapsed.TotalSeconds
            $rate = [math]::Round($done / $el, 1)
            Set-Content -Path 'C:\Users\user\mtp_progress.txt' -Value "done=$done failed=$failed tocopy=$totalToCopy elapsed=$el rate=$rate/s" -Encoding UTF8
            Write-Output "progress $done copied, failed=$failed ($rate/s)"
        }
    }
}

Set-Content -Path 'C:\Users\user\mtp_progress.txt' -Value "DONE done=$done failed=$failed elapsed=$($sw2.Elapsed.TotalSeconds)" -Encoding UTF8
Write-Output "DONE done=$done failed=$failed"
