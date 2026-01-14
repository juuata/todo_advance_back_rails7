require 'rails_helper'

RSpec.describe Tasks::CreateService do
  let!(:genre) { Genre.create!(name: 'テストジャンル') }

  describe '#call' do
    context '正常系: 全パラメータが揃っている場合' do
      let(:params) do
        ActionController::Parameters.new(
          name: 'タスク名',
          explanation: 'タスク説明',
          status: 'pending',
          priority: 'high',
          genreId: genre.id,
          deadlineDate: '2026-01-10'
        )
      end

      it 'Taskが作成されること' do
        expect {
          described_class.new(params).call
        }.to change(Task, :count).by(1)
      end

      it '正しい属性でTaskが作成されること' do
        result = described_class.new(params).call
        task = result.data

        expect(task.name).to eq('タスク名')
        expect(task.explanation).to eq('タスク説明')
        expect(task.status).to eq('pending')
        expect(task.priority).to eq('high')
        expect(task.genre_id).to eq(genre.id)
        expect(task.deadline_date).to eq(Date.parse('2026-01-10'))
      end

      it 'ServiceResult.successを返すこと' do
        result = described_class.new(params).call

        expect(result).to be_a(ServiceResult)
        expect(result.success?).to be true
        expect(result.data).to be_a(Task)
      end
    end

    context '正常系: priorityパラメータが欠けている場合' do
      let(:params) do
        ActionController::Parameters.new(
          name: 'タスク名',
          genreId: genre.id
        )
      end

      it 'デフォルト値mediumでTaskが作成されること' do
        result = described_class.new(params).call
        task = result.data

        expect(task.priority).to eq('medium')
      end
    end

    context '正常系: 一部パラメータが欠けている場合' do
      let(:params) do
        ActionController::Parameters.new(
          name: 'タスク名',
          genreId: genre.id
        )
      end

      it 'Taskが作成されること' do
        expect {
          described_class.new(params).call
        }.to change(Task, :count).by(1)
      end

      it '存在するパラメータのみが保存されること' do
        result = described_class.new(params).call
        task = result.data

        expect(task.name).to eq('タスク名')
        expect(task.genre_id).to eq(genre.id)
        expect(task.explanation).to be_nil
        expect(task.status).to be_nil
      end
    end

    context '正常系: キャメルケースパラメータが正しく変換される' do
      let(:params) do
        ActionController::Parameters.new(
          name: 'タスク名',
          genreId: genre.id,
          deadlineDate: '2026-01-15'
        )
      end

      it 'genreId -> genre_id に変換されること' do
        result = described_class.new(params).call
        task = result.data

        expect(task.genre_id).to eq(genre.id)
      end

      it 'deadlineDate -> deadline_date に変換されること' do
        result = described_class.new(params).call
        task = result.data

        expect(task.deadline_date).to eq(Date.parse('2026-01-15'))
      end
    end

    context '異常系: バリデーションエラーの場合（nameが空）' do
      let(:params) do
        ActionController::Parameters.new(
          genreId: genre.id
        )
      end

      it 'Taskが作成されないこと' do
        expect {
          described_class.new(params).call
        }.not_to change(Task, :count)
      end

      it 'ServiceResult.failureを返すこと' do
        result = described_class.new(params).call

        expect(result).to be_a(ServiceResult)
        expect(result.failure?).to be true
        expect(result.errors).to be_present
      end
    end

    context '異常系: genre_idが存在しない場合' do
      let(:params) do
        ActionController::Parameters.new(
          name: 'タスク名',
          genreId: 99999
        )
      end

      it 'Taskが作成されないこと' do
        expect {
          described_class.new(params).call
        }.not_to change(Task, :count)
      end

      it 'ServiceResult.failureを返すこと' do
        result = described_class.new(params).call

        expect(result).to be_a(ServiceResult)
        expect(result.failure?).to be true
      end
    end
  end
end
