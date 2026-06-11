# Meridian flagship page — design spec (2026-06-11)

## Goal
Replace the D365 ERP Manager Web flagship everywhere on the site with **Meridian** (the Cost Accounting & Controlling Terminal, repo `kmarcy95/cost-accounting-terminal`, local app at `127.0.0.1:5000`). New detail page `work/meridian.html` is the site's showpiece: Apple-Pro-dark "J" direction + Variant 1 "Capability Wall" enhancements, chosen via the brainstorming visual companion (3 rounds of direction mockups, then 3 enhanced variants with real screenshots).

## Visual direction (locked by user)
- **Apple Pro dark**: pure-black page, huge tight typography, one gradient headline pattern.
- Palette from the Meridian logo: navy `#0d1b2e`, royal blue `#2563eb`/`#4f8df9`, cyan `#22ccf5`; gradient `linear-gradient(100deg,#4f8df9,#22ccf5,#7fd9f7)`.
- Hero: eyebrow `KM² · FLAGSHIP BUILD` → low-poly cube mark (inline SVG in a glowing rounded tile) → **Meridian** (white, ~84px) → **Beyond D365.** (gradient) → one-line sub → CTAs → Executive Overview screenshot in hairline frame with cyan glow.
- Gradient-number stat strip: 71 registers · 19 modules · ~160 AI command bars · 42.7k lines · $0.00 out of balance.

## Page structure (`work/meridian.html`)
Self-contained (own `<style>`, no `assets/site.css` dependency — precedent: `contract-reconciler.html`). Standard site nav links + footer, dark-styled; sticky CTA omitted-or-dark per build. SEO/OG/Twitter meta + canonical; `data-cta` analytics hooks preserved.

1. Hero + stat strip (above).
2. **Why it exists** intro (D365 parity origin → 32 features past it; built by one person).
3. Scenes (giant headline + caption + full-width real screenshot):
   - The whole ledger. One workspace. — register grid (`shot-register`)
   - Every journal balances. Always. — journals (`shot-journals`)
   - AI on every section. — AI Insights floating window (`shot-ai`)
   - The Control Tower. — controls dashboard (`shot-controls`)
   - Close with confidence. — allocation Sankey page (`shot-allocations`)
4. **Capability Wall** (Variant 1 differentiator): "Everything inside." — all 19 modules as a 4-col grid of cards (name + contents), then 9 differentiator tiles (offline AI engine, governed posting, continuous controls, floating windows, My Workspace, one process, data in, analytics depth, real close).
5. Tech specs grid (6 cells: TypeScript 5.6 / React 18 + Vite 7 / Express 5 / SQLite + Drizzle / TanStack Query / PDF·XLSX·CSV export).
6. QA pills (0 type errors · $0.00 out-of-balance verified via API · 0 console errors · 8 QA'd waves).
7. Closing: "Built by one person. Run by one process." + contact CTA.

## Screenshots
Captured live via Playwright (Python) against the production build on `:5000`, 1600×900 @1.5dpr; the AI shot opened by clicking a real `scb-*-ai` button. PNGs in `C:\tmp\meridian-shots\` → WebP via sharp (`C:\tmp`) → `images/work/meridian/{hero,register,journals,ai,controls,allocations}.webp` + `images/proj-meridian.webp` (index bento cover).

## Site integration (full takeover — user choice)
- `index.html` featured-work card 1 → Meridian (cover `proj-meridian.webp`, copy, link `work/meridian.html`).
- `work.html` case row 1 → Meridian; `Live demo` badge dropped (app is local-only) — badge becomes `Flagship build`.
- `work/d365.html` deleted; `images/work/d365/` + `images/proj-d365web.webp` deleted; `sitemap.xml` entry swapped for `work/meridian.html`.
- The D365 Command Center live-demo link goes away with the page (accepted; can resurface elsewhere later).
- Professional "D365" skill mentions (about/experience/services copy) are untouched — only the app showcase is replaced.

## Out of scope
Other work pages/cards, per-tab themes, the standalone tool pages, OG share-card regeneration.
