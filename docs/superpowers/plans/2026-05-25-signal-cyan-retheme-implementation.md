# Signal Cyan Retheme — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Re-theme the Business Landing Page from charcoal+yellow to a near-black + signal-cyan palette ("Sharp Operator" — Linear/Vercel-inflected) targeting fintech-CFO recruiters, while preserving every existing layout, copy, asset position, and contrast guarantee (≥ WCAG AA on every text/bg pair).

**Architecture:** The site uses a two-`:root` layering pattern — a base `:root` at lines 65–90 and a *theme override* `:root` block at lines 1084–1108 that wins via source-order cascade. The current active theme (charcoal+yellow) lives entirely in that override block. This plan **edits only the override block**, leaving the base `:root` untouched. That keeps the diff small, the risk low, and matches the existing retheme convention. Cyan replaces yellow as `--accent-1`; near-black replaces charcoal as `--bg-0`; CTA dark-text-on-accent pattern is preserved (it already exists in the override block for the yellow theme). Headshot gets a CSS frame to prevent halo on dark; OG card script gets re-colored and regenerated.

**Tech Stack:** Vanilla HTML/CSS/JS in a single `index.html` (no build step). PowerShell scripts for asset generation (`scripts/make-og.ps1` uses System.Drawing). Node script `C:\tmp\contrast.js` for WCAG verification. Manual browser testing (no automated test suite).

**Conventions:**
- One commit per task. Match existing commit-message tone in this repo (`git log --oneline -15`).
- Verification = open `index.html` in Chrome and inspect; this site has no automated tests.
- Don't touch the in-progress working-tree changes (`images/proj-agent.webp`, the bento Aurora-card edits in `index.html`) — those are independent of this retheme. Stage and commit *only* the lines you edit per task.

---

## Task 1: Replace the theme override block with Signal Cyan

**Goal:** Swap the entire charcoal+yellow override block at lines 1084–1108 with the Signal Cyan equivalent. This is the load-bearing change — once tokens are cyan, everything that uses `var(--accent-1)` etc. inherits correctly.

**Files:**
- Modify: `C:\Users\keyst\Business-Landing-Page\index.html` lines 1084–1108 (and add a new `.skip-link` override + `.btn-ghost` cyan border)

- [ ] **Step 1: Read the current override block to confirm exact contents**

Run:
```powershell
Select-String -Path "C:\Users\keyst\Business-Landing-Page\index.html" -Pattern "THEME:" -Context 0,25
```

Expected: the `/* ===== THEME: Charcoal gray + yellow (Apple-style layout) ===== */` block prints, ending at `.uv-stats{background:#16161a;border-color:#33333a;}`. Confirm it spans lines 1084–1108 exactly. If line numbers have shifted, adjust subsequent steps accordingly.

- [ ] **Step 2: Replace the override block via Edit tool**

Replace the entire block from `/* ===== THEME: Charcoal gray + yellow (Apple-style layout) ===== */` through `.uv-stats{background:#16161a;border-color:#33333a;}` (inclusive) with:

