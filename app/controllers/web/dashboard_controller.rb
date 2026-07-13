class Web::DashboardController < WebApplicationController
  layout "application"
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  def index
    #--------------------------------------------------------------------
    # Creating calendar

    # params[:month] – retrieves the month parameter from the URL (e.g., ?month=6).
    # Date.today.month – the current month (e.g. 7 for July).
    # .to_i – converts the value to an integer.
    @month = (params[:month] || Date.today.month).to_i
    @year = (params[:year] || Date.today.year).to_i
    # Checks whether the month is less than 1. In other words, whether someone tried to navigate to December of the previous year.
    if @month < 1
      # Sets the month to December.
      @month = 12
      # Decreases the year by 1.
      @year -= 1
    # Same logic but oposite
    elsif @month > 12
      @month = 1
      @year += 1
    end
    # Creates a date object for the first day of the selected month and year. Date.new(2026, 7, 1) → 2026-07-01.
    @current_date = Date.new(@year, @month, 1)
    #--------------------------------------------------------------------
    # Creating reservation stats
    # Retrieves all reservations of the logged-in user and counts them.
    # policy_scope is a Pundit method that filters a list of records in the database, returning only the records that the user
    # is allowed to see.
    @total_reservations = policy_scope(current_user.reservations).count
    # policy_scope is a Pundit method that filters a list of records in the database, returning only the records that the user
    # is allowed to see.
    # current_user.reservations - all reservations belonging to the user
    # .joins(:schedule) joins with the schedules table.
    # .where(schedules: { weekday: Date.today.wday }) - filters schedules where weekday equals today's day of the week.
    # Date.today.wday – returns the number of the day of the week (0 = Sunday, 1 = Monday, ...).
    # policy_scope is a Pundit method that filters a list of records in the database, returning only the records that the user
    # is allowed to see.
    @today_reservations = policy_scope(current_user.reservations).joins(:schedule).where(schedules: { weekday: Date.today.wday }).count
    # .confirmed - only confirmed reservations (scope from Reservation model). .where(status: 'confirmed') - also is working here
    # .where('created_at < ?', 1.month.ago) - only reservations older than 1 month.
    # 1.month.ago – the date from one month ago
    # ? – a placeholder that protects against SQL Injection.
    # policy_scope is a Pundit method that filters a list of records in the database, returning only the records that the user
    # is allowed to see.
    @completed_reservations = policy_scope(current_user.reservations).confirmed.where("reservations.created_at < ?", 1.month.ago).count
    # policy_scope is a Pundit method that filters a list of records in the database, returning only the records that the user
    # is allowed to see.
    # .joins(schedule: :course) - joins the tables: reservations + schedules + courses. This gives access to the course price.
    @total_spent = policy_scope(current_user.reservations).confirmed.joins(schedule: :course).sum("courses.price").to_f
    #--------------------------------------------------------------------
    # :dashboard - looks for DashboardPolicy. Instead of passing an object (e.g. @course), we pass its name.
    # It is the name of a method in the policy. It tells Pundit which method to call. In DashboardPolicy, it looks for the index? method.
    authorize :dashboard, :index?

    # current_user.reservations - retrieves all reservations of the logged-in user.
    # .includes(schedule: :course) - loads associated data with a single query. Avoids the N+1 query problem.
    # .order(created_at: :DESC) - sorts from newest to oldest.
    # .limit(10) - if the user has 1,000 reservations, the page will be very slow. With a limit, retrieves only 10 records.
    # Fast query, the page loads instantly.
    @reservations = policy_scope(current_user.reservations).includes(schedule: :course).order(created_at: :DESC).limit(10)
    # current_user.reservations.confirmed - retrieves the user's confirmed reservations, confirmed is a scope defined in the model.
    # .joins(:schedule) - joins with the schedules table.
    # .where('schedules.start_time > ?', Time.now) - filters only future classes. Schedules that start in the future.
    # ? - protects against SQL Injection attacks by treating user data as plain text (a string), not as SQL code.
    @upcoming = policy_scope(current_user.reservations).confirmed.joins(:schedule).where("schedules.start_time > ?", Time.now)
          # .order('schedules.start_time ASC') - sorts from earliest to latest.
          .order("schedules.start_time ASC").limit(3)
  end
end
