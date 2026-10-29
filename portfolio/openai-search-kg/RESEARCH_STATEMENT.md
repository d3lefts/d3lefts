# Research statement — Search / Knowledge Graphs

I direct NIGHTFALL, a human-led research collaboration that uses AI-assisted implementation and adversarial review to make research claims reproducible. The recurring technical question is how to represent information so that a system can recover the original evidence, expose missing assumptions, and correct itself when a source changes.

The most relevant implementation is **SourceBound**, a source-grounded assertion-admission system. It separates extraction from acceptance and tracks candidate subject–relation–object assertions alongside source revisions, evidence spans, DOM locations, identity constraints and temporal qualifiers. Its bug-fixed public release includes 27 unit tests and a 14,000-page synthetic fixture replay with 6,000 retained fixture assertions. Those tests demonstrate bounded source-consistency behavior; they do not demonstrate independent natural-web extraction accuracy or production scale.

A second research line, **Proof After Scarcity**, models how bibliographic links differ from logical dependencies in evidence graphs. Its retrospective prioritization experiment performed *worse* than simpler baselines (8/20 versus 11/20). Publishing that negative result reflects the standard I want a knowledge system to enforce: evidence and falsification must constrain the claim, even when the results are unfavorable.

I have also assembled a small runnable retrieval interface over six canonical, manually curated claims. It returns verbatim scope statements, primary citations, typed evidence edges and explicit abstentions when no matching record exists. The code and negative-control tests are public. The demonstration is a transparent systems component, not a surrogate benchmark for agentic search.

The Foundations Search knowledge-graphs role is particularly interesting because it joins three problems I have been working toward: extracting structure from inconsistent sources, choosing representations that models can use, and evaluating whether those representations improve grounded reasoning. The next experiment I would prioritize is a frozen, domain-held-out SourceBound evaluation at matched recall, followed by downstream question-answering/retrieval comparisons with latency, abstention and cost reported. I would rather publish a clear negative result than promote a claim beyond its evidence.

**Work sample:** https://d3lefts.github.io/d3lefts/portfolio.html  
**Code and research evidence:** https://github.com/d3lefts/d3lefts

*Scope: research work sample and personal research direction. No claim of prior OpenAI employment, independent human refereeing, production web-scale deployment, or a measured positive retrieval lift.*