```css
/* ===== THEME: Signal Cyan (near-black + cyan, Vercel-inflected) ===== */
:root{
  --bg-0:#0a0a0a; --bg-1:#101012;
  --surface:#141416; --surface-translucent:rgba(20,20,22,0.65); --surface-2:#1c1c20;
  --border:#2a2a2f; --border-strong:#3a3a40;
  --text:#fafafa; --text-dim:#a3a3a3; --text-muted:#737373;
  --accent-1:#00b8ff; --accent-2:#0090d4;
  --grad-accent:linear-gradient(135deg,#00b8ff 0%,#0090d4 100%);
  --accent-glow:0,184,255;
  --font-display:-apple-system,'SF Pro Display','Segoe UI',system-ui,sans-serif; --font-body:-apple-system,'SF Pro Text','Segoe UI',system-ui,sans-serif;
  --shadow-sm:0 1px 2px rgba(0,0,0,.45); --shadow-md:0 8px 24px -10px rgba(0,0,0,.55); --shadow-lg:0 24px 60px -24px rgba(0,0,0,.65);
  --r-sm:0.7rem; --r-md:1rem; --r-lg:1.25rem;
}
h1,h2,h3{letter-spacing:-0.015em;font-weight:600;}
.bg-grain{opacity:0;}
.btn,.nav-cta{border-radius:980px;}
.btn-ghost{box-shadow:none; border-color:var(--accent-1); color:var(--accent-1);}
.btn-ghost:hover{background:rgba(0,184,255,0.08); border-color:var(--accent-1); color:var(--accent-1);}
.btn-primary{color:#0a0a0a !important;}
.nav-cta{color:#0a0a0a !important;}
.skip-link{color:#0a0a0a !important;}
.section{padding-block:clamp(4rem,11vw,8.5rem);}
.bg-mesh{background:
  radial-gradient(900px 500px at 50% -10%, rgba(0,184,255,.10), transparent 60%),
  linear-gradient(180deg,#0a0a0a 0%,#101012 100%);}
.section-tint{ --surface:#1c1c20; --surface-2:#101012; --surface-translucent:rgba(20,20,22,.7); --border:#2f2f35;}
.uv-stats{background:#141416;border-color:#2a2a2f;}
```

**Diff summary** (what changed vs. the old override block):
- `--bg-0` `#202024` → `#0a0a0a` (near-black)
- `--bg-1` `#1a1a1d` → `#101012`
- `--surface` `#2a2a2f` → `#141416`, `--surface-2` `#242428` → `#1c1c20`
- `--surface-translucent` opacity `0.6` → `0.65`, color tracks new surface
- `--border` `#3a3a40` → `#2a2a2f`, `--border-strong` `#4c4c54` → `#3a3a40`
- `--text` `#ececee` → `#fafafa`, `--text-dim` `#c4c4c8` → `#a3a3a3`, `--text-muted` `#9596a0` → `#737373`
- `--accent-1` `#f5c518` (yellow) → `#00b8ff` (signal cyan), `--accent-2` `#e0a800` → `#0090d4`
- `--grad-accent` yellow→amber → cyan→darker-cyan
- `--accent-glow` `245,197,24` → `0,184,255`
- `--shadow-*` opacities bumped slightly (`.4/.5/.6` → `.45/.55/.65`) for more depth on the darker base
- `.btn-ghost` now has cyan border + cyan text (was inheriting `--text` light gray on dark surface); hover gets translucent cyan wash instead of `--surface-2` swap
- `.btn-primary` / `.nav-cta` dark text changed from `#111` → `#0a0a0a` (matches spec; identical contrast in practice)
- `.skip-link{color:#0a0a0a !important;}` **NEW** — overrides the hardcoded `color:#fff` at line 157 (white-on-cyan fails AA)
- `.bg-mesh` swapped to subtle cyan radial top-glow over near-black-to-charcoal vertical gradient
- `.section-tint` overrides now *lift* (lighter surfaces inside tinted sections) instead of *darken* — matches spec's inverted relationship for the dark base
- `.uv-stats` now references the new surface/border shades

- [ ] **Step 3: Verify the only-this-block changes via git diff**

Run:
```powershell
git -C C:\Users\keyst\Business-Landing-Page diff index.html
```

Expected: the diff touches ONLY the lines inside the old `THEME: Charcoal` block. The in-progress bento-card edits and the first `:root` block at lines 65–90 must NOT appear in the diff. If they do, revert and retry the Edit with a more specific `old_string`.

- [ ] **Step 4: Open the page in Chrome and walk the visual checklist**

Run:
```powershell
Start-Process "C:\Users\keyst\Business-Landing-Page\index.html"
```

