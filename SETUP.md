1. rails new . --api --database=postgresql --skip-test
'rails new' - creates a new Rails application
'.' - creates application in the current directory
'--api' - creates the application in API-only mode. Excludes views, ERB templates, helpers, and asset pipeline (CSS/JS) resulting in a smaller, API-focused Rails application
'--database=postgresql' - sets PostgreSQL as the default database
'--skip-test' - skips generating the default test files
2. sudo apt update - updates the list of available packages from system repositories
3. sudo apt install postgresql postgresql-contrib libpq-dev -y - installs PostgreSQL and required additional packages
'postgresql-contrib' - additional PostgreSQL extensions, useful tools and enhancements
'libpq-dev' - development headers and libraries required to compile applications (e.g. Rails) that connect to PostgreSQL
'-y' - automatically answers "yes" to installation prompts, so no manual confirmation is required
4. which psql - to check if PostgreSQL is installed (/usr/bin/psql)
5. sudo -u postgres createuser -s -P edureserve_user - '-s' - grants superuser privileges required for creating databases and full access control
'-P' - forces password setup requirement during installation or configuration
6. In config/database.yaml add  
development:
  <<: *default
  database: edureserve_development
  username: edureserve_user
  password: your_password
  host: localhost
test:
  <<: *default
  database: edu_reserve_test
  username: edureserve_user
  password: your_password
  host: localhost
7. sudo service postgresql start
8. rails s - to start server and check if works (shortcut from rails server)
9. Open Gemfile and make sure you have this gems there
gem 'jwt'
# Adds JSON Web Token (JWT) support to Devise
gem "devise-jwt"

# Helps control which data is returned in JSON responses
gem 'active_model_serializers'

# A system for running background jobs (e.g. sending emails, processing data)
gem 'sidekiq'

# In-memory key-value database (used as a cache or fast data store)
gem 'redis'

group :development, :test do
  # Replaces the default Minitest framework with RSpec (more popular and flexible testing framework)
  gem 'rspec-rails'

  # Tool for generating test data (replacement for fixtures)
  gem 'factory_bot_rails'

  # Generates fake realistic data (names, addresses, emails, phone numbers)
  gem 'faker'
end

group :development do
  # Captures sent emails and opens them in a browser instead of sending them
  gem 'letter_opener'
end
10. bundle install - installs all gems/libraries listed in the 'Gemfile' and creates file Gemfile.lock
11. rails g devise:install - installs and configures Devise in your Rails application.
12. rails g devise:views - customizes the login and registration forms (optional)
13. rails g devise User - creates model and migration

Now the main logic of the app.
Hybrid Registration-Invitation Based Signup
The school or instructor invites a student by sending an email containing an invitation link.

The student clicks the link and is redirected to the registration page, where they complete their profile by providing the required information (e.g., first name, last name, and password). The account is already associated with the correct school, so the student does not need to enter any additional school-related information.

From technical point of view
The school or instructor creates a student account through the admin panel by entering the student's email address and assigning them to the appropriate classes. The system sends an invitation email containing an account activation link. The student follows the link, sets their password, and completes any remaining profile information.

Advantages:
- The school controls who has access to the system.
- sers create their own passwords, which is more secure than sending passwords via email.
- revents unauthorized or fake account registrations.
- Simplifies user management, as the school creates the accounts while students activate them independently. 

