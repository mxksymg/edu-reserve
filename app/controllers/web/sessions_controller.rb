# Controller for logging in through the web page.
class Web::SessionsController < WebApplicationController
  # Skips authenticate_user! for the new and create actions. authenticate_user! requires the user to be logged in, but on the login
  # page, the user is not logged in yet!
  skip_before_action :authenticate_user!, only: [ :new, :create ]
  # Sets a different layout for the views in this controller. Uses auth.html.erb instead of application.html.erb.
  # The login page looks different from the dashboard. It does not have a navigation bar or a "Log out" button.
  layout "auth"
  # GET /login
  def new
    # If the user is already logged in (logged_in? = true), Redirects them to the home page (root_path)
    redirect_to root_path if logged_in?
  end
  # POST /login
  def create
    # Finds a user in the database by email. params[:email] – the email provided from the form. Returns nil if no user is found.
    user = User.find_by(email: params[:email])
    # user – checks whether the user was found. valid_password? – checks whether the password is correct.
    # &. – safe navigation operator. If user is nil, it returns nil.
    if user&.valid_password?(params[:password])
      # Stores the user's ID in the session (cookie). This means that the user is logged in.
      session[:user_id] = user.id
      # Redirects to the home page (dashboard).
      redirect_to root_path, notice: "Zalogowano pomyślnie. Witaj, #{user.first_name}!"
    else
      # flash - passes a message between pages (after a redirect), flash.now - only on the current page (without a redirect).
      flash.now[:alert] = "Nieprawidłowy email lub hasło"
      # render - renders the login page again. We use render to preserve error messages. If we used redirect_to, the flash message
      # would disappear.
      render :new, status: :unprocessable_entity
    end
  end
  # DELETE /logout
  def destroy
    # Removes the user's ID from the session. This means that the user is logged out.
    session[:user_id] = nil
    redirect_to login_path, notice: "Wylogowano pomyślnie!"
  end
end
