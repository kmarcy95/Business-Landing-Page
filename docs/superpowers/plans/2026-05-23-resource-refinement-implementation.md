# Resource-Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the evidence-aligned subset of `awesome-design` resources to the Business Landing Page — WebP performance pass, CSS browser-chrome on Work screenshots, contrast audit, and Services icons — without any change that conflicts with the recruiter-first market analysis.

**Architecture:** Single-file vanilla `index.html` (no build, no CDN). Image optimization runs through Node `sharp` from `C:\tmp` (keeps the repo clean). All markup/style changes are in-place edits to `index.html`. No automated tests exist; each task ends with a manual/observable verification.

**Tech Stack:** HTML5, CSS custom properties, vanilla JS, Node `sharp` (image tooling only), inline SVG (Tabler icons, MIT).

> **Note on commits/deploy:** Do NOT commit, push, or deploy during execution. All git/Netlify actions are deferred to Task 7, gated on explicit user approval.

---

## File Structure

- `index.html` — modified (image refs, preload, browser-chrome markup+CSS, icon markup+CSS, any contrast token tweak).
- `images/*.webp` — created (5 screenshots + 1 hero).
- `images/headshot-hero.jpg` — deleted (unused).
- `C:\tmp\optimize-images.js` — created (throwaway tooling, outside repo).
- `C:\tmp\contrast.js` — created (throwaway tooling, outside repo).
- `docs/superpowers/specs/2026-05-23-resource-refinement-design.md` — source spec (already written).

---

### Task 1: Generate optimized WebP images

**Files:**
- Create: `C:\tmp\optimize-images.js`
- Create: `images/proj-d365web.webp`, `images/proj-codex.webp`, `images/proj-creator.webp`, `images/proj-agent.webp`, `images/proj-ml.webp`, `images/headshot-about.webp`

- [ ] **Step 1: Install sharp in C:\tmp (outside the repo)**

Run: `cd /c/tmp && npm install sharp`
Expected: sharp installs without error (a `node_modules` appears under `C:\tmp`, not the repo).

- [ ] **Step 2: Write the optimizer script**

Create `C:\tmp\optimize-images.js`:

```js
const sharp = require('C:/tmp/node_modules/sharp');
const dir = 'C:/Users/keyst/Business-Landing-Page/images/';
const shots = ['proj-d365web', 'proj-codex', 'proj-creator', 'proj-agent', 'proj-ml'];

(async () => {
  for (const name of shots) {
    const info = await sharp(dir + name + '.png').webp({ quality: 80 }).toFile(dir + name + '.webp');
    console.log(name + '.webp', Math.round(info.size / 1024) + ' KB');
  }
  const hero = await sharp(dir + 'headshot-about.jpg')
    .resize({ width: 960 })
    .webp({ quality: 82 })
    .toFile(dir + 'headshot-about.webp');
  console.log('headshot-about.webp', Math.round(hero.size / 1024) + ' KB');
})().catch(e => { console.error(e); process.exit(1); });
```

- [ ] **Step 3: Run the optimizer**

Run: `node C:/tmp/optimize-images.js`
Expected: six lines printed, each well under the original (screenshots total ~200 KB; `headshot-about.webp` < 30 KB).

- [ ] **Step 4: Verify outputs exist and are smaller**

Run: `cd /c/Users/keyst/Business-Landing-Page/images && ls -la *.webp`
Expected: 6 `.webp` files present; `proj-d365web.webp` ≪ 250 KB; `headshot-about.webp` < 30 KB.

---

### Task 2: Repoint image references and preload to WebP

**Files:**
- Modify: `index.html` (head preload line ~9; hero img line ~1116; five `card-image` `<img>` `src` attrs in `#work`)

- [ ] **Step 1: Update the hero preload**

Replace:
```html
  <link rel="preload" as="image" href="images/headshot-about.jpg" fetchpriority="high" />
```
With:
```html
  <link rel="preload" as="image" href="images/headshot-about.webp" type="image/webp" fetchpriority="high" />
```

- [ ] **Step 2: Update the hero `<img>` (src + intrinsic dims to 960²)**

