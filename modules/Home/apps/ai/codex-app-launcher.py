"""Resolve ChatGPT's bundled CLI from its package metadata on each invocation."""

import json
import os
from pathlib import Path
import subprocess
import sys


class LauncherError(Exception):
    pass


def find_app():
    # Launch Services identifies the app even after a rename or relocation.
    try:
        result = subprocess.run(
            [
                "/usr/bin/osascript",
                "-e",
                'POSIX path of (path to application id "com.openai.codex")',
            ],
            check=True,
            capture_output=True,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        raise LauncherError(
            "ChatGPT アプリ (com.openai.codex) の所在を取得できません"
        ) from error
    app = result.stdout.rstrip("\n")
    if not app:
        raise LauncherError("ChatGPT アプリの所在が空です")
    return Path(app).resolve(strict=True)


def resolve_entrypoint(app):
    contents = app / "Contents"
    if not contents.is_dir():
        raise LauncherError(f"アプリの Contents が見つかりません: {app}")

    candidates = []

    def scan_error(error):
        raise error

    # The package directory and entrypoint names may change independently.
    for directory, _, files in os.walk(contents, onerror=scan_error):
        if "codex-package.json" not in files:
            continue
        manifest = Path(directory) / "codex-package.json"
        try:
            metadata = json.loads(manifest.read_text(encoding="utf-8"))
        except (ValueError, UnicodeError) as error:
            raise LauncherError(f"配布メタデータを読めません: {manifest}") from error
        if not isinstance(metadata, dict):
            raise LauncherError(f"配布メタデータの形式が不正です: {manifest}")
        if metadata.get("variant") != "codex":
            continue
        version = metadata.get("layoutVersion")
        if type(version) is not int or version != 1:
            raise LauncherError(
                f"未対応の layoutVersion {version!r}: {manifest}"
            )
        entrypoint = metadata.get("entrypoint")
        if (
            not isinstance(entrypoint, str)
            or not entrypoint
            or "\0" in entrypoint
            or Path(entrypoint).is_absolute()
        ):
            raise LauncherError(f"entrypoint は空でない相対パスが必要です: {manifest}")
        package = manifest.parent.resolve(strict=True)
        entry = package / entrypoint
        resolved = entry.resolve(strict=True)
        if not resolved.is_relative_to(package):
            raise LauncherError(f"entrypoint が配布パッケージの外を指しています: {manifest}")
        if not resolved.is_file() or not os.access(resolved, os.X_OK):
            raise LauncherError(f"entrypoint を実行できません: {entry}")
        candidates.append(entry)

    if not candidates:
        raise LauncherError(f"内蔵 Codex の配布メタデータが見つかりません: {app}")
    if len(candidates) != 1:
        raise LauncherError(f"内蔵 Codex の起動先が複数あります: {candidates}")
    return candidates[0]


def main():
    try:
        entry = str(resolve_entrypoint(find_app()))
        # Use the declared launcher so its own resource/symlink handling is kept.
        os.execv(entry, [entry, *sys.argv[1:]])
    except (LauncherError, OSError) as error:
        print(f"error: ChatGPT の内蔵 Codex を起動できません: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
