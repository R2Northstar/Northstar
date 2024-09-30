---
description: >-
  Information intended mostly for internal use on what to consider when making
  new releases
---

# Releases

!!! info
    WIP


## General

CI on Northstar release repo builds versioned release if tag is pushed. It checks Launcher and Mods for the same tag.
It then downloads the related build for Launcher from releases and the Squirrel related source files from the mods repo.
It then combines the files together with DiscordRPC and navmeshes to build the final release. \
Therefore make sure to push tags of Mods and Launcher first (and make sure Launcher has finished building).

CI also pushes release directly to Thunderstore as a mod called [`Northstar`](https://northstar.thunderstore.io/package/northstar/Northstar/). \
If it's a release-candidate with the `-rcX` suffix, it will instead get pushed to Thunderstore as [`NorthstarReleaseCandidate`](https://northstar.thunderstore.io/package/northstar/NorthstarReleaseCandidate/).

### The process of making a release:

The following is a rough draft of the steps needed to make a release.
The process is ever changing in order to simplify it so these steps outlined might not be up-to-date anymore depending on when you are reading this.

The current process of making release (includinging release candidate) is:

1. Make release branch (`MAJOR.MINOR.X`) (only if commits need to be cherry-picked)

2. Take desired commits from `main`
    - Make sure to consider whether changing are breaking in regards to older/newer server/client and in regards to Squirrel API.
      - Older/newer client/server breakage might need to be version gated and should **NOT** be done in patch releases.
      - Squirrel API changes likely breaks mods and should **NOT** be done in patch releases. Additionaly make sure to ping modders on release or preferably even in advance.
    - If changes can be merged fast-forward use `git merge --ff-only origin/main` otherwise cherry-pick relevant commits.

3. Make release candidate\
   Push tags ending in `-rcX` where `X` is integer for
    1. Launcher
    2. Mods
    3. Release

4. Make draft notes\
   You can use FlightCore to generate them and then format them manually.\
   If you use FlightCore make sure to remove already released commits if they were cherry-picked.

5. Create a draft discussion in [release repo discussions](https://github.com/R2Northstar/Northstar/discussions)

6. Make related github-org thread and link the draft notes there for feedback etc

7. Ping playtesters to test release candidate.
    1. Add information about what specific aspect to test.
    2. Copy relevant changes for this release candidate from draft release notes.
    3. Link draft release notes.
    4. Make thread to leave feedback about release in.

8. Wait until release candidate was sufficiently tested.

9. Make release
   Push tags for
    1. Launcher
    2. Mods
    3. Release

10. Once release has finished building
    1. Go to GitHub release and select the new unpublished release
    2. Copy release notes from draft.
    3. Click checkbox for creating discussion and select _Release_ as category
    4. Publish

11. Post release announcement on Discord in `#releases` channel.
    Make sure to highlight aspects relevant for server hosters, modders, and end-users.

12. Update main menu promos version on Atlas

13. Push Docker image
    1. Get SHA512 checksum of zip from release CI
    2. Make PR to [Docker repo](https://github.com/pg9182/northstar-dedicated) to update Docker image to newest Northstar release
    3. Merge PR
    4. Wait for Docker repo CI to finish
    5. Approve image

14. Observe version roll-out via [Grafana dashboard](https://northstar-stats.frontier.tf/).

### Git commands for tags:

**For release candidates:**

```
git tag vX.Y.Z-rcN
git push origin vX.Y.Z-rcN
```

Example:

```
git tag v1.8.0-rc1
git push origin v1.8.0-rc1
```

**For actual releases**

```
git tag vX.Y.Z
git push origin vX.Y.Z
```

Example:

```
git tag v1.8.0
git push origin v1.8.0
```

## Version numbering

In general, Northstar tries to follow [semantic versioning](https://semver.org/). This means version numbers are `MAJOR.MINOR.PATCH`, where

- `MAJOR` is updated for breaking changes
- `MINOR` is updated for changes that are backwards compatible
- `PATCH` is updated for fixes that are backwards compatible

Semantic versioning is however not followed exactly. For example, to ship out smaller features faster they have been included in patch releases. Similarly, there have been smaller breaking changes, yet at the time of writing the major version number so far has never been updated.

The reason for this is mostly due to player expectations. Players expect the change from `1.0` to `2.0` to be big. As such, the plan for the near future is to update the major version, once we have a bigger feature ready to release that brings us closer to vanilla in terms of missing features (e.g. _Frontier Defense_).

Once `2.0` has been released, expectations for `3.0` tend to be lower as the number is no longer "doubled". Past `3.0`, proper semver can probably be employed without hampering player expectations.


## Best practices:

- Make at least one release candidate and test it before actual release.
- Release should also only ever be latest release candidate but tagged as release to avoid introducing new bugs.


## Other repos

Repos like navmeshes and DiscordRPC get their release unrelated to main Northstar release numbering as they usually only see a few release per year due to


### DiscordRPC

Push new tag which in turn will generate a release. Tags are formatted as `vN` where `N` is an always increasing integer, i.e. `v4`, `v5`, `v6`, etc.

Once a new DiscordRPC release has been made, the version number needs to be bumped in the [release repo](https://github.com/R2Northstar/Northstar) to pull the new release.
