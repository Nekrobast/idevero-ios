import { readFileSync } from 'node:fs';
import { execFileSync, spawnSync } from 'node:child_process';

const base = 'b4d577dd3e703e83c5236194184ca6f4ba8954af';
const changes = execFileSync('git', ['diff', '--unified=0', base, '--', 'Idevero'], { encoding: 'utf8' });
const added = changes.split(/\r?\n/).filter(line => line.startsWith('+') && !line.startsWith('+++')).join('\n');
const forbidden = /apicultores|abejas|\bmiel\b|producción diaria|\bboda\b|\bRSVP\b|invitados|SKU_ID|VAT_ID|personal trainers|workout plans|operations_registry/i;
if (forbidden.test(added)) throw new Error('Production additions contain a physical fixture-specific term');
const unchanged = execFileSync('git', ['diff', base, '--', 'Idevero/Models/DiscoverySemantics.swift'], { encoding: 'utf8' });
if (unchanged.trim()) throw new Error('Conservative semantic identity unexpectedly changed');
const project = readFileSync('Idevero.xcodeproj/project.pbxproj', 'utf8');
if (!project.includes('CURRENT_PROJECT_VERSION = 11') || !project.includes('MARKETING_VERSION = 0.2.8')) throw new Error('Candidate version/build mismatch');
const production = spawnSync('git', ['grep', '-n', '-E', 'OPENAI_API_KEY|api.openai.com', '--', 'Idevero'], { encoding: 'utf8' });
if (production.status !== 1) throw new Error('Paid API audit failed: ' + production.stdout + production.stderr);
console.log('PASS: hard-code additions audit; unchanged conservative identity; 0.2.8 build 11; no OpenAI API');

