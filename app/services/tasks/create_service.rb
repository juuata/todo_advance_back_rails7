# frozen_string_literal: true

module Tasks
  class CreateService
    def initialize(params)
      @params = params
    end

    def call
      task = Task.new(normalized_params)

      if task.save
        ServiceResult.success(task)
      else
        ServiceResult.failure(task.errors)
      end
    end

    private

    def normalized_params
      {
        name: @params[:name],
        explanation: @params[:explanation],
        status: @params[:status],
        priority: @params[:priority],
        genre_id: @params[:genreId],
        deadline_date: @params[:deadlineDate]
      }.compact
    end
  end
end
