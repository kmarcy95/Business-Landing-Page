# Business Landing Page — Work Detail Pages Design

**Date:** 2026-05-25
**Status:** Approved (design)
**Source request:** Each card in the "Selected Work" bento (`#work` section of `index.html`) should be clickable. Clicking takes the visitor to a dedicated page about that project, with screenshots and explanations of what each screenshot shows. No card should link directly to the live application.

## Context

The site (`index.html`, single-file vanilla HTML/CSS/JS, no build step, dark charcoal+yellow theme) currently has 6 cards in the `#work` section. Five of them are display-only `<article>` elements; one (Codex Job Tracking App) is an `<a>` element that opens the external live app `kmcaijobtracker.netlify.app`. The user has decided all six should now open dedicated detail pages — pure portfolio/case-study mode, no direct app links anywhere.

Each detail page is a "standard depth" walkthrough — substantive but shippable — using a **section-stacked case-study layout** (hero screenshot, "Why it exists" paragraph, alternating screenshot/caption rows, tech tags, back-to-work link). The visual treatment matches the existing site (same nav, footer, sticky CTA, browser-chrome `.shot` frames, dark theme).

A `PreToolUse` security hook blocks `innerHTML` assignment on dynamic content. The detail pages are static HTML (no dynamic DOM), so this is not a constraint, but any future JS additions on these pages must use `createElement`/`textContent`.

## Goals

1. Let recruiters click any project card and learn how the app works without leaving the site or needing a live demo.
2. Keep the existing landing page visually unchanged except for the card link behavior.
3. Avoid content duplication: reuse the existing style system across all 7 pages.
4. Match the site's existing brainstorm → spec → plan → execute workflow.

## Non-goals (flagged, not done this round)

- **No analytics events** on detail-page CTAs. GA4/Clarity scaffolding stays inactive (no IDs).
- **No `<picture>` fallbacks** for screenshots — site already commits to WebP everywhere.
- **No in-app deep walkthroughs of Codex** (login-gated). Codex ships with the existing hero + 1-2 public-landing shots unless the user supplies in-app screenshots in a later pass.
- **No CMS / generation script** for the detail pages — six handwritten HTML files. If we ever exceed ~15 projects, revisit.
- **No content for projects not currently in the bento.** Aurora, Codex, Creator, D365, Agentic OS, Housing-ML only.

## Architecture

### URL structure

One static HTML file per project under a new `/work/` directory:

| Project | Path |
|---|---|
| D365 ERP Manager Web | `work/d365.html` |
| Codex Job Tracking App | `work/codex.html` |
| Agentic OS Dashboard | `work/agentic-os.html` |
| Creator Dashboard | `work/creator.html` |
| Aurora — Marketing Agency | `work/aurora.html` |
| Housing-Price ML Models | `work/ml.html` |

`.html` extensions kept (no clean-URL rewrites) — simpler, no Netlify config, no breakage if files are opened locally.

### Shared CSS extract

The current `index.html` has ~1,000 lines of inline CSS. Without extraction, every detail page either duplicates that block or diverges visually. So:

- Extract all `<style>` content from `index.html` into a new file: `assets/site.css`.
- Replace the inline block in `index.html` with `<link rel="stylesheet" href="assets/site.css">`.
- Detail pages load the same `assets/site.css`.

No visual change on the landing page. The extract is a mechanical move (one commit, easy to revert).

### Per-page asset folder

Per-project screenshots live under `images/work/<slug>/`:

```
images/work/d365/{hero,walkthrough-1,walkthrough-2,walkthrough-3}.webp
images/work/agentic-os/...
images/work/aurora/...
images/work/creator/...
images/work/ml/...
images/work/codex/{hero}.webp  (others added later if supplied)
```

The existing `images/proj-*.webp` cards already serve as the *bento card thumbnail*; the detail-page hero is a separate, larger, less-cropped capture per page (1440×900). Keeps the cards small/fast while detail pages get richer imagery.

## Detail page template

