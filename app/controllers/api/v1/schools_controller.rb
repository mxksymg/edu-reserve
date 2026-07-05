class Api::V1::SchoolsController < ApplicationController
  # Requires the user to be logged in before executing any action
  before_action :authenticate_user!
  # Runs the set_school (private) method before the show, update and destroy actions
  before_action :set_school, only: [ :show, :update, :destroy ]

  # GET /api/v1/schools
  def index
    # School.all - retrieves all records from the schools table in the database
    @schools = School.all
    # Returns JSON type format with @schools - list of schools and HTTP 200 OK status code
    render json: @schools, status: :ok
  end

  # GET /api/v1/schools/:id
  def show
    render json: @school, status: :ok
  end

  # POST /api/v1/schools
  def create
    # @school = School.new(school_params) - creates a new School object in memory without saving it to the database.
    # school_params - private method
    @school = School.new(school_params)
    # Trying save School object into database
    if @school.save
      # status: :created - sets the HTTP status code to 201 Created, the standard response for a successfully created resource.
      render json: @school, status: :created
    else
      # @school.errors.full_messages - returns an array of error messages (e.g. ["Name can't be blank"]).
      # status: :unprocessable_entity - sets the HTTP status code to 422 Unprocessable Entity, indicating that the request is
      # sort of valid but contains invalid or unprocessable data
      render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/schools/:id
  def update
    # @school is an existing school object that was previously loaded by the set_school method
    # .update(school_params) attempts to update the object with the permitted parameters from school_params and save the changes to the database
    if @school.update(school_params)
      render json: @school, status: :ok
    else
      render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/schools/:id
  def destroy
    @school.destroy
    head :no_content
  end

  private

  def set_school
    # @school = School.find(params[:id]) - finds the school with the ID provided in the URL (e.g. /api/v1/schools/5) and
    # stores the resulting object in the @school instance variable
    @school = School.find(params[:id])
  # rescue ActiveRecord::RecordNotFound - if no school with the specified ID exists, Rails raises an ActiveRecord::RecordNotFound
  rescue ActiveRecord::RecordNotFound
    # render json: { error: 'School not found' }, status: :not_found - returns an HTTP 404 Not Found response with the message "School not found"
    render json: { error: "School not found" }, status: :not_found
  end

  def school_params
    # params.require(:school) - requires the request payload to include a :school key (e.g.{ "school": { ... } }).
    # If the key is missing, Rails raises an exception.
    # .permit(:name, ...) - permits only the following attributes: name, address, description, phone, email and website
    params.require(:school).permit(:name, :address, :description, :phone, :email, :website)
  end
end

# Mass assignment is a Rails feature that allows multiple model attributes to be assigned at once using a single hash
# typically from a form submission or an API request. Example :
# @user = User.new(params[:user])
# All attributes contained in params[:user] are assigned to the User object in a single operation.
# Mass assignment attack occurs when an attacker includes unauthorized attributes in a request to modify fields that should not be editable
# for a user. Example :
# {
#  "user": {
#    "email": "jan@example.com",
#    "password": "password123",
#    "admin": true
#  }
# }
# The attacker attempts to set the admin attribute to true, potentially granting themselves administrative privileges
# if the application does not properly filter permitted parameters.
# The solution is Strong Parameters. Rails uses it to explicitly define which attributes are allowed for mass assignment. Example :
# def user_params
#  params.require(:user).permit(:name, :email, :password)
# end
# If someone attempts to submit an additional attribute (e.g. admin: true), Rails ignores it because it is not included in the 'permit list.
# This protects the application from unauthorized changes to sensitive attributes.
