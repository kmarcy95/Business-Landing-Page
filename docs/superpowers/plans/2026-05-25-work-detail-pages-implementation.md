# Selected Work Detail Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build six static-HTML detail pages under `/work/<slug>.html` so every card in the `#work` bento on `index.html` navigates to a dedicated walkthrough page with hero + 3 screenshot/caption rows. Remove all direct-app links from cards.

**Architecture:** One handwritten HTML file per project. Shared styles extracted from `index.html` into `assets/site.css` so all 7 pages load one stylesheet. Detail pages reuse the existing `<nav>`, `<footer>`, `<div class="sticky-cta">`, and `<script>` blocks from `index.html` (with relative paths rewritten to `../`). Screenshots captured via headless Chrome (and Playwright for tab-switching), converted to WebP via the `sharp` install in `C:\tmp`. Per-project assets live under `images/work/<slug>/`. No build step; no JS framework.

**Tech Stack:** Vanilla HTML/CSS, Chrome headless (already installed at `C:\Program Files\Google\Chrome\Application\chrome.exe`), Playwright (already installed in `C:\tmp\node_modules`), sharp (already installed in `C:\tmp\node_modules`), netlify-cli (linked to site `keystonemarcy`).

**Spec:** `docs/superpowers/specs/2026-05-25-work-detail-pages-design.md`

**Execution ordering (important for subagent dispatch):**
- Tasks 1 → 2 are sequential (Task 2 appends to the file Task 1 creates).
- Task 3 → 4 → 5 → 6 are sequential (Task 6 is a user checkpoint).
- **Phase 3 tasks (7-15) are gated on Task 6 approval.** Inside Phase 3, capture tasks (7, 9, 11, 13) are independent and can run in parallel. Each build-page task (8, 10, 12, 14, 15) depends on its own capture task AND on Task 4 (template source).
- Phase 4 tasks (16-18) are sequential and run last.

---

## Prerequisites

Three pending uncommitted changes from the prior Aurora+Agentic OS work sit in the working tree:

```
 M images/proj-agent.webp
 M index.html
?? images/proj-aurora.webp
```

Before starting Task 1, commit them so this plan's changes don't co-mingle with unrelated edits. If the user prefers to keep them pending, they can be excluded — but every subsequent commit must use `git add <specific-files>` rather than `git add -A`.

Recommended pre-flight commit (run from `C:\Users\keyst\Business-Landing-Page`):

```bash
git add index.html images/proj-agent.webp images/proj-aurora.webp
git commit -m "$(cat <<'EOF'
Add Aurora work card and refresh Agentic OS card with real screenshot

- New Aurora card (wide, dark mission-control screenshot, demo data)
- Agentic OS Dashboard renamed from "Agent Dashboard"; replaces designed
  mock with a real Slate-themed agent-roster capture
- ML demoted from full-width banner to wide so the bottom row balances
- D365 demoted from flagship 2x2 to wide so all 6 cards share a uniform
  3-row x 2-col grid with no dead space

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: working tree clean (`git status --short` returns nothing).

---

## Phase 1 — Foundation (CSS extract)

### Task 1: Extract `<style>` block from `index.html` into `assets/site.css`

**Why:** The 6 detail pages would otherwise duplicate ~1,000 lines of CSS per file. Extracting once means future style edits hit one file.

**Files:**
- Create: `assets/site.css`
- Modify: `index.html` (replace inline `<style>...</style>` block at lines 61-1133 with a `<link>` element)

- [ ] **Step 1: Create the `assets/` directory**

```bash
mkdir -p assets
```

- [ ] **Step 2: Read the `<style>` block boundaries in `index.html`**

Use Grep to confirm: `<style>` opens at line 61, `</style>` closes at line 1133. If these lines have shifted since this plan was written, use the actual line numbers.

- [ ] **Step 3: Extract the inline CSS content (lines 62-1132, between the tags) into `assets/site.css`**

The simplest reliable extract: read the file, slice the inner content, write to `assets/site.css`. Approximate one-liner via Node from `C:\Users\keyst\Business-Landing-Page`:

```bash
node -e "
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');
const m = html.match(/<style>([\s\S]*?)<\/style>/);
if (!m) { console.error('no <style> block found'); process.exit(1); }
fs.writeFileSync('assets/site.css', m[1].trim() + '\n');
console.log('wrote assets/site.css:', m[1].length, 'chars');
"
```

Expected: prints `wrote assets/site.css: ~52000 chars` (give or take).

- [ ] **Step 4: Replace the inline block in `index.html` with a `<link>` element**

Use the Edit tool. Replace the full `<style>...</style>` block (61-1133) with a single line. The exact replacement keeps preceding whitespace consistent:

`old_string` = lines 61 through 1133 (entire `<style>...</style>` block — use Read first to see exact content).

`new_string` =

```html
  <link rel="stylesheet" href="assets/site.css" />
```

- [ ] **Step 5: Verify visually that the landing page still renders identically**

Run the existing verification script:

```bash
cd /c/tmp && node verify-work.js
```

Then Read `C:\tmp\work-section.png` and confirm the work-section bento renders the same as before (6 wide cards in 3 rows, no broken styles, correct dark theme).

Also do a full-page render check:

```bash
cat > /c/tmp/verify-full.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  let browser;
  try { browser = await chromium.launch({ channel: 'chrome' }); }
  catch (e) { browser = await chromium.launch(); }
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.goto('file:///C:/Users/keyst/Business-Landing-Page/index.html', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: 'C:/tmp/site-full.png', fullPage: true });
  console.log('captured full page');
  await browser.close();
})();
EOF
node /c/tmp/verify-full.js
```

Read `C:\tmp\site-full.png` and confirm hero, work bento, services, about, footer all render correctly with no missing styles.

- [ ] **Step 6: Commit**

```bash
git add assets/site.css index.html
git commit -m "$(cat <<'EOF'
Extract index.html inline CSS to assets/site.css

Mechanical refactor with no visual change. Detail pages under /work/
will reuse the same stylesheet.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Add detail-page CSS classes to `assets/site.css`

**Why:** Detail pages need a handful of new classes for the layout (back-link button, page header, hero, walkthrough rows, tags block). Adding them now means all subsequent page-build tasks can just use the classes.

**Files:**
- Modify: `assets/site.css` (append)

- [ ] **Step 1: Append the detail-page block to `assets/site.css`**

Use the Edit tool. Find the end of `assets/site.css` (last non-empty line). Append:

```css

/* ===== Detail pages (under /work/) ===== */
.back-link { margin: 1.25rem 0 1rem; }
.back-link a {
  display: inline-flex; align-items: center; gap: .35rem;
  padding: .4rem .85rem;
  border: 1px solid var(--border); border-radius: 980px;
  color: var(--text-dim); font-size: .9rem; font-weight: 500;
  transition: color .2s, border-color .2s, background .2s;
}
.back-link a:hover { color: var(--text); border-color: var(--accent-1); background: var(--surface-2); }

.detail-head { margin: 1.5rem 0 1.25rem; max-width: 70ch; }
.detail-title {
  font-family: var(--font-display);
  font-size: clamp(2rem, 4.4vw, 3rem);
  line-height: 1.08;
  margin: .25rem 0 .5rem;
}
.detail-subtitle { color: var(--text-dim); font-size: 1.05rem; line-height: 1.55; margin: 0; max-width: 60ch; }

.detail-hero { margin: 1.5rem 0 2.5rem; }
.detail-hero .card-image { height: auto; max-height: 540px; width: 100%; object-fit: cover; }

.detail-intro { max-width: 70ch; margin: 2.5rem 0 1.25rem; }
.detail-intro h2 { font-family: var(--font-display); font-size: 1.5rem; margin: 0 0 .5rem; }
.detail-intro p { color: var(--text-dim); font-size: 1.05rem; line-height: 1.65; margin: 0; }

.walkthrough { display: flex; flex-direction: column; gap: 3rem; margin: 2.5rem 0 3.5rem; }
.wt-row {
  display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; align-items: center;
}
.wt-row.flip { direction: rtl; }
.wt-row.flip > * { direction: ltr; }
.wt-row .shot { margin: 0; }
.wt-row .card-image { height: auto; max-height: 360px; width: 100%; object-fit: cover; }
.wt-caption h3 { font-family: var(--font-display); font-size: 1.25rem; margin: 0 0 .5rem; }
.wt-caption p { color: var(--text-dim); font-size: 1rem; line-height: 1.65; margin: 0; }

.detail-tags { margin: 2.5rem 0 4rem; }
.detail-tags .tag-row { margin-top: .5rem; }

@media (max-width: 760px) {
  .wt-row, .wt-row.flip { grid-template-columns: 1fr; direction: ltr; gap: 1rem; }
}
```

