import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

const base = 'fc5b5b5fc1763adcc1d11ae0022dfde545e56051';
const frozen = ['Idevero/Intelligence', 'Idevero/Models', 'Idevero/ViewModels', 'Idevero/Views/OperationFeedbackView.swift', 'Idevero/Views/RootView.swift', 'Idevero/Views/HistoryView.swift'];
for (const path of frozen) {
  if (execFileSync('git', ['diff', base, '--', path], { encoding: 'utf8' }).trim()) throw new Error('Frozen semantic/runtime surface changed: ' + path);
}
const allowed = new Set(['Idevero/Views/DiscoveryPresentation.swift', 'Idevero/Views/ResultView.swift', 'Idevero/Views/CreateView.swift', 'Idevero/Views/SettingsView.swift', 'Idevero/Knowledge/DiscoveryDisplayMetadata.json']);
for (const path of execFileSync('git', ['diff', '--name-only', base, '--', 'Idevero'], { encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean)) {
  if (!allowed.has(path)) throw new Error('Unexpected production edit: ' + path);
}
const concepts = JSON.parse(readFileSync('Idevero/Knowledge/Concepts.json')).concepts;
const strategies = JSON.parse(readFileSync('Idevero/Knowledge/StrategyPacks.json')).strategies;
const known = new Set([...concepts.map(c => 'K_' + c.id), ...strategies.flatMap(s => s.candidates.map((_, i) => 'S_' + s.id + '_' + i))]);
const catalog = JSON.parse(readFileSync('Idevero/Knowledge/DiscoveryDisplayMetadata.json'));
const seen = new Set();
if (catalog.schema !== 1) throw new Error('Invalid display schema');
for (const entry of catalog.entries) {
  for (const id of entry.ids) {
    if (!known.has(id) || seen.has(id)) throw new Error('Unknown or repeated display resource: ' + id);
    seen.add(id);
  }
  for (const language of ['es', 'en']) {
    if (!entry.title[language]?.trim() || !entry.explanation[language]?.trim()) throw new Error('Missing bilingual copy');
  }
}
const row = readFileSync('Idevero/Views/ResultView.swift', 'utf8');
if (!row.includes('onState(item.id, state)')) throw new Error('Actions no longer use original discovery identity');
if (row.includes('displayName(language:') || row.includes('Text(item.semanticRole') || row.includes('Text(item.id)')) throw new Error('Raw metadata presentation detected');
console.log(`PASS: frozen semantic/runtime surfaces; original identity callbacks; ${catalog.entries.length} display concepts / ${seen.size} resource bindings; bilingual metadata`);
