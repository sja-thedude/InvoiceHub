class AddPublicTokenToInvoices < ActiveRecord::Migration[7.2]
  def change
    add_column :invoices, :public_token, :string
    add_index :invoices, :public_token, unique: true
  end
end
