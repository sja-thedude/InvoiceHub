# Public, token-addressable invoice view used for the "Pay online" link.
class PublicInvoicesController < ApplicationController
  skip_before_action :authenticate_user!
  layout "marketing"

  def show
    @invoice = Invoice.includes(:invoice_items, :user, :client).find_by!(public_token: params[:token])
    @user = @invoice.user
    @stripe_enabled = Stripe.configured?
  end
end
