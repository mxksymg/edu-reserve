# Inherits from WebApplicationController
class Teacher::CoursesController < WebApplicationController
  layout "application"
  # Requires the user to be logged in before performing the action.
  before_action :authenticate_user!
  # Checks whether the user has the teacher or admin role (private method)
  before_action :ensure_teacher!
  # Launch private method set_course before show, edit, update and destroy actions
  before_action :set_course, only: [ :show, :edit, :update, :destroy ]

  def index
    @courses = Course.where(teacher_id: current_user.id)
    # Checks whether the teacher can view the list of courses -> CoursePolicy#index?.
    authorize @courses, :index?
  end

  def show
    # Checks whether the teacher can view this course -> CoursePolicy#show?.
    authorize @course, :show?
    # SELECT * FROM schedules WHERE course_id = 1;
    @schedules = @course.schedules
    # SELECT * FROM reservations INNER JOIN schedules ON schedules.id = reservations.schedule_id INNER JOIN courses ON courses.id = schedules.course_id
    # WHERE courses.id = 1;
    @reservations = Reservation.joins(schedule: :course).where(courses: { id: @course.id })
  end

  def new
    # Creates a new, empty course object.
    @course = Course.new
    # Checks whether the teacher can create courses -> CoursePolicy#create?.
    authorize @course, :create?
  end

  def create
    # Creates a course object using the data from the form.
    @course = Course.new(course_params)
    # Sets the teacher to the currently logged-in user.
    @course.teacher_id = current_user.id
    # Checks whether the teacher can create courses -> CoursePolicy#create?.
    authorize @course, :create?

    # INSERT INTO courses (name, description, level, price, category, max_students, duration, school_id, teacher_id, created_at, updated_at)
    # VALUES ('...', '...', '...', ..., '...', 15, 20, 1, 4, NOW(), NOW());
    if @course.save
      redirect_to teacher_courses_path, notice: "✅ Kurs został utworzony!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course, :update?
  end

  def update
    authorize @course, :update?
    # UPDATE courses SET name = 'Ruby on Rails - Aktualizacja', updated_at = NOW() WHERE id = 1;
    if @course.update(course_params)
      redirect_to teacher_course_path(@course), notice: "✅ Kurs został zaktualizowany!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Checks whether the teacher can delete the course -> CoursePolicy#destroy?.
    authorize @course, :destroy?
    # DELETE FROM courses WHERE id = 1;
    @course.destroy
    redirect_to teacher_courses_path, notice: "❌ Kurs został usunięty."
  end

  private

  def set_course
    # SELECT * FROM courses WHERE id = 1;
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :description, :level, :price, :category, :max_students, :duration, :school_id)
  end

  def ensure_teacher!
    unless current_user.teacher? || current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień nauczyciela!"
    end
  end
end
