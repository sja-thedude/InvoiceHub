namespace :invoices do
  desc "Generate due recurring invoices (run daily)"
  task generate_recurring: :environment do
    created = RecurringInvoiceGenerator.run
    puts "Generated #{created.size} recurring invoice(s)."
  end

  desc "Mark unpaid invoices past their due date as overdue (run daily)"
  task mark_overdue: :environment do
    count = 0
    Invoice.unpaid.where("due_date < ?", Date.current).find_each do |invoice|
      invoice.refresh_payment_status!
      count += 1 if invoice.overdue?
    end
    puts "Marked #{count} invoice(s) overdue."
  end

  desc "Daily maintenance: recurring + overdue"
  task daily: %i[generate_recurring mark_overdue]
end