- [ ] **Step 2: Confirm no syntax errors via a sanity check**

```bash
node -e "console.log('CSS bytes:', require('fs').statSync('assets/site.css').size)"
```

Expected: a number that's ~1,500 bytes larger than before the append.

- [ ] **Step 3: Commit**

```bash
git add assets/site.css
git commit -m "$(cat <<'EOF'
Add detail-page CSS classes (back-link, detail-head, walkthrough, etc.)

Used by the upcoming /work/<slug>.html pages. Single-column on mobile,
alternating left/right rows on desktop via .wt-row.flip.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 2 — D365 detail page as proof-of-concept (user checkpoint)

### Task 3: Capture D365 detail-page screenshots

**Why:** The D365 detail page needs 4 screenshots (1 hero + 3 walkthrough). Capture them all up front so Task 4 has the assets it needs.

**Files:**
- Create: `images/work/d365/hero.webp`, `images/work/d365/wt-1.webp`, `images/work/d365/wt-2.webp`, `images/work/d365/wt-3.webp`

- [ ] **Step 1: Create the images folder**

```bash
mkdir -p images/work/d365
```

- [ ] **Step 2: Start the D365 Blazor app in the background**

```bash
cd /c/Users/keyst/D365ERPManager.Web
ASPNETCORE_URLS=http://localhost:5080 ASPNETCORE_ENVIRONMENT=Development dotnet run
```

Run this with `run_in_background: true`. Then poll until it responds (the `Failed to determine the https port` warning is benign in HTTP-only dev — ignore it):

```bash
for i in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:5080/ 2>/dev/null)
  if [ "$code" = "200" ]; then echo "up after ~${i}s"; break; fi
  sleep 1
done
```

Expected: `up after ~Ns` for some N ≤ 20.

- [ ] **Step 3: Write a Playwright capture script for D365**

```bash
cat > /c/tmp/capture-d365.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  let browser;
  try { browser = await chromium.launch({ channel: 'chrome' }); }
  catch (e) { browser = await chromium.launch(); }
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  const shots = [
    { path: '/roadmap',   out: 'd365-hero.png' },
    { path: '/risks',     out: 'd365-wt-1.png' },
    { path: '/milestones', out: 'd365-wt-2.png' },
    { path: '/reports',   out: 'd365-wt-3.png' },
  ];
  for (const s of shots) {
    try {
      await page.goto('http://localhost:5080' + s.path, { waitUntil: 'networkidle' });
      await page.waitForTimeout(1500);
      await page.screenshot({ path: 'C:/tmp/' + s.out });
      console.log('captured', s.path);
    } catch (e) {
      console.error('FAILED', s.path, e.message);
    }
  }
  await browser.close();
})();
EOF
cd /c/tmp && node capture-d365.js
```

Expected: `captured /roadmap`, `captured /risks`, etc. Four PNG files in `C:\tmp\d365-*.png`.

If any of those routes don't exist (CLAUDE.md confirms `/roadmap` and Reports exist, but `/risks` and `/milestones` may be named differently — verify via the app's nav), adjust the path and re-run. The four target captures are: a Roadmap view, a risk/issue heatmap, the Milestones tab, and an AI-drafted Status Report.

- [ ] **Step 4: Visually verify each shot**

Read each `C:\tmp\d365-*.png` and confirm it shows the expected D365 view with data rendered (not a loading state, not an empty page, not an error).

- [ ] **Step 5: Convert all four to WebP**

```bash
cd /c/tmp && node -e "
const sharp = require('sharp');
const shots = [
  ['d365-hero.png', 'hero.webp'],
  ['d365-wt-1.png', 'wt-1.webp'],
  ['d365-wt-2.png', 'wt-2.webp'],
  ['d365-wt-3.png', 'wt-3.webp'],
];
Promise.all(shots.map(([src, dst]) =>
  sharp('C:/tmp/' + src).webp({ quality: 82 }).toFile('C:/Users/keyst/Business-Landing-Page/images/work/d365/' + dst).then(i => console.log(dst, i.size, 'bytes'))
)).catch(e => { console.error(e); process.exit(1); });
"
```

Expected: four lines `hero.webp NNNNN bytes`, `wt-1.webp NNNNN bytes`, etc. Each in the 30-100 KB range.

- [ ] **Step 6: Stop the D365 server**

```powershell
$p = (Get-NetTCPConnection -LocalPort 5080 -State Listen -ErrorAction SilentlyContinue).OwningProcess
if ($p) { Stop-Process -Id $p -Force }
```

- [ ] **Step 7: Commit the assets**

```bash
git add images/work/d365/
git commit -m "$(cat <<'EOF'
Add D365 ERP Manager Web detail-page screenshots

Hero + 3 walkthrough captures (Roadmap, Risks/Issues, Milestones,
Reports). Captured from the live Blazor app at localhost:5080 via
Playwright, converted to WebP at quality 82.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Build `work/d365.html` (canonical template — referenced by Tasks 8/10/12/14/15)

**Why:** This is the proof-of-concept. The exact HTML structure here is the template every other detail page will copy. Get this right and the rest are mechanical.

**Files:**
- Create: `work/d365.html`

- [ ] **Step 1: Create the `work/` directory**

```bash
mkdir -p work
```

- [ ] **Step 2: Read the `<nav>`, `<footer>`, `<div class="sticky-cta">`, and `<script>` blocks from `index.html`**

Their current line ranges (confirm with Grep — they may shift):
- `<nav class="container nav-inner" aria-label="Primary">` opens line 1166, closes `</nav>` at 1184
- `<footer class="footer">` opens 1724, closes 1740
- `<div class="sticky-cta" id="stickyCta">` opens 1742, closes 1748
- The `<script>` block opens 1750, closes before `</body>` at 1908

You'll paste these verbatim into `work/d365.html` with two adjustments:
- Every `href="#anchor"` becomes `href="../#anchor"` (going up one directory to land on `index.html`)
- Every `href="Keystone-Marcy-Resume.pdf"` becomes `href="../Keystone-Marcy-Resume.pdf"`
- Every `href="images/..."` (if any in nav/footer) becomes `href="../images/..."`
- Add `id="top"` to the `<header class="detail-head">` element so the sticky-CTA JS's "pastHero" gating works on detail pages too.

- [ ] **Step 3: Write `work/d365.html`**

Use the Write tool with the following content. The placeholder comments `<!-- COPY: ... -->` indicate where to paste the exact blocks from `index.html`. Replace each comment with the actual block content (with path adjustments noted above).

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <meta name="theme-color" content="#202024" />
  <meta name="description" content="D365 ERP Manager Web — a Blazor companion to the WPF desktop app that auto-drafts D365 F&O implementation roadmaps, risk logs, milestones, and AI-generated status reports." />
  <link rel="canonical" href="https://keystonemarcy.pages.dev/work/d365.html" />
  <meta name="author" content="Keystone Marcy" />

  <meta property="og:type" content="article" />
  <meta property="og:title" content="D365 ERP Manager Web — Keystone Marcy" />
  <meta property="og:description" content="A Blazor companion to the WPF app that auto-drafts D365 F&O implementation roadmaps, risk logs, milestones, and AI-generated status reports." />
  <meta property="og:image" content="https://keystonemarcy.pages.dev/images/work/d365/hero.webp" />
  <meta property="og:url" content="https://keystonemarcy.pages.dev/work/d365.html" />

  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="D365 ERP Manager Web — Keystone Marcy" />
  <meta name="twitter:description" content="A Blazor companion to the WPF app that auto-drafts D365 F&O implementation roadmaps, risk logs, milestones, and AI-generated status reports." />
  <meta name="twitter:image" content="https://keystonemarcy.pages.dev/images/work/d365/hero.webp" />

  <title>D365 ERP Manager Web — Keystone Marcy</title>

  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0' y1='0' x2='1' y2='1'%3E%3Cstop offset='0' stop-color='%231e40af'/%3E%3Cstop offset='1' stop-color='%231e3a8a'/%3E%3C/linearGradient%3E%3C/defs%3E%3Ccircle cx='32' cy='32' r='28' fill='url(%23g)'/%3E%3C/svg%3E" />

  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

  <link rel="stylesheet" href="../assets/site.css" />
