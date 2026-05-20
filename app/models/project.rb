class Project < ApplicationRecord
  belongs_to :client
  belongs_to :user

  has_many :invoices,     dependent: :nullify
  has_many :expenses,     dependent: :nullify
  has_many :time_entries, dependent: :destroy

  enum :status, { active: 0, completed: 1, archived: 2 }

  validates :name, presence: true
  validates :hourly_rate, :budget, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(created_at: :desc) }

  STATUS_COLORS = {
    "active"    => "bg-emerald-100 text-emerald-700",
    "completed" => "bg-blue-100 text-blue-700",
    "archived"  => "bg-gray-100 text-gray-600"
  }.freeze

  def status_color
    STATUS_COLORS[status]
  end

  # --- Profitability ---
  def total_revenue
    invoices.paid.sum(:total)
  end

  def total_billed
    invoices.where.not(status: :draft).sum(:total)
  end

  def total_expenses
    expenses.sum(:amount)
  end

  def profit
    total_revenue - total_expenses
  end

  def total_hours
    time_entries.sum(:hours)
  end

  def billable_hours
    time_entries.where(billable: true).sum(:hours)
  end

  def unbilled_hours
    time_entries.where(billable: true, invoiced: false).sum(:hours)
  end

  def budget_used_percent
    return 0 if budget.to_d.zero?

    ((total_billed / budget) * 100).round
  end
end
