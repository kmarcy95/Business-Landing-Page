# Business Landing Page — UV-Inspired Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a hero headshot, editorial typography, social-proof strip, marquee skill ticker, stats band, About-section headshot, certifications row, and dual-email contact to the existing single-file business landing page — without rebuilding the bento Work grid.

**Architecture:** Everything is additive or in-place edits to one file (`index.html`). Tokens, fonts, and existing components are reused. One new PowerShell script generates the web-ready JPEGs from the user's local PNG library. Site stays single-file, no build step.

**Tech Stack:** Vanilla HTML, CSS (custom properties + container queries), vanilla JS (IntersectionObserver, already present). PowerShell 5.1 + `System.Drawing` for the resize step.

**Spec:** [`docs/superpowers/specs/2026-05-18-business-landing-uv-enhancements-design.md`](../specs/2026-05-18-business-landing-uv-enhancements-design.md)

---

## File Inventory

| File | Action | Purpose |
|------|--------|---------|
| `scripts/resize-headshots.ps1` | Create | Downsample 2048×2048 PNGs → 1024×1024 progressive JPEGs |
| `images/headshot-hero.jpg` | Create (script output) | Hero portrait (composed) |
| `images/headshot-about.jpg` | Create (script output) | About-section portrait (smiling) |
| `index.html` | Modify (CSS + HTML) | All structural changes |

`index.html` will be modified in 6 contained passes — one per visual unit — so each commit is reviewable on its own.

---

## Task 1: Resize script + generate web-ready headshots

**Files:**
- Create: `scripts/resize-headshots.ps1`
- Create (script output): `images/headshot-hero.jpg`
- Create (script output): `images/headshot-about.jpg`

- [ ] **Step 1: Create the scripts folder**

Run (PowerShell, from repo root `C:\Users\keyst\Business-Landing-Page`):

```powershell
if (-not (Test-Path scripts)) { New-Item -ItemType Directory -Path scripts | Out-Null }
```

Expected: silent success, `scripts/` exists.

- [ ] **Step 2: Write the resize script**

Create `scripts/resize-headshots.ps1` with this exact content:

```powershell
# Resize the two source headshots into web-ready 1024x1024 progressive JPEGs.
# Reads PNG originals from the user's local headshot library (outside this repo)
# and writes into images/ inside this repo. Idempotent.

Add-Type -AssemblyName System.Drawing

$SourceDir = 'C:\Users\keyst\headshots\linkedin'
$RepoRoot  = Split-Path -Parent $PSScriptRoot
$OutDir    = Join-Path $RepoRoot 'images'

$Jobs = @(
    @{
        Source = Join-Path $SourceDir '7ebe20d5-8480-4d66-be5e-52cdc04542e7.png'
        Dest   = Join-Path $OutDir 'headshot-hero.jpg'
    },
    @{
        Source = Join-Path $SourceDir '87214a06-e06e-41c7-9b28-500308fbe1d2.png'
        Dest   = Join-Path $OutDir 'headshot-about.jpg'
    }
)

function Convert-ToWebJpeg {
    param([string]$Source, [string]$Dest, [int]$Size = 1024, [int]$Quality = 82)

    if (-not (Test-Path $Source)) {
        Write-Error "Source missing: $Source"
        return
    }

    $img = [System.Drawing.Image]::FromFile($Source)
    try {
        $bmp = New-Object System.Drawing.Bitmap($Size, $Size)
        try {
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $g.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
            $g.DrawImage($img, 0, 0, $Size, $Size)
            $g.Dispose()

            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
                Where-Object { $_.MimeType -eq 'image/jpeg' }
            $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
                [System.Drawing.Imaging.Encoder]::Quality, [int64]$Quality)

            $bmp.Save($Dest, $jpegCodec, $params)
            $kb = [math]::Round((Get-Item $Dest).Length / 1KB, 1)
            Write-Host "[ok] $([System.IO.Path]::GetFileName($Dest))  $kb KB"
        } finally {
            $bmp.Dispose()
        }
    } finally {
        $img.Dispose()
    }
}

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }

foreach ($job in $Jobs) {
    Convert-ToWebJpeg -Source $job.Source -Dest $job.Dest
}
```

