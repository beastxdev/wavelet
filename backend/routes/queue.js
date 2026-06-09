const express = require('express');
const { readJson, writeJson } = require('../utils/jsonStore');

const router = express.Router();
const file = 'queue.json';

router.get('/', async (_req, res, next) => {
  try {
    res.json(await readJson(file));
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const queue = await readJson(file);
    res.status(201).json(await writeJson(file, [...queue, req.body]));
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const queue = await readJson(file);
    res.json(await writeJson(file, queue.filter((track) => track.id !== req.params.id)));
  } catch (error) {
    next(error);
  }
});

router.delete('/', async (_req, res, next) => {
  try {
    res.json(await writeJson(file, []));
  } catch (error) {
    next(error);
  }
});

module.exports = router;
