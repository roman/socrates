---
id: 2-e75b-init-stamp-review-mode
status: draft
priority: 1
category: functional
ticket: null
revisions: 1
---

# Stamp review_mode default in socrates-init

<outcome>
Running `/socrates-init` on a project produces an installed RALPH.md
whose frontmatter contains `review_mode: false`. The install's
post-run output includes a clear paragraph (not a one-liner)
explaining what review-mode does, when an operator might want it,
and how to enable it after install (by editing RALPH.md frontmatter
directly, or by accepting the prompt that `/spec` will surface on
its first run with no tickets in flight). No interactive prompt is
added at install time — discoverability is handled by `/spec` (per
the hook in task 1), where the operator is already in an
interactive session and is thinking about lifecycle. Re-running
init on a project where the operator has set `review_mode: true`
preserves that value rather than silently overwriting it.
</outcome>

<verification>
- Running init on a fresh project produces a RALPH.md whose
  frontmatter contains `review_mode: false`.
- The init's post-run output includes a paragraph (not a single
  line) explaining review-mode, naming when the operator might
  want it, and pointing to RALPH.md frontmatter as the place to
  flip the flag manually.
- The post-run output also tells the operator that `/spec` will
  surface the option on its first run when no tickets are in
  flight, so the operator does not have to remember the manual
  edit path.
- Re-running init on a project where the operator has set
  `review_mode: true` preserves that value.
- The init flow remains non-interactive: no prompt is introduced
  at install time.
</verification>

<review></review>
