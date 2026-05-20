class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy history]

  def index
    scope = current_user.clients.alphabetical
    scope = scope.where("name ILIKE :q OR company ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @clients = pagy(scope)
  end

  def show
    @projects = @client.projects.recent
    @invoices = @client.invoices.recent.limit(10)
  end

  def history
    @invoices = @client.invoices.includes(:project).recent
    @payments = Payment.joins(:invoice).where(invoices: { client_id: @client.id }).recent
  end

  def new
    @client = current_user.clients.new
  end

  def edit; end

  def create
    @client = current_user.clients.new(client_params)
    if @client.save
      redirect_to @client, notice: "Client was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Client was deleted.", status: :see_other
  end

  private

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :company, :address, :phone, :notes)
  end
end
