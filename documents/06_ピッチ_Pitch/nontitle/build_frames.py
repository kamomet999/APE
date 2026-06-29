#!/usr/bin/env python3
"""APEノンタイトル用ピッチ: index.html を 12枚の PNG に書き出す。"""
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.resolve()
SRC = ROOT / "index.html"
FRAMES_DIR = ROOT / "frames"
SLIDES_DIR = ROOT / "slides_split"

CHROME = "/opt/pw-browsers/chromium-1194/chrome-linux/chrome"

def split_slides() -> list[Path]:
    html = SRC.read_text(encoding="utf-8")
    head_match = re.search(r"<head>(.*?)</head>", html, re.S)
    head = head_match.group(1) if head_match else ""
    sections = re.findall(r"<section class=\"slide[^\"]*\".*?</section>", html, re.S)
    SLIDES_DIR.mkdir(parents=True, exist_ok=True)
    paths = []
    for i, sec in enumerate(sections, 1):
        out = SLIDES_DIR / f"slide_{i:02d}.html"
        out.write_text(
            f"""<!doctype html><html lang="ja"><head>{head}
<style>html,body{{background:#000;margin:0;padding:0}}.slide{{margin:0!important}}</style>
</head><body>{sec}</body></html>""",
            encoding="utf-8",
        )
        paths.append(out)
    return paths

def render(paths: list[Path]) -> list[Path]:
    FRAMES_DIR.mkdir(parents=True, exist_ok=True)
    frames = []
    for i, p in enumerate(paths, 1):
        out = FRAMES_DIR / f"frame_{i:02d}.png"
        cmd = [
            CHROME,
            "--headless=new",
            "--no-sandbox",
            "--disable-gpu",
            "--hide-scrollbars",
            "--force-device-scale-factor=1",
            "--window-size=1920,1080",
            f"--screenshot={out}",
            f"file://{p}",
        ]
        print(f"[{i:02d}/{len(paths)}] {p.name} -> {out.name}")
        subprocess.run(cmd, check=True, capture_output=True)
        if not out.exists():
            raise RuntimeError(f"screenshot failed: {out}")
        frames.append(out)
    return frames

if __name__ == "__main__":
    paths = split_slides()
    print(f"split into {len(paths)} slides")
    frames = render(paths)
    print(f"wrote {len(frames)} frames to {FRAMES_DIR}")
