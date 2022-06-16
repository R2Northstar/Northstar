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
