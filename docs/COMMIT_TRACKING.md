# Commit tracking

Git commit history is the canonical record of code changes.

For every program change:

1. Read the latest commit and current files before editing.
2. Review all commits since the last known commit, regardless of count.
3. Compare the previous and current commit when determining what changed.
4. Do not repeat an already completed change unless the user requests a revision.
5. Record each release in `CHANGELOG.md` and `VERSION_INFO.txt`.
6. Keep one coherent implementation change per commit where practical.

The assistant can inspect recent commits, fetch any commit, compare two commits, and review changed files through the connected GitHub repository.
