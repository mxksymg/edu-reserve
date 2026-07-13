# Inherits from WebApplicationController
class Teacher::DashboardController < WebApplicationController
  layout "application"
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  # Checks whether the user has the teacher or admin role (private method)
  before_action :ensure_teacher!

  def index
    # current_user.schedules – all schedules of the teacher. .includes(:course) – loads courses (avoids N+1 queries).
    # .map - A Ruby method that iterates through each element of a collection. Creates a new array with the results.
    # & - operator that converts a symbol into a code block.
    # map(&:course) –  name of the method to call. Example:
    # Without          courses = schedules.map do |schedule|
    #                     schedule.course
    #                 end
    # With             courses = schedules.map(&:course)
    # .uniq – removes duplicates (one course can have multiple schedules). Used in Ruby with tables
    @courses = current_user.schedules.includes(:course).map(&:course).uniq

    @total_courses = @courses.count
    # Reservation.joins(schedule: :course) – joins : reservations + schedules + courses.
    # .where(schedules: { teacher_id: current_user.id }) – only courses belonging to this teacher.
    # .distinct – removes duplicates (a student can be enrolled in multiple courses). Used in SQL
    # .count(:user_id) – counts unique students.
    @total_students = Reservation.joins(schedule: :course).where(schedules: { teacher_id: current_user.id }).distinct.count(:user_id)
    # Same logic, however its counts all reservations without looking if students are involved with multiple courses
    @total_reservations = Reservation.joins(schedule: :course).where(schedules: { teacher_id: current_user.id }).count
    # Only diffrence here is counting where status in pending
    @pending_reservations = Reservation.joins(schedule: :course).where(schedules: { teacher_id: current_user.id }).where(status: "pending")
                                       .count

    # .where(weekday: Date.today.wday) – only today (wday = day of the week). .includes(:course) – loads courses.
    # .order(:start_time) – sorts from the earliest.
    @today_schedules = current_user.schedules.where(weekday: Date.today.wday).includes(:course).order(:start_time)

    # .includes(:user, schedule: :course) – loads related data (avoids N+1 queries). For limit(10) with include there is 4 queries
    # but without include there is 21 queries
    # .order(created_at: :desc) – sorts from newest. .limit(10) – only 10 records.
    @recent_reservations = Reservation.joins(schedule: :course).where(schedules: { teacher_id: current_user.id })
                                      .includes(:user, schedule: :course).order(created_at: :desc).limit(10)
  end

  private
  # Checks whether the user has the teacher or admin role. If not, redirects to the dashboard with a message.
  def ensure_teacher!
    unless current_user.teacher? || current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień nauczyciela!"
    end
  end
end
