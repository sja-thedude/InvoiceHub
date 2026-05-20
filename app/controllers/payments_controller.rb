class PaymentsController < ApplicationController
  before_action :set_invoice, only: %i[new create]

  def new
    @payment = @invoice.payments.new(amount: @invoice.balance_due, payment_date: Date.current)
  end

  def create
    @payment = @invoice.payments.new(payment_params)
    if @payment.save
      redirect_to @invoice, notice: "Payment of #{@payment.amount} recorded."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @payment = Payment.joins(:invoice).where(invoices: { user_id: current_user.id }).find(params[:id])
    invoice = @payment.invoice
    @payment.destroy
    redirect_to invoice, notice: "Payment removed.", status: :see_other
  end

  private

  def set_invoice
    @invoice = current_user.invoices.find(params[:invoice_id])
  end

  def payment_params
    params.require(:payment).permit(:amount, :payment_date, :payment_method, :reference, :notes)
  end
end
