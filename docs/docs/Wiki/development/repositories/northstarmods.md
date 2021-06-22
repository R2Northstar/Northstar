---
description: Core squirrel mods
---

# NorthstarMods

TODO

## Reviewing PRs committing vanilla files

When a PR adds new Squirrel script source files that are from the base game, make sure to commit unmodified files first to `main`.

### 1. Update the PR branch

Before adding vanilla files to `main`, make sure that the corresponding PR is up-to-date.
Adding the vanilla file will cause a merge conflict on the PR, that is expected.

### 2. Add vanilla file to NorthstarMods' `main`

Before adding the vanilla file to `NorthstarMods`, make sure its end-of-line sequence is set on the host native line ending (LF on Linux, CRLF on Windows).
When it is done, push the file on `main` as `Respawn`:

```sh
git -c user.name="Respawn" -c user.email="<respawn@northstar.tf>" commit -m "Add SQUIRREL_FILE.nut from VPK_NAME"
```

This process is done to later leverage the power of `git blame` to see who authored a particular code line, which assists with better understanding changes in the codebase.

### 3. Merge the change in the PR branch

Afterwards, update the PR branch ignoring the commit from `main` by checking out the PR branch and merging with:

```sh
git merge --strategy=ours main
```

This will merge `main` into the PR branch and always prefer the changes from the PR branch in case of conflict.

(in case you forgot to update the PR first, you can also merge the commit before that into the PR branch manually by using `git merge <commit hash>`)

#### Example with a PR from NachosChipeados

```sh
# After pushing vanilla files to main, configure PR branch
git remote add NachosChipeados git@github.com:NachosChipeados/NorthstarMods.git
git fetch NachosChipeados

# Move to the PR branch
git checkout NachosChipeados/global_precacheres

# Merge main into the PR branch
git merge --strategy=ours main

# Push modification to the PR branch
git push -u NachosChipeados HEAD:global_precacheres
```
