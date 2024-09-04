$value = Get-ExecutionPolicy

if ("Bypass" -eq $value -or "Default" -eq $value -Or "Restricted" -eq $value -Or "Undefined" -eq $value) {
    try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned }catch {}
}

if (Get-Command "poetry" -ErrorAction SilentlyContinue) {}
else {
    py -m pip install -U poetry
}
py -m poetry install
py -m poetry run mkdocs serve
