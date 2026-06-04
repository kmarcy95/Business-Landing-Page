# Cost Accounting Template Tools — Suite + Flagship Design

**Date:** 2026-06-03
**Project:** Business Landing Page (KM Consulting) — `templates.html` product catalog
**Status:** Approved design (pending user spec review) → next step is `writing-plans`

---

## 1. Goal

Extend the KM Consulting finance-template catalog with a line of **sophisticated cost-accounting Excel template tools**. Each tool ships as a matched pair: a **free, self-contained browser demo** that funnels to a **paid downloadable `.xlsx`**. The line reinforces the recruiter-first positioning ("in-seat FP&A leader who builds real tools") and feeds the consulting funnel.

The full line is a **suite of four** independent tools, built one at a time on a shared pattern:

1. **Standard Costing & Variance Analysis** — *the flagship, designed in full here.*
2. Job-Order / Project Costing
3. Activity-Based Costing (ABC)
4. Inventory Valuation & Overhead Absorption

Tools 2–4 are out of scope for this spec; they reuse the conventions in §3 and get their own spec → plan → build cycle later.

## 2. Build approach (decided: "Spec-first shared engine")

Both deliverables compute the same variances, so the math must match exactly. Approach: define the variance math **once** as an authoritative set of formulas + worked examples; build the browser demo from it (where the numbers can be executed and unit-tested in JS); lock the math against known-answer examples; then hand the verified spec to the `shortcut` CLI to author the `.xlsx`. One source of truth — the file and the demo cannot drift.

Rejected alternatives: `.xlsx`-first (Excel formulas are harder to execute/verify than JS; demo becomes reverse-engineered) and demo-first/defer-xlsx (abandons the paid half).

## 3. Suite architecture — shared conventions

Conventions every tool in the line follows, established by the flagship:

- **Two artifacts per tool:**
  - Free browser demo: `cost-<slug>.html` at the repo root (precedent: `contract-reconciler.html`).
  - Paid downloadable `.xlsx` in `downloads/`.
- **Funnel:** free-demo `.bento-card` on `templates.html` → CTA opens the demo → in-demo "Get the full multi-product Excel model — $X" button posts the existing **Web3Forms** purchase flow (same `access_key` / `cc` / subject pattern as the `buy13week` form). Keystone emails a payment link + the file within 1 business day.
- **Browser-demo shell:** fully self-contained — its own professional light palette (white surfaces, navy→slate-blue accent, Inter), brand bar + back-link + footer, **not** dependent on `assets/site.css` (avoids class collisions, mirrors `contract-reconciler.html`). Runs entirely client-side; nothing is uploaded.
- **Workbook skeleton (every paid `.xlsx`):**
  1. `Read Me` — what it does, how to use, assumptions, version.
  2. `Inputs` — standards / budgeted rates & quantities (the cells the user edits).
  3. `Actuals` — actual rates, quantities, volumes.
  4. `Calc` — the variance engine (formula-only, protected/locked).
  5. `Dashboard` — variance bridge/waterfall + KPI summary.
  6. `Example` — a pre-filled worked sample that ties out to the spec to the cent.
- **Workbook hygiene:** named ranges for inputs; data validation on input cells; input cells visually distinct (fill/border) from calculated cells; `Calc`/`Dashboard` protected; formula-only (no macros — stays `.xlsx`, Excel 2016+).
- **Pricing convention:** free demo + paid `.xlsx`; price set per tool.

## 4. Flagship spec — Standard Costing & Variance Analysis

### 4.1 Variance coverage (full suite, multi-product / multi-input)

All variances reconcile **budgeted operating profit → actual operating profit**.

**Direct material**
- Price variance = (AP − SP) × AQ purchased
- Quantity/usage variance = (AQ used − SQ allowed) × SP
- **Mix** variance = Σ [(actual mix % − standard mix %) × total actual qty] × SP
- **Yield** variance = (actual total input − standard input for actual output) × standard weighted-avg cost

**Direct labor**
- Rate variance = (AR − SR) × AH
- Efficiency variance = (AH − SH allowed) × SR
- **Mix** variance (multi-grade labor) = analogous to material mix

**Overhead**
- Variable OH spending = actual VOH − (SVR × actual activity)
- Variable OH efficiency = SVR × (actual activity − standard activity allowed)
- Fixed OH budget (spending) = actual FOH − budgeted FOH
- Fixed OH volume = budgeted FOH − (SFR × standard activity allowed)

**Sales**
- Sales price variance = (actual price − budgeted price) × actual units
- Sales volume variance = (actual units − budgeted units) × budgeted contribution margin per unit
- **Sales mix** variance = Σ [(actual mix % − budgeted mix %) × total actual units] × budgeted CM per unit

**Reconciliation**
- Budgeted operating profit + favorable variances − unfavorable variances = actual operating profit (closing waterfall must tie exactly).

