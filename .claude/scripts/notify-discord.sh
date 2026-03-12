#!/bin/bash
# Discord 通知スクリプト（Claude Code Stop フック用）
# session_summary.md を読み取り、装飾して Cloud Function 経由で Discord に送信する。

set -euo pipefail

NOTIFY_URL="https://post-notification-jqw3lteeqq-an.a.run.app"
SUMMARY_FILE="${CLAUDE_PROJECT_DIR:-.}/02_claude/.session_summary.md"

# リポジトリ名を git remote から取得
REPO_NAME=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" 2>/dev/null || echo "")

if [ -z "$REPO_NAME" ]; then
  exit 0
fi

if [ ! -f "$SUMMARY_FILE" ]; then
  exit 0
fi

RAW_MESSAGE=$(cat "$SUMMARY_FILE")

if [ -z "$RAW_MESSAGE" ]; then
  exit 0
fi

# 現在時刻（JST）
TIMESTAMP=$(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M')

# ブランチ名を取得
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

# 装飾付きメッセージを組み立て
MESSAGE=$(cat <<MSGEOF
━━━━━━━━━━━━━━━━━━━━
🤖 Claude Code 作業レポート
━━━━━━━━━━━━━━━━━━━━
📁 リポジトリ: ${REPO_NAME}
🌿 ブランチ: ${BRANCH}
🕐 完了時刻: ${TIMESTAMP}
──────────────────

${RAW_MESSAGE}

──────────────────
📌 このメッセージは Claude Code の
　 Stopフックにより自動送信されました
━━━━━━━━━━━━━━━━━━━━
MSGEOF
)

# 2000文字制限に対応（超過時は末尾を切り詰め）
if [ ${#MESSAGE} -gt 1950 ]; then
  MESSAGE="${MESSAGE:0:1900}

⚠️ （長文のため一部省略されました）
━━━━━━━━━━━━━━━━━━━━"
fi

# Cloud Function に送信
curl -s -X POST "$NOTIFY_URL" \
  -H "Content-Type: application/json" \
  -d "$(jq -n --arg repo "$REPO_NAME" --arg message "$MESSAGE" '{repo: $repo, message: $message}')" \
  > /dev/null 2>&1 || true
