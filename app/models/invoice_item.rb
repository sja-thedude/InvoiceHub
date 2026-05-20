class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :description, presence: true
  validates :quantity, :unit_price, numericality: { greater_than_or_equal_to: 0 }

  before_save :set_total

  # Used by Invoice#recalculate_totals before this record is persisted.
  def line_total
    (quantity.to_d * unit_price.to_d).round(2)
  end

  private

  def set_total
    self.total = line_total
  end
end
