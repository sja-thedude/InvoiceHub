<div align="center">

<img src="public/icon.svg" width="84" alt="InvoiceHub logo" />

# InvoiceHub

### Invoicing &amp; client management that gets freelancers paid faster.

Create polished invoices, track time and expenses, accept online payments,
and see exactly how your freelance business is performing — all in one place.

[![Ruby on Rails](https://img.shields.io/badge/Rails-7.2-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![Ruby](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Hotwire](https://img.shields.io/badge/Hotwire-Turbo%20%2B%20Stimulus-5ca0f2)](https://hotwired.dev)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-v4-38BDF8?logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![Deploy on Render](https://img.shields.io/badge/Deploy-Render-46E3B7?logo=render&logoColor=white)](https://render.com)

</div>

---

![Dashboard](docs/screenshots/02-dashboard.png)

## ✨ Highlights

- 📊 **Insightful dashboard** — total revenue, outstanding & overdue balances, a 12-month revenue chart, an invoice-status donut, recent activity and top clients.
- 🧾 **Invoice builder** — add line items with live totals, set tax & discount, preview, download a branded PDF, and email it to the client in one click.
- 👥 **Client management** — full client profiles, project history and total-billed/outstanding figures per client.
- 🗂️ **Projects** — hourly rates, budgets, status, and live **profitability** (revenue − expenses).
- ⏱️ **Time tracking** — log billable hours per project and **import unbilled time straight into an invoice** as line items.
- 🧮 **Expense tracking** — categorise spend, attach receipts (Active Storage) and link to projects.
- 📈 **Reports** — revenue by month, revenue by client, project profitability and a **tax summary** for your accountant.
- 💳 **Online payments** — public, token-based pay page powered by **Stripe Checkout**; payments recorded and invoice status updated automatically via webhook.
- 🔁 **Recurring invoices** — weekly / monthly / quarterly / yearly auto-generation via a daily cron job.
- 💰 **Payment recording** — log bank / PayPal / Stripe / cash payments; status flips to *paid* / *overdue* automatically.
- 🌍 **Multi-currency** — per-invoice currency with proper symbols & formatting (money-rails).
- 📧 **Action Mailer** — invoices and receipts delivered as styled HTML email with the PDF attached.

## 📸 Screenshots

<table>
  <tr>
    <td width="50%"><b>Invoice builder</b><br/><img src="docs/screenshots/06-invoice-edit.png" alt="Invoice builder"/></td>
    <td width="50%"><b>Invoice detail</b><br/><img src="docs/screenshots/04-invoice-show.png" alt="Invoice detail"/></td>
  </tr>
  <tr>
    <td><b>Invoices list</b><br/><img src="docs/screenshots/03-invoices.png" alt="Invoices"/></td>
    <td><b>Clients</b><br/><img src="docs/screenshots/05-clients.png" alt="Clients"/></td>
  </tr>
  <tr>
    <td><b>Projects</b><br/><img src="docs/screenshots/07-projects.png" alt="Projects"/></td>
    <td><b>Time tracking</b><br/><img src="docs/screenshots/08-time.png" alt="Time tracking"/></td>
  </tr>
  <tr>
    <td><b>Expenses</b><br/><img src="docs/screenshots/09-expenses.png" alt="Expenses"/></td>
    <td><b>Revenue report</b><br/><img src="docs/screenshots/11-report-revenue.png" alt="Revenue report"/></td>
  </tr>
  <tr>
    <td><b>Project profitability</b><br/><img src="docs/screenshots/12-report-profit.png" alt="Profitability"/></td>
    <td><b>Client detail</b><br/><img src="docs/screenshots/16-client-show.png" alt="Client detail"/></td>
  </tr>
  <tr>
    <td><b>Public pay page</b><br/><img src="docs/screenshots/15-public-invoice.png" alt="Public invoice"/></td>
    <td><b>Generated PDF (Prawn)</b><br/><img src="docs/screenshots/17-pdf.png" alt="PDF invoice"/></td>
  </tr>
  <tr>
    <td><b>Landing page</b><br/><img src="docs/screenshots/01-landing.png" alt="Landing"/></td>
    <td><b>Sign in</b><br/><img src="docs/screenshots/14-signin.png" alt="Sign in"/></td>
  </tr>
</table>

## 🛠️ Tech stack

| Layer | Choice |
|------|--------|
| Framework | **Ruby on Rails 7.2** (Ruby 3.4) |
| Database | **PostgreSQL** |
| Front-end | **Hotwire** (Turbo + Stimulus), **Tailwind CSS v4** |
| Auth | **Devise** |
| PDF | **Prawn** + prawn-table |
| Charts | **Chartkick** + Chart.js (+ groupdate) |
| Payments | **Stripe** Checkout & webhooks |
| Money | **money-rails** (multi-currency) |
| Files | **Active Storage** (logos & receipts) |
| Email | **Action Mailer** |
| Pagination | **Pagy** |
| Deploy | **Render.com** (Blueprint included) |

## 🗃️ Data model

```
User (freelancer)
 ├─ has_many Clients
 │            └─ has_many Projects ─┐
 ├─ has_many Projects ──────────────┤
 │            ├─ has_many TimeEntries
 │            └─ has_many Expenses
 ├─ has_many Invoices
 │            ├─ has_many InvoiceItems
 │            └─ has_many Payments
 ├─ has_many Expenses        (receipt via Active Storage)
 └─ has_many TimeEntries
```

- **User** — name, email, password, business_name, business_address, tax_id, logo, default_currency, bank_details, invoice prefix & counter, payment terms.
- **Client** — name, email, company, address, phone, notes.
- **Project** — name, description, hourly_rate, budget, status (`active/completed/archived`), currency.
- **Invoice** — auto-generated number, status (`draft/sent/paid/overdue`), issue/due dates, tax_rate, discount, subtotal, total, amount_paid, currency, recurring fields, public token.
- **InvoiceItem** — description, quantity, unit_price, total.
- **Payment** — amount, date, method (`bank/paypal/stripe/cash`), reference.
- **Expense** — description, amount, category, date, receipt, billable.
- **TimeEntry** — description, hours, date, billable, invoiced.

## 🚀 Local setup

**Requirements:** Ruby 3.4, PostgreSQL 14+, Node 18+ (for the importmap toolchain).

```bash
git clone https://github.com/<your-username>/InvoiceHub.git
cd InvoiceHub

bundle install

# Create, migrate and seed the database
bin/rails db:create db:migrate db:seed

# Start Rails + the Tailwind watcher together
bin/dev
```

Visit **http://localhost:3000** and sign in with the seeded freelancer:

| Email | Password |
|-------|----------|
| `demo@invoicehub.app` | `password` |

The seed creates **1 freelancer, 5 clients, several projects, 10 invoices** across every status (draft / sent / paid / overdue), plus payments, time entries and expenses.

## ⚙️ Environment variables

All optional in development — the app degrades gracefully (e.g. online-payment buttons fall back to manual recording when Stripe isn't configured).

| Variable | Purpose |
|----------|---------|
| `RAILS_MASTER_KEY` | Decrypts credentials in production |
| `APP_HOST` | Host used in mailer links (e.g. `invoicehub.onrender.com`) |
| `DATABASE_URL` | Provided automatically by Render |
| `STRIPE_SECRET_KEY` / `STRIPE_PUBLISHABLE_KEY` | Stripe Checkout |
| `STRIPE_WEBHOOK_SECRET` | Verifies incoming Stripe webhooks |
| `SMTP_ADDRESS` / `SMTP_PORT` / `SMTP_USERNAME` / `SMTP_PASSWORD` | Outgoing email |
| `MAIL_FROM` | From-address for invoices & receipts |

## ⏰ Background jobs (recurring invoices & overdue)

A daily task generates due recurring invoices and marks overdue ones:

```bash
bin/rails invoices:daily          # both of the below
bin/rails invoices:generate_recurring
bin/rails invoices:mark_overdue
```

Locally you can schedule it with the `whenever` gem (`config/schedule.rb`); on Render it runs as the cron service defined in `render.yaml`.

## ☁️ Deploy to Render

This repo ships a **Render Blueprint** (`render.yaml`) that provisions a web service, a PostgreSQL database and the daily cron job.

1. Push the repo to GitHub.
2. In Render: **New → Blueprint**, select the repo.
3. Set the secret env vars when prompted: `RAILS_MASTER_KEY` (contents of `config/master.key`) and `APP_HOST`.
4. Deploy. The build script runs migrations and seeds demo data on first boot.

Build & start commands (already wired up):

```bash
# build
./bin/render-build.sh            # bundle, assets:precompile, db:migrate, seed-if-empty
# start
bundle exec puma -C config/puma.rb
```

## 🧱 Project structure

```
app/
├─ controllers/      dashboard, invoices, clients, projects, payments,
│                    expenses, time_entries, reports, checkouts, webhooks…
├─ models/           business logic (totals, status transitions, recurring)
├─ services/
│   ├─ invoice_pdf.rb                 # Prawn PDF generator
│   └─ recurring_invoice_generator.rb # recurring invoice engine
├─ mailers/          InvoiceMailer (HTML email + PDF attachment)
├─ javascript/controllers/  Stimulus: line-items (live totals), sidebar, dismiss
└─ views/            Tailwind UI, marketing & auth layouts
config/
├─ routes.rb         resourceful routes + Stripe + public pay page
├─ schedule.rb       whenever cron definition
└─ initializers/     stripe, money, pagy
render.yaml          Render Blueprint
db/seeds.rb          rich demo dataset
```

## 📋 Feature checklist

- [x] Dashboard: revenue, outstanding, overdue, monthly chart, recent activity
- [x] Client management with history & totals
- [x] Invoice builder (line items, tax, discount, live totals)
- [x] Professional PDF generation (Prawn) with logo, totals, bank details
- [x] Time tracking → convert to invoice line items
- [x] Expense tracking with receipt uploads & categories
- [x] Reports: revenue by month/client, profitability, tax summary
- [x] Multi-currency support
- [x] Email invoices (Action Mailer)
- [x] Recurring invoices (weekly/monthly/quarterly/yearly)
- [x] Payment recording with automatic status updates
- [x] Stripe online payments + webhook
- [x] Seed data & Render deployment

---

<div align="center">
Built with ❤️ using Ruby on Rails.
</div>
