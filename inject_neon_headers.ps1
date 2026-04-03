$files = Get-ChildItem -Path . -Recurse -Filter *.md | Where-Object { 
  $_.FullName -notmatch '\\.git|\\.github|\\.gemini' -and $_.Name -ne 'README.md' 
}

foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        if ([string]::IsNullOrEmpty($content)) { continue }
        
        # Don't inject multiple times
        if ($content -match 'https://img.shields.io/badge/SECTOR-') { continue }

        $parentDir = $file.Directory.Name
        $grandparentDir = $file.Directory.Parent.Name
        
        $sector = "Core"
        $module = $file.BaseName

        # Deduce Sector from Folder structure
        if ($parentDir -match 'Week') {
            $sector = $parentDir -replace 'Week-\d+-', ''
        } elseif ($parentDir -match 'future|projects|resources') {
            $sector = $parentDir
        } elseif ($grandparentDir -match 'Week') {
            $sector = $grandparentDir -replace 'Week-\d+-', ''
            $module = $parentDir + "_" + $file.BaseName
        }

        # Format strings for Shields.io (replace dashes/spaces with underscores temporarily, then double dashes)
        $sectorFmt = $sector -replace '[ -]', '_'
        $moduleFmt = $module -replace '[ -]', '_'

        $header = "[![Sector](https://img.shields.io/badge/SECTOR-$($sectorFmt)-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-$($moduleFmt)-FF0055?style=flat-square&labelColor=0A0A0A)](#)`n`n"
        
        $newContent = $header + $content
        
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
        
        Write-Host "Injected Neon Header: $($file.FullName)"
    } catch {
        Write-Error "Error processing $($file.FullName): $_"
    }
}

Write-Host "Neon Header Injection Complete."
