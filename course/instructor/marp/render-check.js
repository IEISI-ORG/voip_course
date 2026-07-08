// VoIPSec E4 — Playwright render + readability check for the MARP decks. Opens each rendered HTML
// deck in a headless browser (run under xvfb-run) and asserts (1) it renders MARP slides with no
// page errors, and (2) NO slide's content overflows its page box (feedback1: content must fit each
// page). Usage: node render-check.js [out-dir]   (default ./out)
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const OVERFLOW_TOL = 4; // px slack before a slide is judged to overflow its box

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

    // MARP renders each slide as a <section> (wrapped in <svg data-marpit-svg><foreignObject>).
    const slides = await page.locator('section').count();

    // Per-slide overflow: a section whose content is taller/wider than its own box (scroll vs client)
    // means text/figures spill past the page edge. scrollHeight reflects true content size even when
    // the section clips with overflow:hidden, so this catches clipped-but-overflowing slides too.
    const over = await page.evaluate((tol) => {
      const secs = [...document.querySelectorAll('section')];
      const bad = [];
      secs.forEach((s, i) => {
        const dh = s.scrollHeight - s.clientHeight;
        const dw = s.scrollWidth - s.clientWidth;
        if (dh > tol || dw > tol) bad.push(`#${i + 1}(+${dh > 0 ? dh : 0}h/+${dw > 0 ? dw : 0}w)`);
      });
      return bad;
    }, OVERFLOW_TOL);

    const ok = slides > 0 && errors.length === 0 && over.length === 0;
    const detail = `${slides} slides` +
      (errors.length ? `, ${errors.length} errors` : '') +
      (over.length ? `, ${over.length} overflow: ${over.join(' ')}` : '');
    console.log(`  ${ok ? 'PASS' : 'FAIL'}: ${f}  (${detail})`);
    if (!ok) { fail++; errors.slice(0, 2).forEach(e => console.log('      ! ' + e)); }
    await page.close();
  }
  await browser.close();
  console.log(fail === 0 ? `RENDER CHECK: PASS (${files.length} decks, no overflow)` : `RENDER CHECK: FAIL (${fail}/${files.length})`);
  process.exit(fail === 0 ? 0 : 1);
})().catch(e => { console.log('RENDER CHECK ERROR:', e.message.split('\n')[0]); process.exit(2); });