</head>
<body>
  <!-- COPY: <nav>...</nav> from index.html lines 1166-1184, with all href="#X" changed to href="../#X" -->

  <main class="container">
    <p class="back-link"><a href="../#work" data-cta="detail_back">&larr; Back to work</a></p>

    <header class="detail-head" id="top">
      <p class="section-eyebrow">D365 / BLAZOR / .NET 8</p>
      <h1 class="detail-title">D365 ERP Manager Web</h1>
      <p class="detail-subtitle">A Blazor companion to the WPF desktop app that auto-drafts D365 F&amp;O implementation roadmaps, risk logs, milestones, and AI-generated status reports.</p>
    </header>

    <figure class="shot detail-hero">
      <div class="shot-bar" aria-hidden="true">
        <span class="shot-dots"><i></i><i></i><i></i></span>
        <span class="shot-url">d365web · roadmap</span>
      </div>
      <img class="card-image" src="../images/work/d365/hero.webp" alt="D365 ERP Manager Web — implementation roadmap with a six-phase Gantt timeline and phase-by-phase progress summary" width="1440" height="900" loading="eager" />
    </figure>

    <section class="detail-intro">
      <h2>Why it exists</h2>
      <p>Every D365 F&amp;O rollout reinvents the same artifacts: project plans, risk registers, milestones, status reports. Finance and ERP teams burn hours rebuilding spreadsheets per engagement. This Blazor app replaces the per-engagement spreadsheet rebuild with reusable tooling &mdash; and uses Claude to auto-draft the documents that finance leaders actually have to produce.</p>
    </section>

    <section class="walkthrough">

      <div class="wt-row">
        <figure class="shot">
          <div class="shot-bar" aria-hidden="true">
            <span class="shot-dots"><i></i><i></i><i></i></span>
            <span class="shot-url">d365web · risks</span>
          </div>
          <img class="card-image" src="../images/work/d365/wt-1.webp" alt="Risk register with severity heatmap and an issue queue showing owner and status per issue" width="1440" height="900" loading="lazy" />
        </figure>
        <div class="wt-caption">
          <h3>Risk and issue tracking</h3>
          <p>What it shows: a heatmap of open risks plus an issue queue with severity, owner, and status. Mirrors the WPF desktop app's risk register so both clients view the same data, and feeds directly into the AI status-report generator.</p>
        </div>
      </div>

      <div class="wt-row flip">
        <figure class="shot">
          <div class="shot-bar" aria-hidden="true">
            <span class="shot-dots"><i></i><i></i><i></i></span>
            <span class="shot-url">d365web · milestones</span>
          </div>
          <img class="card-image" src="../images/work/d365/wt-2.webp" alt="Milestones tab listing implementation milestones with target dates and status" width="1440" height="900" loading="lazy" />
        </figure>
        <div class="wt-caption">
          <h3>Milestones</h3>
          <p>What it shows: the implementation milestones for the current engagement. Each milestone has a target date, owner, and rollup status. The Milestones model was added in v2.3 alongside an AI flow that drafts a roadmap-aware milestone list from the current project state.</p>
        </div>
      </div>

      <div class="wt-row">
        <figure class="shot">
          <div class="shot-bar" aria-hidden="true">
            <span class="shot-dots"><i></i><i></i><i></i></span>
            <span class="shot-url">d365web · reports</span>
          </div>
          <img class="card-image" src="../images/work/d365/wt-3.webp" alt="Status reports panel with an AI-drafted finance-ready status report rendered as markdown" width="1440" height="900" loading="lazy" />
        </figure>
        <div class="wt-caption">
          <h3>AI-drafted status reports</h3>
          <p>What it shows: a finance-ready status report generated from the current roadmap with one click. Powered by Claude Opus 4.7 via a strict JSON schema &mdash; the output is a structured object, not free text, so it renders into the same component every time. Copy or download as markdown.</p>
        </div>
      </div>

    </section>

    <section class="detail-tags">
      <p class="section-eyebrow">Built with</p>
      <div class="tag-row">
        <span class="tag">Blazor</span>
        <span class="tag">C#</span>
        <span class="tag">.NET 8</span>
        <span class="tag">Claude API</span>
      </div>
    </section>
  </main>

  <!-- COPY: <footer>...</footer> from index.html lines 1724-1740, with href="#X" changed to href="../#X" -->

  <!-- COPY: <div class="sticky-cta" id="stickyCta">...</div> from index.html lines 1742-1748,
       with href="Keystone-Marcy-Resume.pdf" -> href="../Keystone-Marcy-Resume.pdf"
       and  href="#contact" -> href="../#contact" -->

  <!-- COPY: <script>...</script> block from index.html lines 1750-1907 verbatim (no path changes) -->
</body>
</html>
```

**Important:** before saving, replace each `<!-- COPY: ... -->` comment with the actual block content from `index.html` (with the path adjustments listed). Do NOT ship the file with `<!-- COPY -->` comments still in it.

- [ ] **Step 4: Open the page locally and confirm it renders**

```bash
cat > /c/tmp/verify-d365.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  let browser;
  try { browser = await chromium.launch({ channel: 'chrome' }); }
  catch (e) { browser = await chromium.launch(); }
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  await page.goto('file:///C:/Users/keyst/Business-Landing-Page/work/d365.html', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);
  await page.screenshot({ path: 'C:/tmp/d365-page.png', fullPage: true });
  console.log('captured');
  await browser.close();
})();
EOF
node /c/tmp/verify-d365.js
```

Read `C:\tmp\d365-page.png` and confirm: nav at top, back-link, header, hero image renders, "Why it exists" prose, three walkthrough rows (image alternates left/right), tech tags, footer at bottom. No broken images, no `<!-- COPY -->` comments visible.

- [ ] **Step 5: Commit**

```bash
git add work/d365.html
git commit -m "$(cat <<'EOF'
Add D365 ERP Manager Web detail page

First detail page; serves as the template structure for the remaining 5.
Section-stacked case study with hero, "Why it exists" prose, three
alternating screenshot/caption rows, and a tech-stack tag block. Reuses
nav, footer, sticky-CTA, and script blocks from index.html with relative
paths adjusted to ../.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Convert the D365 card in `index.html` to link to its detail page

**Why:** Without this, the new detail page exists but no one can reach it from the landing page.

**Files:**
- Modify: `index.html` (the D365 card markup in the `#work` bento)

- [ ] **Step 1: Find the current D365 card**

It currently looks like:

```html
<!-- Card 1: D365 ERP Manager Web (wide 2x1) — display-only -->
<article class="bento-card wide reveal" aria-label="D365 ERP Manager Web" style="transition-delay: 0ms">
```

- [ ] **Step 2: Replace the wrapper with an `<a>` element and update the closing tag**

Use the Edit tool. Two edits required.

**Edit A — opening tag:**

`old_string`:
```html
        <!-- Card 1: D365 ERP Manager Web (wide 2x1) — display-only -->
        <article class="bento-card wide reveal" aria-label="D365 ERP Manager Web" style="transition-delay: 0ms">
```

`new_string`:
```html
        <!-- Card 1: D365 ERP Manager Web (wide 2x1) — detail-page link -->
        <a class="bento-card wide reveal" href="work/d365.html" aria-label="D365 ERP Manager Web — open detail page" style="transition-delay: 0ms" data-cta="work_d365">
```

