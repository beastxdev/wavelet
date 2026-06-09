# Contributing to Wavelet

Thanks for helping improve Wavelet.

## Forking

1. Fork the repository.
2. Clone your fork.
3. Add the upstream repository when needed:

```bash
git remote add upstream <upstream-repository-url>
```

## Branches

Create a focused branch from `main`:

```bash
git checkout main
git pull
git checkout -b feat/short-description
```

Recommended prefixes:

- `feat/` for new features
- `fix/` for bug fixes
- `docs/` for documentation
- `chore/` for maintenance
- `ci/` for workflow changes

## Commits

Use concise conventional commits:

```text
feat: add playlist search
fix: handle empty Lavalink results
docs: update backend setup
ci: add Flutter analyze workflow
```

Do not commit secrets, generated build output, `node_modules/`, `.env`, Lavalink jars, or local data files.

## Pull Requests

Before opening a pull request:

```bash
flutter analyze
cd backend
npm install
npm run lint --if-present
```

Open a pull request with:

- A clear summary.
- Screenshots or screen recordings for UI changes.
- Test notes.
- Linked issues when relevant.

Keep pull requests small and focused.
