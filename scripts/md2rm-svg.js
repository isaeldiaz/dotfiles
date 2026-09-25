// md2rm-svg: render an SVG with HTML labels (<foreignObject>, e.g. mermaid
// exports) to PDF or PNG with the Chromium that mermaid-cli installs.
// usage: node md2rm-svg.js IN.svg OUT.pdf|OUT.png
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const mmdc = fs.realpathSync(execFileSync('sh', ['-c', 'command -v mmdc']).toString().trim());
const puppeteer = require(require.resolve('puppeteer', { paths: [path.dirname(mmdc)] }));
const [input, output] = process.argv.slice(2);

(async () => {
  const browser = await puppeteer.launch({ headless: 'shell' });
  const page = await browser.newPage();
  await page.goto('file://' + path.resolve(input));
  // Size the SVG to its viewBox so the output has no margins or scaling.
  const { width, height } = await page.evaluate(() => {
    const svg = document.documentElement;
    const box = svg.viewBox.baseVal;
    const w = box && box.width ? box.width : svg.getBBox().width;
    const h = box && box.height ? box.height : svg.getBBox().height;
    svg.setAttribute('width', w);
    svg.setAttribute('height', h);
    svg.style.maxWidth = 'none';
    return { width: Math.ceil(w), height: Math.ceil(h) };
  });
  if (output.endsWith('.pdf')) {
    await page.pdf({ path: output, width: width + 'px', height: height + 'px',
                     printBackground: true, pageRanges: '1' });
  } else {
    // 2808 px wide at most, matching md2rm.lua's cap.
    await page.setViewport({ width, height, deviceScaleFactor: Math.min(4, 2808 / width) });
    await page.screenshot({ path: output, omitBackground: false });
  }
  await browser.close();
})().catch((e) => { console.error(e.message); process.exit(1); });
