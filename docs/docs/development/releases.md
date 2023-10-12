---
description: >-
  Information intended mostly for internal use on what to consider when making
  new releases
---

# Releases

{% hint style="info" %}
WIP
{% endhint %}

## General

CI on Northstar release repo builds versioned release if tag is pushed. It checks Launcher and Mods for the same tag.
It then downloads the related build for Launcher from releases and the Squirrel related source files from the mods repo.
It then combines the files together with DiscordRPC and navmeshes to build the final release. \
Therefore make sure to push tags of Mods and Launcher first (and make sure Launcher has finished building).

CI also pushes release directly to Thunderstore as a mod called [`Northstar`](https://northstar.thunderstore.io/package/northstar/Northstar/). \
If it's a release-candidate with the `-rcX` suffix, it will instead get pushed to Thunderstore as [`NorthstarReleaseCandidate`](https://northstar.thunderstore.io/package/northstar/NorthstarReleaseCandidate/).

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
