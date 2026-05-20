class ReportsController < ApplicationController
  def index; end

  # Revenue by month (collected payments) for the selected year.
  def revenue
    @year = (params[:year] || Date.current.year).to_i
    payments = current_user.payments.where(payment_date: Date.new(@year).all_year)
    @by_month = payments.group_by_month(:payment_date, format: "%b").sum(:amount)
    @total = payments.sum(:amount)
    @invoiced = current_user.invoices.for_year(@year).where.not(status: :draft).sum(:total)
    @years = available_years
  end

  # Revenue grouped by client.
  def clients
    @rows = current_user.clients.alphabetical.map do |client|
      { client: client, billed: client.total_billed, paid: client.total_paid, outstanding: client.outstanding }
    end.sort_by { |r| -r[:paid] }
    @chart = @rows.first(10).to_h { |r| [r[:client].name, r[:paid]] }
    @total_paid = @rows.sum { |r| r[:paid] }
  end

  # Project profitability: revenue minus expenses.
  def profitability
    @rows = current_user.projects.includes(:client).map do |project|
      {
        project: project, revenue: project.total_revenue,
        expenses: project.total_expenses, profit: project.profit,
        hours: project.total_hours
      }
    end.sort_by { |r| -r[:profit] }
    @chart = @rows.first(10).to_h { |r| [r[:project].name, r[:profit]] }
  end

  # Tax summary for accounting.
  def tax
    @year = (params[:year] || Date.current.year).to_i
    @invoices = current_user.invoices.for_year(@year).where.not(status: :draft).order(:issue_date)
    @tax_collected = @invoices.sum(&:tax_amount)
    @net_revenue = @invoices.sum(:subtotal)
    @gross_revenue = @invoices.sum(:total)
    @expenses_total = current_user.expenses.for_year(@year).sum(:amount)
    @quarters = @invoices.group_by { |i| "Q#{((i.issue_date.month - 1) / 3) + 1}" }
                         .transform_values { |invs| invs.sum(&:tax_amount) }
    @years = available_years
  end

  private

  def available_years
    years = current_user.invoices.pluck(Arel.sql("EXTRACT(YEAR FROM issue_date)::int")).uniq
    (years << Date.current.year).compact.uniq.sort.reverse
  end
end
