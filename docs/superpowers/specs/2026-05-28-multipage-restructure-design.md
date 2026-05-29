# Multi-page restructure — design spec

**Date:** 2026-05-28
**Project:** Business Landing Page (KM Consulting) — `C:\Users\keyst\Business-Landing-Page`
**Status:** Approved design, pending spec review

## Context

The site is currently a single long-scroll `index.html` (hero → logo wall → marquee → stats →
Experience → Work bento → Services → About → How I Work → Contact), plus 6 work detail pages under
`/work/<slug>.html` and a standalone green-accented `consulting.html`. The user wants to convert it
into a **multi-page site**: a slimmed **Home** that only carries recruiter/client attention-grabbers
(plus more graphics), and a **dedicated page for each nav tab**, with detailed content repurposed
out of Home onto those pages. Each tab must also carry a **distinct accent color** for visual
distinction. Goal: a more professional, fuller-feeling site where each subject gets room to breathe.

## Decisions (confirmed with user)

- **Merge Services + Consulting into one `Services` page** (capabilities + $100/hr rates + tiers +
  intake form). Drop the separate "Consulting" tab.
- **Nav (every page):** Home · Work · Services · About · How I Work · Experience · Contact.
- **Home keeps:** hero + headline + CTAs · stats band · logo wall + marquee · **plus** a featured-work
  strip, a one-line services teaser, and a closing contact CTA (the "anything else" additions).
- **Graphics:** a mix of inline SVG (icons, motifs, simple charts) and a couple of generated raster
  images (hero feature, per-page OG cards).
- **Per-tab accent color:** each page gets its own accent via a `body.theme-*` class.

## Approach

**Shared-shell multi-page extraction** — each tab becomes its own root-level HTML page reusing the
existing nav / footer / sticky-CTA / `<script>` shell and `assets/site.css`, exactly like the existing
`/work/*` detail pages. Pure vanilla, no build step. Accepted tradeoff: nav/footer markup is
duplicated across pages (the site already does this); future nav edits use a scripted find-replace.

## Page architecture

All pages live at the repo root and are served as Netlify "pretty URLs" (`/work`, `/services`, etc.).

| Page | File | Content source | Accent |
|---|---|---|---|
| Home | `index.html` | Slimmed (see below) | Cyan (site default `:root`) |
| Work | `work.html` | `#work` bento → portfolio index linking to the 6 `/work/<slug>` detail pages | Violet |
| Services | `services.html` | 3 service-capability cards (expanded) **+** consulting page's rate band, tiers, intake form | Green |
| About | `about.html` | `#about` bio + Core Competencies + Certs/Education | Amber |
| How I Work | `how-i-work.html` | `#how-i-work` personality dossier | Magenta |
| Experience | `experience.html` | `#experience` career timeline | Teal |
| Contact | `contact.html` | `#contact` form + résumé/email/socials | Coral |

**`consulting.html`:** content migrates into `services.html`. Add a Netlify redirect
`/consulting → /services` (301, in `netlify.toml`) to preserve the already-deployed/indexed URL, then
delete `consulting.html`. The `consulting-intake` Netlify form moves to the Services page unchanged
(same `name="consulting-intake"`, so existing form registration + any notifications keep working).

### Home (slimmed) — final section list
1. Hero (headshot + identity H1 + eyebrow + résumé / contact CTAs) — **add a hero feature graphic**.
2. Stats band (animated count-up `.uv-stats`).
3. Logo wall ("Finance & accounting roles across") + captioned marquee.
4. **Featured work** — 3 top project cards (e.g. D365, Agent OS, + one) → "See all work →" to `/work`.
5. **What I do** — one-line services teaser + button → `/services`.
6. **Closing CTA** — short "let's talk" band → `/contact`.
7. Footer + sticky CTA.

Everything else (full Experience, full Work bento, full Services, About, How I Work, Contact form)
moves to its dedicated page and is **removed** from Home.

## Per-tab accent color system

Extend the existing `body.theme-green` pattern (already in `assets/site.css`) into a set of theme
classes, one per page, each redefining the four accent tokens plus the two hardcoded-cyan overrides:

