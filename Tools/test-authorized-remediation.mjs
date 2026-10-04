import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { validateChange, digest, BASE, normalized } from './audit-authorized-remediation.mjs';

const read = path => execFileSync('git', ['show', BASE + ':' + path]);
let count = 0;
function simulation(label, path, updated, expectedPass) {
  const original = read(path);
  const snapshots = {};
  if (expectedPass) snapshots[path] = digest(Buffer.from(normalized(updated)));
  let passed = true;
  try { validateChange(path, original, updated, snapshots); } catch { passed = false; }
  assert.equal(passed, expectedPass, label);
  console.log(label + ': observed ' + (passed ? 'PASS' : 'FAIL') + ' / expected ' + (expectedPass ? 'PASS' : 'FAIL'));
  count++;
}
const settingsPath = 'Idevero/Views/SettingsView.swift';
const settings = normalized(read(settingsPath));
simulation('Authorized Settings/Privacy reviewed snapshot', settingsPath,
  settings.replace('Section(language.ui("Privacidad", "Privacy"))', 'Section(language.ui("Política de privacidad", "Privacy policy"))'), true);
const createPath = 'Idevero/Views/CreateView.swift';
const projectPath = 'Idevero.xcodeproj/project.pbxproj';
const project15 = normalized(read(projectPath)).replaceAll('CURRENT_PROJECT_VERSION = 14;', 'CURRENT_PROJECT_VERSION = 15;');
simulation('Authorized build 14 to 15 only', projectPath, project15, true);
const wrongProject = project15.replace('MARKETING_VERSION = 0.2.9;', 'MARKETING_VERSION = 1.0;');
assert.throws(() => validateChange(projectPath, read(projectPath), Buffer.from(wrongProject),
  {[projectPath]: digest(Buffer.from(wrongProject))}), /Only the authorized build/);
console.log('Reviewed seal cannot permit unrelated project change: observed FAIL / expected FAIL');
count++;
const physicalPath = 'Tools/audit-physical-v6.mjs';
const wrongPhysical = normalized(read(physicalPath)).replaceAll('CURRENT_PROJECT_VERSION = 14', 'CURRENT_PROJECT_VERSION = 15').replaceAll('build 14;', 'build 15;') + '\n// unrelated guard change\n';
assert.throws(() => validateChange(physicalPath, read(physicalPath), Buffer.from(wrongPhysical),
  {[physicalPath]: digest(Buffer.from(wrongPhysical))}), /only the build expectation/);
console.log('Reviewed seal cannot alter physical protections: observed FAIL / expected FAIL');
count++;
const create = normalized(read(createPath));
simulation('Authorized save error propagation reviewed snapshot', createPath,
  create.replace('try? PromptRecord.upsert(analysis, in: context)', 'do { _ = try PromptRecord.upsert(analysis, in: context) } catch { /* Save feedback belongs here. */ }'), true);
for (const [label, path] of [
  ['Semantic engine', 'Idevero/Intelligence/LocalDiscoveryEngine.swift'],
  ['Compiler', 'Idevero/Intelligence/SpecializedCompiler.swift'],
  ['Foundation provider', 'Idevero/Intelligence/FoundationModelsProvider.swift'],
  ['PromptRecord schema', 'Idevero/Models/PromptRecord.swift'],
  ['Discovery Control semantics', 'Idevero/Models/DiscoverySemantics.swift'],
  ['Provider selection', 'Idevero/Intelligence/IntelligenceCoordinator.swift'],
  ['Generation concurrency', 'Idevero/ViewModels/CreateViewModel.swift'],
  ['Existing test assertions', 'IdeveroTests/Pre028RedReproductionTests.swift']
]) simulation(label + ' unauthorized mutation', path, Buffer.concat([read(path), Buffer.from('\n// unauthorized mutation\n')]), false);

// A path-only allowlist would incorrectly permit this mixed-file mutation.
// Seal the authorized variant, then mutate an unrelated callback in the same file.
const authorized = create.replace('try? PromptRecord.upsert(analysis, in: context)', 'do { _ = try PromptRecord.upsert(analysis, in: context) } catch { /* Save feedback belongs here. */ }');
const changedFrozenCallback = authorized.replace('await model.setState(state, id: id)', 'await model.setState(.excluded, id: id)');
assert.notEqual(changedFrozenCallback, authorized);
assert.throws(() => validateChange(createPath, Buffer.from(create), Buffer.from(changedFrozenCallback),
  {[createPath]: digest(Buffer.from(authorized))}), /seal mismatch/);
console.log('Frozen Discovery Control callback inside allowed CreateView: observed FAIL / expected FAIL');
count++;
assert.throws(() => validateChange(settingsPath, Buffer.from(settings), null, {}), /Deletion/);
console.log('Delete allowed UI file: observed FAIL / expected FAIL'); count++;
assert.throws(() => validateChange('Idevero/Views/Unexpected.swift', null, Buffer.from('import SwiftUI'), {}), /out-of-scope/);
console.log('Unlisted production addition: observed FAIL / expected FAIL'); count++;
console.log('PASS: ' + count + ' isolation simulations; no production files modified');
