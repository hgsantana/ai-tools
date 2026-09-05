# Wrapper Templates

Standard canonical templates for authoring agent wrappers across supported harnesses.

## Directory Structure

```text
templates/wrappers/
├── antigravity.md         # Google Antigravity wrapper template (*.md)
├── claude-code.md         # Claude Code wrapper template (*.md)
├── codex.toml             # OpenAI Codex wrapper template (*.toml)
├── copilot.agent.md       # GitHub Copilot wrapper template (*.agent.md)
├── cursor.md              # Cursor wrapper template (*.md)
├── grok.md                # Grok Build wrapper template (*.md)
└── README.md              # This documentation
```

## Individual Harness Frontmatter Rules & Specifications

Each harness has distinct parsing and format requirements. Only apply the rules that belong to each harness:

1. **Grok (`grok.md`)**:
   - **Quoting**: `description` **must** be enclosed in double quotes (`"..."`) when containing a colon followed by space (`: `). Grok uses a strict Rust `serde_yaml` parser; unquoted scalars with `: ` trigger a fatal YAML parse error and cause Grok to drop the agent.
   - **Model pinning**: Do **not** declare `model:` in frontmatter (Grok ignores frontmatter models). Models are pinned at installation in `~/.grok/config.toml` under `[subagents.models]`.
   - **Inheritance**: Declares `mcpInheritance: all`.

2. **OpenAI Codex (`codex.toml`)**:
   - **Format**: Strictly TOML (`*.toml`). All string values must be quoted (`name = "..."`, `description = "..."`, `model = "..."`, optional `model_reasoning_effort = "..."`).
   - **Body**: Prompt body lives in `developer_instructions = """..."""` (backslashes doubled for Windows paths).

3. **Claude Code (`claude-code.md`)**:
   - **Format**: Markdown with YAML frontmatter.
   - **Quoting**: Tolerates unquoted plain scalars.
   - **Model & effort**: Declares `model:` (`opus`/`sonnet`/`haiku`), plus optional `effort:` (`high`) when specified in `MODELS.csv`.

4. **GitHub Copilot (`copilot.agent.md`)**:
   - **Format**: Must use `*.agent.md` filename extension.
   - **Model**: `model:` must be a single string scalar (e.g. `Grok 4.6`, `Gemini 3.8 Flash`). The CLI rejects YAML array syntax.
   - **Quoting**: Plain unquoted string scalar.

5. **Google Antigravity (`antigravity.md`)**:
   - **Format**: Markdown with YAML frontmatter.
   - **Model**: `model:` must be a subagent tier (`inherit`, `flash`, or `pro`), not an external vendor model name.
   - **Quoting**: Plain unquoted string scalar.

6. **Cursor (`cursor.md`)**:
   - **Format**: Markdown with YAML frontmatter.
   - **Fields**: Declares `model:`, `readonly: false`, and `is_background: false`.
   - **Quoting**: Plain unquoted string scalar.

7. **Canonical Body**: Every wrapper carries the exact canonical text referencing `$HOME/.ai-tools/agents/SUBAGENT-CONTRACT.md` and `$HOME/.ai-tools/agents/<name>.md` (Rule 6).
