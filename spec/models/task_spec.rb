require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:genre) { Genre.create!(name: 'テストジャンル') }

  describe '優先度（priority）' do
    context 'バリデーション' do
      it '優先度が「低」「中」「高」のいずれかであること' do
        # 優先度が「低」の場合
        task_low = Task.new(name: 'タスク1', genre: genre, priority: :low)
        expect(task_low).to be_valid

        # 優先度が「中」の場合
        task_medium = Task.new(name: 'タスク2', genre: genre, priority: :medium)
        expect(task_medium).to be_valid

        # 優先度が「高」の場合
        task_high = Task.new(name: 'タスク3', genre: genre, priority: :high)
        expect(task_high).to be_valid
      end

      it '不正な優先度を設定しようとするとエラーになること' do
        expect {
          Task.new(name: 'タスク', genre: genre, priority: :invalid)
        }.to raise_error(ArgumentError)
      end
    end

    context 'デフォルト値' do
      it '新規タスク作成時に、優先度のデフォルト値が「中」であること' do
        task = Task.new(name: 'タスク', genre: genre)
        expect(task.priority).to eq('medium')
      end

      it 'DB保存後も優先度のデフォルト値が「中」であること' do
        task = Task.create!(name: 'タスク', genre: genre)
        expect(task.priority).to eq('medium')
        expect(task.reload.priority).to eq('medium')
      end
    end

    context 'enumメソッド' do
      let(:task) { Task.create!(name: 'タスク', genre: genre) }

      it 'low!で優先度を「低」に変更できること' do
        task.low!
        expect(task.priority).to eq('low')
        expect(task.low?).to be true
      end

      it 'medium!で優先度を「中」に変更できること' do
        task.medium!
        expect(task.priority).to eq('medium')
        expect(task.medium?).to be true
      end

      it 'high!で優先度を「高」に変更できること' do
        task.high!
        expect(task.priority).to eq('high')
        expect(task.high?).to be true
      end
    end
  end
end
