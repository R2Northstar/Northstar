---
description: Core squirrel mods
---

# NorthstarMods

TODO

When adding new Sqirrel script source files that are from the base game, make sure to commit the unmodified file first.
In particular, on `main` they should committed as `Respawn` with the email address `respawn@northstar.tf`.

```sh
git -c user.name="Respawn" -c user.email="<respawn@northstar.tf>" commit -m "Add SQUIRREL_FILE.nut from VPK_NAME"
```

This process is done to later leverage the power of `git blame` to see who authored a particular code line which assists with better understanding changes in the codebase.
