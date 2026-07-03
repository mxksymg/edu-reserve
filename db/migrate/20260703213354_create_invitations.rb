class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.references :school, null: false, foreign_key: true
      t.datetime :sent_at
      t.datetime :accepted_at
      t.datetime :expired_at

      t.timestamps
    end
  end
end
