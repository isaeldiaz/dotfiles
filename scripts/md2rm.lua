-- Pandoc filter for md2rm: turns images, mermaid blocks and ASCII drawings into
-- grayscale PNGs (EPUB) or vector PDFs (PDF) that fit an A5 page, and sizes
-- table columns so cell text wraps within the page.

-- 2x the rM2 screen width, so zooming in keeps detail.
local max_w = os.getenv('RM_MAX_W') or '2808'
local count = 0

-- Layout warnings, printed once (on the PDF pass) for claude/skills/remarkable.
-- Code wider than this many monospace characters wraps; diagrams wider than
-- this many px have labels under 8 pt at the 141 mm text width.
local code_cols, diagram_px = 60, 800

local function warn(msg)
  if FORMAT == 'latex' then io.stderr:write('md2rm: ' .. msg .. '\n') end
end

local function snippet(text)
  local first = text:match('^%s*([^\n]*)')
  if utf8.len(first) and utf8.len(first) > 30 then
    first = first:sub(1, utf8.offset(first, 31) - 1) .. '...'
  end
  return '"' .. first .. '"'
end

-- Natural width in px from an SVG's viewBox or width, or from a PDF page
-- (points, 0.75 per px).
local function natural_px(data, mime)
  if mime == 'application/pdf' then
    local w = data:match('/MediaBox%s*%[%s*[%d.]+%s+[%d.]+%s+([%d.]+)')
    return w and tonumber(w) / 0.75
  end
  local w = data:match('viewBox="%s*[-%d.]+[%s,]+[-%d.]+[%s,]+([%d.]+)')
    or data:match('<svg[^>]-%swidth="([%d.]+)')
  return w and tonumber(w)
end

local function check_width(what, data, mime)
  local w = natural_px(data, mime)
  if w and w > diagram_px then
    warn(('%s is %d px wide (max %d)'):format(what, math.floor(w), diagram_px))
  end
end

local function add(data, ext, mime)
  count = count + 1
  local name = ('md2rm/%03d.%s'):format(count, ext)
  pandoc.mediabag.insert(name, mime, data)
  return name
end

local function png(data)
  return add(pandoc.pipe('magick', {'-', '-resize', max_w .. 'x>',
    '-colorspace', 'Gray', '-strip', 'png:-'}, data), 'png', 'image/png')
end

-- Pass the file path when there is one, so rsvg-convert resolves images the SVG
-- references relative to itself.
local function from_svg(svg, path)
  -- rsvg-convert cannot draw HTML labels (mermaid exports), so use Chromium.
  if path and svg:find('<foreignObject') then
    local ext = FORMAT == 'latex' and 'pdf' or 'png'
    local data = pandoc.system.with_temporary_directory('md2rm', function(dir)
      local out = dir .. '/out.' .. ext
      pandoc.pipe('node', {pandoc.path.join({pandoc.path.directory(PANDOC_SCRIPT_FILE),
        'md2rm-svg.js'}), path, out}, '')
      local fh = io.open(out, 'rb')
      local d = fh:read('a')
      fh:close()
      return d
    end)
    if ext == 'pdf' then return add(data, 'pdf', 'application/pdf') end
    return png(data)
  end
  local function convert(args)
    if path then table.insert(args, path) end
    return pandoc.pipe('rsvg-convert', args, path and '' or svg)
  end
  if FORMAT == 'latex' then
    return add(convert({'-f', 'pdf'}), 'pdf', 'application/pdf')
  end
  return png(convert({'-z', '4', '-f', 'png', '-b', 'white'}))
end

local function figure(src, attr)
  return pandoc.Para({pandoc.Image({}, src, '', attr)})
end

local function mermaid(code)
  local ok, result = pcall(pandoc.system.with_temporary_directory, 'md2rm', function(dir)
    local input, output = dir .. '/in.mmd', dir .. '/out.' .. (FORMAT == 'latex' and 'pdf' or 'png')
    local fh = io.open(input, 'w')
    fh:write(code)
    fh:close()
    local args = {'-q', '-i', input, '-o', output, '-b', 'white', '-t', 'neutral'}
    if FORMAT == 'latex' then
      -- A wide viewport keeps the natural size; mmdc's default 800 px squeezes wider ones.
      for _, a in ipairs({'--pdfFit', '-w', '4000'}) do table.insert(args, a) end
    else
      for _, a in ipairs({'-w', '1404', '-s', '2'}) do table.insert(args, a) end
    end
    pandoc.pipe('mmdc', args, '')
    fh = io.open(output, 'rb')
    local data = fh:read('a')
    fh:close()
    return data
  end)
  if not ok then
    warn('mermaid block ' .. snippet(code) .. ' left as code: ' .. tostring(result))
    return nil
  end
  if FORMAT == 'latex' then
    check_width('mermaid block ' .. snippet(code), result, 'application/pdf')
    return figure(add(result, 'pdf', 'application/pdf'))
  end
  return figure(png(result))
