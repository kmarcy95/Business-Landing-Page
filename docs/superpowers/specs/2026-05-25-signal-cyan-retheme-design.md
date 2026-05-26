# Signal Cyan retheme — design

**Date:** 2026-05-25
**Status:** approved (brainstorming → spec)
**Scope:** color tokens, surface treatments, CTA pattern, and themed assets only. No content, layout, copy, typography, or IA changes.

## Goal

Replace the current white + deep-navy palette with a near-black + signal-cyan palette ("Sharp Operator" — Linear/Vercel-inflected) so the page reads as software-fluent and "modern operator" to fintech-CFO and strategic-finance recruiters, while preserving WCAG AA contrast and all existing functionality.

## Audience & positioning

- Primary recruiter audience: fintech / tech-forward CFO and strategic-finance leadership (Series A–D fintechs, SaaS finance, FP&A-for-tech).
- Identity reinforced: "I lead FP&A AND build the software that delivers it."
- Why dark + cyan: cyan is the canonical dashboard / chart-axis color across every finance tool the audience already uses, so the accent reinforces the FP&A discipline rather than fighting it. Dark base differentiates from the ~95% of finance-leader pages that are light. The combination signals "ships measured systems."

## Tokens

Replace `:root` color tokens in `index.html` as follows. All other token groups (radii, spacing, type scale) are unchanged.

| Token | Old | New | Contrast on `--bg-0` |
|---|---|---|---|
| `--bg-0` | `#ffffff` | `#0a0a0a` | — |
| `--bg-1` | `#eceef3` | `#101012` | — |
| `--surface` | `#ffffff` | `#141416` | — |
| `--surface-2` | `#f3f4f7` | `#1c1c20` | — |
| `--surface-translucent` | `rgba(42,42,47,0.62)` | `rgba(20,20,22,0.65)` | — |
| `--border` | `#e6e7ec` | `#2a2a2f` | — |
| `--border-strong` | `#d2d4dc` | `#3a3a40` | — |
| `--text` | `#16171c` | `#fafafa` | 19.5:1 AAA |
| `--text-dim` | `#44464f` | `#a3a3a3` | 7.5:1 AAA |
| `--text-muted` | `#5b5d68` | `#737373` | 4.6:1 AA |
| `--accent-1` | `#1e40af` | `#00b8ff` | 9.2:1 AAA |
| `--accent-2` | `#1e3a8a` | `#0090d4` | 5.8:1 AA |
| `--grad-accent` | indigo→navy | `linear-gradient(135deg,#00b8ff 0%,#0090d4 100%)` | — |
| `--accent-glow` | `30, 64, 175` | `0, 184, 255` | — |

Every text/background pair meets WCAG AA. Required: re-run the existing contrast check (`C:\tmp\contrast.js`) against the new tokens and confirm.

## CTA pattern (load-bearing change)

Cyan + white text fails AA (~2.3:1). All primary CTAs flip to cyan-on-dark-text — the canonical Vercel/Stripe-dark pattern.

- **Primary CTA** (`.btn-primary`, `.nav-cta`, sticky CTA): `background: var(--accent-1); color: #0a0a0a` — contrast 10.4:1.
- **Hover**: `background: var(--accent-2)` (darker cyan), text stays `#0a0a0a`.
- **Ghost / secondary** (`.btn-ghost`): `background: transparent; border: 1px solid var(--accent-1); color: var(--accent-1)`; hover lifts to `background: rgba(0,184,255,0.08)`.
- **Skip link**: cyan bg + dark text (same as primary).

Apply to every CTA on the page including: hero `Download résumé` + `Get in touch`, nav `Contact`, sticky CTA, contact form `Send` button, any in-card CTAs.

## Shadows, glows, translucent surfaces

Light-mode black-alpha drop shadows disappear on dark. Replace with:

- **Card lifts / hovers**: `box-shadow: 0 0 0 1px rgba(0,184,255,0.18), 0 16px 40px -12px rgba(0,0,0,0.7)` — cyan ring whispers "active," black drop preserves depth.
- **`--shadow-sm`**: `0 1px 2px rgba(0,0,0,0.45), 0 1px 3px rgba(0,0,0,0.35)`.
- **`--shadow-md`**: `0 6px 16px -6px rgba(0,0,0,0.6), 0 2px 6px -2px rgba(0,0,0,0.4)`.
- **`--shadow-lg`**: `0 22px 48px -20px rgba(0,0,0,0.75), 0 10px 22px -14px rgba(0,0,0,0.5)`.
- **`.bg-mesh`** (hero glow): swap to `radial-gradient(900px 500px at 50% -10%, rgba(0,184,255,0.10), transparent 60%)` — single subtle cyan top-glow, cinematic without noise.
- **`.surface-translucent`** (marquee captions, frosted hero panels): `rgba(20,20,22,0.65)` + existing `backdrop-filter: blur(14px)`.

## Section alternation + chips

- **`.section-tint`**: invert the relationship — on dark, "tinted" sections become slightly *lifted* (`background: var(--bg-1)` = `#101012`) rather than slightly depressed. Same Linear-home-page trick.
- **Logo chips** (`.logo-chip` — "Finance & accounting roles across"): `background: var(--surface-2); color: var(--text-dim); border: 1px solid var(--border)`. Hover → `color: var(--accent-1); border-color: var(--accent-1)`.
- **Skill / tag chips** (`.skill`, `.tag`): same pattern as logo chips.
- **`.hiw-bar`** (How-I-Work score bars): bar bg `var(--surface-2)`, fill `var(--grad-accent)` (cyan gradient).
- **Stats band count-up numbers**: color stays `var(--accent-1)` — now cyan instead of blue.

