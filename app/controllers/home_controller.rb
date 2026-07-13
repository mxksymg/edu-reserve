class HomeController < WebApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    if current_user
      if current_user.admin?
        redirect_to admin_dashboard_path
      elsif current_user.teacher?
        redirect_to teacher_dashboard_path
      else
        redirect_to web_dashboard_path
      end
    else
      redirect_to login_path
    end
  end
end
