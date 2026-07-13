class Web::CoursesController < WebApplicationController
  layout "application"
  def index
    @courses = Course.all
    # Checks whether the search parameter was provided in the URL. params[:search] – comes from the search field.
    # .present? – checks whether it is not empty.
    if params[:search].present?
        # "name ILIKE ? OR description ILIKE ?" - this is an SQL condition written as a string.
        # It means: "Search in the name column OR in the description column.". ILIKE - case-insensitive search.
        # "%#{params[:search]}%" - creates a string with the search term.
        # % - any characters before and after the word.
        # #{params[:search]} - the value from the search field.
        @courses = @courses.where("name ILIKE ? OR description ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
    # Checks whether the level parameter was provided
    if params[:level].present?
        # Filters courses where the level column equals the value from the parameter. level – a column in the courses table.
        # params[:level] – the value from the URL (e.g. beginner, intermediate, advanced).
        @courses = @courses.where(level: params[:level])
    end
    # Checks whether the category parameter was provided
    if params[:category].present?
        @courses = @courses.where(category: params[:category])
    end
    # Checks the sort parameter and performs the corresponding action. It works like a switch, it selects one of the options.
    case params[:sort]
    # Sorts courses by price ascending, from the cheapest
    when "price_asc"
        @courses = @courses.order(price: :asc)
    # Sorts courses by price descending, from the most expensive
    when "price_desc"
        @courses = @courses.order(price: :desc)
    when "popular"
        # # takes most popular courses with the most reservations
        # Course.left_joins(schedules: :reservations) - joins the tables : courses + schedules + reservations. Uses LEFT JOIN instead
        # of INNER JOIN. LEFT JOIN returns all courses, even those without reservations.
        # .group(:id) - groups the results by the course ID and combines all records with the same course.id
        # .order('COUNT(reservations.id) DESC') - sorts the results by the number of reservations. DESC - from highest to lowest, so
        # the most popular courses will be displayed on top
        @courses = @courses.left_joins(schedules: :reservations).group(:id).order("COUNT(reservations.id) DESC")
    else
        # Default sorting (when the user has not selected a sorting option). Sorts by the newest courses.
        @courses = @courses.order(created_at: :desc)
    end
    @courses = @courses.limit(50)
  end
  def show
    # Finds the course in the database by ID. params[:id] – retrieves the ID from the URL (e.g. /courses/1 -> id = 1).
    @course = Course.find(params[:id])
    # Retrieves all schedules for this course. .includes(:teacher) – loads the teacher with a single query.
    @schedules = @course.schedules.includes(:teacher)
    # Creates a new, empty reservation object. Does not save it to the database.
    @reservation = Reservation.new
  end
end
