#!/bin/bash
# Discord通知スクリプト
# 使用方法: ./discord_notify.sh
# 02_claude/.session_summary.md の内容を読み取り、
# git情報を付与してDiscord webhookにPOSTする。
# 環境変数 DISCORD_WEBHOOK_URL が必要（.envに設定）。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SUMMARY_FILE="$PROJECT_DIR/02_claude/.session_summary.md"
ENV_FILE="$PROJECT_DIR/.env"

# .envからwebhook URLを読み込み
if [ -f "$ENV_FILE" ]; then
  DISCORD_WEBHOOK_URL=$(grep '^DISCORD_WEBHOOK_URL=' "$ENV_FILE" | cut -d'=' -f2-)
fi

if [ -z "${DISCORD_WEBHOOK_URL:-}" ]; then
  echo "Error: DISCORD_WEBHOOK_URL not set" >&2
  exit 1
fi

# サマリーファイルがなければスキップ
if [ ! -f "$SUMMARY_FILE" ]; then
  exit 0
fi

SUMMARY=$(cat "$SUMMARY_FILE")
if [ -z "$SUMMARY" ]; then
  exit 0
fi

# git情報を取得
cd "$PROJECT_DIR"
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
RECENT_COMMIT=$(git log -1 --format="%h %s" 2>/dev/null || echo "none")
CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | head -10 || echo "none")

# メッセージ組み立て
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
HEADER="─────────────────────────────
**Claude Code セッションサマリー**"
if [ -n "$REMOTE_URL" ]; then
  HEADER="${HEADER}
**リポジトリ**: ${REMOTE_URL}"
else
  HEADER="${HEADER}
**リポジトリ**: ${REPO_NAME}"
fi
HEADER="${HEADER}
**ブランチ**: \`${BRANCH}\` | ${TIMESTAMP}"

MESSAGE="${HEADER}

${SUMMARY}

**最新コミット**: \`${RECENT_COMMIT}\`
**変更ファイル**:
\`\`\`
${CHANGED_FILES}
\`\`\`"

# 2000文字制限に切り詰め
if [ ${#MESSAGE} -gt 1950 ]; then
  MESSAGE="${MESSAGE:0:1947}..."
fi

# JSON用にエスケープ（改行・引用符・バックスラッシュ）
JSON_MESSAGE=$(printf '%s' "$MESSAGE" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

# Discord webhookにPOST
curl -s -o /dev/null -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "{\"content\": ${JSON_MESSAGE}}" \
  "$DISCORD_WEBHOOK_URL"