- [ ] **Step 3: Run the script**

Run (from repo root):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\resize-headshots.ps1
```

Expected output (file sizes will vary slightly):

```
[ok] headshot-hero.jpg   ~150 KB
[ok] headshot-about.jpg  ~130 KB
```

- [ ] **Step 4: Verify outputs**

Run:

```powershell
Get-ChildItem images\headshot-*.jpg | Select-Object Name, @{n='KB';e={[math]::Round($_.Length/1KB,1)}}
```

Expected: two rows, each `KB` value between 80 and 250. If either is >250 KB, drop quality to `75` in the script and rerun.

Visual sanity check: double-click each JPEG; both should be 1024×1024, in focus, framed correctly (head + shoulders, not cropped tight).

- [ ] **Step 5: Commit**

```powershell
git add scripts/resize-headshots.ps1 images/headshot-hero.jpg images/headshot-about.jpg
git commit -m "Add headshot resize script and generate web-ready JPEGs"
```

---

## Task 2: Hero — editorial split with headshot

**Files:**
- Modify: `index.html` (CSS in `<style>` block, HTML in `<section class="hero">`)

- [ ] **Step 1: Modify the `.hero-title` CSS rule**

In `index.html`, find the existing `.hero-title` rule (around line 182) and **replace** it with:

```css
  .hero-grid {
    display: grid;
    grid-template-columns: 1.2fr 1fr;
    gap: clamp(2rem, 4vw, 4rem);
    align-items: center;
  }
  .hero-title {
    font-size: clamp(2.8rem, 7vw, 5.6rem);
    font-weight: 700;
    letter-spacing: -0.04em;
    line-height: 0.95;
    margin-bottom: 1.5rem;
    max-width: none;
  }
  .hero-line { display: block; }
```

The existing `.hero-title .accent` rule (gradient text) stays as-is — it still works on a child span.

- [ ] **Step 2: Add the portrait CSS, immediately after the `.hero-line` rule**

```css
  .hero-portrait {
    position: relative;
    justify-self: end;
    max-width: 480px;
    width: 100%;
  }
  .hero-portrait::before {
    content: '';
    position: absolute;
    inset: -24px;
    border-radius: calc(var(--r-lg) + 24px);
    background: var(--grad-accent);
    opacity: 0.35;
    filter: blur(40px);
    z-index: -1;
    pointer-events: none;
  }
  .hero-portrait img {
    width: 100%;
    aspect-ratio: 1 / 1;
    object-fit: cover;
    border-radius: var(--r-lg);
    border: 1px solid var(--border-strong);
    display: block;
  }
  @media (max-width: 800px) {
    .hero-grid {
      grid-template-columns: 1fr;
      gap: 2rem;
    }
    .hero-portrait {
      max-width: 280px;
      justify-self: center;
      order: -1;
    }
    .hero-title {
      font-size: clamp(2.4rem, 9vw, 3.4rem);
    }
  }
```

- [ ] **Step 3: Restructure the hero HTML**

Replace the entire `<section class="section hero container reveal" id="top"> … </section>` block (around lines 511–528) with:

```html
    <section class="section hero container reveal" id="top">
      <div class="hero-grid">
        <div class="hero-text">
          <span class="hero-eyebrow">Available for select consulting work</span>
          <h1 class="hero-title">
            <span class="hero-line">ERP</span>
            <span class="hero-line">consultant</span>
            <span class="hero-line">turned</span>
            <span class="hero-line accent">builder.</span>
          </h1>
          <p class="hero-sub">
            Apps, AI workflows, and Excel add-ins for the way finance &amp; ops teams actually work.
            I ship the tooling your spreadsheets and processes have been waiting for.
          </p>
          <div class="hero-ctas">
            <a class="btn btn-primary" href="#work">
              See my work <span class="btn-arrow" aria-hidden="true">&rarr;</span>
            </a>
            <a class="btn btn-ghost" href="#contact">
              Get in touch
            </a>
          </div>
        </div>
        <div class="hero-portrait">
          <img src="images/headshot-hero.jpg" alt="Keystone Marcy — portrait" width="1024" height="1024" loading="eager" fetchpriority="high" />
        </div>
      </div>
    </section>
