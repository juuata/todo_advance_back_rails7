# コードスタイルと規約

## 基本原則
- **SOLID原則**に従う
- **Rails Way** を尊重
- **TDD (テスト駆動開発)**: Red → Green → Refactor

## アーキテクチャパターン
- **Fat Model, Skinny Controller**: ビジネスロジックはモデル・サービス層に
- **サービス層**: 複雑なロジックは `app/services/` に分離
  - `ServiceResult` パターンで結果を返す
  - 名前空間でグループ化（例: `Tasks::CreateService`）

## コーディング規約
- RuboCopに準拠（設定ファイルは未作成だが、デフォルト設定を使用）
- 命名規則:
  - クラス: PascalCase (`TasksController`)
  - メソッド/変数: snake_case (`find_task`)
  - 定数: SCREAMING_SNAKE_CASE (`MAX_COUNT`)

## テスト
- RSpecを使用
- ディレクトリ構造:
  - `spec/models/` - モデルテスト
  - `spec/requests/` - リクエストスペック（API統合テスト）
  - `spec/services/` - サービス層テスト
- フォーマット: documentation形式（`--format documentation`）

## ワークフロー（CLAUDE.md より）
1. GitHub Issue番号からブランチ作成
2. 実装計画を策定し、ユーザー承認を得る
3. 実装 → セルフレビュー → ユーザー承認
4. テスト・Lint通過を確認してコミット

## 禁止事項
- ユーザー承認なしに作業を進めない
- 同じ方法で3回以上失敗しない
