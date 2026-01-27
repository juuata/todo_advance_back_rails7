# コードベース構造

```
todo_advance_back_rails7/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── tasks_controller.rb      # タスクAPI
│   │   └── genres_controller.rb     # ジャンルAPI
│   ├── models/
│   │   ├── application_record.rb
│   │   ├── task.rb                  # タスクモデル
│   │   └── genre.rb                 # ジャンルモデル
│   ├── services/
│   │   ├── service_result.rb        # 結果オブジェクト基底
│   │   └── tasks/
│   │       ├── create_service.rb    # タスク作成
│   │       └── duplicate_service.rb # タスク複製
│   ├── views/
│   │   ├── layouts/
│   │   └── tasks/
│   │       └── all_tasks.json.jbuilder
│   ├── helpers/
│   ├── jobs/
│   ├── mailers/
│   ├── channels/
│   ├── assets/
│   └── javascript/
├── config/
│   └── routes.rb                    # ルーティング定義
├── db/
│   └── schema.rb                    # DBスキーマ
├── spec/
│   ├── spec_helper.rb
│   ├── rails_helper.rb
│   ├── models/
│   │   └── task_spec.rb
│   ├── requests/
│   │   └── tasks_spec.rb
│   └── services/
│       └── tasks/
│           ├── create_service_spec.rb
│           └── duplicate_service_spec.rb
├── Gemfile
├── Gemfile.lock
├── CLAUDE.md                        # AI開発ガイドライン
└── .rspec                           # RSpec設定
```

## データベーステーブル
- **tasks**: id, name, explanation, deadline_date, status, genre_id, priority, timestamps
- **genres**: id, name, timestamps
- **active_storage_***: ファイル添付用テーブル

## 主要な関係
- Task belongs_to Genre (genre_id)
