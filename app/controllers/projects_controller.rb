class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    scope = current_user.projects.includes(:client).recent
    scope = scope.where(status: params[:status]) if params[:status].present? && Project.statuses.key?(params[:status])
    @pagy, @projects = pagy(scope)
  end

  def show
    @invoices     = @project.invoices.recent
    @time_entries = @project.time_entries.recent.limit(10)
    @expenses     = @project.expenses.recent.limit(10)
  end

  def new
    @project = current_user.projects.new(client_id: params[:client_id])
  end

  def edit; end

  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Project was deleted.", status: :see_other
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :hourly_rate, :budget, :status, :currency, :client_id)
  end
end
