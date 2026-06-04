# Standard Costing & Variance Analysis Flagship — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the flagship cost-accounting tool — a free, tested browser variance calculator (`cost-standard-costing.html`) that funnels to a paid $129 multi-product Excel model — and surface both on `templates.html`.

**Architecture:** A pure-function JS variance engine (`assets/cost-variance-engine.js`) is the single source of truth for the math; it is unit-tested with Node's built-in test runner and loaded by the self-contained demo page. The paid `.xlsx` is authored by the `shortcut` CLI from the same documented formulas and verified to tie out to a hand-computed worked example. `templates.html` gets a free-tool card + a paid purchase card (Web3Forms).

**Tech Stack:** Vanilla HTML/CSS/JS (no build, no framework — matches `contract-reconciler.html`); Node `node:test` for unit tests; `shortcut` CLI v0.3.56 (`--provider anthropic`) for the Excel workbook; Web3Forms for the purchase inquiry; `sharp` (in `C:\tmp`) for the cover image.

**Working directory:** All paths are relative to the repo root `C:\Users\keyst\Business-Landing-Page`. Run all commands from there.

---

## File Structure

- `assets/cost-variance-engine.js` — **Create.** Pure variance math (no DOM). UMD-style export so both Node tests and the browser page use the identical code. One responsibility: compute standard-costing variances.
- `tests/cost-variance-engine.test.js` — **Create.** Node unit tests locking the engine to a hand-computed worked example.
- `cost-standard-costing.html` — **Create.** Self-contained free demo (own inline CSS, brand bar, inputs, variance bridge, plain-English read-out, paid CTA). Loads `assets/cost-variance-engine.js`.
- `downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx` — **Create (via `shortcut` only).** Paid full multi-product model.
- `templates.html` — **Modify.** Add a free-tool card (Card 4) and a paid purchase card (Card 5).
- `sitemap.xml` — **Modify.** Add the new demo page URL.
- `images/templates/standard-costing-cover.webp` — **Create.** Card cover screenshot.

**Worked example (the single source of numeric truth — used by tests, the demo defaults, and `.xlsx` verification):**

Single product, actual output drives the standard quantities below.

| Element | Standard | Actual |
|---|---|---|
| Material price / qty | $5.00/lb · 3,000 lb | $5.20/lb · 3,200 lb |
| Labor rate / hours | $20.00/hr · 2,000 hr | $19.50/hr · 2,100 hr |
| Variable OH | rate $4.00/labor-hr (applied on hours) | actual VOH $8,600 |
| Fixed OH | budget $11,000 · std fixed rate $5.00/hr | actual FOH $11,300 |

Expected variances (sign convention: **positive = Unfavorable**, negative = Favorable):

- Material price = (5.20−5.00)×3,200 = **+640 U**
- Material quantity = (3,200−3,000)×5.00 = **+1,000 U**
- Labor rate = (19.50−20.00)×2,100 = **−1,050 F**
- Labor efficiency = (2,100−2,000)×20.00 = **+2,000 U**
- Variable OH spending = 8,600 − 4.00×2,100 = **+200 U**
- Variable OH efficiency = 4.00×(2,100−2,000) = **+400 U**
- Fixed OH budget = 11,300 − 11,000 = **+300 U**
- Fixed OH volume = 11,000 − 5.00×2,000 = **+1,000 U**
- Standard cost = 15,000 + 40,000 + 8,000 + 10,000 = **$73,000**
- Actual cost = 16,640 + 40,950 + 8,600 + 11,300 = **$77,490**
- Total variance = 77,490 − 73,000 = **+4,490 U** (equals the sum of the 8 variances — must reconcile)

---

## Task 1: Variance engine — failing tests

**Files:**
- Create: `tests/cost-variance-engine.test.js`

- [ ] **Step 1: Write the failing test file**

