# Tab redesigns — Experience, Services, Templates, About, How I Work, Contact

**Date:** 2026-06-09
**Pages:** `experience.html`, `services.html`, `templates.html`, `about.html`, `how-i-work.html`, `contact.html`
**Goal:** Make each non-home/non-work tab read faster and show value more clearly, keeping each tab's existing per-tab accent theme (teal / green / orange / bronze / amethyst / clay). Approved from the visual-companion gallery render (one concept per tab).

**Shared approach:** new component CSS appended to `assets/site.css`, scoped to new class names, using the theme tokens (`--accent-1/-2`, `--accent-glow`) so each page auto-inherits its color. Markup swapped inside each page's `<main>`. No JS changes. Nav/footer/sticky-CTA/script untouched.

## Experience (theme-teal)
Convert the flat `.xp-list` into a **timeline rail**: a vertical accent line with a node per role. Each role keeps **company + dates/location + role title(s) + ALL original bullet points** (nothing removed — user requirement), and **adds** a row of large **metric chips** above the bullets, pulling the numbers already in the copy:
- C.H. Guenther: $450M segment · ~$500K/yr · 33% faster · $2B transformation
- Lancer: $5–10M R&D · $200M business · $5B parent · J-SOX
- H-E-B: 92% shrinkage · ~$300K/yr · $1.5M inventory · $50B retailer
- AllianceBernstein: $867B AUM · 27 countries · 4 asset classes
H-E-B keeps both roles (Lead P&L Analyst + Cost Accounting Manager) and both bullet groups.

## Services (theme-green)
Keep the 3 capability cards, the `$100/hr` rate band, the 3 tiers (Build Sprint stays `.featured`), and the "What I automate" list. **Add a 3-step "How it works" strip** (Audit → Build Sprint → Iterate) between the rate band and the tiers.

## Templates (theme-orange)
Replace the two stacked bento sections with a **filter bar (All / Free / Premium)** + a product grid. Each product card gets a **price badge** (Free / $99 / $129), a tight **"what you get"** bullet list, and its existing CTA/form. Keep all existing products, forms (Web3Forms), and links intact. Filtering is CSS/JS class-toggle on the cards.

## About (theme-bronze)
Editorial layout: portrait + bio with a **pull-quote** ("Finance judgment plus the ability to build the fix myself…"), a **by-the-numbers strip** (7+ yrs · 4 industries · $450M · ~$500K/yr), competencies as a **chip grid** (existing 12–14 skills), and **credentials in their own band**. Keep all existing copy/skills/certs.

## How I Work (theme-amethyst)
Lead with an **archetype hero** (Operator / Strategic Creator · ENTJ) with the SoulTrace 5-color bars beside it. Keep the 3 superpower cards. Condense the six framework blocks from one long column into a **tight 3-column grid** of mini score-bar cards (keep 2–3 bars each). Keep "Where I fit" chips.

## Contact (theme-clay)
**Two-column**: left = availability badge + "what happens next" 3-step + direct links (résumé / email / LinkedIn / GitHub); right = the existing contact form moved into an **elevated card**. Keep the Web3Forms form, all fields, the JS submit handler, and all links/socials intact.

## Success criteria
- Each page renders the new layout in its own accent color; all existing links, forms, and copy preserved (Experience keeps every bullet).
- CSS additions are scoped + additive — no regression on other pages.
- Headless screenshot per page confirms layout.
- Deploy via `git push origin main` → GitHub Pages.

## v2 — richer graphics (Services / About / How I Work)
Second iteration adding more graphics + modern styling so each tab's takeaway lands. New CSS appended under a "TAB v2" block in `assets/site.css` (theme-token-driven). Approved from a second visual-companion gallery render.
- **Services:** proof stat band (~$500K/yr · 33% · $2B, real in-seat metrics) after the page-head; the 3-step strip upgraded to a connected **process flow** (circular numbered nodes + icons + dashed connectors); **✓ checklists** added to each of the 3 tiers; "What I automate" list → a 2×2 **icon grid**.
- **About:** dual-identity **badges** (📊 FP&A · ⚙ Builder) in the bio; the aside (skills-card + certs) replaced by full-width blocks — a **"Two sides of my work"** split (Reads the numbers + Builds the tools), an **industries** icon row (Manufacturing/Retail/Distribution/Asset Mgmt), competencies **grouped into 3 categories** with icons (all 14 skills kept), and credentials as **seal cards** (all 4 kept).
- **How I Work:** archetype hero's score-bars replaced by an SVG **SoulTrace donut** (Black 40/Blue 25/Red 19/White 10/Green 6) + legend; new **personality radar** (SVG, 6 axes) under "How I show up"; framework bar-cards → compact **radial-gauge cards**.
