class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[edit update destroy]

  def index
    scope = current_user.time_entries.includes(project: :client).recent
    scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
    @pagy, @time_entries = pagy(scope)
    @total_hours    = scope.sum(:hours)
    @billable_hours = scope.where(billable: true).sum(:hours)
  end

  def new
    @time_entry = current_user.time_entries.new(date: Date.current, project_id: params[:project_id])
  end

  def edit; end

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)
    if @time_entry.save
      redirect_to time_entries_path, notice: "Logged #{@time_entry.hours}h."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @time_entry.update(time_entry_params)
      redirect_to time_entries_path, notice: "Time entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry.destroy
    redirect_to time_entries_path, notice: "Time entry deleted.", status: :see_other
  end

  private

  def set_time_entry
    @time_entry = current_user.time_entries.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:description, :hours, :date, :billable, :project_id)
  end
end