```javascript
const test = require('node:test');
const assert = require('node:assert/strict');
const VE = require('../assets/cost-variance-engine.js');

const example = {
  standardPrice: 5.00, standardQty: 3000, actualPrice: 5.20, actualQty: 3200,
  standardRate: 20.00, standardHours: 2000, actualRate: 19.50, actualHours: 2100,
  standardVarRate: 4.00, actualVOH: 8600,
  budgetedFOH: 11000, standardFixedRate: 5.00, actualFOH: 11300
};

test('material price variance', () => {
  assert.equal(VE.materialPriceVariance(5.20, 5.00, 3200), 640);
});
test('material quantity variance', () => {
  assert.equal(VE.materialQuantityVariance(3200, 3000, 5.00), 1000);
});
test('labor rate variance is favorable (negative)', () => {
  assert.equal(VE.laborRateVariance(19.50, 20.00, 2100), -1050);
});
test('labor efficiency variance', () => {
  assert.equal(VE.laborEfficiencyVariance(2100, 2000, 20.00), 2000);
});
test('variable OH spending variance', () => {
  assert.equal(VE.variableOhSpendingVariance(8600, 4.00, 2100), 200);
});
test('variable OH efficiency variance', () => {
  assert.equal(VE.variableOhEfficiencyVariance(4.00, 2100, 2000), 400);
});
test('fixed OH budget variance', () => {
  assert.equal(VE.fixedOhBudgetVariance(11300, 11000), 300);
});
test('fixed OH volume variance', () => {
  assert.equal(VE.fixedOhVolumeVariance(11000, 5.00, 2000), 1000);
});
test('classify maps sign to F/U', () => {
  assert.equal(VE.classify(640).label, 'U');
  assert.equal(VE.classify(640).favorable, false);
  assert.equal(VE.classify(-1050).label, 'F');
  assert.equal(VE.classify(-1050).favorable, true);
  assert.equal(VE.classify(0).label, '—');
});
test('computeAll totals and reconciliation', () => {
  const r = VE.computeAll(example);
  assert.equal(r.material.total, 1640);
  assert.equal(r.labor.total, 950);
  assert.equal(r.varOH.total, 600);
  assert.equal(r.fixedOH.total, 1300);
  assert.equal(r.totals.standardCost, 73000);
  assert.equal(r.totals.actualCost, 77490);
  assert.equal(r.totals.totalVariance, 4490);
  assert.equal(r.reconciles, true);
});
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `node --test tests/*.test.js`  (the bare `node --test tests/` directory form is broken on Node 24/Windows — use the glob)
Expected: FAIL — `Cannot find module '../assets/cost-variance-engine.js'`.

- [ ] **Step 3: Commit the failing test**

```bash
git add tests/cost-variance-engine.test.js
git commit -m "test: add failing variance-engine tests with worked example"
```

## Task 2: Variance engine — implementation

**Files:**
- Create: `assets/cost-variance-engine.js`
- Test: `tests/cost-variance-engine.test.js`

- [ ] **Step 1: Write the engine**

```javascript
/* Standard Costing variance engine — pure functions, no DOM.
 * Sign convention: returned dollar amounts are signed so that
 *   POSITIVE  = Unfavorable (actual cost above standard)
 *   NEGATIVE  = Favorable   (actual cost below standard)
 * Overhead activity base = labor hours (actualHours / standardHours).
 */
