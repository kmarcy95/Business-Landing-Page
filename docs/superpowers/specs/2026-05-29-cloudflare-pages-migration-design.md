# Cloudflare Pages Migration — Phase 1 (static sites)

**Date:** 2026-05-29
**Status:** Approved (design)
**Scope:** Migrate the three *static* sites off Netlify to Cloudflare Pages, move the Business LP contact forms to Web3Forms, and delete the broken duplicate Netlify site. The Next.js job-tracker app is explicitly deferred to a separate Phase 2 spec.

## Problem

Netlify moved its free **Personal** tier onto a credit-based model. The `keystonemarcywork` team (free tier, no payment method on file) **exceeded its monthly credit limit, and Netlify paused all five sites** ("This team has exceeded the credit limit… all projects and deploys have been paused"). The live sites are currently down.

Root causes of the credit drain:
- **Five sites** on one free credit budget.
- **Frequent AI-driven deploys** (this workflow ships often).
- A **broken duplicate site** (`keystonemarcykmconsulting`) that fails a build on *every* push to the Business LP repo — failed builds still consume credits.
- Netlify's new credit-billed extras (dev servers, agent runs, preview servers).
- The **Next.js job-tracker** (`kmcaijobtracker`) runs SSR + serverless functions + image optimization on Netlify — the single heaviest consumer (handled in Phase 2).

For a user who ships as often as this one, Netlify's free tier is now fundamentally unreliable: hit the monthly credit budget and every site goes offline. The durable fix is to move to a host with **no credit model and no pausing**.

## Goals

- Get the static sites back online, **free, with no credit-pause risk**.
- **Preserve working contact/intake forms** (a hard requirement).
- Eliminate recurring waste (the broken duplicate; the deploy-hygiene `--dir .` dance).
- Keep the existing git-push → auto-deploy workflow.

## Non-goals (Phase 1)

- Migrating the Next.js job-tracker (`kmcaijobtracker`) — separate Phase 2 spec.
- Keeping the `*.netlify.app` URLs — **user accepted new `*.pages.dev` URLs** (no custom domain purchased this round).
- Re-enabling the Personal LP `/admin` Decap CMS (it was never functional — Netlify Identity was never enabled; see Risks).
- Building any on-site payment/checkout (unchanged: Personal LP routes to OnlyFans).

## Decisions (from brainstorming)

| Decision | Choice |
|---|---|
| Host | **Cloudflare Pages** (free, no credit model, unlimited bandwidth, git-connected auto-deploy, free SSL) |
| Forms | **Web3Forms** (free, unlimited submissions, email delivery, honeypot/captcha) |
| URLs | Accept free `*.pages.dev` subdomains |
| Sites this phase | Business LP, Personal LP, aurora-km |
| Duplicate | **Delete** `keystonemarcykmconsulting` |
| Job tracker | Defer to Phase 2 (Next.js → Cloudflare via Next adapter) |

## Architecture

Three independent units, each migrated and verifiable on its own.

### Unit A — Business Landing Page (`keystonemarcy` → Cloudflare Pages)
- **Source:** GitHub `kmarcy95/Business-Landing-Page`, multi-page static HTML + `assets/site.css`, **no build step**.
- **Cloudflare Pages project:** connect to the repo, branch `main`, **build command = none**, **output dir = `/`** (repo root). Push to `main` → auto-deploy (same trigger as today).
- **Forms (the critical piece):** convert every Netlify form to Web3Forms.
  - Affected tracked pages: `contact.html` (the `contact` form, currently `data-netlify="true" netlify-honeypot="bot-field"`) and the `consulting-intake` form (wired across `about.html` / `experience.html` / `how-i-work.html`). Enumerate exact form locations during implementation.
  - Per form: remove Netlify-specific markup (`data-netlify`, `netlify-honeypot`, any hidden `form-name` input); set `action="https://api.web3forms.com/submit"` `method="POST"`; add hidden `access_key`; keep a honeypot field (`botcheck`); preserve existing field names; add a hidden `subject`/`from_name` for clean email subjects; set a `redirect` or handle the JSON response in the existing form JS (`contactFormEl` / `intakeFormEl` handlers already exist).
  - `preview-*.html` are gitignored scratch files — **ignore** (they also contain old Netlify forms but never deploy).
  - Web3Forms access key is registered to the user's email; configure recipients to match today's Netlify notifications (`kmarcy@KMconsulting995.onmicrosoft.com` and `marcy.keystone@outlook.com`).
- **URL change:** strings hardcoded to `https://keystonemarcy.netlify.app` (canonical link, OG/Twitter image URLs, JSON-LD `url`/`image`, `sitemap.xml`) must be updated to the new `*.pages.dev` URL.

