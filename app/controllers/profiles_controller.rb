class ProfilesController < ApplicationController
  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Business profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(
      :name, :business_name, :business_address, :tax_id, :default_currency,
      :bank_details, :invoice_prefix, :phone, :website, :payment_terms_days, :logo
    )
  end
end
