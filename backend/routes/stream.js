const { Readable } = require('stream');
const express = require('express');

const router = express.Router();

const lavalinkHost = () => (process.env.LAVALINK_HOST || 'http://localhost:2333').replace(/\/+$/, '');
const lavalinkPassword = () => process.env.LAVALINK_PASSWORD || 'youshallnotpass';

router.get('/youtube/:videoId', async (req, res, next) => {
  try {
    const videoId = req.params.videoId;
    const url = `${lavalinkHost()}/youtube/stream/${encodeURIComponent(videoId)}`;
    const headers = {
      Authorization: lavalinkPassword(),
    };
    if (req.headers.range) {
      headers.Range = req.headers.range;
    }

    const response = await fetch(url, {
      headers,
    });

    if (!response.ok || !response.body) {
      const message = await response.text();
      return res.status(response.status).json({
        error: message || 'Lavalink could not open the YouTube stream',
      });
    }

    res.status(response.status);
    const contentType = response.headers.get('content-type');
    const contentLength = response.headers.get('content-length');
    const acceptRanges = response.headers.get('accept-ranges');
    const contentRange = response.headers.get('content-range');

    if (contentType) res.setHeader('Content-Type', contentType);
    if (contentLength) res.setHeader('Content-Length', contentLength);
    if (acceptRanges) res.setHeader('Accept-Ranges', acceptRanges);
    if (contentRange) res.setHeader('Content-Range', contentRange);
    res.setHeader('Cache-Control', 'no-store');

    Readable.fromWeb(response.body).pipe(res);
  } catch (error) {
    error.status = error.status || 503;
    error.message = `Unable to stream from Lavalink: ${error.message}`;
    next(error);
  }
});

module.exports = router;
