class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 12, scale: 2, default: "0.0", null: false
      t.date    :payment_date, null: false
      t.integer :payment_method, null: false, default: 0
      t.string  :reference
      t.text    :notes
      t.string  :stripe_payment_intent_id
      t.references :invoice, null: false, foreign_key: true

      t.timestamps
    end
  end
end
