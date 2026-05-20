# frozen_string_literal: true

# InvoiceHub sample data: one freelancer, 5 clients, several projects,
# 10 invoices in mixed statuses, payments, time entries and expenses.
#
# Run with: bin/rails db:seed   (safe to re-run — it resets the demo user)

puts "🌱 Seeding InvoiceHub…"

DEMO_EMAIL = "demo@invoicehub.app"

# Reset the demo user so seeds are idempotent.
User.find_by(email: DEMO_EMAIL)&.destroy

user = User.create!(
  email: DEMO_EMAIL,
  password: "password",
  password_confirmation: "password",
  name: "Alex Rivera",
  business_name: "Rivera Studio",
  business_address: "27 Maple Avenue\nPortland, OR 97201\nUnited States",
  tax_id: "US-93-2841756",
  default_currency: "USD",
  phone: "+1 (503) 555-0148",
  website: "https://riverastudio.example",
  invoice_prefix: "RS",
  payment_terms_days: "30",
  bank_details: "Rivera Studio LLC\nBank: First Republic\nAccount: 0042 8819 5567\nRouting: 021000021\nPayPal: pay@riverastudio.example"
)
puts "  ✔ Freelancer: #{user.display_name} (login: #{DEMO_EMAIL} / password)"

clients_data = [
  { name: "Jordan Blake",   company: "Northwind Apps",     email: "jordan@northwind.example",  phone: "+1 (415) 555-0102", address: "500 Howard St\nSan Francisco, CA 94105" },
  { name: "Priya Sharma",   company: "Lumen Health",       email: "priya@lumenhealth.example", phone: "+1 (212) 555-0190", address: "1140 Broadway\nNew York, NY 10001" },
  { name: "Marcus Lee",     company: "Foundry Coffee Co.", email: "marcus@foundrycoffee.example", phone: "+1 (503) 555-0177", address: "88 Alder St\nPortland, OR 97204" },
  { name: "Sofia Romano",   company: "Atlas Ventures",     email: "sofia@atlasvc.example",     phone: "+44 20 7946 0102",  address: "30 St Mary Axe\nLondon EC3A 8BF\nUK" },
  { name: "Daniel Carter",  company: "Pixel & Co",         email: "daniel@pixelco.example",    phone: "+1 (646) 555-0133", address: "210 W 35th St\nNew York, NY 10001" }
]

clients = clients_data.map { |attrs| user.clients.create!(attrs) }
puts "  ✔ #{clients.size} clients"

project_templates = [
  { name: "Website Redesign",  hourly_rate: 95,  budget: 14_000, status: :active },
  { name: "Brand Identity",    hourly_rate: 110, budget: 8_000,  status: :completed },
  { name: "Mobile App MVP",    hourly_rate: 120, budget: 28_000, status: :active },
  { name: "Marketing Site",    hourly_rate: 85,  budget: 6_500,  status: :completed },
  { name: "Design System",     hourly_rate: 105, budget: 12_000, status: :active },
  { name: "E-commerce Build",  hourly_rate: 100, budget: 22_000, status: :active },
  { name: "Monthly Retainer",  hourly_rate: 90,  budget: 0,      status: :active }
]

projects = clients.flat_map do |client|
  project_templates.sample(rand(1..2)).map do |t|
    client.projects.create!(t.merge(user: user,
                                    currency: client.company.include?("Atlas") ? "GBP" : "USD",
                                    description: "#{t[:name]} engagement for #{client.company}."))
  end
end
puts "  ✔ #{projects.size} projects"

# --- Time entries ---
task_names = ["Discovery & wireframes", "UI design", "Front-end build", "API integration",
              "Client revisions", "QA & polish", "Content setup", "Deployment"]
projects.each do |project|
  rand(3..6).times do
    project.time_entries.create!(
      user: user,
      description: task_names.sample,
      hours: [1, 1.5, 2, 3, 4, 6, 8].sample,
      date: rand(90).days.ago.to_date,
      billable: [true, true, true, false].sample
    )
  end
end
puts "  ✔ #{TimeEntry.count} time entries"

