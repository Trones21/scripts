# 🛠️ Scripts and Utilities

This repository contains a collection of shell-based tools grouped by domain
(shell ergonomics, content creation, automation, etc.).

Some are polished, some are experimental. Originally i was going to put things from a variety of languages here but i think it might just be shell scripts

They may execute code, accept arguments, define functions, or do a mix of things.

There is intentionally **no strict convention** enforced by filenames, extensions,
or directory layout.

---

## A note on assumptions (important)

Do **not** assume how a script is meant to be used based on:

* its filename
* whether it ends in `.sh`
* where it lives in the repo

To understand what a script does or how it is intended to be used,
**open the file and read it**.

There is no substitute for this.

---

### Practical guidance

If a script:

* defines functions meant to persist → it is likely meant to be sourced
* performs an action and exits → it is likely meant to be run
* does something unclear → read it

When in doubt, read the first ~20 lines.

---

### Rule of thumb

> **If you care what a script does, read it.**

---

## Filtering scripts by path (recommended workflow)

Scripts are grouped by domain, so the most reliable way to explore the repo
is to filter by **path fragments** using `find -path`.

This works regardless of extensions or naming conventions.

---

### Example: filter by directory fragment + `.sh`

```bash
tjr@s7:~/gh/scripts$ find . -path '*cont*/*.sh'
./content-creation/record-terminal.sh
```

---

### Example: include scripts without `.sh`

Some shell scripts intentionally do not use a `.sh` extension:

```bash
tjr@s7:~/gh/scripts$ find . -path '*cont*/*'
./content-creation/record-terminal.sh
./content-creation/asciirec
./content-creation/aggcast
./content-creation/termresize
```

---

### Common patterns

```bash
# All shell helpers (by folder)
find . -path '*shell-helpers*/*'

# All content-creation scripts
find . -path '*content-creation*/*'

# Only cd-related helpers
find . -path '*shell-helpers*/*cd*'
```

---

## Registering shell helpers (when appropriate)

Some scripts define functions intended to be available in your shell session.

If you choose to register them, you can explicitly source them:

```bash
source shell-helpers/cdp.sh
```

To generate `source` lines for multiple helpers:

```bash
find shell-helpers -name '*.sh' | while read -r f; do
  echo "source ~/scripts/$f"
done
```

Append to your shell config if desired:

```bash
find shell-helpers -name '*.sh' | while read -r f; do
  echo "source ~/scripts/$f"
done >> ~/.bashrc
```

Nothing is installed automatically — everything is opt-in and explicit.

---

## Command names vs filenames (quick note)

When sourcing a script, the **function names defined inside the file**
determine what commands become available — not the filename.

Example:

```text
shell-helpers/abc.sh
```

```bash
# inside abc.sh
xyz() {
  echo "hello"
}
```

After sourcing:

```bash
source shell-helpers/abc.sh
```

The command you run is:

```bash
xyz
```

Not `abc` or `abc.sh`.

Files organize code; functions define commands.

---

## Philosophy

This repo favors:

* explicit behavior over rigid conventions
* readable filters over installers
* low ceremony and fast iteration
* code as the source of truth

If something matters, it’s visible in the script itself.

**Don’t guess. Read the script.**


