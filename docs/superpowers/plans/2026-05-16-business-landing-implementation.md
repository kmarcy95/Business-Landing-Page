# Business Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `index.html` for the Keystone Marcy / KM Consulting hybrid landing page, deployed to Netlify, matching the approved design spec at [docs/superpowers/specs/2026-05-16-business-landing-design.md](../specs/2026-05-16-business-landing-design.md).

**Architecture:** Single-file vanilla HTML/CSS/JS — no build step, no framework, no JS dependencies. Google Fonts via `<link>`. Dark theme, violet→teal accent gradient. Bento-grid layout with 5 featured project cards. Hosted on Netlify with auto-deploy from a new GitHub repo (`kmarcy95/Business-Landing-Page`).

**Tech Stack:** HTML5, CSS3 (Grid + custom properties), vanilla JS (~30 lines: IntersectionObserver for scroll-in, magnetic hover for hero CTAs). Google Fonts: Inter + Space Grotesk. Netlify hosting (no build, publish dir `.`).

**Verification model:** This is a static landing page — there is no test framework. Each task ends with a *manual verification step* (open `index.html` in a browser, confirm specific behavior). Final task runs a Lighthouse audit and an axe-core accessibility scan via `npx` (no install).

---

## File Structure

```
Business-Landing-Page/
├── index.html              # everything: HTML, CSS, JS inline (single file)
├── netlify.toml            # publish dir = "." (no build)
├── images/
│   ├── og.svg              # 1200×630 OG image
│   └── favicon.svg         # gradient orb favicon (inline data: URI also works; standalone for clarity)
├── README.md               # exists — short blurb
├── .gitignore              # exists
└── docs/
    └── superpowers/
        ├── specs/2026-05-16-business-landing-design.md  # exists
        └── plans/2026-05-16-business-landing-implementation.md  # this file
```

`index.html` ends up around 600–800 lines (HTML + inline `<style>` + inline `<script>`). It stays one file because it's small, atomic, and matches the user's other single-file projects.

---

## Task 1: Scaffold index.html + netlify.toml

**Files:**
- Create: `index.html`
- Create: `netlify.toml`

- [ ] **Step 1: Create `netlify.toml`**

```toml
[build]
  publish = "."

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
```

- [ ] **Step 2: Create the `index.html` skeleton with meta tags, Google Fonts, and empty body**

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <meta name="theme-color" content="#0a0a12" />
  <meta name="description" content="Keystone Marcy — ERP consultant turned builder. Apps, AI workflows, and Excel add-ins for the way finance & ops teams actually work." />
  <meta name="author" content="Keystone Marcy" />

  <!-- Open Graph -->
  <meta property="og:type" content="website" />
  <meta property="og:title" content="Keystone Marcy — KM Consulting" />
  <meta property="og:description" content="ERP consultant turned builder. Apps, AI workflows, and Excel add-ins." />
  <meta property="og:image" content="images/og.svg" />

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Keystone Marcy — KM Consulting" />
  <meta name="twitter:description" content="ERP consultant turned builder. Apps, AI workflows, and Excel add-ins." />
  <meta name="twitter:image" content="images/og.svg" />

  <title>Keystone Marcy — KM Consulting</title>

  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0' y1='0' x2='1' y2='1'%3E%3Cstop offset='0' stop-color='%237c5cff'/%3E%3Cstop offset='1' stop-color='%235eead4'/%3E%3C/linearGradient%3E%3C/defs%3E%3Ccircle cx='32' cy='32' r='28' fill='url(%23g)'/%3E%3C/svg%3E" />

  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;600;700&display=swap" rel="stylesheet" />

  <style>
    /* tokens, reset, and components will go here in Task 2+ */
  </style>
</head>
<body>
  <!-- nav goes here in Task 3 -->
  <!-- hero goes here in Task 4 -->
  <!-- bento grid goes here in Tasks 5-8 -->
  <!-- services strip goes here in Task 9 -->
  <!-- about goes here in Task 10 -->
  <!-- contact + footer go here in Task 11 -->

  <script>
    /* motion will go here in Task 12 */
  </script>
</body>
</html>
```

- [ ] **Step 3: Verify the skeleton loads**

Open `C:\Users\keyst\Business-Landing-Page\index.html` in a browser.
Expected: blank page (`#000` because no styles yet), title bar shows "Keystone Marcy — KM Consulting", no console errors.

- [ ] **Step 4: Commit**

```bash
cd /c/Users/keyst/Business-Landing-Page
git add index.html netlify.toml
git commit -m "Scaffold index.html and netlify.toml"
```

---

## Task 2: Design tokens, reset, base styles, ambient background

**Files:**
- Modify: `index.html` — replace the empty `<style>` block

- [ ] **Step 1: Add tokens + reset + body + ambient background to `<style>`**

Replace the `<style>` block from Task 1 with:

