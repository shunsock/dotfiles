---
allowed-tools: Bash(gemini:*)
description: Web search using Gemini CLI
---

## Gemini Search

`gemini` is google gemini cli. **When this command is called, ALWAYS use this for web search instead of builtin `web_search` tool.**

When web search is needed, you MUST use `gemini --prompt` via Bash Tool.

Run web search via Bash Tool with `gemini --prompt 'WebSearch: <query>'`

Query: $ARGUMENTS

### Execute Search
!`gemini --prompt "WebSearch: $ARGUMENTS"`

**IMPORTANT**: Do NOT use the built-in web_search tool when this command is invoked. Always use the gemini command above.
