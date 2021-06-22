const fs = require('fs');
const { exit } = require('process');
const langPath = "Northstar.Client/mod/resource";
const knownLanguages = ['english', 'french', 'german', 'italian', 'japanese', 'mspanish', 'portuguese', 'russian', 'spanish', 'tchinese'];


// Proceed checks before launch
if (![2,3].includes(process.argv.length)) {
    console.error('Wrong number of arguments, either call this script with no argument, or with a language.');
    return;
}
const inputLang = process.argv[2];
if (process.argv.length === 3 && !knownLanguages.includes(inputLang)) {
    console.error(`"${inputLang}" is not a valid language.\nValid languages are: ${knownLanguages}`);
    return;
}


// Get language files names
const langs = fs.readdirSync(langPath)
    .filter(lang => lang.indexOf('northstar_client_localisation_') !== -1);


function getLanguageKeys (lang) {
    if (knownLanguages.indexOf(lang) === -1) return;
    return fs.readFileSync(`${langPath}/northstar_client_localisation_${lang}.txt`, {encoding:'utf16le', flag:'r'})
        .split('\n')
        .filter(line => line.length !== 0)                  // remove empty lines
        .map(line => line.replaceAll(/\s+/g, ' ').trim())   // remove multiple spaces
        .map(line => line.replaceAll('\t', ''))             // remove tabs characters
        
        // keep only lines with translation keys
        .filter(line => {
            const words = line.split('" "');
            return words.length === 2 && words[1] !== 'english"'
        })
        .map(line => line.split('" "')[0].substring(1)); // only keep translation keys (throw values)
}

// We use english keys as reference for other languages
const englishKeys = getLanguageKeys('english');
const inputLanguages = inputLang !== undefined ? ["", inputLang] : [...knownLanguages];
inputLanguages.shift();

// Check for each language if there are missing keys
var missingKeysCount = 0;

for (const language of inputLanguages) {
    const languageKeys = getLanguageKeys(language);
    const missingKeys = [...englishKeys] // clone
        .filter(key => languageKeys.indexOf(key) === -1);
    const missingKeysLength = missingKeys.length;
    console.log(
        missingKeysLength === 0 
        ? `✔️ "${language}" doesn't have missing keys.`
        : `❌ "${language}" has ${missingKeys.length} missing key${missingKeys.length === 1 ? '' : 's'}:`
    );

    if (missingKeysLength !== 0) {
        console.log(missingKeys);
        missingKeysCount += missingKeys.length;
    }
}

process.exitCode = missingKeysCount;
exit();
