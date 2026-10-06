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
  'Tools/test-causal-instrumentation.mjs',
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
  'Idevero/ViewModels/CreateViewModel.swift',
  'Idevero/Intelligence/IntelligenceCoordinator.swift',
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
export const normalized = value => Buffer.from(value).toString('utf8').replaceAll('\r\n', '\n');


export const CAUSAL_BASE = 'a2f1a21698bb4a59766bb168c0bc7f593fe6d503';
// Exact reviewed replacements only: not a generic logging/return normalizer.
export const causalRules = {
  "Idevero/Views/CreateView.swift": [
    [
      "import SwiftData\n",
      "import SwiftData\nimport OSLog\n\nprivate let causalCreateLogger = Logger(subsystem: \"com.aitor93.idevero.causal\", category: \"generation\")\n"
    ],
    [
      "    private func submit() {\n",
      "    private func submit() {\n        causalCreateLogger.notice(\"IDEVERO_CAUSAL E1 TAP_HANDLER_ENTER uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n"
    ]
  ],
  "Idevero/ViewModels/CreateViewModel.swift": [
    [
      "import Foundation\n",
      "import Foundation\nimport OSLog\n\nprivate let causalModelLogger = Logger(subsystem: \"com.aitor93.idevero.causal\", category: \"generation\")\n"
    ],
    [
      "    func generate() async {\n",
      "    func generate() async {\n        causalModelLogger.notice(\"IDEVERO_CAUSAL E2 GENERATION_TASK_START uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n"
    ],
    [
      "            guard generation == generationSequence, !Task.isCancelled else { return }\n            analysis = result\n            providerName = provider\n",
      "            causalModelLogger.notice(\"IDEVERO_CAUSAL E7 GENERATION_RESULT_READY uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n            guard generation == generationSequence, !Task.isCancelled else { return }\n            causalModelLogger.notice(\"IDEVERO_CAUSAL E8 MAINACTOR_RESULT_ASSIGN_BEGIN uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n            analysis = result\n            providerName = provider\n            causalModelLogger.notice(\"IDEVERO_CAUSAL E9 MAINACTOR_RESULT_ASSIGN_END uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n"
    ]
  ],
  "Idevero/Intelligence/IntelligenceCoordinator.swift": [
    [
      "import Foundation\n",
      "import Foundation\nimport OSLog\n\nprivate let causalCoordinatorLogger = Logger(subsystem: \"com.aitor93.idevero.causal\", category: \"generation\")\n"
    ],
    [
      "    func analyze(_ request: String) async throws -> (PromptAnalysis, String) {\n        if case .ready = await foundation.availability() {\n            do { return (try await foundation.analyze(request), foundation.name) }\n            catch is CancellationError { throw CancellationError() }\n            catch { return (try await local.analyze(request), local.name) }\n        }\n        return (try await local.analyze(request), local.name)\n    }\n\n",
      "    func analyze(_ request: String) async throws -> (PromptAnalysis, String) {\n        causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E3 PROVIDER_SELECTION_START uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n        if case .ready = await foundation.availability() {\n            do {\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E4 PROVIDER_SELECTED provider=FOUNDATION uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E5 PROVIDER_WORK_START provider=FOUNDATION uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                let causalFoundationResult = try await foundation.analyze(request)\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E6 PROVIDER_WORK_END provider=FOUNDATION uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                return (causalFoundationResult, foundation.name)\n            }\n            catch is CancellationError { throw CancellationError() }\n            catch {\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL FOUNDATION_ERROR provider=FOUNDATION uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL FALLBACK_START provider=FALLBACK_LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E4 PROVIDER_SELECTED provider=FALLBACK_LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E5 PROVIDER_WORK_START provider=FALLBACK_LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                let causalFallbackResult = try await local.analyze(request)\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E6 PROVIDER_WORK_END provider=FALLBACK_LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL FALLBACK_END provider=FALLBACK_LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n                return (causalFallbackResult, local.name)\n            }\n        }\n        causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E4 PROVIDER_SELECTED provider=LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n        causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E5 PROVIDER_WORK_START provider=LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n        let causalLocalResult = try await local.analyze(request)\n        causalCoordinatorLogger.notice(\"IDEVERO_CAUSAL E6 PROVIDER_WORK_END provider=LOCAL uptime=\\(ProcessInfo.processInfo.systemUptime, privacy: .public) wall=\\(Date.timeIntervalSinceReferenceDate, privacy: .public)\")\n        return (causalLocalResult, local.name)\n    }\n\n"
    ]
  ]
};
const causalHashes = {
  'Idevero/Views/CreateView.swift': 'bef7ee563a9a2d0583768a61c3523170c4c5a1dc960cfb53638d4458ab67b256',
  'Idevero/ViewModels/CreateViewModel.swift': '3663f1743e23e401a8a04fbc750f0c830655dae88a5ba5c7239409dded406374',
  'Idevero/Intelligence/IntelligenceCoordinator.swift': '8e459a2c6b1b631a3fceedb9d134be2f3e2a9c9bb6f155611112bf5c306259b1'
};
export function causalBaseline(path) {
  const baseline = normalized(execFileSync('git', ['show', CAUSAL_BASE + ':' + path]));
  if (digest(Buffer.from(baseline)) !== causalHashes[path]) throw new Error('Causal baseline hash mismatch: ' + path);
  return baseline;
}
export function causalExpected(path) {
  let value = causalBaseline(path);
  for (const [oldValue, newValue] of causalRules[path]) {
    if (value.split(oldValue).length !== 2) throw new Error('Nonunique causal boundary');
    value = value.replace(oldValue, newValue);
  }
  return value;
}
export function causalEquivalent(path, value) {
  value = normalized(value);
  if (value !== causalExpected(path)) throw new Error('Unauthorized diagnostic structure: ' + path);
  for (const [oldValue, newValue] of [...causalRules[path]].reverse()) {
    if (value.split(newValue).length !== 2) throw new Error('Nonunique reconstruction');
    value = value.replace(newValue, oldValue);
  }
  if (value !== causalBaseline(path)) throw new Error('Functional equivalence failed: ' + path);
}

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
  if (causalRules[path] && (path !== 'Idevero/Views/CreateView.swift' ||
      snapshots['Idevero/ViewModels/CreateViewModel.swift'] || normalized(after).includes('IDEVERO_CAUSAL'))) {
    causalEquivalent(path, after);
  }
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