**Edit B — closing tag:** find the matching `</article>` that closes this card (it's the `</article>` immediately before the comment for Card 2: Codex). Change it to `</a>`.

- [ ] **Step 3: Verify the page still renders and the card is clickable**

Open `index.html` in a browser (or use the verify-work.js script from Task 1) and confirm the D365 card looks the same (same image, title, description, tags) but now navigates on click.

```bash
node /c/tmp/verify-work.js
```

Read `C:\tmp\work-section.png` and confirm the D365 card looks identical to before.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "$(cat <<'EOF'
Link D365 card to /work/d365.html detail page

Card wrapper goes from <article> to <a href="work/d365.html">. No visual
change. First card to use the detail-page pattern.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 6: Deploy POC and pause for user review

**Why:** Get sign-off on the D365 page's look, tone, and content density before producing five more.

**Files:** none (deploy operation)

- [ ] **Step 1: Stash gitignored junk before `--dir .` deploy**

```bash
mkdir -p /c/tmp/blp-deploy-stash/images
mv ruvector.db /c/tmp/blp-deploy-stash/
mv images/ruvector.db /c/tmp/blp-deploy-stash/images/
mv preview-*.html /c/tmp/blp-deploy-stash/
```

- [ ] **Step 2: Push to GitHub (triggers canonical CD) and direct-deploy**

```bash
git push origin main
netlify deploy --prod --dir .
```

Expected: a Production URL of `https://keystonemarcy.pages.dev` and a unique deploy URL.

- [ ] **Step 3: Restore junk to working dir**

```bash
mv /c/tmp/blp-deploy-stash/ruvector.db ./
mv /c/tmp/blp-deploy-stash/images/ruvector.db images/
mv /c/tmp/blp-deploy-stash/preview-*.html ./
rmdir /c/tmp/blp-deploy-stash/images /c/tmp/blp-deploy-stash
```

- [ ] **Step 4: Verify the live detail page**

```bash
curl -s -o /dev/null -w "d365.html -> HTTP %{http_code}\n" https://keystonemarcy.pages.dev/work/d365.html
curl -s -o /dev/null -w "hero.webp -> HTTP %{http_code}\n" https://keystonemarcy.pages.dev/images/work/d365/hero.webp
curl -s -o /dev/null -w "site.css  -> HTTP %{http_code}\n" https://keystonemarcy.pages.dev/assets/site.css
```

Expected: all three HTTP 200.

- [ ] **Step 5: User checkpoint**

Open `https://keystonemarcy.pages.dev/work/d365.html` in the user's browser. **Pause execution and ask the user to review.** Specifically: does the layout feel right? Are the captions in the right voice? Is the depth right? Any visual adjustments needed?

**Only proceed to Phase 3 after the user approves.** Apply any requested changes to `work/d365.html` and redeploy before continuing.

---

## Phase 3 — Build the remaining 5 detail pages

After Phase 2 approval, the template is locked. Tasks 7-15 produce five more pages using the same structure as Task 4.

### Task 7: Capture Agentic OS screenshots (hero + 3 walkthrough)

**Files:**
- Create: `images/work/agentic-os/{hero,wt-1,wt-2,wt-3}.webp`

- [ ] **Step 1: Create the images folder**

```bash
mkdir -p images/work/agentic-os
```

- [ ] **Step 2: Start `dashboard.py` in the background**

```bash
cd /c/Users/keyst/agent-dashboard && python dashboard.py
```

Run with `run_in_background: true`. Poll until port 8765 responds:

```bash
for i in $(seq 1 20); do
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://localhost:8765/ 2>/dev/null)
  if [ "$code" = "200" ]; then echo "up after ~${i}s"; break; fi
  sleep 1
done
```

- [ ] **Step 3: Capture Agents (hero), Systems, Skills, Workflows tabs via Playwright**

Crucial: **skip the Overview tab** — it exposes real personal AI spend. Spec calls this out explicitly.

```bash
cat > /c/tmp/capture-agentos.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  let browser;
  try { browser = await chromium.launch({ channel: 'chrome' }); }
  catch (e) { browser = await chromium.launch(); }
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('http://localhost:8765/', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500);

  const shots = [
    { tab: 'agents',    out: 'ao-hero.png' },
    { tab: 'systems',   out: 'ao-wt-1.png' },
    { tab: 'skills',    out: 'ao-wt-2.png' },
    { tab: 'workflows', out: 'ao-wt-3.png' },
  ];
  for (const s of shots) {
    await page.click('#tabs button[data-tab="' + s.tab + '"]');
    await page.waitForTimeout(1800);
    await page.screenshot({ path: 'C:/tmp/' + s.out });
    console.log('captured', s.tab);
  }
  await browser.close();
})();
EOF
cd /c/tmp && node capture-agentos.js
```

Expected: four `captured X` lines.

- [ ] **Step 4: Verify each shot visually**

Read each `C:\tmp\ao-*.png`. Confirm none of them show dollar figures (no `$NNN` in the visible area). If any shot rendered as the Overview tab or a blank canvas, re-run with the appropriate tab name or pick a different tab.

If the Systems tab is empty (no saved systems), substitute the Memory tab or another populated tab:

```javascript
{ tab: 'memory', out: 'ao-wt-1.png' }
```

Re-run the capture for just that tab.

- [ ] **Step 5: Convert to WebP**

```bash
cd /c/tmp && node -e "
const sharp = require('sharp');
const shots = [
  ['ao-hero.png', 'hero.webp'],
  ['ao-wt-1.png', 'wt-1.webp'],
  ['ao-wt-2.png', 'wt-2.webp'],
  ['ao-wt-3.png', 'wt-3.webp'],
];
Promise.all(shots.map(([src, dst]) =>
  sharp('C:/tmp/' + src).webp({ quality: 82 }).toFile('C:/Users/keyst/Business-Landing-Page/images/work/agentic-os/' + dst).then(i => console.log(dst, i.size, 'bytes'))
)).catch(e => { console.error(e); process.exit(1); });
"
```

- [ ] **Step 6: Stop the dashboard server**

```powershell
$p = (Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue).OwningProcess
if ($p) { Stop-Process -Id $p -Force }
```

- [ ] **Step 7: Commit**

```bash
git add images/work/agentic-os/
git commit -m "$(cat <<'EOF'
Add Agentic OS detail-page screenshots

Hero (Agents tab) + walkthrough (Systems, Skills, Workflows). Captured
from the live dashboard.py at localhost:8765 via Playwright. Overview
tab deliberately skipped to keep real personal AI-spend numbers off the
public site (FP&A brand protection).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 8: Build `work/agentic-os.html`

**Files:**
- Create: `work/agentic-os.html`

- [ ] **Step 1: Copy `work/d365.html` to `work/agentic-os.html`**

```bash
cp work/d365.html work/agentic-os.html
```

- [ ] **Step 2: Apply per-page substitutions**

Use the Edit tool. Substitutions:

| Find | Replace with |
|---|---|
| `D365 ERP Manager Web — Keystone Marcy` (in `<title>` and OG/Twitter title) | `Agentic OS Dashboard — Keystone Marcy` |
| Every `images/work/d365/` | `images/work/agentic-os/` |
| `https://keystonemarcy.pages.dev/work/d365.html` (canonical + og:url) | `https://keystonemarcy.pages.dev/work/agentic-os.html` |
| `name="description" content="D365 ERP Manager Web — a Blazor companion to the WPF desktop app that auto-drafts D365 F&O implementation roadmaps, risk logs, milestones, and AI-generated status reports."` | `name="description" content="Agentic OS Dashboard — a self-built operations console for an AI-driven workflow with single-pane visibility into agents, skills, workflows, and token usage."` |
| OG/Twitter description (same long string above, both occurrences) | Same Agentic OS description |
| `D365 / BLAZOR / .NET 8` (in `.section-eyebrow`) | `PYTHON / AGENT OPS` |
| `<h1 class="detail-title">D365 ERP Manager Web</h1>` | `<h1 class="detail-title">Agentic OS Dashboard</h1>` |
| `<p class="detail-subtitle">A Blazor companion to the WPF desktop app that auto-drafts D365 F&amp;O implementation roadmaps, risk logs, milestones, and AI-generated status reports.</p>` | `<p class="detail-subtitle">A self-built operations console for an AI-driven workflow &mdash; single-pane visibility into agents, skills, workflows, and token usage.</p>` |
| Hero `shot-url` `d365web · roadmap` | `agentic-os · agents` |
| Hero `alt` attribute (long D365 string) | `Agentic OS Dashboard — Slate-themed operations console showing a searchable roster of AI agents with a token-usage meter and quick-launch skills` |
| `<h2>Why it exists</h2>` paragraph (the full prose) | `<p>AI automations sprawl across CLIs, scripts, and a dozen tools &mdash; no single view of what's running, what just ran, what it cost. This zero-dependency Python dashboard reads the local agent state and surfaces every workflow, agent, and skill in one console. It's the dashboard a finance leader would build for their own AI ops if they couldn't buy one.</p>` |
| Walkthrough row 1 `shot-url` `d365web · risks` | `agentic-os · systems` |
| WT1 alt | `Systems tab showing a Drawflow visual builder for composing multi-agent graphs` |
| WT1 `<h3>` `Risk and issue tracking` | `Multi-agent system builder` |
| WT1 caption | `What it shows: a visual DAG editor for composing systems of agents. Drag in prompt, agent, and skill nodes, wire them up, and run the whole graph as one supervised execution.` |
| Walkthrough row 2 `shot-url` `d365web · milestones` | `agentic-os · skills` |
| WT2 alt | `Skills tab showing the installed skills catalog with pin buttons` |
| WT2 `<h3>` `Milestones` | `Skill launcher` |
| WT2 caption | `What it shows: every installed skill from the plugin packs. Pin the ones you use most to the overview for one-click access. Click a skill to pre-fill the console prompt; Shift+click to run it immediately.` |
| Walkthrough row 3 `shot-url` `d365web · reports` | `agentic-os · workflows` |
| WT3 alt | `Workflows tab showing saved workflow cards (Quick code review, Bug debug, Brainstorm a feature) and a workflow editor` |
| WT3 `<h3>` `AI-drafted status reports` | `Reusable workflows` |
| WT3 caption | `What it shows: a library of reusable workflows (code review, bug debug, brainstorm) that bind a prompt template to a model and a permission set. Save a new workflow or send any existing one straight to the console.` |
| `<span class="tag">Blazor</span><span class="tag">C#</span><span class="tag">.NET 8</span><span class="tag">Claude API</span>` (in `.tag-row`) | `<span class="tag">Python</span><span class="tag">http.server</span><span class="tag">Multi-Agent</span>` |
| `data-cta="work_d365"` in back-link (if added) | not applicable on back-link; the back-link itself is fine. Keep `data-cta="detail_back"` |

- [ ] **Step 3: Render-verify the page**

```bash
sed -i 's|d365.html|agentic-os.html|' /c/tmp/verify-d365.js
sed -i 's|d365-page.png|agentic-os-page.png|' /c/tmp/verify-d365.js
node /c/tmp/verify-d365.js
```

Then revert /c/tmp/verify-d365.js to the d365 paths (or write a fresh script). Read `C:\tmp\agentic-os-page.png` and confirm: page renders, all 4 images load, no `D365` text leaked through.

- [ ] **Step 4: Commit**

```bash
git add work/agentic-os.html
git commit -m "$(cat <<'EOF'
Add Agentic OS Dashboard detail page

Same template as work/d365.html. Hero is the Agents roster; walkthrough
covers Systems (multi-agent builder), Skills (launcher), and Workflows.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 9: Capture Aurora screenshots

**Files:**
- Create: `images/work/aurora/{hero,wt-1,wt-2,wt-3}.webp`

- [ ] **Step 1: Create folder**

```bash
mkdir -p images/work/aurora
```

- [ ] **Step 2: Make a theme-forced temp copy of the Aurora source**

```bash
cp "/c/Users/keyst/OneDrive/Documents/Cowork Station/marketing-agency-command-center.html" /c/tmp/aurora-capture.html
sed -i "s/theme:'fluent'/theme:'aurora-dark'/" /c/tmp/aurora-capture.html
grep -c "theme:'aurora-dark'" /c/tmp/aurora-capture.html
```

Expected: `1`.

- [ ] **Step 3: Capture Mission Control (hero) + 3 modal views via Playwright**

Aurora's main panels live as modals opened from `openModal(...)`. Open each, screenshot, close.

```bash
cat > /c/tmp/capture-aurora.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  let browser;
  try { browser = await chromium.launch({ channel: 'chrome' }); }
  catch (e) { browser = await chromium.launch(); }
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('file:///C:/tmp/aurora-capture.html', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500); // wait for boot overlay

  // Hero: Mission Control (default view)
  await page.screenshot({ path: 'C:/tmp/au-hero.png' });
  console.log('captured hero (Mission Control)');

  // wt-1: CRM modal
  await page.evaluate(() => openModal('crm'));
  await page.waitForTimeout(1200);
  await page.screenshot({ path: 'C:/tmp/au-wt-1.png' });
  console.log('captured CRM');
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);

  // wt-2: Pipeline (kanban) modal
  await page.evaluate(() => openModal('kanban'));
  await page.waitForTimeout(1200);
  await page.screenshot({ path: 'C:/tmp/au-wt-2.png' });
  console.log('captured Pipeline');
  await page.keyboard.press('Escape');
  await page.waitForTimeout(500);

  // wt-3: Campaigns modal
  await page.evaluate(() => openModal('campaigns'));
  await page.waitForTimeout(1200);
  await page.screenshot({ path: 'C:/tmp/au-wt-3.png' });
  console.log('captured Campaigns');

  await browser.close();
})();
EOF
cd /c/tmp && node capture-aurora.js
```

Expected: 4 `captured X` lines.

- [ ] **Step 4: Verify shots visually**

Read each `C:\tmp\au-*.png`. Confirm dark aurora theme, no boot overlay still showing, modal content rendered. If a modal didn't open (`openModal` may have a different name in some versions), substitute the agentRoster, abtests, or scheduleManager modal — pick whichever opens with content.

- [ ] **Step 5: Convert to WebP**

```bash
cd /c/tmp && node -e "
const sharp = require('sharp');
const shots = [
  ['au-hero.png', 'hero.webp'],
  ['au-wt-1.png', 'wt-1.webp'],
  ['au-wt-2.png', 'wt-2.webp'],
  ['au-wt-3.png', 'wt-3.webp'],
];
Promise.all(shots.map(([src, dst]) =>
  sharp('C:/tmp/' + src).webp({ quality: 82 }).toFile('C:/Users/keyst/Business-Landing-Page/images/work/aurora/' + dst).then(i => console.log(dst, i.size, 'bytes'))
)).catch(e => { console.error(e); process.exit(1); });
"
```

- [ ] **Step 6: Commit**

```bash
git add images/work/aurora/
git commit -m "$(cat <<'EOF'
Add Aurora detail-page screenshots (aurora-dark theme)

