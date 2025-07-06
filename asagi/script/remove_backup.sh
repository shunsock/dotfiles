TARGET="/Users/shunsock/Library/Application Support/AquaSKK/skk-jisyo.utf8.hm-backup"

if [ -e "$TARGET" ]; then
  rm "$TARGET"
  echo "削除しました: $TARGET"
else
  echo "ファイルが存在しません: $TARGET"
fi

