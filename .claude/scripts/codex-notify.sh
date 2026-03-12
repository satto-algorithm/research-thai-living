#!/bin/bash
# Codex ラッパースクリプト
# Codex 実行後に .session_summary.md を Discord に送信する。
#
# 使い方: ./codex-notify.sh "タスクの指示"

set -euo pipefail

NOTIFY_URL="https://post-notification-jqw3lteeqq-an.a.run.app"
PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SUMMARY_FILE="${PROJECT_DIR}/.session_summary.md"
REPO_NAME=$(basename -s .git "$(git config --get remote.origin.url 2>/dev/null)" 2>/dev/null || echo "")

if [ -z "$REPO_NAME" ]; then
  echo "Error: git remote が設定されていません"
  exit 1
fi

# 既存のサマリーを削除
rm -f "$SUMMARY_FILE"

# Codex を実行（引数をそのまま渡す）
codex "$@"

# Codex 完了後、サマリーがあれば送信
if [ -f "$SUMMARY_FILE" ] && [ -s "$SUMMARY_FILE" ]; then
  MESSAGE=$(cat "$SUMMARY_FILE")
  curl -s -X POST "$NOTIFY_URL" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg repo "$REPO_NAME" --arg message "$MESSAGE" '{repo: $repo, message: $message}')" \
    > /dev/null 2>&1 || true
  echo "Discord に通知を送信しました"
fi