Hero is Mission Control; walkthrough covers the CRM, Pipeline (kanban),
and Campaigns modals. Captured from a theme-forced temp copy in C:/tmp;
user's source file in OneDrive is unchanged.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 10: Build `work/aurora.html`

**Files:**
- Create: `work/aurora.html`

- [ ] **Step 1: Copy `work/d365.html` to `work/aurora.html`**

```bash
cp work/d365.html work/aurora.html
```

- [ ] **Step 2: Apply per-page substitutions**

| Find | Replace with |
|---|---|
| `D365 ERP Manager Web — Keystone Marcy` (title + OG/Twitter title) | `Aurora — Marketing Agency — Keystone Marcy` |
| Every `images/work/d365/` | `images/work/aurora/` |
| Canonical + og:url `work/d365.html` | `work/aurora.html` |
| Meta description / OG description / Twitter description | `Aurora — a self-driving marketing agency: autonomous agents that plan campaigns, work a recruiter CRM, and track engagement, all from one Mission Control.` |
| Eyebrow `D365 / BLAZOR / .NET 8` | `VANILLA JS / MULTI-AGENT` |
| H1 `D365 ERP Manager Web` | `Aurora — Marketing Agency` |
| Subtitle | `A self-driving marketing agency: autonomous agents that plan campaigns, work a recruiter CRM, and track engagement, all from one Mission Control.` |
| Hero `shot-url` `d365web · roadmap` | `aurora · mission control` |
| Hero alt | `Aurora autonomous marketing agency dashboard — dark mission control with campaign KPIs, a recruiter CRM pipeline kanban, live page visits, system health, and a live agent activity feed` |
| Why-it-exists paragraph | `Personal-brand marketing means juggling content, outreach, CRM, and analytics by hand. Aurora runs a roster of autonomous agents &mdash; strategist, content, publisher, outreach, engagement, analytics &mdash; that take a brand goal and run the marketing motions for it: planning posts, working a recruiter CRM, sending personalized outreach, watching for replies. The whole thing lives in one single-file HTML dashboard with six themes and full localStorage persistence.` |
| WT1 shot-url | `aurora · crm` |
| WT1 alt | `CRM modal showing recruiter contacts grouped by pipeline stage` |
| WT1 h3 | `Recruiter CRM` |
| WT1 caption | `What it shows: every recruiter contact tagged with stage (cold, engaged, conversation, offer) and the agent currently working it. The outreach agent sources contacts; the engagement agent tracks replies; the analytics agent reports conversion at each step.` |
| WT2 shot-url | `aurora · pipeline` |
| WT2 alt | `Pipeline kanban with content cards across draft / scheduled / published columns` |
| WT2 h3 | `Content pipeline` |
| WT2 caption | `What it shows: kanban view of the content pipeline. Draft posts move through scheduling and publishing as agents pick them up. The strategist sets the cadence; the content agent drafts; the publisher pushes to the right channel at the right time.` |
| WT3 shot-url | `aurora · campaigns` |
| WT3 alt | `Campaigns modal listing active marketing campaigns with status, channel, and KPIs` |
| WT3 h3 | `Campaigns` |
| WT3 caption | `What it shows: active campaigns, each with a goal, channel mix, and live KPIs. Status pills indicate which agents are running, paused, or waiting on input. Pause a campaign and every assigned agent stops automatically.` |
| Tag row | `<span class="tag">HTML</span><span class="tag">JS</span><span class="tag">Multi-Agent</span>` |