14. rails generate migration AddFieldsToUsers first_name:string last_name:string role:integer school_id:references invitation_token:string invitation_sent_at:datetime invitation_accepted_at:datetime active:boolean
rails db:migrate
'migration' - specifies the generator type. It generates a migration file used to modify the database schema.
'AddFieldsToUsers' - migration name. Rails automatically infers the table name (users). (AddFieldsToTableName)
'school_id:references' - creates a school_id column of type integer and automatically adds an index and a foreign key constraint referencing the schools table.
'invitation_token:string' - stores a unique invitation token.
'active:boolean' - stores a Boolean value (true or false) with the default set to false for invited users.
If error, change in db/migrate ......._add_fields_to_users.rb modyfiy this line to add_reference :users, :school, foreign_key: true
and run rails db:migrate again 
15. rails db:migrate - runs all pending migrations, updating the database schema based on the migration files located in the db/migrate/ directory.
16. rails g model School name:string address:text description:text
17. rails db:migrate
18. rails g model Class
19. rails g migration AddContactFieldsToSchools phone:string email:string website:string
rails db:migrate
'AddContactFieldsToSchools' - add exta fields to table School
19. rails g model Class name:string description:text category:string level:string age_group:string duration:integer price:decimal school:references teacher:references max_students:integer     
rails db:migrate
!!!Class!!! - this is incorrect because Class is key word used by Ruby (use Course instead) ...model Course ...
20. rails g model Schedule weekday:integer start_time:time end_time:time room:string course:references teacher:references
21. rails db:migrate - if  ERROR:  relation "teachers" does not exist, change in db/migrate/20260703154048_create_schedules.rb
for t.references :teacher, null: false, foreign_key: { to_table: :users }
By default, Rails would look for a teachers table, which does not exist, resulting in a migration error.
The fix explicitly specifies the correct target table users.
21. rails g model Reservation user:references schedule:references status:string
22. rails g model Invitation email:string token:string school:references sent_at:datetime accepted_at:datetime expired_at:datetime
rails db:migrate
23. rails db:migrate
24. After going through all command check in rails console if all tabels are properly created 
User.count
School.count
Course.count
Schedule.count
Reservation.count
Invitation.count
25. Creating the JwtBlacklist model to keep track of which JWT tokens are still valid and which have been revoked
rails generate model JwtBlacklist jti:string exp:datetime
rails db:migrate
26. In app/models/user.rb add this line in devise - :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
27. In app/models/jwt_blacklist.rb add include Devise::JWT::RevocationStrategies::Denylist inside class JwtBlacklist
Here I got some troubles. I have no clue what to put after RevocationStrategies::. I was using Blacklist instead of Denylist, because when i ask AI
it gives me Blacklist, which is wrong. Based on versions of jwt key words are changing. To serach for current vocabulary use this command
Devise::JWT::RevocationStrategies.constants
28. in config/routes.rb add
post '/login', to: 'api/v1/sessions#create
delete '/logout', to: 'api/v1/sessions#destroy'
namespace :api do
  namespace :v1 do
    resources :schools, only: [:index, :show, :create, :update, :destroy]
  end
end
29. Now you can run rails s or in rails console JwtBlacklist.table_exists? to check if all points above are working
30. rails g controller api/v1/sessions
31. In app/controllers/api/v1/sessions_controller.rb put this
class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:create]
  def create
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      token = user.generate_jwt
      render json: { token: token, user: user }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    head :no_content
  end
end
32. rails generate controller api/v1/schools
33. In app/controllers/api/v1/schools_controller.rb put this
class Api::V1::SchoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_school, only: [:show, :update, :destroy]
  def index
    @schools = School.all
    render json: @schools, status: :ok
  end
  def show
    render json: @school, status: :ok
  end
  def create
    @school = School.new(school_params)
    if @school.save
      render json: @school, status: :created
    else
      render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def update
    if @school.update(school_params)
      render json: @school, status: :ok
    else
      render json: { errors: @school.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def destroy
    @school.destroy
    head :no_content
  end
  private
  def set_school
    @school = School.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'School not found' }, status: :not_found
  end
  def school_params
    params.require(:school).permit(:name, :address, :description, :phone, :email, :website)
  end
end
34. In app/controllers/application_controller.rb put this
class ApplicationController < ActionController::API
  before_action :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  private
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    if token
      begin
        decoded = JWT.decode(token, Rails.application.credentials.secret_key_base, true, algorithm: 'HS256')
        @current_user = User.find(decoded[0]['user_id'])
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing token' }, status: :unauthorized
    end
  end
  def not_found
    render json: { error: 'Resource not found' }, status: :not_found
  end
end
35. In put this app/models/user.rb
def generate_jwt
  payload = { user_id: id, exp: 24.hours.from_now.to_i }
  JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
end
36. To check if all points above work run
rails s -d  #runs server in the back, so you can work in one terminal and test the app
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}'
37. Copy token which is generated and paste here
curl -X GET http://localhost:3000/api/v1/schools \
  -H "Authorization: Bearer place_for_your_copied_token"
It should return [] - because the list of school is blank
38. Adding pundit, in Gemfile add this gem 'pundit'
bundle install
rails g pundit:install -  creates app/policies/application_policy.rb
39. In a app/controllers/application_controller.rb add this
include Pundit::Authorization
rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
def user_not_authorized
  render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
