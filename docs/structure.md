# Project Structure

Wavelet uses a practical Flutter-first repository layout:

```text
wavelet/
├── lib/                    # Flutter app source
├── backend/                # Node.js API
├── lavalink/               # Lavalink config and docs
├── docs/                   # Documentation
├── assets/                 # Images and branding
└── .github/                # GitHub templates and workflows
```

The prompt-style `music-app/frontend` layout maps to this repo as follows:

- `frontend/` -> Flutter files at the repository root (`lib/`, `android/`, `ios/`, `web/`, `pubspec.yaml`)
- `backend/` -> Node.js backend
- `lavalink/` -> Lavalink configuration
- `docs/` -> Project docs
- `assets/` -> App assets
