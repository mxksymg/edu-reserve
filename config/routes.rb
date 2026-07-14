Rails.application.routes.draw do
  get "login", to: "web/sessions#new"
  post "login", to: "web/sessions#create"
  delete "logout", to: "web/sessions#destroy"
  get "dashboard", to: "web/dashboard#index", as: "web_dashboard"
  root "home#index"
  get "register", to: "web/users#new"
  post "register", to: "web/users#create"

  get "courses", to: "web/courses#index"
  get "courses/:id", to: "web/courses#show", as: "course"
  post "reservations", to: "web/reservations#create"

  get "profile", to: "web/users#profile", as: "profile"
  get "profile/edit", to: "web/users#edit", as: "edit_profile"
  patch "profile", to: "web/users#update"

  # if Rails.env.development? - checks whether the application is running in the development environment.
  # development – the environment where you work on the code (locally on your computer).
  # Other environments include: test (testing) and production (live application).
  if Rails.env.development?
    # mount – attach an application to your Rails app.
    # LetterOpenerWeb::Engine – a complete application (engine) provided by Letter Opener Web.
    # at: "/letter_opener" – defines the URL path where it will be available.
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Generates all default Devise routes for the User model
  devise_for :users
  #------------------------------------------
  # TEACHER's PANEL
  namespace :teacher do
    get "dashboard", to: "dashboard#index"
    get "calendar", to: "calendar#index"
    get "calendar/:id", to: "calendar#show", as: :calendar_event
    resources :courses, only: [ :index, :show, :edit, :update, :new, :create ] do
      member do
        delete :destroy
      end
    end
    resources :reservations, only: [ :index ] do
      member do
        patch :confirm
        patch :cancel
      end
    end
    resources :students, only: [ :index ]
  end
  #------------------------------------------
  # ADMIN's PANEL
  # Creates a group of routes with the /admin prefix.
  namespace :admin do
    # Creates a route for the admin dashboard. GET /admin/dashboard
    get "dashboard", to: "dashboard#index"
    resources :users, only: [ :index, :show, :edit, :update, :destroy ] do
      # Adds routes for a single resource (with :id in the URL).
      member do
        # Adds a route for updating a user's role. PATCH /admin/users/:id/update_role
        patch :update_role
        # Adds a route for activating/deactivating a user. PATCH /admin/users/:id/toggle_active
        patch :toggle_active
      end
    end
    resources :courses, only: [ :index, :new, :create, :edit, :update, :destroy ]
    resources :reservations, only: [ :index, :show, :destroy ] do
      member do
        # Adds a route for confirming a reservation. PATCH /admin/reservations/:id/confirm
        patch :confirm
        # Adds a route for cancelling a reservation. PATCH /admin/reservations/:id/cancel
        patch :cancel
      end
    end
    resources :schools, only: [ :index, :new, :create, :edit, :update, :destroy ]
  end


  #------------------------------------------
  # 'namespace :api' – all routes defined within this namespace are automatically prefixed with /api
  namespace :api do
    # API versioning is the practice of assigning version numbers (e.g., `v1`, `v2`, `v3`) to different versions
    # of your API. This allows you to introduce changes such as modifying response formats, adding new fields,
    # or removing existing ones without breaking applications that depend on earlier versions of the API.
    namespace :v1 do
    # Defines a custom login route
    # 'post' - HTTP method used to submit login credentials
    # '/login' - URL path for loging in (e.g. http://localhost:3000/login)
    # 'to: sessions#create' routes the request to Api::V1::SessionsController#create and  allows login
    # via /login instead of the default /users/sign_in
    post "/login", to: "sessions#create"

    # Defines a custom logout route
    # 'delete' – the HTTP method used to terminate the user's session (or invalidate the authentication token)
    # '/logout' – the route path
    # 'to: sessions#destroy' – maps the request to the destroy action in SessionsController
    delete "/logout", to: "sessions#destroy"

      get "users/me"
      # Generates the standard routes for the School resource. The 'only' option limits the generated routes to the specified actions
      # excluding 'new' and 'edit'
      resources :schools, only: [ :index, :show, :create, :update, :destroy ]
      # Generates the standard routes for the Course resource
      resources :courses, only: [ :index, :show, :create, :update, :destroy ]
      resources :schedules, only: [ :index, :show, :create, :update, :destroy ]
      # To allow changing a reservation's status from pending to confirmed, we can do it in two ways : update – PATCH /api/v1/reservations/1 with
      # { "status": "confirmed" } or dedicated confirm action – PATCH /api/v1/reservations/1/confirm
      # confirm clearly expresses what the action does (it confirms a reservation). update is generic, it could be used to modify many other
      # fields (e.g. user_id, schedule_id). With update, we would need to check whether the user is allowed to modify any field and then
      # additionally verify whether they can change the status. With confirm, authorization is straightforward. Only an admin or teacher can
      # confirm reservations. With update someone could submit additional fields (e.g. user_id) and modify them if they are not properly protected.
      # With confirm, only the status is changed, nothing else.
      # member - Rails method that adds a route for a single resource.
      # do ... end - opens a block where you can define additional custom routes for this resource.
      # patch :confirm - defines a PATCH route: /api/v1/reservations/:id/confirm
      resources :reservations, only: [ :index, :show, :create, :destroy ] do
        member do
          patch :confirm
        end
      end
      resources :users, only: [ :index, :show, :update, :destroy ] do
        member do
          patch :update_role
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
