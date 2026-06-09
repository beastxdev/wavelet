const crypto = require('crypto');
const express = require('express');
const { readJson, uniqueById, writeJson } = require('../utils/jsonStore');

const router = express.Router();
const file = 'playlists.json';

router.get('/', async (_req, res, next) => {
  try {
    res.json(await readJson(file));
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const name = (req.body.name || '').toString().trim();
    if (!name) return res.status(400).json({ error: 'Playlist name is required' });
    const playlists = await readJson(file);
    const playlist = { id: crypto.randomUUID(), name, tracks: [], createdAt: new Date().toISOString() };
    res.status(201).json(await writeJson(file, [playlist, ...playlists]));
  } catch (error) {
    next(error);
  }
});

router.post('/:id/tracks', async (req, res, next) => {
  try {
    const playlists = await readJson(file);
    const nextPlaylists = playlists.map((playlist) => {
      if (playlist.id !== req.params.id) return playlist;
      return { ...playlist, tracks: uniqueById([req.body, ...(playlist.tracks || [])]) };
    });
    res.status(201).json(await writeJson(file, nextPlaylists));
  } catch (error) {
    next(error);
  }
});

router.delete('/:id/tracks/:trackId', async (req, res, next) => {
  try {
    const playlists = await readJson(file);
    const nextPlaylists = playlists.map((playlist) => {
      if (playlist.id !== req.params.id) return playlist;
      return { ...playlist, tracks: (playlist.tracks || []).filter((track) => track.id !== req.params.trackId) };
    });
    res.json(await writeJson(file, nextPlaylists));
  } catch (error) {
    next(error);
  }
});

module.exports = router;
