# The Unwritten Semester — Systems Engineering at the Research Frontier

A free, independent, self-guided **doctoral-level laboratory course** for the methods, artifacts, and judgment often learned informally during a PhD, EngD, or research-intensive systems engineering degree.

Inspired by the educational format of [MIT's Missing Semester](https://missing.csail.mit.edu/), but independently written. **Not an MIT program, a university degree, or a credential.**

## Open the site

Open `index.html` in a browser, or serve the directory (recommended):

```bash
python3 -m http.server 8000
# then visit http://localhost:8000
```

Works on GitHub Pages without a build step, dependencies, cookies, external scripts, or a backend. Lesson completion is saved **locally in your browser only**.

## Course model

- 14 teaching sessions in four phases: Frame, Model, Verify, Transfer.
- Each session has narrative notes, an operational method, an exercise, an adversarial check, a research extension, and an acceptance artifact.
- One synthetic capstone: **AURORA**, a remote environmental sensing system with a reproducible standard-library Python simulator.
- A two-role defense: a construction team and an independently specified audit team. The audit is not automatically independent just because the code is different.
- Separate standards resources, reusable templates, and a capstone rubric.

Suggested cadence: 14 sessions (90 minutes teaching + 2–4 hours lab each), then 10–20 hours for a capstone. Equivalent to a short workshop or elective supplement, not a doctoral program.

## Execute the lab

```bash
python3 labs/aurora.py --seed 2026 --trials 5000 --policy quorum --out labs/output.csv
python3 labs/audit.py labs/output.csv
python3 -m unittest discover -s labs -p 'test_*.py' -v
```

The simulator is synthetic and illustrative. Its conclusions do not establish field reliability, domain fitness, or real-world safety.

## Publish

Put this folder at a GitHub Pages site root, or copy its contents into a subfolder; all internal navigation uses relative paths. If the site is mounted under a subpath, no configuration is needed.

## License and references

Original course prose and site code: CC BY 4.0 / MIT license respectively (see `LICENSE.md`). Primary source references are linked from `resources.html`. External references retain their own licenses. This package does not reproduce MIT lecture material.

## Version 1.1 — executable doctoral toolchain

The [research toolkit](TOOLKIT.md) adds four executable field practicums: paired decisions, a 27-state exhaustive policy check, SHA-256 byte manifests and declared dependency impact, and negative-test defense. The [quantitative bridge](MATH_BRIDGE.md) adds exact micro-exercises spanning probability, dynamic observability, robust control, decision theory, causal inference, and formal methods. **These are extensions, not complete PhD coursework.**

```bash
python3 labs/aurora.py --policy any --seed 2026 --trials 5000 --out labs/any.csv
python3 labs/aurora.py --policy quorum --seed 2026 --trials 5000 --out labs/quorum.csv
python3 labs/compare.py labs/any.csv labs/quorum.csv --bootstrap 800
python3 labs/modelcheck.py
python3 labs/exact_switch.py labs/any.csv labs/quorum.csv
python3 labs/passport.py create --root . --claim 'Synthetic trace arithmetic only' --out evidence/passport.json labs/aurora.py labs/audit.py labs/modelcheck.py labs/output.csv README.md TOOLKIT.md MATH_BRIDGE.md build.py assets/site.css labs/compare.py labs/exact_switch.py labs/passport.py labs/any.csv labs/quorum.csv evidence/dependency-graph.json
python3 labs/passport.py verify --root . --manifest evidence/passport.json --graph evidence/dependency-graph.json
python3 -m unittest discover -s labs -p 'test_*.py' -v
python3 scripts/check_site.py
python3 scripts/verify_reference.py
```

A reusable standalone-repository GitHub Actions workflow is included in `.github/workflows/course-checks.yml`. It has not been run on GitHub in this session. To regenerate HTML, install the **build-only** dependency with `python3 -m pip install -r requirements-build.txt`, then run `python3 build.py`. Visitors need no external packages. A test pass does not confer formal or field certification. See `CHANGELOG.md` for verified and unverified gates.
