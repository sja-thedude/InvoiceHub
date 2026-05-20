class CreateTimeEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :time_entries do |t|
      t.string  :description, null: false
      t.decimal :hours, precision: 8, scale: 2, default: "0.0", null: false
      t.date    :date, null: false
      t.boolean :billable, null: false, default: true
      t.boolean :invoiced, null: false, default: false
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :time_entries, :date
  end
end
