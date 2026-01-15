# frozen_string_literal: true

module Tasks
  class ReportService
    def call
      total_count = Task.count
      count_by_status = {
        not_started: Task.not_started.count,
        in_progress: Task.in_progress.count,
        completed: Task.completed.count
      }
      completed_count = count_by_status[:completed]
      completion_rate = calculate_completion_rate(completed_count, total_count)

      ServiceResult.success({
        total_count: total_count,
        count_by_status: count_by_status,
        completion_rate: completion_rate
      })
    end

    private

    def calculate_completion_rate(completed_count, total_count)
      return 0.0 if total_count.zero?

      (completed_count.to_f / total_count * 100).round(1)
    end
  end
end
