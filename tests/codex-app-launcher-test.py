"""Exercise CLI discovery with relocated bundles and incompatible metadata."""

import contextlib
import importlib.util
import io
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "launcher", ROOT / "modules/Home/apps/ai/codex-app-launcher.py"
)
launcher = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(launcher)


class LauncherTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.app = Path(self.temp.name).resolve() / "Renamed ChatGPT.app"
        (self.app / "Contents").mkdir(parents=True)

    def package(self, directory="Resources/moved package", **metadata):
        package = self.app / "Contents" / directory
        package.mkdir(parents=True)
        entry = package / "new bin/renamed cli"
        entry.parent.mkdir()
        entry.write_text("#!/bin/sh\nexit 0\n")
        entry.chmod(0o755)
        manifest = package / "codex-package.json"
        manifest.write_text(json.dumps({
            "layoutVersion": 1,
            "variant": "codex",
            "entrypoint": "new bin/renamed cli",
            **metadata,
        }))
        return manifest, entry

    def test_launch_services_and_relocated_entrypoint(self):
        _, entry = self.package("SharedSupport/another layout/CLI package")
        with patch.object(launcher.subprocess, "run", return_value=subprocess.CompletedProcess(
            [], 0, stdout=str(self.app) + "/\n"
        )) as query:
            self.assertEqual(launcher.resolve_entrypoint(launcher.find_app()), entry)
        self.assertIn('application id "com.openai.codex"', query.call_args.args[0][-1])

    def test_reads_metadata_again_after_update(self):
        manifest, entry = self.package()
        self.assertEqual(launcher.resolve_entrypoint(self.app), entry)
        renamed = entry.with_name("updated cli")
        entry.rename(renamed)
        metadata = json.loads(manifest.read_text())
        metadata["entrypoint"] = "new bin/updated cli"
        manifest.write_text(json.dumps(metadata))
        self.assertEqual(launcher.resolve_entrypoint(self.app), renamed)

    def test_preserves_declared_launcher_and_arguments(self):
        _, entry = self.package()
        binary = entry.with_name("raw binary")
        entry.rename(binary)
        entry.symlink_to(binary.name)
        arguments = ["codex", "exec", "a prompt with spaces", "", "$literal\ntext"]
        with patch.object(launcher, "find_app", return_value=self.app), \
             patch.object(launcher.sys, "argv", arguments), \
             patch.object(launcher.os, "execv") as execute:
            self.assertEqual(launcher.main(), 0)
        execute.assert_called_once_with(str(entry), [str(entry), *arguments[1:]])

    def test_missing_and_multiple_packages(self):
        with self.assertRaisesRegex(launcher.LauncherError, "見つかりません"):
            launcher.resolve_entrypoint(self.app)
        self.package()
        self.package("SharedSupport/second package")
        with self.assertRaisesRegex(launcher.LauncherError, "複数"):
            launcher.resolve_entrypoint(self.app)

    def test_unknown_layout_version_and_invalid_json(self):
        manifest, _ = self.package(layoutVersion=2)
        with self.assertRaisesRegex(launcher.LauncherError, "未対応"):
            launcher.resolve_entrypoint(self.app)
        manifest.write_text("{broken")
        with self.assertRaisesRegex(launcher.LauncherError, "読めません"):
            launcher.resolve_entrypoint(self.app)

    def test_absolute_and_escaping_entrypoints(self):
        manifest, _ = self.package()
        outside = self.app / "Contents/outside"
        outside.write_text("#!/bin/sh\nexit 0\n")
        outside.chmod(0o755)
        for entrypoint in [str(outside), "../../outside"]:
            with self.subTest(entrypoint=entrypoint):
                manifest.write_text(json.dumps({
                    "variant": "codex", "layoutVersion": 1, "entrypoint": entrypoint,
                }))
                with self.assertRaises(launcher.LauncherError):
                    launcher.resolve_entrypoint(self.app)

    def test_missing_or_nonexecutable_entrypoint_reports_error(self):
        _, entry = self.package()
        for remove in [False, True]:
            with self.subTest(remove=remove):
                if remove:
                    entry.unlink()
                else:
                    entry.chmod(0o644)
                stderr = io.StringIO()
                with patch.object(launcher, "find_app", return_value=self.app), \
                     patch.object(launcher.os, "execv") as execute, \
                     contextlib.redirect_stderr(stderr):
                    self.assertEqual(launcher.main(), 1)
                execute.assert_not_called()
                self.assertIn("error:", stderr.getvalue())

    def test_missing_app_reports_error(self):
        failure = subprocess.CalledProcessError(1, ["osascript"])
        stderr = io.StringIO()
        with patch.object(launcher.subprocess, "run", side_effect=failure), \
             contextlib.redirect_stderr(stderr):
            self.assertEqual(launcher.main(), 1)
        self.assertIn("所在を取得できません", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