```html
<style>
  /* ============ TOKENS ============ */
  :root {
    /* surface */
    --bg-0: #0a0a12;
    --bg-1: #0f0e1a;
    --surface: rgba(255,255,255,0.04);
    --surface-2: rgba(255,255,255,0.06);
    --border: rgba(255,255,255,0.08);
    --border-strong: rgba(255,255,255,0.16);

    /* ink */
    --text: #f7f7ff;
    --text-dim: #c5c5d5;
    --text-muted: #9999b0;

    /* accent */
    --accent-1: #7c5cff;
    --accent-2: #5eead4;
    --grad-accent: linear-gradient(135deg, #7c5cff 0%, #5eead4 100%);
    --accent-glow: 124, 92, 255;

    /* radii */
    --r-sm: 0.5rem;
    --r-md: 0.9rem;
    --r-lg: 1.4rem;

    /* fonts */
    --font-display: 'Space Grotesk', system-ui, sans-serif;
    --font-body: 'Inter', system-ui, -apple-system, 'Segoe UI', sans-serif;
    --font-mono: ui-monospace, 'SF Mono', Consolas, monospace;

    /* layout */
    --container: 1200px;
  }

  /* ============ RESET ============ */
  *, *::before, *::after { box-sizing: border-box; }
  html { scroll-behavior: smooth; -webkit-text-size-adjust: 100%; }
  body {
    margin: 0;
    font-family: var(--font-body);
    background: var(--bg-0);
    color: var(--text);
    line-height: 1.55;
    font-size: 16px;
    overflow-x: hidden;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }
  img, svg { display: block; max-width: 100%; }
  a { color: inherit; text-decoration: none; }
  button { font-family: inherit; cursor: pointer; border: 0; background: none; color: inherit; }
  h1, h2, h3, h4 { font-family: var(--font-display); letter-spacing: -0.02em; line-height: 1.1; margin: 0; }
  p { margin: 0; }

  /* ============ AMBIENT BACKGROUND ============ */
  .bg-mesh {
    position: fixed; inset: 0; z-index: -2; pointer-events: none;
    background:
      radial-gradient(900px 600px at 12% 10%, rgba(124,92,255,.22), transparent 60%),
      radial-gradient(700px 500px at 88% 0%, rgba(94,234,212,.14), transparent 60%),
      radial-gradient(800px 600px at 50% 100%, rgba(124,92,255,.10), transparent 60%),
      linear-gradient(180deg, var(--bg-0) 0%, var(--bg-1) 100%);
  }
  .bg-grain {
    position: fixed; inset: 0; z-index: -1; pointer-events: none; opacity: .04;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='200' height='200'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='2'/></filter><rect width='100%25' height='100%25' filter='url(%23n)'/></svg>");
  }

  /* ============ LAYOUT ============ */
  .container { max-width: var(--container); margin-inline: auto; padding-inline: clamp(1rem, 3vw, 2rem); }
  .section { padding-block: clamp(3rem, 8vw, 6rem); }

  /* ============ A11Y ============ */
  :focus-visible { outline: 2px solid var(--accent-1); outline-offset: 3px; border-radius: 4px; }
  .skip-link {
    position: absolute; top: -40px; left: 8px;
    background: var(--accent-1); color: #fff; padding: .5rem .9rem;
    border-radius: var(--r-sm); z-index: 100; font-weight: 600;
  }
  .skip-link:focus { top: 8px; }

  /* ============ REDUCED MOTION ============ */
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
      animation-duration: 0.001ms !important;
      animation-iteration-count: 1 !important;
      transition-duration: 0.001ms !important;
      scroll-behavior: auto !important;
    }
  }
</style>
```

- [ ] **Step 2: Add the ambient background divs and skip-link as the first elements in `<body>`**

Replace the first comment in `<body>` so the body now starts:

```html
<body>
  <a class="skip-link" href="#main">Skip to main content</a>
  <div class="bg-mesh" aria-hidden="true"></div>
  <div class="bg-grain" aria-hidden="true"></div>

  <!-- nav goes here in Task 3 -->
  <!-- hero goes here in Task 4 -->
  <!-- ... -->
```

- [ ] **Step 3: Verify the background**

Refresh `index.html` in the browser.
Expected: page background is near-black with subtle violet/teal radial glows in the corners, very subtle grain texture overlay. No content yet but the page should feel atmospheric.

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add design tokens, reset, and ambient background"
```

---

## Task 3: Sticky nav

**Files:**
- Modify: `index.html` — add nav CSS to `<style>`, add nav HTML to `<body>`

- [ ] **Step 1: Append nav CSS to the `<style>` block (after `/* ============ REDUCED MOTION ============ */` section)**

```css
/* ============ NAV ============ */
.nav {
  position: sticky; top: 0; z-index: 50;
  backdrop-filter: blur(12px);
  background: rgba(10,10,18,0.72);
  border-bottom: 1px solid var(--border);
}
.nav-inner {
  display: flex; align-items: center; justify-content: space-between;
  height: 64px;
}
.brand {
  display: flex; align-items: center; gap: .55rem;
  font-family: var(--font-display); font-weight: 700; font-size: 1.05rem;
}
.brand-orb {
  width: 22px; height: 22px; border-radius: 50%;
  background: var(--grad-accent);
  box-shadow: 0 0 18px rgba(var(--accent-glow), 0.55);
}
.nav-links {
  display: flex; align-items: center; gap: 1.5rem;
  list-style: none; padding: 0; margin: 0;
}
.nav-links a {
  font-size: .9rem; color: var(--text-dim); font-weight: 500;
  transition: color .15s ease;
}
.nav-links a:hover { color: var(--text); }
.nav-cta {
  padding: .5rem .9rem; border-radius: var(--r-sm);
  background: var(--surface-2); border: 1px solid var(--border);
  font-size: .85rem; font-weight: 600; color: var(--text) !important;
  transition: background .15s ease, border-color .15s ease;
}
.nav-cta:hover { background: var(--surface); border-color: var(--border-strong); }

@media (max-width: 640px) {
  .nav-links li:not(:last-child) { display: none; }
}
```

- [ ] **Step 2: Add the nav HTML right after the `bg-grain` div in `<body>`**

```html
<header class="nav" role="banner">
  <nav class="container nav-inner" aria-label="Primary">
    <a class="brand" href="#top" aria-label="Keystone Marcy — home">
      <span class="brand-orb" aria-hidden="true"></span>
      <span>KM Consulting</span>
    </a>
    <ul class="nav-links">
      <li><a href="#work">Work</a></li>
      <li><a href="#services">Services</a></li>
      <li><a href="#about">About</a></li>
      <li><a class="nav-cta" href="#contact">Contact</a></li>
    </ul>
  </nav>
</header>
```

- [ ] **Step 3: Verify the nav**

Refresh. Expected:
- Nav bar at the top with "KM Consulting" + gradient orb on the left, four links on the right
- Nav stays pinned when scrolling (test by scrolling — nothing below it yet so just confirm it doesn't move when window is resized)
- At < 640px width, only the Contact button is visible
- Hovering Contact slightly lightens its background
- Tab key cycles focus through the four links with a visible focus ring

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add sticky nav with brand orb and primary links"
```

---

## Task 4: Hero section

**Files:**
- Modify: `index.html` — append hero CSS and HTML

- [ ] **Step 1: Append hero CSS to `<style>`**

