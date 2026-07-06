class ChangeRoleToStringInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :role, :string
  end
end
