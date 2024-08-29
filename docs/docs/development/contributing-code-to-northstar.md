---
description: Useful information when contributing to Northstar
---

# Contributing code to Northstar

{% hint style="info" %}
WIP
{% endhint %}

## Guidelines

For a pull request to be merged, it has to be reviewed first. In order to make the review process as smooth as possible and therefore ensuring quick merging of your pull request, keep the following things in mind:

- If the changes you made can be summarised in a screenshot or screenrecording, make sure to add one to quickly give a reviewer an idea what your pull request is about.
- Please use a sensible title for your pull request. We squash commits when merging and as such your pull request title will be used as the commit message. We can of course edit it before merging but using a sensible title for your PR both makes it easier to understand what it is about and saves us from having to edit the title before merging.
- Please describe the changes you made. The easier it is to understand what you changed, the higher the chances of your PR being merged (in a timely manner).
- If you made multiple independent changes, please make a new PR for each one. This prevents cases where your PR is being blocked from merging by a bug one of the changes you made.

## Tips and tricks

An example of a well-formatted PR description:

{% embed url="https://github.com/R2Northstar/NorthstarMods/pull/392" %}

To get the cropped GIFs of a screenrecording:

1. Use your screenrecording tool of choice (OBS/ShadowPlay/...) to record the clip
2. Cut it down to just the moment you want to show using [Avidemux](http://www.avidemux.org/), [VLC](https://www.videolan.org/vlc/), etc.
3. Use a site like [https://ezgif.com/video-to-gif](https://ezgif.com/video-to-gif) for cropping and turning it into a GIF \
   (The linked site has not been vetted, use at own risk)
4. Upload GIF to GitHub pull request description by just pasting it at the appropriate location.

### Useful links

- [How to write a commit message](https://cbea.ms/git-commit/)
- [Atomic commits](https://www.freshconsulting.com/insights/blog/atomic-commits/)

### Avoiding "PR hell"

_"PR hell"_ is what contributors refer to when a pull request is stuck as pending without any indication for progress.

There can be a variety reasons for this. Whether it's because the pull request was overlooked, the changes are too big that anyone actually dares looking at it, or simply every reviewer is too busy at the moment, not getting a response on something you put a lot of work into is a terrible experience.

While we are continuously working on improving the experience and recruiting more reviewers, here's a few tips to avoid _"PR hell"_.

**Make sure your PR is easy to review:**

If you are submitting a new feature, highlight it with screenshots, screenrecordings, GIFs etc. If you can make your change look interesting, it highly increases the chance of someone becoming interested in getting it merged.

If you are submitting a bug fix, make sure to mention the steps to reproduce the bug and that the same steps no longer cause the bug on your fixed version.

Finally, smaller code changes are easier to review than bigger ones, which brings us to:

**Keep PRs concise and focused on a specific issue:**

While working on code to create some feature or fix some issue you might come across some other things you also want to change. While this is fine, it's highly recommended to split out these changes into separate PRs.

Having lots of small PRs is way easier to review and work with than one big PR. Further if there's an issue with one of the changes it does not block the whole big PR but just one of the small ones.

Smaller changes are also way easier to review and test.

If you're working on a big feature that introduces lots of changes (let's say you implemented an entire party system into Northstar) a recommended approach is to PR your big change so that feature can be easily observed and interest generated. \
Then ask which parts should be turned into separate pull requests, PR those, and link them with your big PR. As the the smaller PRs are merged, the diff of the big PR should shrink overtime until concise enough to be merged all at once.

Just make sure to resolve merge conflicts when the smaller PRs are merged ;)

**Ping previous author:**

Especially when you fix a bug in existing code, you usually modify code that was written by someone else. In that case the best person to review that code is the original author. So `@` ping them in the pull request!

You can use tools like [`git blame`](https://www.git-scm.com/docs/git-blame) (on the web via GitHub, in vscode via gitlens, via command-line, ...) to see who previously wrote the code.


**Ping for updates:**

Sometimes it can happen that a pull request simply gets lost in the sea of other pull requests. If you haven't received a response in a while on a pull request that has already received some responses, just leave a comment on it (even if it's just "bump"). This will send a notification to everyone that responded previously in the PR and likely cause them to respond again.

Similarly, you can also check merged pull requests and see who reviewed/merged them and ping that person individually.

**If all else fails:**

If despite all your attempts you are still not seeing responses, your last resort is always to ask around in `#development` on the Northstar Discord. We really do not want to see anyone become frustrated with the lack of responses on their pull request and close it in frustration. As such please reach out earlier rather than later.

We will try our best to look at it <3