```css
/* ============ HERO ============ */
.hero {
  padding-block: clamp(4rem, 10vw, 8rem) clamp(3rem, 6vw, 5rem);
}
.hero-eyebrow {
  display: inline-flex; align-items: center; gap: .5rem;
  padding: .35rem .75rem;
  border-radius: 999px;
  background: var(--surface);
  border: 1px solid var(--border);
  font-size: .8rem; color: var(--text-dim);
  margin-bottom: 1.5rem;
}
.hero-eyebrow::before {
  content: ''; width: 6px; height: 6px; border-radius: 50%;
  background: var(--accent-2); box-shadow: 0 0 8px var(--accent-2);
}
.hero-title {
  font-size: clamp(2.4rem, 6vw, 4.4rem);
  font-weight: 700;
  letter-spacing: -0.035em;
  max-width: 18ch;
  margin-bottom: 1.25rem;
}
.hero-title .accent {
  background: var(--grad-accent);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  color: transparent;
}
.hero-sub {
  font-size: clamp(1rem, 1.6vw, 1.15rem);
  color: var(--text-dim);
  max-width: 60ch;
  margin-bottom: 2.25rem;
}
.hero-ctas { display: flex; flex-wrap: wrap; gap: .75rem; }
.btn {
  display: inline-flex; align-items: center; justify-content: center; gap: .5rem;
  padding: .85rem 1.4rem;
  border-radius: var(--r-md);
  font-size: .95rem; font-weight: 600;
  transition: transform .15s ease, box-shadow .2s ease, background .15s ease;
  will-change: transform;
}
.btn-primary {
  background: var(--grad-accent);
  color: #0a0a12;
  box-shadow: 0 8px 30px -8px rgba(var(--accent-glow), 0.6);
}
.btn-primary:hover {
  box-shadow: 0 12px 40px -8px rgba(var(--accent-glow), 0.85);
}
.btn-ghost {
  background: var(--surface);
  border: 1px solid var(--border);
  color: var(--text);
}
.btn-ghost:hover { background: var(--surface-2); border-color: var(--border-strong); }
.btn-arrow { transition: transform .15s ease; }
.btn:hover .btn-arrow { transform: translateX(3px); }
```

- [ ] **Step 2: Add the hero HTML inside a `<main>` element that follows the nav**

Replace the placeholder comments and start `<main>`:

```html
<main id="main">

  <section class="section hero container" id="top">
    <span class="hero-eyebrow">Available for select consulting work</span>
    <h1 class="hero-title">
      ERP consultant turned <span class="accent">builder</span>.
    </h1>
    <p class="hero-sub">
      Apps, AI workflows, and Excel add-ins for the way finance &amp; ops teams actually work.
      I ship the tooling your spreadsheets and processes have been waiting for.
    </p>
    <div class="hero-ctas">
      <a class="btn btn-primary" href="#work">
        See my work <span class="btn-arrow" aria-hidden="true">→</span>
      </a>
      <a class="btn btn-ghost" href="#contact">
        Get in touch
      </a>
    </div>
  </section>

  <!-- bento grid goes here in Tasks 5-8 -->
  <!-- services strip goes here in Task 9 -->
  <!-- about goes here in Task 10 -->
  <!-- contact + footer go here in Task 11 -->

</main>
```

- [ ] **Step 3: Verify the hero**