```

- [ ] **Step 4: Verify in browser**

Run (from repo root):

```powershell
npx -y serve .
```

Open `http://localhost:3000` (port may differ — read the console output). Confirm:
- Headshot loads on the right, square with a soft violet/teal glow behind it.
- Headline stacks as 4 lines, "builder." is gradient.
- Resize browser to ≤800 px wide → headshot stacks above headline, scaled to ~280 px.
- CTA buttons still work and animate on hover.

Kill the server with `Ctrl+C` when done.

- [ ] **Step 5: Commit**

```powershell
git add index.html
git commit -m "Redesign hero with editorial split and headshot"
```

---

## Task 3: Social-proof strip

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add the social-proof CSS**

In `index.html`, find the end of the existing `/* ============ HERO ============ */` block (just before `/* ============ SECTION HEADING ============ */`) and **insert** this new block:

```css
  /* ============ SOCIAL PROOF ============ */
  .uv-social-proof {
    text-align: center;
    padding-block: clamp(1.5rem, 3vw, 2.5rem);
    border-top: 1px solid var(--border);
    border-bottom: 1px solid var(--border);
  }
  .uv-social-proof-label {
    font-family: var(--font-mono);
    font-size: 0.75rem;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: var(--text-muted);
    margin-bottom: 0.75rem;
  }
  .uv-social-proof-list {
    font-family: var(--font-display);
    font-weight: 600;
    color: var(--text-dim);
    font-size: clamp(1rem, 2vw, 1.4rem);
    letter-spacing: 0.04em;
  }
  .uv-social-proof-list .sep {
    color: var(--text-muted);
    margin: 0 0.6em;
    opacity: 0.6;
  }
```

- [ ] **Step 2: Insert the social-proof HTML immediately after the hero section closing tag**

Find `</section>` of the hero (the one before `<section class="section container" id="work">`) and insert this between them:

```html
    <section class="uv-social-proof container reveal" aria-label="Past employers">
      <p class="uv-social-proof-label">Trusted by teams at</p>
      <p class="uv-social-proof-list">
        Lancer Worldwide <span class="sep">·</span>
        H-E-B <span class="sep">·</span>
        Alliance Bernstein
      </p>
    </section>
```

- [ ] **Step 3: Verify in browser**

```powershell
npx -y serve .
```

Confirm: a thin bordered band sits between hero and Work grid. Eyebrow is mono uppercase, brand line is `Space Grotesk` semibold dim, dots are muted.

- [ ] **Step 4: Commit**

```powershell
git add index.html
git commit -m "Add social-proof strip below hero"
```

---

## Task 4: Marquee skill ticker

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add the marquee CSS**

Insert this block immediately after the `/* ============ SOCIAL PROOF ============ */` block:

```css
  /* ============ MARQUEE ============ */
  .uv-marquee {
    overflow: hidden;
    padding-block: clamp(1.5rem, 3vw, 2.5rem);
    -webkit-mask-image: linear-gradient(90deg, transparent 0%, black 8%, black 92%, transparent 100%);
            mask-image: linear-gradient(90deg, transparent 0%, black 8%, black 92%, transparent 100%);
  }
  .uv-marquee-row {
    display: flex;
    gap: 1rem;
    width: max-content;
    animation: uv-marquee-scroll linear infinite;
    will-change: transform;
  }
  .uv-marquee-row.row-1 { animation-duration: 40s; }
  .uv-marquee-row.row-2 {
    animation-duration: 55s;
    margin-top: 1rem;
    animation-direction: reverse;
  }
  .uv-marquee:hover .uv-marquee-row {
    animation-play-state: paused;
  }
  .uv-marquee-item {
    flex: none;
    padding: 0.5rem 1rem;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--r-sm);
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--text-dim);
    white-space: nowrap;
  }
  @keyframes uv-marquee-scroll {
    from { transform: translateX(0); }
    to   { transform: translateX(-50%); }
  }
  @media (prefers-reduced-motion: reduce) {
    .uv-marquee {
      -webkit-mask-image: none;
              mask-image: none;
    }
    .uv-marquee-row {
      animation: none;
      flex-wrap: wrap;
      justify-content: center;
      width: 100%;
    }
  }
```

