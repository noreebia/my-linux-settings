---
name: review-doc
description: Reviews an LLM-generated document (system analysis, situation analysis, implementation plan).
user-invocable: true
disable-model-invocation: true
argument-hint: "<file-path> [generate-file] [context]"
---

Review a document — most likely produced by another LLM agent — and give feedback.

## Arguments

- `file-path` (required): Path to the document or directory to review.
- `generate-file` (optional): If provided, write the review feedback to a file instead of outputting it inline. Any truthy value (e.g., `true`, `yes`, `file`) enables this.
- `context` (optional): Additional context to guide the review — e.g., specific concerns, areas to focus on, constraints, or background information the reviewer should know.

## Process

### 1. Read the Document

Read the target document(s) thoroughly. If a directory was provided, read all files within it and understand how they relate to each other.

### 2. Understand the Subject Matter

The document likely makes claims about a codebase, system, process, or situation. Before evaluating those claims, build your own understanding:

- If the document analyzes a codebase or technical system: read the actual source code, configs, and any other artifacts the document references. Do not take the document's descriptions at face value — verify them.
- If the document references external resources (URLs, tickets, APIs): attempt to access and read them for additional context.
- If the document proposes an implementation plan: read the parts of the codebase that would be affected to understand the real starting point.

### 3. Evaluate
Assess the document. Is it accurate? Are there any glaring issues or problems? Are there any blind spots? Are there any alternate approaches or optimizations that you want to suggest? If additional context was provided, factor it into your evaluation.

# Give Feedback
Provide your feedback in a clear, constructive manner. If there are issues, explain why they are issues and provide suggestions for improvement. If there are things that you agree with and parts that are well done, acknowledge those as well.

If the `generate-file` argument was set, write the full review to a markdown file instead of outputting it inline.