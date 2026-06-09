const fs = require('fs/promises');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');

async function ensureFile(name, fallback) {
  await fs.mkdir(dataDir, { recursive: true });
  const file = path.join(dataDir, name);
  try {
    await fs.access(file);
  } catch {
    await fs.writeFile(file, JSON.stringify(fallback, null, 2));
  }
  return file;
}

async function readJson(name, fallback = []) {
  const file = await ensureFile(name, fallback);
  const raw = await fs.readFile(file, 'utf8');
  try {
    return JSON.parse(raw || JSON.stringify(fallback));
  } catch {
    await writeJson(name, fallback);
    return fallback;
  }
}

async function writeJson(name, value) {
  const file = await ensureFile(name, Array.isArray(value) ? [] : {});
  await fs.writeFile(file, JSON.stringify(value, null, 2));
  return value;
}

function uniqueById(items) {
  const seen = new Set();
  return items.filter((item) => {
    if (!item || !item.id || seen.has(item.id)) return false;
    seen.add(item.id);
    return true;
  });
}

module.exports = { readJson, writeJson, uniqueById };
