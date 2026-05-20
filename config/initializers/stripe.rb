# Stripe configuration. Set the keys via environment variables / Rails credentials.
# In development the app works fully without Stripe keys — online payment buttons
# simply fall back to manual payment recording when no key is present.
Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"],
  secret_key:      ENV["STRIPE_SECRET_KEY"],
  webhook_secret:  ENV["STRIPE_WEBHOOK_SECRET"]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key] if Rails.configuration.stripe[:secret_key].present?

def Stripe.configured?
  Rails.configuration.stripe[:secret_key].present?
end