## Themed assets

### Browser-chrome work frames (`.shot`)

Chrome bar bg → `var(--surface-2)`, dots → light gray (`var(--text-muted)`), URL text → `var(--text-muted)`. Light-themed app screenshots inside the dark chrome reads as "real product screenshots in our shell" — same Vercel/Linear pattern. No screenshot regeneration needed.

### Headshot (`images/headshot-about.webp`)

Current source is on a light/white backdrop and will halo on near-black. Two-step mitigation:

1. **Step 1 (mandatory)**: CSS frame — `border-radius: 50%; box-shadow: 0 0 0 1px var(--border), 0 0 0 6px var(--surface);`
2. **Step 2 (only if step-1 halo is still visible after manual browser check)**: regenerate hero headshot via `scripts/resize-headshots.ps1` with the backdrop fill swapped from light to `#0a0a0a` in the script's `Graphics.Clear(...)` call. Re-export `headshot-about.webp` via the existing sharp WebP step.

### OG share card (`images/og.png`)

Currently charcoal+yellow per `scripts/make-og.ps1`. Re-theme to cyan-on-near-black:

- Background fill: `#0a0a0a` (was `#202024`)
- Accent band / orb / subtitle color: `#00b8ff` (was `#f5c518` / `#e0a800`)
- Title text: `#fafafa` (white-ish)
- Subtitle text: `#a3a3a3`

Same script structure, only color values change. Regenerate `images/og.png` and confirm dimensions remain 1200×630.

### Favicon / other assets

No changes required this round. If the favicon includes a brand color, leave it; favicon update can be a follow-up.

## Files touched

- `index.html` — `:root` tokens, shadow values, `.bg-mesh`, `.btn-primary`, `.btn-ghost`, `.nav-cta`, `.skip-link`, `.surface-translucent`, `.section-tint`, `.logo-chip`, `.skill`, `.tag`, `.hiw-bar`, `.shot` chrome styles, `.headshot-about` frame styles, any other components that reference old token values directly (audit for hex-coded colors that should reference tokens).
- `scripts/make-og.ps1` — color literals.
- `images/og.png` — regenerated artifact.
- Possibly `images/headshot-about.webp` — only if step-1 mitigation fails.
- `CLAUDE.md` — Business Landing Page section: update theme description, tokens, and any references to "charcoal+yellow" or "white + deep blue." Note "Signal Cyan" as the live theme as of 2026-05-25.
- `C:\Users\keyst\.claude\projects\C--Users-keyst\memory\project_business_landing_page.md` — same update (kept in sync per the global rule).

## Out of scope

- Content, copy, IA, typography (Inter + system stack stays).
- New sections or new bento cards. (An in-progress Aurora card edit in the working tree is independent of this retheme and not blocked or affected.)
- Light-mode toggle.
- Analytics / GA4 / Clarity setup (still scaffolded, still waiting on IDs).
- Real testimonials, video footage.

## Risks + mitigations

| Risk | Mitigation |
|---|---|
| Cyan reads "designer/template" if overused | Restrict to: CTAs, links, focus rings, single hero glow, hover borders, count-up stats. No cyan headings, no cyan section backgrounds, no cyan body text. |
| Headshot halo on dark | CSS frame first; regen with dark backdrop only if needed. |
| Inconsistent look with light-app screenshots inside dark frames | Not a real risk — this is the canonical Vercel/Linear pattern. Focal point becomes the work itself. |
| CLAUDE.md is stale (says charcoal+yellow but live is white+blue) | Update CLAUDE.md + project memory as part of the implementation plan. |
| Sibling Netlify site (`keystonemarcykmconsulting`) has broken auto-deploy | Known gotcha. Implementation plan must include the manual `netlify deploy --prod --dir . --site 55407d90-c8c3-4948-a7e4-644aeba1860a` step (and the gitignored-files-move dance). |
| A hex-coded color slipped past the tokens in an old commit | The implementation plan must include a grep for `#1e40af`, `#1e3a8a`, `#2747c9`, `#eceef3`, `#f3f4f7`, `#e6e7ec`, `#d2d4dc`, and other current literals in `index.html` to confirm token replacement is complete. |

## Verification (manual, no automated test suite for this site)

1. Open `index.html` in Chrome.
2. Walk every section: nav, hero (incl. headshot framing), logo-chip wall, marquee, stats band, experience, work bento (incl. `.shot` frames), services, about, how-i-work, contact, sticky CTA, footer.
3. Hover every CTA — confirm cyan→darker-cyan and dark text stays legible.
4. Scroll-spy underline in nav — confirm visible on dark.
5. Mobile breakpoint (≤640px): hamburger toggle, nav drawer bg.
6. Re-run `C:\tmp\contrast.js` against the new tokens — every pair ≥ AA.
7. Inspect OG card preview (`images/og.png`) at 1200×630.
8. Optional but recommended: LinkedIn Post Inspector / Twitter Card Validator on the live URL after deploy.

## Deploy steps (canonical + sibling)

1. `git add` + commit (one commit per phase per the existing project convention).
2. `git push origin main` — deploys canonical `keystonemarcy.netlify.app` automatically.
3. Move gitignored junk (`preview-*.html`, `*.db`) out of the repo dir temporarily.
4. `netlify deploy --prod --dir . --site 55407d90-c8c3-4948-a7e4-644aeba1860a` — manually deploys the sibling site (whose auto-deploy is broken by design).
5. Move the gitignored junk back.