*Sign/labeling convention:* favorable (F) when actual cost < standard or actual revenue > budget; unfavorable (U) otherwise. Stated consistently across demo and workbook.

### 4.2 Free browser demo — `cost-standard-costing.html` (teaser scope)

- **Inputs:** single product. Standard vs. actual for price/qty (material), rate/hours (labor), and overhead (variable + fixed).
- **Outputs:** the **core** variances — material price & quantity, labor rate & efficiency, variable OH spending & efficiency, fixed OH budget & volume — rendered as a live **variance waterfall** (budgeted cost → actual cost) plus a plain-English "what this means" read-out per variance (F/U + driver).
- **Excluded from the demo (paid upgrade):** multi-product, material mix & yield, labor mix, sales variances, and the full operating-profit bridge. The demo explicitly names these as what the paid model adds.
- **Behavior:** all math client-side; pre-filled with the worked example on load; reset button; mobile + `prefers-reduced-motion` friendly.

### 4.3 Paid `.xlsx` — full multi-product model ($129)

- Multi-product, multi-material-input workbook implementing **every** variance family in §4.1.
- `Dashboard` = operating-profit bridge waterfall + per-variance KPI table (amount, F/U, % of standard).
- Scenario-style inputs on `Inputs`/`Actuals`; `Example` tab pre-filled with a worked multi-product case that ties to the spec.
- Formula-only; Excel 2016+. Google Sheets caveats noted in `Read Me` for any functions that differ.
- **Price: $129** (a step above the $99 13-Week tool; justified by breadth).

## 5. Toolchain & skills map

| Phase | Skill / tool | Notes |
|---|---|---|
| Design (this doc) | `superpowers:brainstorming` → `superpowers:writing-plans` | Brainstorm → implementation plan |
| All coding sessions | `andrej-karpathy-skills:karpathy-guidelines` | Required every session (home CLAUDE.md) |
| Variance math spec | Cost-accounting domain knowledge, written as worked examples | Single source of truth (§2) |
| Browser demo build | `frontend-design` + the `contract-reconciler.html` pattern | Self-contained client-side tool |
| Math verification | `superpowers:test-driven-development` + `superpowers:systematic-debugging` | Unit-test JS variance functions vs. known-answer examples before handoff |
| Paid `.xlsx` authoring | **`shortcut` CLI ONLY** — `shortcut -p "<task>" @"<file>" --skip-spreadsheet-permissions --provider anthropic` | Hook-enforced. Built-in `xlsx` / `complex-excel-builder` / `excel-variance-analyzer` skills are **deliberately excluded** (routing rule forbids them on `.xlsx`). Verified: `shortcut` v0.3.56 installed, `ANTHROPIC_API_KEY` set. |
| Spec / copy polish | `elements-of-style:writing-clearly-and-concisely` (if available) | Clean spec + catalog copy |
| Catalog integration | Existing `templates.html` patterns | `.bento-card`, Web3Forms forms, per-tab accent theme |

## 6. Catalog integration

- Add two presences on `templates.html`: a **free interactive tool** card (links to `cost-standard-costing.html`) and the **paid `.xlsx`** purchase card ($129, reusing the `buy`-form Web3Forms pattern).
- Add both pages to `sitemap.xml`.
- Card cover image: Chrome-headless screenshot of the demo → WebP (sharp in `C:\tmp`), per existing convention.
- Keep `templates.html` on its current `theme-orange` accent; the demo page carries its own self-contained palette.

## 7. Testing / verification

1. **Demo math:** JS variance functions unit-tested against hand-computed worked examples (textbook standard-costing problems with published answers). All variance families that exist in the demo must pass before any `.xlsx` work.
2. **Workbook tie-out:** feed the `Example` inputs into the `shortcut`-built `.xlsx`; confirm every output ties to the demo and the spec **to the cent**, and that the operating-profit bridge reconciles.
3. **Demo UX:** manual browser smoke test — no upload, reset works, mobile layout, reduced-motion.
4. **Catalog:** links resolve, forms post, sitemap updated, cover image renders.

## 8. Out of scope (this spec)

- Tools 2–4 of the suite (separate spec/plan/build each).
- Macros / VBA / Office Scripts (formula-only by decision).
- Payment automation (manual payment-link flow, matching the existing 13-Week tool).
- Analytics IDs (site-wide GA4/Clarity still scaffold-only).

## 9. Deliverables checklist

- [ ] `cost-standard-costing.html` — free browser demo (core variances, waterfall, plain-English read-out)
- [ ] Worked-example test set + passing JS unit tests for the variance math
- [ ] `downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx` — full multi-product model (built via `shortcut`)
- [ ] `Example` tab tie-out verified to the spec
- [ ] `templates.html` — free-demo card + $129 paid card
- [ ] Cover image (WebP) + `sitemap.xml` entries