```css
body.theme-violet { --accent-1:…; --accent-2:…; --grad-accent:…; --accent-glow:…; }
body.theme-violet .btn-ghost:hover { background: rgba(<glow>,0.08); }
body.theme-violet .bg-mesh { background: radial-gradient(… rgba(<glow>,.10) …), linear-gradient(…); }
/* repeat per theme */
```

Because every component reads `var(--accent-*)`, the page's buttons, links, the active nav link, icons,
chart fills, focus rings, brand orb, and `.bg-mesh` glow all pick up the page color automatically.

**Proposed palette** (exact shades contrast-tuned during implementation):

| Theme | accent-1 | accent-2 | Notes |
|---|---|---|---|
| Cyan (Home) | `#00b8ff` | `#0090d4` | site default, unchanged |
| Violet (Work) | `#a06bff` | `#7c4dff` | |
| Green (Services) | `#22c55e` | `#16a34a` | existing |
| Amber (About) | `#f5b324` | `#d99814` | |
| Magenta (How I Work) | `#f062c0` | `#d23ea4` | |
| Teal (Experience) | `#2dd4bf` | `#14b8a6` | |
| Coral (Contact) | `#ff7a59` | `#f2542d` | |

**Contrast rule:** `.btn-primary`/`.nav-cta` use dark text (`#0a0a0a`) on the accent. For any accent
whose gradient is too dark for AA with dark text (likely Violet, Magenta, Coral), add a per-theme
override flipping that page's primary-button text to white (`.theme-X .btn-primary{color:#fff
!important}`). All ghost-button/link text uses accent-on-near-black, which passes for every hue. The
gray-box surface/border tokens stay neutral across all themes (only the accent changes per page).

## Graphics plan (mix)

- **Inline SVG (most of it):**
  - A per-page **topic icon** in each page header (work/services/about/etc.), theme-colored.
  - A reusable **hero/section motif** (cyan/green/etc. radial orb + faint grid) — already partly via
    `.bg-mesh`; add an SVG accent in page headers.
  - Simple **SVG/CSS charts**: a competencies bar set on About; a metric donut/gauge on Home or
    Experience (driven by the existing stat numbers). No chart library.
  - Decorative dividers between Home sections.
- **Generated raster (a couple):** a richer **Home hero feature graphic** and refreshed **per-page OG
  share images**, generated with the existing System.Drawing (`scripts/make-og.ps1`,
  `scripts/make-agent-card.ps1`) or `sharp` tooling. Branded/abstract/diagrammatic (data-automation
  motifs, device frames of real app screenshots) — not stock photography. Stored as WebP under
  `images/` (and `images/og/` per-page), kept light.

## Out of scope / notes
- No new dependencies, no build step, keep the no-`innerHTML`-on-dynamic convention.
- SEO: each page gets its own `<title>`, meta description, canonical, and OG/Twitter tags; update
  `sitemap.xml` to list all new root pages; keep `/consulting` redirect so the old URL 301s.
- Deploy hygiene unchanged: canonical via `git push origin main`; sibling via manual
  `netlify deploy --prod --dir . --site 55407d90-…` with the `preview-*.html`/`ruvector.db` junk
  moved out and restored.

## Verification (high level — detailed steps in the plan)
- Each page opens locally, renders with the shared shell + its distinct accent, and is responsive.
- Nav works across all pages; active tab is marked and themed; no dead links; `/consulting` 301s to
  `/services`.
- The `consulting-intake` form still has its Netlify attributes on the Services page.
- WCAG AA spot-check on each theme's primary button (dark or white text as needed).
- After deploy: all new pretty URLs return 200 on both Netlify sites; `ruvector.db` 404s.

## Build sequence (for the plan)
1. Shared shell + the per-tab theme CSS classes.
2. Extract each subject page (Work, Services [merged], About, How I Work, Experience, Contact).
3. Slim Home + add featured-work / services-teaser / closing-CTA.
4. Graphics (SVG icons/charts/motifs, then the couple of generated raster images).
5. Redirect + sitemap + nav consistency sweep across all pages (incl. `/work/*`).
6. Local verification, then deploy to both sites + post-deploy URL checks.