Replace:
```html
        <img src="images/headshot-about.jpg" alt="Keystone Marcy — portrait" width="1024" height="1024" loading="eager" fetchpriority="high" />
```
With:
```html
        <img src="images/headshot-about.webp" alt="Keystone Marcy — portrait" width="960" height="960" loading="eager" fetchpriority="high" />
```

- [ ] **Step 3: Update the five Work screenshot `src` attributes**

Change each `.png` to `.webp` (alt/width/height/loading unchanged):
- `images/proj-d365web.png` → `images/proj-d365web.webp`
- `images/proj-codex.png` → `images/proj-codex.webp`
- `images/proj-agent.png` → `images/proj-agent.webp`
- `images/proj-creator.png` → `images/proj-creator.webp`
- `images/proj-ml.png` → `images/proj-ml.webp`

- [ ] **Step 4: Verify no stale references remain**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -nE "images/(proj-[a-z0-9]+|headshot-about)\.(png|jpg)" index.html`
Expected: no matches (og.png is intentionally untouched and won't match this pattern).

---

### Task 3: Delete the unused hero JPG

**Files:**
- Delete: `images/headshot-hero.jpg`

- [ ] **Step 1: Confirm it is unreferenced**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -n "headshot-hero" index.html`
Expected: no matches.

- [ ] **Step 2: Delete the file**

Run: `rm /c/Users/keyst/Business-Landing-Page/images/headshot-hero.jpg`
Expected: file removed; `ls images/headshot-hero.jpg` errors.

---

### Task 4: Add CSS browser-chrome to Work screenshots

**Files:**
- Modify: `index.html` (add CSS after the `.card-image` block ~line 631; wrap each `<img class="card-image">` in `#work`)

- [ ] **Step 1: Add the `.shot` CSS**

Insert after the `.bento-card.banner .card-image { ... }` rule:

```css
  /* ---- browser-chrome frame for work screenshots ---- */
  .shot {
    margin-bottom: 1.15rem;
    border: 1px solid var(--border);
    border-radius: var(--r-md);
    overflow: hidden;
    background: var(--surface-2);
  }
  .shot-bar {
    display: flex; align-items: center; gap: .55rem;
    padding: .4rem .65rem;
    background: var(--surface-2);
    border-bottom: 1px solid var(--border);
  }
  .shot-dots { display: inline-flex; gap: .3rem; flex: none; }
  .shot-dots i { width: 9px; height: 9px; border-radius: 50%; background: var(--border-strong); }
  .shot-url {
    font-family: var(--font-mono);
    font-size: .64rem;
    color: var(--text-muted);
    letter-spacing: .02em;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  }
  .shot .card-image {
    margin-bottom: 0;
    border: 0;
    border-radius: 0;
  }
```

- [ ] **Step 2: Wrap the flagship (d365web) screenshot**

Replace:
```html
          <img class="card-image" src="images/proj-d365web.webp" alt="D365 ERP Manager Web — implementation roadmap with a six-phase Gantt timeline and phase-by-phase progress summary" loading="lazy" width="1440" height="900" />
```
With:
```html
          <div class="shot">
            <div class="shot-bar" aria-hidden="true">
              <span class="shot-dots"><i></i><i></i><i></i></span>
              <span class="shot-url">d365web · roadmap</span>
            </div>
            <img class="card-image" src="images/proj-d365web.webp" alt="D365 ERP Manager Web — implementation roadmap with a six-phase Gantt timeline and phase-by-phase progress summary" loading="lazy" width="1440" height="900" />
          </div>
```

- [ ] **Step 3: Wrap the Codex (live) screenshot with its real URL**

Replace:
```html
          <img class="card-image" src="images/proj-codex.webp" alt="AI Job Tracker dashboard — Job search cockpit with KPI cards (active jobs, average AI fit, approvals, recruiter replies), AI workflow command panel, and top nav covering Applications, Calendar, Opportunities, Analytics, Recruiter CRM, Agents, Task Runs" loading="lazy" width="1440" height="760" />
```
With:
```html
          <div class="shot">
            <div class="shot-bar" aria-hidden="true">
              <span class="shot-dots"><i></i><i></i><i></i></span>
              <span class="shot-url">kmcaijobtracker.netlify.app</span>
            </div>
            <img class="card-image" src="images/proj-codex.webp" alt="AI Job Tracker dashboard — Job search cockpit with KPI cards (active jobs, average AI fit, approvals, recruiter replies), AI workflow command panel, and top nav covering Applications, Calendar, Opportunities, Analytics, Recruiter CRM, Agents, Task Runs" loading="lazy" width="1440" height="760" />
          </div>
```

