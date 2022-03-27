from collections import defaultdict
import json
from pathlib import Path
import re

NS_MODS = Path("PATH_TO/R2Northstar/mods/")

# Layers of vscripts, topmost is overwritten by below
VSCRIPT_LAYERS = [
    (
        "Titanfall 2",
        Path("PATH/TO/assets_dump/scripts/vscripts"),
    ),
    (
        "Northstar.CustomServers",
        NS_MODS / "Northstar.CustomServers/mod/scripts/vscripts",
    ),
    ("Northstar.Coop", NS_MODS / "Northstar.Coop/mod/scripts/vscripts"),
    ("Northstar.Custom", NS_MODS / "Northstar.Custom/mod/scripts/vscripts"),
    ("Northstar.Client", NS_MODS / "Northstar.Client/mod/scripts/vscripts"),
]


def get_layer(filename):
    for name, layer in reversed(VSCRIPT_LAYERS):
        path = layer / filename
        if path.exists():
            return path, name
    raise FileNotFoundError(f"Could not locate {filename} in any layer.")


def openl(filename: str, mode="r", encoding="utf-8"):
    path, name = get_layer(filename)
    if path:
        return name, path.open(mode, encoding=encoding, errors="ignore")


with open("scripts.json") as f:
    scripts = json.load(f)

sl_cmnt = re.compile(r"\/\/.*")
funname_re = re.compile(r"function (\w+)\(")
global_re = re.compile(r"global function ([1-zA-Z_]\w+)")


def runon_parse(inp: str):
    try:
        inp, additional = inp.split("&&")
        additional = " &&" + additional
    except ValueError:
        additional = ""
    runons = inp.split("||")
    runons = [r.strip(" \n()") + additional for r in runons]
    return runons


funcs = defaultdict(list)

for runon, filelist in scripts.items():
    runons = runon_parse(runon)
    if "CONSOLE_PROG" in runon:
        continue
    for filename in filelist:
        try:
            found_in, fp = openl(filename)
            with fp as f:
                ml_comment_depth = 0
                global_all = False
                runons_mod = []
                globalized_funcs = []
                for line in f:
                    line = line.removesuffix("\n")
                    # globalize all
                    if "globalize_all_functions" in line:
                        global_all = True

                    # comment skipping
                    line = sl_cmnt.sub("", line)
                    if "/*" in line:
                        ml_comment_depth += 1
                        line = line.split("/*")[0]
                    elif "*/" in line:
                        ml_comment_depth -= 1
                        line = line.split("*/")[1]
                    elif ml_comment_depth > 0:
                        continue

                    # preproc conditions
                    if "#if" in line:
                        runon_modifier = line.strip().replace("#if ", "")
                        runons_mod = runon_parse(runon_modifier)
                    if "#elseif" in line:
                        runon_modifier = line.strip().replace("#elseif ", "")
                        runons_mod = runon_parse(runon_modifier)
                    if "#endif" in line:
                        runon_modifier = ""
                        runons_mod = []

                    # global lines
                    match = global_re.search(line)
                    if match:
                        globalized_funcs.append(match.group(1))

                    # function
                    match = funname_re.search(line)
                    if match:
                        name = match.group(1)
                        local_params = {}
                        local_params["name"] = name
                        local_params["found_in"] = found_in
                        local_params["file"] = filename
                        if "global function" in line or name in globalized_funcs:
                            local_params["global"] = True
                        else:
                            local_params["global"] = global_all
                        local_params["line"] = line
                        runon = runons_mod or runons
                        funcs[str(runon)].append(local_params)
        except FileNotFoundError:
            print(filename)

with open("funcs.json", "w") as f:
    json.dump(funcs, f)
