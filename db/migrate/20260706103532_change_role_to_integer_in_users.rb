class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column :users, :role, :integer, using: 'role::integer'
  end
end
