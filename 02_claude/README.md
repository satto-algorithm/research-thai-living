# 02_claude

Claude Code によるリサーチ作業スペース。

## フォルダ構成

```
02_claude/
├── docs/
│   ├── plans/          # 調査計画（{日付}_{概要}.md）
│   ├── knowledges/     # 調査中の知見メモ（Claude作業用、{日付}_{概要}.md）
│   ├── reports/        # 人間向けレポート（重要な調査結果のみ、{日付}_{タイトル}.md）
│   ├── sessions/       # セッションログ（{日付}_{概要}.md）
│   ├── descriptions/   # 関数のインプット・アウトプット説明
│   └── templates/      # 各種テンプレート
├── analyses/           # 分析用notebook（{日付}_{概要}/配下に.ipynb）
├── src/                # Pythonソースコード（{機能}.py）
├── data/               # 共有データ（.parquet）
└── old/                # 使わなくなったファイル置き場
```

## knowledges と reports の使い分け

| | knowledges | reports |
|---|---|---|
| 対象 | Claude（AI作業用） | 人間 |
| 作成頻度 | 調査ごとに毎回 | 指示があった時 or 重要な結果のみ |
| 内容 | 生の知見メモ | 整理・構成されたレポート |
