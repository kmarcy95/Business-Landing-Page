# Work tab → case-study feed

**Date:** 2026-06-09
**Page:** `work.html` (theme-indigo)
**Goal:** Make the projects easier to *see*. Replace the six uniform bento cards (each with one small screenshot) with a portfolio-style feed of large, alternating image-and-story rows.

## What changes
- Swap the `.bento` grid inside `work.html`'s `<section>` for a `.case-feed` of six `.case-row`s.
- Each row alternates: odd rows image-left, even rows image-right (`.case-row.flip`).
- Stacks to single column (image on top) on narrow screens.
- Same six projects, same order, same detail-page links:
  D365 → Codex → Agentic OS → Creator → Aurora → Housing ML.

## Each row
- **Media:** existing `images/proj-*.webp` in the current `.shot` browser-chrome frame, rendered large.
- **Body:**
  - `.card-label` (tech stack, reused) + a **category tag** (`.case-cat`): Finance tooling · AI system · Data science.
  - `.card-title` (reused).
  - **Impact pill** (`.case-impact`) — the one-line "so what", lifted from the bolded clause already in each card's copy (nothing invented).
  - 1–2 sentence description (trimmed current copy).
  - `.tag-row`/`.tag` tech tags (reused).
  - "View walkthrough →" link.
- **D365 only:** a single "Live demo" badge (`.case-live`) — it's the one project with a public companion demo.

## Badges decision
No site-wide live/case-study badge (only D365 is publicly live, would mislead). Category tags carry the framing and reinforce breadth.

## Implementation
- New `.case-feed` / `.case-row` / `.case-media` / `.case-body` / `.case-impact` / `.case-cat` / `.case-live` / `.case-view` CSS **appended** to `assets/site.css` (scoped — no edits to existing rules, no other page affected).
- Reuses `.shot*`, `.card-image`, `.card-label`, `.card-title`, `.tag-row`, `.tag`.
- No JS changes — reveal-on-scroll already targets `.reveal`; rows keep the `.reveal` class + staggered `transition-delay`.

## Success criteria
- `work.html` shows 6 alternating large rows; all 6 detail-page links and `proj-*.webp` images intact.
- No visual regression on other pages (only additive CSS + markup inside work.html's section).
- Headless screenshot confirms the alternating big-row layout.
