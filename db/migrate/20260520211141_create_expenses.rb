class CreateExpenses < ActiveRecord::Migration[7.2]
  def change
    create_table :expenses do |t|
      t.string  :description, null: false
      t.decimal :amount, precision: 12, scale: 2, default: "0.0", null: false
      t.integer :category, null: false, default: 0
      t.date    :date, null: false
      t.string  :currency, null: false, default: "USD"
      t.boolean :billable, null: false, default: false
      t.references :project, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :expenses, :category
    add_index :expenses, :date
  end
end
