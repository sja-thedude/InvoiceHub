class DashboardController < ApplicationController
  def index
    @invoices = current_user.invoices
    @currency = current_user.default_currency

    @total_revenue      = current_user.total_revenue
    @outstanding_amount = current_user.outstanding_amount
    @overdue_amount     = current_user.overdue_amount
    @draft_count        = @invoices.draft.count

    @clients_count  = current_user.clients.count
    @projects_count = current_user.projects.active.count

    # Revenue collected per month (last 12 months) from recorded payments.
    @monthly_revenue = current_user.payments
                                   .where("payment_date >= ?", 11.months.ago.beginning_of_month)
                                   .group_by_month(:payment_date, format: "%b %Y", last: 12)
                                   .sum(:amount)

    # Invoice status breakdown for the donut chart.
    @status_breakdown = @invoices.group(:status).count
                                 .transform_keys { |k| Invoice.statuses.key(k) || k }

    @recent_invoices = @invoices.includes(:client).recent.limit(6)
    @recent_payments = current_user.payments.includes(invoice: :client).recent.limit(6)
    @overdue_invoices = @invoices.includes(:client).overdue.recent.limit(5)
    @top_clients = current_user.clients.includes(:invoices)
                               .sort_by { |c| -c.total_billed }.first(5)
  end
end
