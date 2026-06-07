---
name: hacker_news
description: Fetches and summarizes the top stories from Hacker News. Use this skill when the user asks for the latest tech news, Hacker News updates, or what's trending on HN.
---

# Hacker News

This skill allows Antigravity CLI to fetch the latest top stories from Hacker News and provide a concise summary.

## Workflow

1.  **Fetch Stories**: Run the `scripts/fetch_hn.sh` script to get the top 10 stories.
2.  **Summarize**: Analyze the output (titles, scores, and URLs) and provide a bulleted summary to the user, highlighting the most interesting or highly-voted items.

## Usage Examples

- "What's on Hacker News today?"
- "Give me a summary of the top stories on HN."
- "What's trending in tech news right now?"

## Resources

- `scripts/fetch_hn.sh`: A bash script that uses `curl` and `jq` to fetch the top 10 stories from the Hacker News Firebase API.
