class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[show edit update destroy]

  def index
    scope = current_user.expenses.includes(:project).recent
    scope = scope.where(category: params[:category]) if params[:category].present? && Expense.categories.key?(params[:category])
    @pagy, @expenses = pagy(scope)
    @total = scope.sum(:amount)
    @by_category = current_user.expenses.group(:category).sum(:amount)
                               .transform_keys { |k| Expense.categories.key(k) || k }
  end

  def show; end

  def new
    @expense = current_user.expenses.new(date: Date.current, project_id: params[:project_id])
  end

  def edit; end

  def create
    @expense = current_user.expenses.new(expense_params)
    if @expense.save
      redirect_to expenses_path, notice: "Expense was recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: "Expense was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    redirect_to expenses_path, notice: "Expense was deleted.", status: :see_other
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :category, :date, :currency, :billable, :project_id, :receipt)
  end
end
