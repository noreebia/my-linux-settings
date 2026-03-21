---
name: review-doc
description: Reviews an LLM-generated document (system analysis, situation analysis, implementation plan).
user-invocable: true
disable-model-invocation: true
argument-hint: "<file-path> [generate-file] [context]"
---

# Review Document

Review a document — most likely produced by another LLM agent — and generate feedback.

## Arguments

- `file-path` (required): Path to the document or directory to review.
- `generate-file` (optional): If provided, write the review feedback to a file instead of outputting it inline. Any truthy value (e.g., `true`, `yes`, `file`) enables this.
- `context` (optional): Additional context to guide the review — e.g., specific concerns, areas to focus on, constraints, or background information that could aid in the review.

## Process

### 1. Read the Document

Read the target document(s). If a directory was provided, read all files within it.

### 2. Understand the Subject Matter

The document likely makes claims about a codebase, system, process, or situation. Before evaluating those claims, build your own understanding:

- If the document analyzes a codebase or technical system: read the actual source code, configs, and any other artifacts the document references. Do not take the document's descriptions at face value — verify them for yourself.
- If the document references external resources (URLs, tickets, APIs): attempt to access and read them for additional context.
- If the document proposes an implementation plan: read the parts of the codebase that would be affected.

### 3. Evaluate
Assess the document. Are there any glaring problems or inaccuracies? Are there any blind spots? Are there any overlooked factors or aspects? Are there any alternate approaches that you want to suggest? 

If additional context was provided, factor it into your evaluation. 

Choose to be sensible and pragmatic over perfectionistic. Decide when things are a worth calling out, versus when they are just differences in perspectives.

### 4. Give Feedback
Provide your evaluation of the document, including any issues you found and suggestions for improvement. Also acknowledge any parts that you think are well done or that you agree with.

If the `generate-file` argument was set, write the full review to a markdown file instead of outputting it inline.