# --- Expenses ---
expense_samples = [
  ["Figma annual plan", :software, 144], ["Stock photography", :marketing, 49],
  ["Domain renewal", :software, 18], ["Client lunch meeting", :meals, 64],
  ["Adobe Creative Cloud", :software, 59], ["Co-working day pass", :office, 35],
  ["USB-C dock", :hardware, 189], ["Flight to client workshop", :travel, 320],
  ["Online course: Rails", :education, 79], ["Contractor: illustration", :subcontractor, 450]
]
expense_samples.each do |desc, category, amount|
  user.expenses.create!(
    description: desc, category: category, amount: amount,
    date: rand(120).days.ago.to_date, currency: "USD",
    project: projects.sample, billable: [true, false].sample
  )
end
puts "  ✔ #{Expense.count} expenses"

# --- Invoices ---
line_item_pool = [
  ["Discovery & strategy workshop", 1, 1200],
  ["UI/UX design — homepage", 1, 1800],
  ["Front-end development", 24, 95],
  ["Responsive implementation", 12, 95],
  ["Logo & brand guidelines", 1, 2400],
  ["Monthly retainer — design support", 1, 2500],
  ["API integration", 18, 120],
  ["QA & bug fixing", 8, 90],
  ["Content migration", 6, 85],
  ["Consulting call", 2, 150]
]

def build_invoice(user, client, project, status:, issue_offset:, items:, tax_rate:, discount: 0, recurring: false, interval: nil)
  invoice = user.invoices.new(
    client: client, project: project, status: :draft,
    issue_date: issue_offset.days.ago.to_date,
    tax_rate: tax_rate, discount: discount, currency: project&.currency || "USD",
    notes: "Thanks for working with Rivera Studio.",
    recurring: recurring, recurring_interval: interval,
    recurring_next_run: (recurring ? 1.month.from_now.to_date : nil)
  )
  invoice.due_date = invoice.issue_date + 30
  items.each_with_index do |(desc, qty, price), idx|
    invoice.invoice_items.build(description: desc, quantity: qty, unit_price: price, position: idx)
  end
  invoice.save!
  # Apply the real status afterwards so number/totals are generated first.
  # Non-draft invoices are considered "sent" (needed for overdue logic).
  sent_at = status == :draft ? nil : invoice.issue_date.to_time
  invoice.update_columns(status: Invoice.statuses[status.to_s], sent_at: sent_at)
  invoice
end

invoice_plan = [
  { status: :paid,    offset: 75, items: 3, tax: 8.5, pay: :full },
  { status: :paid,    offset: 60, items: 2, tax: 0,   pay: :full },
  { status: :paid,    offset: 48, items: 4, tax: 8.5, pay: :full },
  { status: :sent,    offset: 20, items: 3, tax: 8.5, pay: :partial },
  { status: :sent,    offset: 12, items: 2, tax: 0,   pay: :none },
  { status: :overdue, offset: 55, items: 3, tax: 8.5, pay: :none },
  { status: :overdue, offset: 70, items: 2, tax: 5,   pay: :partial },
  { status: :draft,   offset: 3,  items: 4, tax: 8.5, pay: :none },
  { status: :draft,   offset: 1,  items: 2, tax: 0,   pay: :none },
  { status: :sent,    offset: 8,  items: 3, tax: 8.5, pay: :none, recurring: true }
]

invoice_plan.each_with_index do |plan, i|
  client  = clients[i % clients.size]
  project = client.projects.first
  items   = line_item_pool.sample(plan[:items])
  inv = build_invoice(
    user, client, project,
    status: plan[:status], issue_offset: plan[:offset], items: items,
    tax_rate: plan[:tax], discount: [0, 0, 100, 250].sample,
    recurring: plan[:recurring] || false, interval: (plan[:recurring] ? :monthly : nil)
  )
  inv.reload

  case plan[:pay]
  when :full
    inv.payments.create!(amount: inv.total, payment_date: inv.issue_date + rand(2..20),
                         payment_method: %i[bank stripe paypal].sample, reference: "TXN-#{rand(100000..999999)}")
  when :partial
    inv.payments.create!(amount: (inv.total * 0.5).round(2), payment_date: inv.issue_date + rand(2..15),
                         payment_method: :bank, reference: "TXN-#{rand(100000..999999)}")
    # Re-assert overdue state if the plan called for it (payment recalcs status).
    inv.update_column(:status, Invoice.statuses[plan[:status].to_s]) if plan[:status] == :overdue
  end
end

puts "  ✔ #{Invoice.count} invoices #{Invoice.group(:status).count}"
puts "  ✔ #{Payment.count} payments"

puts "\n✅ Done! Sign in at /users/sign_in with #{DEMO_EMAIL} / password"
