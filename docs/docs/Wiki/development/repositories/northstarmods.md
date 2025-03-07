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

Before adding that vanilla make sure that the corresponding PR is up-to-date.
Adding the vanilla file will cause a merge conflict on the PR, that is expected.

In case you forgot to update the PR first, you can also merge the commit before that into the PR branch manually by using `git merge <commit hash>`.

Afterwards, update the PR branch by ignoring the commit from `main` by checking out the PR branch and merging with

```sh
git merge --strategy=ours main
```

This will merge `main` into the PR branch and always prefer the changes from the PR branch in case of conflict.
