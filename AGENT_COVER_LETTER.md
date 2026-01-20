# Agent Cover Letter

> **Purpose:** This file enables communication between the repository agent (Claude) and the review agent (Gemini PR Review). The repo agent uses this file to address previous review feedback before requesting a re-review.

## Instructions for Repo Agent

When addressing PR review comments:

1. Copy this template or edit the existing file
2. Fill in the sections below to explain how you've addressed each concern
3. Commit this file with your fixes
4. The PR review workflow will read this file during re-review

---

## PR Context

**PR Number:** <!-- e.g., #42 -->
**PR Title:** <!-- e.g., Add user authentication feature -->
**Review Iteration:** <!-- e.g., 2 (second review after addressing first round) -->

---

## Previous Review Summary

<!-- Briefly summarize what the previous review requested -->

---

## Addressed Issues

### Critical Issues

<!-- For each critical issue raised, explain how it was addressed -->

#### Issue: [Issue Title from Review]

- **Original Concern:** <!-- What the reviewer flagged -->
- **Resolution:** <!-- How you fixed it -->
- **Files Changed:** <!-- List of files modified to address this -->
- **Verification:** <!-- How you verified the fix (tests, manual check, etc.) -->

---

### Important Issues

<!-- Same format as critical issues -->

#### Issue: [Issue Title from Review]

- **Original Concern:**
- **Resolution:**
- **Files Changed:**
- **Verification:**

---

### Suggestions Addressed

<!-- Optional: Note which suggestions you incorporated -->

| Suggestion         | Status                       | Notes  |
| ------------------ | ---------------------------- | ------ |
| Example suggestion | Implemented / Deferred / N/A | Reason |

---

## Additional Context for Reviewer

<!-- Any additional context that would help the reviewer understand your changes -->

---

## Questions for Reviewer

<!-- Any questions or clarifications you need from the reviewer -->

---

## Checklist

- [ ] All critical issues addressed
- [ ] All important issues addressed
- [ ] Tests updated/added as needed
- [ ] Documentation updated if behavior changed
- [ ] No new linting/formatting errors introduced

---

_This cover letter was prepared by the repository agent to facilitate agent-to-agent communication during code review._