Refresh. Expected:
- Eyebrow pill with pulsing teal dot reading "Available for select consulting work"
- Large headline with "builder" rendered in the violet→teal gradient
- Subheadline in muted text below
- Two buttons: primary (gradient) and ghost (subtle), both with hover lift
- The arrow on "See my work" slides right on hover
- Clicking "See my work" tries to scroll to `#work` (does nothing yet — anchor doesn't exist)
- Resize down to 375px: headline shrinks gracefully, buttons wrap

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add hero section with gradient headline and CTAs"
```

---

## Task 5: Bento grid container + flagship card (#1 D365 ERP Web)

**Files:**
- Modify: `index.html` — append bento CSS, add `#work` section with bento container + flagship card

- [ ] **Step 1: Append bento + card CSS to `<style>`**

```css
/* ============ SECTION HEADING ============ */
.section-eyebrow {
  font-family: var(--font-mono);
  font-size: .72rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--text-muted);
  margin-bottom: .5rem;
}
.section-title {
  font-size: clamp(1.8rem, 3.5vw, 2.6rem);
  font-weight: 600;
  margin-bottom: 2.5rem;
  max-width: 28ch;
}

/* ============ BENTO GRID ============ */
.bento {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-auto-rows: minmax(180px, auto);
  gap: 1rem;
}
.bento-card {
  display: flex; flex-direction: column;
  padding: 1.4rem;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r-lg);
  transition: transform .2s ease, border-color .2s ease, box-shadow .25s ease;
  position: relative;
  overflow: hidden;
  text-decoration: none; color: inherit;
}
.bento-card::before {
  content: ''; position: absolute; inset: 0;
  background: var(--grad-accent);
  opacity: 0; transition: opacity .25s ease;
  z-index: 0; pointer-events: none;
  mix-blend-mode: overlay;
}
.bento-card:hover {
  transform: translateY(-3px);
  border-color: var(--border-strong);
  box-shadow: 0 16px 50px -20px rgba(var(--accent-glow), 0.4);
}
.bento-card:hover::before { opacity: 0.06; }
.bento-card > * { position: relative; z-index: 1; }
.bento-card.flagship { grid-column: span 2; grid-row: span 2; }
.bento-card.wide { grid-column: span 2; }
.bento-card.banner { grid-column: span 4; }

.card-label {
  font-family: var(--font-mono);
  font-size: .68rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--text-muted);
  margin-bottom: .85rem;
}
.card-title {
  font-size: 1.4rem;
  font-weight: 600;
  margin-bottom: .55rem;
}
.bento-card.flagship .card-title { font-size: 2rem; }
.card-desc {
  color: var(--text-dim);
  font-size: .95rem;
  margin-bottom: 1.15rem;
  flex: 1;
}
.tag-row { display: flex; flex-wrap: wrap; gap: .4rem; margin-bottom: 1.15rem; }
.tag {
  font-size: .72rem; font-weight: 500;
  padding: .25rem .55rem;
  border: 1px solid var(--border);
  border-radius: 999px;
  color: var(--text-dim);
}
.card-foot {
  display: flex; align-items: center; justify-content: space-between;
  font-size: .85rem; font-weight: 600;
}
.card-foot .view {
  color: var(--accent-2);
  transition: gap .15s ease;
  display: inline-flex; align-items: center; gap: .35rem;
}
.bento-card:hover .card-foot .view { gap: .6rem; }
.pill-progress {
  font-size: .68rem; font-weight: 700; letter-spacing: 0.1em;
  text-transform: uppercase;
  padding: .25rem .55rem;
  border-radius: 999px;
  background: rgba(94,234,212,0.1);
  border: 1px solid rgba(94,234,212,0.3);
  color: var(--accent-2);
}

/* swatch — abstract accent block used in cards instead of screenshots in v1 */
.swatch {
  height: 80px;
  border-radius: var(--r-md);
  margin-bottom: 1.15rem;
  background: linear-gradient(135deg, rgba(124,92,255,0.4), rgba(94,234,212,0.2));
  border: 1px solid var(--border);
}
.bento-card.flagship .swatch { height: 160px; }
.bento-card.banner .swatch { height: 100px; }

@media (max-width: 900px) {
  .bento { grid-template-columns: 1fr; }
  .bento-card.flagship,
  .bento-card.wide,
  .bento-card.banner {
    grid-column: span 1;
    grid-row: span 1;
  }
  .bento-card.flagship .card-title { font-size: 1.5rem; }
}
```

- [ ] **Step 2: Add the `#work` section with the bento container and flagship card**

Replace the `<!-- bento grid goes here in Tasks 5-8 -->` line with:

```html
<section class="section container" id="work">
  <p class="section-eyebrow">Selected Work</p>
  <h2 class="section-title">Things I've built for finance, ops, and creative teams.</h2>

  <div class="bento">

    <!-- Card 1: D365 ERP Manager Web (flagship 2x2) -->
    <a class="bento-card flagship" href="#" aria-label="D365 ERP Manager Web — case study">
      <p class="card-label">D365 / BLAZOR / .NET 8</p>
      <h3 class="card-title">D365 ERP Manager Web</h3>
      <div class="swatch" aria-hidden="true"></div>
      <p class="card-desc">
        Blazor app that generates ERP implementation timelines, project templates, and user stories for D365 Finance &amp; Ops rollouts. Built so consultants can stop rebuilding the same spreadsheet on every engagement.
      </p>
      <div class="tag-row">
        <span class="tag">Blazor</span>
        <span class="tag">C#</span>
        <span class="tag">.NET 8</span>
      </div>
      <div class="card-foot">
        <span class="view">View case study <span aria-hidden="true">→</span></span>
      </div>
    </a>

    <!-- More cards in Tasks 6, 7, 8 -->

  </div>
</section>
```

- [ ] **Step 3: Verify the flagship card**

Refresh. Scroll to the "Selected Work" section. Expected:
- Section eyebrow "SELECTED WORK" in mono uppercase, then a section title
- Single large card occupying 2/4 columns × 2 rows (so wider and taller than other cards will be once added)
- Card contents top to bottom: monospace label, large title "D365 ERP Manager Web", a gradient swatch box, description, 3 tag pills, "View case study →" link in teal
- Hover: card lifts slightly, border lightens, subtle accent glow
- At < 900px, card spans the full single column
- Tab key focus shows a clear ring around the card

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add bento grid container and flagship D365 ERP Web card"
```

---

## Task 6: Card #2 — Codex Job Tracking App (wide, with In-Progress pill)

**Files:**
- Modify: `index.html` — add card 2 inside `.bento` div

- [ ] **Step 1: Add the Codex card right after the flagship card (before the closing `</div>` of `.bento`)**

```html
<!-- Card 2: Codex Job Tracking App (wide 2x1, in-progress) -->
<div class="bento-card wide" aria-label="Codex Job Tracking App — in progress">
  <p class="card-label">NEXT.JS / FASTAPI / CREWAI</p>
  <h3 class="card-title">Codex Job Tracking App</h3>
  <p class="card-desc">
    Full-stack AI job-search command center. Aggregates listings from public boards, ranks fit with OpenAI, tailors résumés, monitors Gmail &amp; Outlook for recruiter replies, and runs approval-gated auto-apply via Playwright — orchestrated by a CrewAI multi-agent backbone.
  </p>
  <div class="tag-row">
    <span class="tag">Next.js</span>
    <span class="tag">FastAPI</span>
    <span class="tag">CrewAI</span>
  </div>
  <div class="card-foot">
    <span></span>
    <span class="pill-progress">In progress</span>
  </div>
</div>
```

> Note: This card is a `<div>` rather than an `<a>` because there's no link yet. When the URL is available, change `<div class="bento-card wide" ...>` to `<a class="bento-card wide" href="https://...">` and replace the `card-foot` contents with a `.view` span like the flagship card.

- [ ] **Step 2: Verify card 2**

Refresh. Expected:
- Codex card sits to the right of the flagship card, occupying the top 2 columns of the right half
- Has a teal "In progress" pill at the bottom-right (no "View" link)
- Cursor does NOT show pointer on hover (it's a div, not a link)
- The flagship card now stops at row 2 instead of stretching — column heights look right

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Add Codex Job Tracking App card with in-progress pill"
```

---

## Task 7: Cards #3 and #4 — Agent Dashboard + Creator Dashboard

**Files:**
- Modify: `index.html` — add cards 3 and 4

- [ ] **Step 1: Add cards 3 and 4 immediately after card 2 (before closing `</div>` of `.bento`)**

```html
<!-- Card 3: Agent Dashboard (1x1) -->
<a class="bento-card" href="#" aria-label="Agent Dashboard — case study">
  <p class="card-label">PYTHON / AGENTS</p>
  <h3 class="card-title">Agent Dashboard</h3>
  <p class="card-desc">
    An agentic OS that surfaces every AI automation in one place — active workflows, skill usage, and token consumption across projects.
  </p>
  <div class="tag-row">
    <span class="tag">Python</span>
    <span class="tag">Agents</span>
    <span class="tag">Observability</span>
  </div>
  <div class="card-foot">
    <span class="view">View <span aria-hidden="true">→</span></span>
  </div>
</a>

<!-- Card 4: Creator Dashboard (1x1) -->
<a class="bento-card" href="#" aria-label="Creator Dashboard — case study">
  <p class="card-label">HTML / VANILLA JS</p>
  <h3 class="card-title">Creator Dashboard</h3>
  <p class="card-desc">
    A single-file shell application helping social media creators grow their digital footprint — scheduling, link-in-bio, analytics, and promo tools.
  </p>
  <div class="tag-row">
    <span class="tag">HTML</span>
    <span class="tag">JS</span>
    <span class="tag">LocalStorage</span>
  </div>
  <div class="card-foot">
    <span class="view">View <span aria-hidden="true">→</span></span>
  </div>
</a>
```

- [ ] **Step 2: Verify cards 3 and 4**

Refresh. Expected:
- Two smaller cards now fill the bottom-right of the bento grid, each one column wide
- Row 1 (right half): Codex card (spans 2 columns)
- Row 2 (right half): Agent Dashboard | Creator Dashboard side by side
- Left half (rows 1-2): flagship card
- All three small cards have similar height because `grid-auto-rows` sets a minimum
- Both small cards have "View →" links in teal
- At < 900px, the grid collapses to a single column and cards stack in this order: flagship → Codex → Agent → Creator

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Add Agent Dashboard and Creator Dashboard cards"
```

---

## Task 8: Card #5 — Housing-Price ML Models (full-width banner)

**Files:**
- Modify: `index.html` — add the banner card

- [ ] **Step 1: Add card 5 immediately after card 4 (still inside `.bento`)**

```html
<!-- Card 5: Housing-Price ML Models (banner — full 4 cols) -->
<a class="bento-card banner" href="#" aria-label="Housing-Price ML Models — case study">
  <p class="card-label">DATA SCIENCE / SCIKIT-LEARN / XGBOOST</p>
  <h3 class="card-title">Housing-Price ML Models</h3>
  <p class="card-desc">
    Predicting residential sale prices with ensemble methods — XGBoost, Gradient Boosting, and Linear Regression compared head-to-head. Includes feature engineering, exploratory analysis, and predicted-vs-actual diagnostics.
  </p>
  <div class="tag-row">
    <span class="tag">Python</span>
    <span class="tag">XGBoost</span>
    <span class="tag">scikit-learn</span>
    <span class="tag">EDA</span>
  </div>
  <div class="card-foot">
    <span class="view">View case study <span aria-hidden="true">→</span></span>
  </div>
</a>
```

- [ ] **Step 2: Verify card 5**

Refresh. Expected:
- The banner card spans the full width of the grid (all 4 columns) below the others
- Card 5 is shorter than the small cards because it has no swatch
- Four tag pills wrap naturally
- The grid now looks like: flagship (left 2 cols) | Codex on top right + Agent/Creator below | banner full-width below
- At < 900px the banner becomes single-column like the rest

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "Add Housing-Price ML Models banner card"
```

---

## Task 9: Services strip (3 pillars)

**Files:**
- Modify: `index.html` — append services CSS, add `#services` section

- [ ] **Step 1: Append services CSS to `<style>`**

```css
/* ============ SERVICES ============ */
.services {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}
.service-card {
  padding: 1.6rem;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
}
.service-num {
  font-family: var(--font-mono);
  font-size: .75rem;
  color: var(--accent-2);
  margin-bottom: .75rem;
  letter-spacing: 0.1em;
}
.service-card h3 {
  font-size: 1.15rem;
  margin-bottom: .5rem;
}
.service-card p {
  color: var(--text-dim);
  font-size: .92rem;
}
@media (max-width: 800px) {
  .services { grid-template-columns: 1fr; }
}
```

- [ ] **Step 2: Add the `#services` section after the `#work` section, before the about/contact placeholders**

Replace `<!-- services strip goes here in Task 9 -->` with:

```html
<section class="section container" id="services">
  <p class="section-eyebrow">What I do</p>
  <h2 class="section-title">Three ways I help businesses ship.</h2>

  <div class="services">
    <div class="service-card">
      <p class="service-num">01</p>
      <h3>Custom business applications</h3>
      <p>Desktop, web, or single-file — built around the workflow you actually have, not the one a SaaS pricing page assumes.</p>
    </div>
    <div class="service-card">
      <p class="service-num">02</p>
      <h3>AI workflows &amp; agent systems</h3>
      <p>Agentic OSes, automation pipelines, and observability for AI-driven processes. Teach the agents your domain once; let them work the rest.</p>
    </div>
    <div class="service-card">
      <p class="service-num">03</p>
      <h3>Excel &amp; ERP automation</h3>
      <p>Add-ins, D365 Finance &amp; Ops tooling, and templates that replace the spreadsheet pain finance and ops teams have been suffering through.</p>
    </div>
  </div>
</section>
```

- [ ] **Step 3: Verify services strip**

Refresh. Expected:
- Below the bento grid, "What I do" eyebrow + section title
- Three equal-width cards in a row, each with a teal number (01/02/03), title, and short description
- At < 800px, the three cards stack into a single column
- Cards have subtle border, no hover lift (they're not links)

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add services strip with three pillar cards"
```

---

## Task 10: About section

**Files:**
- Modify: `index.html` — append about CSS, add `#about` section

- [ ] **Step 1: Append about CSS to `<style>`**

```css
/* ============ ABOUT ============ */
.about {
  display: grid;
  grid-template-columns: 1.4fr 1fr;
  gap: 3rem;
  align-items: start;
}
.about-bio p { color: var(--text-dim); margin-bottom: 1rem; font-size: 1.02rem; }
.about-bio p:last-child { margin-bottom: 0; }
.skills-card {
  padding: 1.5rem;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--r-md);
}
.skills-card h3 {
  font-size: .9rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: var(--text-muted);
  margin-bottom: 1rem;
  font-family: var(--font-mono);
  font-weight: 500;
}
.skill-list { display: flex; flex-wrap: wrap; gap: .5rem; }
.skill {
  padding: .45rem .8rem;
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--r-sm);
  font-size: .85rem;
  font-weight: 500;
}
@media (max-width: 800px) {
  .about { grid-template-columns: 1fr; gap: 2rem; }
}
```

- [ ] **Step 2: Add the `#about` section after `#services`**

Replace `<!-- about goes here in Task 10 -->` with:

```html
<section class="section container" id="about">
  <p class="section-eyebrow">About</p>
  <h2 class="section-title">From the ERP trenches to shipping the fixes.</h2>

  <div class="about">
    <div class="about-bio">
      <p>
        I started out implementing Dynamics 365 Finance &amp; Operations for businesses ranging from scrappy mid-market to enterprise rollouts. Spent years watching teams paper over ERP gaps with spreadsheets, ad-hoc scripts, and tribal knowledge that walked out the door every time someone left.
      </p>
      <p>
        Now I build the tooling those teams actually need — Blazor apps, AI-driven workflows, Excel add-ins, agentic systems that wire it all together. The bias is always toward shipping something useful, not delivering another deck.
      </p>
      <p>
        Based in the US. Working with select clients through KM Consulting. Open to senior implementation, solutions-engineering, and applied-AI roles where the work actually ships.
      </p>
    </div>
    <aside class="skills-card" aria-label="Core skills">
      <h3>Core skills</h3>
      <div class="skill-list">
        <span class="skill">D365 Finance &amp; Ops</span>
        <span class="skill">AI / Agents</span>
        <span class="skill">Excel automation</span>
        <span class="skill">Full-stack</span>
      </div>
    </aside>
  </div>
</section>
```

- [ ] **Step 3: Verify about section**

Refresh. Expected:
- Below services strip, "ABOUT" eyebrow + section title
- Left column: 3 paragraphs of bio (~120 words)
- Right column: a small card titled "CORE SKILLS" with 4 skill pills
- At < 800px the right card stacks below the bio
- Bio reads coherently; no Lorem ipsum

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add about section with bio and core skills card"
```

---

## Task 11: Contact + Footer

**Files:**
- Modify: `index.html` — append contact + footer CSS, add `#contact` section + footer

- [ ] **Step 1: Append contact + footer CSS to `<style>`**

```css
/* ============ CONTACT ============ */
.contact {
  text-align: center;
  padding-block: clamp(4rem, 8vw, 6rem);
}
.contact-title {
  font-size: clamp(2rem, 4vw, 3rem);
  font-weight: 600;
  margin-bottom: 1rem;
  letter-spacing: -0.025em;
}
.contact-sub {
  color: var(--text-dim);
  font-size: 1.05rem;
  max-width: 50ch;
  margin: 0 auto 2rem auto;
}
.contact-ctas { display: flex; justify-content: center; flex-wrap: wrap; gap: .75rem; }
.icon-btn {
  display: inline-flex; align-items: center; justify-content: center;
  width: 44px; height: 44px;
  border-radius: var(--r-md);
  background: var(--surface);
  border: 1px solid var(--border);
  color: var(--text-dim);
  transition: background .15s ease, color .15s ease, border-color .15s ease;
}
.icon-btn:hover {
  background: var(--surface-2);
  color: var(--text);
  border-color: var(--border-strong);
}
.icon-btn svg { width: 18px; height: 18px; }

/* ============ FOOTER ============ */
.footer {
  border-top: 1px solid var(--border);
  padding-block: 2rem;
  text-align: center;
  font-size: .85rem;
  color: var(--text-muted);
}
```

- [ ] **Step 2: Add the `#contact` section and footer to replace the placeholder**

Replace `<!-- contact + footer go here in Task 11 -->` with:

```html
  <section class="section container contact" id="contact">
    <h2 class="contact-title">Let's build something useful.</h2>
    <p class="contact-sub">
      Hiring, consulting, or just want to nerd out about D365 and AI workflows? Email is the fastest way to reach me.
    </p>
    <div class="contact-ctas">
      <a class="btn btn-primary" href="mailto:kmarcy@KMConsulting995.onmicrosoft.com?subject=Hello%20Keystone">
        Email Keystone <span class="btn-arrow" aria-hidden="true">→</span>
      </a>
      <a class="icon-btn" href="https://github.com/kmarcy95" target="_blank" rel="noopener" aria-label="GitHub">
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .5C5.65.5.5 5.66.5 12.04c0 5.1 3.29 9.42 7.86 10.95.58.11.79-.25.79-.56 0-.27-.01-1-.02-1.97-3.2.7-3.87-1.54-3.87-1.54-.52-1.34-1.28-1.7-1.28-1.7-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.2 1.77 1.2 1.03 1.78 2.7 1.27 3.36.97.1-.75.4-1.27.73-1.56-2.55-.29-5.24-1.29-5.24-5.74 0-1.27.45-2.31 1.18-3.12-.12-.3-.51-1.49.11-3.1 0 0 .97-.31 3.18 1.19a11 11 0 0 1 5.79 0c2.21-1.5 3.18-1.19 3.18-1.19.62 1.61.23 2.8.11 3.1.73.81 1.18 1.85 1.18 3.12 0 4.46-2.69 5.44-5.25 5.73.41.36.78 1.06.78 2.14 0 1.54-.01 2.78-.01 3.16 0 .31.21.68.8.56C20.22 21.46 23.5 17.13 23.5 12.04 23.5 5.66 18.35.5 12 .5z"/></svg>
      </a>
      <a class="icon-btn" href="https://www.linkedin.com/in/" target="_blank" rel="noopener" aria-label="LinkedIn">
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.45 20.45h-3.55v-5.57c0-1.33-.03-3.04-1.86-3.04-1.86 0-2.14 1.45-2.14 2.95v5.66H9.36V9h3.4v1.56h.05c.47-.9 1.63-1.86 3.36-1.86 3.59 0 4.25 2.36 4.25 5.43v6.32zM5.34 7.43a2.06 2.06 0 1 1 0-4.13 2.06 2.06 0 0 1 0 4.13zM7.12 20.45H3.56V9h3.56v11.45zM22.22 0H1.77C.79 0 0 .78 0 1.73v20.54C0 23.22.79 24 1.77 24h20.45c.98 0 1.78-.78 1.78-1.73V1.73C24 .78 23.2 0 22.22 0z"/></svg>
      </a>
    </div>
  </section>

</main>

<footer class="footer">
  <div class="container">
    © 2026 KM Consulting · built by Keystone
  </div>
</footer>
```

> Note: The LinkedIn URL is a placeholder (`/in/`). Once the user provides the actual slug, replace `https://www.linkedin.com/in/` with the full URL.

- [ ] **Step 3: Verify contact + footer**

Refresh. Expected:
- Contact section is centered: large title, muted subtitle, then a row of three buttons (email + GitHub + LinkedIn icons)
- Clicking "Email Keystone" opens the system mail client with `kmarcy@KMConsulting995.onmicrosoft.com` and subject "Hello Keystone" pre-filled
- GitHub and LinkedIn open in a new tab
- Footer: thin border above, centered "© 2026 KM Consulting · built by Keystone"
- All nav links now scroll to a real section
- Tab through the page: skip-link → nav links → hero CTAs → bento cards → email → GitHub → LinkedIn, all with visible focus rings

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "Add contact section, social icons, and footer"
```

---

## Task 12: Motion polish — scroll stagger + magnetic hero CTAs

**Files:**
- Modify: `index.html` — append `.reveal` CSS, populate the `<script>` block at the bottom

- [ ] **Step 1: Append `.reveal` CSS to `<style>`**

```css
/* ============ MOTION ============ */
.reveal {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity .6s ease, transform .6s ease;
}
.reveal.in {
  opacity: 1;
  transform: translateY(0);
}
```

- [ ] **Step 2: Add `class="reveal"` to the elements that should fade in**

Add `reveal` to the class list of the hero (`.hero`), each `.bento-card`, each `.service-card`, the `.about` element, and the `.contact` element. For example, the flagship card becomes:

```html
<a class="bento-card flagship reveal" href="#" aria-label="...">
```

For each bento card, also add an inline `style="transition-delay: Nms"` to stagger the entrances. Use:
- flagship: `style="transition-delay: 0ms"`
- Codex: `style="transition-delay: 60ms"`
- Agent: `style="transition-delay: 120ms"`
- Creator: `style="transition-delay: 180ms"`
- Housing-Price banner: `style="transition-delay: 240ms"`

For service cards, similar stagger: 0ms / 60ms / 120ms.

- [ ] **Step 3: Replace the empty `<script>` block at the bottom of `<body>` with the motion script**

```html
<script>
  (function () {
    var reduced = matchMedia('(prefers-reduced-motion: reduce)').matches;

    /* ===== Reveal-on-scroll ===== */
    var targets = document.querySelectorAll('.reveal');
    if (reduced || !('IntersectionObserver' in window)) {
      targets.forEach(function (el) { el.classList.add('in'); });
    } else {
      var io = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (entry.isIntersecting) {
            entry.target.classList.add('in');
            io.unobserve(entry.target);
          }
        });
      }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
      targets.forEach(function (el) { io.observe(el); });
    }

    /* ===== Magnetic hover on hero CTAs (skip on touch / reduced motion) ===== */
    if (reduced) return;
    if (!matchMedia('(hover: hover)').matches) return;

    document.querySelectorAll('.hero-ctas .btn').forEach(function (btn) {
      btn.addEventListener('mousemove', function (e) {
        var r = btn.getBoundingClientRect();
        var x = (e.clientX - r.left - r.width / 2) * 0.18;
        var y = (e.clientY - r.top - r.height / 2) * 0.22;
        btn.style.transform = 'translate(' + x + 'px, ' + y + 'px)';
      });
      btn.addEventListener('mouseleave', function () {
        btn.style.transform = '';
      });
    });
  })();
