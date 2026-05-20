class TimeEntry < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :description, presence: true
  validates :hours, numericality: { greater_than: 0 }
  validates :date, presence: true

  after_initialize :set_defaults, if: :new_record?

  scope :recent,    -> { order(date: :desc) }
  scope :billable,  -> { where(billable: true) }
  scope :unbilled,  -> { where(billable: true, invoiced: false) }

  def amount
    (hours.to_d * project.hourly_rate.to_d).round(2)
  end

  private

  def set_defaults
    self.date ||= Date.current
  end
end
