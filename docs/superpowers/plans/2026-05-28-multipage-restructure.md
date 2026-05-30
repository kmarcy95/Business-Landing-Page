# Multi-page Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the single-page `index.html` into a multi-page site — a slimmed Home plus a dedicated, distinctly-colored page per nav tab (Work, Services, About, How I Work, Experience, Contact) — with added graphics.

**Architecture:** Shared-shell multi-page extraction. Each tab becomes a root-level `.html` page that reuses the existing nav/footer/sticky-CTA/`<script>` shell and `assets/site.css`, exactly like the existing `/work/*` detail pages. Content is moved out of `index.html` into the new pages. Each page sets a `body.theme-*` class that overrides the accent tokens (extending the existing `theme-green` pattern). No build step, no new dependencies.

**Tech Stack:** Vanilla HTML5 + CSS (`assets/site.css`), tiny vanilla JS IIFE, Netlify hosting (pretty URLs + redirects via `netlify.toml`). No test framework — verification is browser + `curl` + static checks, per the site's manual-verification convention.

**Spec:** `docs/superpowers/specs/2026-05-28-multipage-restructure-design.md`

**Conventions for every new page:**
- Root pages link with bare relative hrefs (`work.html`, `about.html`, …) — works under `file://` locally AND Netlify rewrites to pretty URLs (`/work`).
- Reuse the `<head>` block from `index.html` lines 1–87 (favicon, Inter font, `assets/site.css`), changing only `<title>`, `meta description`, canonical, and OG/Twitter tags per page. Drop the homepage-only JSON-LD `ProfilePage` from subpages (Home keeps it).
- Body opens with the page's theme class, e.g. `<body class="theme-indigo">`.
- Reuse the shared NAV, FOOTER, STICKY-CTA, and SCRIPT blocks defined in **Task 2** verbatim, marking the current page's nav link `class="active" aria-current="page"`.
- Each page's main content starts with a standard page header (Task 2 `.page-head`).

---

## Task 1: Per-tab theme classes + active-nav styling (CSS)

**Files:**
- Modify: `assets/site.css` (append at end, after the existing `body.theme-green` block)

- [ ] **Step 1: Append the theme classes.** Add this block at the END of `assets/site.css`:

```css
/* ===== Per-tab accent themes (extends body.theme-green) ===== */
/* Each theme overrides the 4 accent tokens + the two hardcoded-cyan spots. */

/* Work — Indigo */
body.theme-indigo{ --accent-1:#6E7BE6; --accent-2:#5462C8;
  --grad-accent:linear-gradient(135deg,#6E7BE6 0%,#5462C8 100%); --accent-glow:110,123,230; }
body.theme-indigo .btn-ghost:hover{ background:rgba(110,123,230,0.10); }
body.theme-indigo .bg-mesh{ background:
  radial-gradient(900px 500px at 50% -10%, rgba(110,123,230,.12), transparent 60%),
  linear-gradient(180deg,#0a0a0a 0%,#101012 100%); }
body.theme-indigo .btn-primary, body.theme-indigo .nav-cta{ color:#fff !important; }

/* About — Bronze */
body.theme-bronze{ --accent-1:#C2A14D; --accent-2:#A6863A;
  --grad-accent:linear-gradient(135deg,#C2A14D 0%,#A6863A 100%); --accent-glow:194,161,77; }
body.theme-bronze .btn-ghost:hover{ background:rgba(194,161,77,0.10); }
body.theme-bronze .bg-mesh{ background:
  radial-gradient(900px 500px at 50% -10%, rgba(194,161,77,.12), transparent 60%),
  linear-gradient(180deg,#0a0a0a 0%,#101012 100%); }

/* How I Work — Amethyst */
body.theme-amethyst{ --accent-1:#9A7BD0; --accent-2:#7E5FB8;
  --grad-accent:linear-gradient(135deg,#9A7BD0 0%,#7E5FB8 100%); --accent-glow:154,123,208; }
body.theme-amethyst .btn-ghost:hover{ background:rgba(154,123,208,0.10); }
body.theme-amethyst .bg-mesh{ background:
  radial-gradient(900px 500px at 50% -10%, rgba(154,123,208,.12), transparent 60%),
  linear-gradient(180deg,#0a0a0a 0%,#101012 100%); }
body.theme-amethyst .btn-primary, body.theme-amethyst .nav-cta{ color:#fff !important; }

/* Experience — Teal */
body.theme-teal{ --accent-1:#159C92; --accent-2:#0E7E76;
  --grad-accent:linear-gradient(135deg,#159C92 0%,#0E7E76 100%); --accent-glow:21,156,146; }
body.theme-teal .btn-ghost:hover{ background:rgba(21,156,146,0.12); }
body.theme-teal .bg-mesh{ background:
  radial-gradient(900px 500px at 50% -10%, rgba(21,156,146,.12), transparent 60%),
  linear-gradient(180deg,#0a0a0a 0%,#101012 100%); }
body.theme-teal .btn-primary, body.theme-teal .nav-cta{ color:#fff !important; }

/* Contact — Clay */
body.theme-clay{ --accent-1:#C9714E; --accent-2:#A85B3D;
  --grad-accent:linear-gradient(135deg,#C9714E 0%,#A85B3D 100%); --accent-glow:201,113,78; }
body.theme-clay .btn-ghost:hover{ background:rgba(201,113,78,0.12); }
body.theme-clay .bg-mesh{ background:
  radial-gradient(900px 500px at 50% -10%, rgba(201,113,78,.12), transparent 60%),
  linear-gradient(180deg,#0a0a0a 0%,#101012 100%); }
body.theme-clay .btn-primary, body.theme-clay .nav-cta{ color:#fff !important; }

/* Active nav link uses the page's accent */
.nav-links a.active{ color:var(--accent-1); }

/* Page header (subject pages) */
.page-head{ margin:1.75rem 0 1.5rem; max-width:72ch; }
.page-head .page-icon{ width:40px; height:40px; color:var(--accent-1); margin-bottom:.6rem; }
.page-title{ font-family:var(--font-display); font-size:clamp(2rem,4.4vw,3rem); line-height:1.08; margin:.25rem 0 .5rem; }
.page-intro{ color:var(--text-dim); font-size:1.2rem; line-height:1.55; margin:0; max-width:62ch; }
```

