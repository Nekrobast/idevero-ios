import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';

const base = 'fc4af6faba6b1dfa8997e4f6e36cbbd9ecd689a1';
const allowed = new Set(['Idevero/Views/DiscoveryPresentation.swift', 'Idevero/Views/ResultView.swift', 'Idevero/Knowledge/DiscoveryDisplayMetadata.json']);
const changed = execFileSync('git', ['diff', '--name-only', base, '--', 'Idevero'], { encoding: 'utf8' }).trim().split(/\r?\n/).filter(Boolean);
for (const path of changed) if (!allowed.has(path)) throw new Error('Build-13 frozen production surface changed: ' + path);
const baseline = JSON.parse(execFileSync('git', ['show', base + ':Idevero/Knowledge/DiscoveryDisplayMetadata.json'], { encoding: 'utf8' }));
const current = JSON.parse(readFileSync('Idevero/Knowledge/DiscoveryDisplayMetadata.json', 'utf8'));
for (const old of baseline.entries) {
  if (!current.entries.some(entry => JSON.stringify(entry) === JSON.stringify(old))) throw new Error('Physically accepted build-13 copy changed: ' + old.ids.join(','));
}
const row = readFileSync('Idevero/Views/ResultView.swift', 'utf8');
if (!row.includes('onState(item.id, state)') || !row.includes('display.controlTitle(state)') || !row.includes('display.isSelectedAction(state)')) throw new Error('Original identity callback / selected-action presentation missing');
if (!row.includes('DiscoveryPresentation.summary(displayedDiscoveries)') || !row.includes('moreRecommendations')) throw new Error('Lossless shared progressive disclosure missing');
const additions = execFileSync('git', ['diff', '--unified=0', base, '--', 'Idevero'], { encoding: 'utf8' }).split(/\r?\n/).filter(line => line.startsWith('+') && !line.startsWith('+++')).join('\n');
if (/comunidad de vecinos|ascensores|garajes|proveedores|telescope bookings|archive digitization|SAMPLE_KEY|ISO 17025/i.test(additions)) throw new Error('Fixture-specific production presentation detected');
console.log('PASS: build-13 engine, models, compiler, providers, persistence, original plain copy frozen; three presentation-only files; original action callbacks; no physical/holdout fixture hardcodes');
