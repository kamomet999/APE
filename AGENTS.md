# APE プロジェクト マルチエージェント運用ルール

事業計画・プロダクト・戦略の意思決定を、複数視点の並列評価で精度を上げる仕組み。

最終更新: 2026-05-02

---

## 基本原則

1. **独立タスクは並列実行**（1メッセージで複数エージェント呼び出し）
2. **依存タスクは順次実行**（ハンドオフドキュメント経由）
3. **1フェーズ最大3-4エージェント**（コスト管理）
4. **各エージェントには完全なコンテキスト**（会話履歴は共有されない）
5. **必ず統合レポートを生成**

---

## ワークフロー種別

### auto（既定）
タスクを分析して最適パターンを自動選択する。

### feature
機能実装パイプライン:
```
planner → [implementation] → code-reviewer + security-reviewer (並列)
```

### bugfix
仮説を並列で検証する:
```
Explore(仮説1) + Explore(仮説2) + Explore(仮説3) → 修正
```

### review
多視点レビュー (並列):
```
code-reviewer + security-reviewer + architect → 統合レポート
```

### refactor
安全なリファクタリング:
```
architect → [refactor] → code-reviewer + security-reviewer (並列)
```

### design
競合する設計案を並列生成:
```
architect(simplicity) + architect(scalability) + architect(cost) → 比較
```

### business-plan-review (APE 固有)
事業計画を3視点で並列評価:
```
business-plan-market + business-plan-financial + business-plan-execution → 統合レポート
```

各視点の責務とエージェント定義:
- **market** ([.claude/agents/business-plan-market.md](.claude/agents/business-plan-market.md)) — TAM/SAM/SOM、競合、ポジショニング、参入障壁、Go-to-Market 戦略
- **financial** ([.claude/agents/business-plan-financial.md](.claude/agents/business-plan-financial.md)) — 収益モデル、ユニットエコノミクス、調達計画、燃焼率、出口
- **execution** ([.claude/agents/business-plan-execution.md](.claude/agents/business-plan-execution.md)) — チーム適合度、技術リスク、運用ボトルネック、Day 1-90 の実現性

---

## モデル選択

| モデル | 用途 |
|--------|------|
| opus | 戦略、アーキテクチャ、複雑な分析、事業計画評価 |
| sonnet | 標準レビュー、計画、TDD |
| haiku | 単純検索、フォーマットチェック |

---

## ハンドオフドキュメント形式

順次ステージ間の引き継ぎに使用。

```markdown
## HANDOFF: [前エージェント] → [次エージェント]

### Context
[実施内容のサマリ]

### Findings
[主要な発見・決定]

### Files Modified
[編集したファイル一覧]

### Open Questions
[未解決事項]
```

---

## 統合レポート形式

```
[Multi-Agent: パターン名] (agents: a, b, c)

## Summary
[統合された発見を3-5文で]

## Per-Agent Findings
### [Agent 1]
- [主要ポイント]

### [Agent 2]
- [主要ポイント]

## Conflicts
[エージェント間の矛盾、あれば]

## Recommended Actions
1. [最優先]
2. [次]

## Verdict
[SHIP / NEEDS WORK / BLOCKED]
```

---

## コスト意識

- 1視点で十分なら他エージェント発動禁止
- 小規模レビューは code-reviewer 単独で十分
- 単純なバグは並列仮説不要、直接調査
- 30分未満の機能は planner スキップ

---

## APE 固有のドキュメント運用

事業計画関連ドキュメントは `documents/00_事業計画資料_Docs/` に集約:
- `Business_Plan.md` — 当初版（2026-02 時点、農家向け SaaS 中心）
- `business_plan_v0_2026-05.md` — 統合版（流通インフラ転換後、新戦略反映）
- `competitive_strategy_2026.md` — 競合戦略
- `competitor_analysis.md` — 競合詳細

評価レポートは `documents/00_事業計画資料_Docs/reviews/` に保存:
- `YYYY-MM-DD_business_plan_v0_review.md` — 並列評価結果

ユーザーインタビューは `documents/05_ユーザーインタビュー_Interviews/`:
- `YYYY-MM-DD_<参加者>_<種別>.md` — 命名規則

---

## 使い方

```
/multi-agent business-plan-review documents/00_事業計画資料_Docs/business_plan_v0_2026-05.md
/multi-agent design 飲食店向け発注UIの設計案
/multi-agent review apps/web の Phase 1 改造プラン
```
