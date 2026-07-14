class Admin::DashboardController < WebApplicationController
  layout "application"
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  # Checks whether the user has the teacher or admin role (private method)
  before_action :ensure_admin!

  def index
    # SELECT COUNT(*) FROM users
    @total_users = User.count
    # SELECT COUNT(*) FROM courses
    @total_courses = Course.count
    # SELECT COUNT(*) FROM reservations
    @total_reservations = Reservation.count
    # Uses the pending scope from the Reservation model
    # SELECT COUNT(*) FROM reservations WHERE status = 'pending'
    @pending_reservations = Reservation.pending.count
    # SELECT COUNT(*) FROM schools
    @total_schools = School.count
    # SELECT * FROM users ORDER BY created_at DESC LIMIT 5
    @recent_users = User.order(created_at: :desc).limit(5)
    # SELECT * FROM reservations ORDER BY created_at DESC LIMIT 10
    # Users of those reservations SELECT * FROM users WHERE id IN (1, 2, 3, ...)
    # Schedules and courses SELECT * FROM schedules WHERE id IN (...), SELECT * FROM courses WHERE id IN (...)
    @recent_reservations = Reservation.includes(:user, schedule: :course).order(created_at: :desc).limit(10)

    # .* - all columns from the given table.
    # SELECT courses.*, COUNT(reservations.id) as reservations_count FROM courses LEFT JOIN schedules ON schedules.course_id = courses.id
    # LEFT JOIN reservations ON reservations.schedule_id = schedules.id GROUP BY courses.id ORDER BY COUNT(reservations.id) DESC LIMIT 5
    @popular_courses = Course.left_joins(schedules: :reservations).group(:id).order("COUNT(reservations.id) DESC").limit(5)
  end

  private

  def ensure_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień administratora!"
    end
  end
end
