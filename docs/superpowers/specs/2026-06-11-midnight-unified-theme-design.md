# Midnight unified theme — design spec (2026-06-11)

## Goal
One visual system across the whole Business Landing Page, replacing four competing ones (light-green "Bold Executive" default, 7-hue per-tab accent rainbow, purple-mesh dark homepage hero, plus assorted hardcoded colors). Direction chosen via the brainstorming visual companion (round 1: 5 advisor-informed systems, all rejected; round 2: 5 harmonious systems → **"Midnight" picked**). Advisor input: Paid Social Strategist (kill rainbow/purple, one accent family, no outline-only CTAs) and Feedback Synthesizer (revealed preference = dark + blue family; unify toward the Meridian page).

## The Midnight system — strictly monochromatic blue
One hue, five lightness stops. Clashing is structurally impossible.

| Token | Value | Role |
|---|---|---|
| `--bg-0` | `#0a1220` | ink canvas |
| `--bg-1` | `#0e1a30` | canvas grade end |
| `--surface` | `#13233f` | navy cards |
| `--surface-2` | `#1b3050` | raised navy |
| `--border` | `rgba(126,177,255,.16)` | hairline |
| `--border-strong` | `rgba(126,177,255,.30)` | strong hairline |
| `--accent-1` | `#2f6bdb` | royal — CTAs, links, active |
| `--accent-2` | `#7eb1ff` | sky — stats, data, eyebrows |
| `--text` | `#eaf2ff` | ice |
| `--text-dim` | `#9fb6d9` | secondary |
| `--text-muted` | `#7d96bd` | muted |
| `--grad-accent` | `linear-gradient(100deg,#2f6bdb,#7eb1ff)` | the only gradient |
| `--accent-glow` | `47,107,219` | rgba triplet |

- **Green is semantic-only** (favorable variances, "numbers going up"): `#34d399` on dark. Never a brand accent.
- Retired outright: per-tab rainbow (indigo/bronze/amethyst/teal/orange/green/clay), multi-stop purple→green gradient, KM² gradient top bar (`body::before`), black-outlined CTAs, purple anywhere.

## Effects ruleset
Gradient text within the family (royal→sky) for big headlines and stat figures; faint sky hairline ring on screenshot `.shot` frames; frosted ink nav (`backdrop-filter: blur`); count-up stats kept; soft dark shadows. No orange, no purple, no glow walls, no glass on content.

## Implementation
**CSS:** one scoped **`/* ===== MIDNIGHT UNIFIED THEME ===== */`** block appended to the END of `assets/site.css` (the file's established pattern). It (a) re-declares the `:root` tokens above, (b) re-declares every `body.theme-*` selector to the same midnight accents (rainbow neutralized; pages keep their class attributes — no HTML class churn), (c) restyles the hardcoded light/green leftovers: nav (ink + blur), `body::before` top bar (display:none), `.uv-stats` (navy band, sky gradient figures), `.btn-primary`/`.nav-cta` (royal bg, white text, no black outline), ghost buttons (hairline + ice), form inputs (navy on ink, royal focus), `.section-tint`, `.shot` frames, scrollspy/active states, chips/pills, and the `.hero-immersive` block (purple→green mesh → navy/royal/sky; gradient H1 accent → royal→sky), TAB v2 / case-feed / consult hardcoded colors as found in verification.

**HTML (all 14 pages):** nav + footer logo `images/km2-logo.png` → `images/km2-white.png`; `<meta name="theme-color">` → `#0a1220`. `images/favicon.svg` re-tinted royal/sky.

**Untouched (explicit):** `work/meridian.html` (already in-family; the reference look), the two standalone tool pages (`contract-reconciler.html`, `cost-standard-costing.html` — deliberately self-contained light palettes; separate follow-up if wanted), résumé PDF, and `images/og.png` (regeneration = follow-up).

## Verification
Headless full-page screenshots of every page; patch hardcoded leftovers until clean; WCAG AA spot-check (ice/ink ≈ 13:1, muted #7d96bd on ink ≥ 5:1, white on royal ≥ 4.5:1). **No deploy until the user reviews the local render and approves.**
