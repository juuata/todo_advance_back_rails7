# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::ReportService do
  let!(:genre) { Genre.create!(name: 'テストジャンル') }

  describe '#call' do
    subject(:result) { described_class.new.call }

    context 'タスクが存在しない場合' do
      it 'ServiceResult.successを返すこと' do
        expect(result).to be_a(ServiceResult)
        expect(result.success?).to be true
      end

      it 'totalCountが0であること' do
        expect(result.data[:total_count]).to eq(0)
      end

      it 'countByStatusが全て0であること' do
        expect(result.data[:count_by_status]).to eq({
          not_started: 0,
          in_progress: 0,
          completed: 0
        })
      end

      it 'completionRateが0.0であること' do
        expect(result.data[:completion_rate]).to eq(0.0)
      end
    end

    context 'タスクが存在する場合' do
      before do
        # not_started: 3件
        3.times { Task.create!(name: '未着手タスク', genre: genre, status: :not_started, priority: :medium) }
        # in_progress: 2件
        2.times { Task.create!(name: '進行中タスク', genre: genre, status: :in_progress, priority: :medium) }
        # completed: 5件
        5.times { Task.create!(name: '完了タスク', genre: genre, status: :completed, priority: :medium) }
      end

      it 'ServiceResult.successを返すこと' do
        expect(result.success?).to be true
      end

      it 'totalCountが正しいこと' do
        expect(result.data[:total_count]).to eq(10)
      end

      it 'countByStatusが正しいこと' do
        expect(result.data[:count_by_status]).to eq({
          not_started: 3,
          in_progress: 2,
          completed: 5
        })
      end

      it 'completionRateが正しいこと（小数点以下1桁）' do
        # 5 / 10 * 100 = 50.0
        expect(result.data[:completion_rate]).to eq(50.0)
      end
    end

    context '完了率の小数点処理' do
      before do
        # 3件中1件完了 = 33.333...%
        Task.create!(name: '完了タスク', genre: genre, status: :completed, priority: :medium)
        Task.create!(name: '未着手タスク1', genre: genre, status: :not_started, priority: :medium)
        Task.create!(name: '未着手タスク2', genre: genre, status: :not_started, priority: :medium)
      end

      it '小数点以下1桁に丸められること' do
        # 1 / 3 * 100 = 33.333... -> 33.3
        expect(result.data[:completion_rate]).to eq(33.3)
      end
    end
  end
end
