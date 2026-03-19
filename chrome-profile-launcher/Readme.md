# `chrome-profile`

Simple CLI tool to launch Google Chrome with a specific profile by **human-readable name** (as shown in the Chrome UI).

Avoids:

* remembering `Profile 1`, `Profile 2`, etc.
* cookie/session contamination across ventures
* manual profile switching

---

## ✨ Features

* Lists available Chrome profiles
* Launches by display name (not internal directory)
* Case-insensitive matching
* Works from anywhere (script-relative execution)
* No hard-coded mappings

---

## 📦 Structure

```text
chrome_profile/
  chrome-profile   # executable entrypoint (on PATH)
  main.py          # CLI + launch logic
  local_state.py   # Chrome profile discovery
```

---

## ⚙️ Installation

1. Place the directory somewhere on your system:

```bash
~/code/chrome_profile
```

2. Ensure it's on your `PATH`:

```bash
export PATH="$HOME/<dir_you_cloned_to>/chrome-profile-launcher:$PATH"
```

3. Make the entrypoint executable:

```bash
chmod +x <location-of_chrome-profile_shell-script>
```

---

## 🚀 Usage

### List profiles

```bash
chrome-profile
```

Example output:

```text
Available Chrome profiles:
  Talktopus    [Profile 1]
  xyz.show     [Profile 2]
  Noubly       [Profile 3]
```

---

### Launch a profile

```bash
chrome-profile "Talktopus"
```

---

### Launch with URL

```bash
chrome-profile "xyz.show" https://buffer.com
```

---

## 🧠 How it works

Chrome stores profile metadata in:

```text
~/.config/google-chrome/Local State
```

This tool:

1. Parses that file
2. Extracts profile names from `profile.info_cache`
3. Resolves name → internal directory (`Profile X`)
4. Launches Chrome with:

```bash
--profile-directory=<dir>
```

---

## 🔧 Configuration

### Override Chrome binary

```bash
export CHROME_BIN=google-chrome-stable
```

---

## ⚠️ Notes

* Profile names must match those set in Chrome UI
* Matching is:

  * exact first
  * then case-insensitive
* Duplicate names are not supported (will error)

---

## 🧪 Future Improvements (optional)

* Partial matching (`talk` → `Talktopus`)
* `fzf` interactive selection when no args provided
* Profile aliases (short keys)
* Auto-open common URLs per profile
* Caching for faster startup (probably unnecessary)

---

## 🎯 Why this exists

When managing multiple ventures/projects:

* each needs isolated sessions (socials, analytics, auth)
* Chrome profiles provide isolation
* but default UX is clunky

This tool turns profiles into:

> fast, deterministic, CLI-addressable environments

---

## 🧠 Philosophy

* No abstraction layers
* No config files (yet)
* No hard-coded mappings
* Just derive truth from Chrome itself
