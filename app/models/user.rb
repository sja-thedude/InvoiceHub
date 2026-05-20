class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # --- Active Storage ---
  has_one_attached :logo

  # --- Associations ---
  has_many :clients,       dependent: :destroy
  has_many :projects,      dependent: :destroy
  has_many :invoices,      dependent: :destroy
  has_many :expenses,      dependent: :destroy
  has_many :time_entries,  dependent: :destroy
  has_many :invoice_items, through: :invoices
  has_many :payments,      through: :invoices

  # --- Validations ---
  validates :name, presence: true
  validates :default_currency, presence: true
  validates :invoice_prefix, presence: true

  # --- Defaults ---
  after_initialize :set_defaults, if: :new_record?

  def display_name
    business_name.presence || name
  end

  # Generates the next sequential invoice number, e.g. "INV-2026-0007".
  def next_invoice_number
    with_lock do
      increment!(:invoice_counter)
      format("%<prefix>s-%<year>d-%<seq>04d",
             prefix: invoice_prefix, year: Date.current.year, seq: invoice_counter)
    end
  end

  # --- Money helpers ---
  def total_revenue
    invoices.paid.sum(:total)
  end

  def outstanding_amount
    invoices.where(status: %i[sent overdue]).sum { |i| i.balance_due }
  end

  def overdue_amount
    invoices.overdue.sum(&:balance_due)
  end

  private

  def set_defaults
    self.default_currency ||= "USD"
    self.invoice_prefix   ||= "INV"
    self.invoice_counter  ||= 0
  end
end
