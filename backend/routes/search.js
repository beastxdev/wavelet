const express = require('express');
const { searchTracks } = require('../services/lavalink');

const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const query = (req.query.q || '').toString().trim();
    if (!query) return res.json([]);
    const tracks = await searchTracks(query);
    res.json(tracks);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