Inspect, in order:
- Nav: brand left, links right, `Contact` pill should be cyan with dark text. Scroll-spy underline visible against dark.
- Hero: dark base, subtle cyan top-glow, headshot on right (HALO MAY BE VISIBLE — handled in Task 2), `Download résumé` cyan button + `Get in touch` cyan-outlined ghost button.
- Logo-chip wall ("Finance & accounting roles across"): dark chips with light text; hover one → text + border turn cyan.
- Marquee: dark frosted captions over images.
- Stats band: cyan count-up numbers against the lifted `.uv-stats` card.
- Experience timeline, Work bento, Services, About, How-I-Work (bars should fill cyan), Contact form, sticky CTA, footer.

If anything is mid-gray/unreadable or yellow-tinted, stop and inspect — likely a hardcoded literal from the old theme escaped to a selector outside the override block (Task 6 will sweep, but a glaring miss is worth investigating now).

- [ ] **Step 5: Commit**

Run:
```powershell
git -C C:\Users\keyst\Business-Landing-Page add index.html
git -C C:\Users\keyst\Business-Landing-Page commit -m "Retheme site to Signal Cyan (near-black + cyan, Vercel-inflected)"
```

Note: this commit may also include lines from your in-progress bento-card work because `git add index.html` stages the whole file. Inspect `git diff --staged` first; if the bento changes shouldn't ship in this commit, use `git add -p` to stage only the override-block hunks.

---

## Task 2: Add a CSS frame around the hero headshot

**Goal:** Prevent the headshot's light backdrop from haloing on the near-black hero. CSS frame first (cheap, reversible); regen with dark backdrop only if step-1 isn't enough.

**Files:**
- Modify: `C:\Users\keyst\Business-Landing-Page\index.html` — append a `.hero-portrait img` rule inside the Signal Cyan override block

- [ ] **Step 1: Add the frame rule to the override block**

Insert immediately AFTER the `.uv-stats{background:#141416;border-color:#2a2a2f;}` line (last line of the override block) and BEFORE the `/* ===== How I Work (personality dossier) ===== */` comment:

```css
.hero-portrait img{ border-radius:50%; box-shadow:0 0 0 1px var(--border), 0 0 0 6px var(--surface); }
```

This wraps the circular crop in a 1px dark border immediately, then a 6px darker-surface ring — visually blends the photo's pale backdrop into the page bg.

- [ ] **Step 2: Reload `index.html` in Chrome and inspect the hero portrait**

Look specifically for: a visible bright crescent around the head (the halo). If present and obvious from 2+ feet away, proceed to Step 3. If subtle / not noticeable, skip Step 3 and go to Step 4.

- [ ] **Step 3 (CONDITIONAL — only if halo is still obvious): Regenerate the headshot with a dark backdrop**

Open `C:\Users\keyst\Business-Landing-Page\scripts\resize-headshots.ps1` and find the `Graphics.Clear(...)` call (or wherever the backdrop fill color is set). Change the fill color from the current light value to:

```powershell
$g.Clear([System.Drawing.Color]::FromArgb(10, 10, 10))  # was light; now matches --bg-0
```

