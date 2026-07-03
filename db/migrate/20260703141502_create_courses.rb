class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.text :description
      t.string :category
      t.string :level
      t.string :age_group
      t.integer :duration
      t.decimal :price
      t.references :school, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.integer :max_students

      t.timestamps
    end
  end
end
