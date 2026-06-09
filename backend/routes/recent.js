const express = require('express');
const { readJson, uniqueById, writeJson } = require('../utils/jsonStore');

const router = express.Router();
const file = 'recent.json';

router.get('/', async (_req, res, next) => {
  try {
    res.json(await readJson(file));
  } catch (error) {
    next(error);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const recent = await readJson(file);
    const nextRecent = uniqueById([{ ...req.body, playedAt: new Date().toISOString() }, ...recent]).slice(0, 50);
    res.status(201).json(await writeJson(file, nextRecent));
  } catch (error) {
    next(error);
  }
});

module.exports = router;
