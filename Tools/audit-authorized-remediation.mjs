import { readFileSync, existsSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';

export const BASE = '36b36c2463e00e3ef148f7d8ac7fe8f7a99d6a1d';
export const PHYSICAL = '61eb2a8490b1bcfcbedbaadfda18b4746035326f';
// Control-plane files require review, never blanket authorization for directories.
export const allowed = new Set([
  'Tools/audit-authorized-remediation.mjs',
  'Tools/test-authorized-remediation.mjs',
  'Tools/authorized-remediation-snapshots.json',
  'PRE-1.0-MINIMAL-REMEDIATION.md',
  'MINIMAL-REMEDIATION-BUILD15-RETEST.md',
  'Idevero.xcodeproj/project.pbxproj',
  'Tools/audit-physical-v6.mjs',
  'Tools/VERIFY-IDEVERO-0.2.9-BUILD15.ps1',
  '.github/workflows/ios-ci.yml',
  '.github/workflows/minimal-remediation-targeted.yml',
  'Idevero/Views/SettingsView.swift',
  'Idevero/Views/CreateView.swift',
  'Idevero/Views/HistoryView.swift',
  'Idevero/Views/PrivacySupportConfiguration.swift',
  'Idevero/Views/PrivacySupportAccessView.swift',
  'Idevero/Views/PersistenceFeedback.swift',
  'IdeveroTests/MinimalComplianceSaveTests.swift',
  'IdeveroUITests/MinimalComplianceSaveUITests.swift',
  'IdeveroUITests/PresentationRemediationUITests.swift',
  'docs/index.html', 'docs/privacy.html', 'docs/support.html',
  'docs/styles.css', 'docs/.nojekyll', 'docs/PAGES-PREPARATION.md'
]);
export const digest = value => createHash('sha256').update(value).digest('hex');
export const normalized = value => Buffer.from(value).toString('utf8').replaceAll('\n', '\n');

export function validateChange(path, before, after, snapshots) {
  if (before !== null && after !== null && Buffer.from(before).equals(Buffer.from(after))) return;
  if (!allowed.has(path)) throw new Error('Frozen/out-of-scope file: ' + path);
  if (after === null) throw new Error('Deletion prohibited: ' + path);
  if (path === 'Tools/authorized-remediation-snapshots.json') return;
  if (path === 'Idevero.xcodeproj/project.pbxproj' &&
      normalized(after) !== normalized(before).replaceAll('CURRENT_PROJECT_VERSION = 14;', 'CURRENT_PROJECT_VERSION = 15;'))
    throw new Error('Only the authorized build 14 to 15 increment is permitted');
  if (path === 'Tools/audit-physical-v6.mjs' &&
      normalized(after) !== normalized(before).replaceAll('CURRENT_PROJECT_VERSION = 14', 'CURRENT_PROJECT_VERSION = 15').replaceAll('build 14;', 'build 15;'))
    throw new Error('Historical physical audit permits only the build expectation correction');
  // Exact full-file review seal protects mixed files as well as allowed additions.
  // Even an accidental change INSIDE an allowed UI file fails until separately reviewed.
  const expected = snapshots[path];
  if (!expected || digest(Buffer.from(normalized(after))) !== expected)
    throw new Error('Unreviewed content (exact seal mismatch): ' + path);
}
export function readPolicy() {
  const policy = JSON.parse(readFileSync('Tools/authorized-remediation-snapshots.json', 'utf8'));
  if (policy.version !== 1 || policy.base !== BASE || policy.physicalBaseline !== PHYSICAL)
    throw new Error('Invalid authoritative baselines');
  if (Object.keys(policy).some(k => !['version','base','physicalBaseline','snapshots'].includes(k)))
    throw new Error('Unexpected policy fields');
  for (const [path, hash] of Object.entries(policy.snapshots)) {
    if (!allowed.has(path) || path === 'Tools/authorized-remediation-snapshots.json' || !/^[0-9a-f]{64}$/.test(hash))
      throw new Error('Invalid review seal: ' + path);
  }
  return policy;
}
export function audit() {
  execFileSync('git', ['merge-base', '--is-ancestor', BASE, 'HEAD']);
  const policy = readPolicy();
  const tracked = execFileSync('git', ['ls-tree', '-r', '-z', '--name-only', BASE], {encoding:'utf8'}).split('\0').filter(Boolean);
  const current = execFileSync('git', ['ls-files', '-z', '--cached', '--others', '--exclude-standard'], {encoding:'utf8'}).split('\0').filter(Boolean);
  const paths = new Set([...tracked, ...current].filter(Boolean));
  for (const path of paths) {
    let before = null;
    if (tracked.includes(path)) before = execFileSync('git', ['show', BASE + ':' + path], {maxBuffer:20 * 1024 * 1024});
    const after = existsSync(path) ? readFileSync(path) : null;
    if (before !== null && after !== null) {
      // Compare Git-canonical bytes, respecting CRLF checkout filters on Windows.
      // Binary files remain byte-exact; never decode arbitrary binaries as UTF-8.
      const canonicalCurrent = execFileSync('git', ['hash-object', '--path=' + path, path], {encoding:'utf8'}).trim();
      const canonicalBase = execFileSync('git', ['rev-parse', BASE + ':' + path], {encoding:'utf8'}).trim();
      if (canonicalCurrent === canonicalBase) continue;
    }
    validateChange(path, before, after, policy.snapshots);
  }
  // No broad directory allowance: ALL existing tests/model/provider/compiler/etc.
  // are byte-identical to the consolidated baseline unless explicitly review-sealed UI.
  const workflow = normalized(readFileSync('.github/workflows/ios-ci.yml'));
  const original = normalized(execFileSync('git', ['show', BASE + ':.github/workflows/ios-ci.yml']));
  const marker = '      - name: Select installed Xcode\n';
  // Demonstrated build-14 metadata incompatibility: alter only artifact metadata,
  // never the existing native test/build/re-signability commands or assertions.
  const expectedTail = original.slice(original.indexOf(marker))
    .replaceAll('build 14 —', 'build 15 —')
    .replace('raw "$INFO")" = "14"', 'raw "$INFO")" = "15"')
    .replace('"version": "0.2.9", "build": 14,', '"version": "0.2.9", "build": 15,')
    .replace('"productionEquivalentToPhysicalBaseline": True', '"productionEquivalentToPhysicalBaseline": False')
    .replaceAll('VERIFY-IDEVERO-0.2.9-BUILD14.ps1', 'VERIFY-IDEVERO-0.2.9-BUILD15.ps1')
    .replace('          cp HUMAN-FRIENDLY-UX-BUILD14-RETEST.md Tools/VERIFY-IDEVERO-0.2.9-BUILD15.ps1 DeviceArtifact/',
             '          cp HUMAN-FRIENDLY-UX-BUILD14-RETEST.md Tools/VERIFY-IDEVERO-0.2.9-BUILD15.ps1 DeviceArtifact/\n          cp MINIMAL-REMEDIATION-BUILD15-RETEST.md DeviceArtifact/')
    .replace('            DeviceArtifact/VERIFY-IDEVERO-0.2.9-BUILD15.ps1',
             '            DeviceArtifact/MINIMAL-REMEDIATION-BUILD15-RETEST.md\n            DeviceArtifact/VERIFY-IDEVERO-0.2.9-BUILD15.ps1');
  if (workflow.slice(workflow.indexOf(marker)) !== expectedTail)
    throw new Error('Existing XCTest/UI/device gate or artifact pipeline changed');
  console.log('PASS: Authorized Remediation Diff Gate; exact reviewed snapshots; all other files frozen');
  console.log('PHYSICALLY VALIDATED BASELINE ' + PHYSICAL);
  console.log('CONSOLIDATED PRE-1.0 BASELINE ' + BASE);
}
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) audit();
