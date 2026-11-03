#!/usr/bin/env python3
"""Pull every dialogue line (by line ID) out of a Scenario Spec markdown file.

  python3 tools/scenario/extract_lines.py docs/bible/05_OPENING_SCENARIO.md > data/scenarios/opening_lines.json

Line IDs follow the spec format <SCENE>_<SPK>_<NN> (bible 05 §0). The scenario JSON references
lines by ID, so the bible stays the single source of truth for the words.
"""
import json
import re
import sys

SPEAKERS = {"ASH": "Ashe", "DST": "Dust", "DNA": "Deena", "KSB": "K'saabu", "SHP": "Ship Computer",
            "UNT": "Unity Orbital Control", "SGT": "Sergeant", "MQ": "Mama Quell"}
ID = r"\*\*((?:OP\d|F\d|T\d)_[A-Z]+_\d+)\*\*"


def clean(seg):
    seg = seg.strip()
    seg = re.sub(r"^—\s*[A-Z' ]+?(?=\s*(\*\(|:))", "", seg).strip()   # " — ASHE"
    d = None
    m = re.match(r"^\*\((.*?)\)\*\s*", seg)
    if m:
        d = m.group(1)
        seg = seg[m.end():]
    seg = seg.lstrip(":").strip()
    m = re.match(r"^\*\((.*?)\)\*\s*", seg)            # direction after the colon
    if m and not d:
        d = m.group(1)
        seg = seg[m.end():]
    sub = None
    m = re.search(r"`\((?:subtitle\) \()?(.*?)\)`", seg)
    if m:
        sub = m.group(1)
        seg = seg[:m.start()].strip()
    trail = None
    m = re.search(r'"\s*\*\((.*?)\)\*\s*(.*)$', seg)     # direction mid-line: "..." *(beat)* "..."
    text = seg.strip()
    text = re.sub(r"`\[[^\]]*\]`", "", text).strip()
    text = text.strip().strip('"').replace('" *(', ' *(').replace(')* "', ')* ')
    text = text.replace("*", "")
    text = re.sub(r'"?\s*(Ashe|Dust|Deena|K\'saabu):\s*$', "", text)
    return {"text": text.strip(), "dir": d, "subtitle": sub}


def main(path):
    src = open(path, encoding="utf-8").read()
    out = {}
    for line in src.splitlines():
        hits = list(re.finditer(ID, line))
        for i, h in enumerate(hits):
            end = hits[i + 1].start() if i + 1 < len(hits) else len(line)
            seg = line[h.end():end]
            seg = re.split(r"\s+/\s+(?:[A-Z][a-z']+:)?\s*$|\s+/\s*$", seg)[0]
            seg = re.sub(r"\s*/\s*(Deena|Ashe|Dust|K'saabu):\s*$", "", seg)
            lid = h.group(1)
            if lid in out:
                continue
            spk = SPEAKERS.get(lid.split("_")[1], lid.split("_")[1])
            item = clean(seg)
            item["speaker"] = spk
            out[lid] = {k: v for k, v in item.items() if v}
    json.dump(out, sys.stdout, indent=1, ensure_ascii=False)


if __name__ == "__main__":
    main(sys.argv[1])
