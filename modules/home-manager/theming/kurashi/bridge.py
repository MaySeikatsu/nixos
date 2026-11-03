#!/usr/bin/env python3
"""kurashi theming bridge (modules/home-manager/theming/kurashi.nix).

Writes the app theme files that kurashi does not write itself (helix, neovim, fzf, ...). Every {{token}} in a template
takes kurashi's live token when kurashi sends one, else the value of the Nix palette (palette.nix). With kurashi not
running, every file is rendered from the Nix palette alone, so an app never loses its theme.

  render --registry R --static S --out DIR   build time: the Nix palette alone (the files of the off state)
  once   --registry R --static S [--home H]  one pass into H (default $HOME), for testing
  run    --registry R --static S [--home H]  the session service: follows kurashi's theme

Templates: {{token}}, or {{token|hex}} for the colour without its #. A template that names a token no source has is
left as it was.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

PLACEHOLDER = re.compile(r"\{\{\s*([A-Za-z0-9_.]+)\s*(?:\|\s*([a-z0-9]+)\s*)?\}\}")


def render(text, tokens):
    """The filled text, and the sorted tokens the text names that no source has."""
    unknown = set()

    def fill(match):
        key, filt = match.group(1), match.group(2)
        if key not in tokens:
            unknown.add(key)
            return match.group(0)
        value = str(tokens[key])
        if filt is None:
            return value
        if filt == "hex":
            return value.lstrip("#")
        raise SystemExit(f"kurashi-theme-bridge: unknown filter '{filt}'")

    return PLACEHOLDER.sub(fill, text), sorted(unknown)


def log(message):
    print(f"kurashi-theme-bridge: {message}", file=sys.stderr, flush=True)


def live_tokens(kurashi):
    """kurashi's current theme tokens, or None when kurashi does not answer."""
    try:
        # --count 0: the snapshot, then stop (--count N stops after N patches, so 1 would wait for a change)
        done = subprocess.run(
            [kurashi, "sub", "theme", "--count", "0"],
            capture_output=True,
            text=True,
            timeout=10,
        )
    except (OSError, subprocess.SubprocessError) as error:
        log(f"kurashi not reachable ({error})")
        return None
    for line in done.stdout.splitlines():
        message = json.loads(line)
        if message.get("t") == "snap":
            return message["data"]["tokens"]
    log("kurashi sent no theme snapshot; rendering from the Nix palette")
    return None


def tokens_now(static, kurashi):
    return {**static, **(live_tokens(kurashi) or {})}


def write_file(path, text):
    """Writes text unless the file already holds it. A Home Manager link (the off state) is replaced, not written through."""
    if path.is_symlink():
        path.unlink()
    if path.is_file() and path.read_text() == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".kurashi-tmp")
    tmp.write_text(text)
    os.replace(tmp, path)
    return True


def apply(targets, tokens, home):
    failed = []
    for target in targets:
        text, unknown = render(Path(target["template"]).read_text(), tokens)
        if unknown:
            failed.append(f"{target['name']} ({', '.join(unknown)})")
            continue
        write_file(home / target["out"], text)
    if failed:
        log("left as they were, tokens unknown: " + "; ".join(failed))


def follow(targets, static, home, kurashi):
    """Re-renders on every change kurashi reports; falls back to the Nix palette whenever kurashi is not there."""
    while True:
        try:
            stream = subprocess.Popen(
                [kurashi, "sub", "theme"],
                stdout=subprocess.PIPE,
                text=True,
            )
        except OSError as error:
            log(f"cannot start {kurashi} ({error}); rendering from the Nix palette")
            apply(targets, static, home)
            time.sleep(10)
            continue
        rendered = False
        for _ in stream.stdout:  # the first line is the current theme, each later line a change to it
            apply(targets, tokens_now(static, kurashi), home)
            rendered = True
        stream.wait()
        if not rendered:
            apply(targets, static, home)
        time.sleep(5)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("mode", choices=["render", "once", "run"])
    parser.add_argument("--registry", required=True, help="JSON: {targets: [{name, template, out}]}")
    parser.add_argument("--static", required=True, help="JSON: the Nix palette, token name to value")
    parser.add_argument("--out", help="render: the directory to write, one file per target name")
    parser.add_argument("--home", default=os.environ.get("HOME"), help="the directory the targets' paths are under")
    parser.add_argument("--kurashi", default="kurashi", help="the kurashi CLI")
    args = parser.parse_args()

    targets = json.loads(Path(args.registry).read_text())["targets"]
    static = json.loads(Path(args.static).read_text())

    if args.mode == "render":
        if not args.out:
            parser.error("render needs --out")
        out = Path(args.out)
        out.mkdir(parents=True, exist_ok=True)
        for target in targets:
            text, unknown = render(Path(target["template"]).read_text(), static)
            if unknown:
                raise SystemExit(
                    f"kurashi-theme-bridge: {target['name']} names tokens the Nix palette lacks: {', '.join(unknown)}"
                )
            (out / target["name"]).write_text(text)
        return

    if not args.home:
        parser.error("needs --home (or HOME)")
    home = Path(args.home)
    if args.mode == "once":
        apply(targets, tokens_now(static, args.kurashi), home)
    else:
        follow(targets, static, home, args.kurashi)


if __name__ == "__main__":
    main()
