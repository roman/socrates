# Spike 0.3 — gh API Review Metadata Findings

**Date**: 2026-04-04
**Test PR**: https://github.com/NixOS/nixpkgs/pull/506637
**Result**: All required fields available across two API surfaces

## REST API: `pulls/{n}/comments`

Endpoint: `gh api repos/{owner}/{repo}/pulls/{n}/comments`

Available fields (confirmed):
- `body` — comment text (includes GitHub suggestion blocks)
- `path` — file path relative to repo root
- `line` / `original_line` — line number in the diff
- `start_line` / `original_start_line` — for multi-line comments
- `commit_id` — SHA the comment was made against
- `user.login` — author
- `side` — LEFT or RIGHT (old vs new file)
- `diff_hunk` — surrounding diff context
- `created_at` / `updated_at` — timestamps
- `pull_request_review_id` — groups comments into reviews

Missing from REST:
- **Thread resolved status** — not available on this endpoint

## REST API: `pulls/{n}/reviews`

Endpoint: `gh api repos/{owner}/{repo}/pulls/{n}/reviews`

Available fields:
- `state` — COMMENTED, APPROVED, CHANGES_REQUESTED, DISMISSED
- `body` — review-level summary
- `user.login` — reviewer
- `submitted_at` — timestamp

## GraphQL: Thread resolved status

Only available via GraphQL `reviewThreads` query:

```graphql
repository(owner, name) {
  pullRequest(number) {
    reviewThreads(first: N) {
      nodes {
        isResolved
        comments(first: N) {
          nodes { body, path, author { login } }
        }
      }
    }
  }
}
```

`isResolved` is a boolean per thread.

## Implications for ralph.sh / code-review

1. **REST is sufficient** for extracting comment body, file, line, author,
   and commit SHA — the core data needed to create tk ticket comments.
2. **Thread resolved status requires GraphQL** — needed if ralph should
   skip already-resolved threads. Worth using since `gh api graphql` is
   straightforward.
3. **Parsing**: REST returns JSON array, jq works directly. No NDJSON
   issue like tk query.
4. **Pagination**: large PRs may need `--paginate` flag on `gh api`.