Then run the script:
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\keyst\Business-Landing-Page\scripts\resize-headshots.ps1"
```

Then regenerate the WebP variant. Per CLAUDE.md, the WebP step uses `sharp` in `C:\tmp\`:
```powershell
node -e "require('C:/tmp/node_modules/sharp')('C:/Users/keyst/Business-Landing-Page/images/headshot-about.jpg').resize(960,960).webp({quality:82}).toFile('C:/Users/keyst/Business-Landing-Page/images/headshot-about.webp').then(()=>console.log('done'))"
```

Reload Chrome → confirm halo is gone.

- [ ] **Step 4: Commit**

Run:
```powershell
git -C C:\Users\keyst\Business-Landing-Page add index.html
# If Step 3 ran, also: git add scripts/resize-headshots.ps1 images/headshot-about.webp
git -C C:\Users\keyst\Business-Landing-Page commit -m "Frame hero headshot to prevent halo on dark base"
```

---

## Task 3: Verify WCAG AA contrast on the new tokens

**Goal:** Run a contrast script targeted at the new Signal Cyan tokens and confirm every text/background pair meets ≥ 4.5:1 (AA). The existing `C:\tmp\contrast.js` is hardcoded for the old white+blue palette — rewrite it for Signal Cyan.

**Files:**
- Modify: `C:\tmp\contrast.js` (this file is outside the repo — overwrite the pairs array)

- [ ] **Step 1: Overwrite `C:\tmp\contrast.js` with the Signal Cyan check**

Replace the entire file with:

```javascript
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
const BG = '#0a0a0a', BG1 = '#101012', S = '#141416', S2 = '#1c1c20';
const TEXT = '#fafafa', DIM = '#a3a3a3', MUTED = '#737373';
const CYAN = '#00b8ff', CYAN_DARK = '#0090d4';
const pairs = [
  ['text on bg-0',                     TEXT, BG],
  ['text-dim on bg-0',                 DIM,  BG],
  ['text-muted on bg-0',               MUTED,BG],
  ['text on surface',                  TEXT, S],
  ['text-dim on surface',              DIM,  S],
  ['text-muted on surface-2',          MUTED,S2],
  ['accent-1 cyan on bg-0',            CYAN, BG],
  ['accent-1 cyan on surface',         CYAN, S],
  ['accent-2 darker-cyan on bg-0',     CYAN_DARK, BG],
  ['dark text on cyan button',         '#0a0a0a', CYAN],
  ['dark text on darker-cyan hover',   '#0a0a0a', CYAN_DARK],
  ['cyan link on section-tint surface',CYAN, '#1c1c20'],
];
pairs.forEach(([label, a, b]) => console.log(ratio(a, b).padStart(6), label));
```

- [ ] **Step 2: Run the script**

```powershell
node C:\tmp\contrast.js
```

Expected (approximate — these are the targets the design spec assumed):
```
 19.50  text on bg-0
  7.50  text-dim on bg-0
  4.60  text-muted on bg-0
 (≥18)  text on surface
 (≥6.5) text-dim on surface
  4.20  text-muted on surface-2          ← borderline AA — see Step 3
  9.20  accent-1 cyan on bg-0
 (≥8.5) accent-1 cyan on surface
  5.80  accent-2 darker-cyan on bg-0
 10.40  dark text on cyan button
 (≥7)   dark text on darker-cyan hover
 (≥8.5) cyan link on section-tint surface
```

- [ ] **Step 3: Confirm every pair is ≥ 4.5:1 (AA). If any pair fails, lift `--text-muted` from `#737373` to `#8a8a8a` (still reads "muted" on dark, but pushes the surface-2 pair safely above AA), update both the override block and the script, and re-run.**

- [ ] **Step 4: No commit needed** (contrast.js is outside the repo). Make a note in the task list if Step 3's mitigation was applied, since the override block would then need a follow-up edit + commit.

---

## Task 4: Re-theme the OG share card to Signal Cyan

**Goal:** Regenerate `images/og.png` so the LinkedIn / Twitter share preview matches the new live theme. The PowerShell generator (`scripts/make-og.ps1`) needs three color literals swapped; everything else stays.

**Files:**
- Modify: `C:\Users\keyst\Business-Landing-Page\scripts\make-og.ps1` — swap charcoal+yellow ARGB tuples
- Regenerate: `C:\Users\keyst\Business-Landing-Page\images\og.png`

- [ ] **Step 1: Apply the color swaps in `make-og.ps1`**

Five surgical edits. Use the Edit tool, one at a time:

