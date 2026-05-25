#!/bin/bash

# Fetch top 10 stories
STORY_IDS=$(curl -s https://hacker-news.firebaseio.com/v0/topstories.json | jq '.[:10][]')

echo "Hacker News Top Stories (as of $(date))"
echo "---"

for ID in $STORY_IDS; do
  STORY=$(curl -s "https://hacker-news.firebaseio.com/v0/item/$ID.json")
  TITLE=$(echo "$STORY" | jq -r '.title')
  URL=$(echo "$STORY" | jq -r '.url // "https://news.ycombinator.com/item?id=" + (.id|tostring)')
  SCORE=$(echo "$STORY" | jq -r '.score')
  USER=$(echo "$STORY" | jq -r '.by')
  
  echo "[$SCORE] $TITLE"
  echo "URL: $URL"
  echo "By: $USER"
  echo "---"
done
