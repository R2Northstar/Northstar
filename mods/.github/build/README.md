# Finding missing translations

This package contains a script that detects missing translation keys in Titanfall2 translation files contained in this repository (in the `Northstar.Client/mod/resource` folder).

It uses english translations file as reference.

You have to launch it **from the repository root folder**:
```shell
node .github/build/find-missing-translations.js
```
The script will then list all missing translations for all supported languages.

If you want to display missing keys for a given language, just add it as an argument:
```shell
node .github/build/find-missing-translations.js french
```

Here's the list of supported languages: 
* english
* french
* german
* italian
* japanese
* mspanish
* portuguese
* russian
* spanish
* tchinese