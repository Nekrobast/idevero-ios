import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { causalRules, causalExpected, causalEquivalent, validateChange, digest, normalized, CAUSAL_BASE } from './audit-authorized-remediation.mjs';
const policy = JSON.parse(readFileSync('Tools/authorized-remediation-snapshots.json')).snapshots;
const read = p => normalized(execFileSync('git', ['show', CAUSAL_BASE + ':' + p]));
const view = 'Idevero/Views/CreateView.swift', vm = 'Idevero/ViewModels/CreateViewModel.swift', co = 'Idevero/Intelligence/IntelligenceCoordinator.swift';
let count = 0;
function rejects(label, path, oldText, newText, reseal = true) {
  const current = normalized(readFileSync(path));
  assert(current.includes(oldText), 'Missing mutation anchor: ' + label);
  const mutated = current.replace(oldText, newText);
  assert.notEqual(current, mutated);
  const seals = {...policy};
  if (reseal) seals[path] = digest(Buffer.from(mutated));
  assert.throws(() => validateChange(path, Buffer.from(read(path)), Buffer.from(mutated), seals));
  console.log('REJECT PASS: ' + label); count++;
}
for (const path of Object.keys(causalRules)) {
  const current = normalized(readFileSync(path));
  assert.equal(current, causalExpected(path));
  causalEquivalent(path, current);
  validateChange(path, Buffer.from(read(path)), Buffer.from(current), policy);
  console.log('ACCEPT PASS: authorized diagnostic instrumentation ' + path); count++;
}
rejects('timeout', 'IdeveroUITests/PresentationRemediationUITests.swift', 'timeout: 20', 'timeout: 30', false);
rejects('input', 'IdeveroUITests/PresentationRemediationUITests.swift', 'I want an app to manage telescope bookings', 'A different input', false);
rejects('Create condition', view, 'if let analysis = model.analysis', 'if let analysis = model.analysis, !model.isGenerating');
rejects('sequence', vm, 'generationSequence &+= 1', 'generationSequence &+= 2');
rejects('remove guard', vm, 'guard generation == generationSequence, !Task.isCancelled else { return }', '');
rejects('provider order', co, 'if case .ready = await foundation.availability()', 'if case .ready = await local.availability()');
rejects('fallback', co, 'let causalFallbackResult = try await local.analyze(request)', 'let causalFallbackResult = try await foundation.analyze(request)');
rejects('additional await', vm, 'analysis = result', 'await Task.yield(); analysis = result');
rejects('additional Task', view, 'isIdeaFocused = false', 'Task {}; isIdeaFocused = false');
rejects('analysis assignment', vm, 'analysis = result', 'analysis = nil');
rejects('engine', 'Idevero/Intelligence/LocalDiscoveryEngine.swift', 'return analysis', 'return analysis // mutation', false);
rejects('compiler', 'Idevero/Intelligence/SpecializedCompiler.swift', 'import Foundation', 'import Foundation\n// mutation', false);
rejects('Presentation test', 'IdeveroUITests/PresentationRemediationUITests.swift', 'continueAfterFailure = false', 'continueAfterFailure = true', false);
rejects('unapproved production', 'Idevero/Models/PromptRecord.swift', 'import Foundation', 'import Foundation\n// mutation', false);
for (const [temp, provider] of [['causalFoundationResult','foundation'],['causalLocalResult','local'],['causalFallbackResult','local']]) {
  const text = normalized(readFileSync(co));
  assert(text.includes('let ' + temp + ' = try await ' + provider + '.analyze(request)'));
  assert(text.includes('return (' + temp + ', ' + provider + '.name)'));
  causalEquivalent(co, text);
  console.log('ACCEPT E6 PASS: ' + temp); count++;
}
rejects('E6 provider', co, 'let causalFoundationResult = try await foundation.analyze(request)', 'let causalFoundationResult = try await local.analyze(request)');
rejects('E6 request', co, 'foundation.analyze(request)', 'foundation.analyze("different")');
rejects('E6 name', co, 'return (causalFoundationResult, foundation.name)', 'return (causalFoundationResult, local.name)');
rejects('E6 second await', co, 'let causalLocalResult = try await local.analyze(request)', 'let duplicate = try await local.analyze(request); let causalLocalResult = try await local.analyze(request)');
rejects('E6 missing await', co, 'try await local.analyze(request)', 'try local.analyze(request)');
rejects('E6 moved branch', co, 'if case .ready = await foundation.availability()', 'if case .unavailable = await foundation.availability()');
rejects('E6 return tuple', co, 'return (causalLocalResult, local.name)', 'return (causalFoundationResult, local.name)');
rejects('E6 different return', co, 'return (causalLocalResult, local.name)', 'throw CancellationError()');
rejects('E6 catch', co, 'catch is CancellationError { throw CancellationError() }', 'catch is CancellationError { return (try await local.analyze(request), local.name) }');
rejects('E6 fallback order', co, 'let causalFallbackResult = try await local.analyze(request)', 'let causalFallbackResult = try await foundation.analyze(request)');
rejects('E6 Task', co, 'let causalLocalResult = try await local.analyze(request)', 'Task {}; let causalLocalResult = try await local.analyze(request)');
rejects('E6 defer', co, 'let causalLocalResult = try await local.analyze(request)', 'defer {}; let causalLocalResult = try await local.analyze(request)');
rejects('E6 other expression', co, 'self.local = local', 'self.local = LocalExpertProvider()');
console.log('PASS: ' + count + ' causal acceptance/mutation checks; no fixtures rewritten');