Every detail page has this exact structure (no per-page variation in skeleton):

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <meta name="theme-color" content="#202024" />
  <meta name="description" content="<per-page>" />
  <link rel="canonical" href="https://keystonemarcy.netlify.app/work/<slug>.html" />
  <!-- OG: hero is the page's OG image -->
  <meta property="og:type" content="article" />
  <meta property="og:title" content="<per-page>" />
  <meta property="og:image" content="https://keystonemarcy.netlify.app/images/work/<slug>/hero.webp" />
  <title><per-page> — Keystone Marcy</title>
  <link rel="stylesheet" href="../assets/site.css" />
  <!-- fonts preconnect same as index.html -->
</head>
<body>
  <!-- Same <nav> as index.html (Work / Services / About / How I Work / Experience / Contact) -->
  <main class="container">
    <p class="back-link"><a href="../#work">← Back to work</a></p>
    <header class="detail-head">
      <p class="section-eyebrow"><PROJECT TAGS, UPPERCASE></p>
      <h1 class="detail-title"><Project Name></h1>
      <p class="detail-subtitle"><one-line subtitle></p>
    </header>

    <figure class="shot detail-hero">
      <div class="shot-bar"><span class="shot-dots"><i></i><i></i><i></i></span><span class="shot-url"><slug></span></div>
      <img src="../images/work/<slug>/hero.webp" alt="<descriptive>" width="1440" height="900" />
    </figure>

    <section class="detail-intro">
      <h2>Why it exists</h2>
      <p><problem the project solves — same voice as the bento card desc but longer></p>
    </section>

    <section class="walkthrough">
      <!-- 3 rows; class .row.flip alternates image side -->
      <div class="wt-row">
        <figure class="shot">…walkthrough-1.webp…</figure>
        <div class="wt-caption"><h3><caption heading></h3><p>What it shows: …</p></div>
      </div>
      <div class="wt-row flip">…walkthrough-2…</div>
      <div class="wt-row">…walkthrough-3…</div>
    </section>

    <section class="detail-tags">
      <p class="section-eyebrow">Built with</p>
      <div class="tag-row"><span class="tag">…</span></div>
    </section>
  </main>
  <!-- Same footer + sticky CTA as index.html -->
</body>
</html>
```

### New CSS classes (added once to `assets/site.css`)

- `.back-link` — top of page, ghost button feel, dark
- `.detail-head` — eyebrow + H1 + subtitle, tighter spacing than the bento
- `.detail-hero` — same `.shot` browser-chrome frame as cards but larger (image height ~480px)
- `.detail-intro` — single-column prose, max-width 70ch, larger leading
- `.walkthrough` — vertical stack of `.wt-row`s, gap 3rem
- `.wt-row` — grid `1fr 1fr` desktop, single column mobile, gap 2rem
- `.wt-row.flip` — visually reverses on desktop (image on right via `grid-template-columns` swap)
- `.wt-caption` — h3 + paragraph, vertical-center alignment in row
- `.detail-tags` — small footer-style block

All existing tokens (`--bg-0`, `--accent-1`, `--shadow-md`, etc.) and existing component classes (`.shot`, `.shot-bar`, `.tag`, `.tag-row`, `.section-eyebrow`, `.container`) are reused as-is.

## Per-page content sources

Each page = 1 hero + 3 walkthrough screenshots. Sources:

| Page | Capture method |
|---|---|
| `d365.html` | Run the live Blazor app on `localhost:5080` via `dotnet run` in `D365ERPManager.Web` (Development env). Capture: Roadmap (hero), Risks/Issues, Milestones, Reports/AI flows. Headless Chrome + sharp WebP. |
| `agentic-os.html` | Run `dashboard.py` (port 8765). Capture via Playwright (tabs need JS clicks): Agents (hero — already exists, recaptured higher-res for hero), Systems, Skills, Workflows. **Skip the Overview tab** — it exposes real personal AI spend, off-brand for an FP&A leader. |
| `aurora.html` | Open the local file in headless Chrome with the `aurora-dark` theme forced (same temp-copy + sed pattern used to capture the bento thumbnail). Capture: Mission Control (hero), CRM, Agents, Campaigns. |
| `creator.html` | Open `C:\Users\keyst\creator-dashboard.html` in headless Chrome. Capture: Home (hero), then Sessions, Insights, Goals as the 3 walkthrough rows. |
| `ml.html` | Use existing PNGs already in `C:\Users\keyst\` — convert to WebP and copy in. Selection: `Correlation_Heatmap.png` (hero), `Feature_Importances_GBR.png`, `Predicted_vs_Actual_GBR.png`, `GarageCars_vs_SalePrice.png`. Zero new capture. |
| `codex.html` | Hero = existing `images/proj-codex.webp` (recropped if needed). 2-3 supplemental shots: capture the public landing/marketing portion only. **Caveat:** if the public portion doesn't carry the in-app cockpit story, page ships thin until the user supplies login-gated shots. |

Captions for each shot follow the same voice as the bento descriptions: 1-2 sentences, plain English, "What it shows: …" framing, recruiter-readable.

## Card behavior change (index.html)

In the `#work` bento section:

