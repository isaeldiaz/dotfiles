| | |
|---|---|
| Upstream | https://github.com/K-Dense-AI/claude-scientific-skills, path skills/scientific-visualization |
| Commit | ec59a29 (`ec59a29a03d5c40f73ab40878df04860bc00e876`; last commit touching the path: `a92663a0`) |
| Reviewed | 2026-11-23: every file read; scripts run in the no-network container. No network or process calls, no hidden content. Notes for bumps: `assets/color_palettes.py` is executed as code (`palette_audit.py`, `style_presets.py`), review it as code; `image_metadata.py --min-dpi 300` rejects a 300 dpi PNG (reads 299.9994) |
| Local changes | `SKILL.md`: `description` narrowed to Matplotlib figures and grayscale checks (local sha256 `1f96b29d8e1e`) |
| | `SKILL.md`: `allowed-tools` line removed (pre-approved Bash, Write, Edit) |
| | `SKILL.md`: "Citing Scientific Agent Skills" section removed (told Claude to cite the vendor's paper and fetch arXiv) |
| | `SKILL.md`: `compatibility` names the container instead of uv |
| | `SKILL.md`, "Pinned snapshot": `uv run --with` block replaced by the `sv` container wrapper; upstream pins kept as one line |
| | `SKILL.md`, "Bundled CLIs": `uv run ... python scripts/X` → `sv python3 /skill/scripts/X` |
| | `references/color_palettes.md:129`: same replacement (local sha256 `12bda524462b`) |
| | `references/matplotlib_examples.md:5-9, 243, 340`: same replacement; PDF check marked as needing pypdf (local sha256 `075222aa71e5`) |
| | `VENDOR.md`: this file (not upstream) |

Hashes below are of the upstream files at ec59a29.

| File | sha256 (12 hex) |
|---|---|
| `assets/color_palettes.py` | 98ee4aa4b9bb |
| `assets/nature.mplstyle` | f37a361cdda8 |
| `assets/presentation.mplstyle` | d0e5a768e596 |
| `assets/publication.mplstyle` | eba3001f3466 |
| `assets/publisher_profiles.json` | 1e1b1b5a4e0e |
| `references/color_palettes.md` | c9b6a596dd1d |
| `references/journal_requirements.md` | f7c4b6660eb7 |
| `references/matplotlib_examples.md` | 74fd5977ce57 |
| `references/publication_guidelines.md` | 5f70c6b22dbb |
| `references/sources.md` | 3ff34759c0fe |
| `scripts/_common.py` | e4eea2c2e5f5 |
| `scripts/export_plan.py` | c20962bf4c62 |
| `scripts/figure_export.py` | fe9c77878da6 |
| `scripts/image_metadata.py` | 45f79cefd99b |
| `scripts/palette_audit.py` | 3a90b3c9a4a3 |
| `scripts/style_presets.py` | 8413cfae7f2c |
| `scripts/style_preview.py` | ca14e714dc2f |
| `SKILL.md` | 8cbde7cdc10d |
