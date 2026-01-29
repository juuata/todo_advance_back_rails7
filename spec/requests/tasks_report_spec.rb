# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks Report API', type: :request do
  let!(:genre) { Genre.create!(name: 'テストジャンル') }

  describe 'GET /tasks/report' do
    context 'タスクが存在しない場合' do
      before { get '/tasks/report' }

      it 'HTTPステータス200を返すこと' do
        expect(response).to have_http_status(:ok)
      end

      it 'JSONレスポンスを返すこと' do
        expect(response.content_type).to include('application/json')
      end

      it '正しいレスポンス形式であること' do
        json = response.parsed_body
        expect(json).to include(
          'totalCount' => 0,
          'countByStatus' => {
            'notStarted' => 0,
            'inProgress' => 0,
            'completed' => 0
          },
          'completionRate' => 0.0
        )
      end
    end

    context 'タスクが存在する場合' do
      before do
        # not_started: 3件, in_progress: 4件, completed: 3件 = 合計10件
        3.times { Task.create!(name: '未着手', genre: genre, status: :not_started, priority: :medium) }
        4.times { Task.create!(name: '進行中', genre: genre, status: :in_progress, priority: :medium) }
        3.times { Task.create!(name: '完了', genre: genre, status: :completed, priority: :medium) }
        get '/tasks/report'
      end

      it 'HTTPステータス200を返すこと' do
        expect(response).to have_http_status(:ok)
      end

      it '正しいtotalCountを返すこと' do
        json = response.parsed_body
        expect(json['totalCount']).to eq(10)
      end

      it '正しいcountByStatusを返すこと' do
        json = response.parsed_body
        expect(json['countByStatus']).to eq({
          'notStarted' => 3,
          'inProgress' => 4,
          'completed' => 3
        })
      end

      it '正しいcompletionRateを返すこと' do
        json = response.parsed_body
        # 3 / 10 * 100 = 30.0
        expect(json['completionRate']).to eq(30.0)
      end
    end

    context 'completionRateの小数点処理' do
      before do
        # 3件中1件完了 = 33.333...%
        Task.create!(name: '完了', genre: genre, status: :completed, priority: :medium)
        2.times { Task.create!(name: '未着手', genre: genre, status: :not_started, priority: :medium) }
        get '/tasks/report'
      end

      it '小数点以下1桁に丸められること' do
        json = response.parsed_body
        expect(json['completionRate']).to eq(33.3)
      end
    end
  end
end