- [ ] **Step 4: Wrap the Agent Dashboard screenshot**

Replace:
```html
          <img class="card-image" src="images/proj-agent.webp" alt="Agent Dashboard — agentic OS observability with workflow, skill, and token-spend metrics plus a recent-runs panel" loading="lazy" width="1440" height="900" />
```
With:
```html
          <div class="shot">
            <div class="shot-bar" aria-hidden="true">
              <span class="shot-dots"><i></i><i></i><i></i></span>
              <span class="shot-url">agent-os · dashboard</span>
            </div>
            <img class="card-image" src="images/proj-agent.webp" alt="Agent Dashboard — agentic OS observability with workflow, skill, and token-spend metrics plus a recent-runs panel" loading="lazy" width="1440" height="900" />
          </div>
```

- [ ] **Step 5: Wrap the Creator Dashboard screenshot**

Replace:
```html
          <img class="card-image" src="images/proj-creator.webp" alt="Creator Dashboard interface — dark UI with KPI cards (streams logged, followers, tips, hours) and a growth-principles checklist" loading="lazy" width="1440" height="900" />
```
With:
```html
          <div class="shot">
            <div class="shot-bar" aria-hidden="true">
              <span class="shot-dots"><i></i><i></i><i></i></span>
              <span class="shot-url">creator-dashboard</span>
            </div>
            <img class="card-image" src="images/proj-creator.webp" alt="Creator Dashboard interface — dark UI with KPI cards (streams logged, followers, tips, hours) and a growth-principles checklist" loading="lazy" width="1440" height="900" />
          </div>
```

- [ ] **Step 6: Wrap the Housing-ML banner screenshot**

Replace:
```html
          <img class="card-image" src="images/proj-ml.webp" alt="Predicted vs. actual sale price scatter plot for the Gradient Boosting model — points cluster tightly around the diagonal reference line, indicating accurate predictions" loading="lazy" width="1000" height="600" />
```
With:
```html
          <div class="shot">
            <div class="shot-bar" aria-hidden="true">
              <span class="shot-dots"><i></i><i></i><i></i></span>
              <span class="shot-url">housing-model · predicted vs actual</span>
            </div>
            <img class="card-image" src="images/proj-ml.webp" alt="Predicted vs. actual sale price scatter plot for the Gradient Boosting model — points cluster tightly around the diagonal reference line, indicating accurate predictions" loading="lazy" width="1000" height="600" />
          </div>
```

