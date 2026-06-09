const cors = require('cors');
const dotenv = require('dotenv');
const express = require('express');

dotenv.config();

const searchRoutes = require('./routes/search');
const likedRoutes = require('./routes/liked');
const recentRoutes = require('./routes/recent');
const playlistRoutes = require('./routes/playlists');
const queueRoutes = require('./routes/queue');
const streamRoutes = require('./routes/stream');

const app = express();
const port = process.env.PORT || 3000;
const host = process.env.HOST || '0.0.0.0';

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, app: 'Wavelet' });
});

app.use('/api/search', searchRoutes);
app.use('/api/liked', likedRoutes);
app.use('/api/recent', recentRoutes);
app.use('/api/playlists', playlistRoutes);
app.use('/api/queue', queueRoutes);
app.use('/api/stream', streamRoutes);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

app.listen(port, host, () => {
  console.log(`Wavelet backend listening on http://${host}:${port}`);
  console.log(`Use http://YOUR_COMPUTER_LAN_IP:${port}/api from phones or other devices.`);
});
