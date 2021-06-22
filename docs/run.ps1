$value = Get-ExecutionPolicy

if ("Bypass" -eq $value -or "Default" -eq $value -Or "Restricted" -eq $value -Or "Undefined" -eq $value) {
    try { Set-ExecutionPolicy -Scope CurrentUser RemoteSigned }catch {}
}

if (Get-Command "uv" -ErrorAction SilentlyContinue) {}
else {
    py -m pip install -U uv
}
py -m uv run mkdocs serve
