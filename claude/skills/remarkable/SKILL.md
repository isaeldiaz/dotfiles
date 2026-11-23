---
name: remarkable
description: Write a new Markdown document, or rewrite an existing one, so it reads well on the reMarkable 2 after md2rm converts it to EPUB/PDF — narrow tables, short code lines, diagrams readable without zooming, plots readable in grayscale. Use when the user wants a doc "for the reMarkable", "for the tablet", or asks to make a Markdown file reMarkable friendly.
argument-hint: "[FILE.md to transform | topic to write]"
---

# reMarkable-friendly Markdown

`md2rm FILE.md` (in `~/dotfiles/scripts`) writes `FILE.epub` and `FILE.pdf` to
`~/OneDrive/reMarkable`. The PDF page is 157x210 mm with 141 mm of text width.
Content that does not fit is shrunk, wrapped or rotated; the job here is to
write content that does not need that.

## Modes

- **Transform** (argument is an existing `.md`): write `NAME.rm.md` next to it
  and leave the original untouched. Keep every fact; change only the structure.
- **Generate** (argument is a topic): write `NAME.md` in the directory the
  user names (ask if unclear), following the limits below from the start.

## Limits

The check below is the authority; these are the targets that keep it quiet.

| Element | Limit |
|---|---|
| Table | about 4 columns; md2rm sizes columns from each column's longest word, so long identifiers count more than column count |
| Code line | 60 characters |
| Diagram | 800 px wide, about 10 nodes |
| PNG image | printed at the full 141 mm text width; height at most 1.2 x width |
| Diagram label | 3 lines of ~20 characters |

## Fixing what does not fit

Tables:
- Split a wide table into two that share the key column.
- Turn a table of records with long cells into one short section per row:
  a bold name, then a short list of `field: value` lines.
- Move long explanations out of cells into a numbered note under the table.
- Long identifiers or paths in cells: give them a short name defined once
  above the table.

Code:
- Break long expressions at operators, one argument per line.
- Shorten repeated hierarchical prefixes with a note, e.g. "`tx.` is
  `ua_tl_orig_tltl_port_tx.`".

Diagrams:
- Keep every node, edge and label fact. Text that leaves the diagram goes in
  a note under it; never move an edge to a different node.
- Use `flowchart TB` (the page is portrait); `LR` only for 4 nodes or fewer.
- At most one level of `subgraph`. Subgraphs with no edges between them are
  laid out side by side; drop or merge them.
- Split a big diagram into an overview and one diagram per part.
- Still too wide: shorten edge labels, and push nodes down a row with
  invisible links (`A ~~~ B`).
- Automatic layout still does not fit: redraw the diagram in Pikchr, where
  you place every box. Write `X.pikchr` and render `X.png` with the repo's
  diagrams Makefile, or else:
  `pikchr --svg-only X.pikchr | rsvg-convert -z 4 -b white -o X.png`.
  Set label size with `fontscale` (about 1.1 gives 10 pt on a 3.5 in wide
  diagram); `scale` does not change the printed size.
- To check one diagram quickly, put only its block in a scratch `.md` and run
  the check on that.
- For an image linked to a mermaid export (`X.svg` next to `X.mermaid`),
  inline the edited source as a ` ```mermaid ` block instead of linking the
  SVG. md2rm renders it. Leave any mention of the source files in the text.
- Box drawings: use box-drawing characters (`┌─┐`) or tag the block
  ` ```ascii `, and keep them within 60 columns.

## Grayscale

The reMarkable 2 shows 16 levels of gray. Hues of similar lightness (red and
green, blue and orange) print as the same gray, and pale fills vanish.

Plots and images:
- Tell series apart by line style (solid, dashed, dotted), marker shape and a
  label at the end of each line. Hue may stay as a third cue.
- At most four series per panel; split into panels beyond that.
- Lines at least 1.5 pt, text at least 8 pt at the printed size (141 mm wide).
- Heatmaps: one sequential colormap with monotonic lightness (`Greys`,
  `viridis`); write the value in each cell when there are few cells.
- Bars and areas: hatching or distinct gray levels, not hue.
- If the plot's source script is at hand, fix the script and re-render;
  otherwise list the figure for the user as not grayscale-safe.

Mermaid: no meaning carried by fill color alone; use node shape, a label or a
border style (`stroke-dasharray`) instead.

If the plot's script is at hand, audit its palette with the
scientific-visualization skill (`sv` is defined there). Pass every series
color and the axes background as six-digit hex:

```sh
sv python3 /skill/scripts/palette_audit.py --color 2a78d6 --color eb6834 \
  --background fcfcfb --fail-on grayscale
```

A pair marked `review` (lightness difference under 10 CIE L*) can show as
the same gray: give it distinct line styles and markers, or change a color.

Then, for every image, convert and read the result:

```sh
magick IMG.png -colorspace Gray /tmp/IMG_gray.png
```

Every series and every label must still be distinguishable.

## Check

Run the check after writing, fix what it reports, and repeat until it prints
nothing or only items you have decided to keep:

```sh
~/.claude/skills/remarkable/check.sh FILE.md
```

It reports tables md2rm must shrink or rotate, code blocks with lines over 60
characters, drawings over 60 columns, diagrams over 800 px, and images md2rm
could not load. Warnings quote the start of the block or the first header
cells so you can find them. Tell the user about any item left in and why.

Then give the user the command `md2rm FILE.md` to send it to the tablet.
Run it yourself only if they asked for the document to be sent.