- [ ] **Step 2: Insert the marquee HTML after the social-proof section**

The item lists are **duplicated inline** — that's what makes the `translateX(-50%)` loop seamless. Both halves must be identical.

```html
    <section class="uv-marquee reveal" aria-label="Skills and tools">
      <div class="uv-marquee-row row-1">
        <span class="uv-marquee-item">D365 Finance &amp; Ops</span>
        <span class="uv-marquee-item">Excel VBA</span>
        <span class="uv-marquee-item">Power Query</span>
        <span class="uv-marquee-item">NetSuite</span>
        <span class="uv-marquee-item">Prophix</span>
        <span class="uv-marquee-item">Hyperion</span>
        <span class="uv-marquee-item">MicroStrategy</span>
        <span class="uv-marquee-item">SharePoint</span>
        <span class="uv-marquee-item" aria-hidden="true">D365 Finance &amp; Ops</span>
        <span class="uv-marquee-item" aria-hidden="true">Excel VBA</span>
        <span class="uv-marquee-item" aria-hidden="true">Power Query</span>
        <span class="uv-marquee-item" aria-hidden="true">NetSuite</span>
        <span class="uv-marquee-item" aria-hidden="true">Prophix</span>
        <span class="uv-marquee-item" aria-hidden="true">Hyperion</span>
        <span class="uv-marquee-item" aria-hidden="true">MicroStrategy</span>
        <span class="uv-marquee-item" aria-hidden="true">SharePoint</span>
      </div>
      <div class="uv-marquee-row row-2">
        <span class="uv-marquee-item">CrewAI</span>
        <span class="uv-marquee-item">Next.js</span>
        <span class="uv-marquee-item">FastAPI</span>
        <span class="uv-marquee-item">Blazor</span>
        <span class="uv-marquee-item">.NET 8</span>
        <span class="uv-marquee-item">Python</span>
        <span class="uv-marquee-item">XGBoost</span>
        <span class="uv-marquee-item">scikit-learn</span>
        <span class="uv-marquee-item">Playwright</span>
        <span class="uv-marquee-item" aria-hidden="true">CrewAI</span>
        <span class="uv-marquee-item" aria-hidden="true">Next.js</span>
        <span class="uv-marquee-item" aria-hidden="true">FastAPI</span>
        <span class="uv-marquee-item" aria-hidden="true">Blazor</span>
        <span class="uv-marquee-item" aria-hidden="true">.NET 8</span>
        <span class="uv-marquee-item" aria-hidden="true">Python</span>
        <span class="uv-marquee-item" aria-hidden="true">XGBoost</span>
        <span class="uv-marquee-item" aria-hidden="true">scikit-learn</span>
        <span class="uv-marquee-item" aria-hidden="true">Playwright</span>
      </div>
    </section>
```

- [ ] **Step 3: Verify in browser**

```powershell
npx -y serve .
```

Confirm:
- Two rows scroll horizontally — top row left-to-right, bottom row right-to-left.
- Hovering anywhere on the marquee pauses both rows.
- Edges fade to background (no hard cutoff).
- DevTools → Rendering tab → check "Emulate CSS media feature prefers-reduced-motion" → "reduce": rows become a centered static wrap of pills, no scrolling.

- [ ] **Step 4: Commit**

```powershell
git add index.html
git commit -m "Add scrolling marquee skill ticker"
```

---

## Task 5: Stats / credentials band

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add the stats CSS**

Insert this block immediately after the `/* ============ MARQUEE ============ */` block:

```css
  /* ============ STATS BAND ============ */
  .uv-stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: clamp(1rem, 3vw, 2rem);
    padding-block: clamp(2rem, 5vw, 4rem);
  }
  .uv-stat {
    display: flex;
    flex-direction: column;
    gap: 0.6rem;
  }
  .uv-stat-number {
    font-family: var(--font-display);
    font-weight: 700;
    font-size: clamp(2.6rem, 5vw, 4.2rem);
    letter-spacing: -0.03em;
    line-height: 1;
    background: var(--grad-accent);
    -webkit-background-clip: text;
            background-clip: text;
    -webkit-text-fill-color: transparent;
    color: transparent;
  }
  .uv-stat-label {
    font-family: var(--font-mono);
    text-transform: uppercase;
    letter-spacing: 0.15em;
    color: var(--text-muted);
    font-size: 0.72rem;
    line-height: 1.4;
  }
  @media (max-width: 800px) {
    .uv-stats { grid-template-columns: repeat(2, 1fr); }
  }
  @media (max-width: 480px) {
    .uv-stats { grid-template-columns: 1fr; }
  }
```

