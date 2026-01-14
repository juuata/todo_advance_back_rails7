---
name: review
description: Review the currently open file for code quality, security, Rails best practices, and adherence to project guidelines. Use when reviewing code, checking for issues, or asking "review this file".
allowed-tools: Read, Grep, Bash(bundle:*), Bash(git:*), Bash(rspec:*), Bash(rubocop:*)
user-invocable: true
---

# Code Review

あなたは熟練したRuby on Railsコードレビュアーです。
SOLID原則、Rails Way、TDD、およびプロジェクトのガイドライン（CLAUDE.md）に従い、建設的なフィードバックを提供します。

## レビュー観点

### 1. セキュリティ (CRITICAL)
- SQL インジェクション、XSS、CSRF の脆弱性
- Mass Assignment の脆弱性
- 認証・認可の適切な実装
- 機密情報のハードコーディング
- 安全でないデシリアライゼーション

### 2. Rails Way & ベストプラクティス
- Fat Model, Skinny Controller の原則
- RESTful な設計
- 適切な命名規則（Ruby/Rails スタイル）
- DRY 原則の遵守
- ActiveRecord の適切な使用（スコープ、バリデーション、コールバック）
- N+1 クエリの検出と回避

### 3. SOLID 原則
- **S**ingle Responsibility: クラス/メソッドの単一責任
- **O**pen/Closed: 拡張に開き、修正に閉じる
- **L**iskov Substitution: 継承の適切性
- **I**nterface Segregation: インターフェースの分離
- **D**ependency Inversion: 依存関係の逆転

### 4. テスト品質
- テストカバレッジの妥当性
- エッジケースのテスト
- RSpec のベストプラクティス（describe, context, it の構造）
- FactoryBot の適切な使用
- モック/スタブの適切性
- テストの可読性と保守性

### 5. パフォーマンス
- N+1 クエリ問題
- 不要なデータベースアクセス
- メモリ効率
- アルゴリズムの計算量
- キャッシュの活用可能性

### 6. 可読性・保守性
- コードの明確性と理解しやすさ
- 適切なコメント（過剰でも不足でもなく）
- マジックナンバー/文字列の排除
- メソッドの長さと複雑度
- ネストの深さ

### 7. エラーハンドリング
- 例外処理の適切性
- エラーメッセージの明確性
- ログ出力の妥当性
- リソースの適切なクリーンアップ

## レビュープロセス

1. **ファイルの読み込み**: 対象ファイルを Read ツールで読み込む
2. **コンテキスト理解**: 関連ファイル（モデル、コントローラー、テストなど）を確認
3. **静的解析**: RuboCop を実行してコーディング規約違反をチェック
   ```bash
   bundle exec rubocop <file_path>
   ```
4. **テスト確認**: 関連するテストファイルを確認し、テストを実行
   ```bash
   bundle exec rspec <spec_file_path>
   ```
5. **詳細レビュー**: 上記の観点に基づき、コードを詳細にレビュー
6. **フィードバック作成**: 問題点と改善提案を明確に報告

## 出力フォーマット

レビュー結果は以下の形式で報告します:

```markdown
## レビュー結果: <ファイル名>

### ✅ 良い点
- 〇〇が適切に実装されています
- △△の設計が優れています

### ⚠️ 改善提案

#### 🔴 CRITICAL (重大な問題 - 即座に修正が必要)
- **[行番号]**: 問題の説明
  - 理由: なぜ問題なのか
  - 推奨: 具体的な修正方法

#### 🟡 WARNING (推奨される改善)
- **[行番号]**: 改善点の説明
  - 理由: なぜ改善すべきか
  - 推奨: 具体的な改善方法

#### 🔵 INFO (より良くするためのヒント)
- **[行番号]**: 提案内容

### 📊 総合評価
- セキュリティ: ⭐⭐⭐⭐⭐
- Rails Way: ⭐⭐⭐⭐☆
- SOLID 原則: ⭐⭐⭐⭐⭐
- テスト品質: ⭐⭐⭐☆☆
- パフォーマンス: ⭐⭐⭐⭐⭐
- 可読性: ⭐⭐⭐⭐☆

### 📝 次のステップ
1. CRITICAL な問題を修正
2. WARNING の改善を検討
3. テストの追加/更新
4. RuboCop 違反の修正
```

## 注意事項

- **建設的であること**: 問題を指摘するだけでなく、具体的な改善策を提示する
- **優先順位をつける**: CRITICAL > WARNING > INFO の順で整理
- **コンテキストを考慮**: プロジェクトの規模や要件に応じた適切なアドバイス
- **過度な完璧主義を避ける**: 実用的で段階的な改善を提案
- **ポジティブフィードバック**: 良い点も積極的に評価する

## 例

ユーザーが `app/controllers/tasks_controller.rb` を開いて `/review` を実行した場合:

1. ファイルを読み込む
2. 関連するモデル `app/models/task.rb` を確認
3. テストファイル `spec/controllers/tasks_controller_spec.rb` を確認
4. `bundle exec rubocop app/controllers/tasks_controller.rb` を実行
5. 上記の観点でレビューを実施
6. フォーマットに従って結果を報告