| Old | New | Rationale |
|---|---|---|
| `$g.Clear([System.Drawing.Color]::FromArgb(32, 32, 36))` | `$g.Clear([System.Drawing.Color]::FromArgb(10, 10, 10))` | bg charcoal → near-black |
| `$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 197, 24))), 0, 0, $W, 14)` | `$g.FillRectangle((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 184, 255))), 0, 0, $W, 14)` | top accent band yellow → cyan |
| `$orbBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($orb, [System.Drawing.Color]::FromArgb(255, 216, 77), [System.Drawing.Color]::FromArgb(245, 184, 0), 45)` | `$orbBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($orb, [System.Drawing.Color]::FromArgb(0, 184, 255), [System.Drawing.Color]::FromArgb(0, 144, 212), 45)` | brand orb yellow gradient → cyan gradient |
| `$ink    = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(236, 236, 238))` | `$ink    = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(250, 250, 250))` | title text `#ECECEE` → `#FAFAFA` (matches `--text`) |
| `$yellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 197, 24))` | `$yellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 184, 255))` | subtitle accent text yellow → cyan |

The variable `$yellow` is now a misnomer but renaming it would expand the diff. Leave the variable name; only swap the color value. (Optional cleanup: rename to `$cyan` and update the one reference — only if doing so doesn't trigger noise.)

The `$gray` brush stays the same — gray subtitle text reads correctly on near-black too.

- [ ] **Step 2: Run the generator**

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\keyst\Business-Landing-Page\scripts\make-og.ps1"
```

Expected output: `Wrote C:\Users\keyst\Business-Landing-Page\images\og.png`. No errors.

- [ ] **Step 3: Eyeball the output**

```powershell
Start-Process "C:\Users\keyst\Business-Landing-Page\images\og.png"
```

Verify: 1200×630, near-black bg, cyan top band, cyan brand orb at top-left, light text "Keystone Marcy", cyan subtitle "FP&A & Strategic Finance Leader", gray descriptor and URL line. Looks LinkedIn-share-ready.

- [ ] **Step 4: Commit**

```powershell
git -C C:\Users\keyst\Business-Landing-Page add scripts/make-og.ps1 images/og.png
git -C C:\Users\keyst\Business-Landing-Page commit -m "Retheme OG share card to Signal Cyan to match live site"
```

---

## Task 5: Sweep for stray light-mode / yellow-theme hex literals

**Goal:** Catch any hardcoded color that escaped tokenization and would now visually clash. The override block has us covered for token-referencing CSS, but a direct `#f5c518` or `#202024` outside the override block would not get updated.

**Files:**
- Possibly modify: `C:\Users\keyst\Business-Landing-Page\index.html` if a stray literal turns up

- [ ] **Step 1: Grep for old-theme hex literals**

Run:
```powershell
Select-String -Path "C:\Users\keyst\Business-Landing-Page\index.html" -Pattern "#1e40af|#1e3a8a|#2747c9|#eceef3|#f3f4f7|#e6e7ec|#d2d4dc|#202024|#1a1a1d|#2a2a2f|#242428|#f5c518|#e0a800|#ffd84d|#f5b800|#ececee|#c4c4c8|#9596a0|#16161a|#101013|#33333a"
```

Cross-reference each hit against line ranges:
- Lines 65–90: base `:root` block — expected and intentional (defaults that get overridden). LEAVE ALONE.
- Lines 1084–1108 (now Signal Cyan override): hits expected if any hex slipped in — already updated in Task 1.
- Anywhere else: STRAY. Fix it.

- [ ] **Step 2: For each stray hit (if any), replace with the appropriate token reference**

Map:
- `#16161a` or `#202024` (old dark bg) → `var(--bg-0)` or `var(--surface)` depending on context
- `#f5c518` / `#ffd84d` (yellow accent) → `var(--accent-1)`
- `#33333a` (old border) → `var(--border)`
- White-on-cyan failures (`color:#fff` paired with `var(--accent-1)` bg) → already handled for `.btn-primary`, `.nav-cta`, `.skip-link` in the override block. If a new selector falls into this trap, add a parallel `!important` override.

- [ ] **Step 3: Reload Chrome, walk the visual checklist one more time** (same checklist as Task 1 Step 4). Confirm nothing looks off.

- [ ] **Step 4: Commit (only if Step 2 made changes)**

```powershell
git -C C:\Users\keyst\Business-Landing-Page add index.html
git -C C:\Users\keyst\Business-Landing-Page commit -m "Fix stray light-mode hex literals missed by token swap"
```

If no changes were needed, skip the commit and proceed to Task 6.

---

## Task 6: Sync CLAUDE.md and project memory

**Goal:** Keep documentation aligned with reality. CLAUDE.md and the project-memory file both describe the theme — update both to reflect Signal Cyan as the live theme as of 2026-05-25.

**Files:**
- Modify: `C:\Users\keyst\CLAUDE.md` — Business Landing Page section, the theme paragraph
- Modify: `C:\Users\keyst\.claude\projects\C--Users-keyst\memory\project_business_landing_page.md` — same theme description

- [ ] **Step 1: Update the theme description in `CLAUDE.md`**

Find this paragraph (in the Business Landing Page section, the line starting with "**Theme (LIVE 2026-05-24): charcoal gray + yellow…**" if it still reads that way after the white+blue intermezzo, or whatever the current live-theme paragraph says):

> **Theme (LIVE …): charcoal gray + yellow, Apple-style layout.** Promoted from an exploration of brand design-system skills … (Yellow contrast handled deliberately: dark text on yellow CTAs …)

Replace it with a Signal Cyan equivalent. Sample (adapt to whatever phrasing is currently there):

> **Theme (LIVE 2026-05-25): Signal Cyan — near-black base + signal-cyan accent, Vercel/Linear-inflected "Sharp Operator" personality.** Promoted from a brainstormed comparison of three dark-base operator schemes (Operator Violet / Signal Cyan / Spark Lime); cyan picked for highest semantic fit with FP&A (canonical dashboard / chart-axis color in every finance tool) and brand-consistency with the agent-dashboard accent. CSS vars in the theme override block at lines 1084–1108 of `index.html`: `--bg-0 #0a0a0a`/`--bg-1 #101012`, `--surface #141416`/`--surface-2 #1c1c20`, `--text #fafafa`/`--text-dim #a3a3a3`/`--text-muted #737373`, cyan `--accent-1 #00b8ff`/`--accent-2 #0090d4`, `--grad-accent` cyan gradient; `--accent-glow 0,184,255`. CTA pattern: cyan bg + dark text (`#0a0a0a !important` on `.btn-primary`, `.nav-cta`, `.skip-link`) — white-on-cyan fails WCAG AA so dark-on-cyan is the only viable contrast direction. Ghost buttons get cyan border + cyan text + translucent cyan hover. `.section-tint` flips the relationship to *lift* (lighter surfaces inside tinted sections) since base is near-black. `.bg-mesh` is a single subtle cyan radial top-glow over a near-black-to-charcoal vertical gradient. Headshot has a CSS frame (`box-shadow: 0 0 0 1px var(--border), 0 0 0 6px var(--surface)`) to prevent halo. Previous themes (charcoal+yellow as of 2026-05-24, white+navy briefly, originally dark violet/teal) are retired.

Also update the OG card paragraph (currently says charcoal+yellow): swap to "cyan top band + cyan brand orb on near-black, `#fafafa` title text, `#00b8ff` subtitle accent — regenerate via `scripts/make-og.ps1`."

- [ ] **Step 2: Update the project memory file**

Read `C:\Users\keyst\.claude\projects\C--Users-keyst\memory\project_business_landing_page.md`. Replace any theme/color description with a condensed version of the Step 1 paragraph (memory entries are shorter than CLAUDE.md). Keep the `description:` frontmatter line accurate.

- [ ] **Step 3: Commit (CLAUDE.md only — memory file is outside the repo)**

```powershell
git -C C:\Users\keyst add CLAUDE.md
git -C C:\Users\keyst commit -m "Update Business Landing Page theme notes: Signal Cyan"
```

Note: `C:\Users\keyst` is the home directory git repo (different from the Business Landing Page repo). This commit lands there, not in `Business-Landing-Page/`.

---

## Task 7: Push canonical site and manual-deploy the sibling

**Goal:** Deploy the rethemed site to both Netlify properties. Canonical (`keystonemarcy.pages.dev`) auto-deploys via push; sibling (`keystonemarcykmconsulting`) needs the known manual workaround per CLAUDE.md.

**Files:** none modified — this is a deploy task.

- [ ] **Step 1: Confirm working tree is clean of unintended changes**

```powershell
git -C C:\Users\keyst\Business-Landing-Page status
```

Expected: clean working tree, or only the pre-existing in-progress bento-card edits (Aurora card, `proj-agent.webp`) and untracked `images/proj-aurora.webp` — none of these should be in our retheme commits; they were already in the working tree at start.

If retheme commits leaked them, STOP and clean up (`git reset HEAD~N` + re-commit with `git add -p`) before proceeding to deploy. Deploying half-merged work to the live site is a destructive mistake.

- [ ] **Step 2: Push to origin/main (canonical site auto-deploys)**

```powershell
git -C C:\Users\keyst\Business-Landing-Page push origin main
```

Wait ~60 seconds, then visit `https://keystonemarcy.pages.dev` and confirm the new theme is live.

- [ ] **Step 3: Move gitignored junk out of the repo dir for the manual sibling deploy**

`netlify deploy --dir .` uploads the entire directory regardless of `.gitignore`. Move pre-existing local junk out temporarily so it doesn't ship:

```powershell
$junk = @("preview-*.html", "*.db")
$temp = "C:\Users\keyst\Business-Landing-Page-junk-temp"
New-Item -ItemType Directory -Force -Path $temp | Out-Null
foreach ($pat in $junk) {
    Get-ChildItem -Path "C:\Users\keyst\Business-Landing-Page" -Filter $pat -File -ErrorAction SilentlyContinue | Move-Item -Destination $temp
}
Get-ChildItem $temp
```

The last `Get-ChildItem` lists what got moved. Record this list — you'll move them back in Step 5.

- [ ] **Step 4: Manual deploy to the sibling site**

```powershell
cd "C:\Users\keyst\Business-Landing-Page"
netlify deploy --prod --dir . --site 55407d90-c8c3-4948-a7e4-644aeba1860a
```

Watch for "Deploy URL" / "Website URL" lines in the output. Visit the second Netlify URL (the sibling — check Netlify dashboard if you don't have it memorized; CLAUDE.md doesn't record the public URL because the canonical is the one that matters). Confirm theme.

- [ ] **Step 5: Move junk back**

```powershell
Move-Item "C:\Users\keyst\Business-Landing-Page-junk-temp\*" "C:\Users\keyst\Business-Landing-Page\"
Remove-Item "C:\Users\keyst\Business-Landing-Page-junk-temp"
git -C C:\Users\keyst\Business-Landing-Page status
```

Confirm the working tree is back to the same state as the end of Step 1.

- [ ] **Step 6: Cross-check social preview**

Open https://www.linkedin.com/post-inspector/inspect/https%3A%2F%2Fkeystonemarcy.pages.dev in a browser, click "Inspect," and verify the new cyan OG card renders. If LinkedIn shows the old card, click "Inspect" again (it forces a re-fetch). Twitter Card Validator (`https://cards-dev.twitter.com/validator`) is a useful second check.

---

## Done

When all seven tasks above are checked off, the Signal Cyan retheme is live on both Netlify properties, contrast is verified, the OG card matches, docs are synced, and the working tree is clean of leftover artifacts.

If at any point a verification step fails and you're not sure how to recover, STOP and surface the issue rather than improvising — color choices have brand impact and a partially-deployed retheme is worse than no retheme.