- [ ] **Step 2: Insert the stats band HTML between `#work` and `#services`**

Find the closing `</section>` of `<section class="section container" id="work">` and insert this immediately after it (before `<section class="section container" id="services">`):

```html
    <section class="uv-stats container reveal" aria-label="By the numbers">
      <div class="uv-stat">
        <div class="uv-stat-number">7 yrs</div>
        <div class="uv-stat-label">Finance + Accounting</div>
      </div>
      <div class="uv-stat">
        <div class="uv-stat-number">2</div>
        <div class="uv-stat-label">ERP Implementations</div>
      </div>
      <div class="uv-stat">
        <div class="uv-stat-number">$1.5M</div>
        <div class="uv-stat-label">Inventory Managed</div>
      </div>
      <div class="uv-stat">
        <div class="uv-stat-number">92%</div>
        <div class="uv-stat-label">Loss Reduction</div>
      </div>
    </section>
```

- [ ] **Step 3: Verify in browser**

```powershell
npx -y serve .
```

Confirm:
- 4 columns at ≥800 px width: each shows an oversized gradient number with a mono uppercase label underneath.
- 2 columns at 480–800 px.
- 1 column ≤480 px.

- [ ] **Step 4: Commit**

```powershell
git add index.html
git commit -m "Add stats band with hard credibility numbers"
```

---

## Task 6: About section — headshot + certifications

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Add the about-aside / certs CSS**

Find the existing `/* ============ ABOUT ============ */` block. After the existing `.skills-card` rule and before the `@media (max-width: 800px)` query for `.about`, **insert**:

```css
  .about-aside {
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
  }
  .about-headshot {
    width: 100%;
    max-width: 280px;
    aspect-ratio: 1 / 1;
    object-fit: cover;
    border-radius: var(--r-md);
    border: 1px solid var(--border-strong);
    align-self: flex-start;
    display: block;
  }
  .certs {
    padding: 1.25rem;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--r-md);
  }
  .certs h3 {
    font-size: 0.85rem;
    text-transform: uppercase;
    letter-spacing: 0.12em;
    color: var(--text-muted);
    margin-bottom: 0.9rem;
    font-family: var(--font-mono);
    font-weight: 500;
  }
  .cert-list {
    display: flex;
    flex-wrap: wrap;
    gap: 0.4rem;
  }
  .cert {
    padding: 0.35rem 0.7rem;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--r-sm);
    font-size: 0.78rem;
    font-weight: 500;
    color: var(--text-dim);
  }
```

Then **append** to the existing `@media (max-width: 800px)` block for `.about` (so the about responsive group becomes):

```css
  @media (max-width: 800px) {
    .about { grid-template-columns: 1fr; gap: 2rem; }
    .about-headshot { max-width: 220px; align-self: center; }
  }
```

- [ ] **Step 2: Restructure the about right column HTML**

Find the existing `<aside class="skills-card" aria-label="Core skills"> … </aside>` block inside `#about`. Replace that single `<aside>` with this `<aside class="about-aside">` wrapper that contains the headshot, the existing skills card, and the new certifications card:

```html
        <aside class="about-aside" aria-label="Headshot, core skills, and credentials">
          <img class="about-headshot" src="images/headshot-about.jpg" alt="Keystone Marcy" width="1024" height="1024" loading="lazy" />
          <div class="skills-card">
            <h3>Core skills</h3>
            <div class="skill-list">
              <span class="skill">D365 Finance &amp; Ops</span>
              <span class="skill">AI / Agents</span>
              <span class="skill">Excel automation</span>
              <span class="skill">Full-stack</span>
            </div>
          </div>
          <div class="certs">
            <h3>Certifications &amp; Education</h3>
            <div class="cert-list">
              <span class="cert">AMA&reg;</span>
              <span class="cert">ChFM&reg;</span>
              <span class="cert">GAFM Advisor</span>
              <span class="cert">MA Economics &mdash; UTSA (Fall 2026)</span>
              <span class="cert">BS Finance &mdash; Evansville</span>
            </div>
          </div>
        </aside>
```