- All 6 `<article>` / `<a>` wrappers become `<a>` elements with `href="work/<slug>.html"`.
- The current Codex external `<a href="https://kmcaijobtracker.netlify.app">` is rewritten to `href="work/codex.html"`.
- The "Open live app ↗" footer (`.card-foot .view`) is **removed** from the Codex card. No external-link affordance remains on any card.
- Cards keep all existing classes (`bento-card wide reveal`), `aria-label`, transition delays, screenshots, descriptions, tags. Only the wrapper element + `href` change.

Hover state for clickable cards already exists (existing `.bento-card:hover` lift effect) — no new CSS needed for affordance.

## SEO / sitemap

- `sitemap.xml` updated to list the 6 new URLs.
- Each detail page has its own `<title>`, `<meta description>`, canonical URL, OG image (= the page's hero), Twitter card.
- No JSON-LD on detail pages (the `ProfilePage` JSON-LD stays only on `index.html` — semantically correct).

## Production order

Incremental, with a checkpoint after the proof-of-concept:

1. **CSS extract** — move `<style>` block from `index.html` → `assets/site.css`. Update `index.html` `<head>`. Deploy. Verify no visual regression.
2. **Build D365 detail page** — richest content, easiest to get right. Capture screenshots, write template, write captions. Update card markup to link to it. Deploy.
3. **User reviews D365** — once look + tone approved, batch the rest.
4. **Capture screenshots for the remaining 5** — using each app's preferred capture method (above).
5. **Build the remaining 5 detail pages** from the now-validated template.
6. **Update card markup for all 5** to link to detail pages. Update `sitemap.xml`.
7. **Final deploy + verification** — check all 6 links work on live, OG previews render, mobile layout holds.

Each step ends with a deploy so the live site is always working. The checkpoint after step 2 prevents producing 6 pages in the wrong style.

## Caveats and deferred items

- **Codex content depth** depends on whether the user can supply in-app screenshots later. Default ship: hero + brief description, no deep walkthrough.
- **CSS extract** is a mechanical refactor outside the feature scope but required to avoid duplication; included as Step 1.
- **OG images per page** will be 1440×900 (same as hero). LinkedIn prefers 1200×630 — acceptable since LinkedIn auto-crops, but if rich previews ever look bad, generate dedicated 1200×630 OG cards per page.
- **No analytics** wired (matches site-wide state).
- **Aurora's mission-control screenshot uses seeded demo data** — already confirmed safe to publish.
- **Agentic OS screenshots avoid the Overview tab** to keep real personal AI spend out of public view (FP&A brand protection).

## Acceptance criteria

- All 6 cards in `#work` on the live site become links. Clicking any card navigates to its detail page.
- No card link opens an external app.
- Each detail page renders: header, hero shot, "Why it exists" paragraph, 3 walkthrough rows, tech tags, back-to-work link, shared nav/footer/sticky CTA.
- `index.html` visual rendering is identical to current after the CSS extract.
- `sitemap.xml` includes all 6 new URLs.
- Each detail page passes a basic OG-image fetch (HTTP 200 on the hero WebP).
- Deploy uses the established `netlify deploy --prod --dir .` flow with the same junk-stash hygiene; `images/work/**/*.webp` are tracked in git.
