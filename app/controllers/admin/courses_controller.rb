# app/controllers/admin/courses_controller.rb
class Admin::CoursesController < WebApplicationController
  layout "application"
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_course, only: [ :show, :edit, :update, :destroy ]

  def index
    @courses = Course.all.order(created_at: :desc)

    if params[:level].present?
      @courses = @courses.where(level: params[:level])
    end

    if params[:category].present?
      @courses = @courses.where(category: params[:category])
    end

    if params[:search].present?
      @courses = @courses.where("name ILIKE ?", "%#{params[:search]}%")
    end

    @courses = @courses.paginate(page: params[:page], per_page: 20)
  end

  def show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)

    if @course.save
      redirect_to admin_courses_path, notice: "✅ Kurs został utworzony!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to admin_courses_path, notice: "✅ Kurs został zaktualizowany!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @course.destroy
      redirect_to admin_courses_path, notice: "✅ Kurs został usunięty!"
    else
      redirect_to admin_courses_path, alert: "❌ Nie udało się usunąć kursu!"
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :description, :level, :price, :category, :max_students, :duration, :school_id, :teacher_id)
  end

  def ensure_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień administratora!"
    end
  end
end
