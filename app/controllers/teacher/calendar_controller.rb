class Teacher::CalendarController < WebApplicationController
  # Sets the application.html.erb layout. Provides the navbar, footer, and flash messages.
  layout "application"
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  # Checks whether the user has the teacher or admin role (private method)
  before_action :ensure_teacher!

  def index
    # current_user.schedules – all schedules of the teacher. .includes(:course, :reservations) – loads courses and reservations (avoids N+1 queries).
    # .order(:start_time) – sorts from the earliest.
    # SELECT * FROM schedules WHERE teacher_id = 4 ORDER BY start_time ASC
    @schedules = current_user.schedules.includes(:course, :reservations).order(:start_time)

    # Checks whether the teacher can view the schedule list -> CalendarPolicy#index?.
    authorize @schedules, :index?

    # (0..6) - creates a range from 0 to 6. These are the weekday numbers in Ruby. .. - means closed range <>, ... - open range ()
    # .map - iterates through each element in the range (0, 1, 2, 3, 4, 5, 6). Executes the code block for each element and returns a new array
    # do |day| - variable that takes the successive values from the range.
    @week_schedules = (0..6).map do |day|
      @schedules.where(weekday: day)
    end
  end

  def show
    # Finds the schedule with the given ID belonging to the teacher.
    @schedule = current_user.schedules.find(params[:id])
    # Checks whether the teacher can view the schedule details -> CalendarPolicy#show?
    authorize @schedule, :show?
    # Retrieves all reservations for the schedule, including users.
    @reservations = @schedule.reservations.includes(:user)
    # Retrieves ONLY confirmed reservations. Uses the confirmed scope from the Reservation model.
    @confirmed = @reservations.confirmed
    # Retrieves ONLY pending reservations. Uses the pending scope from the Reservation model.
    @pending = @reservations.pending
  end

  private
  # Checks whether the user has the teacher or admin role. If not, redirects to the dashboard with a message.
  def ensure_teacher!
    unless current_user.teacher? || current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień nauczyciela!"
    end
  end
end
