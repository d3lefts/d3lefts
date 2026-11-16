// Browser acceptance test for Commonwealth OS's SYNTHETIC, NONBINDING website preview.
// This tests the presentation and local-only interactions, not election, identity,
// legal verification, consent storage, institutional authority or software security.
import assert from "node:assert/strict";
import { createServer } from "node:http";
import { readFile, mkdir } from "node:fs/promises";
import { extname, join, normalize, resolve, sep } from "node:path";
import { chromium } from "playwright-core";

const root = resolve("docs");
const mime = { ".html":"text/html; charset=utf-8", ".js":"text/javascript; charset=utf-8",
  ".css":"text/css; charset=utf-8", ".svg":"image/svg+xml" };
const server = createServer(async (req, res) => {
  try {
    const path = decodeURIComponent(new URL(req.url, "http://localhost").pathname).replace(/^\/+/, "") || "index.html";
    const file = resolve(join(root, normalize(path)));
    if (file !== root && !file.startsWith(root + sep)) {
      res.writeHead(403).end(); return;
    }
    const content = await readFile(file);
    res.writeHead(200, {"Content-Type": mime[extname(file)] || "application/octet-stream"});
    res.end(content);
  } catch {
    res.writeHead(404).end("Not found");
  }
});
await new Promise(resolveListener => server.listen(0, "127.0.0.1", resolveListener));
const base = "http://127.0.0.1:" + server.address().port + "/";
let browser;
try {
  browser = await chromium.launch({
    headless: true,
    executablePath: process.env.CHROME_BIN || "/usr/bin/chromium",
    args: ["--no-sandbox"]
  });
  await mkdir("browser-artifacts", {recursive:true});
  for (const width of [390, 1280]) {
    const context = await browser.newContext({viewport:{width,height:850}, reducedMotion:"reduce"});
    const page = await context.newPage();
    const errors = [];
    page.on("pageerror", e => errors.push("JS: " + e.message));
    page.on("response", r => {
      if (r.url().startsWith(base) && r.status() >= 400) errors.push("HTTP " + r.status() + ": " + r.url());
    });
    await page.goto(base + "commonwealth-os.html", {waitUntil:"load"});
    assert.equal(await page.locator("h1").count(), 1, "one product hero");
    assert.equal(await page.locator('[role="tab"]').count(), 4, "four demo workspaces");
    assert.equal(await page.locator('[data-cw-panel]').count(), 4, "four panels");
    assert.equal(await page.locator('[data-cw-detail]').count(), 4, "four explanation views");
    assert.equal(await page.locator('a[href="https://github.com/d3lefts/d3lefts/blob/main/projects/commonwealth-os/README.md"]').count() >= 1, true, "real source link");
    assert.equal(await page.locator('[data-cw-tab="chamber"]').getAttribute("aria-selected"), "true");
    assert.equal(await page.locator('[data-cw-panel="chamber"]').isVisible(), true);

    await page.selectOption("#cw-scenario", "stale");
    assert.match(await page.locator("#cw-scenario-verdict").innerText(), /STALE RULE/);
    await page.selectOption("#cw-scenario", "review");
    assert.match(await page.locator("#cw-scenario-verdict").innerText(), /INDETERMINATE/);

    await page.locator('[data-cw-tab="voter"]').click();
    assert.equal(await page.locator('[data-cw-panel="chamber"]').isVisible(), false);
    await page.locator('[data-cw-choice="SUPPORT"]').click();
    assert.match(await page.locator("#cw-choice-summary").innerText(), /SUPPORT/);
    assert.equal(await page.locator('[data-cw-choice="SUPPORT"]').getAttribute("aria-pressed"), "true");
    await page.locator("#cw-reset-choice").click();
    assert.match(await page.locator("#cw-choice-summary").innerText(), /UNKNOWN/);

    await page.locator('[data-cw-tab="passport"]').click();
    await page.locator("#cw-change-source").click();
    assert.match(await page.locator("#cw-source-verdict").innerText(), /RECHECK REQUIRED/);
    await page.locator("#cw-change-source").click();
    assert.match(await page.locator("#cw-source-verdict").innerText(), /MODEL-SUPPORTED/);

    await page.locator('[data-cw-tab="history"]').click();
    await page.selectOption("#cw-history-group", "school");
    assert.match(await page.locator("#cw-history-official").innerText(), /Alex Rivera/);
    assert.match(await page.locator("#cw-history-source").innerText(), /SYNTHETIC_UNVERIFIED/);

    await page.locator('[data-cw-tab="chamber"]').focus();
    await page.keyboard.press("ArrowRight");
    assert.equal(await page.locator('[data-cw-tab="voter"]').getAttribute("aria-selected"), "true", "keyboard tab navigation");

    await page.reload({waitUntil:"load"});
    await page.locator('[data-cw-tab="voter"]').click();
    assert.match(await page.locator("#cw-choice-summary").innerText(), /UNKNOWN/, "simulated preference not persisted");
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    assert.ok(overflow <= 3, "no horizontal overflow at " + width + ": " + overflow);
    await page.screenshot({path:"browser-artifacts/commonwealth-demo-" + width + ".png",fullPage:true});
    assert.deepEqual(errors, [], "no broken local assets or runtime errors");
    await context.close();
    process.stdout.write("Commonwealth fictional demo UI verified at " + width + "px\n");
  }
} finally {
  if (browser) await browser.close();
  await new Promise(resolveClose => server.close(resolveClose));
}
