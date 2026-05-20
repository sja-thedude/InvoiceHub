class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string  :name, null: false
      t.text    :description
      t.decimal :hourly_rate, precision: 12, scale: 2, default: "0.0"
      t.decimal :budget, precision: 12, scale: 2, default: "0.0"
      t.integer :status, null: false, default: 0
      t.string  :currency, null: false, default: "USD"
      t.references :client, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :projects, :status
  end
end
