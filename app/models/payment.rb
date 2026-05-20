class Payment < ApplicationRecord
  belongs_to :invoice

  enum :payment_method, { bank: 0, paypal: 1, stripe: 2, cash: 3 }

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_date, presence: true

  after_initialize :set_defaults, if: :new_record?
  after_commit :update_invoice_status

  scope :recent, -> { order(payment_date: :desc) }

  private

  def set_defaults
    self.payment_date ||= Date.current
  end

  def update_invoice_status
    # Skip when the invoice is being torn down (e.g. cascading destroy).
    return if destroyed? && (invoice.nil? || invoice.destroyed?)
    return unless Invoice.exists?(invoice_id)

    invoice.refresh_payment_status!
  end
end