The `.skills-card` styling is reused — only the wrapper changes. `aria-label` moved from `.skills-card` to `.about-aside`.

- [ ] **Step 3: Verify in browser**

```powershell
npx -y serve .
```

Confirm:
- About section right column now stacks: smiling headshot at top (~280 px square), then existing skills card, then certifications card.
- All 5 certification badges visible and wrap on smaller screens.
- ≤800 px: column collapses to single, headshot centers at 220 px max.

- [ ] **Step 4: Commit**

```powershell
git add index.html
git commit -m "Add About-section headshot and certifications row"
```

---

## Task 7: Contact — dual-email CTAs

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Update the contact CTAs**

Find the existing `<div class="contact-ctas"> … </div>` block. The current first link reads:

```html
        <a class="btn btn-primary" href="mailto:kmarcy@KMConsulting995.onmicrosoft.com?subject=Hello%20Keystone">
          Email Keystone <span class="btn-arrow" aria-hidden="true">&rarr;</span>
        </a>
```

Replace the `contact-ctas` div with:

```html
      <div class="contact-ctas">
        <a class="btn btn-primary" href="mailto:kmarcy@KMConsulting995.onmicrosoft.com?subject=Hello%20Keystone">
          Email Keystone (business) <span class="btn-arrow" aria-hidden="true">&rarr;</span>
        </a>
        <a class="btn btn-ghost" href="mailto:keystone.marcy@outlook.com?subject=Hello%20Keystone">
          Personal email
        </a>
        <a class="icon-btn" href="https://github.com/kmarcy95" target="_blank" rel="noopener" aria-label="GitHub">
          <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .5C5.65.5.5 5.66.5 12.04c0 5.1 3.29 9.42 7.86 10.95.58.11.79-.25.79-.56 0-.27-.01-1-.02-1.97-3.2.7-3.87-1.54-3.87-1.54-.52-1.34-1.28-1.7-1.28-1.7-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.2 1.77 1.2 1.03 1.78 2.7 1.27 3.36.97.1-.75.4-1.27.73-1.56-2.55-.29-5.24-1.29-5.24-5.74 0-1.27.45-2.31 1.18-3.12-.12-.3-.51-1.49.11-3.1 0 0 .97-.31 3.18 1.19a11 11 0 0 1 5.79 0c2.21-1.5 3.18-1.19 3.18-1.19.62 1.61.23 2.8.11 3.1.73.81 1.18 1.85 1.18 3.12 0 4.46-2.69 5.44-5.25 5.73.41.36.78 1.06.78 2.14 0 1.54-.01 2.78-.01 3.16 0 .31.21.68.8.56C20.22 21.46 23.5 17.13 23.5 12.04 23.5 5.66 18.35.5 12 .5z"/></svg>
        </a>
        <a class="icon-btn" href="https://www.linkedin.com/in/" target="_blank" rel="noopener" aria-label="LinkedIn">
          <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.86-3.04-1.86 0-2.14 1.45-2.14 2.95v5.66H9.36V9h3.4v1.56h.05c.47-.9 1.63-1.86 3.36-1.86 3.59 0 4.25 2.36 4.25 5.43v6.32zM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13zM7.12 20.45H3.56V9h3.56v11.45zM22.22 0H1.77C.79 0 0 .78 0 1.73v20.54C0 23.22.79 24 1.77 24h20.45c.98 0 1.78-.78 1.78-1.73V1.73C24 .78 23.2 0 22.22 0z"/></svg>
        </a>
      </div>
```

Only changes vs. current: the primary button text gets `" (business)"` appended, and a new `.btn-ghost` "Personal email" button is added between the primary CTA and the GitHub icon. SVG paths for GitHub and LinkedIn are unchanged.

- [ ] **Step 2: Verify in browser**

```powershell
npx -y serve .
```

Click both email buttons → confirm `mailto:` opens with the correct address and subject. On mobile width, the four buttons wrap reasonably (existing `flex-wrap` on `.contact-ctas` handles this).

