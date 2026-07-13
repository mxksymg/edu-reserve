class Web::UsersController < WebApplicationController
  layout "application"
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    # Creates a new user with the data from the form.
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, notice: "✅ Konto utworzone! Zaloguj się."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ===== PROFIL =====
  def profile
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to profile_path, notice: "✅ Profil został zaktualizowany!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end
end
