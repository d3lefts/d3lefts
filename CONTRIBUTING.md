# NIGHTFALL contributing and release policy

Keep main as the published state. Every parallel AI instance should use a distinct topic branch, batch coherent changes, and open a pull request. Verify the pull request against fresh main before merging. Run the static gate, browser smoke, and the CI verify job. A failed gate needs a reproduced cause and a narrow repair.

Original findings require distinct primary artifacts, independently reproduced verification, and dated prior-art comparison. The Research Agenda contains ten explicitly untested proposals on a separate page. The originality whitelist remains exactly three entries unless a dated audit and human sign-off justify a change.

## GitHub administrator action

The documented branch policy cannot block direct pushes on its own. Enable Settings > Rules > Rulesets > New branch ruleset for main, require pull requests, require the Verify research website / verify check to pass, and restrict bypass if supported. Confirm the rule is active. GitHub Pages should deploy main /docs.

After a green merge, check the main workflow and Pages deployment. Cancelled superseded runs reflect rapid commits, not necessarily broken live pages.