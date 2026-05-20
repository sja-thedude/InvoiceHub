class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update destroy pdf mark_sent send_email duplicate import_time]

  def index
    scope = current_user.invoices.includes(:client, :project).recent
    scope = scope.where(status: params[:status]) if params[:status].present? && Invoice.statuses.key?(params[:status])
    scope = scope.where(client_id: params[:client_id]) if params[:client_id].present?
    refresh_overdue(scope)
    @pagy, @invoices = pagy(scope)
  end

  def show
    @invoice.refresh_payment_status! if @invoice.overdue_by_date? && !@invoice.overdue?
  end

  def new
    @invoice = current_user.invoices.new(client_id: params[:client_id], project_id: params[:project_id])
    @invoice.invoice_items.build if @invoice.invoice_items.empty?
    3.times { @invoice.invoice_items.build }
  end

  def edit
    @invoice.invoice_items.build if @invoice.invoice_items.empty?
  end

  def create
    @invoice = current_user.invoices.new(invoice_params)
    if @invoice.save
      redirect_to @invoice, notice: "Invoice #{@invoice.invoice_number} was created."
    else
      @invoice.invoice_items.build if @invoice.invoice_items.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Invoice was updated."
    else
      @invoice.invoice_items.build if @invoice.invoice_items.empty?
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.destroy
    redirect_to invoices_path, notice: "Invoice was deleted.", status: :see_other
  end

  # GET /invoices/:id/pdf
  def pdf
    pdf = InvoicePdf.new(@invoice).render
    send_data pdf,
              filename: "#{@invoice.invoice_number}.pdf",
              type: "application/pdf",
              disposition: params[:download] ? "attachment" : "inline"
  end

  def mark_sent
    @invoice.mark_sent!
    redirect_back fallback_location: @invoice, notice: "Invoice marked as sent."
  end

  # POST /invoices/:id/send_email
  def send_email
    InvoiceMailer.invoice_email(@invoice).deliver_later
    @invoice.mark_sent!
    redirect_to @invoice, notice: "Invoice emailed to #{@invoice.client.email.presence || 'the client'}."
  end

  def duplicate
    copy = @invoice.build_recurrence
    copy.parent_invoice = nil
    copy.save!
    redirect_to edit_invoice_path(copy), notice: "Invoice duplicated as a new draft."
  end

  # POST /invoices/:id/import_time — pulls unbilled time entries into line items.
  def import_time
    entries = @invoice.project ? @invoice.project.time_entries.unbilled : TimeEntry.none
    if entries.any?
      entries.find_each do |entry|
        @invoice.invoice_items.create!(
          description: "#{entry.date.strftime('%b %-d')} — #{entry.description}",
          quantity: entry.hours,
          unit_price: entry.project.hourly_rate
        )
        entry.update!(invoiced: true)
      end
      @invoice.save!
      redirect_to edit_invoice_path(@invoice), notice: "Imported #{entries.size} time entries as line items."
    else
      redirect_to edit_invoice_path(@invoice), alert: "No unbilled time entries to import for this project."
    end
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find(params[:id])
  end

  def refresh_overdue(scope)
    scope.unpaid.where("due_date < ?", Date.current).find_each do |inv|
      inv.refresh_payment_status!
    end
  end

  def invoice_params
    params.require(:invoice).permit(
      :client_id, :project_id, :status, :issue_date, :due_date, :notes, :terms,
      :currency, :tax_rate, :discount, :recurring, :recurring_interval, :recurring_next_run,
      invoice_items_attributes: %i[id description quantity unit_price position _destroy]
    )
  end
end