(function (root) {
  'use strict';

  function round2(n) { return Math.round((n + Number.EPSILON) * 100) / 100; }

  function materialPriceVariance(actualPrice, standardPrice, actualQty) {
    return round2((actualPrice - standardPrice) * actualQty);
  }
  function materialQuantityVariance(actualQty, standardQty, standardPrice) {
    return round2((actualQty - standardQty) * standardPrice);
  }
  function laborRateVariance(actualRate, standardRate, actualHours) {
    return round2((actualRate - standardRate) * actualHours);
  }
  function laborEfficiencyVariance(actualHours, standardHours, standardRate) {
    return round2((actualHours - standardHours) * standardRate);
  }
  function variableOhSpendingVariance(actualVOH, standardVarRate, actualActivity) {
    return round2(actualVOH - standardVarRate * actualActivity);
  }
  function variableOhEfficiencyVariance(standardVarRate, actualActivity, standardActivity) {
    return round2(standardVarRate * (actualActivity - standardActivity));
  }
  function fixedOhBudgetVariance(actualFOH, budgetedFOH) {
    return round2(actualFOH - budgetedFOH);
  }
  function fixedOhVolumeVariance(budgetedFOH, standardFixedRate, standardActivity) {
    return round2(budgetedFOH - standardFixedRate * standardActivity);
  }

  function classify(amount) {
    if (Math.abs(amount) < 0.005) return { label: '—', favorable: null };
    return amount > 0 ? { label: 'U', favorable: false } : { label: 'F', favorable: true };
  }

  function computeAll(i) {
    var material = {
      price: materialPriceVariance(i.actualPrice, i.standardPrice, i.actualQty),
      quantity: materialQuantityVariance(i.actualQty, i.standardQty, i.standardPrice)
    };
    material.total = round2(material.price + material.quantity);

    var labor = {
      rate: laborRateVariance(i.actualRate, i.standardRate, i.actualHours),
      efficiency: laborEfficiencyVariance(i.actualHours, i.standardHours, i.standardRate)
    };
    labor.total = round2(labor.rate + labor.efficiency);

    var varOH = {
      spending: variableOhSpendingVariance(i.actualVOH, i.standardVarRate, i.actualHours),
      efficiency: variableOhEfficiencyVariance(i.standardVarRate, i.actualHours, i.standardHours)
    };
    varOH.total = round2(varOH.spending + varOH.efficiency);

    var fixedOH = {
      budget: fixedOhBudgetVariance(i.actualFOH, i.budgetedFOH),
      volume: fixedOhVolumeVariance(i.budgetedFOH, i.standardFixedRate, i.standardHours)
    };
    fixedOH.total = round2(fixedOH.budget + fixedOH.volume);

    var standardCost = round2(
      i.standardPrice * i.standardQty +
      i.standardRate * i.standardHours +
      i.standardVarRate * i.standardHours +
      i.standardFixedRate * i.standardHours
    );
    var actualCost = round2(
      i.actualPrice * i.actualQty +
      i.actualRate * i.actualHours +
      i.actualVOH +
      i.actualFOH
    );
    var totalVariance = round2(actualCost - standardCost);
    var sumOfVariances = round2(material.total + labor.total + varOH.total + fixedOH.total);

    return {
      material: material, labor: labor, varOH: varOH, fixedOH: fixedOH,
      totals: { standardCost: standardCost, actualCost: actualCost, totalVariance: totalVariance },
      reconciles: Math.abs(sumOfVariances - totalVariance) < 0.01
    };
  }

  var api = {
    materialPriceVariance: materialPriceVariance,
    materialQuantityVariance: materialQuantityVariance,
    laborRateVariance: laborRateVariance,
    laborEfficiencyVariance: laborEfficiencyVariance,
    variableOhSpendingVariance: variableOhSpendingVariance,
    variableOhEfficiencyVariance: variableOhEfficiencyVariance,
    fixedOhBudgetVariance: fixedOhBudgetVariance,
    fixedOhVolumeVariance: fixedOhVolumeVariance,
    classify: classify,
    computeAll: computeAll
  };

  if (typeof module !== 'undefined' && module.exports) { module.exports = api; }
  else { root.VarianceEngine = api; }
})(typeof window !== 'undefined' ? window : this);
```

- [ ] **Step 2: Run the tests to verify they pass**

Run: `node --test tests/*.test.js`
Expected: PASS — `pass 10`, `fail 0`.

- [ ] **Step 3: Commit**

```bash
git add assets/cost-variance-engine.js
git commit -m "feat: standard-costing variance engine (8 core variances + reconciliation)"
```

## Task 3: Free browser demo page

**Files:**
- Create: `cost-standard-costing.html`

- [ ] **Step 1: Write the page**

Create `cost-standard-costing.html` with exactly this content:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
  <meta name="theme-color" content="#1e3a5f" />
  <meta name="description" content="Free standard-costing variance calculator: material, labor, and overhead variances with a live variance bridge. By an in-seat FP&A leader." />
  <link rel="canonical" href="https://keystonemarcy.pages.dev/cost-standard-costing.html" />
  <title>Standard Costing Variance Calculator — KM Consulting</title>
  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'%3E%3Ccircle cx='32' cy='32' r='28' fill='%231e3a5f'/%3E%3C/svg%3E" />
  <style>
    :root{
      --navy:#1e3a5f; --slate:#2c5282; --ink:#1a202c; --muted:#5a6678;
      --line:#e2e8f0; --bg:#f7f9fc; --card:#ffffff;
      --fav:#15803d; --fav-bg:#dcfce7; --unfav:#b91c1c; --unfav-bg:#fee2e2;
      --r:12px; --shadow:0 1px 3px rgba(16,24,40,.06),0 8px 24px rgba(16,24,40,.06);
    }
    *{box-sizing:border-box}
    body{margin:0;font-family:Inter,-apple-system,"Segoe UI",system-ui,sans-serif;color:var(--ink);background:var(--bg);line-height:1.5}
    a{color:var(--slate)}
    .bar{display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:1rem 1.25rem;background:var(--card);border-bottom:1px solid var(--line)}
    .brand{display:flex;align-items:center;gap:.5rem;font-weight:700;color:var(--navy);text-decoration:none}
    .brand-orb{width:14px;height:14px;border-radius:50%;background:linear-gradient(135deg,var(--navy),var(--slate))}
    .wrap{max-width:1080px;margin:0 auto;padding:1.5rem 1.25rem 4rem}
    h1{font-size:1.8rem;margin:.2rem 0 .3rem;color:var(--navy)}
    .lede{color:var(--muted);margin:0 0 1.5rem;max-width:60ch}
    .grid{display:grid;grid-template-columns:minmax(300px,380px) 1fr;gap:1.5rem;align-items:start}
    @media(max-width:820px){.grid{grid-template-columns:1fr}}
    .panel{background:var(--card);border:1px solid var(--line);border-radius:var(--r);box-shadow:var(--shadow);padding:1.25rem}
    .panel h2{font-size:1.05rem;margin:.1rem 0 1rem;color:var(--navy)}
    fieldset{border:1px solid var(--line);border-radius:10px;padding:.75rem .9rem 1rem;margin:0 0 1rem}
    legend{font-weight:600;font-size:.85rem;color:var(--slate);padding:0 .4rem}
    .row{display:flex;gap:.75rem}
    .row .field{flex:1}
    .field{margin:.55rem 0}
    .field label{display:block;font-size:.78rem;color:var(--muted);margin-bottom:.25rem}
    .field input{width:100%;padding:.5rem .6rem;border:1px solid var(--line);border-radius:8px;font:inherit;background:#fff}
    .field input:focus{outline:none;border-color:var(--slate);box-shadow:0 0 0 3px rgba(44,82,130,.15)}
    .actions{display:flex;gap:.6rem;margin-top:.4rem}
    .btn{display:inline-flex;align-items:center;gap:.4rem;border:none;border-radius:9px;padding:.6rem 1rem;font:inherit;font-weight:600;cursor:pointer;text-decoration:none}
    .btn-primary{background:var(--navy);color:#fff}
    .btn-ghost{background:#fff;color:var(--slate);border:1px solid var(--line)}
    .totals{display:grid;grid-template-columns:repeat(3,1fr);gap:.75rem;margin-bottom:1.25rem}
    .stat{background:var(--bg);border:1px solid var(--line);border-radius:10px;padding:.8rem}
    .stat .k{font-size:.72rem;color:var(--muted);text-transform:uppercase;letter-spacing:.03em}
    .stat .v{font-size:1.25rem;font-weight:700;color:var(--navy);margin-top:.2rem}
    .bridge{margin:0 0 1.25rem}
    .step{display:grid;grid-template-columns:160px 1fr 92px;align-items:center;gap:.6rem;padding:.3rem 0}
    .step .name{font-size:.85rem;color:var(--ink)}
    .step .track{height:18px;background:#eef2f7;border-radius:5px;position:relative;overflow:hidden}
    .step .fill{position:absolute;top:0;bottom:0;border-radius:5px}
    .step .fill.u{background:var(--unfav)}
    .step .fill.f{background:var(--fav)}
    .step .amt{text-align:right;font-variant-numeric:tabular-nums;font-weight:600;font-size:.85rem}
    .amt.u{color:var(--unfav)} .amt.f{color:var(--fav)}
    .tag{display:inline-block;font-size:.68rem;font-weight:700;padding:.05rem .35rem;border-radius:4px;margin-left:.35rem}
    .tag.u{background:var(--unfav-bg);color:var(--unfav)} .tag.f{background:var(--fav-bg);color:var(--fav)}
    .readout{border-top:1px solid var(--line);padding-top:1rem}
    .readout li{margin:.4rem 0;font-size:.9rem;color:var(--ink)}
    .upsell{margin-top:1.5rem;background:linear-gradient(135deg,var(--navy),var(--slate));color:#fff;border-radius:var(--r);padding:1.4rem}
    .upsell h2{color:#fff;margin:.1rem 0 .4rem}
    .upsell p{margin:.2rem 0 1rem;opacity:.92;max-width:60ch}
    .upsell .btn-primary{background:#fff;color:var(--navy)}
    .upsell ul{margin:.4rem 0 1rem;padding-left:1.1rem;opacity:.95;font-size:.9rem}
    .foot{max-width:1080px;margin:0 auto;padding:1.5rem 1.25rem;color:var(--muted);font-size:.85rem;border-top:1px solid var(--line)}
    .note{font-size:.78rem;color:var(--muted);margin-top:.6rem}
  </style>
</head>
<body>
  <div class="bar">
    <a class="brand" href="templates.html"><span class="brand-orb"></span> KM Consulting</a>
    <a href="templates.html">&larr; All templates</a>
  </div>

  <main class="wrap">
    <h1>Standard Costing Variance Calculator</h1>
    <p class="lede">Enter your standards and actuals. See exactly where cost went off-plan — material, labor, and overhead — with a live variance bridge from standard to actual cost. Runs entirely in your browser; nothing is uploaded.</p>

    <div class="grid">
      <form class="panel" id="vform" autocomplete="off">
        <h2>Inputs</h2>
        <fieldset>
          <legend>Direct material</legend>
          <div class="row">
            <div class="field"><label for="standardPrice">Std price / unit ($)</label><input id="standardPrice" type="number" step="any" value="5.00" /></div>
            <div class="field"><label for="actualPrice">Actual price / unit ($)</label><input id="actualPrice" type="number" step="any" value="5.20" /></div>
          </div>
          <div class="row">
            <div class="field"><label for="standardQty">Std quantity</label><input id="standardQty" type="number" step="any" value="3000" /></div>
            <div class="field"><label for="actualQty">Actual quantity</label><input id="actualQty" type="number" step="any" value="3200" /></div>
          </div>
        </fieldset>
        <fieldset>
          <legend>Direct labor</legend>
          <div class="row">
            <div class="field"><label for="standardRate">Std rate / hr ($)</label><input id="standardRate" type="number" step="any" value="20.00" /></div>
            <div class="field"><label for="actualRate">Actual rate / hr ($)</label><input id="actualRate" type="number" step="any" value="19.50" /></div>
          </div>
          <div class="row">
            <div class="field"><label for="standardHours">Std hours</label><input id="standardHours" type="number" step="any" value="2000" /></div>
            <div class="field"><label for="actualHours">Actual hours</label><input id="actualHours" type="number" step="any" value="2100" /></div>
          </div>
        </fieldset>
        <fieldset>
          <legend>Overhead (activity base = labor hours)</legend>
          <div class="row">
            <div class="field"><label for="standardVarRate">Std variable OH rate / hr ($)</label><input id="standardVarRate" type="number" step="any" value="4.00" /></div>
            <div class="field"><label for="actualVOH">Actual variable OH ($)</label><input id="actualVOH" type="number" step="any" value="8600" /></div>
          </div>
          <div class="row">
            <div class="field"><label for="budgetedFOH">Budgeted fixed OH ($)</label><input id="budgetedFOH" type="number" step="any" value="11000" /></div>
            <div class="field"><label for="actualFOH">Actual fixed OH ($)</label><input id="actualFOH" type="number" step="any" value="11300" /></div>
          </div>
          <div class="field"><label for="standardFixedRate">Std fixed OH rate / hr ($)</label><input id="standardFixedRate" type="number" step="any" value="5.00" /></div>
        </fieldset>
        <div class="actions">
          <button type="button" class="btn btn-ghost" id="resetBtn">Reset to example</button>
        </div>
        <p class="note">Sign convention: <strong>U</strong> = unfavorable (cost above standard), <strong>F</strong> = favorable. Fixed overhead uses absorption costing.</p>
      </form>

      <section class="panel" aria-live="polite">
        <h2>Results</h2>
        <div class="totals">
          <div class="stat"><div class="k">Standard cost</div><div class="v" id="tStd">—</div></div>
          <div class="stat"><div class="k">Actual cost</div><div class="v" id="tAct">—</div></div>
          <div class="stat"><div class="k">Total variance</div><div class="v" id="tVar">—</div></div>
        </div>
        <div class="bridge" id="bridge"></div>
        <ul class="readout" id="readout"></ul>
      </section>
    </div>

    <section class="upsell">
      <h2>Get the full multi-product Excel model — $129</h2>
      <p>This calculator covers one product and the core variances. The paid workbook scales it to your whole operation:</p>
      <ul>
        <li>Unlimited products &amp; multiple material inputs</li>
        <li>Material <strong>mix &amp; yield</strong> and labor <strong>mix</strong> variances</li>
        <li>Sales price, volume &amp; mix variances</li>
        <li>Full budgeted &rarr; actual <strong>operating-profit bridge</strong> dashboard</li>
        <li>Pre-filled worked example + read-me; Excel 2016+</li>
      </ul>
      <a class="btn btn-primary" href="templates.html#buy-standard-costing">Get the Excel model &rarr;</a>
    </section>
  </main>

  <footer class="foot">© 2026 KM Consulting · built by Keystone Marcy — FP&amp;A &amp; Strategic Finance Leader</footer>

  <script src="assets/cost-variance-engine.js"></script>
  <script>
    (function () {
      var FIELDS = ['standardPrice','actualPrice','standardQty','actualQty',
        'standardRate','actualRate','standardHours','actualHours',
        'standardVarRate','actualVOH','budgetedFOH','actualFOH','standardFixedRate'];
      var DEFAULTS = {standardPrice:5,actualPrice:5.2,standardQty:3000,actualQty:3200,
        standardRate:20,actualRate:19.5,standardHours:2000,actualHours:2100,
        standardVarRate:4,actualVOH:8600,budgetedFOH:11000,actualFOH:11300,standardFixedRate:5};

      var usd = function (n) {
        return (n < 0 ? '-$' : '$') + Math.abs(n).toLocaleString('en-US', {minimumFractionDigits: 0, maximumFractionDigits: 0});
      };
      function readInputs() {
        var o = {};
        FIELDS.forEach(function (id) { o[id] = parseFloat(document.getElementById(id).value) || 0; });
        return o;
      }

      var BRIDGE = [
        ['Material price', function (r) { return r.material.price; }],
        ['Material quantity', function (r) { return r.material.quantity; }],
        ['Labor rate', function (r) { return r.labor.rate; }],
        ['Labor efficiency', function (r) { return r.labor.efficiency; }],
        ['Variable OH spending', function (r) { return r.varOH.spending; }],
        ['Variable OH efficiency', function (r) { return r.varOH.efficiency; }],
        ['Fixed OH budget', function (r) { return r.fixedOH.budget; }],
        ['Fixed OH volume', function (r) { return r.fixedOH.volume; }]
      ];

      function render() {
        var r = VarianceEngine.computeAll(readInputs());
        document.getElementById('tStd').textContent = usd(r.totals.standardCost);
        document.getElementById('tAct').textContent = usd(r.totals.actualCost);
        var totV = r.totals.totalVariance, tc = VarianceEngine.classify(totV);
        var tVarEl = document.getElementById('tVar');
        tVarEl.textContent = usd(Math.abs(totV)) + ' ' + tc.label;
        tVarEl.style.color = tc.favorable === false ? 'var(--unfav)' : (tc.favorable ? 'var(--fav)' : 'var(--navy)');

        var rows = BRIDGE.map(function (b) { return [b[0], b[1](r)]; });
        var max = Math.max.apply(null, rows.map(function (x) { return Math.abs(x[1]); }).concat([1]));
        var bridge = document.getElementById('bridge');
        bridge.innerHTML = '';
        rows.forEach(function (row) {
          var amt = row[1], c = VarianceEngine.classify(amt), cls = c.favorable === false ? 'u' : (c.favorable ? 'f' : '');
          var w = Math.round(Math.abs(amt) / max * 100);
          var div = document.createElement('div');
          div.className = 'step';
          div.innerHTML = '<span class="name">' + row[0] + '</span>' +
            '<span class="track"><span class="fill ' + cls + '" style="width:' + w + '%"></span></span>' +
            '<span class="amt ' + cls + '">' + usd(Math.abs(amt)) + ' ' + c.label + '</span>';
          bridge.appendChild(div);
        });

        var readout = document.getElementById('readout');
        readout.innerHTML = '';
        var items = explain(r);
        items.forEach(function (txt) {
          var li = document.createElement('li');
          li.innerHTML = txt;
          readout.appendChild(li);
        });
      }

      function tag(amt) {
        var c = VarianceEngine.classify(amt);
        if (c.favorable === null) return '<span class="tag">flat</span>';
        return '<span class="tag ' + (c.favorable ? 'f' : 'u') + '">' + (c.favorable ? 'Favorable' : 'Unfavorable') + '</span>';
      }
      function explain(r) {
        var out = [];
        out.push('Materials ' + tag(r.material.total) + ' — price vs. usage drove ' + dollars(r.material.total) + ' against standard.');
        out.push('Labor ' + tag(r.labor.total) + ' — rate vs. efficiency netted ' + dollars(r.labor.total) + '.');
        out.push('Variable overhead ' + tag(r.varOH.total) + ' — spending plus efficiency totaled ' + dollars(r.varOH.total) + '.');
        out.push('Fixed overhead ' + tag(r.fixedOH.total) + ' — budget plus volume totaled ' + dollars(r.fixedOH.total) + '.');
        return out;
      }
      function dollars(n) {
        var c = VarianceEngine.classify(n);
        return '<strong>' + (n < 0 ? '-$' : '$') + Math.abs(n).toLocaleString('en-US', {maximumFractionDigits: 0}) + ' ' + c.label + '</strong>';
      }

      document.getElementById('vform').addEventListener('input', render);
      document.getElementById('resetBtn').addEventListener('click', function () {
        FIELDS.forEach(function (id) { document.getElementById(id).value = DEFAULTS[id]; });
        render();
      });
      render();
    })();
  </script>
</body>
</html>
```

- [ ] **Step 2: Verify the page renders and computes**

Run: `node --eval "const VE=require('./assets/cost-variance-engine.js');const r=VE.computeAll({standardPrice:5,actualPrice:5.2,standardQty:3000,actualQty:3200,standardRate:20,actualRate:19.5,standardHours:2000,actualHours:2100,standardVarRate:4,actualVOH:8600,budgetedFOH:11000,actualFOH:11300,standardFixedRate:5});console.log(r.totals, r.reconciles);"`
Expected: `{ standardCost: 73000, actualCost: 77490, totalVariance: 4490 } true`

(This confirms the page's default inputs reconcile via the same engine the page loads.)

- [ ] **Step 3: Commit**

```bash
git add cost-standard-costing.html
git commit -m "feat: free standard-costing variance calculator demo page"
```

## Task 4: Manual browser smoke test

**Files:** none (verification only)

- [ ] **Step 1: Open the page in a real browser**

Run: `start "" "C:\Users\keyst\Business-Landing-Page\cost-standard-costing.html"` (PowerShell)

- [ ] **Step 2: Verify by observation**

Confirm:
- Totals show **Standard $73,000 / Actual $77,490 / Total variance $4,490 U**.
- The bridge shows 8 rows; Labor rate renders green/F, the rest red/U.
- Editing any input recomputes live.
- "Reset to example" restores defaults.
- Narrow the window to mobile width — the two-column grid collapses to one column.

If any check fails, STOP and use `superpowers:systematic-debugging` before proceeding.

## Task 5: Paid `.xlsx` — author via `shortcut` CLI

**Files:**
- Create (via `shortcut` ONLY): `downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx`

> Excel files are hook-locked to the `shortcut` CLI. Do NOT use Write/Edit/Read on the `.xlsx`. `shortcut` v0.3.56 is installed; `ANTHROPIC_API_KEY` is set, so use `--provider anthropic`. If `shortcut` reports no provider/key, STOP and tell the user.

- [ ] **Step 1: Build the workbook**

Run (PowerShell, from repo root — single command):

```powershell
shortcut -p @'
Build a professional Standard Costing & Variance Analysis Excel workbook for an FP&A audience. Formula-only (NO macros). Excel 2016+ compatible. Use named ranges for inputs, data validation on input cells, and visually distinguish input cells (light-blue fill) from calculated cells (white/locked). Protect the Calc and Dashboard sheets (no password). Sheets in this order:

1) "Read Me": purpose, how to use, sign convention (Unfavorable = actual cost above standard; Favorable = below), assumptions (fixed OH uses absorption costing; overhead activity base = labor hours), version v1.0, and a note that Google Sheets users should re-check any AVERAGEIFS/structured formulas.

2) "Inputs": a products table (supports many products, one row each) with standard price/unit, standard qty, standard labor rate, standard labor hours, standard variable OH rate/hr, budgeted fixed OH, standard fixed OH rate/hr, budgeted selling price, budgeted units, budgeted standard mix %. Support multiple material inputs per product on a second linked table (material name, std price, std qty, actual price, actual qty) so material MIX and YIELD can be computed.

3) "Actuals": actual price/qty, actual labor rate/hours, actual variable OH, actual fixed OH, actual selling price, actual units per product.

4) "Calc": compute per product and in total — material price, quantity, MIX, YIELD; labor rate, efficiency, MIX; variable OH spending & efficiency; fixed OH budget & volume; sales price, volume & mix variances. Each variance signed so positive = Unfavorable. Sub-totals per family and grand totals.

5) "Dashboard": a budgeted-operating-profit -> actual-operating-profit bridge (waterfall) plus a KPI table listing each variance amount, F/U flag, and % of standard. Include a cost-side reconciliation block: Standard cost, Actual cost, Total cost variance.

6) "Example": pre-fill with this exact two-product, single-material-input worked example so totals can be verified:
   Product A: std price 5.00, std qty 3000, actual price 5.20, actual qty 3200; std labor rate 20.00, std hours 2000, actual rate 19.50, actual hours 2100; std var OH rate 4.00, actual var OH 8600; budgeted fixed OH 11000, std fixed OH rate 5.00, actual fixed OH 11300.
   Product B: std price 8.00, std qty 1000, actual price 7.80, actual qty 1050; std labor rate 25.00, std hours 750, actual rate 25.40, actual hours 720; std var OH rate 6.00, actual var OH 4700; budgeted fixed OH 6000, std fixed OH rate 8.00, actual fixed OH 5900.
   With these inputs the cost-side grand totals MUST be: Standard cost 110250, Actual cost 114568, Total cost variance 4318 Unfavorable. Make the Example tab show these three grand totals prominently so they can be checked.
'@ @"downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx" --skip-spreadsheet-permissions --provider anthropic
```

Expected: `shortcut` reports the workbook was written to `downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx`.

- [ ] **Step 2: Confirm the file exists**

Run: `Get-Item "downloads\KM-Consulting_Standard-Costing-Variance_v1.0.xlsx" | Select-Object Name,Length`
Expected: a non-zero file size.

- [ ] **Step 3: Commit**

```bash
git add downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx
git commit -m "feat: paid standard-costing multi-product Excel model (built via shortcut)"
```

## Task 6: Verify the `.xlsx` ties out

**Files:** none (verification only — must go through `shortcut`)

- [ ] **Step 1: Ask `shortcut` to read back the Example grand totals**

Run (PowerShell):

```powershell
shortcut -p "Open the Example sheet and report exactly three numbers from its grand-total reconciliation block: Standard cost, Actual cost, and Total cost variance (with its F/U flag). Output only those three labeled values." @"downloads/KM-Consulting_Standard-Costing-Variance_v1.0.xlsx" --skip-spreadsheet-permissions --provider anthropic
```

Expected output values: **Standard cost = 110,250 · Actual cost = 114,568 · Total cost variance = 4,318 Unfavorable.**

- [ ] **Step 2: Decide**

If the three numbers match, the cost-side engine ties out — proceed. (Sales variances and the profit bridge are eyeballed in the Dashboard; the automated tie-out covers the cost reconciliation, the most error-prone part.)

If they do NOT match, re-run Task 5 Step 1 with a corrective note to `shortcut` describing the specific cell(s) that were wrong, then repeat this task. Use `superpowers:systematic-debugging` if it fails twice.

## Task 7: Surface both products on `templates.html`

**Files:**
- Modify: `templates.html` (insert two cards after the existing Card 3 block, before the closing `</div>` of `.bento`)
- Modify: `sitemap.xml`

- [ ] **Step 1: Add the two cards**

In `templates.html`, immediately AFTER the Card 3 closing `</div>` (the ASC 606 card) and BEFORE `      </div>\n    </section>`, insert:

```html
        <!-- Card 4: Free interactive tool — standard costing -->
        <div class="bento-card wide reveal" style="transition-delay: 180ms">
          <p class="card-label">Free · Interactive tool</p>
          <h3 class="card-title">Standard Costing Variance Calculator</h3>
          <div class="shot">
            <div class="shot-bar" aria-hidden="true">
              <span class="shot-dots"><i></i><i></i><i></i></span>
              <span class="shot-url">standard costing · variance bridge</span>
            </div>
            <img class="card-image" src="images/templates/standard-costing-cover.webp" alt="Standard costing variance calculator with a variance bridge" loading="lazy" width="1440" height="900" />
          </div>
          <p class="card-desc">
            Enter standards and actuals; see material, labor, and overhead variances and a live bridge from standard to actual cost — each split into price/rate and quantity/efficiency, flagged favorable or unfavorable. Runs entirely in your browser.
          </p>
          <p>
            <a class="btn btn-primary" href="cost-standard-costing.html" data-cta="templates_launch_stdcost">Launch the tool <span class="btn-arrow" aria-hidden="true">&rarr;</span></a>
          </p>
        </div>

        <!-- Card 5: Paid — standard costing full model -->
        <div class="bento-card wide reveal" id="buy-standard-costing" style="transition-delay: 240ms">
          <p class="card-label">$129 · Premium</p>
          <h3 class="card-title">Standard Costing &amp; Variance — Full Multi-Product Model</h3>
          <p class="card-desc">
            The complete workbook: unlimited products and material inputs; material mix &amp; yield, labor mix, and sales price/volume/mix variances; and a budgeted&rarr;actual operating-profit bridge. Built for Excel 2016+.
          </p>
          <form name="buy_stdcost" action="https://api.web3forms.com/submit" method="POST" class="contact-form buy-form">
            <input type="hidden" name="access_key" value="457f9dc9-76ba-4c91-b515-fdb1ffba7243" />
            <input type="hidden" name="subject" value="Purchase request — Standard Costing Full Model ($129)" />
            <input type="hidden" name="from_name" value="KM Consulting Templates" />
            <input type="hidden" name="cc" value="kmarcy@KMConsulting995.onmicrosoft.com" />
            <input type="checkbox" name="botcheck" class="hidden-field" style="display:none" tabindex="-1" autocomplete="off" aria-hidden="true" />
            <div class="field">
              <label for="buy-stdcost-email">Email</label>
              <input id="buy-stdcost-email" type="email" name="email" autocomplete="email" placeholder="you@company.com" required />
            </div>
            <button type="submit" class="btn btn-primary" data-cta="templates_get_stdcost">Request to buy — $129 <span class="btn-arrow" aria-hidden="true">&rarr;</span></button>
          </form>
          <p class="card-fineprint" style="font-size:.85rem;color:var(--text-muted);margin-top:.6rem;">I'll email you a secure payment link and the file within 1 business day. Excel 2016+.</p>
        </div>
```

- [ ] **Step 2: Wire the new buy form into the page's JS**

In the `<script>` IIFE of `templates.html`, find the block that handles `form[name="buy13week"]`. Immediately after that closing `}` (the `if (buyFormEl) { ... }` block), add a generalized handler so the new form posts the same way:

```javascript
      /* ===== Standard Costing purchase inquiry (Web3Forms) ===== */
      var buyStdEl = document.querySelector('form[name="buy_stdcost"]');
      if (buyStdEl) {
        buyStdEl.addEventListener('submit', function (e) {
          e.preventDefault();
          track('generate_lead', { method: 'buy_stdcost_form' });
          var btn = buyStdEl.querySelector('button[type="submit"]');
          var btnKids = btn ? Array.prototype.slice.call(btn.childNodes) : null;
          function resetBtn() { if (btn) { btn.disabled = false; btn.replaceChildren.apply(btn, btnKids); } }
          function showError(text) {
            var old = buyStdEl.querySelector('.form-status');
            if (old) old.remove();
            var msg = document.createElement('p');
            msg.className = 'form-status form-status--err';
            msg.setAttribute('role', 'alert');
            msg.textContent = text;
            buyStdEl.appendChild(msg);
            resetBtn();
          }
          if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
          fetch('https://api.web3forms.com/submit', { method: 'POST', body: new FormData(buyStdEl) })
            .then(function (r) { return r.json(); })
            .then(function (data) {
              if (data.success) {
                var msg = document.createElement('p');
                msg.className = 'form-status form-status--ok';
                msg.setAttribute('role', 'status');
                msg.textContent = "Got it — I'll email your payment link and the file within 1 business day.";
                buyStdEl.replaceChildren(msg);
              } else {
                showError('Something went wrong. Please email kmarcy@KMConsulting995.onmicrosoft.com instead.');
              }
            })
            .catch(function () {
              showError('Network error. Please email kmarcy@KMConsulting995.onmicrosoft.com instead.');
            });
        });
      }
