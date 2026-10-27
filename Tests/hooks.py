"""Exercise the pre-commit hook through real commits in disposable repositories."""

import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
UNFORMATTED = b"local value={1,2}\n"
FORMATTED = b"local value = { 1, 2 }\n"


class PreCommitTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix="nvim-hooks-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.env = {
            key: value for key, value in os.environ.items() if not key.startswith("GIT_")
        }
        self.env.update(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull)
        self.git("init", "-q")
        self.git("config", "user.name", "Hook Test")
        self.git("config", "user.email", "hook@example.invalid")
        self.git("config", "core.hooksPath", ".githooks")
        (self.root / ".githooks").mkdir()
        shutil.copy2(ROOT / ".githooks/pre-commit", self.root / ".githooks/pre-commit")
        shutil.copy2(ROOT / ".stylua.toml", self.root / ".stylua.toml")

    def git(self, *args, check=True):
        return subprocess.run(
            ["git", *args],
            cwd=self.root,
            env=self.env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=check,
        )

    def write(self, filename, content, stage=True):
        path = self.root / filename
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
        if stage:
            self.git("add", "--", filename)
        return path

    def commit(self, *args, check=True):
        return self.git("commit", "-qm", "Test commit", *args, check=check)

    def hide_formatter(self):
        bin_dir = self.root / "bin"
        bin_dir.mkdir()
        (bin_dir / "python3").symlink_to(sys.executable)
        (bin_dir / "git").symlink_to(shutil.which("git"))
        self.env["PATH"] = str(bin_dir)

    def test_initial_commit_formats_staged_file_and_worktree(self):
        path = self.write("lua/first.lua", UNFORMATTED)
        self.commit()
        self.assertEqual(self.git("show", "HEAD:lua/first.lua").stdout, FORMATTED)
        self.assertEqual(path.read_bytes(), FORMATTED)
        self.assertEqual(self.git("diff").stdout, b"")

    def test_partial_staging_preserves_unstaged_edits(self):
        path = self.write("partial.lua", UNFORMATTED)
        unstaged = UNFORMATTED + b"local unfinished =\n"
        path.write_bytes(unstaged)
        other = self.write("untracked.lua", UNFORMATTED, stage=False)
        self.commit()
        self.assertEqual(self.git("show", "HEAD:partial.lua").stdout, FORMATTED)
        self.assertEqual(path.read_bytes(), unstaged)
        self.assertEqual(other.read_bytes(), UNFORMATTED)
        self.assertEqual(self.git("ls-tree", "--name-only", "HEAD").stdout, b"partial.lua\n")

    def test_syntax_error_leaves_entire_index_and_worktree_unchanged(self):
        good = self.write("a-good.lua", UNFORMATTED)
        bad = self.write("z-bad.lua", b"local value =\n")
        before = self.git("write-tree").stdout
        result = self.commit(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"StyLua failed", result.stderr)
        self.assertEqual(self.git("write-tree").stdout, before)
        self.assertEqual(good.read_bytes(), UNFORMATTED)
        self.assertEqual(bad.read_bytes(), b"local value =\n")

    def test_missing_formatter_blocks_lua_commit(self):
        self.write("first.lua", UNFORMATTED)
        before = self.git("write-tree").stdout
        self.hide_formatter()
        result = self.commit(check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"StyLua is unavailable", result.stderr)
        self.assertEqual(self.git("write-tree").stdout, before)

    def test_non_lua_commit_does_not_need_formatter(self):
        self.write("notes.txt", b"Notes\n")
        self.hide_formatter()
        self.commit()

    def test_rename_deletion_symlink_and_unusual_filename(self):
        self.write("old.lua", FORMATTED)
        self.write("deleted.lua", FORMATTED)
        self.commit()
        filename = "renamed space\t换行\nfile.lua"
        self.git("mv", "old.lua", filename)
        path = self.write(filename, UNFORMATTED)
        path.chmod(0o755)
        self.git("add", "--", filename)
        self.git("rm", "deleted.lua")
        (self.root / "link.lua").symlink_to(filename)
        self.git("add", "link.lua")
        self.commit()
        self.assertEqual(self.git("show", "HEAD:" + filename).stdout, FORMATTED)
        self.assertTrue(self.git("ls-files", "--stage", "--", filename).stdout.startswith(b"100755"))
        self.assertEqual(path.stat().st_mode & 0o777, 0o755)
        self.assertTrue((self.root / "link.lua").is_symlink())
        self.assertNotEqual(self.git("cat-file", "-e", "HEAD:deleted.lua", check=False).returncode, 0)

    def test_commit_only_rejects_formatting_without_changing_either_index(self):
        self.write("selected.lua", FORMATTED)
        self.write("other.lua", FORMATTED)
        self.commit()
        self.write("selected.lua", b"local selected={3,4}\n", stage=False)
        self.write("other.lua", b"local other={5,6}\n")
        before = self.git("write-tree").stdout
        result = self.commit("--only", "--", "selected.lua", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(b"temporary or alternate index", result.stderr)
        self.assertEqual(self.git("write-tree").stdout, before)
        self.assertEqual((self.root / "selected.lua").read_bytes(), b"local selected={3,4}\n")
        self.assertEqual(self.git("show", "HEAD:selected.lua").stdout, FORMATTED)
        self.assertEqual(self.git("show", "HEAD:other.lua").stdout, FORMATTED)

    def test_commit_only_accepts_already_formatted_files(self):
        self.write("selected.lua", FORMATTED)
        self.commit()
        expected = b"local selected = { 3, 4 }\n"
        self.write("selected.lua", expected, stage=False)
        self.commit("--only", "--", "selected.lua")
        self.assertEqual(self.git("show", "HEAD:selected.lua").stdout, expected)
        self.assertEqual(self.git("diff", "HEAD").stdout, b"")

    def test_unstaged_deletion_is_preserved(self):
        path = self.write("removed.lua", UNFORMATTED)
        path.unlink()
        self.commit()
        self.assertEqual(self.git("show", "HEAD:removed.lua").stdout, FORMATTED)
        self.assertFalse(path.exists())


if __name__ == "__main__":
    unittest.main()