- [ ] **Step 7: Verify wrapping**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -c "shot-bar" index.html`
Expected: `5`.

---

### Task 5: Color & contrast audit

**Files:**
- Create: `C:\tmp\contrast.js`
- Modify: `index.html` (only if a pair measures < 4.5:1)

- [ ] **Step 1: Write the contrast checker (no deps)**

Create `C:\tmp\contrast.js`:

```js
function lum(hex) {
  const v = hex.replace('#', '').match(/.{2}/g).map(h => {
    const c = parseInt(h, 16) / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2];
}
function ratio(a, b) {
  const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
  return ((hi + 0.05) / (lo + 0.05)).toFixed(2);
}
const W = '#ffffff', S2 = '#f3f4f7';
const pairs = [
  ['text #16171c on white', '#16171c', W],
  ['text-dim #44464f on white', '#44464f', W],
  ['text-muted #5b5d68 on white', '#5b5d68', W],
  ['text-muted on surface-2', '#5b5d68', S2],
  ['accent-1 #1e40af on white', '#1e40af', W],
  ['accent-2 #1e3a8a on white', '#1e3a8a', W],
  ['white on accent-1 (button)', W, '#1e40af'],
];
pairs.forEach(([label, a, b]) => console.log(ratio(a, b).padStart(6), label));
```

- [ ] **Step 2: Run it**

Run: `node C:/tmp/contrast.js`
Expected: every ratio ≥ 4.5. (Predicted: text ~16, text-dim ~9, text-muted ~6.3, accent-1 ~6.3, accent-2 ~8.)

- [ ] **Step 3: Fix only if something fails**

If any pair < 4.5:1, darken the offending token by the smallest step that clears 4.5:1 (e.g. `--text-muted` → `#54565f`) in the `:root` block of `index.html`, then re-run Step 2 to confirm. If all pass, make no change.

- [ ] **Step 4: Record the result**

Note the measured ratios in the execution summary (these are the audit deliverable).

---

### Task 6: Add icons to the Services cards

**Files:**
- Modify: `index.html` (add `.service-icon` CSS near the `.service-num` rule ~line 663; add one inline SVG to each of the three `.service-card`s ~lines 1368-1382)

- [ ] **Step 1: Add `.service-icon` CSS**

Insert just before the `.service-num { ... }` rule:

```css
  .service-icon {
    width: 26px; height: 26px;
    color: var(--accent-1);
    margin-bottom: .65rem;
  }
```

- [ ] **Step 2: Add the app-window icon to card 01**

Immediately after `<p class="service-num">01</p>` insert:

```html
          <svg class="service-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M3 9h18" /><path d="M6.5 6.5h.01" /><path d="M9.5 6.5h.01" /></svg>
```

- [ ] **Step 3: Add the cpu/agent icon to card 02**

Immediately after `<p class="service-num">02</p>` insert:

```html
          <svg class="service-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="6" y="6" width="12" height="12" rx="1" /><rect x="9" y="9" width="6" height="6" rx="1" /><path d="M10 3v2M14 3v2M10 19v2M14 19v2M3 10h2M3 14h2M19 10h2M19 14h2" /></svg>
```

- [ ] **Step 4: Add the table icon to card 03**

Immediately after `<p class="service-num">03</p>` insert:

```html
          <svg class="service-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2" /><path d="M3 9h18" /><path d="M3 15h18" /><path d="M9 3v18" /></svg>
```

- [ ] **Step 5: Verify**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -c "service-icon" index.html`
Expected: `4` (1 CSS rule selector + 3 SVGs).

---

### Task 7: Final verification and deferred ship

**Files:** none (review + gated git/deploy)

- [ ] **Step 1: Static integrity checks**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -nE "\.(png|jpg)\"" index.html`
Expected: only `og.png` (and the data-URI favicon) remain as raster refs.

- [ ] **Step 2: Confirm image payload dropped**

Run: `cd /c/Users/keyst/Business-Landing-Page/images && ls -la *.webp *.png *.jpg`
Expected: referenced WebP set is materially smaller than the prior PNG/JPG set; `headshot-hero.jpg` absent.

- [ ] **Step 3: Visual check in a browser**

Open `index.html` in a browser at desktop (~1280px) and mobile (~390px) widths. Confirm: hero portrait loads, all 5 Work cards show framed screenshots with chrome + label, 3 Services icons render in accent blue, no layout breakage, sticky CTA + nav still work.

- [ ] **Step 4: Review the diff**

Run: `cd /c/Users/keyst/Business-Landing-Page && git status && git --no-pager diff --stat`
Expected: `index.html` modified; 6 `.webp` added; `headshot-hero.jpg` deleted; 2 spec/plan docs added. No stray files (watch for `ruvector.db`, `node_modules`).

- [ ] **Step 5: Commit + deploy — ONLY after explicit user approval**

When the user says to ship:
```bash
git add -A
git commit -m "Perf + proof polish: WebP images, browser-chrome work shots, service icons"
git push origin main
netlify deploy --prod --dir .
```
Remember both Netlify sites auto-deploy from this repo. Confirm `git status` is clean before `netlify deploy` (it uploads the whole dir).

---

## Self-Review

**Spec coverage:** A (WebP screenshots + hero resize/preload + og.png left + delete headshot-hero) → Tasks 1-3. B (browser chrome) → Task 4. C (contrast audit) → Task 5. D (service icons) → Task 6. Verification + deferred deploy → Task 7. All spec sections mapped.

**Placeholder scan:** No TBD/TODO; every code/edit step shows exact content; verification commands have expected output.

**Type/name consistency:** `.shot` / `.shot-bar` / `.shot-dots` / `.shot-url` / `.service-icon` used identically in CSS and markup. WebP filenames consistent across Tasks 1, 2, 4, 7.
