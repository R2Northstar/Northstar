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

CI on Northstar release repo builds versioned release if tag is pushed. It checks Launcher and Mods for same tag and builds those versions. \
Therefore make sure to push tags of Mods and Launcher first.

CI also pushes release directly to Thunderstore if it does not contain the `-rcX` suffix.

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

## Best practices:

- Make at least one release candidate and test it before actual release.
- Release should also only ever be latest release candidate but tagged as release to avoid introducing new bugs.
