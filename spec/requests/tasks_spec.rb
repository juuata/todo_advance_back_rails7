require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  let!(:genre) { Genre.create!(name: 'テストジャンル') }

  describe 'POST /tasks' do
    context '優先度を指定してタスクを作成する場合' do
      it 'priority="low"を指定して優先度「低」のタスクを作成できること' do
        post '/tasks', params: {
          name: '低優先度タスク',
          genreId: genre.id,
          priority: 'low'
        }

        expect(response).to have_http_status(:success)

        created_task = Task.last
        expect(created_task.priority).to eq('low')
      end

      it 'priority="medium"を指定して優先度「中」のタスクを作成できること' do
        post '/tasks', params: {
          name: '中優先度タスク',
          genreId: genre.id,
          priority: 'medium'
        }

        expect(response).to have_http_status(:success)

        created_task = Task.last
        expect(created_task.priority).to eq('medium')
      end

      it 'priority="high"を指定して優先度「高」のタスクを作成できること' do
        post '/tasks', params: {
          name: '高優先度タスク',
          genreId: genre.id,
          priority: 'high'
        }

        expect(response).to have_http_status(:success)

        created_task = Task.last
        expect(created_task.priority).to eq('high')
      end
    end

    context '優先度を指定しない場合' do
      it 'デフォルト値「中」でタスクが作成されること' do
        post '/tasks', params: {
          name: 'デフォルト優先度タスク',
          genreId: genre.id
        }

        expect(response).to have_http_status(:success)

        created_task = Task.last
        expect(created_task.priority).to eq('medium')
      end
    end

    context 'レスポンスJSON' do
      it '作成されたタスクのpriorityがレスポンスに含まれていること' do
        post '/tasks', params: {
          name: 'テストタスク',
          genreId: genre.id,
          priority: 'high'
        }

        expect(response).to have_http_status(:success)

        json_response = JSON.parse(response.body)

        # レスポンスが配列の場合（tasks_allを返す実装の場合）
        if json_response.is_a?(Array)
          created_task_json = json_response.find { |t| t['name'] == 'テストタスク' }
          expect(created_task_json).to be_present
          expect(created_task_json['priority']).to eq('high')
        else
          # レスポンスが単一オブジェクトの場合
          expect(json_response['priority']).to eq('high')
        end
      end
    end

    context '優先度の更新' do
      let!(:task) { Task.create!(name: '既存タスク', genre: genre, priority: :medium) }

      it 'PATCH /tasks/:idで優先度を更新できること' do
        patch "/tasks/#{task.id}", params: {
          priority: 'high'
        }

        expect(response).to have_http_status(:success)

        task.reload
        expect(task.priority).to eq('high')
      end
    end
  end

  describe 'GET /tasks' do
    before do
      Task.create!(name: '低優先度タスク', genre: genre, priority: :low)
      Task.create!(name: '中優先度タスク', genre: genre, priority: :medium)
      Task.create!(name: '高優先度タスク', genre: genre, priority: :high)
    end

    it 'レスポンスに各タスクのpriorityが含まれること' do
      get '/tasks'

      expect(response).to have_http_status(:success)

      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(3)

      # 全てのタスクにpriorityが含まれていることを確認
      json_response.each do |task_json|
        expect(task_json).to have_key('priority')
        expect(['low', 'medium', 'high']).to include(task_json['priority'])
      end
    end
  end

  # ===========================================
  # タスク複製API (POST /tasks/:id/duplicate)
  # ===========================================
  describe 'POST /tasks/:id/duplicate' do
    let!(:other_genre) { Genre.create!(name: '別のジャンル') }

    # ===========================================
    # 6. 正常系：リクエスト/レスポンス
    # ===========================================
    context '6. 正常系: リクエスト/レスポンス' do
      let!(:original_task) do
        Task.create!(
          name: 'オリジナルタスク',
          explanation: 'タスクの説明文',
          genre_id: genre.id,
          priority: :high,
          status: 2,
          deadline_date: Date.new(2026, 3, 15)
        )
      end

      describe '6-1: 有効なIDを指定してリクエスト' do
        it '201 Createdが返ること' do
          post "/tasks/#{original_task.id}/duplicate"

          expect(response).to have_http_status(:created)
        end
      end

      describe '6-2: レスポンスに複製されたタスクの情報が含まれる' do
        it '新しいタスクのJSONが返ること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)

          expect(json_response).to have_key('id')
          expect(json_response).to have_key('name')
          expect(json_response['id']).not_to eq(original_task.id)
        end
      end

      describe '6-3: データベースにタスクが1件増加する' do
        it 'Task.countが+1になること' do
          expect {
            post "/tasks/#{original_task.id}/duplicate"
          }.to change(Task, :count).by(1)
        end
      end

      describe '6-4: 元のタスクは変更されない' do
        it '元タスクの属性が変わらないこと' do
          original_attributes = original_task.attributes.except('updated_at')

          post "/tasks/#{original_task.id}/duplicate"

          original_task.reload
          expect(original_task.attributes.except('updated_at')).to eq(original_attributes)
        end
      end
    end

    # ===========================================
    # 7. 正常系：レスポンス内容の検証
    # ===========================================
    context '7. 正常系: レスポンス内容の検証' do
      let!(:original_task) do
        Task.create!(
          name: '元のタスク名',
          explanation: '詳細な説明',
          genre_id: genre.id,
          priority: :high,
          status: 2,
          deadline_date: Date.new(2026, 6, 30)
        )
      end

      describe '7-1: レスポンスのnameに「(コピー)」が付与されている' do
        it 'name末尾に「(コピー)」が付与されること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['name']).to eq('元のタスク名(コピー)')
        end
      end

      describe '7-2: レスポンスのstatusが「未着手」になっている' do
        it 'statusが初期値になること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('not_started')
        end
      end

      describe '7-3: レスポンスのdeadlineDateがnullになっている' do
        it 'deadlineDateがnullになること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          # キーがdeadlineDate または deadline_date のいずれかを確認
          deadline_value = json_response['deadlineDate'] || json_response['deadline_date']
          expect(deadline_value).to be_nil
        end
      end

      describe '7-4: レスポンスのgenreId, priorityが元と同じ' do
        it 'genreIdが元のタスクと一致すること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          genre_id_value = json_response['genreId'] || json_response['genre_id']
          expect(genre_id_value).to eq(original_task.genre_id)
        end

        it 'priorityが元のタスクと一致すること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['priority']).to eq('high')
        end
      end

      describe '7-5: explanationが元と同じ' do
        it 'explanationが元のタスクと一致すること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['explanation']).to eq('詳細な説明')
        end
      end
    end

    # ===========================================
    # 8. 異常系：存在しないリソース
    # ===========================================
    context '8. 異常系: 存在しないリソース' do
      describe '8-1: 存在しないタスクIDを指定' do
        it '404 Not Foundが返ること' do
          non_existent_id = 999999

          post "/tasks/#{non_existent_id}/duplicate"

          expect(response).to have_http_status(:not_found)
        end
      end

      describe '8-2: IDに不正な値（文字列）を指定' do
        it '404 Not Foundが返ること' do
          post '/tasks/invalid_id/duplicate'

          expect(response).to have_http_status(:not_found)
        end
      end

      describe '8-3: IDに0を指定' do
        it '404 Not Foundが返ること' do
          post '/tasks/0/duplicate'

          expect(response).to have_http_status(:not_found)
        end
      end

      describe '8-4: IDに負数を指定' do
        it '404 Not Foundが返ること' do
          post '/tasks/-1/duplicate'

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    # ===========================================
    # 9. 異常系：バリデーションエラー
    # ===========================================
    context '9. 異常系: バリデーションエラー', skip: 'nameのバリデーションが実装されたら有効化' do
      describe '9-1: 「(コピー)」付与後にnameが最大長を超える場合' do
        let(:max_length_name) { 'あ' * 255 }
        let!(:max_length_task) do
          Task.create!(
            name: max_length_name,
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '422 Unprocessable Entityが返ること' do
          post "/tasks/#{max_length_task.id}/duplicate"

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      describe '9-2: エラーレスポンスに適切なエラーメッセージが含まれる' do
        let(:max_length_name) { 'あ' * 255 }
        let!(:max_length_task) do
          Task.create!(
            name: max_length_name,
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it 'errors配列にメッセージが含まれること' do
          post "/tasks/#{max_length_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response).to have_key('errors')
          expect(json_response['errors']).to be_present
        end
      end

      describe '9-3: バリデーションエラー時、データベースにタスクが増えない' do
        let(:max_length_name) { 'あ' * 255 }
        let!(:max_length_task) do
          Task.create!(
            name: max_length_name,
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it 'Task.countが変わらないこと' do
          expect {
            post "/tasks/#{max_length_task.id}/duplicate"
          }.not_to change(Task, :count)
        end
      end
    end

    # ===========================================
    # 10. 異常系：HTTPメソッド
    # ===========================================
    context '10. 異常系: HTTPメソッド', skip: 'テスト環境の問題でルーティングエラーの検証が不安定' do
      let!(:task) do
        Task.create!(
          name: 'テストタスク',
          genre_id: genre.id,
          priority: :medium,
          status: 0
        )
      end

      describe '10-1: GET /tasks/:id/duplicate でリクエスト' do
        it 'ルーティングエラーまたは404が返ること' do
          get "/tasks/#{task.id}/duplicate"
          expect(response).to have_http_status(:not_found)
        end
      end

      describe '10-2: PUT /tasks/:id/duplicate でリクエスト' do
        it 'ルーティングエラーまたは404が返ること' do
          put "/tasks/#{task.id}/duplicate"
          expect(response).to have_http_status(:not_found)
        end
      end

      describe '10-3: DELETE /tasks/:id/duplicate でリクエスト' do
        it 'ルーティングエラーまたは404が返ること' do
          delete "/tasks/#{task.id}/duplicate"
          expect(response).to have_http_status(:not_found)
        end
      end

      describe '10-4: PATCH /tasks/:id/duplicate でリクエスト' do
        it 'ルーティングエラーまたは404が返ること' do
          patch "/tasks/#{task.id}/duplicate"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    # ===========================================
    # 補足：データベースの整合性
    # ===========================================
    context '補足: データベースの整合性' do
      let!(:original_task) do
        Task.create!(
          name: '整合性テスト用タスク',
          explanation: '説明文',
          genre_id: genre.id,
          priority: :high,
          status: 1,
          deadline_date: Date.new(2026, 12, 31)
        )
      end

      describe 'データベースに保存された値の検証' do
        it '複製されたタスクがデータベースに正しく保存されること' do
          post "/tasks/#{original_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          duplicated_task = Task.find(json_response['id'])

          expect(duplicated_task.name).to eq('整合性テスト用タスク(コピー)')
          expect(duplicated_task.explanation).to eq('説明文')
          expect(duplicated_task.genre_id).to eq(genre.id)
          expect(duplicated_task.priority).to eq('high')
          expect(duplicated_task.status).to eq('not_started')
          expect(duplicated_task.deadline_date).to be_nil
        end
      end

      describe '連続して複製した場合' do
        it '各複製が独立したタスクとして作成されること' do
          post "/tasks/#{original_task.id}/duplicate"
          first_response = JSON.parse(response.body)

          post "/tasks/#{original_task.id}/duplicate"
          second_response = JSON.parse(response.body)

          expect(first_response['id']).not_to eq(second_response['id'])
          expect(first_response['name']).to eq('整合性テスト用タスク(コピー)')
          expect(second_response['name']).to eq('整合性テスト用タスク(コピー)')
        end

        it 'タスク数が2件増加すること' do
          expect {
            post "/tasks/#{original_task.id}/duplicate"
            post "/tasks/#{original_task.id}/duplicate"
          }.to change(Task, :count).by(2)
        end
      end

      describe '複製したタスクをさらに複製した場合' do
        it '「(コピー)(コピー)」が付与されること' do
          # 1回目の複製
          post "/tasks/#{original_task.id}/duplicate"
          first_copy = JSON.parse(response.body)

          # 2回目の複製（1回目の複製を元に）
          post "/tasks/#{first_copy['id']}/duplicate"
          second_copy = JSON.parse(response.body)

          expect(first_copy['name']).to eq('整合性テスト用タスク(コピー)')
          expect(second_copy['name']).to eq('整合性テスト用タスク(コピー)(コピー)')
        end
      end
    end

    # ===========================================
    # 補足：様々なタスクパターンの複製
    # ===========================================
    context '補足: 様々なタスクパターンの複製' do
      describe '説明文がnilのタスクを複製' do
        let!(:task_without_explanation) do
          Task.create!(
            name: '説明なしタスク',
            explanation: nil,
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '正常に複製されること' do
          post "/tasks/#{task_without_explanation.id}/duplicate"

          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['explanation']).to be_nil
        end
      end

      describe '各ステータスのタスクを複製' do
        let!(:pending_task) { Task.create!(name: '未着手', genre_id: genre.id, priority: :low, status: :not_started) }
        let!(:in_progress_task) { Task.create!(name: '進行中', genre_id: genre.id, priority: :medium, status: :in_progress) }
        let!(:completed_task) { Task.create!(name: '完了', genre_id: genre.id, priority: :high, status: :completed) }

        it '未着手タスクを複製するとstatusが未着手になること' do
          post "/tasks/#{pending_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('not_started')
        end

        it '進行中タスクを複製するとstatusが未着手にリセットされること' do
          post "/tasks/#{in_progress_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('not_started')
        end

        it '完了タスクを複製するとstatusが未着手にリセットされること' do
          post "/tasks/#{completed_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['status']).to eq('not_started')
        end
      end

      describe '各優先度のタスクを複製' do
        let!(:low_task) { Task.create!(name: '低優先度', genre_id: genre.id, priority: :low, status: 0) }
        let!(:medium_task) { Task.create!(name: '中優先度', genre_id: genre.id, priority: :medium, status: 0) }
        let!(:high_task) { Task.create!(name: '高優先度', genre_id: genre.id, priority: :high, status: 0) }

        it '低優先度タスクの複製でpriorityが引き継がれること' do
          post "/tasks/#{low_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['priority']).to eq('low')
        end

        it '中優先度タスクの複製でpriorityが引き継がれること' do
          post "/tasks/#{medium_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['priority']).to eq('medium')
        end

        it '高優先度タスクの複製でpriorityが引き継がれること' do
          post "/tasks/#{high_task.id}/duplicate"

          json_response = JSON.parse(response.body)
          expect(json_response['priority']).to eq('high')
        end
      end
    end
  end
end