</script>
```

- [ ] **Step 4: Verify motion**

Refresh and reload the page from scratch. Expected:
- Hero, bento cards, service cards, about, and contact all fade in from below as you scroll past them
- Bento cards stagger in (flagship first, then ripples right & down)
- Hover the hero CTAs: they subtly track the cursor (magnetic effect)
- Open OS-level "Reduce motion" preference (Windows Settings → Accessibility → Visual effects → Animation effects OFF), reload: all elements appear immediately, no magnetic hover. Turn motion back on.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "Add scroll-reveal stagger and magnetic hero CTAs"
```

---

## Task 13: Responsive + accessibility verification (no code changes expected)

**Files:**
- None expected. If issues are found, modify `index.html` to fix them and re-verify.

- [ ] **Step 1: Visual responsive check at three breakpoints**

Open DevTools → Responsive mode. Set viewport widths and verify:

- **1440 px (desktop):** nav full, hero headline ~4.4rem, bento as designed (flagship 2×2 + Codex top-right + Agent/Creator below + banner full-width), services 3-up, about 2-column.
- **768 px (tablet):** nav shows links, hero shrinks proportionally, bento collapses to single column (per the `@media (max-width: 900px)` rule), services stack 1-col (per `@media (max-width: 800px)`), about stacks 1-col.
- **375 px (mobile, iPhone SE):** nav shows only "Contact" pill, hero text wraps cleanly, no horizontal scroll anywhere, all cards readable.

