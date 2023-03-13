$value = Get-ExecutionPolicy

if ("Bypass" -eq $value -or "Default" -eq $value -Or "Restricted" -eq $value -Or "Undefined" -eq $value) {
    try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned }catch {}
}

if (Get-Command "poetry" -ErrorAction SilentlyContinue) {}
else {
    py -m pip install -U poetry
}
py -m poetry install
Set-Location ./docs
py -m poetry run sphinx-autobuild source build/html --open-browser --ignore *build/**
Set-Location ../