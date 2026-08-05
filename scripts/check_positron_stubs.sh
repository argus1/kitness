#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "scripts/positron_stub.sh"
  ".vscode/positron.settings.template.json"
  "r/kitnessGpu/examples/positron_stub.R"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required Positron stub file: $file" >&2
    exit 1
  fi
  echo "Found: $file"
done

if [[ ! -x "scripts/positron_stub.sh" ]]; then
  echo "Expected executable stub script: scripts/positron_stub.sh" >&2
  exit 1
fi

echo "Executable: scripts/positron_stub.sh"

echo "Positron stub file validation passed."
