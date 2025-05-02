# nbpkg

N.B.: next build, new binaries, no biggie.
See also [nbvm](https://github.com/schmonz/nbvm).

## What's here:

For increasingly arbitrary combinations of...

- Unixy host/guest OSes
- hardware architectures
- emulation and virtualization tools

...we have a consistent shell UI to perform various pkgsrc-specific steps.

I use this, at present, for couple purposes:

- Test-build pkgsrc packages on a variety of platforms
- Do weekly rebuilds of all packages for my server

## Why (generally)

In principle, when I'm responsible for outcomes, I want to encounter problems myself as early as possible, so as to:

1. Narrow them down with minimal time and brain, and
2. Consider mitigation options with maximal time and brain.

## Why (this repo specifically)

In practice, this repo helps me:

- As a pkgsrc developer, to make sure all my packages work on a wide variety of platforms.
- As a server administrator, to update every week to a fresh-built set of the latest packages I rely on (not only mine).

## Goals

### Short-term

- Automate more manual steps

### Medium-term

- Connect two hosts (such as `aarch64` and `x86_64`) in tandem:
  for any guest, run where virtualized, else run where emulation
  is probably "faster"
- Learn how to do a (limited) bulk build and publish (for myself) the results
- Iterate over all guests

### Long-term

- Have these tools adopted as official pkgsrc infrastructure
- Allow pkgsrc developers to submit proposed changes _before_ committing, to see how they build across a wide variety of platforms
- Build a GitHub Action backed by these tools
