class CreateInvoiceItems < ActiveRecord::Migration[7.2]
  def change
    create_table :invoice_items do |t|
      t.string  :description, null: false
      t.decimal :quantity, precision: 12, scale: 2, default: "1.0"
      t.decimal :unit_price, precision: 12, scale: 2, default: "0.0"
      t.decimal :total, precision: 12, scale: 2, default: "0.0"
      t.integer :position, default: 0
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
