#!/bin/bash
# 自動コミット＆プッシュスクリプト（Claude Code Stop フック用）
# 変更があれば自動的に git add / commit / push を実行する。

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

# .gitignore が効くので安全にステージング
# ただし .env 等の機密ファイルは明示的に除外
EXCLUDE_PATTERNS=(
  ".env"
  ".env.*"
  "credentials*"
  "*.pem"
  "*.key"
)

# 変更があるか確認
if git diff --quiet HEAD && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  echo "[auto-commit] 変更なし。スキップします。"
  exit 0
fi

# ステージング（.gitignore + 追加除外パターン適用）
git add -A

for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  git ls-files --cached "$pattern" 2>/dev/null | while read -r f; do
    git reset HEAD -- "$f" 2>/dev/null || true
  done
done

# ステージされた変更があるか再確認
if git diff --cached --quiet; then
  echo "[auto-commit] ステージされた変更なし。スキップします。"
  exit 0
fi

# タイムスタンプ付きコミットメッセージ
TIMESTAMP=$(TZ=Asia/Tokyo date '+%Y-%m-%d_%H%M%S')
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

git commit -m "auto-commit: ${TIMESTAMP}"

# リモートが設定されていればプッシュ
if git remote get-url origin &>/dev/null; then
  # upstream が設定されていなければ -u 付きでプッシュ
  if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" &>/dev/null; then
    git push || echo "[auto-commit] push 失敗（ネットワークエラー等）。次回リトライします。"
  else
    git push -u origin "$BRANCH" || echo "[auto-commit] push 失敗。次回リトライします。"
  fi
else
  echo "[auto-commit] リモートが未設定。ローカルコミットのみ実行しました。"
fi

echo "[auto-commit] 完了: ${TIMESTAMP} on ${BRANCH}"
