# Research Template

Claude Code で戦略調査・技術調査・学術リサーチ・市場調査・データ分析を効率的に実行するためのテンプレートリポジトリ。

## 使い方

1. GitHub で「Use this template」ボタンからリポジトリを作成
2. `CLAUDE.md` のプロジェクト概要セクションを記入
3. `.env` に必要なAPIキーを設定
4. Claude Code でリサーチタスクを開始

## フォルダ構成

```
├── 01_codex/          # Codex用の作業スペース
├── 02_claude/         # Claude用の作業スペース
│   ├── analyses/      # Jupyter notebook（定量分析）
│   ├── data/          # データファイル（parquet等）
│   ├── docs/
│   │   ├── descriptions/  # 関数の説明
│   │   ├── knowledges/    # 調査で得た知見
│   │   ├── plans/         # 調査計画
│   │   ├── sessions/      # セッションログ
│   │   └── templates/     # テンプレートファイル
│   ├── old/           # 使わなくなったファイル
│   └── src/           # Pythonスクリプト
├── CLAUDE.md          # Claude Code への指示書
└── AGENTS.md          # Codex への指示書
```

## ブランチ戦略

```
main
└── dev
    ├── codex/{project}
    └── claude/{project}
```

## セットアップ

```bash
# Poetry環境の初期化（未設定の場合）
poetry init
poetry env use python3.12
```
