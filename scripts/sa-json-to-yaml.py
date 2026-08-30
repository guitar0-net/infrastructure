#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Andrey Kotlyar <guitar0.app@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

"""Convert a Google service-account JSON key into the YAML block the vault wants.

The Play Billing credentials reach Django as a single JSON env var
(GOOGLE_PLAY_SERVICE_ACCOUNT_INFO), which `env.j2` builds by running the vault
variable through `| to_json`. So the vault has to hold the key as a YAML
mapping, and `private_key` — the one multi-line field — has to survive the trip.

Typing that mapping by hand is where it goes wrong: in a single-quoted YAML
scalar the `\\n` sequences stay two literal characters, `to_json` escapes the
backslash, and Django ends up with a PEM whose line breaks are the text "\\n".
Nothing fails until the first purchase verification. A literal block scalar
(`|`) has no escaping rules at all, so this script emits that.

Usage:

    python3 scripts/sa-json-to-yaml.py ~/Downloads/sa.json | pbcopy
    make vault-edit INVENTORY=production    # paste at the top level, save

In vim, `:set paste` before pasting — autoindent turns the block into a
staircase and YAML then reads it as one long line.

Delete the downloaded JSON afterwards; the vault is the only copy that belongs
in this repo's workflow.
"""

import json
import sys

import yaml

VAR = "backend_google_play_service_account_info"


def str_presenter(dumper, data):
    """Emit multi-line strings as literal blocks, leave the rest to PyYAML.

    PyYAML already quotes digit-only strings such as `client_id`, so they come
    back as strings rather than decaying into ints.
    """
    if "\n" in data:
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


def main(argv):
    if len(argv) != 2:
        sys.exit(f"usage: {argv[0]} <service-account.json>")

    with open(argv[1], encoding="utf-8") as fh:
        info = json.load(fh)

    key = info.get("private_key", "")
    if "\n" not in key:
        sys.exit(
            "private_key holds no line breaks — the JSON was probably already "
            "mangled by an editor. Re-download the key from the Google Cloud "
            "console instead of fixing it up here."
        )

    yaml.add_representer(str, str_presenter)
    sys.stdout.write(
        yaml.dump(
            {VAR: info},
            default_flow_style=False,
            sort_keys=False,
            allow_unicode=True,
            # Long values (client_x509_cert_url) must not be folded: a folded
            # plain scalar reads back with the line break turned into a space.
            width=10**9,
        )
    )


if __name__ == "__main__":
    main(sys.argv)