end

local function is_drawing(block)
  if block.classes:includes('ascii') then return true end
  if #block.classes > 0 then return false end
  return block.text:find('\xE2[\x94\x95]') -- box drawing U+2500-U+257F
end

local function drawing(text)
  local size, lines, cols = 20, {}, 1
  for line in (text .. '\n'):gmatch('(.-)\n') do
    cols = math.max(cols, utf8.len(line) or #line)
    local esc = line:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
    table.insert(lines, ('<text x="%d" y="%g">%s</text>'):format(
      size, size * 1.16 * (#lines + 1) + size / 2, esc))
  end
  -- DejaVu Sans Mono advance width is 0.602 em.
  local svg = ([[<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">
<rect width="100%%" height="100%%" fill="white"/>
<g font-family="DejaVu Sans Mono" font-size="%d" xml:space="preserve">%s</g></svg>]]):format(
    math.ceil(cols * size * 0.602 + 2 * size), math.ceil(size * 1.16 * #lines + 1.5 * size),
    size, table.concat(lines, '\n'))
  -- Scale to the width the text would take at body size (about 60 columns per page).
  if cols > code_cols then
    warn(('drawing %s is %d columns wide (max %d)'):format(snippet(text), cols, code_cols))
  end
  local width = math.min(100, math.ceil(cols / code_cols * 100)) .. '%'
  return figure(from_svg(svg), pandoc.Attr('', {}, {width = width}))
end

-- Page width in characters: body text, \footnotesize text, and \footnotesize
-- on a landscape page (194 mm instead of 141 mm of text width).
local page_chars, small_chars, landscape_chars = 66, 90, 124
-- Longer words (URLs, identifiers) are allowed to break rather than widen a column.
local max_word = 20

local function table_rows(tbl)
  local rows = {}
  for _, r in ipairs(tbl.head.rows) do table.insert(rows, r) end
  for _, body in ipairs(tbl.bodies) do
    for _, r in ipairs(body.head) do table.insert(rows, r) end
    for _, r in ipairs(body.body) do table.insert(rows, r) end
  end
  for _, r in ipairs(tbl.foot.rows) do table.insert(rows, r) end
  return rows
end

-- Size columns from their content: each gets at least its longest word, and the
-- remaining width goes to the columns with the most text.
local function fit_table(tbl)
  local n = #tbl.colspecs
  local min, max = {}, {}
  for i = 1, n do min[i], max[i] = 2, 2 end
  for _, row in ipairs(table_rows(tbl)) do
    local col = 1
    for _, cell in ipairs(row.cells) do
      if cell.col_span == 1 and col <= n then
        local text = pandoc.utils.stringify(cell.contents)
        max[col] = math.max(max[col], (utf8.len(text) or #text) + 1)
        for word in text:gmatch('%S+') do
          min[col] = math.max(min[col], math.min(max_word, utf8.len(word) or #word) + 1)
        end
      end
      col = col + cell.col_span
    end
  end
  local sum_min, sum_max = 0, 0
  for i = 1, n do sum_min, sum_max = sum_min + min[i], sum_max + max[i] end

  -- Use the first layout where every column fits its longest word, with up to
  -- 20% of the width left for long text. Only the last layout shrinks columns
  -- below their longest word.
  local layouts = {{'normal', page_chars}, {'small', small_chars}}
  if FORMAT == 'latex' then table.insert(layouts, {'landscape', landscape_chars}) end
  local layout, budget, reserve
  for _, l in ipairs(layouts) do
    layout, budget = l[1], l[2] - 2 * n
    reserve = math.min(0.2 * budget, sum_max - sum_min)
    if sum_min + reserve <= budget then break end
  end

  local widths = {}
  if sum_max <= budget then
    for i = 1, n do widths[i] = pandoc.ColWidthDefault end
  else
    local extra = math.max(budget - sum_min, reserve)
    local scale = math.min(1, (budget - extra) / sum_min)
    for i = 1, n do
      local share = sum_max > sum_min and (max[i] - min[i]) / (sum_max - sum_min) or 1 / n
      widths[i] = (min[i] * scale + extra * share) / budget
    end
  end
  for i = 1, n do tbl.colspecs[i][2] = widths[i] end
  if widths[1] ~= pandoc.ColWidthDefault then tbl.classes:insert('wrap') end

  if layout == 'normal' then return tbl end
  local head = {}
  for i, cell in ipairs(tbl.head.rows[1] and tbl.head.rows[1].cells or {}) do
    if i > 2 then break end
    table.insert(head, pandoc.utils.stringify(cell.contents))
  end
  warn(('table "%s | ..." (%d columns, %d rows) needs %s'):format(
    table.concat(head, ' | '), n, #table_rows(tbl),
    layout == 'landscape' and 'a landscape page' or 'a smaller font'))
  if layout == 'landscape' then
    return {pandoc.RawBlock('latex', '\\begin{landscape}\\footnotesize'), tbl,
            pandoc.RawBlock('latex', '\\end{landscape}')}
  end
  if FORMAT == 'latex' then
    return {pandoc.RawBlock('latex', '\\begingroup\\footnotesize'), tbl,
            pandoc.RawBlock('latex', '\\endgroup')}
  end
  return pandoc.Div(tbl, pandoc.Attr('', {'small'}))
end

local latex_escape = {
  ['\\'] = '\\textbackslash{}', ['{'] = '\\{', ['}'] = '\\}', ['$'] = '\\$',
  ['&'] = '\\&', ['#'] = '\\#', ['%'] = '\\%', ['_'] = '\\_',
  ['^'] = '\\^{}', ['~'] = '\\textasciitilde{}',
}

-- LaTeX never breaks inside \texttt, so long paths and signal names run off the
-- page. Allow a line break after separators.
local function breakable_code(code)
  if FORMAT ~= 'latex' then return nil end
  local out = code.text:gsub('[\\{}$&#%%_^~]', latex_escape)
    :gsub('([/.,:%-%[(]+)', '%1\\allowbreak{}')
    :gsub('(\\_)', '%1\\allowbreak{}')
  return pandoc.RawInline('latex', '\\texttt{' .. out .. '}')
end

return {
  {
    Pandoc = function(doc)
      local meta = doc.meta
      if not meta.title then
        local first = doc.blocks[1]
        if first and first.t == 'Header' and first.level == 1 then
          meta.title = first.content
          doc.blocks:remove(1)
        else
          local input = PANDOC_STATE.input_files[1] or 'document'
          meta.title = pandoc.path.split_extension(pandoc.path.filename(input))
        end
      end
      return doc
    end,
  },
  {
    CodeBlock = function(block)
      -- Control characters (e.g. ANSI colour codes) break both LaTeX and SVG.
      block.text = block.text:gsub('[%z\1-\8\11-\31]', '')
      if block.classes:includes('mermaid') then return mermaid(block.text) end
      if is_drawing(block) then return drawing(block.text) end
      local longest = 0
      for line in block.text:gmatch('[^\n]+') do
        longest = math.max(longest, utf8.len(line) or #line)
      end
      if longest > code_cols then
        warn(('code block %s has a %d-character line (max %d)'):format(
          snippet(block.text), longest, code_cols))
      end
      return block
    end,
    Table = fit_table,
    Image = function(img)
      local ok, mime, data = pcall(pandoc.mediabag.fetch, img.src)
      if not ok or not data then
        warn('image left as is: ' .. tostring(ok and img.src or mime))
        return nil
      end
      if mime == 'image/svg+xml' then
        check_width('image ' .. img.src, data, mime)
        local path
        for _, dir in ipairs(PANDOC_STATE.resource_path) do
          local p = pandoc.path.join({dir, img.src})
          local fh = io.open(p)
          if fh then fh:close(); path = p; break end
        end
        img.src = from_svg(data, path)
      else
        img.src = png(data)
      end
      img.attributes.width, img.attributes.height = nil, nil
      return img
    end,
  },
  -- After fit_table, which measures the code text.
  {Code = breakable_code},
}