If horizontal scroll appears at any size, find the offender (usually `overflow-x: hidden` on body already prevents this — but check for any wide element).

- [ ] **Step 2: Keyboard navigation check**

Click somewhere neutral, then press Tab repeatedly. Expected order:
1. Skip-link (appears top-left when focused)
2. Brand link
3. Work → Services → About → Contact (nav)
4. See my work → Get in touch (hero CTAs)
5. Each bento card (1, 2 is not focusable since it's a div, 3, 4, 5)
6. Email → GitHub → LinkedIn (contact)

Every focused element shows the violet outline.

- [ ] **Step 3: Axe-core accessibility scan via npx (no install)**

Open a terminal at the project root and run:

```bash
npx -y @axe-core/cli ./index.html --browser chrome --exit
```

Expected: 0 violations. If any appear, fix them and re-run. Common issues:
- Missing alt text → add to any `<img>` (there shouldn't be any in v1)
- Insufficient contrast → adjust muted text colors if flagged
- Missing label on interactive element → add `aria-label`

If axe complains it can't find a Chromium binary, try `--browser firefox` or use the Lighthouse approach in Task 15 (which also catches a11y issues).

- [ ] **Step 4: Commit any fixes**

```bash
git add index.html
git commit -m "Responsive and accessibility fixes from verification pass"
# Skip commit if no fixes were needed.
```

---

## Task 14: OG image (SVG) + final meta tag pass

**Files:**
- Create: `images/og.svg`

- [ ] **Step 1: Create `images/og.svg` — 1200×630, brand-matched**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" width="1200" height="630">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0a0a12"/>
      <stop offset="1" stop-color="#0f0e1a"/>
    </linearGradient>
    <linearGradient id="accent" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#7c5cff"/>
      <stop offset="1" stop-color="#5eead4"/>
    </linearGradient>
    <radialGradient id="glow1" cx="0.2" cy="0.2" r="0.6">
      <stop offset="0" stop-color="rgba(124,92,255,0.35)"/>
      <stop offset="1" stop-color="rgba(124,92,255,0)"/>
    </radialGradient>
    <radialGradient id="glow2" cx="0.85" cy="0.9" r="0.5">
      <stop offset="0" stop-color="rgba(94,234,212,0.25)"/>
      <stop offset="1" stop-color="rgba(94,234,212,0)"/>
    </radialGradient>
  </defs>

  <rect width="1200" height="630" fill="url(#bg)"/>
  <rect width="1200" height="630" fill="url(#glow1)"/>
  <rect width="1200" height="630" fill="url(#glow2)"/>

  <!-- brand orb -->
  <circle cx="96" cy="100" r="22" fill="url(#accent)"/>
  <text x="134" y="108" fill="#f7f7ff" font-family="'Space Grotesk', system-ui, sans-serif" font-weight="700" font-size="28">KM Consulting</text>

  <!-- headline -->
  <text x="96" y="320" fill="#f7f7ff" font-family="'Space Grotesk', system-ui, sans-serif" font-weight="700" font-size="84" letter-spacing="-3">ERP consultant</text>
  <text x="96" y="412" fill="#f7f7ff" font-family="'Space Grotesk', system-ui, sans-serif" font-weight="700" font-size="84" letter-spacing="-3">turned <tspan fill="url(#accent)">builder</tspan>.</text>

  <!-- subline -->
  <text x="96" y="490" fill="#c5c5d5" font-family="'Inter', system-ui, sans-serif" font-weight="400" font-size="28">Apps, AI workflows, and Excel add-ins.</text>

  <!-- author bar -->
  <rect x="96" y="540" width="120" height="2" fill="url(#accent)"/>
  <text x="96" y="580" fill="#9999b0" font-family="'Inter', system-ui, sans-serif" font-weight="500" font-size="22">Keystone Marcy</text>
</svg>
```

- [ ] **Step 2: Verify the SVG renders correctly**

Open `images/og.svg` directly in a browser. Expected:
- 1200×630 dark canvas with subtle violet (top-left) and teal (bottom-right) glows
- "KM Consulting" with the gradient orb in the top-left corner
- Large headline "ERP consultant turned builder." with "builder" in the violet→teal gradient
- Muted subline "Apps, AI workflows, and Excel add-ins."
- "Keystone Marcy" label at the bottom

If text doesn't render with Space Grotesk (fonts in SVG don't load Google Fonts automatically), the system fallback shows — that's acceptable for an OG image since it's rasterized by the consumer.

- [ ] **Step 3: Add a comment in `index.html` noting the SVG OG caveat**

In the OG meta block, add a comment above `og:image`:

```html
  <!-- SVG OG image. Most modern scrapers accept SVG; if Twitter/Facebook misbehave, generate images/og.png from this SVG and switch the path. -->
  <meta property="og:image" content="images/og.svg" />
```

- [ ] **Step 4: Commit**

```bash
git add images/og.svg index.html
git commit -m "Add SVG OG image and document PNG fallback"
```

---

## Task 15: Lighthouse audit + GitHub + Netlify deploy

**Files:**
- Modify: `README.md` (final polish)
- No code changes expected unless Lighthouse flags issues.

- [ ] **Step 1: Run Lighthouse via npx (no install)**

```bash
cd /c/Users/keyst/Business-Landing-Page
npx -y lighthouse "file://$(pwd)/index.html" --preset=desktop --output=html --output-path=./lighthouse-report.html --chrome-flags="--headless" --quiet
```

Open `lighthouse-report.html` in a browser. Expected scores:
- Performance ≥ 90
- Accessibility ≥ 95
- Best Practices ≥ 90
- SEO ≥ 90

If scores fall short:
- Performance under 90 — typically caused by Google Fonts blocking. Mitigation: ensure `&display=swap` is in the font URL (it is).
- Accessibility under 95 — fix whatever axe missed.
- SEO under 90 — confirm `<meta name="description">` is present and `lang="en"` is on `<html>`.

Add `lighthouse-report.html` to `.gitignore` so it doesn't pollute the repo:

```bash
echo 'lighthouse-report.html' >> .gitignore
git add .gitignore
git commit -m "Ignore Lighthouse report output"
```

- [ ] **Step 2: Update README.md with a brief usage note**

Replace the contents of `README.md` with:

```markdown
# Business Landing Page

Personal business landing page for Keystone Marcy / KM Consulting.

Single-file vanilla HTML/CSS/JS. No build step. Hosted on Netlify with auto-deploy from `main`.

## Local preview

Just open `index.html` in a browser — no server needed.

For live-reload during edits:

    npx -y serve .

## Deploy

Netlify auto-deploys on push to `main`. Publish directory is the repo root (see `netlify.toml`).

## Reference

- Design spec: [`docs/superpowers/specs/2026-05-16-business-landing-design.md`](docs/superpowers/specs/2026-05-16-business-landing-design.md)
- Implementation plan: [`docs/superpowers/plans/2026-05-16-business-landing-implementation.md`](docs/superpowers/plans/2026-05-16-business-landing-implementation.md)
```

Commit:

```bash
git add README.md
git commit -m "Polish README with local preview and deploy notes"
```

- [ ] **Step 3: Create GitHub repo and push (user action — script provided)**

Authenticate `gh` if you haven't already:

```bash
gh auth status
# If not logged in: gh auth login
```

Create the repo and push:

```bash
cd /c/Users/keyst/Business-Landing-Page
gh repo create kmarcy95/Business-Landing-Page --public --source=. --remote=origin --description "Personal business landing page for Keystone Marcy / KM Consulting"
git push -u origin main
```

Expected output: GitHub URL like `https://github.com/kmarcy95/Business-Landing-Page`.

> If the user does not want a public repo, replace `--public` with `--private`. Confirm with the user before running this step.

- [ ] **Step 4: Connect Netlify (user action — manual web UI)**

This step requires the user's browser; cannot be automated without a Netlify API token.

Open <https://app.netlify.com/start>. Then:

1. Click **Import from Git**
2. Authorize GitHub if prompted
3. Pick **kmarcy95/Business-Landing-Page**
4. Build settings — leave **Build command** blank, **Publish directory** = `.` (Netlify reads `netlify.toml` automatically)
5. Click **Deploy site**
6. Once live, Site settings → Domain management → Options → Edit site name → set to `keystonemarcy` (fallback: `kmconsulting`). Final URL becomes `https://keystonemarcy.netlify.app`.

Verify the live URL in a browser. The page should match the local version exactly.

- [ ] **Step 5: Final commit (optional placeholder)**

If Step 4 surfaced any tweaks (e.g. updating the LinkedIn URL because you now know the slug), commit them:

```bash
git add -A
git commit -m "Final tweaks after Netlify deploy"
git push
```

If nothing changed, skip this step.

---

## Self-Review Notes (already addressed)

- **Spec coverage** — every spec section maps to a task: identity → Task 1 meta + Task 4 hero; bento → Tasks 5–8; services → Task 9; about → Task 10; contact + footer → Task 11; motion → Task 12; visual style tokens → Task 2; OG image → Task 14; hosting → Task 15.
- **Placeholder scan** — no "TBD" / "implement later" / "add error handling" appear. The two acknowledged unknowns (Codex app link, LinkedIn slug) are explicitly called out as placeholders the user updates later.
- **Type consistency** — CSS class names (`.bento-card`, `.flagship`, `.wide`, `.banner`, `.reveal`, `.btn-primary`, `.btn-ghost`, `.section-eyebrow`, etc.) are introduced once and reused consistently in every later task that references them.
- **Bento layout math** — desktop 4-col grid: flagship spans 2 cols × 2 rows, Codex spans 2 cols × 1 row (top-right), Agent + Creator each 1×1 (bottom-right), banner spans 4 cols (full width below). Mobile collapses to single column.
