class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.string  :invoice_number, null: false
      t.integer :status, null: false, default: 0
      t.date    :issue_date
      t.date    :due_date
      t.text    :notes
      t.text    :terms
      t.string  :currency, null: false, default: "USD"
      t.decimal :tax_rate, precision: 5, scale: 2, default: "0.0"
      t.decimal :discount, precision: 12, scale: 2, default: "0.0"
      t.decimal :subtotal, precision: 12, scale: 2, default: "0.0"
      t.decimal :total, precision: 12, scale: 2, default: "0.0"
      t.decimal :amount_paid, precision: 12, scale: 2, default: "0.0"
      t.boolean :recurring, null: false, default: false
      t.integer :recurring_interval
      t.date    :recurring_next_run
      t.references :parent_invoice, foreign_key: { to_table: :invoices }
      t.datetime :sent_at
      t.datetime :paid_at
      t.references :client, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :invoices, :invoice_number, unique: true
    add_index :invoices, :status
  end
end
