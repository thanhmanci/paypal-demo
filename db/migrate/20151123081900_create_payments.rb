class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.datetime :expires_at
      t.datetime :purchased_at
      t.boolean :canceled, default: false
      t.integer :quantity
      t.integer :amount, default: 1
      t.string :status
      t.string :payer_id
      t.string :token
      t.string :transaction_id
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
