class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  layout :layout_by_resource

  protected

  def layout_by_resource
    devise_controller? ? "auth" : "application"
  end

  def configure_permitted_parameters
    extra = %i[name business_name business_address tax_id default_currency
               bank_details invoice_prefix phone website payment_terms_days]
    devise_parameter_sanitizer.permit(:sign_up, keys: extra)
    devise_parameter_sanitizer.permit(:account_update, keys: extra)
  end
end
