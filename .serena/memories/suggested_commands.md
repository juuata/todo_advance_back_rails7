# 開発コマンド一覧

## テスト
```bash
# 全テスト実行
bundle exec rspec

# 特定ファイルのテスト
bundle exec rspec spec/models/task_spec.rb

# 特定のexampleのみ
bundle exec rspec spec/models/task_spec.rb:10
```

## Lint/静的解析
```bash
# RuboCop実行
bundle exec rubocop

# 自動修正付き
bundle exec rubocop -a
```

## Rails
```bash
# サーバー起動
rails s

# コンソール
rails c

# マイグレーション
rails db:migrate

# マイグレーションロールバック
rails db:rollback

# ルーティング確認
rails routes
```

## Bundler
```bash
# gem インストール
bundle install

# gem 更新
bundle update
```

## Git
```bash
# ステータス確認
git status

# 差分確認
git diff

# コミット
git commit -m "メッセージ"

# ブランチ作成・切り替え
git checkout -b feature/branch-name
```

## システムユーティリティ (macOS/Darwin)
```bash
# ディレクトリ一覧
ls -la

# ファイル検索
find . -name "*.rb"

# テキスト検索
grep -r "検索文字列" .

# カレントディレクトリ
pwd
```