- [ ] **Step 3: Commit**

```powershell
git add index.html
git commit -m "Add personal-email ghost button alongside business email"
```

---

## Task 8: Final QA — Lighthouse, reduced motion, mobile sweep

**Files:**
- Verify only (no edits expected; if any are needed, commit at end)

- [ ] **Step 1: Run Lighthouse**

```powershell
npx -y serve .
```

In a separate terminal, with the server running:

```powershell
npx -y lighthouse http://localhost:3000 --output html --output-path lighthouse-report.report.html --quiet --chrome-flags="--headless"
```

Open `lighthouse-report.report.html`. Confirm:
- Performance ≥ 85
- Accessibility ≥ 95
- Best Practices ≥ 90
- SEO ≥ 90

If Performance dips below 85, the most likely culprit is the hero JPEG — rerun the resize script with `-Quality 75` (line 23 of the script, change `[int]$Quality = 82` to `75`), then redo Task 1 step 3 to regenerate. Don't commit the quality change unless it's needed.

- [ ] **Step 2: Reduced-motion check**

In Chrome DevTools → ⋮ → More tools → Rendering → "Emulate CSS media feature prefers-reduced-motion" → "reduce". Reload page. Confirm:
- Marquee rows render as a static centered wrap (no horizontal motion).
- `.reveal` elements appear instantly with no fade-up.
- Hero button magnetic-hover does nothing (the existing JS already early-returns on reduced motion).

- [ ] **Step 3: Mobile viewport check**

DevTools → device toolbar → test at:
- iPhone SE (375×667)
- iPhone 14 Pro (393×852)
- iPad (768×1024)

For each: confirm hero stacks correctly, headshot doesn't overflow, marquee scrolls without horizontal page scroll, stats band reflows, About headshot centers, contact buttons wrap.

- [ ] **Step 4: Keyboard nav check**

Tab from the top of the page. Focus order should be:
1. Skip-link → 2. Brand link → 3-5. Nav links → 6. Contact nav CTA → 7. Hero "See my work" → 8. Hero "Get in touch" → 9-13. Bento cards → 14. Email business → 15. Personal email → 16. GitHub → 17. LinkedIn.

All focused elements should show a violet outline.

- [ ] **Step 5: Commit any QA fixes (if needed)**

If Lighthouse forced a quality change or any visual bug was caught:

```powershell
git add <changed files>
git commit -m "QA pass: <one-line description of fix>"
```

If nothing needed fixing, skip this step.

- [ ] **Step 6: Push and deploy**

```powershell
git push origin main
```

Netlify auto-deploys from main; watch the dashboard or:

```powershell
netlify deploy --prod --dir .
```

Open `https://keystonemarcy.netlify.app/` in an incognito window and walk the page one more time on the live deploy.

---

## Self-Review (post-write)

**Spec coverage:** Every spec section maps to a task — hero (T2), social-proof (T3), marquee (T4), stats (T5), about + certs (T6), contact dual email (T7), asset resize script (T1), QA + Lighthouse + reduced-motion + mobile (T8). No spec section is unaddressed.

**Placeholder scan:** No `TBD`, `TODO`, "fill in later", or "similar to above" — every code block is the literal content to paste.

**Type/name consistency:** CSS class names used in HTML steps match class names defined in their CSS steps:
- `.hero-grid`, `.hero-line`, `.hero-portrait` (T2)
- `.uv-social-proof`, `.uv-social-proof-label`, `.uv-social-proof-list`, `.sep` (T3)
- `.uv-marquee`, `.uv-marquee-row`, `.uv-marquee-item`, `.row-1`, `.row-2`, keyframe `uv-marquee-scroll` (T4)
- `.uv-stats`, `.uv-stat`, `.uv-stat-number`, `.uv-stat-label` (T5)
- `.about-aside`, `.about-headshot`, `.certs`, `.cert-list`, `.cert` (T6)

Filenames and source paths: `headshot-hero.jpg` / `headshot-about.jpg` are referenced in T1 (generated) and T2/T6 (consumed) with identical paths. Source PNG UUIDs in T1 match the spec exactly.

No gaps found.
