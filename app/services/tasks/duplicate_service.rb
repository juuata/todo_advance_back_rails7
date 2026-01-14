# frozen_string_literal: true

module Tasks
  class DuplicateService
    # コピーする属性
    COPY_ATTRIBUTES = %i[name explanation genre_id priority].freeze

    # 名前に付与するサフィックス
    COPY_SUFFIX = '(コピー)'

    # 変換ルール
    TRANSFORM_RULES = {
      name: ->(value) { "#{value}#{COPY_SUFFIX}" }
    }.freeze

    # 強制的に設定する値
    FORCED_VALUES = {
      status: :not_started,
      deadline_date: nil
    }.freeze

    def initialize(task)
      @task = task
    end

    def call
      duplicated_task = Task.new(build_attributes)

      if duplicated_task.save
        ServiceResult.success(duplicated_task)
      else
        ServiceResult.failure(duplicated_task.errors)
      end
    end

    private

    def build_attributes
      copied = copy_attributes
      apply_transform_rules(copied)
      apply_forced_values(copied)
      copied
    end

    def copy_attributes
      @task.attributes.slice(*COPY_ATTRIBUTES.map(&:to_s)).symbolize_keys
    end

    def apply_transform_rules(attributes)
      TRANSFORM_RULES.each do |attr, transformer|
        attributes[attr] = transformer.call(attributes[attr]) if attributes.key?(attr)
      end
    end

    def apply_forced_values(attributes)
      attributes.merge!(FORCED_VALUES)
    end
  end
end
