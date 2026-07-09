class Reservation < ApplicationRecord
  # Each reservation belongs to one user and one schedule (requires user_id and schedule_id columns in the reservations table)
  belongs_to :user
  belongs_to :schedule
  # presence: true - status must be present, it cannot be nil.
  # inclusion is one of the built in validations in Rails. It checks whether an attribute value belongs to a specified set.
  # { in: ... } – an option that defines the set of allowed values. %w[...] is a shorthand syntax for creating an array of strings in Ruby.
  # inclusion: { in: %w[pending confirmed cancelled] } – the status must be one of : 'pending', 'confirmed', 'cancelled'
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled] }
  # Call private methods during validation
  validate :no_conflict
  validate :places_available
  # after_initialize - after initializing a new object, it sets_the_default - sets the default status, if: :new_record? - if it is a new record
  # Calls the private method set_default_status
  after_initialize :set_default_status, if: :new_record?
  # Sets the default status to 'pending'
  def set_default_status
    # ||= - assigns a value only if the variable is nil or false
    self.status ||= "pending"
  end
  def no_conflict
    # schedule – checks whether the schedule exists, user – the user object (e.g. User.find(1)), .reservations – returns a collection
    # of all reservations associated with the user (has_many :reservations in schedule.rb).
    # .joins – an Active Record method that joins the reservations table with the schedules table through their association (:schedule) - belongs_to :schedule
    if schedule && user.reservations.joins(:schedule)
      # .where(schedules: { weekday: schedule.weekday }) – filters only the reservations that take place on the same day of the week.
      .where(schedules: { weekday: schedule.weekday })
      # .where.not() – does not match the search condition, id: id -  first id is the column name (in the reservations table), the second id is
      # the value (the ID of the current reservation that we want to exclude).
      .where.not(id: id)
      # .exists? - Active Record method that checks whether at least one record matching the condition exists. Returns true of false.
      # "schedules.start_time < ? AND schedules.end_time > ?" - this is an SQL condition written as a string.
      # schedule.end_time, schedule.start_time - these are two arguments that are substituted for the ? placeholders in order.
      # First ? is schedule.end_time, the second ? is schedule.start_time.
      .where("schedules.start_time < ? AND schedules.end_time > ?", schedule.end_time, schedule.start_time)
      .exists?
      # errors - ActiveModel::Errors object assigned to every model in Rails.
      # .add - A method that adds a new error to the object. It takes two arguments: Attribute, Message
      # base - a special attribute representing a general error, not assigned to a specific field. Used when an error applies to the
      # entire object rather than a single attribute.
      errors.add(:base, "Masz już zajęcia w tym terminie")
    end
  end

  # Responsible for checking whether there are available spots for a given class.
  def places_available
    # puts ">>> places_available called!"
    # new_record? – checks whether the reservation is new (it is created, not updated). This ensures that the validation is not triggered
    # when confirming a reservation (updating the status)
    # schedule.reservations – all reservations for this schedule
    # .where(status: 'confirmed') – filters only confirmed reservations, does not include pending or cancelled one
    # .count – counts the number of confirmed reservations
    # >= schedule.course.max_students - the maximum number of participants allowed for this course. If the number of confirmed reservations
    # is greater than or equal to the limit, there are no available spots.
    if new_record? && schedule && schedule.reservations.where(status: [ "pending", "confirmed" ]).count >= schedule.course.max_students
      errors.add(:base, "Brak wolnych miejsc")
    end
  end

  scope :confirmed, -> { where(status: "confirmed") }
  scope :pending, -> { where(status: "pending") }
  scope :cancelled, -> { where(status: "cancelled") }
end