- [ ] **Step 3: Render-verify, then commit**

Use a similar Playwright capture as before (file URL `work/aurora.html`). Read the screenshot, confirm correctness.

```bash
git add work/aurora.html
git commit -m "$(cat <<'EOF'
Add Aurora — Marketing Agency detail page

Same template as work/d365.html. Hero is Mission Control; walkthrough
covers the recruiter CRM, content pipeline, and campaigns views.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 11: Capture Creator Dashboard screenshots

**Files:**
- Create: `images/work/creator/{hero,wt-1,wt-2,wt-3}.webp`

- [ ] **Step 1: Create folder**

```bash
mkdir -p images/work/creator
```

- [ ] **Step 2: Capture the 4 tabs via Playwright**

The Creator Dashboard is at `C:\Users\keyst\creator-dashboard.html`. Tabs (per CLAUDE.md): Home, Sessions, Insights, Goals, Calendar, Promo, Landing, Overlay, Settings. We'll capture Home, Sessions, Insights, Goals.

Tab switching mechanism: inspect the file with Grep first to find whether tabs use `[data-tab]`, `onclick`, or hashchange. Then write the capture script:

```bash
cat > /c/tmp/capture-creator.js <<'EOF'
const { chromium } = require('playwright');
(async () => {
  let browser;
  try { browser = await chromium.launch({ channel: 'chrome' }); }
  catch (e) { browser = await chromium.launch(); }
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('file:///C:/Users/keyst/creator-dashboard.html', { waitUntil: 'networkidle' });
  await page.waitForTimeout(1500);

  // Hero: Home tab (default)
  await page.screenshot({ path: 'C:/tmp/cr-hero.png' });
  console.log('captured Home');

  // Adjust the click selector based on what's in the file. Examples:
  //   await page.click('[data-tab="sessions"]');  OR
  //   await page.click('text=Sessions');
  for (const [tab, out] of [['Sessions', 'cr-wt-1.png'], ['Insights', 'cr-wt-2.png'], ['Goals', 'cr-wt-3.png']]) {
    try {
      await page.click('text=' + tab);
      await page.waitForTimeout(1000);
      await page.screenshot({ path: 'C:/tmp/' + out });
      console.log('captured', tab);
    } catch (e) {
      console.error('FAILED', tab, e.message);
    }
  }
  await browser.close();
})();
EOF
cd /c/tmp && node capture-creator.js
```

If the `text=` selector fails for any tab, Read the creator-dashboard.html file to find the actual tab selector (could be a `<button>` with text, an `<a href="#sessions">`, etc.) and adjust.

- [ ] **Step 3: Verify visually, convert to WebP, commit**

```bash
cd /c/tmp && node -e "
const sharp = require('sharp');
const shots = [['cr-hero.png','hero.webp'],['cr-wt-1.png','wt-1.webp'],['cr-wt-2.png','wt-2.webp'],['cr-wt-3.png','wt-3.webp']];
Promise.all(shots.map(([src,dst]) =>
  sharp('C:/tmp/' + src).webp({ quality: 82 }).toFile('C:/Users/keyst/Business-Landing-Page/images/work/creator/' + dst).then(i => console.log(dst, i.size, 'bytes'))
)).catch(e => { console.error(e); process.exit(1); });
"
git add images/work/creator/
git commit -m "Add Creator Dashboard detail-page screenshots

Hero (Home), Sessions, Insights, Goals tabs.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Task 12: Build `work/creator.html`

**Files:**
- Create: `work/creator.html`

- [ ] **Step 1: Copy template, apply substitutions**

```bash
cp work/d365.html work/creator.html
```

Per-page substitutions:

| Find | Replace with |
|---|---|
| Title | `Creator Dashboard — Keystone Marcy` |
| `images/work/d365/` → | `images/work/creator/` |
| Canonical + og:url path | `work/creator.html` |
| Meta description | `Creator Dashboard — a zero-backend cockpit for creators with scheduling, link-in-bio, analytics, and promo in one single-file HTML app.` |
| Eyebrow | `HTML / VANILLA JS` |
| H1 | `Creator Dashboard` |
| Subtitle | `A zero-backend cockpit for creators &mdash; scheduling, link-in-bio, analytics, and promo all in one single-file HTML app.` |
| Hero shot-url | `creator-dashboard · home` |
| Hero alt | `Creator Dashboard home tab — dark UI with KPI cards (streams logged, followers, tips, hours) and a growth-principles checklist` |
| Why prose | `Creators juggle 6+ tools to run a small operation: scheduling, link-in-bio, basic analytics, promo planning. This shell app pulls all of those into one single-file HTML cockpit with localStorage persistence &mdash; no backend, no install, just open the file. Designed for people who want the dashboard without standing up infrastructure.` |
| WT1 shot-url | `creator-dashboard · sessions` |
| WT1 alt | `Sessions tab listing streaming sessions with duration, viewers, and tips per session` |
| WT1 h3 | `Sessions tracker` |
| WT1 caption | `What it shows: each streaming session logged with duration, viewers, and tips. The dashboard rolls these up into the weekly and monthly KPIs that show on the home tab.` |
| WT2 shot-url | `creator-dashboard · insights` |
| WT2 alt | `Insights tab with top-line metrics and a growth-principles checklist` |
| WT2 h3 | `Insights view` |
| WT2 caption | `What it shows: top-line metrics &mdash; followers added, hours streamed, tip income, retention proxies &mdash; alongside a growth-principles checklist that nudges the creator toward higher-ROI activities.` |
| WT3 shot-url | `creator-dashboard · goals` |
| WT3 alt | `Goals tab showing quarterly goals with progress bars` |
| WT3 h3 | `Goals + Promo` |
| WT3 caption | `What it shows: quarterly goals with progress bars, tied to scheduled content via the Promo planner. Everything persists to localStorage &mdash; no account, no signup, no servers to maintain.` |
| Tag row | `<span class="tag">HTML</span><span class="tag">JS</span><span class="tag">LocalStorage</span>` |

- [ ] **Step 2: Render-verify and commit**

