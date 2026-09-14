# Who made this, and how carefully

*A [Rigor, Vouch, Stages](https://rigor.diaconou.com/) disclosure stamp. The format and vocabulary are specified at [rigor.diaconou.com/spec](https://rigor.diaconou.com/spec/), version 1.0.*

<!-- rigor:summary -->
**The idea was mine. The plan was mine. The implementation was written by me
with an AI. I have read and understood this code; I can explain every line of
it. It was tested by me with an AI. No one maintains this. This assessment is as
of 2026-09-13. I am specifically not recommending you depend on this. Why: it is
archived, and Claude Code now fulfils its goals. Statement made by: Stephen
Ierodiaconou.**
<!-- /rigor:summary -->

## Notes

ai_refactor was an experimental tool to see how AI could be applied to bulk
refactoring of code. I started it in 2023 and wrote it by hand at first. As the
capabilities of the underlying LLM models increased, the work became more and
more AI-driven, until the later changes were made by an AI under my direction.
I have read the code.

The project is archived. Claude Code now fulfils its main goals and is a more
complete tool. No one maintains ai_refactor, and I do not recommend that you
depend on it.

## Stamp

```yaml
spec: "1.0"
signed: "Stephen Ierodiaconou"
rigor: comprehended
vouch: {claim: withheld, why: "it is archived, and Claude Code now fulfils its goals"}
checks:
  comprehended: human
  tested: human-with-ai
stages:
  idea: {by: human}
  plan: {by: human}
  implementation: {by: human-with-ai}
  maintenance: {by: none}
assessed: 2026-09-13
```

<!--
checks: surface any subset; a done value names who did it.
  comprehended / quality_reviewed / security_reviewed / tested / owned:
    yes | human | ai | human-with-ai | no | not-applicable,
    or a pair [before LLMs, since LLMs] of actors.
  engineered and owned must surface the checks they imply; comprehended
  cannot be satisfied by an AI alone.
Run `rigor-md fmt RIGOR.md` after editing the stamp to refresh the summary.
-->
