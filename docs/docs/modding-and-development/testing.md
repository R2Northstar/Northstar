---
description: >-
  Instructions regarding testing new features, directed at both developers and
  maintainers
---

# Testing

{% hint style="info" %}
This section is very much still WIP. Feel free to help expand it.
{% endhint %}

## Developers & Contributors

This section applies to you if you're opening a pull request to any of the Northstar repos.

Whatever your change includes, whether a bug fix or a new feature make sure to test it appropriately.

This means if your change is a bug fix, it's recommend you first make sure you can reproduce the bug. Then after making the necessary changes to fix it, test it using the same method you used to originally confirm the bug.\
When you're opening a pull request, make sure to mention how to reproduce the bug, so that reviewers can confirm that your chance indeed fixed the issue.

If your change is a new feature, make sure to test both that the newly added functionality performs as expected, as well as ensuring that it doesn't introduce any form of regression bugs. This means, testing anything that might be affected by your new feature.

## Maintainers

This section applies to you if you're someone who's able to merge PRs in any of the repos of the Northstar GitHub org as well as when simplying performing reviews, even without being able to actually merge a PR.

When reviewing pull requests on GitHub, make sure to checkout the changes made by a PR locally and test it there. In particular, test the parts of the code that are touched by a PR.

After testing, make sure to mention the steps tested in your review.
