JISYO="/Users/shunsock/Library/Application Support/AquaSKK/skk-jisyo.utf8.hm-backup"

if [ -e "$JISYO" ]; then
  rm "$JISYO"
  echo "削除しました: $JISYO"
else
  echo "ファイルが存在しません: $JISYO"
fi

JISYOL="/Users/shunsock/Library/Application Support/AquaSKK/SKK-JISYO.L.hm-backup"
if [ -e "$JISYOL" ]; then
  rm "$JISYOL"
  echo "削除しました: $JISYOL"
else
  echo "ファイルが存在しません: $JISYOL"
fi
