# Cloudflare Pages Migration — Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the three static sites (Business LP, Personal LP, aurora-km) off Netlify's credit-paused free tier onto Cloudflare Pages, convert the two Netlify Forms to Web3Forms, and delete the broken duplicate site.

**Architecture:** Each site becomes an independent Cloudflare Pages project. The two git-backed sites use Cloudflare's GitHub integration (push-to-`main` → auto-deploy, same trigger as today). aurora-km (manual deploy, no repo) ships via Wrangler direct upload after recovering its source. Netlify Forms (deploy-time HTML detection) are replaced by Web3Forms (client-side POST to a hosted endpoint + email delivery), so forms become host-independent.

**Tech Stack:** Static HTML/CSS/JS (no build step), Cloudflare Pages, Wrangler CLI (for aurora-km), Web3Forms (forms), Netlify CLI (cleanup/deletion), Git/GitHub.

**Verification note:** These are static sites with no automated test suite (the project's established convention is manual verification). "Verify" steps therefore use `curl` HTTP checks, browser inspection, and real form submissions rather than unit tests. Steps marked **[USER ACTION]** require the user (account signup, dashboard clicks, OAuth logins) — pause and hand these to the user, then continue once done. Steps marked **[CONFIRM]** are destructive or outward-facing (push, delete) — get explicit go-ahead before running.

**Deterministic project names → URLs** (chosen up front so URL rewrites are exact):
- Business LP → project `keystonemarcy` → `https://keystonemarcy.pages.dev`
- Personal LP → project `keith-links-995` → `https://keith-links-995.pages.dev`
- aurora-km → project `aurora-km` → `https://aurora-km.pages.dev`

---

### Task 1: Create the Web3Forms access key

**Files:** none (external account setup)

- [ ] **Step 1: [USER ACTION] Register a Web3Forms access key**

Go to https://web3forms.com → enter the email that should receive submissions (use `marcy.keystone@outlook.com`, the inbox already used for Netlify form notifications) → click "Create Access Key". Web3Forms emails an **Access Key** (a UUID like `a1b2c3d4-...`). This key is *public* and safe to embed in client HTML — that is how Web3Forms is designed to work.

- [ ] **Step 2: [USER ACTION] Add the second recipient**

In the Web3Forms confirmation email / dashboard, add `kmarcy@KMConsulting995.onmicrosoft.com` as a CC recipient (or note that a per-form `cc` hidden field will be added in Tasks 2–3) so both inboxes receive submissions, matching the current Netlify setup.

- [ ] **Step 3: Record the key for Tasks 2–3**

Paste the access key into this plan here for reference, then use it everywhere the literal `WEB3FORMS_ACCESS_KEY` appears in Tasks 2 and 3:

```
Access key: ____________________________________
```

---

### Task 2: Convert the contact form to Web3Forms (`contact.html`)

**Files:**
- Modify: `C:\Users\keyst\Business-Landing-Page\contact.html` (form markup at lines 77–81; JS handler at lines 155–160)

- [ ] **Step 1: Replace the Netlify form opening + honeypot with Web3Forms markup**

In `contact.html`, replace lines 77–81 (the `<form …>` open tag, the hidden `form-name` input, and the `bot-field` honeypot paragraph):

```html
      <form name="contact" method="POST" data-netlify="true" netlify-honeypot="bot-field" class="contact-form">
        <input type="hidden" name="form-name" value="contact" />
        <p class="hidden-field" aria-hidden="true">
          <label>Don't fill this out if you're human: <input name="bot-field" tabindex="-1" autocomplete="off" /></label>
        </p>
```

with:

```html
      <form name="contact" action="https://api.web3forms.com/submit" method="POST" class="contact-form">
        <input type="hidden" name="access_key" value="WEB3FORMS_ACCESS_KEY" />
        <input type="hidden" name="subject" value="New contact — keystonemarcy.pages.dev" />
        <input type="hidden" name="from_name" value="KM Consulting site" />
        <input type="hidden" name="cc" value="kmarcy@KMConsulting995.onmicrosoft.com" />
        <input type="checkbox" name="botcheck" class="hidden-field" style="display:none" tabindex="-1" autocomplete="off" aria-hidden="true" />
```

(Substitute the real key from Task 1 for `WEB3FORMS_ACCESS_KEY`. Leave the Name/Email/Message fields at lines 82–94 and the closing `</form>` unchanged.)

- [ ] **Step 2: Replace the submit handler with an AJAX Web3Forms handler**

In `contact.html`, replace the existing handler (lines 155–160):

```js
      var contactFormEl = document.querySelector('form[name="contact"]');
      if (contactFormEl) {
        contactFormEl.addEventListener('submit', function () {
          track('generate_lead', { method: 'contact_form' });
        });
      }
```

with:

```js
      var contactFormEl = document.querySelector('form[name="contact"]');
      if (contactFormEl) {
        contactFormEl.addEventListener('submit', function (e) {
          e.preventDefault();
          track('generate_lead', { method: 'contact_form' });
          var btn = contactFormEl.querySelector('button[type="submit"]');
          if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
          fetch('https://api.web3forms.com/submit', { method: 'POST', body: new FormData(contactFormEl) })
            .then(function (r) { return r.json(); })
            .then(function (data) {
              var msg = document.createElement('p');
              msg.className = 'form-status';
              if (data.success) {
                msg.textContent = "Thanks — your message is on its way. I'll be in touch shortly.";
                contactFormEl.replaceChildren(msg);
              } else {
                msg.textContent = 'Something went wrong. Please email kmarcy@KMConsulting995.onmicrosoft.com instead.';
                contactFormEl.appendChild(msg);
                if (btn) { btn.disabled = false; btn.textContent = 'Send message'; }
              }
            })
            .catch(function () {
              var msg = document.createElement('p');
              msg.className = 'form-status';
              msg.textContent = 'Network error. Please email kmarcy@KMConsulting995.onmicrosoft.com instead.';
              contactFormEl.appendChild(msg);
              if (btn) { btn.disabled = false; btn.textContent = 'Send message'; }
            });
        });
      }
```

(Uses `createElement`/`textContent`/`replaceChildren` — no `innerHTML` — so it stays safe under the home-dir security conventions.)

- [ ] **Step 3: Verify the file has no remaining Netlify form markup**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -nE 'data-netlify|netlify-honeypot|name="form-name"|bot-field' contact.html`
Expected: no output (all Netlify-specific markup removed from contact.html).

- [ ] **Step 4: Commit**

```bash
cd /c/Users/keyst/Business-Landing-Page
git add contact.html
git commit -m "Convert contact form from Netlify Forms to Web3Forms"
```

---

### Task 3: Convert the consulting-intake form to Web3Forms (`services.html`)

**Files:**
- Modify: `C:\Users\keyst\Business-Landing-Page\services.html` (form markup at lines 176–180; JS handler at lines 286–291)

- [ ] **Step 1: Replace the Netlify form opening + honeypot with Web3Forms markup**

In `services.html`, replace lines 176–180:

```html
      <form name="consulting-intake" method="POST" data-netlify="true" netlify-honeypot="bot-field" class="contact-form consult-form">
        <input type="hidden" name="form-name" value="consulting-intake" />
        <p class="hidden-field" aria-hidden="true">
          <label>Don't fill this out if you're human: <input name="bot-field" tabindex="-1" autocomplete="off" /></label>
        </p>
```

with:

```html
      <form name="consulting-intake" action="https://api.web3forms.com/submit" method="POST" class="contact-form consult-form">
        <input type="hidden" name="access_key" value="WEB3FORMS_ACCESS_KEY" />
        <input type="hidden" name="subject" value="New consulting intake — keystonemarcy.pages.dev" />
        <input type="hidden" name="from_name" value="KM Consulting site" />
        <input type="hidden" name="cc" value="kmarcy@KMConsulting995.onmicrosoft.com" />
        <input type="checkbox" name="botcheck" class="hidden-field" style="display:none" tabindex="-1" autocomplete="off" aria-hidden="true" />
```

(Substitute the real Task 1 key. Leave all fields at lines 181–231 — name/email/company, the `services` checkboxes, `details`, `budget`, `timeline`, and the submit button — and the closing `</form>` unchanged. The repeated `services` checkboxes submit fine as multiple values via `FormData`.)

- [ ] **Step 2: Replace the submit handler with an AJAX Web3Forms handler**

In `services.html`, replace the existing handler (lines 286–291):

```js
      var intakeFormEl = document.querySelector('form[name="consulting-intake"]');
      if (intakeFormEl) {
        intakeFormEl.addEventListener('submit', function () {
          track('generate_lead', { method: 'consulting_intake' });
        });
      }
```

with:

```js
      var intakeFormEl = document.querySelector('form[name="consulting-intake"]');
      if (intakeFormEl) {
        intakeFormEl.addEventListener('submit', function (e) {
          e.preventDefault();
          track('generate_lead', { method: 'consulting_intake' });
          var btn = intakeFormEl.querySelector('button[type="submit"]');
          if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
          fetch('https://api.web3forms.com/submit', { method: 'POST', body: new FormData(intakeFormEl) })
            .then(function (r) { return r.json(); })
            .then(function (data) {
              var msg = document.createElement('p');
              msg.className = 'form-status';
              if (data.success) {
                msg.textContent = "Got it — I'll review your project and come back with an approach and rough estimate shortly.";
                intakeFormEl.replaceChildren(msg);
              } else {
                msg.textContent = 'Something went wrong. Please email kmarcy@KMConsulting995.onmicrosoft.com instead.';
                intakeFormEl.appendChild(msg);
                if (btn) { btn.disabled = false; btn.textContent = 'Send request'; }
              }
            })
            .catch(function () {
              var msg = document.createElement('p');
              msg.className = 'form-status';
              msg.textContent = 'Network error. Please email kmarcy@KMConsulting995.onmicrosoft.com instead.';
              intakeFormEl.appendChild(msg);
              if (btn) { btn.disabled = false; btn.textContent = 'Send request'; }
            });
        });
      }
```

- [ ] **Step 3: Add a `.form-status` style so the success/error message is legible**

Append to `C:\Users\keyst\Business-Landing-Page\assets\site.css`:

```css
.form-status {
  margin: 0;
  padding: 1rem 1.1rem;
  border: 1px solid var(--border);
  border-radius: var(--r-md);
  background: var(--surface);
  color: var(--text);
  font-weight: 500;
}
```

- [ ] **Step 4: Verify no remaining Netlify form markup**

Run: `cd /c/Users/keyst/Business-Landing-Page && grep -rnE 'data-netlify|netlify-honeypot|name="form-name"|bot-field' --include=*.html . | grep -v preview-`
Expected: no output (no Netlify form markup in any tracked page).

- [ ] **Step 5: Commit**

```bash
cd /c/Users/keyst/Business-Landing-Page
git add services.html assets/site.css
git commit -m "Convert consulting-intake form to Web3Forms + add form-status style"
```

---

### Task 4: Rewrite Business LP `netlify.app` URLs → `pages.dev`

**Files:**
- Modify: every tracked file containing `keystonemarcy.pages.dev` (16 files: `index.html`, `about.html`, `contact.html`, `experience.html`, `how-i-work.html`, `services.html`, `work.html`, `work/*.html`, `robots.txt`, `sitemap.xml`)

- [ ] **Step 1: Replace the domain across all tracked files**

```bash
cd /c/Users/keyst/Business-Landing-Page
git grep -l 'keystonemarcy\.netlify\.app' | xargs sed -i 's/keystonemarcy\.netlify\.app/keystonemarcy.pages.dev/g'
```

- [ ] **Step 2: Verify the old domain is gone and the new one is present**

Run: `cd /c/Users/keyst/Business-Landing-Page && git grep -c 'keystonemarcy\.netlify\.app'; echo "--- new ---"; git grep -c 'keystonemarcy\.pages\.dev' | head`
Expected: first command prints nothing (zero matches for the old domain); second lists files now referencing `keystonemarcy.pages.dev`.

- [ ] **Step 3: Commit**

```bash
cd /c/Users/keyst/Business-Landing-Page
git add -A
git commit -m "Point canonical/OG/sitemap URLs at keystonemarcy.pages.dev"
```

---

### Task 5: Rewrite Personal LP `netlify.app` URLs → `pages.dev`

**Files:**
- Modify: `C:\Users\keyst\Personal-Landing-Page\index.html`, `robots.txt`, `sitemap.xml` (3 files containing `keith-links-995.netlify.app`)

- [ ] **Step 1: Replace the domain across all tracked files**

```bash
cd /c/Users/keyst/Personal-Landing-Page
git grep -l 'keith-links-995\.netlify\.app' | xargs sed -i 's/keith-links-995\.netlify\.app/keith-links-995.pages.dev/g'
```

- [ ] **Step 2: Verify**

Run: `cd /c/Users/keyst/Personal-Landing-Page && git grep -c 'keith-links-995\.netlify\.app'; echo "--- new ---"; git grep -c 'keith-links-995\.pages\.dev'`
Expected: zero matches for the old domain; matches present for the new one.

- [ ] **Step 3: Commit**

```bash
cd /c/Users/keyst/Personal-Landing-Page
git add -A
git commit -m "Point canonical/robots/sitemap URLs at keith-links-995.pages.dev"
```

---

### Task 6: Push both repos to GitHub

**Files:** none (git push)

- [ ] **Step 1: [CONFIRM] Push Business LP**

```bash
cd /c/Users/keyst/Business-Landing-Page && git push origin main
```
(Cloudflare's git integration in Task 7 deploys from GitHub, so the form + URL commits must be on `main` first. The broken Netlify sibling will fail its auto-build on this push — that is expected and harmless; it gets deleted in Task 10.)

- [ ] **Step 2: [CONFIRM] Push Personal LP**

```bash
cd /c/Users/keyst/Personal-Landing-Page && git push origin main
```

- [ ] **Step 3: Verify both pushes landed**

Run: `cd /c/Users/keyst/Business-Landing-Page && git status -sb | head -1; cd /c/Users/keyst/Personal-Landing-Page && git status -sb | head -1`
Expected: both show `## main...origin/main` with no "ahead" count.

---

### Task 7: Create the two git-connected Cloudflare Pages projects

**Files:** none (Cloudflare dashboard)

- [ ] **Step 1: [USER ACTION] Ensure a Cloudflare account exists**

If the user has no Cloudflare account, sign up free at https://dash.cloudflare.com/sign-up. No card required for Pages.

- [ ] **Step 2: [USER ACTION] Create the Business LP project**

Cloudflare dashboard → **Workers & Pages** → **Create** → **Pages** → **Connect to Git** → authorize the GitHub app for `kmarcy95` → select **`Business-Landing-Page`** → configure:
- Project name: **`keystonemarcy`** (this sets the URL to `keystonemarcy.pages.dev`)
- Production branch: **`main`**
- Framework preset: **None**
- Build command: **(leave empty)**
- Build output directory: **`/`**

Click **Save and Deploy**.

- [ ] **Step 3: [USER ACTION] Create the Personal LP project**

Repeat Step 2 for the **`Personal-Landing-Page`** repo:
- Project name: **`keith-links-995`** → URL `keith-links-995.pages.dev`
- Production branch: **`main`**, preset **None**, build command **empty**, output dir **`/`**.

- [ ] **Step 4: Verify both sites are live and assets resolve**

Run:
```bash
curl -s -o /dev/null -w "biz home: %{http_code}\n" https://keystonemarcy.pages.dev/
curl -s -o /dev/null -w "biz contact: %{http_code}\n" https://keystonemarcy.pages.dev/contact.html
curl -s -o /dev/null -w "biz headshot webp: %{http_code}\n" https://keystonemarcy.pages.dev/images/headshot-about.webp
curl -s -o /dev/null -w "personal home: %{http_code}\n" https://keith-links-995.pages.dev/
curl -s -o /dev/null -w "personal planner: %{http_code}\n" https://keith-links-995.pages.dev/planner.html
```
Expected: all `200`. (If a `.webp` 404s, the output dir is wrong — it must be `/`.)

- [ ] **Step 5: Verify the forms actually deliver (the critical check)**

[USER ACTION] In a browser, open `https://keystonemarcy.pages.dev/contact.html`, submit a real test message, and confirm: (a) the inline "Thanks — your message is on its way" success state appears, and (b) the email arrives at `marcy.keystone@outlook.com` (and the CC at `kmarcy@KMConsulting995.onmicrosoft.com`). Repeat on `https://keystonemarcy.pages.dev/services.html#intake` for the consulting-intake form. Do **not** proceed to deletion (Task 10) until both forms are confirmed working.

---

### Task 8: Recover and migrate aurora-km

**Files:**
- Possibly create: a local source folder for aurora-km (location TBD by Step 1)

- [ ] **Step 1: Locate the aurora-km source**

Run a broad search for the source (it is NOT a connected git repo and was a manual Netlify deploy):
```bash
cd /c/Users/keyst
ls -d *aurora* *Aurora* 2>/dev/null
grep -rIl --include=*.html 'aurora' OneDrive 2>/dev/null | head
```
Also check `C:\tmp` and `Downloads`. If a folder with the aurora-km `index.html` is found, note its path and skip to Step 3.

- [ ] **Step 2: If no source is found, scrape the live site BEFORE it is deleted**

The live deploy is the last copy. Mirror it locally while it is still up:
```bash
mkdir -p /c/tmp/aurora-km-src
cd /c/tmp/aurora-km-src
wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -e robots=off https://aurora-km.netlify.app/ 2>&1 | tail -5
ls -R aurora-km.netlify.app 2>/dev/null | head
```
(If `wget` is unavailable, use `curl` to fetch `index.html` plus its referenced assets, or download the deploy from the Netlify dashboard → aurora-km → Deploys → latest → "Download".) The recovered files become the deploy directory; call it `<AURORA_SRC>`.

- [ ] **Step 3: [USER ACTION] Install + authenticate Wrangler (one-time)**

```bash
npm install -g wrangler
wrangler login
```
`wrangler login` opens a browser for Cloudflare OAuth — complete it.

- [ ] **Step 4: Create the project and deploy via direct upload**

```bash
wrangler pages project create aurora-km --production-branch main
wrangler pages deploy "<AURORA_SRC>" --project-name aurora-km --branch main
```
(Replace `<AURORA_SRC>` with the folder from Step 1 or 2 — the directory that contains aurora-km's `index.html`.)

- [ ] **Step 5: Verify**

Run: `curl -s -o /dev/null -w "aurora: %{http_code}\n" https://aurora-km.pages.dev/`
Expected: `200`. Open it in a browser and confirm it renders the same as the old Netlify site.

---

### Task 9: Delete the broken duplicate Netlify site

**Files:** none (Netlify API)

- [ ] **Step 1: [CONFIRM] Delete `keystonemarcykmconsulting`**

This site is a pure duplicate of the Business LP whose builds fail on every push (wasting credits). It has no unique content to preserve.
```bash
netlify api deleteSite '{"site_id":"55407d90-c8c3-4948-a7e4-644aeba1860a"}'
```

- [ ] **Step 2: Verify it is gone**

Run: `netlify api listSites 2>&1 | python -c "import sys,json; print([s['name'] for s in json.load(sys.stdin)])"`
Expected: `keystonemarcykmconsulting` no longer in the list.

---

### Task 10: Retire the migrated Netlify sites (frees the credits)

**Files:** none (Netlify API)

- [ ] **Step 1: Pre-flight — confirm all three Cloudflare sites are verified**

Confirm Task 7 Step 5 (forms deliver) and Task 8 Step 5 (aurora renders) both passed. Deleting the Netlify sites is what actually relieves the credit limit, but it is irreversible for `aurora-km` (no git repo) — so verification must come first.

- [ ] **Step 2: [CONFIRM] Delete the three migrated Netlify sites**

```bash
netlify api deleteSite '{"site_id":"8a8690a8-3948-4dd8-8ebd-0ead895bfd17"}'   # keystonemarcy
netlify api deleteSite '{"site_id":"fd50bef9-62d..."}'                         # keith-links-995 (use full id from listSites)
netlify api deleteSite '{"site_id":"ba1cab17-c8e5-4e43-a11e-3558e8c78b86"}'    # aurora-km
```
(Run `netlify api listSites` first to copy the exact full `keith-links-995` site id.) **Alternative if the user prefers a safety net:** leave these three sites in place but *unlinked from auto-deploy* — they will sit idle. Deleting is recommended because idle sites still count toward the credit math; only `kmcaijobtracker` should remain.

- [ ] **Step 3: Verify only the job tracker remains**

Run: `netlify api listSites 2>&1 | python -c "import sys,json; print([s['name'] for s in json.load(sys.stdin)])"`
Expected: only `kmcaijobtracker` (Phase 2) remains.

- [ ] **Step 4: [USER ACTION] Confirm the credit banner clears**

In the Netlify dashboard, confirm the "exceeded the credit limit" banner is resolving and `kmcaijobtracker` is no longer paused (or note that it may still hit limits on its own — that is the Phase 2 problem).

---

### Task 11: Sync documentation

**Files:**
- Modify: `C:\Users\keyst\CLAUDE.md`
- Modify: `C:\Users\keyst\.claude\projects\C--Users-keyst\memory\project_business_landing_page.md`
- Modify: `C:\Users\keyst\.claude\projects\C--Users-keyst\memory\project_personal_landing_page.md`

- [ ] **Step 1: Update CLAUDE.md**

In the **Business Landing Page** and **Personal Landing Page** sections of `CLAUDE.md`:
- Change host references from Netlify to **Cloudflare Pages**; update **Live URLs** to `keystonemarcy.pages.dev` and `keith-links-995.pages.dev`.
- Replace the **Deploy** lines: new deploy = `git push origin main` (Cloudflare auto-deploys from GitHub; no `netlify deploy`, no `--dir .` hygiene dance, no two-site sibling workaround). Remove/clearly retire the "two Netlify sites" GOTCHA and the broken-sibling workaround.
- Change form references from **Netlify Forms** to **Web3Forms** (contact + consulting-intake; access key embedded client-side; recipients `marcy.keystone@outlook.com` + CC `kmarcy@KMConsulting995.onmicrosoft.com`).
- Note that `kmcaijobtracker` remains on Netlify pending **Phase 2** (Next.js → Cloudflare).

- [ ] **Step 2: Update the two project memory files**

Apply the same changes (host, URLs, deploy command, forms, retired GOTCHAs) to `project_business_landing_page.md` and `project_personal_landing_page.md` so memory and CLAUDE.md stay in sync (per the user's standing "keep docs updated" preference).

- [ ] **Step 3: Commit the doc changes in each repo**

```bash
cd /c/Users/keyst/Business-Landing-Page && git add docs && git commit -m "Docs: migration plan complete (Cloudflare Pages + Web3Forms)" || true
```
(The CLAUDE.md and memory files live in the home directory, not these repos — save them in place; they are not committed to the landing-page repos.)

---

## Self-Review

**Spec coverage:**
- Host → Cloudflare Pages: Tasks 7 (git sites), 8 (aurora). ✓
- Forms → Web3Forms (critical): Tasks 1–3, verified in Task 7 Step 5. ✓
- URLs → pages.dev: Tasks 4–5. ✓
- Delete duplicate: Task 9. ✓
- Retire migrated Netlify sites / free credits: Task 10. ✓
- aurora-km source recovery before deletion: Task 8 Step 2 + Task 10 Step 1 ordering. ✓
- Personal LP `/admin` Decap left dead (non-regression): no task needed; called out in spec Non-goals. ✓
- Job tracker deferred to Phase 2: stated in header + Task 10. ✓
- Doc sync: Task 11. ✓

**Placeholder scan:** The only literal placeholders are `WEB3FORMS_ACCESS_KEY` (a runtime secret the user generates in Task 1 — instructed to substitute), `<AURORA_SRC>` (a path discovered in Task 8 Step 1/2), and the truncated `keith-links-995` site id in Task 10 (instructed to fetch the full id via `listSites`). These are unavoidable runtime values with explicit resolution instructions, not unfilled design gaps.

**Type/identifier consistency:** Form element vars (`contactFormEl`, `intakeFormEl`), the `.form-status` class (defined in Task 3 Step 3, used by both handlers), button-label restore strings ("Send message" / "Send request"), and the Web3Forms field names (`access_key`/`subject`/`from_name`/`cc`/`botcheck`) are consistent across Tasks 2–3. Project names (`keystonemarcy`/`keith-links-995`/`aurora-km`) map consistently to the `*.pages.dev` URLs used in Tasks 4–10.
