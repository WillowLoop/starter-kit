"""Pre-commit hook: check that all Settings fields have a matching .env.example entry."""

import re
import sys
from pathlib import Path

IGNORED_FIELDS = {"model_config"}


def main():
    env_keys = set()
    for line in Path("backend/.env.example").read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            env_keys.add(line.split("=", 1)[0])

    config = Path("backend/shared/config.py").read_text()
    field_pattern = re.compile(r"^\s{4}(\w+):\s*(?:str|int|bool|float|list)", re.MULTILINE)
    config_keys = {m.group(1).upper() for m in field_pattern.finditer(config)} - {
        f.upper() for f in IGNORED_FIELDS
    }

    missing = config_keys - env_keys
    if missing:
        print(f"Ontbreekt in .env.example: {', '.join(sorted(missing))}")  # noqa: T201
        print("Voeg placeholder-waarden toe aan backend/.env.example")  # noqa: T201
        sys.exit(1)


if __name__ == "__main__":
    main()
