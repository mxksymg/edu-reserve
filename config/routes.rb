Rails.application.routes.draw do
  # Generates all default Devise routes for the User model
  devise_for :users
  # Defines a custom login route
  # 'post' - HTTP method used to submit login credentials
  # '/login' - URL path for loging in (e.g. http://localhost:3000/login)
  # 'to: api/v1/sessions#create' routes the request to Api::V1::SessionsController#create and  allows login
  # via /login instead of the default /users/sign_in
  post "/login", to: "api/v1/sessions#create"
  # Defines a custom logout route
  # 'delete' – the HTTP method used to terminate the user's session (or invalidate the authentication token)
  # '/logout' – the route path
  # 'to: api/v1/sessions#destroy' – maps the request to the destroy action in SessionsController
  delete "/logout", to: "api/v1/sessions#destroy"

  # 'namespace :api' – all routes defined within this namespace are automatically prefixed with /api
  namespace :api do
    # API versioning is the practice of assigning version numbers (e.g., `v1`, `v2`, `v3`) to different versions
    # of your API. This allows you to introduce changes such as modifying response formats, adding new fields,
    # or removing existing ones without breaking applications that depend on earlier versions of the API.
    namespace :v1 do
      # Generates the standard routes for the School resource. The 'only' option limits the generated routes to the specified actions
      # excluding 'new' and 'edit'
      resources :schools, only: [ :index, :show, :create, :update, :destroy ]
      # Generates the standard routes for the Course resource
      resources :courses, only: [ :index, :show, :create, :update, :destroy ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
