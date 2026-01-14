class TasksController < ApplicationController
  before_action :select_task, only: [:update, :destroy, :update_status]
  skip_before_action :verify_authenticity_token

  def index
    tasks_all
  end

  def create
    Tasks::CreateService.new(params).call
    tasks_all
  end

  def update
    @task.update(task_params)
    tasks_all
  end

  def destroy
    @task.destroy
    tasks_all
  end

  def update_status
    @task.update(status: params[:status])
    tasks_all
  end

  def duplicate
    task = Task.find(params[:id])
    result = Tasks::DuplicateService.new(task).call

    if result.success?
      render json: task_json(result.data), status: :created
    else
      render json: { errors: result.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Task not found' }, status: :not_found
  end

  private

  def task_json(task)
    {
      id: task.id,
      name: task.name,
      explanation: task.explanation,
      status: task.status,
      priority: task.priority,
      genre_id: task.genre_id,
      deadline_date: task.deadline_date,
      created_at: task.created_at,
      updated_at: task.updated_at
    }
  end

  def task_params
    permitted = params.permit(:name, :explanation, :status, :priority)
    permitted[:genre_id] = params[:genreId] if params[:genreId].present?
    permitted[:deadline_date] = params[:deadlineDate] if params[:deadlineDate].present?
    permitted
  end

  def select_task
    @task = Task.find(params[:id])
  end

  def tasks_all
    @tasks = Task.includes(:genre).all
    render :all_tasks
  end
end
