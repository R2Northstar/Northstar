# Northstar Wiki Repo

This repo contains documentation around the [Northstar mod](https://github.com/R2Northstar), a Titanfall 2 mod to join and host custom community servers.

The `docs/` directory contains the content synchronised to the [GitBook Wiki page](https://r2northstar.gitbook.io/).

Use this repo to perform pull requests and open issues to request changes to the wiki content.

## Building locally

Unfortunately, [GitBook](https://www.gitbook.com/) does not offer a way to work and preview edited content locally.

However, under the hood GitBook just uses [Markdown](https://www.markdownguide.org/) files that can be edited using any text editor.
They can also be previewed to some degree on GitHub directly.

### mdBook

When working locally, [`mdBook`](https://rust-lang.github.io/mdBook/) can be used to render previews by simply running `mdbook serve`.
Note that GitBook has a custom extended markdown syntax that is not supported by mdBook but using mdBook results in a rendered version that is good enough to verify the correctness of most changes.

To install mdBook use the following link if:

- [you have Rust toolchain installed](https://rust-lang.github.io/mdBook/guide/installation.html#build-from-source-using-rust)
- [you **DON'T** have Rust toolchain installed](https://rust-lang.github.io/mdBook/guide/installation.html#pre-compiled-binaries)

#### mdBook-linkcheck
Additionally there's a community-made package that you can use alongside mdBook to show you some potentially broken links in markdown files called [mdBook-linkcheck](https://github.com/Michael-F-Bryan/mdbook-linkcheck)

Although not required, you may find it helpful to use alongside mdBook to ensure you've linked things properly

To install mdBook-linkcheck use the following link if:
- [you have Rust toolchain installed](https://github.com/Michael-F-Bryan/mdbook-linkcheck#getting-started)
- [you DON'T have Rust toolchain installed](https://github.com/Michael-F-Bryan/mdbook-linkcheck/releases/latest) (add `mdBook-linkcheck.exe` to the same folder `mdBook.exe` is located)
