class Expense < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :user

  has_one_attached :receipt

  enum :category, {
    software: 0, hardware: 1, travel: 2, meals: 3, office: 4,
    marketing: 5, subcontractor: 6, fees: 7, education: 8, other: 9
  }

  validates :description, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :date, presence: true

  after_initialize :set_defaults, if: :new_record?

  scope :recent, -> { order(date: :desc) }
  scope :for_year, ->(year) { where(date: Date.new(year).all_year) }

  CATEGORY_ICONS = {
    "software" => "💻", "hardware" => "🖥️", "travel" => "✈️", "meals" => "🍽️",
    "office" => "🏢", "marketing" => "📣", "subcontractor" => "🤝",
    "fees" => "🏦", "education" => "🎓", "other" => "📦"
  }.freeze

  def icon
    CATEGORY_ICONS[category]
  end

  private

  def set_defaults
    self.date ||= Date.current
  end
end
