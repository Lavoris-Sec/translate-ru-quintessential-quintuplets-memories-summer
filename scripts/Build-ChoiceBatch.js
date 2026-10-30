const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const rows = JSON.parse(fs.readFileSync(path.join(root, 'translation/choices-batch-data.json'), 'utf8'));
const records = [];
for (const [scenario, scene, speaker, prompt, ...choices] of rows) {
  const file = `${scenario}.txt.scn.m.json`;
  const base = `$.scenes[${scene}]`;
  records.push({file, jsonPath: `${base}.selectInfo.language[1].disp`, translation: speaker});
  for (const [target, value] of [[`${base}.selectInfo`, prompt], ...choices.map((v, i) => [`${base}.selects[${i}]`, v])]) {
    for (const field of ['text', 'searchtext', 'speechtext']) {
      records.push({file, jsonPath: `${target}.language[1].${field}`, translation: field === 'text' ? value : value.replace(/%p-?\d*;/g, '').replace(/\\n/g, ' ')});
    }
  }
}
fs.writeFileSync(path.join(root, 'translation/goto01-choices-batch.json'), JSON.stringify(records, null, 2) + '\n');
