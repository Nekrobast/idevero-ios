#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
node "$ROOT/Tools/audit-regex-compatibility.mjs"
node "$ROOT/Tools/prexcode-audit.mjs"
