# Stage 2: Plan format without parallel tags

## Objective

The plan format stops carrying parallelism metadata. Stage dependencies and ordering stay —
they are what the serial executor follows.

## Files

- Modify: `skills/plan-ai-tools/SKILL.md` — plan format and the drafting step that names the tags

## Steps

1. Workflow step 4 (*Draft the plan*): drop `sequential/parallel tags` from the parenthetical
   and put stage ordering in its place, e.g. `… Conventional Commit boundaries, explicit stage order`.
2. Base file template, `## Execution graph` block: remove `(parallel-safe)` from the example and
   state the execution rule, e.g.:
   ```
   Dependency list; every stage appears exactly once.
   Example: 1 before 2 and 3; 4 after 2 and 3.
   Stages run one at a time, in an order consistent with these dependencies.
   ```
3. Stage file template, `## Dependencies` block: delete the line `- Parallel-safe with: …`;
   keep `- Requires stages: … (or none)`.
4. Keep step 3 (*Explore the codebase*) exactly as it is — parallel read-only
   `mechanical-ai-tools` discovery is explicitly in scope to preserve.
5. Leave the rest untouched: status codes, plan locations, *Truth on disk*, Report, Boundaries,
   frontmatter (`description` stays within 500 characters).

## Tests

No automated test covers skill prose. Evidence for this stage:

- `grep -niE "parallel|concurrent" skills/plan-ai-tools/SKILL.md` — only the read-only
  exploration line in Workflow step 3 remains.
- `tools/lint.sh` exits 0.

## Acceptance criteria

- [ ] No `sequential/parallel` tag and no `Parallel-safe with:` field anywhere in the file
- [ ] The base-file template still expresses dependencies and now states one-at-a-time execution
- [ ] Parallel read-only exploration (step 3) is unchanged
- [ ] `tools/lint.sh` passes

## Commit

Suggested message: `refactor(plan-ai-tools): drop parallel tags from the plan format`

## Dependencies

- Requires stages: 1
- Parallel-safe with: none — this plan makes execution serial

## Implementation log
