class Api::V1::UsersController < ApplicationController
  # Defines an action that returns data for the logged-in user.
  def me
    # current_user – retrieves the logged-in user (from the JWT token). render json: – returns data in JSON format.
    render json: current_user, status: :ok
  end

  def index
    # Checks whether the logged-in user has permission to view the list. ->
    authorize User
    render json: User.all, status: :ok
  end

  def show
    # Finds the user by the ID from the URL. params[:id] – e.g /api/v1/users/5.
    user = User.find(params[:id])
    authorize User
    render json: user, status: :ok
  end

  def update
    user = User.find(params[:id])
    authorize user
    user.update(user_params)
    render json: user
  end
  def update_role
    # Finds the user in the database by ID.
    user = User.find(params[:id])
    # Checks whether the logged-in user has permission to perform this action.
    authorize User

    unless current_user.admin?
      render json: { error: "Only admin can change role" }, status: :forbidden
      return
    end
    # Attempts to update the user's role field. params[:role] – the new role (e.g. "admin", "teacher", "student").
    if user.update(role: params[:role])
      render json: user, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    user.destroy
    head :no_content
  end

  private
  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end
end