```bash
git add work/creator.html
git commit -m "Add Creator Dashboard detail page

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Task 13: Convert ML housing PNGs to WebP

**Why:** The ML project's plots are already in `C:\Users\keyst\`. Reuse them — no new captures.

**Files:**
- Create: `images/work/ml/{hero,wt-1,wt-2,wt-3}.webp`

- [ ] **Step 1: Create folder and copy via sharp**

```bash
mkdir -p images/work/ml
cd /c/tmp && node -e "
const sharp = require('sharp');
const shots = [
  ['/c/Users/keyst/Correlation_Heatmap.png', 'hero.webp'],
  ['/c/Users/keyst/Feature_Importances_GBR.png', 'wt-1.webp'],
  ['/c/Users/keyst/Predicted_vs_Actual_GBR.png', 'wt-2.webp'],
  ['/c/Users/keyst/GarageCars_vs_SalePrice.png', 'wt-3.webp'],
];
Promise.all(shots.map(([src, dst]) =>
  sharp(src.replace('/c/','C:/')).webp({ quality: 85 }).toFile('C:/Users/keyst/Business-Landing-Page/images/work/ml/' + dst).then(i => console.log(dst, i.size, 'bytes'))
)).catch(e => { console.error(e); process.exit(1); });
"
```

Expected: 4 lines, each well under 50 KB (Matplotlib plots compress hard as WebP).

- [ ] **Step 2: Commit**

```bash
git add images/work/ml/
git commit -m "$(cat <<'EOF'
Add Housing-Price ML detail-page assets (WebP from existing PNGs)

Hero: correlation heatmap. Walkthrough: GBR feature importance, GBR
predicted-vs-actual, GarageCars vs SalePrice. Sources are the plot PNGs
already in C:/Users/keyst/ from the original Jupyter analysis.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 14: Build `work/ml.html`

**Files:**
- Create: `work/ml.html`

- [ ] **Step 1: Copy template, apply substitutions**

```bash
cp work/d365.html work/ml.html
```

Per-page substitutions:

| Find | Replace with |
|---|---|
| Title | `Housing-Price ML Models — Keystone Marcy` |
| `images/work/d365/` → | `images/work/ml/` |
| Canonical + og:url path | `work/ml.html` |
| Meta description | `Comparing XGBoost, Gradient Boosting, and Linear Regression on real housing-price data, with full feature engineering and predicted-vs-actual diagnostics.` |
| Eyebrow | `DATA SCIENCE / SCIKIT-LEARN / XGBOOST` |
| H1 | `Housing-Price ML Models` |
| Subtitle | `Comparing XGBoost, Gradient Boosting, and Linear Regression on real housing-price data, with full feature engineering and predicted-vs-actual diagnostics.` |
| Hero shot-url | `housing-model · correlation` |
| Hero alt | `Correlation heatmap of engineered housing features against SalePrice` |
| Why prose | `Which model actually predicts home prices best? Most ML "how it works" demos hand-wave model selection. This project compares XGBoost, Gradient Boosting, and Linear Regression on real housing data, with explicit feature engineering and head-to-head predicted-vs-actual diagnostics so the choice isn't a vibe &mdash; it's a number.` |
| WT1 shot-url | `housing-model · feature importance` |
| WT1 alt | `Feature importance bar chart from the Gradient Boosting model — OverallQual and GrLivArea dominate` |
| WT1 h3 | `Feature importance` |
| WT1 caption | `What it shows: Gradient Boosting's top features, ranked by importance. OverallQual and GrLivArea together explain most of the variance. The shape of this chart tells you how the model actually makes decisions, which is half the value of running it.` |
| WT2 shot-url | `housing-model · predicted vs actual` |
| WT2 alt | `Predicted vs. actual sale-price scatter plot for the Gradient Boosting model — points cluster tightly around the diagonal` |
| WT2 h3 | `Predicted vs. actual` |
| WT2 caption | `What it shows: scatter of Gradient Boosting's predictions against true sale prices. Points cluster tightly along the diagonal &mdash; when they drift, that's where the model has the most to learn. The diagnostic that picks the winning model.` |
| WT3 shot-url | `housing-model · garage cars` |
| WT3 alt | `Scatter of GarageCars against SalePrice with a clear positive trend` |
| WT3 h3 | `One feature in detail` |
| WT3 caption | `What it shows: how a single feature (number of garage cars) relates to SalePrice. EDA at this level surfaced the engineered features that ended up driving the model &mdash; not every feature is signal, and not every signal looks linear.` |
| Tag row | `<span class="tag">Python</span><span class="tag">XGBoost</span><span class="tag">scikit-learn</span><span class="tag">EDA</span>` |

- [ ] **Step 2: Render-verify and commit**

```bash
git add work/ml.html
git commit -m "Add Housing-Price ML detail page

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Task 15: Build `work/codex.html` (slim version — login-gated app)

**Why:** Codex's live app requires login. Per spec, ship a slimmer detail page now: hero + an extended "Why it exists" + tech tags. **No walkthrough rows.** The page can be enriched later when the user supplies in-app screenshots.

**Files:**
- Create: `images/work/codex/hero.webp`
- Create: `work/codex.html`

- [ ] **Step 1: Reuse the existing card asset as the hero**

```bash
mkdir -p images/work/codex
cp images/proj-codex.webp images/work/codex/hero.webp
```

- [ ] **Step 2: Copy and edit the template**

```bash
cp work/d365.html work/codex.html
```

This time, edit to **remove the entire `<section class="walkthrough">...</section>` block** (no walkthrough rows for Codex). Substitutions for the rest:

| Find | Replace with |
|---|---|
| Title | `Codex Job Tracking App — Keystone Marcy` |
| `images/work/d365/` → | `images/work/codex/` |
| Canonical + og:url path | `work/codex.html` |
| Meta description | `Codex Job Tracking App — a full-stack command center that aggregates job listings, ranks fit with OpenAI, tailors résumés, watches recruiter inboxes, and runs approval-gated auto-apply.` |
| Eyebrow | `NEXT.JS / FASTAPI / CREWAI` |
| H1 | `Codex Job Tracking App` |
| Subtitle | `A full-stack command center that aggregates job listings, ranks fit with AI, and runs approval-gated auto-apply with a multi-agent crew.` |
| Hero shot-url | `kmcaijobtracker · cockpit` |
| Hero alt | `Codex Job Tracking App cockpit — KPI cards (active jobs, average AI fit, approvals, recruiter replies), AI workflow command panel, and top nav covering Applications, Calendar, Opportunities, Analytics, Recruiter CRM, Agents, Task Runs` |
| Why prose | `Job hunting is fragmented across half a dozen tools &mdash; boards, inboxes, ATS portals, recruiter messages, spreadsheets to track it all. This Next.js + FastAPI app pulls everything into one cockpit and uses a CrewAI multi-agent system to do the search end-to-end: scrape postings, score fit with OpenAI, tailor a résumé per role, watch Gmail and Outlook for replies, and submit applications with a human approval gate. The cockpit screenshot above shows the live state &mdash; active jobs, average AI fit, recent recruiter replies, and pending approvals all at-a-glance.` |
| Tag row | `<span class="tag">Next.js</span><span class="tag">FastAPI</span><span class="tag">CrewAI</span>` |

Also delete the entire `<section class="walkthrough">...</section>` block from the copied template.

- [ ] **Step 3: Render-verify and commit**

```bash
git add images/work/codex/ work/codex.html
git commit -m "$(cat <<'EOF'
Add Codex Job Tracking App detail page (slim version)

Login-gated app, so the detail page ships with hero + extended "Why it
exists" + tags only, no walkthrough rows. Can be enriched later when
in-app screenshots are supplied. Hero reuses the existing card asset.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Phase 4 — Wire up and ship

### Task 16: Convert the remaining 5 cards to detail-page links

**Files:**
- Modify: `index.html` (5 card wrappers in the `#work` section)

- [ ] **Step 1: Codex card — replace external link with detail-page link AND remove the "Open live app" footer**

The Codex card currently looks like:

```html
<!-- Card 2: Codex Job Tracking App (wide 2x1) -->
<a class="bento-card wide reveal" href="https://kmcaijobtracker.netlify.app" target="_blank" rel="noopener" aria-label="AI Job Tracker — open live app in new tab" style="transition-delay: 60ms">
  <p class="card-label">NEXT.JS / FASTAPI / CREWAI</p>
  <h3 class="card-title">Codex Job Tracking App</h3>
  ...
  <div class="card-foot">
    <span class="view">Open live app <span aria-hidden="true">↗</span></span>
  </div>
</a>
```

Use Edit. Two changes:

**Edit A — opening tag:**

`old_string`:
```html
        <!-- Card 2: Codex Job Tracking App (wide 2x1) -->
        <a class="bento-card wide reveal" href="https://kmcaijobtracker.netlify.app" target="_blank" rel="noopener" aria-label="AI Job Tracker — open live app in new tab" style="transition-delay: 60ms">
```

