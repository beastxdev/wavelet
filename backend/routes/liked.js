const express = require('express');
const { readJson, uniqueById, writeJson } = require('../utils/jsonStore');

const router = express.Router();
const file = 'liked.json';

router.get('/', async (_req, res, next) => {
  try {
    res.json(await readJson(file));
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const liked = await readJson(file);
    const nextLiked = uniqueById([req.body, ...liked]);
    res.status(201).json(await writeJson(file, nextLiked));
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const liked = await readJson(file);
    res.json(await writeJson(file, liked.filter((track) => track.id !== req.params.id)));
  } catch (error) {
    next(error);
  }
});

module.exports = router;
