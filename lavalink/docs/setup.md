# Lavalink Setup

Wavelet expects a Lavalink v4 server reachable by the backend.

## Local Configuration

1. Keep `lavalink/application.yml` in source control without real production secrets.
2. Set the same password in `backend/.env`:

```env
LAVALINK_HOST=http://localhost:2333
LAVALINK_PASSWORD=change-me
```

3. Start Lavalink:

```bash
cd lavalink
java -jar Lavalink.jar
```

## Security

- Do not commit real Lavalink passwords.
- Do not expose Lavalink publicly unless it is protected.
- Keep Lavalink jars and plugin jars out of Git; download them during local setup or deployment.
- Use environment-specific credentials in deployment platforms.
