const fs = require('fs');
const path = require('path');

const emojiRegex = /[\u{1F300}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{1F1E0}-\u{1F1FF}⚙️📌📚🛡️🐳🏃🐛📝🔗💡✅❌🟡🚀🏗️🧪🔧🏆🧠📂⚔️🌍🔮🐧🌐🔥🚢🛠️🐋✨]/gu;

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(function(file) {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            if (!file.includes('.git') && !file.includes('.github') && !file.includes('.gemini')) {
                results = results.concat(walk(file));
            }
        } else {
            if (file.endsWith('.md')) {
                results.push(file);
            }
        }
    });
    return results;
}

const files = walk(process.cwd());
files.forEach(file => {
    let content = fs.readFileSync(file, 'utf-8');
    let lines = content.split('\n');
    let modified = false;
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('#')) {
            let original = lines[i];
            // Replace emojis
            let changed = original.replace(emojiRegex, '');
            // Clean up left over spaces
            changed = changed.replace(/\s+/g, ' ');
            changed = changed.replace(/#\s+/g, '# ');
            if (original !== changed) {
                lines[i] = changed;
                modified = true;
            }
        }
    }
    if (modified) {
        fs.writeFileSync(file, lines.join('\n'), 'utf-8');
        console.log('Updated ' + file);
    }
});
