class Web::DashboardController < WebApplicationController
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  def index
    # current_user.reservations - retrieves all reservations of the logged-in user.
    # .includes(schedule: :course) - loads associated data with a single query. Avoids the N+1 query problem.
    # .order(created_at: :DESC) - sorts from newest to oldest.
    # .limit(10) - if the user has 1,000 reservations, the page will be very slow. With a limit, retrieves only 10 records.
    # Fast query, the page loads instantly.
    @reservations = current_user.reservations.includes(schedule: :course).order(created_at: :DESC).limit(10)
    # takes 5 courses from database
    # @courses = Course.limit(5)
    # takes 5 most popular courses with the most reservations
    # Course.left_joins(schedules: :reservations) - joins the tables : courses + schedules + reservations. Uses LEFT JOIN instead
    # of INNER JOIN. LEFT JOIN returns all courses, even those without reservations.
    # .group(:id) - groups the results by the course ID and combines all records with the same course.id
    # .order('COUNT(reservations.id) DESC') - sorts the results by the number of reservations. DESC - from highest to lowest, so
    # the most popular courses will be displayed on top
    @courses = Course.left_joins(schedules: :reservations).group(:id).order("COUNT(reservations.id) DESC").limit(5)
    # current_user.reservations.confirmed - retrieves the user's confirmed reservations, confirmed is a scope defined in the model.
    # .joins(:schedule) - joins with the schedules table.
    # .where('schedules.start_time > ?', Time.now) - filters only future classes. Schedules that start in the future.
    # ? - protects against SQL Injection attacks by treating user data as plain text (a string), not as SQL code.
    @upcoming = current_user.reservations.confirmed.joins(:schedule).where("schedules.start_time > ?", Time.now)
          # .order('schedules.start_time ASC') - sorts from earliest to latest.
          .order("schedules.start_time ASC").limit(3)
  end
end
