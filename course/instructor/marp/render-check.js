// VoIPSec E4 — Playwright render check for the MARP decks. Opens each rendered HTML deck in a
// headless browser (run under xvfb-run) and asserts it actually renders MARP slides with no
// page errors. Usage: node render-check.js [out-dir]   (default ./out)
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

(async () => {
  const dir = path.resolve(process.argv[2] || 'out');
  const files = fs.readdirSync(dir)
    .filter(f => /^[0-9].*\.html$/.test(f))   // numbered decks only (skip README.html)
    .sort();
  if (!files.length) { console.log('no decks in ' + dir); process.exit(1); }

  const browser = await chromium.launch();
  let fail = 0;
  for (const f of files) {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
    await page.goto('file://' + path.join(dir, f), { waitUntil: 'load' });
    // MARP renders each slide as an <svg data-marpit-svg> (or <section>).
    const slides = await page.locator('svg[data-marpit-svg], section').count();
    const ok = slides > 0 && errors.length === 0;
    console.log(`  ${ok ? 'PASS' : 'FAIL'}: ${f}  (${slides} slides${errors.length ? ', ' + errors.length + ' errors' : ''})`);
    if (!ok) { fail++; errors.slice(0, 2).forEach(e => console.log('      ! ' + e)); }
    await page.close();
  }
  await browser.close();
  console.log(fail === 0 ? `RENDER CHECK: PASS (${files.length} decks)` : `RENDER CHECK: FAIL (${fail}/${files.length})`);
  process.exit(fail === 0 ? 0 : 1);
})().catch(e => { console.log('RENDER CHECK ERROR:', e.message.split('\n')[0]); process.exit(2); });