```

- [ ] **Step 3: Add the demo page to `sitemap.xml`**

In `sitemap.xml`, copy the existing `<url>` block used for `templates.html` and add an equivalent entry for `cost-standard-costing.html`:

```xml
  <url>
    <loc>https://keystonemarcy.pages.dev/cost-standard-costing.html</loc>
    <changefreq>monthly</changefreq>
    <priority>0.7</priority>
  </url>
```

(Match the exact host and child tags already used by the other `<url>` entries in the file; if they use `<lastmod>`, include today's date `2026-06-03`.)

- [ ] **Step 4: Verify links and forms**

Run: `start "" "C:\Users\keyst\Business-Landing-Page\templates.html"` (PowerShell)
Confirm: Cards 4 and 5 appear; "Launch the tool" opens the calculator; the upsell button on the calculator (`templates.html#buy-standard-costing`) scrolls to Card 5.

- [ ] **Step 5: Commit**

```bash
git add templates.html sitemap.xml
git commit -m "feat: add standard-costing free tool + paid model cards to templates catalog"
```

## Task 8: Card cover image

**Files:**
- Create: `images/templates/standard-costing-cover.webp`

- [ ] **Step 1: Screenshot the demo with headless Chrome**

Run (PowerShell — adjust the Chrome path if needed):

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --headless=new --disable-gpu --window-size=1440,900 --screenshot="C:\tmp\standard-costing-cover.png" "file:///C:/Users/keyst/Business-Landing-Page/cost-standard-costing.html"
```

Expected: `C:\tmp\standard-costing-cover.png` is created.

- [ ] **Step 2: Convert to WebP with sharp**

Run (PowerShell, from `C:\tmp` where `sharp` is installed):

```powershell
node -e "require('sharp')('C:/tmp/standard-costing-cover.png').resize(1440,900,{fit:'cover',position:'top'}).webp({quality:82}).toFile('C:/Users/keyst/Business-Landing-Page/images/templates/standard-costing-cover.webp').then(()=>console.log('ok'))"
```

Expected: prints `ok`; `images/templates/standard-costing-cover.webp` exists.

- [ ] **Step 3: Commit**

```bash
git add images/templates/standard-costing-cover.webp
git commit -m "chore: add standard-costing card cover image (webp)"
```

---

## Final verification

- [ ] `node --test tests/*.test.js` → all engine tests pass.
- [ ] Demo page totals = Standard $73,000 / Actual $77,490 / Total $4,490 U; bridge + reset + mobile all work (Task 4).
- [ ] `.xlsx` Example grand totals tie out: Standard 110,250 / Actual 114,568 / Variance 4,318 U (Task 6).
- [ ] `templates.html` shows both new cards; calculator launches; upsell anchors to the paid card; cover image renders.
- [ ] `sitemap.xml` includes the demo page.

## Deployment note (do NOT run unless the user asks)

This repo deploys via `git push origin main` (GitHub Pages auto-builds). The `downloads/` folder has historically been untracked — confirm the new `.xlsx` is committed (Task 5 Step 3) so the paid file does not 404 on Pages. Per project rules, only push when the user asks.

## Out of scope (this plan)

- Suite tools 2–4 (Job-Order, ABC, Inventory Valuation) — each gets its own spec/plan later, reusing these conventions.
- Macros/VBA; payment automation; GA4/Clarity IDs.
