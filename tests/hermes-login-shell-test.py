"""Exercise the evaluated activation with isolated account/shell-file stand-ins."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
ACTIVATION = subprocess.check_output(
    [
        "nix", "eval", "--offline", "--raw",
        ".#homeConfigurations.hermesHome.config.home.activation.fishLoginShell.data",
    ],
    cwd=ROOT,
    text=True,
)


class LoginShellTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.shell = self.directory / "profile/bin/fish"
        self.shell.parent.mkdir(parents=True)
        self.shell.write_text("#!/bin/sh\nexit 0\n")
        self.shell.chmod(0o755)
        self.shells = self.directory / "shells"
        # Deliberately omit a trailing newline to check safe appending.
        self.shells.write_text("/bin/bash")
        self.account = self.directory / "account"
        self.account.write_text("/bin/bash")
        self.calls = self.directory / "calls"
        self.calls.touch()
        mocks = {
            "getent": '''
                [ "${MISSING_USER:-}" != 1 ] || exit 2
                printf 'inoyu:x:1000:1000::/home/inoyu:%s\\n' "$(cat "$ACCOUNT")"
            ''',
            "sudo": '''
                echo sudo >> "$CALLS"
                [ "${DENY_SUDO:-}" != 1 ] || exit 1
                exec "$@"
            ''',
            "chsh": '''
                [ "$1" = -s ] && [ "$3" = inoyu ] || exit 2
                echo chsh >> "$CALLS"
                [ "${FAIL_CHSH:-}" != 1 ] || exit 1
                printf '%s' "$2" > "$ACCOUNT"
            ''',
        }
        script = ACTIVATION.replace("/home/inoyu/.nix-profile/bin/fish", str(self.shell))
        script = script.replace("/etc/shells", str(self.shells))
        for name, body in mocks.items():
            path = self.directory / name
            path.write_text("#!/bin/sh\nset -eu\n" + body)
            path.chmod(0o755)
            script = script.replace("/usr/bin/" + name, str(path))
        self.script = '''
            set -euo pipefail
            run() { if [ -z "${DRY_RUN:-}" ]; then "$@"; fi; }
        ''' + script

    def activate(self, **environment):
        return subprocess.run(
            ["/bin/bash", "-c", self.script],
            env={**os.environ, "ACCOUNT": str(self.account), "CALLS": str(self.calls),
                 "DRY_RUN": "", **environment},
            capture_output=True,
            text=True,
        )

    def test_first_activation_and_repeat(self):
        result = self.activate()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.account.read_text(), str(self.shell))
        self.assertEqual(self.shells.read_text().splitlines(), ["/bin/bash", str(self.shell)])
        self.assertEqual(self.calls.read_text(), "sudo\nchsh\n")
        self.assertEqual(self.activate().returncode, 0)
        self.assertEqual(self.calls.read_text(), "sudo\nchsh\n")

    def test_repair_registration_without_changing_account(self):
        self.account.write_text(str(self.shell))
        self.assertEqual(self.activate().returncode, 0)
        self.assertIn(str(self.shell), self.shells.read_text().splitlines())
        self.assertEqual(self.calls.read_text(), "sudo\n")

    def test_existing_registration_is_not_duplicated(self):
        self.shells.write_text("/bin/bash\n" + str(self.shell) + "\n")
        self.assertEqual(self.activate().returncode, 0)
        self.assertEqual(self.shells.read_text().splitlines().count(str(self.shell)), 1)

    def test_dry_run_before_packages_are_installed(self):
        self.shell.unlink()
        self.assertEqual(self.activate(DRY_RUN="1").returncode, 0)
        self.assertEqual(self.calls.read_text(), "")
        self.assertEqual(self.shells.read_text(), "/bin/bash")
        self.assertEqual(self.account.read_text(), "/bin/bash")

    def test_missing_executable_or_user_and_denied_sudo(self):
        for environment in [{"MISSING_USER": "1"}, {"DENY_SUDO": "1"}, {}]:
            if not environment:
                self.shell.unlink()
            self.assertNotEqual(self.activate(**environment).returncode, 0)
            self.assertEqual(self.shells.read_text(), "/bin/bash")
            self.assertEqual(self.account.read_text(), "/bin/bash")

    def test_chsh_failure_is_reported_and_retry_succeeds(self):
        self.assertNotEqual(self.activate(FAIL_CHSH="1").returncode, 0)
        self.assertEqual(self.account.read_text(), "/bin/bash")
        self.assertEqual(self.activate().returncode, 0)
        self.assertEqual(self.account.read_text(), str(self.shell))
        self.assertEqual(self.shells.read_text().splitlines().count(str(self.shell)), 1)


if __name__ == "__main__":
    unittest.main()
