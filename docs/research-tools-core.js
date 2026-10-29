/* NIGHTFALL Exact Research Tools — deterministic offline arithmetic, v1.
   Pure functions. No network, storage, evaluation of uploaded code, or claims of proof.
   UMD export for independent Node regression and browser UI. */
(function (root, factory) {
  const api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  else root.NIGHTFALL_EXACT = api;
})(typeof globalThis === "object" ? globalThis : this, function () {
  "use strict";
  function fail(message) { throw new Error(message); }
  function word(s) {
    if (typeof s !== "string" || !/^[012]{4}$/.test(s)) fail("Qutrit indices must be four ternary digits, e.g. 0121.");
    return s;
  }
  function coeff(x) {
    const s = String(x);
    if (!/^[+-]?\d{1,14}$/.test(s)) fail("Coefficients must be bounded signed integers (up to 14 digits).");
    return BigInt(s);
  }
  const gcd = (a, b) => {
    a = a < 0n ? -a : a; b = b < 0n ? -b : b;
    while (b) { const t = a % b; a = b; b = t; }
    return a;
  };
  function rankBounded(entries) {
    const rows = [...new Set(entries.map(x => x.row))].sort();
    const cols = [...new Set(entries.map(x => x.col))].sort();
    const pivots = [];
    const jmap = new Map(cols.map((x, i) => [x, i]));
    for (const row of rows) {
      let v = Array(cols.length).fill(0n);
      for (const x of entries) if (x.row === row) v[jmap.get(x.col)] = x.coeff;
      for (const p of pivots) {
        const f = v[p.index];
        if (f === 0n) continue;
        const factor = p.v[p.index];
        v = v.map((x, j) => x * factor - p.v[j] * f);
        let g = 0n;
        for (const z of v) if (z) g = gcd(g, z);
        if (g > 1n) v = v.map(z => z / g);
      }
      const index = v.findIndex(x => x !== 0n);
      if (index !== -1) {
        pivots.push({ index, v });
        pivots.sort((a,b)=>a.index-b.index); // eliminate in pivot-column order
        if (pivots.length >= 3) return { rank: "at least 3", rankAtMostTwo: false };
      }
    }
    return { rank: pivots.length, rankAtMostTwo: true };
  }
  function parseWerner(input) {
    const a = typeof input === "string" ? JSON.parse(input) : input;
    if (!Array.isArray(a) || a.length === 0 || a.length > 48) fail("Provide 1–48 sparse matrix entries as a JSON array.");
    const cells = new Map();
    for (const item of a) {
      if (item === null || typeof item !== "object") fail("Each entry is [row,col,integer] or {row,col,coeff}.");
      const row = word(Array.isArray(item) ? item[0] : item.row);
      const col = word(Array.isArray(item) ? item[1] : item.col);
      const z = coeff(Array.isArray(item) ? item[2] : item.coeff);
      const key = row + ":" + col;
      cells.set(key, (cells.get(key) || 0n) + z);
    }
    const entries = [];
    for (const [key, value] of cells) if (value !== 0n) {
      const [row, col] = key.split(":");
      entries.push({ row, col, coeff: value });
    }
    return entries;
  }
  function kernel16(a, b) {
    let n = 1n;
    for (let i = 0; i < 4; i++) {
      const direct = a.row[i] === b.row[i] && a.col[i] === b.col[i] ? 2 : 0;
      const trace = a.row[i] === a.col[i] && b.row[i] === b.col[i] ? 1 : 0;
      n *= BigInt(direct - trace);
    }
    return n;
  }
  function f3(x) { return ((x % 3) + 3) % 3; }
  function syndrome(s) {
    word(s);
    return [f3(Number(s[2]) - Number(s[0]) - Number(s[1])),
      f3(Number(s[3]) - Number(s[0]) - 2 * Number(s[1]))];
  }
  function grade(row, col) { return [...row].map((z, i) => f3(Number(z) - Number(col[i]))).join(""); }
  function werner(input) {
    const entries = parseWerner(input);
    const rank = rankBounded(entries);
    let q16 = 0n, norm = 0n;
    for (const a of entries) {
      norm += a.coeff * a.coeff;
      for (const b of entries) q16 += a.coeff * b.coeff * kernel16(a, b);
    }
    const g = gcd(q16, 16n);
    const denom = 16n / (g || 1n);
    const numer = q16 / (g || 1n);
    return {
      engine: "exact-four-qutrit-werner-v1",
      physicalModel: "K=(I-|Omega_3><Omega_3|/2)^tensor4; rational Q(C)=sum_J (-1/2)^|J| ||Tr_J C||_F^2",
      entries: entries.length, ...rank, q16: q16.toString(), qExact: numer.toString() + (denom === 1n ? "" : "/" + denom.toString()),
      squaredNorm: norm.toString(),
      scope: rank.rankAtMostTwo ? "Rank≤2 input: value is an exact physical quadratic-form evaluation; positivity of this input alone is not a theorem." : "Rank>2 input: outside the admissible Werner witness cone; negative values cannot refute rank-two positivity.",
      coordinates: entries.map(x => ({ row: x.row, col: x.col, coefficient: x.coeff.toString(),
        rowSyndrome: syndrome(x.row).join(""), columnSyndrome: syndrome(x.col).join(""), differenceGrade: grade(x.row, x.col) }))
    };
  }
  function mod5(n) { return ((n % 5) + 5) % 5; }
  function elt(x) {
    if (!Array.isArray(x) || x.length !== 2 || !x.every(v => Number.isInteger(v) && v >= 0 && v < 5)) fail("Each F25 element must be [a,b] with a,b in {0,1,2,3,4}.");
    return x;
  }
  const add = (x, y) => [mod5(x[0] + y[0]), mod5(x[1] + y[1])];
  const mul = (x, y) => [mod5(x[0] * y[0] + 2 * x[1] * y[1]), mod5(x[0] * y[1] + x[1] * y[0])];
  function power(x, n) {
    let z = [1, 0], y = x;
    for (let i = n; i > 0; i = Math.floor(i / 2)) { if (i % 2) z = mul(z, y); y = mul(y, y); }
    return z;
  }
  const all = Array.from({ length: 25 }, (_, n) => [n % 5, Math.floor(n / 5)]);
  const equal = (x, y) => x[0] === y[0] && x[1] === y[1];
  const fieldKey = x => x[0] + 5 * x[1];
  const signalKey = x => fieldKey(x[0]) + 25 * fieldKey(x[1]);
  function f25(input) {
    const obj = typeof input === "string" ? JSON.parse(input) : input;
    if (!obj || typeof obj !== "object" || !Array.isArray(obj.rows) || obj.rows.length < 1 || obj.rows.length > 20) fail("Provide 1–20 sensing rows.");
    const rows = obj.rows.map(row => {
      if (!Array.isArray(row) || row.length !== 2) fail("Every sensing row must contain exactly two F25 coefficients.");
      return row.map(elt);
    });
    if (!Array.isArray(obj.signal) || obj.signal.length !== 2) fail("The signal requires two F25 elements.");
    const signal = obj.signal.map(elt);
    function measure(x) {
      return rows.map(r => power(add(mul(r[0], x[0]), mul(r[1], x[1])), 4));
    }
    const observation = measure(signal), solutions = [];
    for (const x of all) for (const y of all) {
      const s = [x, y], data = measure(s);
      if (data.every((e, j) => equal(e, observation[j]))) solutions.push(s);
    }
    const mu4 = all.filter(a => equal(power(a, 4), [1, 0]));
    if (mu4.length !== 4) fail("F25 fourth-root symmetry check failed.");
    const orbits = new Map();
    for (const x of solutions) {
      const canonical = Math.min(...mu4.map(z => signalKey(x.map(a => mul(z, a)))));
      if (!orbits.has(canonical)) orbits.set(canonical, x);
    }
    return {
      engine: "exhaustive-f25-fourth-power-v1",
      field: "F5[u]/(u^2-2)", signal, rows: rows.length,
      observation, fieldSearchSpace: 625, phaseGroupSize: 4,
      preimages: solutions.length, phaseOrbits: orbits.size,
      identifiableUpToPhase: orbits.size === 1,
      representatives: [...orbits.values()].slice(0, 12),
      scope: "Complete finite enumeration for k=2 and this fixed sensing matrix, not a uniform or probabilistic recovery theorem."
    };
  }
  return Object.freeze({ werner, f25, kernel16, syndrome, grade, mul, add, power });
});
