# Business Landing Page — Resource-Refinement Design

**Date:** 2026-05-23
**Status:** Approved (design)
**Source request:** Apply design resources from the cloned `awesome-design` repo to the Business Landing Page, but only where they align with the recruiter-first market analysis and drive traffic.

## Context

The page (`index.html`, single-file vanilla HTML/CSS/JS, no build step) is already recruiter-first and hits almost every "essential" element the market analysis ranks highest (specific headline, audience subhead, one dominant CTA = résumé, employer trust wall, stats band, real headshot, low-friction Netlify form, résumé download, semantic/accessible markup, JSON-LD + OG + sitemap).

**Key insight that bounds scope:** `awesome-design` is mostly a directory of *decorative* resources (stock photos, mockup generators, color tools, icon sets). The market analysis explicitly warns **against** decorative filler imagery and AI/stock photos in the trust path, and says real screenshots/charts are what proof sections need (already present). Therefore this round applies only the *narrow, evidence-aligned* subset of those resources. No stock photography is added.

**Reference:** market analysis at `OneDrive/Pictures/WEBSITE/Business Landing Page/deep-research-report.md`.

## Goals

1. Improve recruiter first-impression and proof credibility.
2. Drive traffic via measurable performance (Core Web Vitals) gains.
3. Make zero change that conflicts with the evidence base.

## Non-goals (flagged, not done this round)

- **Testimonials** — the one *essential* element still missing; needs the user's real LinkedIn recommendations. Block already exists (commented) and stays ready.
- **Activating GA4 / Microsoft Clarity** — needs the user's account IDs. Scaffolding stays in place.
- No new content sections, no copy rewrites, no layout restructure.

## Workstreams

### A. Performance / speed pass (primary traffic driver)

Evidence: load time 1s→10s raises bounce 123%; CWV (LCP ≤ 2.5s) is a Google ranking factor. Current image payload ≈ **748 KB across 8 files**.

- Convert the 5 project screenshots (`proj-d365web.png`, `proj-codex.png`, `proj-creator.png`, `proj-agent.png`, `proj-ml.png`) from PNG → **WebP** (quality ~80) using Node `sharp` (Node + npx are available locally; ImageMagick/cwebp are not). Update each `<img src>` to the `.webp`. Expected ~532 KB → ~200 KB.
- Resize + WebP the hero **LCP** image: `headshot-about.jpg` is a 1024² JPG displayed at ≤480px. Produce `headshot-about.webp` at ~960px wide, update the `<img src>` **and** the `<link rel="preload" as="image">` (`href` → `.webp`, add `type="image/webp"`). Expected ~92 KB → ~25 KB.
- `og.png` stays PNG (social scrapers don't reliably read WebP). Optimize in place if a meaningful reduction is available; otherwise leave.
- **Delete** unused `headshot-hero.jpg` (99 KB) — hero uses `headshot-about.jpg`; the file is only deploy bloat (Netlify publishes all files in the dir).
- WebP is replaced outright (no `<picture>` PNG fallback) — WebP support is universal in target browsers (2026). Original PNG/JPG remain in git history if ever needed.

**Acceptance:** total referenced image payload roughly halved; hero LCP image < 30 KB; no broken images on desktop or mobile widths; deploy no longer includes `headshot-hero.jpg`.

### B. Proof polish — CSS browser chrome on Work screenshots

Pure-CSS browser frame (no added bytes), user-selected "chrome + URL" style: a top bar with three traffic-light dots and a faint label/URL pill, wrapping each `.card-image` in the `#work` bento.

- New wrapper element (e.g. `.shot`) containing a `.shot-bar` (3 dots + `.shot-url` label) above the existing `<img class="card-image">`.
- The live Codex card shows its real URL (`kmcaijobtracker.netlify.app`); display-only cards show a short descriptive label (e.g. `d365 · roadmap`, `agent-os`, `creator`, `ml · predicted vs actual`).
- Chrome is decorative → `aria-hidden="true"` on the bar; the existing descriptive `alt` text carries the meaning.
- Must preserve current responsive behavior (flagship/wide/banner spans, image heights, `object-position`).

**Acceptance:** every Work card screenshot sits inside a browser frame; layout unchanged at desktop/tablet/mobile breakpoints; no accessibility regression.

### C. Color & contrast audit

Pre-check indicates the palette is largely WCAG-AA compliant (`--text-muted #5b5d68` ≈ 6.4:1, `--accent-1 #1e40af` ≈ 6.3:1 on white).

- Compute contrast for every text/background pair actually used (including text over `--surface-translucent` and over `--surface-2` tints, small mono labels, button text).
- Fix any pair below 4.5:1 (likely none or one borderline translucent-surface case) by nudging the token, not redesigning.
- Confirm interactive elements read as interactive (accent on links/buttons, visible `:focus-visible`).

**Acceptance:** a short report of measured ratios; all body/UI text ≥ 4.5:1; any change is a minimal token tweak documented in the report.

### D. Icon system

Inline SVG icons (Tabler/Feather, MIT-licensed) matching the existing GitHub/LinkedIn inline-SVG pattern — no icon font, no CDN.

- One small accent-colored glyph per **Services** card (01 Custom apps → e.g. `app-window`; 02 AI workflows → e.g. `robot`/`cpu`; 03 Excel/ERP → e.g. `table`/`file-spreadsheet`).
- Icon sits with the existing `.service-num`, subordinate to the heading; `aria-hidden="true"`.

**Acceptance:** three consistent icons render inline; no new network requests; visual weight stays below the card titles.

## Constraints & conventions

- Edit `index.html` in place; keep the single-file, no-build, no-CDN architecture.
- Follow existing token/utility patterns (`--accent-1`, `.btn`, `.card-image`, inline SVG).
- Respect `prefers-reduced-motion` (no new animation that ignores it).

## Verification

No automated test suite (manual by approved project spec). Verify via:
1. `git diff` review.
2. Open `index.html` in a browser at desktop + mobile widths; confirm all images load as WebP, browser chrome renders, icons render, no layout breakage.
3. Confirm referenced image payload dropped (compare byte sizes) and `headshot-hero.jpg` is gone.
4. Contrast ratios reported and ≥ 4.5:1.

## Deploy (when user approves shipping)

`git push origin main && netlify deploy --prod --dir .` — and remember **both** Netlify sites auto-deploy from this repo (`keystonemarcy` + `keystonemarcykmconsulting`). Check `git status` for stray untracked files before `netlify deploy` (it uploads the whole dir).
