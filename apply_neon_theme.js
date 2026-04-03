const fs = require('fs');
const path = require('path');

const emojiRegex = /[\u{1F300}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{1F1E0}-\u{1F1FF}⚙️📌📚🛡️🐳🏃🐛📝🔗💡✅❌🟡🚀🏗️🧪🔧🏆🧠📂⚔️🌍🔮🐧🌐🔥🚢🛠️🐋✨]/gu;

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(function(file) {
        let fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat && stat.isDirectory()) {
            if (!fullPath.includes('.git') && !fullPath.includes('.github') && !fullPath.includes('.gemini')) {
                results = results.concat(walk(fullPath));
            }
        } else {
            if (fullPath.endsWith('.md') && file !== 'README.md') {
                results.push(fullPath);
            }
        }
    });
    return results;
}

const files = walk(process.cwd());
let totalModified = 0;

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf-8');
    let originalContent = content;

    // 1. Scrub Emojis
    content = content.replace(emojiRegex, '');

    let lines = content.split('\n');

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i];

        // 2. Adjust Headers
        if (line.match(/^#\s+/)) {
            // Strip any existing ⚡ or extra spaces
            line = line.replace(/^#\s+⚡?\s*/, '# ⚡ ');
        } else if (line.match(/^##\s+/)) {
            line = line.replace(/^##\s+✦?\s*/, '## ✦ ');
        } else if (line.match(/^###\s+/)) {
            line = line.replace(/^###\s+✦?\s*/, '### ✦ ');
        }

        // 3. Alerts
        line = line.replace(/^>\s*\**Note:?\**/i, '> [!NOTE]');

        // 4. Update Mermaid Themes
        if (line.includes('classDef default')) {
            line = '    classDef default fill:#0A0A0A,stroke:#00E5FF,stroke-width:2px,color:#FFFFFF,rx:5px,ry:5px;';
        } else if (line.includes('classDef active')) {
            line = '    classDef active fill:#0A0A0A,stroke:#FF0055,stroke-width:3px,color:#FFFFFF,rx:5px,ry:5px;';
        } else if (line.includes('classDef phase')) {
            line = '    classDef phase fill:transparent,stroke:#333333,stroke-width:2px,stroke-dasharray: 4 4,color:#00E5FF;';
        }

        // 5. Upgrade shields.io badges
        if (line.includes('img.shields.io/badge/')) {
            // Very simplistic replacement for common colors to Neon
            line = line.replace(/-e05d44\b|-red\b/g, '-FF0055');
            line = line.replace(/-4c1\b|-green\b/g, '-39FF14');
            line = line.replace(/-0366d6\b|-blue\b/g, '-00E5FF');
            
            // Add labelColor if missing
            if (!line.includes('labelColor=')) {
                line = line.replace(/style=([^&"\s]+)/g, 'style=flat-square&labelColor=0A0A0A');
            }
        }

        lines[i] = line;
    }

    let result = lines.join('\n');
    
    // Final cleanup of extra spaces from removed emojis
    result = result.replace(/  +/g, ' ');

    if (originalContent !== result) {
        fs.writeFileSync(file, result, 'utf-8');
        console.log('Updated: ' + file.replace(process.cwd(), ''));
        totalModified++;
    }
});

console.log(`\nTheme rewrite complete! Modified ${totalModified} files.`);
