# Creates Stripe Checkout sessions for paying an invoice online.
class CheckoutsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :create

  def create
    @invoice = Invoice.find_by!(public_token: params[:token])

    unless Stripe.configured?
      redirect_to public_invoice_path(@invoice.public_token),
                  alert: "Online payments are not configured for this account."
      return
    end

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: [{
        quantity: 1,
        price_data: {
          currency: @invoice.currency.downcase,
          unit_amount: (@invoice.balance_due * 100).to_i,
          product_data: { name: "Invoice #{@invoice.invoice_number}" }
        }
      }],
      success_url: success_checkouts_url(token: @invoice.public_token),
      cancel_url: cancel_checkouts_url(token: @invoice.public_token),
      metadata: { invoice_id: @invoice.id, public_token: @invoice.public_token }
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def success
    @invoice = Invoice.find_by!(public_token: params[:token])
    render "public_invoices/paid", layout: "marketing"
  end

  def cancel
    @invoice = Invoice.find_by!(public_token: params[:token])
    redirect_to public_invoice_path(@invoice.public_token), alert: "Payment was canceled."
  end
end
