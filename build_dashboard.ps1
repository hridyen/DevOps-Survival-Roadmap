$data = Get-Content -Raw data.json | ConvertFrom-Json
$bolt = [char]0x26A1 + " "
$star = [char]0x2726 + " "

$files = Get-ChildItem -Path . -Recurse -Filter *.md | Where-Object { 
  $_.FullName -notmatch '\\.git|\\.github|\\.gemini' -and $_.Name -ne 'README.md' 
}

$TotalModified = 0

foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
        if ([string]::IsNullOrEmpty($content)) { continue }
        
        $originalContent = $content

        # ---------------------------------------------------------
        # PHASE 1: Populate Empty Content from JSON mapped paths
        # ---------------------------------------------------------
        # Convert path to Unix style for matching the JSON keys
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "").Replace('\', '/')
        if ($null -ne $data.$relativePath) {
            $replacement = $data.$relativePath
            $pattern1 = '\|\s*\|\s*\|\s*\|[\r\n]+\|\s*\|\s*\|\s*\|'
            $pattern2 = '<!-- Add your own.*?-->'
            
            if ($content -match $pattern1) {
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern1, $replacement)
            } elseif ($content -match $pattern2) {
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern2, $replacement)
            } else {
                $content += "`n`n" + $replacement
            }
        }

        # ---------------------------------------------------------
        # PHASE 2: Apply Neon Typography & Badge Colors
        # ---------------------------------------------------------
        $lines = $content -split "`r?`n"
        $modifiedLines = [System.Collections.Generic.List[string]]::new()
        
        $inCodeBlock = $false

        foreach ($line in $lines) {
            if ($line -match '^```') { $inCodeBlock = -not $inCodeBlock }

            if (-not $inCodeBlock) {
                # Headers
                if ($line -match '^#\s+') {
                    if ($line -notmatch $bolt.Trim()) {
                        $line = $line -replace '^#\s+', ("# " + $bolt)
                    }
                } elseif ($line -match '^##\s+') {
                    if ($line -notmatch $star.Trim()) {
                        $line = $line -replace '^##\s+', ("## " + $star)
                    }
                } elseif ($line -match '^###\s+') {
                    if ($line -notmatch $star.Trim()) {
                        $line = $line -replace '^###\s+', ("### " + $star)
                    }
                }

                # Alerts
                if ($line -match '^>\s*\*?Note:?\*?') {
                    $line = $line -replace '^>\s*\*?Note:?\*?', '> [!NOTE]'
                }
            }

            # Mermaid Themes
            if ($line -match 'classDef default') {
                $line = '    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;'
            } elseif ($line -match 'classDef active') {
                $line = '    classDef active fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;'
            } elseif ($line -match 'classDef phase') {
                $line = '    classDef phase fill:transparent,stroke:#333333,stroke-width:2px,stroke-dasharray: 4 4,color:#00E5FF;'
            }

            # Shields.io badges
            if ($line -match 'img\.shields\.io/badge/') {
                $line = $line -replace '-e05d44\b|-red\b', '-FF0055'
                $line = $line -replace '-4c1\b|-green\b|-success\b', '-39FF14'
                $line = $line -replace '-0366d6\b|-1f425f\b|-blue\b', '-00E5FF'
                
                if ($line -notmatch 'labelColor=') {
                    $line = $line -replace 'style=([^&"]+)', 'style=flat-square&labelColor=0A0A0A'
                }
            }
            $modifiedLines.Add($line)
        }

        $content = $modifiedLines -join "`n"

        # ---------------------------------------------------------
        # PHASE 3: Prepend Neon Module Headers
        # ---------------------------------------------------------
        if ($content -notmatch 'https://img.shields.io/badge/SECTOR-') {
            $parentDir = $file.Directory.Name
            $grandparentDir = $file.Directory.Parent.Name
            
            $sector = "Core"
            $module = $file.BaseName

            if ($parentDir -match 'Week') {
                $sector = $parentDir -replace 'Week-\d+-', ''
            } elseif ($parentDir -match 'future|projects|resources') {
                $sector = $parentDir
            } elseif ($grandparentDir -match 'Week') {
                $sector = $grandparentDir -replace 'Week-\d+-', ''
                $module = $parentDir + "_" + $file.BaseName
            }

            $sectorFmt = $sector -replace '[ -]', '_'
            $moduleFmt = $module -replace '[ -]', '_'

            $header = "[![Sector](https://img.shields.io/badge/SECTOR-$($sectorFmt)-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-$($moduleFmt)-FF0055?style=flat-square&labelColor=0A0A0A)](#)`n`n---`n`n"
            
            $content = $header + $content
        }

        # ---------------------------------------------------------
        # WRITE TO FILE
        # ---------------------------------------------------------
        if ($originalContent -ne $content) {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
            Write-Host "Updated: $($relativePath)"
            $TotalModified++
        }

    } catch {
        Write-Error "Error processing $($file.FullName): $_"
    }
}

Write-Host "`nDashboards built securely! Modified $TotalModified files."
