class CreateSchools < ActiveRecord::Migration[8.1]
  def change
    create_table :schools do |t|
      t.string :name
      t.text :address
      t.text :description

      t.timestamps
    end
  end
end
