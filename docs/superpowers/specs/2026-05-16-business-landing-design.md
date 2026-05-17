# Keystone Marcy — Business Landing Page (Design)

**Date:** 2026-05-16
**Author:** Keystone Marcy (with Claude Code)
**Status:** Approved for v1 implementation

## Purpose

A single-page hybrid landing site that serves two audiences simultaneously:

1. **Recruiters / hiring managers** looking for a senior implementation engineer + builder
2. **Potential consulting clients** looking for someone to ship D365, AI, and Excel/automation work for their business

Both audiences arrive at the same page. The CTAs (See work, Get in touch) work for either intent.

## Identity

- **Name:** Keystone Marcy
- **Brand:** KM Consulting
- **Contact email:** `kmarcy@KMConsulting995.onmicrosoft.com`
- **Headline:** *ERP consultant turned builder. Apps, AI workflows, and Excel add-ins for the way finance & ops teams actually work.*
- **GitHub handle:** `kmarcy95`

## Page Structure

Single-scroll page, top-to-bottom:

1. **Sticky nav** — `KM Consulting · Work · Services · About · Contact`
2. **Hero** — name, headline, two CTAs (`See work` → anchor `#work`, `Get in touch` → anchor `#contact`)
3. **Bento grid** — 5 project cards in asymmetric layout (the centerpiece)
4. **Services strip** — 3 pillars: Apps · AI Workflows · Excel & ERP automation
5. **About** — ~120-word bio with credibility line + 4 skill tags
6. **Contact / final CTA** — mailto button + LinkedIn/GitHub icons
7. **Footer** — `© 2026 KM Consulting · built by Keystone`

## Featured Projects (Bento Grid)

Desktop = 4-column grid (12 columns mathematically). Mobile = single column, cards stack in the order listed below.

| # | Project | Desktop size | Description (final copy) | Tech tags |
|---|---|---|---|---|
| 1 | **D365 ERP Manager Web** | 2 cols × 2 rows (flagship) | Blazor app that generates ERP implementation timelines, project templates, and user stories for D365 Finance & Ops rollouts. | `Blazor`, `C#`, `.NET 8` |
| 2 | **Codex Job Tracking App** | 2 cols × 1 row (wide) | Full-stack AI job-search command center — aggregates listings, ranks fit, tailors résumés, monitors Gmail + Outlook, and runs approval-gated auto-apply via Playwright. Multi-agent CrewAI backbone. *In progress.* | `Next.js`, `FastAPI`, `CrewAI` |
| 3 | **Agent Dashboard** | 1 col × 1 row | An agentic OS to view every AI automation in one place — active workflows, skill usage, and token consumption across projects. | `Python`, `Agents`, `Observability` |
| 4 | **Creator Dashboard** | 1 col × 1 row | A single-file shell app helping social media creators grow their digital footprint — scheduling, link-in-bio, analytics, promo. | `HTML`, `JS`, `LocalStorage` |
| 5 | **Housing-Price ML Models** | 4 cols × 1 row (full-width banner) | Predicting residential sale prices with ensemble methods (XGBoost, Gradient Boosting, Linear Regression). Feature engineering, EDA, and model comparison. | `Python`, `XGBoost`, `scikit-learn` |

**Tiling layout** (desktop, 4-column grid):

```
┌───────────────┬───────────────┐
│  Card 1       │  Card 2       │   row 1
│  D365 ERP Web │  Codex Job    │
│  (flagship)   │  Tracking App │
│  2×2          ├───────┬───────┤
│               │ Card3 │ Card4 │   row 2
│               │ Agent │Creator│
│               │ Dash  │ Dash  │
├───────────────┴───────┴───────┤
│  Card 5  Housing-Price ML     │   row 3
│  (full-width banner)          │
└───────────────────────────────┘
```

On mobile, all cards stack to a single column in the order: 1, 2, 3, 4, 5.

### Project card anatomy

Each card contains, top to bottom:

- Small monospace label (uppercase, ~0.7rem) e.g. `D365 / BLAZOR / .NET 8`
- Card title (Space Grotesk, ~1.4rem on small cards, ~2rem on flagship)
- One-line description (Inter, ~0.95rem, muted color)
- 3 tech-tag pills (small, bordered, muted)
- Bottom strip: `View →` link OR `In progress` pill (for Codex app, has no link yet)
- Hover: subtle lift (`transform: translateY(-2px)`), accent border glow