end
40. rails g pundit:policy School
41. In app/policies/school_policy.rb put this
class SchoolPolicy < ApplicationPolicy
  def index?
    true  
  end
  def show?
    true  
  end
  def create?
    user.admin?  
  end
  def update?
    user.admin? || record.user_id == user.id   
  end
  def destroy?
    user.admin?  
  end
end
42. In app/controllers/api/v1/schools_controller.rb add this
In def index
authorize @schools
In def show
authorize @school
In def create
authorize @school
In def update
authorize @school
In def destory
authorize @school
43. In app/models/user.rb add this
def admin?
  role == 'admin'
end
44. Now we check if pundit authorization is working
rails console
User.create!(
  email: "user@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: nil,   # lub 'student'
  first_name: "Jan",
  last_name: "Kowalski",
  active: true
)
User.create!(
  email: "admin@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "admin",
  first_name: "Admin",
  last_name: "User",
  active: true
)
To check our creater users - User.all.pluck(:id, :email, :role)
exit rails console and create a school as admin
url -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}'
Copy token (long string in "") and paste here place_for_copied_token in new command
curl -X POST http://localhost:3000/api/v1/schools \
  -H "Authorization: Bearer place_for_copied_token" \
  -H "Content-Type: application/json" \
  -d '{"school": {"name": "Nowa Szkoła", "address": "ul. Nowa 1"}}'
If school is created thats good, because admin only can add schools, now try to do it with user
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
Copy token (long string in "") and paste here place_for_copied_token in new command
curl -X POST http://localhost:3000/api/v1/schools \
  -H "Authorization: Bearer place_for_copied_token" \
  -H "Content-Type: application/json" \
  -d '{"school": {"name": "Nieautoryzowana Szkoła", "address": "ul. Testowa 1"}}'
The resoult {"error":"You are not authorized to perform this action"}
45. rails g pundit:policy Course
46. In app/policies/course_policy.rb put this
class CoursePolicy < ApplicationPolicy
  def index?
    true   
  end
  def show?
    true 
  end
  def create?
    user.admin? || user.school_owner?   
  end
  def update?
    user.admin? || user.school_owner? 
  end
  def destroy?
    user.admin? 
  end
end
47. rails g controller api/v1/courses
48. In app/controllers/api/v1/courses_controller.rb add this
class Api::V1::CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: [:show, :update, :destroy]
  def index
    @courses = Course.all
    authorize @courses
    render json: @courses, status: :ok
  end
  def show
    authorize @course
    render json: @course, status: :ok
  end
  def create
    @course = Course.new(course_params)
    authorize @course
    if @course.save
      render json: @course, status: :created
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @course 
    if @course.update(course_params)
      render json: @course, status: :ok
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def destroy
    authorize @course 
    @course.destroy
    head :no_content
  end
  private
  def set_course
    @course = Course.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Course not found' }, status: :not_found
  end
  def course_params
    params.require(:course).permit(:name, :description, :category, :level, :age_group, :duration, :price, :school_id, :teacher_id, :max_students)
  end
end
49. In config/routes.rb add
resources :courses, only: [:index, :show, :create, :update, :destroy]
50. In app/models/course.rb change 
belongs_to :teacher -> belongs_to :teacher, class_name: "User"
51. Lets check if out step are working
rails console
User.create!(
  email: "teacher@example.com",
  password: "password123",
  password_confirmation: "password123",
  role: "teacher",
  first_name: "Jan",
  last_name: "Nauczyciel",
  active: true
)
teacher = User.find_by(role: 'teacher')
teacher.id - remember that id and paste here place_for_remembered_id
exit rails console
rails s -d
curl -X POST http://localhost:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}'
Copy token (long string in "") and paste here place_for_copied_token in new command
Creating course with teacher as admin
curl -X POST http://localhost:3000/api/v1/courses \
  -H "Authorization: Bearer place_for_copied_token" \
  -H "Content-Type: application/json" \
  -d '{"course": {"name": "Angielski B2", "price": 199.99, "school_id": 1, "max_students": 12, "teacher_id": place_for_remembered_id}}'
Now lets check the course as user
curl -X POST http://localhost:3000/login \st:3000/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
Copy token (long string in "") and paste here place_for_copied_token in new command
curl -X GET http://localhost:3000/api/v1/courses/1 \
  -H "Authorization: Bearer place_for_copied_token"
You should be able to see course details
curl -X DELETE http://localhost:3000/api/v1/courses/1 \
  -H "Authorization: Bearer place_for_copied_token"
The resoult {"error":"You are not authorized to perform this action"}
 