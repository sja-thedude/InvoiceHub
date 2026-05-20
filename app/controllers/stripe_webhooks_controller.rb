# Receives Stripe webhook events and records payments automatically.
class StripeWebhooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    secret  = Rails.configuration.stripe[:webhook_secret]

    event =
      if secret.present?
        begin
          Stripe::Webhook.construct_event(payload, request.env["HTTP_STRIPE_SIGNATURE"], secret)
        rescue Stripe::SignatureVerificationError
          return head :bad_request
        end
      else
        Stripe::Event.construct_from(JSON.parse(payload, symbolize_names: true))
      end

    if event.type == "checkout.session.completed"
      session = event.data.object
      record_payment(session)
    end

    head :ok
  rescue JSON::ParserError
    head :bad_request
  end

  private

  def record_payment(session)
    invoice = Invoice.find_by(id: session.dig(:metadata, :invoice_id))
    return unless invoice

    invoice.payments.create!(
      amount: session[:amount_total].to_i / 100.0,
      payment_date: Date.current,
      payment_method: :stripe,
      reference: session[:payment_intent],
      stripe_payment_intent_id: session[:payment_intent]
    )
  end
end
