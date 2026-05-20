# Generates new draft invoices from recurring templates whose next-run date
# has arrived. Intended to be run daily via cron (see config/schedule.rb).
class RecurringInvoiceGenerator
  def self.run(today: Date.current)
    new(today).run
  end

  def initialize(today)
    @today = today
    @created = []
  end

  def run
    templates.find_each do |template|
      ActiveRecord::Base.transaction do
        invoice = template.build_recurrence
        invoice.save!
        template.schedule_next_run!
        @created << invoice
      end
    rescue StandardError => e
      Rails.logger.error("[RecurringInvoiceGenerator] #{template.id}: #{e.message}")
    end
    @created
  end

  private

  def templates
    Invoice.where(recurring: true).where("recurring_next_run <= ?", @today)
  end
end