(Note: `theme-green` already exists from the consulting page; Services will reuse it.)

- [ ] **Step 2: Verify the active-nav rule isn't already defined differently.**

Run: `grep -n 'nav-links a.active' assets/site.css`
Expected: only the one new rule (if a prior `.active` underline rule exists, keep both — color + underline coexist).

- [ ] **Step 3: Commit**

```bash
git add assets/site.css
git commit -m "Add per-tab accent theme classes and page-head/active-nav styles"
```

---

## Task 2: Define the canonical shared shell (reference snippets)

No file change in this task — this task **establishes the exact markup** every subpage reuses. Copy these blocks verbatim into each page built in Tasks 3–9.

- [ ] **Step 1: Canonical NAV** (root pages). Replace the current page's link `class`/`aria-current` per page.

```html
<header class="nav" role="banner">
  <nav class="container nav-inner" aria-label="Primary">
    <a class="brand" href="index.html#top" aria-label="Keystone Marcy — home">
      <span class="brand-orb" aria-hidden="true"></span>
      <span>KM Consulting</span>
    </a>
    <button class="nav-toggle" id="navToggle" aria-expanded="false" aria-controls="navLinks" aria-label="Open menu">
      <span class="nav-toggle-bar" aria-hidden="true"></span>
      <span class="nav-toggle-bar" aria-hidden="true"></span>
      <span class="nav-toggle-bar" aria-hidden="true"></span>
    </button>
    <ul class="nav-links" id="navLinks">
      <li><a href="index.html">Home</a></li>
      <li><a href="work.html">Work</a></li>
      <li><a href="services.html">Services</a></li>
      <li><a href="about.html">About</a></li>
      <li><a href="how-i-work.html">How I Work</a></li>
      <li><a href="experience.html">Experience</a></li>
      <li><a class="nav-cta" href="contact.html" data-cta="nav_contact">Contact</a></li>
    </ul>
  </nav>
</header>
```

- [ ] **Step 2: Canonical FOOTER** (root pages):

```html
<footer class="footer">
  <div class="container footer-inner">
    <a class="footer-brand" href="index.html#top" aria-label="KM Consulting — back to top">
      <span class="brand-orb" aria-hidden="true"></span>
      <span>KM Consulting</span>
    </a>
    <nav class="footer-links" aria-label="Footer">
      <a href="work.html">Work</a>
      <a href="services.html">Services</a>
      <a href="experience.html">Experience</a>
      <a href="about.html">About</a>
      <a href="contact.html">Contact</a>
    </nav>
    <a class="footer-top" href="#top">Back to top <span aria-hidden="true">&uarr;</span></a>
  </div>
  <div class="container footer-copy">© 2026 KM Consulting · built by Keystone</div>
</footer>
```

- [ ] **Step 3: Canonical STICKY-CTA** (root subpages — résumé + contact):

```html
<div class="sticky-cta" id="stickyCta">
  <span class="sticky-cta-text">Keystone Marcy — FP&amp;A &amp; Strategic Finance Leader</span>
  <span class="sticky-cta-actions">
    <a class="btn btn-primary" href="Keystone-Marcy-Resume.pdf" download data-resume-download data-cta="sticky_resume">Résumé</a>
    <a class="btn btn-ghost" href="contact.html" data-cta="sticky_contact">Contact</a>
  </span>
</div>
```

- [ ] **Step 4: Canonical SCRIPT** — reuse the consulting.html `<script>` block (the trimmed variant: analytics `track()`, reveal-on-scroll, sticky-CTA show/hide keyed to `#top`+`#intake`/`#contact`, mobile nav toggle). For pages **without** a form or `#intake`, the sticky logic keyed to `#intake`/`#contact` simply no-ops the "hide" (the `if (intakeEl)` guard handles it). Use the EXACT block from `consulting.html` (the `<script>…</script>` near end of that file). Home reuses the fuller `index.html` script (it has stats count-up + scrollspy).

