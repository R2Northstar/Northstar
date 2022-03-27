from collections import defaultdict
import json

RSON_PATH = "scripts.rson"

stuff = defaultdict(list)

with open(RSON_PATH) as f:
    current = ""
    for line in f:
        line = line.strip()
        if "When" in line:
            current = line.replace('When: "', "").strip('"')
            continue
        line = line.replace("Scripts:", "").strip("[]")
        if len(line) > 1:
            stuff[current].append(line)

with open("scripts.json", "w+") as f:
    json.dump(stuff, f)
