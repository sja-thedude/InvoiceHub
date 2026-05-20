class Invoice < ApplicationRecord
  belongs_to :user
  belongs_to :client
  belongs_to :project, optional: true

  # Self-referential link for recurring invoice generation.
  belongs_to :parent_invoice, class_name: "Invoice", optional: true
  has_many   :child_invoices, class_name: "Invoice",
             foreign_key: :parent_invoice_id, dependent: :nullify

  has_many :invoice_items, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :invoice
  has_many :payments, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true,
                                reject_if: ->(attrs) { attrs[:description].blank? && attrs[:unit_price].blank? }

  enum :status, { draft: 0, sent: 1, paid: 2, overdue: 3 }
  enum :recurring_interval, { weekly: 0, monthly: 1, quarterly: 2, yearly: 3 },
       prefix: :every

  validates :invoice_number, presence: true, uniqueness: true
  validates :currency, presence: true
  validates :tax_rate, :discount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_invoice_number, on: :create
  before_validation :set_defaults, on: :create
  before_validation :ensure_public_token
  before_save :recalculate_totals

  scope :recent, -> { order(issue_date: :desc, created_at: :desc) }
  scope :unpaid, -> { where(status: %i[sent overdue]) }
  scope :for_year, ->(year) { where(issue_date: Date.new(year).all_year) }

  STATUS_COLORS = {
    "draft"   => "bg-gray-100 text-gray-600",
    "sent"    => "bg-blue-100 text-blue-700",
    "paid"    => "bg-emerald-100 text-emerald-700",
    "overdue" => "bg-red-100 text-red-700"
  }.freeze

  def status_color
    STATUS_COLORS[status]
  end

  # --- Money calculations ---
  def recalculate_totals
    self.subtotal = invoice_items.reject(&:marked_for_destruction?).sum(&:line_total)
    discounted    = subtotal - discount.to_d
    discounted    = 0 if discounted.negative?
    tax_amount    = (discounted * tax_rate.to_d / 100).round(2)
    self.total    = (discounted + tax_amount).round(2)
  end

  def tax_amount
    discounted = subtotal.to_d - discount.to_d
    discounted = 0 if discounted.negative?
    (discounted * tax_rate.to_d / 100).round(2)
  end

  def balance_due
    (total.to_d - amount_paid.to_d).round(2)
  end

  def paid_in_full?
    balance_due <= 0
  end

  # --- Status transitions ---
  def mark_sent!
    update!(status: :sent, sent_at: Time.current) if draft?
  end

  def refresh_payment_status!
    return if destroyed? || frozen?

    self.amount_paid = payments.sum(:amount)
    self.status =
      if paid_in_full? && amount_paid.positive?
        :paid
      elsif overdue_by_date?
        :overdue
      elsif amount_paid.positive? || sent_at.present?
        :sent
      else
        :draft
      end
    self.paid_at = status_paid? ? (payments.maximum(:payment_date) || Date.current) : nil
    save!
  end

  def status_paid? = status.to_s == "paid"

  # An invoice can only be overdue once it has actually been sent.
  def overdue_by_date?
    due_date.present? && due_date < Date.current && !paid_in_full? && sent_at.present?
  end

  # --- Recurring ---
  def schedule_next_run!
    return unless recurring?

    advance = { "weekly" => 1.week, "monthly" => 1.month,
                "quarterly" => 3.months, "yearly" => 1.year }[recurring_interval]
    update!(recurring_next_run: (recurring_next_run || Date.current) + advance)
  end

  # Builds a fresh draft invoice cloned from this one (for recurring runs).
  def build_recurrence
    dup.tap do |inv|
      inv.assign_attributes(
        status: :draft, invoice_number: nil, public_token: nil, sent_at: nil, paid_at: nil,
        amount_paid: 0, recurring: false, recurring_interval: nil,
        recurring_next_run: nil, parent_invoice: self,
        issue_date: Date.current,
        due_date: Date.current + (user.payment_terms_days.to_i.days)
      )
      invoice_items.each do |item|
        inv.invoice_items.build(
          description: item.description, quantity: item.quantity,
          unit_price: item.unit_price, position: item.position
        )
      end
    end
  end

  private

  def set_invoice_number
    self.invoice_number ||= user.next_invoice_number if user
  end

  def set_defaults
    self.issue_date ||= Date.current
    self.due_date   ||= issue_date + (user&.payment_terms_days.to_i.days) if user
    self.currency   ||= client&.user&.default_currency || "USD"
  end

  def ensure_public_token
    self.public_token ||= SecureRandom.urlsafe_base64(16)
  end
end
