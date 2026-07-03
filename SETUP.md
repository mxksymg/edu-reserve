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
8. rails s - to start server and check if works
9. Open Gemfile and make sure you have this gems there
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
10. bundle install - installs all gems/libraries listed in the 'Gemfile'
11. rails g devise:install - installs and configures Devise in your Rails application.
12. rails g devise:views - customizes the login and registration forms.
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
15. rails db:migrate - runs all pending migrations, updating the database schema based on the migration files located in the db/migrate/ directory.
16. rails g model School name:string address:text description:text
17. rails db:migrate
18. rails g model Class
19. rails g migration AddContactFieldsToSchools phone:string email:string website:string
'AddContactFieldsToSchools' - add exta fields to table School
19. rails g model Class name:string description:text category:string level:string age_group:string duration:integer price:decimal school:references teacher:references max_students:integer     !!!Class!!! - this is incorrect because Class is key word used by Ruby (use Course instead) ...model Course ...
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