from __future__ import annotations

import os
import shutil
import subprocess
import sys

from local_state import find_profile_by_name, get_profiles


CHROME_BIN = os.environ.get("CHROME_BIN", "google-chrome")


def usage() -> None:
    print(
        """Usage:
  chrome-profile
  chrome-profile "<profile name>"
  chrome-profile "<profile name>" <url>

Examples:
  chrome-profile
  chrome-profile "Talktopus"
  chrome-profile "xyz.show" https://buffer.com
"""
    )


def list_profiles() -> int:
    profiles = get_profiles()

    if not profiles:
        print("No Chrome profiles found.", file=sys.stderr)
        return 1

    print("Available Chrome profiles:")
    for profile in profiles:
        print(f"  {profile.name}    [{profile.directory}]")

    return 0


def launch_profile(profile_name: str, extra_args: list[str]) -> int:
    profile = find_profile_by_name(profile_name)

    chrome_path = shutil.which(CHROME_BIN)
    if chrome_path is None:
        print(f"Could not find Chrome binary: {CHROME_BIN}", file=sys.stderr)
        return 1

    cmd = [
        chrome_path,
        f"--profile-directory={profile.directory}",
        *extra_args,
    ]

    result = subprocess.run(cmd, check=False)
    return result.returncode


def main() -> int:
    args = sys.argv[1:]

    if not args:
        return list_profiles()

    if args[0] in {"-h", "--help"}:
        usage()
        return 0

    profile_name = args[0]
    extra_args = args[1:]

    try:
        return launch_profile(profile_name, extra_args)
    except FileNotFoundError as e:
        print(str(e), file=sys.stderr)
        return 1
    except ValueError as e:
        print(str(e), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())