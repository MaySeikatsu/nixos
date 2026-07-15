"""zellij-layout-preview: render a session-layout.kdl as a tree diagram.

Usage: zellij-layout-preview <session-name-or-file>

If the arg is an existing file, reads that. Otherwise treats it as a zellij
session name and looks up:
    ~/.cache/zellij/contract_version_1/session_info/<name>/session-layout.kdl

The output is a compact tree of tabs -> pane splits -> leaf panes with the
pane's name, running command basename, size, and focus marker, so fzf
previews give an at-a-glance impression of the workspace shape instead of
raw KDL config text.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

# --- Tokenizer ---------------------------------------------------------------

# KDL for our purposes is a sequence of these token kinds:
#   quoted strings, single braces { }, and bareword/prop tokens.
# Comments are single-line //; we strip them per-line before tokenizing to
# avoid quoted "//" false positives.
TOKEN_RE = re.compile(
    r'"(?:[^"\\]|\\.)*"'  # quoted string
    r"|[{}]"              # brace
    r"|\n"                # newline (KDL node terminator)
    r'|[^\s{}"]+'         # bareword / prop
)


def strip_comments(src: str) -> str:
    out = []
    for line in src.splitlines():
        in_str = False
        i = 0
        while i < len(line):
            c = line[i]
            if c == '"' and (i == 0 or line[i - 1] != "\\"):
                in_str = not in_str
            elif not in_str and c == "/" and i + 1 < len(line) and line[i + 1] == "/":
                line = line[:i]
                break
            i += 1
        out.append(line)
    return "\n".join(out)


def tokenize(src: str):
    for m in TOKEN_RE.finditer(src):
        yield m.group(0)


# --- Parser (minimal KDL) ----------------------------------------------------

class Node:
    __slots__ = ("name", "args", "props", "children")

    def __init__(self, name: str) -> None:
        self.name = name
        self.args: list[str] = []
        self.props: dict[str, str] = {}
        self.children: list["Node"] = []


def unquote(s: str) -> str:
    if len(s) >= 2 and s[0] == '"' and s[-1] == '"':
        try:
            return s[1:-1].encode("utf-8").decode("unicode_escape")
        except UnicodeDecodeError:
            return s[1:-1]
    return s


def parse_nodes(tokens, end_at_brace: bool = False) -> list[Node]:
    nodes: list[Node] = []
    for tok in tokens:
        if tok == "\n":
            continue
        if tok == "}":
            if end_at_brace:
                return nodes
            continue
        if tok == "{":
            continue
        node = Node(tok)
        for arg_tok in tokens:
            if arg_tok == "\n" or arg_tok == ";":
                break  # end of this node (no children block)
            if arg_tok == "{":
                node.children = parse_nodes(tokens, end_at_brace=True)
                break
            if arg_tok == "}":
                nodes.append(node)
                return nodes
            # `name="zjp"` tokenizes as two: `name=` and `"zjp"`. Recombine.
            if arg_tok.endswith("=") and not arg_tok.startswith('"'):
                key = arg_tok[:-1]
                # Skip newlines between `=` and value (rare but defensive).
                val = ""
                for v in tokens:
                    if v == "\n":
                        continue
                    val = v
                    break
                node.props[key] = unquote(val)
            elif "=" in arg_tok and not arg_tok.startswith('"'):
                k, _, v = arg_tok.partition("=")
                node.props[k] = unquote(v)
            else:
                node.args.append(unquote(arg_tok))
        nodes.append(node)
    return nodes


def parse(src: str) -> list[Node]:
    return parse_nodes(iter(tokenize(strip_comments(src))))


# --- Rendering ---------------------------------------------------------------

def basename_cmd(cmd: str) -> str:
    if not cmd:
        return ""
    return cmd.rsplit("/", 1)[-1]


def is_status_pane(p: Node) -> bool:
    if p.props.get("size") == "1" and any(c.name == "plugin" for c in p.children):
        return True
    return False


def plugin_name(p: Node) -> str:
    for c in p.children:
        if c.name == "plugin":
            loc = c.props.get("location", "")
            leaf = loc.rsplit("/", 1)[-1]
            leaf = leaf[:-5] if leaf.endswith(".wasm") else leaf
            return leaf or "plugin"
    return ""


def render_pane(node: Node, prefix: str, is_last: bool) -> list[str]:
    connector = "└─ " if is_last else "├─ "
    child_prefix = prefix + ("   " if is_last else "│  ")
    kids = [c for c in node.children if c.name == "pane"]
    split = node.props.get("split_direction", "")
    if kids:
        if split:
            axis = "H-split" if split.lower().startswith("h") else "V-split"
        else:
            axis = "group"
        size = node.props.get("size", "")
        label = axis + (f" [{size}]" if size else "")
        lines = [f"{prefix}{connector}{label}"]
        for i, k in enumerate(kids):
            lines.extend(render_pane(k, child_prefix, i == len(kids) - 1))
        return lines
    name = node.props.get("name", "").strip()
    cmd = basename_cmd(node.props.get("command", ""))
    size = node.props.get("size", "")
    focus = node.props.get("focus") == "true"
    if is_status_pane(node):
        pl = plugin_name(node)
        return [f"{prefix}{connector}[status: {pl or '?'}]"]
    parts: list[str] = []
    if name:
        parts.append(name)
    elif not cmd:
        parts.append("(shell)")
    if cmd:
        parts.append(f"— {cmd}")
    if size:
        parts.append(f"[{size}]")
    if focus:
        parts.append("*")
    label = " ".join(p for p in parts if p) or "(pane)"
    return [f"{prefix}{connector}{label}"]


def render_tab(tab: Node, index: int) -> list[str]:
    name = tab.props.get("name", f"#{index + 1}")
    focus = tab.props.get("focus") == "true"
    header = f"Tab {index + 1}: {name}" + ("  *" if focus else "")
    lines = [header]
    top_panes = [c for c in tab.children if c.name == "pane"]
    if not top_panes:
        lines.append("  (empty)")
    else:
        for i, p in enumerate(top_panes):
            lines.extend(render_pane(p, "  ", i == len(top_panes) - 1))
    floats = [c for c in tab.children if c.name == "floating_panes"]
    if floats:
        fps = [c for c in floats[0].children if c.name == "pane"]
        if fps:
            lines.append(f"  (+ {len(fps)} floating)")
    return lines


def find_layout(nodes: list[Node]) -> Node | None:
    for n in nodes:
        if n.name == "layout":
            return n
    return None


def resolve_source(arg: str) -> Path:
    p = Path(arg).expanduser()
    if p.is_file():
        return p
    return (
        Path.home()
        / ".cache/zellij/contract_version_1/session_info"
        / arg
        / "session-layout.kdl"
    )


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: zellij-layout-preview <session-name-or-file>", file=sys.stderr)
        return 1
    path = resolve_source(sys.argv[1])
    if not path.exists() or path.stat().st_size == 0:
        print("(no saved layout)")
        return 0
    try:
        src = path.read_text(encoding="utf-8", errors="replace")
    except OSError as e:
        print(f"(unable to read layout: {e})")
        return 0
    try:
        tree = parse(src)
    except Exception as e:  # noqa: BLE001
        print(f"(parse error: {e})")
        print(src[:400])
        return 0
    layout = find_layout(tree)
    if layout is None:
        print("(no layout block)")
        return 0
    cwd = ""
    for c in layout.children:
        if c.name == "cwd" and c.args:
            cwd = c.args[0]
            break
    tabs = [c for c in layout.children if c.name == "tab"]
    out: list[str] = []
    if cwd:
        out.append(f"cwd: {cwd}")
        out.append("")
    if not tabs:
        out.append("(no tabs)")
    else:
        for i, t in enumerate(tabs):
            if i:
                out.append("")
            out.extend(render_tab(t, i))
    sys.stdout.write("\n".join(out) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
