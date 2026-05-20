class Client < ApplicationRecord
  belongs_to :user

  has_many :projects, dependent: :destroy
  has_many :invoices, dependent: :destroy

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  scope :alphabetical, -> { order(:name) }

  def total_billed
    invoices.where.not(status: :draft).sum(:total)
  end

  def total_paid
    invoices.paid.sum(:total)
  end

  def outstanding
    invoices.where(status: %i[sent overdue]).sum(&:balance_due)
  end

  def initials
    name.to_s.split.map(&:first).first(2).join.upcase
  end
end
