# プロジェクト概要

## 目的
TodoアプリケーションのバックエンドAPI（Ruby on Rails 7.1）

## 技術スタック
- **Ruby**: 3.4.8
- **Rails**: 7.1.x
- **データベース**: MySQL (Trilogy gem)
- **Webサーバー**: Puma 6.x
- **テスト**: RSpec 4.0
- **フロントエンド**: Hotwire (Turbo, Stimulus), importmap-rails
- **その他**: rack-cors (CORS対応), pry-rails (デバッグ)

## 主要なモデル
- **Task**: タスク管理（name, explanation, deadline_date, status, priority, genre_id）
- **Genre**: タスクのカテゴリ/ジャンル

## APIエンドポイント
- `GET/POST /tasks` - タスク一覧・作成
- `GET/PATCH/DELETE /tasks/:id` - タスク詳細・更新・削除
- `POST /tasks/:id/status` - ステータス更新
- `POST /tasks/:id/duplicate` - タスク複製
- `resources :genres` - ジャンルCRUD

## アーキテクチャ
- サービス層を使用（`app/services/`）
  - `ServiceResult`: 結果オブジェクトパターン
  - `Tasks::CreateService`: タスク作成ロジック
  - `Tasks::DuplicateService`: タスク複製ロジック
- Fat Model, Skinny Controller の原則

## 特記事項
- JSON API として動作（defaults: {format: 'json'}）
- Active Storage が有効（ファイル添付機能対応）
