---
name: review-doc
description: Reviews an LLM-generated document (system analysis, situation analysis, implementation plan) for accuracy, completeness, and overlooked issues.
user-invocable: true
disable-model-invocation: true
argument-hint: "<file-path> [focus]"
---

# Review Document

Critically review a document — typically produced by another LLM agent — and provide structured feedback on its accuracy, completeness, and reasoning quality.

## Arguments

- **file-path** (1st argument, required): Path to the document to review. Can be a single file or a directory containing related documents.
- **focus** (2nd argument, optional): A specific concern or area to pay extra attention to (e.g., "security implications", "feasibility of timeline", "database migration risks"). If omitted, performs a general review.

## Process

### 1. Read the Document

Read the target document(s) thoroughly. If a directory was provided, read all files within it and understand how they relate to each other.

### 2. Understand the Subject Matter

The document likely makes claims about a codebase, system, process, or situation. Before evaluating those claims, build your own understanding:

- If the document analyzes a codebase or technical system: read the actual source code, configs, and any other artifacts the document references. Do not take the document's descriptions at face value — verify them.
- If the document references external resources (URLs, tickets, APIs): attempt to access and read them for additional context.
- If the document proposes an implementation plan: read the parts of the codebase that would be affected to understand the real starting point.

### 3. Evaluate

Assess the document on the following dimensions. Not every dimension will apply to every document — focus on what matters for the specific document type.

#### Accuracy
- **Factual correctness**: Are descriptions of the current system, codebase, or situation accurate? Cross-check against the actual code and artifacts.
- **Mischaracterizations**: Does the document overstate or understate any issues? Does it describe behavior that doesn't match what the code actually does?
- **Stale information**: Does the document reference things that no longer exist or have changed since it was written?

#### Completeness
- **Blind spots**: Are there important aspects of the system, problem, or situation that the document fails to mention entirely?
- **Shallow coverage**: Are there areas that are mentioned but not explored deeply enough, where the shallow treatment could lead to bad decisions?
- **Missing stakeholders or dependencies**: Does the document overlook teams, systems, services, or constraints that would be affected?

#### Reasoning Quality
- **Logical gaps**: Does the document jump to conclusions without sufficient evidence or reasoning?
- **Unsupported assumptions**: Are there implicit assumptions that are never stated or validated?
- **Alternative perspectives**: Has the author considered other interpretations or approaches, or does it present only one view as if it were the only possibility?

#### Risks and Concerns
- **Unaddressed risks**: Are there risks (technical, organizational, security, performance) that the document should flag but doesn't?
- **Overly optimistic assessments**: Does the document downplay difficulty, complexity, or likelihood of failure?
- **Edge cases**: Are there scenarios or conditions that would break the proposed approach or invalidate the analysis?

#### Coherence
- **Internal consistency**: Does the document contradict itself anywhere?
- **Alignment with goals**: If the document states goals or objectives, do the proposed actions or conclusions actually serve those goals?
- **Prioritization**: If the document lists items, are they prioritized sensibly? Are low-impact items given disproportionate attention while high-impact ones are glossed over?

### 4. Produce the Review

Write your review as a direct response to the user (do not create a file). Structure it as follows:

#### Summary Verdict

A 1–3 sentence overall assessment. Is this document trustworthy and actionable as-is, does it need revisions, or does it have fundamental issues? Be direct.

#### Critical Issues

Problems that would lead to incorrect decisions or failed implementations if not addressed. Each issue should:
- State what is wrong or missing.
- Explain why it matters.
- Reference the specific section or claim in the document.
- Where possible, point to the actual code or evidence that contradicts or complicates the document's position.

Only include this section if there are genuine critical issues. Do not manufacture them.

#### Concerns

Non-critical issues that weaken the document but wouldn't necessarily lead to failure. These might include shallow analysis, minor inaccuracies, missing context, or questionable prioritization.

Only include this section if there are genuine concerns.

#### Suggestions

Optional improvements that would strengthen the document — additional areas to explore, alternative framings, better evidence that could be cited. These are nice-to-haves, not problems.

Only include this section if you have substantive suggestions.

## Important

- **Be honest, not diplomatic.** The purpose of this review is to catch problems before they cause real damage. A review that rubber-stamps a flawed document is worse than no review at all.
- **Be specific, not vague.** "The security analysis is weak" is not useful. "The document claims the API is internal-only (section 3.2), but `/api/v2/export` is exposed via the public load balancer (see `nginx.conf:47`)" is useful.
- **Verify before criticizing.** Do not flag something as wrong unless you have checked. If you cannot verify a claim, say so explicitly rather than guessing.
- **Respect what the document does well.** If the analysis is thorough and accurate in certain areas, you don't need to dwell on those — but a brief acknowledgment helps the author understand which parts to trust.
- **Scale your review to the document.** A short analysis gets a short review. A 20-page implementation plan warrants a more thorough evaluation.
- **Do not rewrite the document.** Your job is to review, not to produce a competing version. Point out problems; let the author fix them.
- If the **focus** argument was provided, prioritize that lens throughout the review but still flag critical issues outside the focus area.