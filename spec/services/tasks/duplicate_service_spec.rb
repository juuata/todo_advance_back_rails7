# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::DuplicateService do
  let!(:genre) { Genre.create!(name: 'テストジャンル') }
  let!(:other_genre) { Genre.create!(name: '別のジャンル') }

  describe '#call' do
    # ===========================================
    # 1. 正常系：属性の引き継ぎ
    # ===========================================
    context '1. 正常系: 属性の引き継ぎ' do
      let!(:original_task) do
        Task.create!(
          name: '買い物',
          explanation: 'スーパーで食材を買う',
          genre_id: genre.id,
          priority: :high,
          status: 0,
          deadline_date: Date.new(2026, 1, 31)
        )
      end

      describe '1-1: nameが正しく引き継がれ、末尾に「(コピー)」が付与される' do
        it '元のnameに「(コピー)」が付与されること' do
          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.name).to eq('買い物(コピー)')
        end
      end

      describe '1-2: explanationがそのまま引き継がれる' do
        it '元と同じexplanationが設定されること' do
          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.explanation).to eq('スーパーで食材を買う')
        end
      end

      describe '1-3: genre_idがそのまま引き継がれる' do
        it '元と同じgenre_idが設定されること' do
          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.genre_id).to eq(genre.id)
        end
      end

      describe '1-4: priorityがそのまま引き継がれる' do
        it '元と同じpriority値が設定されること' do
          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.priority).to eq('high')
        end

        context '異なるpriority値の場合' do
          let!(:low_priority_task) do
            Task.create!(
              name: '低優先度タスク',
              genre_id: genre.id,
              priority: :low,
              status: 0
            )
          end

          let!(:medium_priority_task) do
            Task.create!(
              name: '中優先度タスク',
              genre_id: genre.id,
              priority: :medium,
              status: 0
            )
          end

          it 'lowのpriorityが引き継がれること' do
            result = described_class.new(low_priority_task).call
            expect(result.data.priority).to eq('low')
          end

          it 'mediumのpriorityが引き継がれること' do
            result = described_class.new(medium_priority_task).call
            expect(result.data.priority).to eq('medium')
          end
        end
      end
    end

    # ===========================================
    # 2. 正常系：特別な処理
    # ===========================================
    context '2. 正常系: 特別な処理' do
      describe '2-1: statusが「未着手」にリセットされる（元が未着手の場合）' do
        let!(:pending_task) do
          Task.create!(
            name: '未着手タスク',
            genre_id: genre.id,
            priority: :medium,
            status: :not_started
          )
        end

        it 'statusが初期値（未着手）になること' do
          result = described_class.new(pending_task).call
          duplicated_task = result.data

          expect(duplicated_task.status).to eq('not_started')
        end
      end

      describe '2-2: statusが「未着手」にリセットされる（元が進行中の場合）' do
        let!(:in_progress_task) do
          Task.create!(
            name: '進行中タスク',
            genre_id: genre.id,
            priority: :medium,
            status: :in_progress
          )
        end

        it 'statusが初期値（未着手）にリセットされること' do
          result = described_class.new(in_progress_task).call
          duplicated_task = result.data

          expect(duplicated_task.status).to eq('not_started')
        end
      end

      describe '2-3: statusが「未着手」にリセットされる（元が完了の場合）' do
        let!(:completed_task) do
          Task.create!(
            name: '完了タスク',
            genre_id: genre.id,
            priority: :medium,
            status: :completed
          )
        end

        it 'statusが初期値（未着手）にリセットされること' do
          result = described_class.new(completed_task).call
          duplicated_task = result.data

          expect(duplicated_task.status).to eq('not_started')
        end
      end

      describe '2-4: deadline_dateがnilになる（元に期限が設定されている場合）' do
        let!(:task_with_deadline) do
          Task.create!(
            name: '期限ありタスク',
            genre_id: genre.id,
            priority: :medium,
            status: 0,
            deadline_date: Date.new(2026, 12, 31)
          )
        end

        it 'deadline_dateがnilになること' do
          result = described_class.new(task_with_deadline).call
          duplicated_task = result.data

          expect(duplicated_task.deadline_date).to be_nil
        end
      end

      describe '2-5: deadline_dateがnilになる（元の期限がnilの場合）' do
        let!(:task_without_deadline) do
          Task.create!(
            name: '期限なしタスク',
            genre_id: genre.id,
            priority: :medium,
            status: 0,
            deadline_date: nil
          )
        end

        it 'deadline_dateがnilのままであること' do
          result = described_class.new(task_without_deadline).call
          duplicated_task = result.data

          expect(duplicated_task.deadline_date).to be_nil
        end
      end
    end

    # ===========================================
    # 3. 正常系：エッジケース（name属性）
    # ===========================================
    context '3. 正常系: エッジケース（name属性）' do
      describe '3-1: nameが空文字の場合' do
        let!(:empty_name_task) do
          Task.create!(
            name: '',
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '「(コピー)」のみになること' do
          result = described_class.new(empty_name_task).call
          duplicated_task = result.data

          expect(duplicated_task.name).to eq('(コピー)')
        end
      end

      describe '3-2: nameがすでに「(コピー)」で終わる場合' do
        let!(:already_copied_task) do
          Task.create!(
            name: 'タスク(コピー)',
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '「タスク(コピー)(コピー)」になること' do
          result = described_class.new(already_copied_task).call
          duplicated_task = result.data

          expect(duplicated_task.name).to eq('タスク(コピー)(コピー)')
        end
      end

      describe '3-3: nameに特殊文字が含まれる場合' do
        let!(:special_char_task) do
          Task.create!(
            name: 'タスク<script>alert("XSS")</script>',
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '特殊文字を保持し「(コピー)」が付与されること' do
          result = described_class.new(special_char_task).call
          duplicated_task = result.data

          expect(duplicated_task.name).to eq('タスク<script>alert("XSS")</script>(コピー)')
        end
      end

      describe '3-4: nameに絵文字が含まれる場合' do
        let!(:emoji_task) do
          Task.create!(
            name: '買い物リスト🛒',
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '絵文字を保持し「(コピー)」が付与されること' do
          result = described_class.new(emoji_task).call
          duplicated_task = result.data

          expect(duplicated_task.name).to eq('買い物リスト🛒(コピー)')
        end
      end

      describe '3-5: nameが非常に長い場合' do
        let(:long_name) { 'あ' * 250 }
        let!(:long_name_task) do
          Task.create!(
            name: long_name,
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '「(コピー)」が付与されること' do
          result = described_class.new(long_name_task).call
          duplicated_task = result.data

          expect(duplicated_task.name).to eq("#{long_name}(コピー)")
        end
      end
    end

    # ===========================================
    # 4. 正常系：関連データの扱い
    # ===========================================
    context '4. 正常系: 関連データの扱い' do
      let!(:original_task) do
        Task.create!(
          name: 'オリジナルタスク',
          explanation: '説明文',
          genre_id: genre.id,
          priority: :high,
          status: 1,
          deadline_date: Date.new(2026, 6, 15)
        )
      end

      describe '4-1: 複製されたタスクは新しいIDを持つ' do
        it '元のタスクと異なるIDが割り当てられること' do
          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.id).not_to eq(original_task.id)
          expect(duplicated_task.id).to be_present
        end
      end

      describe '4-2: 複製されたタスクは新しいcreated_atを持つ' do
        it '複製時点のタイムスタンプになること' do
          # 元のタスクのcreated_atを過去に設定
          original_task.update_column(:created_at, 1.day.ago)

          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.created_at).to be > original_task.created_at
          expect(duplicated_task.created_at).to be_within(1.second).of(Time.current)
        end
      end

      describe '4-3: genre_idが存在するジャンルを参照している' do
        it '正しくアソシエーションが設定されること' do
          result = described_class.new(original_task).call
          duplicated_task = result.data

          expect(duplicated_task.genre).to eq(genre)
          expect(duplicated_task.genre.name).to eq('テストジャンル')
        end
      end

      describe '4-4: データベースにタスクが1件増加する' do
        it 'Task.countが+1になること' do
          expect {
            described_class.new(original_task).call
          }.to change(Task, :count).by(1)
        end
      end

      describe '4-5: 元のタスクは変更されない' do
        it '元タスクの属性が変わらないこと' do
          original_attributes = original_task.attributes.except('updated_at')

          described_class.new(original_task).call

          original_task.reload
          expect(original_task.attributes.except('updated_at')).to eq(original_attributes)
        end
      end

      describe '4-6: ServiceResult.successを返す' do
        it 'successなServiceResultを返すこと' do
          result = described_class.new(original_task).call

          expect(result).to be_a(ServiceResult)
          expect(result.success?).to be true
          expect(result.data).to be_a(Task)
          expect(result.data).to be_persisted
        end
      end
    end

    # ===========================================
    # 5. 異常系：バリデーションエラー
    # ===========================================
    context '5. 異常系: バリデーションエラー' do
      describe '5-1: 「(コピー)」付与後にnameが最大文字数を超える場合', skip: 'nameのバリデーションが実装されたら有効化' do
        # nameに最大文字数のバリデーションが設定されている場合のテスト
        let(:max_length_name) { 'あ' * 255 } # 仮に255文字が最大とする
        let!(:max_length_task) do
          Task.create!(
            name: max_length_name,
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it 'バリデーションエラーが発生すること' do
          result = described_class.new(max_length_task).call

          expect(result.success?).to be false
          expect(result.failure?).to be true
          expect(result.errors).to be_present
        end

        it 'データベースにタスクが増えないこと' do
          expect {
            described_class.new(max_length_task).call
          }.not_to change(Task, :count)
        end
      end

      describe '5-2: 複製時にgenre_idが無効（削除済みジャンル）の場合' do
        let!(:task_with_genre) do
          Task.create!(
            name: 'ジャンル付きタスク',
            genre_id: other_genre.id,
            priority: :medium,
            status: 0
          )
        end

        context 'ジャンルが削除された後に複製を試みる場合' do
          before do
            # 外部キー制約を一時的に無効化してジャンルを削除
            ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
            other_genre.delete
            ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
          end

          it '適切なエラーが発生すること' do
            result = described_class.new(task_with_genre).call

            expect(result.success?).to be false
            expect(result.failure?).to be true
          end

          it 'データベースにタスクが増えないこと' do
            expect {
              described_class.new(task_with_genre).call
            }.not_to change(Task, :count)
          end
        end
      end

      describe '5-3: explanationがnilの場合でも正常に複製できる' do
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
          result = described_class.new(task_without_explanation).call

          expect(result.success?).to be true
          expect(result.data.explanation).to be_nil
        end
      end

      describe '5-4: genre_idがnilの場合', skip: 'belongs_to :genreのバリデーションによりnilのタスクは作成できない' do
        let!(:task_without_genre) do
          # genre_idがnilのタスクを作成（外部キー制約を一時的に無効化）
          ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0')
          task = Task.create!(
            name: 'ジャンルなしタスク',
            genre_id: nil,
            priority: :medium,
            status: 0
          )
          ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1')
          task
        end

        it 'genre_idがnilのまま複製されること' do
          result = described_class.new(task_without_genre).call
          duplicated_task = result.data

          expect(duplicated_task.genre_id).to be_nil
        end
      end
    end

    # ===========================================
    # 補足：複合的なテストケース
    # ===========================================
    context '補足: 複合的なテストケース' do
      describe '全ての属性が正しく処理される統合テスト' do
        let!(:complete_task) do
          Task.create!(
            name: '完全なタスク',
            explanation: '詳細な説明文がここに入ります',
            genre_id: genre.id,
            priority: :high,
            status: 2, # 完了
            deadline_date: Date.new(2026, 3, 15)
          )
        end

        it '全ての属性が仕様通りに処理されること' do
          result = described_class.new(complete_task).call
          duplicated_task = result.data

          # 引き継がれる属性
          expect(duplicated_task.name).to eq('完全なタスク(コピー)')
          expect(duplicated_task.explanation).to eq('詳細な説明文がここに入ります')
          expect(duplicated_task.genre_id).to eq(genre.id)
          expect(duplicated_task.priority).to eq('high')

          # リセットされる属性
          expect(duplicated_task.status).to eq('not_started')
          expect(duplicated_task.deadline_date).to be_nil

          # 新しく生成される属性
          expect(duplicated_task.id).not_to eq(complete_task.id)
          expect(duplicated_task.created_at).to be_within(1.second).of(Time.current)
        end
      end

      describe '連続して複製した場合' do
        let!(:original_task) do
          Task.create!(
            name: 'オリジナル',
            genre_id: genre.id,
            priority: :medium,
            status: 0
          )
        end

        it '各複製が独立したタスクとして作成されること' do
          result1 = described_class.new(original_task).call
          result2 = described_class.new(original_task).call

          expect(result1.data.id).not_to eq(result2.data.id)
          expect(result1.data.name).to eq('オリジナル(コピー)')
          expect(result2.data.name).to eq('オリジナル(コピー)')
        end
      end
    end
  end
end
