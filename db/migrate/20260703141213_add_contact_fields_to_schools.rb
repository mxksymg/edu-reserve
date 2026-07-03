class AddContactFieldsToSchools < ActiveRecord::Migration[8.1]
  def change
    add_column :schools, :phone, :string
    add_column :schools, :email, :string
    add_column :schools, :website, :string
  end
end
