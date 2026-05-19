# Business Landing Page — UV.club-inspired Enhancements

**Date:** 2026-05-18
**Status:** Approved (pending user review of spec doc)
**Scope:** Targeted enhancements to the existing single-file vanilla HTML/CSS/JS site at `index.html`. Inspired by [ultraviolet.club](https://www.ultraviolet.club/) — premium dark aesthetic, editorial typography, image-forward credibility.

## Goals

1. Add personal presence (headshot) so the site has a face, not just text.
2. Surface real credibility from the resume — employers, certifications, hard numbers.
3. Adopt UV.club's editorial typographic scale and quiet premium motion (marquee, glow, fragmented headlines).
4. Preserve everything that already works: bento Work grid, Services row, color tokens, reveal-on-scroll, accessibility scaffolding.

## Non-goals

- No rebuild of the bento Work grid.
- No swap of color palette, fonts, or layout tokens (`--bg-0`, `--accent-1`, `--accent-2`, `--font-display`, `--font-body`).
- No new build step, framework, or CDN script. Stays single-file vanilla HTML/CSS/JS.
- No real client logos invented. Social proof is text-only ("Lancer Worldwide · H-E-B · Alliance Bernstein") sourced from the resume.

## Architecture

The site stays a single `index.html`. Each enhancement is an additive section or in-place modification:

```
<header class="nav">                    ← unchanged
<main>
  <section.hero>                        ← REDESIGNED: editorial split, adds headshot
  <section.social-proof>                ← NEW
  <section.marquee>                     ← NEW
  <section#work>                        ← unchanged (bento grid stays)
  <section.stats>                       ← NEW
  <section#services>                    ← unchanged
  <section#about>                       ← MODIFIED: 2nd headshot + certifications row
  <section#contact>                     ← MODIFIED: dual-email CTAs
</main>
<footer>                                ← unchanged
```

CSS additions are scoped: each new section gets its own `.uv-*` or section-named block; no edits to `.bento*`, `.services*`, `.btn*` rules except where explicitly noted.

## Component designs

### 1. Hero — Editorial split

```
┌──────────────────────────────────────────────────────────────┐
│ • Available for select consulting work                       │
│                                                              │
│ ERP                            ╭──────────────────╮          │
│ CONSULTANT                     │   HEADSHOT 4     │          │
│ TURNED                         │  (Image 4, dark  │          │
│ BUILDER.                       │   studio, navy)  │          │
│                                ╰──────────────────╯          │
│ Apps, AI workflows, & Excel      ↑ violet/teal glow ring     │
│ add-ins for the way teams work.                              │
│                                                              │
│ [ See my work → ]  [ Get in touch ]                          │
└──────────────────────────────────────────────────────────────┘
```

- Layout: CSS grid, two columns `1.2fr 1fr`, gap `clamp(2rem, 4vw, 4rem)`, align-items center.
- Headline: 4 stacked lines using `<span class="hero-line">` per line. Font size `clamp(2.8rem, 7vw, 5.6rem)`. Line-height `0.95`. Letter-spacing `-0.04em`. Last line `BUILDER.` retains existing `.accent` gradient class.
- Headshot: `<img src="images/headshot-hero.jpg" alt="Keystone Marcy — portrait" width="960" height="1200" loading="eager" fetchpriority="high">`. Aspect-ratio 4/5. Rounded `var(--r-lg)`. Object-fit cover. Width caps at 480px desktop.
- Glow ring: a `::before` on the headshot wrapper, position absolute, inset -24px, border-radius `calc(var(--r-lg) + 24px)`, background `var(--grad-accent)`, opacity `0.35`, filter `blur(40px)`, z-index `-1`.
- Eyebrow pill, sub-copy, and CTAs preserved exactly.
- Mobile (`max-width: 800px`): grid becomes single column; headshot stacks above headline at width 280px max; headline scale drops to `clamp(2.4rem, 9vw, 3.4rem)`.

### 2. Social-proof strip

Sits directly after hero, `<section class="uv-social-proof">`.

```
TRUSTED BY TEAMS AT
LANCER WORLDWIDE   ·   H-E-B   ·   ALLIANCE BERNSTEIN
```

- Eyebrow line: mono, `--text-muted`, letter-spacing `0.18em`, uppercase, font-size `0.75rem`.
- Brand line: `--font-display`, `--text-dim`, font-weight `600`, font-size `clamp(1rem, 2vw, 1.4rem)`, letter-spacing `0.04em`. Dots between names use the existing pattern of inline `·` separators.
- No fake logos. Type-only.
- Padding: `clamp(1.5rem, 3vw, 2.5rem)` top/bottom. Centered text. Container width unchanged.

### 3. Marquee skill ticker

Sits between social-proof and `#work`. Two rows, second row offset.

Row 1: `D365 Finance & Ops · Excel VBA · Power Query · NetSuite · Prophix · Hyperion · MicroStrategy · SharePoint`
Row 2: `CrewAI · Next.js · FastAPI · Blazor · .NET 8 · Python · XGBoost · scikit-learn · Playwright`

- Implementation: pure CSS `@keyframes marquee` translating `transform: translateX(-50%)`. Content duplicated inline so the loop is seamless.
- Speed: row 1 ~40s, row 2 ~55s (different speeds = parallax-ish feel).
- `:hover` on the track → `animation-play-state: paused`.
- Edge mask: `mask-image: linear-gradient(90deg, transparent, black 8%, black 92%, transparent)`.
- Reduced motion: `@media (prefers-reduced-motion: reduce)` sets `animation: none` and replaces with a static, no-overflow line (or first-screen-only).
- Item styling: each pill uses existing `.skill` token rules (padding, surface-2 bg, border). Inline-flex on the track.

### 4. Stats / credentials band

Sits after `#work`, before `#services`, as `<section class="uv-stats">`.

```
7 yrs                2                $1.5M             92%
FINANCE +            ERP              INVENTORY         LOSS
ACCOUNTING           IMPLEMENTATIONS  MANAGED           REDUCTION
```

- Grid: `repeat(4, 1fr)` desktop, `repeat(2, 1fr)` ≤800px, `1fr` ≤480px.
- Number: `--font-display`, font-weight `700`, font-size `clamp(2.6rem, 5vw, 4.2rem)`, letter-spacing `-0.03em`, gradient text using existing `--grad-accent` (same technique as `.hero-title .accent`).
- Label: mono, uppercase, letter-spacing `0.15em`, `--text-muted`, font-size `0.72rem`, line-height `1.4`, 2-3 lines allowed.
- Each cell: align left, gap `0.6rem` between number and label.
- Section padding matches existing `.section` rule.

### 5. About section — headshot + certifications

In the existing `#about > .about` grid:

- Right column (currently `.skills-card`) becomes a vertical stack:
  1. `<img class="about-headshot" src="images/headshot-about.jpg" alt="Keystone Marcy" width="600" height="600" loading="lazy">` — square, rounded `var(--r-md)`, max-width 280px.
  2. Existing `.skills-card` block.
  3. New `<div class="certs">` with eyebrow + badge row:

```
CERTIFICATIONS & EDUCATION
[AMA®] [ChFM®] [GAFM Advisor] [MA Economics — UTSA (Fall 2026)] [BS Finance — Evansville]

MA Economics at UTSA is in progress with expected completion Fall 2026. Badge text reads "MA Economics — UTSA (Fall 2026)".
```

- Cert badges: reuse `.skill` styling (surface-2 bg, border, rounded sm, padding). Smaller font (`0.78rem`).
- Mobile (`max-width: 800px`): About grid collapses to single column as today; image scales to max-width 220px.

### 6. Contact — dual email

The `.contact-ctas` row becomes:

```
[ Email (business) → ]   [ Personal email ]   [ GitHub ]   [ LinkedIn ]
```

- Primary `.btn-primary` → `mailto:kmarcy@KMConsulting995.onmicrosoft.com?subject=Hello%20Keystone`
- New `.btn-ghost` → `mailto:keystone.marcy@outlook.com?subject=Hello%20Keystone`
- GitHub + LinkedIn `.icon-btn` unchanged.

## Data flow

None. Site is static. No new state, no fetch, no localStorage.

## Asset requirements

Two source headshots are needed. Originals (2048×2048 PNG/JPG, supplied via chat) are processed by a resize script into the final web-ready outputs.

| Final output path | Source | Treatment |
|-------------------|--------|-----------|
| `images/headshot-hero.jpg` | Image 4 (composed, navy blazer, dark studio) | Resized to 1024×1024, progressive JPEG, quality 82, ≤200 KB |
| `images/headshot-about.jpg` | Image 3 (smiling, navy blazer, dark studio) | Resized to 1024×1024, progressive JPEG, quality 82, ≤120 KB |

**Resize script:** A script (`scripts/resize-headshots.ps1`) will be added during implementation. Process:

1. User saves the two raw 2048×2048 originals into `images/_src/` as `headshot-hero-src.png` (Image 4) and `headshot-about-src.png` (Image 3).
2. Script reads those, downsamples to 1024×1024 using high-quality bicubic resampling, encodes as progressive JPEG at quality 82, and writes the final paths above.
3. Script is idempotent — running it multiple times produces the same output.
4. `images/_src/` is gitignored (raw originals stay local).

The script uses PowerShell + `System.Drawing` (already available on Windows 11, no install required). No external dependencies, no Node/Python.

Implementation will reference these exact paths. If files are missing at build time, browsers will show alt text — degrades gracefully but should be resolved before going live.

## Accessibility

- Headshots get descriptive `alt` text (not just "headshot").
- Marquee track has `aria-label="Skills and tools"` and individual items wrapped in plain `<span>` (not interactive — no keyboard trap).
- Marquee respects `prefers-reduced-motion: reduce` — animation killed.
- Stats numbers stay as plain text (no images), so screen readers read them correctly.
- All new CTAs reuse existing `.btn` classes — focus-visible styles already cover them.
- Color contrast: all new text colors are `--text` (#f7f7ff) or `--text-dim` (#c5c5d5) on `--bg-0` (#0a0a12) — both already pass WCAG AA.

## Performance

- Two new images added. Hero image uses `fetchpriority="high"` + `loading="eager"`; about image uses `loading="lazy"`.
- Marquee is CSS-only (no JS payload).
- No new fonts, libraries, or external requests.
- Expected impact on Lighthouse Performance: ≤3 point dip from hero image bytes; LCP improves because hero image becomes the LCP element with eager loading.

## Testing

1. Visual diff: open `index.html` in Chrome at 1440, 768, 375 widths; confirm each new section renders, headshot loads, marquee scrolls.
2. Reduced motion: enable `prefers-reduced-motion: reduce` in DevTools rendering pane; confirm marquee is static and reveals are instant.
3. Keyboard nav: tab through nav → hero CTAs → bento cards → contact CTAs. Focus rings visible on every step.
4. Lighthouse: rerun `lighthouse-report.report.html` after changes; Accessibility ≥95, Performance ≥85.
5. Mobile Safari quick check via responsive mode — confirm headshot stacks, marquee doesn't overflow, contact buttons wrap.

## Out of scope (deferred)

- Real screenshot for the D365 ERP Manager Web flagship bento card (still uses gradient swatch).
- Real screenshot for the Agent Dashboard card.
- Case-study pages behind `#work` links (still anchor-only).
- Decap CMS or any admin tooling.
- Animated number counters on the stats band (static numbers only — UV.club doesn't use counters either).

## Files touched

- `index.html` — only HTML/CSS/JS file modified
- `images/headshot-hero.jpg` — generated by resize script from `images/_src/headshot-hero-src.png`
- `images/headshot-about.jpg` — generated by resize script from `images/_src/headshot-about-src.png`
- `images/_src/` — new gitignored folder for raw 2048×2048 originals
- `scripts/resize-headshots.ps1` — new PowerShell resize script
- `.gitignore` — updated to ignore `images/_src/`
- `docs/superpowers/specs/2026-05-18-business-landing-uv-enhancements-design.md` — this doc
- `docs/superpowers/plans/2026-05-18-business-landing-uv-enhancements-implementation.md` — implementation plan (next step)