No screenshots/images in v1. Pure typography + subtle accent gradient swatches on each card. Screenshots can come in v2.

## Services Strip (3 pillars)

After the bento grid, a single row of 3 simple cards:

1. **Custom business applications** — desktop, web, single-file. Built around the workflow you actually have.
2. **AI workflows & agent systems** — agentic OSes, automation pipelines, observability for AI-driven processes.
3. **Excel & ERP automation** — add-ins, D365 Finance & Ops tooling, templates that replace spreadsheet pain.

Each pillar: short heading + 2-sentence description. No CTAs (the page-level CTAs cover this).

## About Section

~120 words covering:

- ERP background (D365 Finance & Ops implementation work)
- Transition to building (the tools that finance/ops teams actually need)
- Philosophy: ship something useful, not a deck
- 4 skill tags: `D365 Finance & Ops`, `AI / Agents`, `Excel automation`, `Full-stack`

Final copy to be drafted during implementation; bio kept short and outcome-focused.

## Visual Style

- **Background:** `#0a0a12` with subtle ambient gradient mesh + 4% noise grain overlay
- **Surface:** `rgba(255,255,255,0.04)` translucent cards, `1px solid rgba(255,255,255,0.08)` border
- **Text:** `#f7f7ff` primary, `#9999b0` muted
- **Accent gradient:** `#7c5cff → #5eead4` (violet → teal) for CTAs, name highlight in hero, hover glows
- **Fonts:** Inter (body, weights 400/500/600/700) + Space Grotesk (display, weights 500/600/700) via Google Fonts
- **Motion:** stagger-in on scroll for bento cards (CSS only, no library), magnetic hover on hero CTAs (~20 lines of JS), respects `prefers-reduced-motion`
- **No emojis** anywhere in copy

## File Structure

```
Business-Landing-Page/
├── index.html              # everything: HTML, CSS, JS inline (single file)
├── images/
│   └── og.png              # 1200×630 OG image (generated, not photo)
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-05-16-business-landing-design.md
├── README.md               # short, just "what this is"
├── .gitignore              # node_modules, .DS_Store, .superpowers/
└── netlify.toml            # publish dir = "."  (no build step)
```

## Tech

- **Stack:** vanilla HTML / CSS / JS, single file (`index.html`)
- **Dependencies:** Google Fonts (Inter + Space Grotesk) via `<link>`. No JS libraries, no build step.
- **Browser support:** modern evergreen (Chrome, Edge, Safari, Firefox last 2 versions)
- **Accessibility:** semantic HTML, sufficient contrast, keyboard navigable, `prefers-reduced-motion` honored, `:focus-visible` outlines on all interactive elements

## Hosting

- **Repo:** new GitHub repo under `kmarcy95/Business-Landing-Page` (separate from `Personal-Landing-Page`)
- **Host:** new Netlify site, proposed subdomain `keystonemarcy.netlify.app` (fallback `kmconsulting.netlify.app`)
- **Deploy:** Netlify auto-deploys on push to `main`. No build command — publish directory `.`.
- **Custom domain:** out of scope for v1; can be upgraded later.

## Out of Scope (v1)

Listed explicitly so we don't drift:

- No CMS, no markdown project pages — project cards stay on the landing page
- No blog
- No analytics integration (Plausible/GA) — defer to user request
- No contact form / backend — `mailto:` link only
- No dark/light theme toggle — dark only
- No real project screenshots — typography-only cards
- No custom domain — Netlify subdomain only
- No testimonials section (no testimonials yet to feature)
- No resume PDF download (can be added later as a single link in the About section)
- No internationalization

## Success Criteria

v1 ships when:

1. Page loads in under 1.5s on a 4G connection
2. All 5 project cards render correctly on desktop (1440px), tablet (768px), mobile (375px)
3. All navigation links scroll to the correct section
4. Mailto CTA opens the user's mail client with `kmarcy@KMConsulting995.onmicrosoft.com` pre-filled
5. Site passes a basic Lighthouse audit (Performance ≥ 90, Accessibility ≥ 95)
6. Pushed to GitHub and live on Netlify subdomain

## Open Questions (resolve during implementation, don't block design)

- **Codex Job Tracking App location** — user doesn't have a final URL yet. Card ships with `In progress` pill and no link until provided.
- **About-section bio copy** — to be drafted in implementation; ~120 words, outcome-focused.
- **Profile photo** — not in v1 scope, but space reserved in About section if user wants to add later.
