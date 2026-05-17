# nbpkg — Suggested Improvements

## Context

nbpkg is a ~330-line personal shell orchestration tool for building and deploying
pkgsrc packages across diverse Unix-like platforms. Most of what it does manually
has well-established, battle-tested tools that could replace the custom code —
improving reliability, portability, and maintainability.

---

## 1. Replace the Generated Deploy Script with Ansible

**Current:** `nbpkg_serverpackages_package_upload()` (`bin/nbpkg:166–266`) writes a
heredoc shell script to `/var/tmp/nbpkg-serverinstall`, rsync's it to the server,
and the operator runs it manually. The script performs a **blue-green deployment**:
install into versioned prefix → stop services → swap symlink → start services →
post-upgrade tasks.

**Why it's problematic:** Quoting in nested heredocs is fragile. Service list is
hardcoded. Uses `perl` just to reverse a list. No idempotency. No dry-run.

**Better approach — Ansible playbook:**

```yaml
# deploy/serverpackages.yml
- hosts: schmonz.com
  tasks:
    - name: install packages into versioned prefix
      command: pkg_add ...

    - name: bless new packages (atomic symlink swap)
      file: src=/opt/.pkg-{{ vintage }} dest=/opt/pkg state=link

    - name: restart services in dependency order
      service: name={{ item }} state=restarted
      loop: [djbdns, tinydyn, rspamd, redis, qmail, dovecot, znc]

    - name: commit /etc/pkg state
      command: etckeeper commit "package-rebuild: after {{ vintage }}"
```

Gains: idempotent, dry-run (`--check`), proper service ordering via `notify`
handlers, inventory-driven (easy to add more hosts), no heredoc quoting hell.

---

## 2. Add shellcheck + shfmt to CI

**Current:** No CI, no linting, no formatting. Several real bugs go undetected.

**Better approach — GitHub Actions:**

```yaml
# .github/workflows/lint.yml
name: lint
on: [push, pull_request]
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: shellcheck bin/nbpkg
  shfmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: shfmt -d bin/nbpkg
```

`shellcheck` would immediately catch the bugs listed in §4 below.
`shfmt` enforces consistent indentation and quoting style automatically.

---

## 3. Use `/etc/os-release` for Linux Platform Detection

**Current:** `nbpkg_platform_linux()` (`bin/nbpkg:103–128`) tries `lsb_release`
first, then falls back to `/etc/gentoo-release` and `/etc/os-release`. The
`/etc/os-release` path has an `XXX` comment admitting it may not be right.

**Better approach:** `/etc/os-release` is the **POSIX-adjacent standard** (used
by all modern Linux distros, systemd-based or not). `lsb_release` is a legacy
wrapper around it. Remove the `lsb_release` dependency and the Gentoo special
case; make `/etc/os-release` the primary path:

```sh
nbpkg_platform_linux() {
    # /etc/os-release is the modern standard (replaces lsb_release)
    . /etc/os-release 2>/dev/null || true
    printf '%s-%s' "${NAME:-UnknownLinux}" "${VERSION_ID:-x.x}" \
        | sed -e 's| |-|g'
}
```

This resolves the `XXX` at `bin/nbpkg:117`.

---

## 4. Fix Correctness Bugs (shellcheck would surface all of these)

### 4a. Unquoted `$@` in `as_root()` — `bin/nbpkg:17,19`
Breaks on arguments containing spaces.
```sh
"$@"          # not: $@
sudo "$@"     # not: sudo $@
```

### 4b. `as_root()` calls `sudo` directly; `nbpkg_sudo` is never used internally
`nbpkg_sudo` has correct doas-first fallback logic but is only exposed as
a subcommand. `as_root` should delegate to it.

### 4c. Stray empty `sed` substitution — `bin/nbpkg:110`
```sh
-e 's|||g'   # does nothing; probably a lost special character
```

### 4d. Missing `gcc11` in `always-libgcc` — `etc/nbpkg-shared.mk.conf`
Lines 74–81 list gcc6–10 and gcc12–14; gcc11 is absent.

### 4e. Bash completion shebang — `etc/completions/nbpkg.bash:1`
```bash
#/usr/bin/env bash   # missing '!' — just a comment, not a shebang
```
Also, `COMPREPLY` must be an array:
```bash
COMPREPLY=( $(compgen -W "..." -- "${COMP_WORDS[COMP_CWORD]}") )
```

---

## 5. Add bats-core Tests for Platform Detection

**Current:** No tests at all. The `nbpkg_platform_*` functions are the most
unit-testable part of the codebase.

**Better approach — bats-core** (the de-facto shell testing standard):

```bash
# tests/platform.bats
@test "platform on Darwin returns macOS-x.y.z" {
  run nbpkg platform   # on macOS
  [[ "$output" =~ ^macOS- ]]
}
```

Enables regression testing when platform detection logic changes.

---

## 6. Minor Cleanups

- **Remove dead variable aliases** (`SED=sed`, `CAT=cat`, etc. at `bin/nbpkg:97–101`) — they add no portability
- **Move `mkdir -p`** from top-level (runs on every invocation) into `nbpkg_serverpackages_package_upload()`
- **Replace perl one-liner** for reversing service list with a static list or awk
- **`sort -un`** instead of `sort -u | sort -n` in `nbpkg_listcompilers`
- **Remove redundant `return $?` / `exit $?`** at `bin/nbpkg:326,330`

---

## Critical Files

| File | Concern |
|---|---|
| `bin/nbpkg` | quoting bugs, hardcoded paths, dead code, as_root/sudo inconsistency |
| `etc/completions/nbpkg.bash` | broken shebang, broken COMPREPLY |
| `etc/nbpkg-shared.mk.conf` | missing gcc11 |
| `.github/workflows/` (create) | no CI |
| `deploy/serverpackages.yml` (create) | replace generated deploy script |

## Verification

1. `shellcheck bin/nbpkg` → zero warnings
2. `nbpkg platform` on Linux and macOS → correct platform string
3. `nbpkg make --version` inside a pkgsrc tree → selects bmake
4. Tab-complete `nbpkg <TAB>` in bash → all subcommands appear
5. Run Ansible playbook with `--check` against server → no errors
