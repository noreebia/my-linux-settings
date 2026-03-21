---
name: review-feedback
description: Review and process feedback from another agent (e.g., a review of a document you produced) and determine how to respond to it.
user-invocable: true
disable-model-invocation: true
argument-hint: "<file-path> [generate-file] [context]"
---

# Review Feedback

## Arguments

- `file-path` (required): Path to the feedback document
- `generate-file` (optional): If provided, write the response to a file instead of outputting it inline. Any truthy value (e.g., `true`, `yes`, `file`) enables this.
- `context` (optional): Additional context — e.g., the original document that was reviewed, constraints on what can change, or priorities to weigh when deciding what feedback to act on.

## Body

Process feedback on a document — most likely a review produced by another LLM agent — and let me know what you think. Are there valid points in the feedback that you agree with? Are there some parts that you have a different perspective on? 

If the `generate-file` argument was set, write your response to a markdown document instead of outputting it inline. Name the file with a `-response` suffix (e.g., if the feedback file is `plan-review.md`, name the response file `plan-review-response.md`).

