from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


DEFAULT_LOCAL_STATE = Path.home() / ".config" / "google-chrome" / "Local State"


@dataclass(frozen=True)
class ChromeProfile:
    directory: str
    name: str


def load_local_state(path: Path | None = None) -> dict:
    local_state_path = path or DEFAULT_LOCAL_STATE

    if not local_state_path.exists():
        raise FileNotFoundError(f"Chrome Local State not found: {local_state_path}")

    with local_state_path.open("r", encoding="utf-8") as f:
        return json.load(f)


def get_profiles(path: Path | None = None) -> list[ChromeProfile]:
    data = load_local_state(path)
    info_cache = data.get("profile", {}).get("info_cache", {})

    profiles: list[ChromeProfile] = []

    for directory, meta in info_cache.items():
        name = meta.get("name", directory)
        profiles.append(ChromeProfile(directory=directory, name=name))

    profiles.sort(key=lambda p: p.name.lower())
    return profiles


def find_profile_by_name(name: str, path: Path | None = None) -> ChromeProfile:
    profiles = get_profiles(path)

    exact = [p for p in profiles if p.name == name]
    if len(exact) == 1:
        return exact[0]
    if len(exact) > 1:
        matches = ", ".join(f"{p.name} [{p.directory}]" for p in exact)
        raise ValueError(f"Multiple exact matches for '{name}': {matches}")

    ci = [p for p in profiles if p.name.lower() == name.lower()]
    if len(ci) == 1:
        return ci[0]
    if len(ci) > 1:
        matches = ", ".join(f"{p.name} [{p.directory}]" for p in ci)
        raise ValueError(f"Multiple case-insensitive matches for '{name}': {matches}")

    raise ValueError(f"No Chrome profile found with name: {name}")