- [ ] **Step 5: Canonical `.page-head`** pattern (each subpage's first element inside `<main class="container" id="main">`, after the skip-link target). Per-page icon + title + intro:

```html
<header class="page-head" id="top">
  <svg class="page-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><!-- per-page icon paths, see each task --></svg>
  <p class="section-eyebrow"><!-- EYEBROW --></p>
  <h1 class="page-title"><!-- TITLE --></h1>
  <p class="page-intro"><!-- INTRO --></p>
</header>
```

Body wrapper for all subpages: `<body class="theme-X">` → `<a class="skip-link" href="#main">…</a>` → `<div class="bg-mesh" aria-hidden="true"></div>` → `<div class="bg-grain" aria-hidden="true"></div>` → NAV → `<main class="container" id="main">` … `</main>` → FOOTER → STICKY-CTA → SCRIPT.

- [ ] **Step 6: Commit** — nothing to commit (reference task). Skip.

---

## Task 3: Work page (`work.html`) — Indigo

**Files:**
- Create: `work.html`

- [ ] **Step 1: Scaffold** the page using the Task-2 shell with `<body class="theme-indigo">`, nav "Work" link `class="active" aria-current="page"`. Head: title `Work — Keystone Marcy | KM Consulting`, description about the project portfolio, canonical `https://keystonemarcy.pages.dev/work`, OG image `images/og.png`.

- [ ] **Step 2: Page header** — icon (grid/layers), eyebrow `SELECTED WORK`, title `Things I've built.`, intro: "Finance tooling, AI systems, and apps I've designed and shipped — each one solving a real reporting or workflow gap. Click any project for the full walkthrough."

Icon paths (briefcase/grid): `<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 10h18"/><path d="M9 4v16"/>`

- [ ] **Step 3: Move the Work bento.** Copy the `#work` bento grid markup from `index.html` lines **302–436** (the `<section class="section container section-tint" id="work"> … </section>` — the intro paragraph + the `.bento`/cards). Paste it into `work.html` after the page header. Change the section's outer tag to `<section class="section">` (drop `section-tint`/`container` since `<main>` is already `.container`; keep the `.bento` grid intact). The card detail links inside point to `work/<slug>.html` — these stay correct (root page → `work/…`). Remove the now-redundant section `<h2>`/eyebrow if it duplicates the page header (keep the descriptive paragraph if useful).

- [ ] **Step 4: Verify** structure:

Run: `node -e "const h=require('fs').readFileSync('work.html','utf8');for(const t of['section','header','main','footer','nav']){const o=(h.match(new RegExp('<'+t+'[ >]','g'))||[]).length,c=(h.match(new RegExp('</'+t+'>','g'))||[]).length;console.log(t,o,c,o===c?'OK':'MISMATCH')}"`
Expected: all OK.

Run: `grep -c 'work/d365.html\|work/codex.html\|work/agentic-os.html\|work/aurora.html\|work/creator.html\|work/ml.html' work.html`
Expected: 6 (each detail link present).

- [ ] **Step 5: Browser check** — open `work.html`; confirm indigo accent, all 6 cards render in browser-chrome frames, links navigate to detail pages, mobile nav works.

- [ ] **Step 6: Commit**

```bash
git add work.html
git commit -m "Add Work portfolio index page (indigo theme)"
```

---

## Task 4: Services page (`services.html`) — Green (merged with Consulting)

**Files:**
- Create: `services.html`
- Reference: `consulting.html` (source of rate band, tiers, intake form), `index.html` lines 438–465 (the 3 service cards)

- [ ] **Step 1: Scaffold** with `<body class="theme-green">`, nav "Services" link `active`. Head: title `Services — AI & Excel Automation | KM Consulting`, description (merge of consulting + services), canonical `https://keystonemarcy.pages.dev/services`, keep the `Service`/`Offer` JSON-LD from `consulting.html`, green favicon SVG (copy from `consulting.html`).

- [ ] **Step 2: Page header** — icon (gear/sliders), eyebrow `SERVICES`, title `What I build, and how to hire me.`, intro: "AI automation, Excel automation, and the custom finance tooling teams actually need — available by the hour or as a scoped project."

Icon paths (sliders): `<line x1="4" y1="21" x2="4" y2="14"/><line x1="4" y1="10" x2="4" y2="3"/><line x1="12" y1="21" x2="12" y2="12"/><line x1="12" y1="8" x2="12" y2="3"/><line x1="20" y1="21" x2="20" y2="16"/><line x1="20" y1="12" x2="20" y2="3"/><line x1="1" y1="14" x2="7" y2="14"/><line x1="9" y1="8" x2="15" y2="8"/><line x1="17" y1="16" x2="23" y2="16"/>`

- [ ] **Step 3: "What I do" capabilities** — move the 3 service cards from `index.html` lines 438–465 (`.services` grid with `.service-card` × 3) into a `<section class="consult-section">` with an eyebrow `What I do` + `<h2 class="section-title">Three ways I help finance & ops teams.</h2>`. Keep the cards' inline Tabler SVG icons.

- [ ] **Step 4: Rate band + tiers + capabilities** — move these blocks verbatim from `consulting.html`: the `.consult-rate` band, the `.consult-tiers` section (3 tiers, Build Sprint `.featured`), and the `.consult-capabilities` "What I automate" list. The `#intake` anchor targets stay (`href="#intake"`).

- [ ] **Step 5: Intake form** — move the entire `<section ... id="intake">` (form `name="consulting-intake"` + the contact-or/contact-ctas block) verbatim from `consulting.html`. Keep `name="consulting-intake"` unchanged so the existing Netlify form registration + notifications keep working. Update the in-page `track()` hook selector (already `form[name="consulting-intake"]`) — reuse the consulting.html script.

- [ ] **Step 6: Verify**

Run: `grep -o 'name="consulting-intake"\|data-netlify="true"\|id="intake"\|theme-green' services.html | sort | uniq -c`
Expected: `consulting-intake` ×2, `data-netlify="true"` ×1, `id="intake"` ×1, `theme-green` ×1.

Run the tag-balance node check from Task 3 Step 4 (swap filename). Expected all OK.

- [ ] **Step 7: Browser check** — green accent, capability cards + rate band + tiers + form all render; form fields labeled; mobile stacks cleanly.

- [ ] **Step 8: Commit**

```bash
git add services.html
git commit -m "Add merged Services page (capabilities + rates + intake, green theme)"
```

---

## Task 5: About page (`about.html`) — Bronze

**Files:**
- Create: `about.html`
- Reference: `index.html` lines 466–514 (`#about`)

- [ ] **Step 1: Scaffold** `<body class="theme-bronze">`, nav "About" active. Head: title `About — Keystone Marcy | KM Consulting`, description (bio summary), canonical `/about`.

- [ ] **Step 2: Page header** — icon (user), eyebrow `ABOUT`, title `From reading the numbers to building the tools.`, intro: one-sentence positioning (FP&A leader who ships the fixes).
Icon paths (user): `<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>`

- [ ] **Step 3: Move About content** — copy the `.about` block (bio `.about-bio` + `.about-aside` with `.skills-card` Core Competencies + `.certs`) from `index.html` lines 466–514 into `about.html`. Drop the duplicate section eyebrow/title (the page header covers it) or keep `<h2>` as a sub-heading — keep just the bio + aside.

- [ ] **Step 4: Fix the leftover-yellow skill chips** (pre-existing bug surfaced earlier): in `assets/site.css` the `.skill` chip uses hardcoded yellow `rgba(245,197,24,…)`. Change it to use the accent token so chips match each page's theme:

In `assets/site.css`, replace:
```css
    background: rgba(245,197,24,0.08);
    border: 1px solid rgba(245,197,24,0.22);
    color: var(--accent-2);
```
with:
```css
    background: rgba(var(--accent-glow),0.10);
    border: 1px solid rgba(var(--accent-glow),0.28);
    color: var(--accent-1);
```

- [ ] **Step 5: Verify** tag balance (node check). Confirm `grep -c 'skills-card\|certs' about.html` ≥ 2.

- [ ] **Step 6: Browser check** — bronze accent, bio in gray panel, competencies + certs cards; skill chips now bronze-tinted.

- [ ] **Step 7: Commit**

```bash
git add about.html assets/site.css
git commit -m "Add About page (bronze theme) and theme-align skill chips"
```

---

## Task 6: How I Work page (`how-i-work.html`) — Amethyst

**Files:**
- Create: `how-i-work.html`
- Reference: `index.html` lines 515–598 (`#how-i-work`)

- [ ] **Step 1: Scaffold** `<body class="theme-amethyst">`, nav "How I Work" active. Head: title `How I Work — Keystone Marcy | KM Consulting`, description (working style / personality dossier), canonical `/how-i-work`.

- [ ] **Step 2: Page header** — icon (compass), eyebrow `HOW I WORK`, title `Strategic Creator — where finance meets creative.`, intro: the `.hiw-lead` sentence.
Icon paths (compass): `<circle cx="12" cy="12" r="10"/><polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"/>`

- [ ] **Step 3: Move How-I-Work content** — copy the `#how-i-work` inner content from `index.html` lines 515–598 (the `.hiw-supers` 3 cards, `.hiw-subhead` + `.hiw-frameworks` score bars incl. the SoulTrace row, the lead/collaborate blurb, and `.hiw-fits` chips) into `how-i-work.html`. Use the `.hiw-lead` paragraph as the page intro instead of duplicating it.

- [ ] **Step 4: Verify** tag balance (node check); `grep -c 'hiw-card\|hiw-fw' how-i-work.html` ≥ 6.

- [ ] **Step 5: Browser check** — amethyst accent, superpower cards, framework score bars (fills use `--grad-accent` → amethyst), fit chips.

- [ ] **Step 6: Commit**

```bash
git add how-i-work.html
git commit -m "Add How I Work page (amethyst theme)"
```

---

## Task 7: Experience page (`experience.html`) — Teal

**Files:**
- Create: `experience.html`
- Reference: `index.html` lines 225–300 (`#experience`)

- [ ] **Step 1: Scaffold** `<body class="theme-teal">`, nav "Experience" active. Head: title `Experience — Keystone Marcy | KM Consulting`, description (career across manufacturing/retail/asset mgmt), canonical `/experience`.

- [ ] **Step 2: Page header** — icon (timeline/briefcase), eyebrow `EXPERIENCE`, title `A finance career across manufacturing, retail, and asset management.`, intro: short framing sentence (full P&L ownership, FP&A leadership, builder).
Icon paths (briefcase): `<rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>`

- [ ] **Step 3: Move the timeline** — copy the `.xp-list` (all `.xp-item` articles) from `index.html` lines 225–300 into `experience.html`. The timeline rail (`.xp-list::before`) uses `var(--accent-1)` → teal automatically. NOTE: line 749 of `assets/site.css` has a hardcoded yellow in the rail gradient `linear-gradient(var(--accent-1), rgba(245,197,24,0.15))` — replace `rgba(245,197,24,0.15)` with `rgba(var(--accent-glow),0.15)` so the rail fades in the page accent.

- [ ] **Step 4: Add a résumé CTA** at the bottom: a `.btn btn-primary` download of `Keystone-Marcy-Resume.pdf` + a ghost link to `contact.html`.

- [ ] **Step 5: Verify** tag balance; `grep -c 'xp-item' experience.html` = 5 (current count of roles incl. the H-E-B split).

- [ ] **Step 6: Browser check** — teal accent, timeline rail + nodes teal, all roles present, résumé CTA works.

- [ ] **Step 7: Commit**

```bash
git add experience.html assets/site.css
git commit -m "Add Experience page (teal theme) and theme-align timeline rail"
```

---

## Task 8: Contact page (`contact.html`) — Clay

**Files:**
- Create: `contact.html`
- Reference: `index.html` lines 619–662 (`#contact`)

- [ ] **Step 1: Scaffold** `<body class="theme-clay">`, nav "Contact" active (the nav-cta link gets `active` too). Head: title `Contact — Keystone Marcy | KM Consulting`, description, canonical `/contact`.

- [ ] **Step 2: Page header** — icon (mail), eyebrow `CONTACT`, title `Let's build something useful.`, intro: the current `.contact-sub` sentence.
Icon paths (mail): `<rect x="2" y="4" width="20" height="16" rx="2"/><path d="m22 7-10 5L2 7"/>`

- [ ] **Step 3: Move the contact section** — copy the `<section ... id="contact">` inner content from `index.html` lines 619–662 (the `contact` Netlify form + `.contact-availability` + `.contact-or`/`.contact-ctas` with résumé/email/GitHub/LinkedIn) into `contact.html`. Keep `name="contact"` unchanged (preserves the existing Netlify form + notifications). Keep the `form[name="contact"]` `track()` hook — use the index.html script's contact-form block (or add a small hook).

- [ ] **Step 4: Verify**

Run: `grep -o 'name="contact"\|data-netlify="true"\|theme-clay' contact.html | sort | uniq -c`
Expected: `name="contact"` ×2 (form + hidden form-name), `data-netlify="true"` ×1, `theme-clay` ×1.
Run tag-balance node check. Expected all OK.

- [ ] **Step 5: Browser check** — clay accent, contact form + secondary CTAs render; form labeled.

- [ ] **Step 6: Commit**

```bash
git add contact.html
git commit -m "Add Contact page (clay theme)"
```

---

## Task 9: Slim the Home page (`index.html`) — Cyan

**Files:**
- Modify: `index.html`

- [ ] **Step 1: Remove migrated sections.** Delete from `index.html`: `#experience` (225–300), `#work` bento (302–436), `#services` (438–465), `#about` (466–514), `#how-i-work` (515–598), the commented `#testimonials` scaffold (600–617), and `#contact` (619–662). KEEP: hero (118–147), `uv-social-proof` logo wall (149–158), `uv-marquee` (160–203), `uv-stats` (205–223).

- [ ] **Step 2: Update Home nav + footer** to the canonical 7-link set from Task 2 (links to `work.html`, `services.html`, etc. — NOT in-page anchors), keeping the "Home" link `class="active" aria-current="page"`. Update the footer links likewise.

- [ ] **Step 3: Add Featured Work strip** after the stats band:

```html
<section class="section container" aria-label="Featured work">
  <p class="section-eyebrow">Selected work</p>
  <h2 class="section-title">A few things I've shipped.</h2>
  <div class="services">
    <a class="service-card reveal" href="work/d365.html" style="text-decoration:none;color:inherit">
      <h3>D365 ERP Manager Web</h3>
      <p>A Blazor companion that auto-drafts D365 F&amp;O roadmaps, risk logs, and AI status reports.</p>
    </a>
    <a class="service-card reveal" href="work/agentic-os.html" style="transition-delay:60ms;text-decoration:none;color:inherit">
      <h3>Agentic OS Dashboard</h3>
      <p>A zero-dependency cockpit for running and observing multi-agent AI workflows.</p>
    </a>
    <a class="service-card reveal" href="work/codex.html" style="transition-delay:120ms;text-decoration:none;color:inherit">
      <h3>Codex Job Tracker</h3>
      <p>A full-stack app that turns a messy job search into a tracked, searchable pipeline.</p>
    </a>
  </div>
  <p class="services-cta"><a class="btn btn-ghost" href="work.html" data-cta="home_see_work">See all work <span class="btn-arrow" aria-hidden="true">&rarr;</span></a></p>
</section>
```

- [ ] **Step 4: Add "What I do" services teaser** after Featured Work:

```html
<section class="section container section-tint" aria-label="Services">
  <p class="section-eyebrow">Services</p>
  <h2 class="section-title">Need the tooling, not just the analysis?</h2>
  <p class="page-intro">I build AI &amp; Excel automation and custom finance apps — by the hour or as a scoped project.</p>
  <p class="services-cta"><a class="btn btn-primary" href="services.html" data-cta="home_services">Explore services <span class="btn-arrow" aria-hidden="true">&rarr;</span></a></p>
</section>
```

- [ ] **Step 5: Add closing Contact CTA** before `</main>`:

```html
<section class="section container" aria-label="Get in touch">
  <h2 class="contact-title">Let's talk.</h2>
  <p class="contact-sub">Hiring, consulting, or comparing notes on FP&amp;A and AI in finance — I'd like to hear from you.</p>
  <p class="services-cta">
    <a class="btn btn-primary" href="contact.html" data-cta="home_contact">Get in touch <span class="btn-arrow" aria-hidden="true">&rarr;</span></a>
    <a class="btn btn-ghost" href="Keystone-Marcy-Resume.pdf" download data-resume-download data-cta="home_resume">Download résumé <span class="btn-arrow" aria-hidden="true">&darr;</span></a>
  </p>
</section>
```

- [ ] **Step 6: Sticky-CTA + script** — keep the existing Home sticky-CTA but point its Contact ghost link to `contact.html`. The script's scrollspy (keyed to `#`-anchor nav links) now finds none and no-ops — harmless; KEEP the script (stats count-up + reveal still needed). The sticky-CTA hide-over-`#contact` no longer applies (no `#contact` on Home) — it will just stay shown after hero; acceptable. Optionally point its observer to the closing CTA section by giving that section `id="contact-cta"` and leaving the JS as-is (skip for simplicity).

- [ ] **Step 7: Verify**

Run: `grep -c 'id="experience"\|id="work"\|id="about"\|id="how-i-work"\|id="contact"' index.html`
Expected: 0 (all migrated).
Run: `grep -o 'work.html\|services.html\|about.html\|experience.html\|contact.html\|how-i-work.html' index.html | sort | uniq -c`
Expected: each present (nav + footer + teasers).
Run tag-balance node check on `index.html`. Expected all OK.

- [ ] **Step 8: Browser check** — Home is short: hero → stats → logos → marquee → featured work → services teaser → closing CTA. Cyan accent. All nav/footer links go to the new pages.

- [ ] **Step 9: Commit**

```bash
git add index.html
git commit -m "Slim Home page to highlights + featured-work/services/contact teasers"
```

---

## Task 10: Nav consistency sweep across `/work/*` detail pages

**Files:**
- Modify: `work/d365.html`, `work/codex.html`, `work/agentic-os.html`, `work/aurora.html`, `work/creator.html`, `work/ml.html`

- [ ] **Step 1: Replace each detail page's nav `<ul class="nav-links">`** so it matches the new 7-link set, using `../` prefixes:

```html
<ul class="nav-links" id="navLinks">
  <li><a href="../index.html">Home</a></li>
  <li><a href="../work.html">Work</a></li>
  <li><a href="../services.html">Services</a></li>
  <li><a href="../about.html">About</a></li>
  <li><a href="../how-i-work.html">How I Work</a></li>
  <li><a href="../experience.html">Experience</a></li>
  <li><a class="nav-cta" href="../contact.html" data-cta="nav_contact">Contact</a></li>
</ul>
```

Do this with a scripted replace (PowerShell) since the block is identical across files. Match the existing `<ul class="nav-links" id="navLinks"> … </ul>` block and swap it.

- [ ] **Step 2: Update each detail page's footer links** to the same set with `../` prefixes (Work/Services/Experience/About/Contact → `../work.html` etc.). Scripted replace of the footer `<nav class="footer-links">…</nav>`.

- [ ] **Step 3: Update the "Back to work" back-link** on each detail page: it currently points to `../index.html#work`; change to `../work.html`.

Run (PowerShell): replace `"../index.html#work"` → `"../work.html"` across `work/*.html`.

- [ ] **Step 4: Verify**

Run: `grep -rl 'index.html#services\|index.html#about\|index.html#how-i-work\|index.html#experience\|index.html#contact\|index.html#work' work/ ; echo "exit:$?"`
Expected: no files listed (all old anchors gone).
Run: `grep -c 'how-i-work.html' work/d365.html`
Expected: 1.

- [ ] **Step 5: Commit**

```bash
git add work/
git commit -m "Update /work/* nav, footer, and back-links to the multi-page nav"
```

---

## Task 11: Redirect `/consulting` → `/services`, delete old page, sitemap

**Files:**
- Modify: `netlify.toml`
- Delete: `consulting.html`
- Modify: `sitemap.xml`

- [ ] **Step 1: Add redirect** to `netlify.toml` (append):

```toml
[[redirects]]
  from = "/consulting"
  to = "/services"
  status = 301
  force = true

[[redirects]]
  from = "/consulting.html"
  to = "/services"
  status = 301
  force = true
```

- [ ] **Step 2: Delete the old page**

```bash
git rm consulting.html
```

- [ ] **Step 3: Rewrite `sitemap.xml`** to list all pages. Replace its `<urlset>` body with `<url><loc>` entries for: `/`, `/work`, `/services`, `/about`, `/how-i-work`, `/experience`, `/contact`, and the 6 detail pages `/work/d365`, `/work/codex`, `/work/agentic-os`, `/work/aurora`, `/work/creator`, `/work/ml`. Use `<lastmod>2026-05-28</lastmod>` on each.

- [ ] **Step 4: Verify**

Run: `grep -c '<loc>' sitemap.xml`
Expected: 13.
Run: `grep -c 'consulting' netlify.toml`
Expected: ≥ 2.

- [ ] **Step 5: Commit**

```bash
git add netlify.toml sitemap.xml
git commit -m "Redirect /consulting to /services, remove old page, rebuild sitemap"
```

---

## Task 12: Graphics — inline SVG (icons done; add stat donut + dividers)

**Files:**
- Modify: `index.html` (stats area), `assets/site.css`

Page-header SVG icons are already added per page (Tasks 3–8). This task adds the lightweight data-viz accents.

- [ ] **Step 1: Add a CSS conic-gradient "metric ring"** style to `assets/site.css` (append):

```css
.metric-ring{ --pct:75; width:120px; height:120px; border-radius:50%;
  background:conic-gradient(var(--accent-1) calc(var(--pct)*1%), var(--surface-2) 0);
  display:grid; place-items:center; margin:0 auto .75rem; }
.metric-ring::after{ content:''; width:84px; height:84px; border-radius:50%; background:var(--bg-0); grid-area:1/1; }
.metric-ring > span{ grid-area:1/1; z-index:1; font-family:var(--font-mono); font-weight:700; color:var(--accent-1); }
.metric-rings{ display:grid; grid-template-columns:repeat(3,1fr); gap:1rem; margin-top:1.5rem; }
@media (max-width:640px){ .metric-rings{ grid-template-columns:1fr; } }
```

- [ ] **Step 2:** On `index.html`, inside the `uv-stats` section, after the existing stat numbers, this is OPTIONAL visual reinforcement — SKIP if the count-up band already reads well. (YAGNI: the count-up stats already cover this; only add `.metric-rings` if the Home looks sparse after slimming.) If added, render 3 rings (e.g. 33% faster reporting, 92% shrinkage reduction, etc.) with `style="--pct:33"`.

- [ ] **Step 3: Add a subtle section divider** style and apply between Home sections:

```css
.divider{ height:1px; max-width:200px; margin:0 auto; background:linear-gradient(90deg,transparent,var(--border-strong),transparent); }
```

- [ ] **Step 4: Verify** — open Home; rings (if added) and dividers render in the page accent; no layout breakage.

- [ ] **Step 5: Commit**

```bash
git add index.html assets/site.css
git commit -m "Add SVG/CSS metric rings + dividers for Home graphics"
```

---

## Task 13: Graphics — generated raster (Home hero feature + per-page OG cards)

**Files:**
- Create/modify: `scripts/make-page-graphics.ps1` (System.Drawing), outputs to `images/` and `images/og/`
- Modify: each page `<head>` OG/Twitter `image` tags

- [ ] **Step 1: Write `scripts/make-page-graphics.ps1`** modeled on `scripts/make-og.ps1`. For each page generate a 1200×630 PNG OG card: near-black `#0a0a0a` bg, the page's accent color band/orb, "KM Consulting" + page title text, exported to `images/og/<page>.png`. Generate one Home hero feature graphic `images/hero-motif.webp` (abstract data-automation motif: cyan nodes/lines on dark) — or reuse the SVG `.bg-mesh` and SKIP raster hero if SVG suffices (YAGNI).

Run: `pwsh -File scripts/make-page-graphics.ps1`
Expected: PNGs written under `images/og/`.

- [ ] **Step 2: Convert OG PNGs to keep size reasonable** (optional) and wire each page's `<head>` `og:image`/`twitter:image` to its `images/og/<page>.png` (absolute URL `https://keystonemarcy.pages.dev/images/og/<page>.png`).

- [ ] **Step 3: Verify** — each `images/og/<page>.png` exists and is 1200×630; OG tags reference the right file per page.

Run: `ls images/og/`
Expected: home/work/services/about/how-i-work/experience/contact `.png`.

- [ ] **Step 4: Commit**

```bash
git add scripts/make-page-graphics.ps1 images/og/ images/hero-motif.webp
git commit -m "Generate per-page OG cards and Home hero motif"
```

> If raster generation proves heavy or low-value, this whole task may be deferred — the SVG graphics in Task 12 + existing `images/og.png` are sufficient for launch. Decide during execution.

---

## Task 14: Full local verification

- [ ] **Step 1: Link audit** — every nav/footer link on every root page resolves to an existing file:

Run:
```bash
for p in index work services about how-i-work experience contact; do
  echo "== $p.html =="; grep -oE '(href="(index|work|services|about|how-i-work|experience|contact)\.html")' $p.html | sort | uniq -c
done
```
Expected: each page references all 7 targets (nav) + footer subset.

- [ ] **Step 2: Theme audit** — each page has exactly its theme class:

Run: `for p in work services about how-i-work experience contact; do printf "%s: " $p; grep -o 'theme-[a-z]*' $p.html | head -1; done`
Expected: work→theme-indigo, services→theme-green, about→theme-bronze, how-i-work→theme-amethyst, experience→theme-teal, contact→theme-clay.

- [ ] **Step 2b: A11y** — each page has `skip-link` + `id="main"`:

Run: `for p in index work services about how-i-work experience contact; do printf "%s: " $p; grep -c 'class="skip-link"' $p.html; done`
Expected: 1 each.

- [ ] **Step 3: Open every page in the browser** and confirm: distinct accent, shared nav/footer, active tab highlighted, responsive, forms labeled, no console errors.

- [ ] **Step 4: Fix anything found, commit fixes.**

---

## Task 15: Deploy to both Netlify sites + post-deploy checks

- [ ] **Step 1: Push canonical** (auto-deploys keystonemarcy.pages.dev):

```bash
git push origin main
```

- [ ] **Step 2: Deploy sibling** (broken auto-deploy → manual `--dir .`, with junk moved out/restored):

```bash
cd /c/Users/keyst/Business-Landing-Page
mkdir -p /c/tmp/bl-stash
mv preview-*.html /c/tmp/bl-stash/ 2>/dev/null; mv ruvector.db /c/tmp/bl-stash/ 2>/dev/null
netlify deploy --prod --dir . --site 55407d90-c8c3-4948-a7e4-644aeba1860a
mv /c/tmp/bl-stash/preview-*.html . 2>/dev/null; mv /c/tmp/bl-stash/ruvector.db . 2>/dev/null
```

- [ ] **Step 3: Post-deploy URL checks** (both sites):

```bash
for base in https://keystonemarcy.pages.dev https://keystonemarcykmconsulting.netlify.app; do
  echo "== $base =="
  for path in / /work /services /about /how-i-work /experience /contact /consulting /ruvector.db; do
    printf "%s%s -> " "$base" "$path"; curl -s -o /dev/null -w "%{http_code}\n" "$base$path"
  done
done
```
Expected: all real pages 200; `/consulting` 301→/services (curl shows 301 or final 200 with `-L`); `/ruvector.db` 404.

- [ ] **Step 4: Confirm form still registered** — `/services` page source contains `name="consulting-intake"` + `data-netlify="true"`.

---

## Task 16: Update docs (CLAUDE.md + memory)

- [ ] **Step 1:** Update the Business Landing Page section of `C:\Users\keyst\CLAUDE.md` and `C:\Users\keyst\.claude\projects\C--Users-keyst\memory\project_business_landing_page.md`: new multi-page architecture (Home + 6 pages), the per-tab theme classes + palette, the `/consulting`→`/services` redirect (consulting.html removed), the merged Services page (still hosts the `consulting-intake` form), and the new sitemap. Note the nav is duplicated across ~13 files (edit via scripted replace).

- [ ] **Step 2: Commit** (CLAUDE.md/memory are outside the repo — no git commit; just save).

---

## Self-review notes
- **Spec coverage:** page set (Tasks 3–9), merge+redirect (4,11), per-tab colors (1), Home slim + additions (9), graphics SVG+raster (12,13), SEO/sitemap (11, page heads), deploy hygiene (15), docs (16). ✓
- **Form continuity:** `consulting-intake` (Services) and `contact` (Contact) keep their exact `name=` so Netlify registrations/notifications survive. ✓
- **Local-vs-Netlify links:** bare `.html` hrefs work under `file://` and Netlify prettifies them. ✓
- **Leftover-yellow cleanup:** `.skill` chips (Task 5) and timeline rail (Task 7) re-pointed to `var(--accent-glow)`/`var(--accent-1)`. ✓
