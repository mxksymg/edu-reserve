class Course < ApplicationRecord
  # Each course belongs to one school
  belongs_to :school
  # belongs_to - Rails method that creates a relationship between model, :teacher - name of the association. That's how you will refer to this
  # connection in your code. This allows you to write : course.teacher – and you will get a teacher object.
  # class_name: "User" - option (parameter) for belongs_to. It tells Rails to don't look for a Teacher model. Use a User model instead.
  # optional: true means the teacher association is not required.
  belongs_to :teacher, class_name: "User", optional: true
  # Course can have many schedules. dependent: :destroy – when a course is deleted, all of its associated schedules are deleted as well.
  has_many :schedules, dependent: :destroy
  # A course can have many reservations through schedules.
  # through: - creates an indirect association, it connects two models through a third model
  has_many :reservations, through: :schedules
  # The course name must be present, it cannot be nil or empty
  validates :name, presence: true
  # Checks whether a numeric value is greater than or equal to the specified value. It is used in the numericality validation.
  # greater_than_or_equal_to - is one of the numerical validation options in Rails.
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  # max_students must be a number greater than 0, allow_nil: true – the field is optional
  validates :max_students, numericality: { greater_than: 0 }, allow_nil: true
end
