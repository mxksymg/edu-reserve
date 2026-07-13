# It will be the parent class for all web controllers. Inherits from ActionController::Base (handles ERB views).
# Contains shared logic for web pages (sessions, cookies, helpers).
# Example ActionController::API - only JSON(api), ActionController: :Base - HTML, ERB, sessions, cookies, forms

class WebApplicationController < ActionController::Base
    # Includes the Pundit::Authorization module in the controller. This makes Pundit's authorization methods such as authorize and
    # policy_scope available in every controller that inherits from WebApplicationController.
    # Without it Rails would not recognize these methods, resulting in a NoMethodError when authorize or policy_scope is called.
    include Pundit::Authorization
    # Protects against CSRF (Cross-Site Request Forgery) attacks. Requires every form to include a hidden security token.
    protect_from_forgery with: :exception
    # Rails method that makes controller methods available in views (.html.erb files).
    helper_method :current_user, :logged_in?
    before_action :authenticate_user!

    def authenticate_user!
        # If we're on the login page, STOP here and don't check whether the user is logged in!
        return if controller_name == "sessions" && action_name.in?([ "new", "create" ])
        # Executes the code only if logged_in? returns false.
        unless logged_in?
            # redirect_to – redirects the user. login_path – the path to the login page. alert: – sets an error message.
            redirect_to login_path, alert: "Musisz być zalogowany"
        end
    end
    # private methods
    private

    def current_user
        # # ||= - assigns a value only if the variable is nil or false
        # User.find_by(id: session[:user_id]) - finds a user in the database by ID.
        # session[:user_id] – retrieves the user's ID from the session.
        # if session[:user_id] - executes the query only if session[:user_id] exists.
        @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end

    def logged_in?
        current_user.present?
    end
end
