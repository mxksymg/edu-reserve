class Schedule < ApplicationRecord
  # Each schedule belongs to a single course (Course)
  belongs_to :course
  # belongs_to - Rails method that creates a relationship between model, :teacher - name of the association. That's how you will refer to this
  # connection in your code. This allows you to write : course.teacher – and you will get a teacher object.
  # class_name: "User" - option (parameter) for belongs_to. It tells Rails to don't look for a Teacher model. Use a User model instead.
  # optional: true means the teacher association is not required.
  belongs_to :teacher, class_name: "User", optional: true
  # Schedule can have many reservations. dependent: :destroy – when a schedule is deleted, all of its associated reservations are deleted as well.
  has_many :reservations, dependent: :destroy
  # :weekday -  weekday must be present, it cannot be nil.
  validates :weekday, presence: true
  # :start_time, :end_time -  start_time and end time end_time must be present.
  validates :start_time, :end_time, presence: true
  # Calls the private during validation.
  validate :end_time_after_start_time

  def weekday_name
    day_names = [ "Niedziela", "Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota" ]
    day_names[weekday] if weekday.present?
  end
  # Returns string with the weekday name and class times.
  def weekday_name_with_time
    # "#{...} ..." - Inserts the value of a variable.
    "#{weekday_name} #{start_time.strftime('%H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  private
  # Checks whether end_time is later than start_time.
  def end_time_after_start_time
    # If not, it adds an error to the end_time field with the message "must be after start time".
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