`new_string`:
```html
        <!-- Card 2: Codex Job Tracking App (wide 2x1) — detail-page link -->
        <a class="bento-card wide reveal" href="work/codex.html" aria-label="Codex Job Tracking App — open detail page" style="transition-delay: 60ms" data-cta="work_codex">
```

**Edit B — remove the `card-foot` block:**

`old_string`:
```html
          <div class="card-foot">
            <span class="view">Open live app <span aria-hidden="true">↗</span></span>
          </div>
```

`new_string`: (empty — delete it entirely)

- [ ] **Step 2: Agentic OS card — wrapper element change**

`old_string`:
```html
        <!-- Card 3: Agentic OS Dashboard (wide 2x1) — display-only -->
        <article class="bento-card wide reveal" aria-label="Agentic OS Dashboard" style="transition-delay: 120ms">
```

`new_string`:
```html
        <!-- Card 3: Agentic OS Dashboard (wide 2x1) — detail-page link -->
        <a class="bento-card wide reveal" href="work/agentic-os.html" aria-label="Agentic OS Dashboard — open detail page" style="transition-delay: 120ms" data-cta="work_agentic_os">
```

Then find the matching `</article>` immediately before the comment `<!-- Card 4: Creator Dashboard ... -->` and change it to `</a>`.

- [ ] **Step 3: Creator card**

`old_string`:
```html
        <!-- Card 4: Creator Dashboard (wide 2x1) — display-only -->
        <article class="bento-card wide reveal" aria-label="Creator Dashboard" style="transition-delay: 180ms">
```

`new_string`:
```html
        <!-- Card 4: Creator Dashboard (wide 2x1) — detail-page link -->
        <a class="bento-card wide reveal" href="work/creator.html" aria-label="Creator Dashboard — open detail page" style="transition-delay: 180ms" data-cta="work_creator">
```

Closing `</article>` (before the Aurora comment) → `</a>`.

- [ ] **Step 4: Aurora card**

`old_string`:
```html
        <!-- Card 5: Aurora — Autonomous Marketing Agency (wide 2x1) — display-only -->
        <article class="bento-card wide reveal" aria-label="Aurora — Autonomous Marketing Agency" style="transition-delay: 240ms">
```

`new_string`:
```html
        <!-- Card 5: Aurora — Autonomous Marketing Agency (wide 2x1) — detail-page link -->
        <a class="bento-card wide reveal" href="work/aurora.html" aria-label="Aurora — Marketing Agency — open detail page" style="transition-delay: 240ms" data-cta="work_aurora">
```

Closing `</article>` (before the Housing-Price ML comment) → `</a>`.

- [ ] **Step 5: Housing-Price ML card**

`old_string`:
```html
        <!-- Card 6: Housing-Price ML Models (wide 2x1) — display-only -->
        <article class="bento-card wide reveal" aria-label="Housing-Price ML Models" style="transition-delay: 300ms">
```

`new_string`:
```html
        <!-- Card 6: Housing-Price ML Models (wide 2x1) — detail-page link -->
        <a class="bento-card wide reveal" href="work/ml.html" aria-label="Housing-Price ML Models — open detail page" style="transition-delay: 300ms" data-cta="work_ml">
```

Closing `</article>` (the last one in the `#work` section, just before `</div>` for `.bento`) → `</a>`.

- [ ] **Step 6: Render-verify the bento still looks the same**

```bash
node /c/tmp/verify-work.js
```

Read `C:\tmp\work-section.png` and confirm all 6 cards still render correctly (same images, titles, descriptions, tags). Visually nothing changed; functionally each card is now a link.

- [ ] **Step 7: Commit**

```bash
git add index.html
git commit -m "$(cat <<'EOF'
Link remaining 5 work cards to their detail pages

Codex's external link to kmcaijobtracker.netlify.app is replaced by
work/codex.html, and the "Open live app" footer is removed. The other
four (Agentic OS, Creator, Aurora, ML) become <a> wrappers around the
same content. No visual change to the bento itself.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 17: Update `sitemap.xml` with the 6 new URLs

**Files:**
- Modify: `sitemap.xml`

- [ ] **Step 1: Read the current sitemap**

```bash
cat sitemap.xml
```

- [ ] **Step 2: Replace its content with one that lists all 7 URLs**

Use Write. Content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://keystonemarcy.pages.dev/</loc></url>
  <url><loc>https://keystonemarcy.pages.dev/work/d365.html</loc></url>
  <url><loc>https://keystonemarcy.pages.dev/work/codex.html</loc></url>
  <url><loc>https://keystonemarcy.pages.dev/work/agentic-os.html</loc></url>
  <url><loc>https://keystonemarcy.pages.dev/work/creator.html</loc></url>
  <url><loc>https://keystonemarcy.pages.dev/work/aurora.html</loc></url>
  <url><loc>https://keystonemarcy.pages.dev/work/ml.html</loc></url>
</urlset>
```

- [ ] **Step 3: Commit**

```bash
git add sitemap.xml
git commit -m "Update sitemap with /work/<slug>.html detail pages

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

### Task 18: Final production deploy and verification

**Files:** none (deploy operation + verification)

- [ ] **Step 1: Confirm working tree is clean**

```bash
git status --short
```

Expected: empty output.

- [ ] **Step 2: Stash gitignored junk before `--dir .` deploy**

```bash
mkdir -p /c/tmp/blp-deploy-stash/images
mv ruvector.db /c/tmp/blp-deploy-stash/
mv images/ruvector.db /c/tmp/blp-deploy-stash/images/
mv preview-*.html /c/tmp/blp-deploy-stash/
```

- [ ] **Step 3: Push to origin and deploy**

```bash
git push origin main
netlify deploy --prod --dir .
```

Expected: deploy completes with a Production URL of `https://keystonemarcy.pages.dev`.

- [ ] **Step 4: Restore junk**

```bash
mv /c/tmp/blp-deploy-stash/ruvector.db ./
mv /c/tmp/blp-deploy-stash/images/ruvector.db images/
mv /c/tmp/blp-deploy-stash/preview-*.html ./
rmdir /c/tmp/blp-deploy-stash/images /c/tmp/blp-deploy-stash
```

- [ ] **Step 5: Verify all 6 detail pages and the CSS file are reachable on live**

```bash
for slug in d365 codex agentic-os creator aurora ml; do
  curl -s -o /dev/null -w "work/${slug}.html -> HTTP %{http_code}\n" "https://keystonemarcy.pages.dev/work/${slug}.html"
  curl -s -o /dev/null -w "  hero.webp     -> HTTP %{http_code}\n"   "https://keystonemarcy.pages.dev/images/work/${slug}/hero.webp"
done
curl -s -o /dev/null -w "assets/site.css -> HTTP %{http_code}\n" "https://keystonemarcy.pages.dev/assets/site.css"
curl -s -o /dev/null -w "ruvector.db (should 404) -> HTTP %{http_code}\n" "https://keystonemarcy.pages.dev/ruvector.db"
```

Expected: all detail pages and CSS = 200, hero assets = 200 (Codex hero too), ruvector.db = 404.

- [ ] **Step 6: Open the landing page in the user's browser and confirm clicks land on detail pages**

```bash
start "" "https://keystonemarcy.pages.dev/#work"
```

User-facing sanity check: click each of the 6 cards and confirm each lands on its detail page; click "← Back to work" on each detail page and confirm it returns to the landing page at the `#work` anchor.

- [ ] **Step 7: Report URLs**

Report to the user:
- Production URL: `https://keystonemarcy.pages.dev`
- All 6 detail page URLs (so they can spot-check)
- This-deploy unique URL from the netlify CLI output

---

## End-of-plan notes

- **Total commits expected:** 1 prereq + 18 task commits (some tasks span multiple commits where assets and HTML are committed separately). Roughly ~20 commits.
- **Time budget estimate:** ~3-4 hours all-in for inline execution; less with subagents working in parallel where possible (image conversions in Tasks 3, 7, 9, 11, 13 are independent and parallelizable).
- **What is NOT done:** GA4/Clarity activation, Codex in-app screenshots, testimonial section, intro video — all flagged in the spec as non-goals.
- **If anything in Task 4's template needs to change after the POC review**, propagate the same change to Tasks 8/10/12/14/15's per-page output (the substitution tables stay; only the template structure changes need follow-up).