### Unit B — Personal Landing Page (`keith-links-995` → Cloudflare Pages)
- **Source:** GitHub `kmarcy95/Personal-Landing-Page`, single-file static HTML + `planner.html` + `gallery.json`, **no build step**.
- **Cloudflare Pages project:** connect repo, branch `main`, build command = none, output dir = `/`.
- **No Netlify contact form** to migrate (the paywall modal routes to OnlyFans — unchanged).
- **`/admin` Decap CMS:** uses Netlify Identity + git-gateway, which **do not exist on Cloudflare**. This was already non-functional (Identity never enabled), so removing it is not a regression. Phase 1 leaves `/admin` as-is (dead); a future option is Decap's GitHub backend via an OAuth proxy — out of scope here.
- **URL change:** update any hardcoded `keith-links-995.netlify.app` references (robots/sitemap, OG tags if present).

### Unit C — aurora-km (manual deploy → Cloudflare Pages)
- **Source:** **manual deploy, no connected git repo.** Source files are NOT in the obvious home-dir locations.
- **First implementation task = locate the source.** If found locally, create a tiny git repo (or a Cloudflare Pages "direct upload" project). If the source is lost, **pull the deployed assets from the live Netlify URL** (`https://aurora-km.netlify.app`) via a recursive fetch/scrape *before* the Netlify project is deleted, then deploy those static files to Cloudflare Pages (direct upload).
- No forms, no build step (static demo).

### Unit D — Netlify cleanup
- **Delete `keystonemarcykmconsulting`** (broken duplicate, pure waste) once Unit A is verified live on Cloudflare.
- After Units A/B/C are verified on Cloudflare, **delete** the corresponding Netlify sites (`keystonemarcy`, `keith-links-995`, `aurora-km`) to free credits — or keep them as dormant unlinked backups. Deleting is what actually relieves the credit pressure. `kmcaijobtracker` stays on Netlify until Phase 2 (it remains the main consumer, so expect continued credit pressure until then — acceptable, since the static sites will be safe on Cloudflare regardless).

## Data flow (forms)

Today: browser → Netlify Forms (deploy-time HTML detection) → Netlify email notification → user inboxes.

After: browser → POST `api.web3forms.com/submit` (with `access_key`) → Web3Forms → email to configured recipients. No backend, no build, host-independent.

## Error handling / edge cases

- **Form spam:** keep honeypot (`botcheck`); enable Web3Forms' built-in spam filter; optionally add hCaptcha later if spam appears.
- **Form JS:** the existing `contactFormEl` / `intakeFormEl` handlers must be updated to read Web3Forms' JSON success/error response (or use a `redirect` field) instead of Netlify's behavior, so the on-page success/thank-you state still works.
- **aurora source loss:** mitigated by scraping the live site before deletion (sequencing: migrate/verify *before* delete).
- **Cached old URLs:** old `*.netlify.app` links will 404 after deletion; acceptable per the URL decision. Update the résumé/links only where the site URL is referenced (business site is the sensitive one — it appears in `index.html` meta + sitemap, not on the résumé PDF, which uses email only).

## Risks

- **URL breakage:** anything linking to the old `*.netlify.app` domains breaks. The business site URL is referenced in its own metadata/sitemap (fixable) and possibly external profiles (user to update manually). LOW–MEDIUM.
- **Decap `/admin` stays dead** on Personal LP — but it was already dead. LOW.
- **aurora-km source recovery** if not found locally — mitigated by pre-deletion scrape. LOW.
- **Continued credit pressure from `kmcaijobtracker`** until Phase 2 — the paused state may recur for *that* site, but the migrated static sites are unaffected on Cloudflare. ACCEPTED.

## Verification

For each migrated site:
1. Cloudflare Pages build succeeds; site loads at its `*.pages.dev` URL (HTTP 200, correct theme/assets, WebP images resolve).
2. **Business LP forms:** submit a real test entry on both the `contact` and `consulting-intake` forms; confirm the email arrives at the configured recipient(s) and the on-page success state fires.
3. Push a trivial commit; confirm auto-deploy fires on Cloudflare.
4. Only after the above pass: delete the corresponding Netlify site.
5. Confirm the credit-limit banner clears / sites are no longer the constraint (duplicate + static sites removed).

## Phasing

- **Phase 1 (this spec):** Units A–D above.
- **Phase 2 (separate spec):** migrate `kmcaijobtracker` Next.js frontend to Cloudflare Pages via `@cloudflare/next-on-pages` (or OpenNext), wiring `NEXT_PUBLIC_API_BASE_URL`/`APP_AUTH_TOKEN` to the existing external FastAPI host; then delete its Netlify site.

## Follow-ups / doc sync

- Update `C:\Users\keyst\CLAUDE.md` and the `project_business_landing_page.md` / `project_personal_landing_page.md` memories: new host (Cloudflare Pages), new URLs, Web3Forms replacing Netlify Forms, deploy command change, and removal of the two-Netlify-site GOTCHA + the `--dir .` hygiene dance.
