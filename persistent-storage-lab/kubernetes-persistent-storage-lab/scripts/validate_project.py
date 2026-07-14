#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import subprocess
import sys
import yaml

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
yaml_count = 0
solution_count = 0
exercise_blank_files = 0

for path in sorted(ROOT.rglob("*.yaml")):
    yaml_count += 1
    text = path.read_text(encoding="utf-8")
    try:
        documents = list(yaml.safe_load_all(text))
    except yaml.YAMLError as exc:
        errors.append(f"YAML parse failed: {path.relative_to(ROOT)}: {exc}")
        continue

    if not documents or all(document is None for document in documents):
        errors.append(f"Empty YAML file: {path.relative_to(ROOT)}")

    if "solution" in path.parts:
        solution_count += 1
        if "________" in text:
            errors.append(f"Solution still contains a blank: {path.relative_to(ROOT)}")

    if "exercise" in path.parts and "________" in text:
        exercise_blank_files += 1

for path in sorted(ROOT.rglob("*.sh")):
    result = subprocess.run(["bash", "-n", str(path)], capture_output=True, text=True)
    if result.returncode != 0:
        errors.append(f"Shell syntax failed: {path.relative_to(ROOT)}: {result.stderr.strip()}")
    if "solution" in path.parts and "________" in path.read_text(encoding="utf-8"):
        errors.append(f"Solution script still contains a blank: {path.relative_to(ROOT)}")

required_readmes = [ROOT / "README.md"] + sorted((ROOT / "exercises").glob("*/README.md"))
for path in required_readmes:
    if not path.exists():
        errors.append(f"Missing README: {path.relative_to(ROOT)}")

if exercise_blank_files == 0:
    errors.append("No fill-in-the-blank exercise YAML files were detected.")

if errors:
    print("Validation failed:\n")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("Validation passed.")
print(f"YAML files parsed       : {yaml_count}")
print(f"Solution YAML files     : {solution_count}")
print(f"Exercise files w/blanks : {exercise_blank_files}")
print("Shell scripts passed bash -n.")
