"""kurashi: Anki follows kurashi's theme, on top of ReColor (modules/home-manager/theming/kurashi.nix).

ReColor keeps the colours it is configured with (the rose-pine values); this add-on does not change that config. It adds
kurashi's stylesheet (rendered by the kurashi theming bridge into ~/.config/kurashi/apps/anki.css) to every webview, after
ReColor's styles. The file's rules are dark-mode only and use !important, so they win while kurashi is on. With no file,
nothing is added.

Webviews opened before the file changed keep the old colours until Anki restarts.
"""

import os

from aqt import gui_hooks

CSS_PATH = os.path.expanduser("~/.config/kurashi/apps/anki.css")


def _inject_kurashi(web_content, context):
    try:
        with open(CSS_PATH, encoding="utf-8") as handle:
            css = handle.read()
    except OSError:
        return
    web_content.head += f"<style id='kurashi'>{css}</style>"


gui_hooks.webview_will_set_content.append(_inject_kurashi)
