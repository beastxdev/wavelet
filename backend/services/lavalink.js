const crypto = require('crypto');

const host = () => (process.env.LAVALINK_HOST || 'http://localhost:2333').replace(/\/+$/, '');
const password = () => process.env.LAVALINK_PASSWORD || 'youshallnotpass';
const source = () => process.env.LAVALINK_SEARCH_SOURCE || 'ytsearch';

async function searchTracks(query) {
  const identifier = query.includes(':') ? query : `${source()}:${query}`;
  const url = new URL(`${host()}/v4/loadtracks`);
  url.searchParams.set('identifier', identifier);

  let response;
  try {
    response = await fetch(url, {
      headers: {
        Authorization: password(),
      },
    });
  } catch (cause) {
    const error = new Error(`Lavalink is not reachable at ${host()}. Start Lavalink or update LAVALINK_HOST in backend/.env.`);
    error.status = 503;
    error.cause = cause;
    throw error;
  }

  if (!response.ok) {
    const message = await response.text();
    const error = new Error(`Lavalink request failed: ${message || response.statusText}`);
    error.status = response.status;
    throw error;
  }

  const payload = await response.json();
  const tracks = payload.tracks || payload.data || [];
  return tracks.map(normalizeTrack).filter(Boolean);
}

function normalizeTrack(item) {
  const info = item.info || item;
  const encodedTrack = item.encoded || item.encodedTrack || item.track || '';
  const idSource = `${encodedTrack}:${info.identifier || info.uri || info.title}`;

  return {
    id: crypto.createHash('sha1').update(idSource).digest('hex'),
    title: info.title || 'Unknown title',
    author: info.author || 'Unknown artist',
    duration: Number(info.length || info.duration || 0),
    thumbnail: info.artworkUrl || info.thumbnail || youtubeThumbnail(info.identifier),
    encodedTrack,
    source: info.sourceName || 'unknown',
    streamUrl: streamUrlFor(info),
  };
}

function streamUrlFor(info) {
  if (isDirectAudioUrl(info.uri)) return info.uri;
  if (info.sourceName === 'youtube' && info.identifier) {
    return `/api/stream/youtube/${encodeURIComponent(info.identifier)}`;
  }
  return null;
}

function youtubeThumbnail(identifier) {
  if (!identifier) return '';
  return `https://img.youtube.com/vi/${identifier}/hqdefault.jpg`;
}

function isDirectAudioUrl(uri) {
  return typeof uri === 'string' && /^https?:\/\//i.test(uri) && /\.(mp3|m4a|aac|ogg|opus|wav|flac)(\?|$)/i.test(uri);
}

module.exports = { searchTracks };
