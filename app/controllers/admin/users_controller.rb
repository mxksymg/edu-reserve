# app/controllers/admin/users_controller.rb
class Admin::UsersController < WebApplicationController
  layout "application"
  before_action :authenticate_user!
  before_action :ensure_admin!
  # Runs private method set_user before the specified actions to find the user by ID and set it to @user instance variable.
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :update_role, :toggle_active ]

  def index
    # Retrieves all users from the database and orders them by creation date in descending order, assigning the result to @users instance variable.
    # SELECT * FROM users ORDER BY created_at DESC
    @users = User.all.order(created_at: :desc)
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "✅ Użytkownik został zaktualizowany!"
    else
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "❌ Nie możesz usunąć samego siebie!"
    else
      @user.destroy
      redirect_to admin_users_path, notice: "✅ Użytkownik został usunięty!"
    end
  end

  def update_role
    if @user == current_user
      redirect_to admin_users_path, alert: "❌ Nie możesz zmienić własnej roli!"
    else
      if @user.update(role: params[:role])
        redirect_to admin_users_path, notice: "✅ Rola użytkownika została zmieniona!"
      else
        redirect_to admin_users_path, alert: "❌ Nie udało się zmienić roli!"
      end
    end
  end
  # The toggle_active action toggles the active status of a user. If the user is the current user, it redirects with an alert.
  # Otherwise, it updates the user's active status and redirects with a notice.
  def toggle_active
    if @user == current_user
      redirect_to admin_users_path, alert: "❌ Nie możesz deaktywować samego siebie!"
    else
      # Toggles the active status of the user. If the user is currently active, it will be deactivated, and vice versa.
      @user.update(active: !@user.active)
      # Sets the status message based on the new active status of the user.
      status = @user.active ? "aktywowany" : "deaktywowany"
      # Redirects to the admin users path with a notice indicating the new status of the user.
      redirect_to admin_users_path, notice: "✅ Użytkownik został #{status}!"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
  # The user_params method defines the allowed parameters for user updates.
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def ensure_admin!
    unless current_user.admin?
      redirect_to root_path, alert: "Nie masz uprawnień administratora!"
    end
  end
end
