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

        $lines = $content -split "`r?`n"
        $modifiedLines = [System.Collections.Generic.List[string]]::new()
        
        $inCodeBlock = $false

        foreach ($line in $lines) {
            # Check for code blocks
            if ($line -match '^```') { $inCodeBlock = -not $inCodeBlock }

            if (-not $inCodeBlock) {
                # 2. Adjust Headers
                if ($line -match '^#\s+') {
                    if ($line -notmatch $bolt.Trim()) {
                        # Add bolt after the #
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

                # 3. Alerts
                if ($line -match '^>\s*\*?Note:?\*?') {
                    $line = $line -replace '^>\s*\*?Note:?\*?', '> [!NOTE]'
                }
            }

            # 4. Update Mermaid Themes
            if ($line -match 'classDef default') {
                $line = '    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;'
            } elseif ($line -match 'classDef active') {
                $line = '    classDef active fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;'
            } elseif ($line -match 'classDef phase') {
                $line = '    classDef phase fill:transparent,stroke:#333333,stroke-width:2px,stroke-dasharray: 4 4,color:#00E5FF;'
            }

            # 5. Upgrade shields.io badges
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

        $result = $modifiedLines -join "`n"

        if ($originalContent -ne $result) {
            # Use UTF8 without BOM (UTF8Encoding($false)) just to be safe
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $result, $utf8NoBom)
            Write-Host "Updated: $($file.FullName)"
            $TotalModified++
        }
    } catch {
        Write-Error "Error processing $($file.FullName): $_"
    }
}

Write-Host "`nTheme rewrite complete! Modified $TotalModified files."
