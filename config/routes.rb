Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  require "admin_constraint"

  #1. Analytics & Charts
  #2. Announcements
  #3. Assignments, Submissions, Grades
  #4. Assignment Types
  #5. Badges
  #6. Challenges
  #7. Integrations
  #8. Courses
  #9. Groups
  #10. Informational Pages
  #11. Grade Schemes
  #12. Teams
  #13. Users
  #14. User Auth
  #15. Uploads
  #16. Events
  #17. API Calls
  #18. Attendance
  #19. Exports
  #20. Errors

  #1. Analytics & Charts
  namespace :analytics do
    get :staff
    get :students
    get :all_events
    get :login_events
    get :login_role_events
    get :role_events
    get :all_pageview_events
    get :all_role_pageview_events
    get :all_user_pageview_events
    get :pageview_events
    get :role_pageview_events
    get :user_pageview_events
  end

  post "analytics_events/predictor_event"
  post "analytics_events/tab_select_event"

  #2. Announcements
  resources :announcements, except: [:edit, :update]

  #3. Assignments, Submissions, Grades
  namespace :assignments do
    resources :importers, param: :provider_id, only: [:index, :show] do
      get :assignments
      get :download
      post "/courses/:id/assignments/import", action: :assignments_import,
        as: :assignments_import
      post "/assignments/:id/refresh", action: :refresh_assignment, as: :refresh_assignment
      post "/assignments/:id/update", action: :update_assignment, as: :update_assignment
    end
  end

  resources :assignments, except: [:create, :update]  do
    collection do
      get :feed
      get :settings
      post "copy" => "assignments#copy"
      get "export_structure"
    end

    member do
      get "grades_review"
    end

    # routes for all grades that are associated with an assignment
    # single resources should go directly on the grades controller
    resources :grades, only: [:index], module: :assignments do
      collection do
        get :export
        get :export_earned_levels
        get :mass_edit
        put :mass_update
        put :release
        post :self_log
        delete :delete_all
      end
    end

    resource :groups, only: [], module: :assignments do
      resources :grades, only: [], module: :groups do
        collection do
          get :mass_edit
          put :mass_update
        end
      end
    end

    namespace :grades do
      resources :importers, param: :provider_id, only: [:index, :show] do
        get :download
        post :upload
        get :assignments
        get "/courses/:id/grades", action: :grades, as: :grades
        post "/courses/:id/grades/import", action: :grades_import, as: :grades_import
      end
    end

    resources :groups, only: [], module: :assignments do
      get :grade, on: :member
    end

    resources :students, only: [], module: :assignments do
      post :grade
    end

    resources :submissions, except: :index

    resource :rubrics, only: [:edit, :destroy] do
      get :index_for_copy, on: :collection
      post :copy, on: :collection
      get :export, on: :collection
    end
  end

  resources :grades, only: [:show, :destroy, :edit] do
    member do
      post :exclude
      post :feedback_read
      post :include
    end
    collection do
      put :release
    end
  end

  resources :submission_files, only: [] do
    get :download
  end

  resources :unlock_states, only: [:create, :destroy, :update] do
    member do
      post :manually_unlock
    end
  end
  resources :unlock_conditions, only: [:create, :destroy, :update]

  resources :levels, only: [:create, :destroy, :update]

  #4. Assignment Types
  resources :assignment_types, except: [:show] do
    get :all_grades, on: :member
    get :export_scores, on: :member
    get :export_all_scores, on: :collection
  end

  #5. Badges
  resources :badges, except: [:update, :create] do
    get "export_structure", on: :collection
    resources :earned_badges do
      get :mass_edit, on: :collection
      post :mass_earn, on: :collection
    end
    namespace :badges do
      resources :importers, param: :provider_id, only: [:index, :show] do
        get :download
        post :upload
      end
    end
  end

  #6. Challenges
  resources :challenges do
    resources :challenge_grades, only: [:new, :create], module: :challenges do
      collection do
        put :release
        get :mass_edit
        put :mass_update
      end
    end
  end

  resources :challenge_grades, except: [:index, :new, :create]

  #7. Integrations
  resources :integrations, only: [:create, :index] do
    resources :courses, only: [:create, :destroy], module: :integrations
  end

  namespace :google_calendars, only: [] do
    resources :assignments, only: [ ] do
      collection do
        post "assignment/:id", action: :add_assignment, as: :add_assignment
        post "/all_assignments", action: :add_assignments, as: :add_assignments
      end
    end
    resources :events do
      collection do
        post "event/:id", action: :add_event, as: :add_event
        post "/all_events", action: :add_events, as: :add_events
      end
    end
  end

  #8. Courses
  resources :courses, except: [:show] do
    post :copy, on: :collection
    post :recalculate_student_scores, on: :member
    put :publish, on: :member
    put :unpublish, on: :member
    post :activate_all_students, on: :collection
    get :badges, on: :member
    get :change, on: :member
    get :new_external, on: :collection
    post :create_external, on: :collection
    get :overview, on: :collection
    get :edit_dashboard_message, on: :collection
    put :update_dashboard_message, on: :collection
  end

  resources :course_memberships, only: [:create, :delete, :destroy] do
    member do
      put :deactivate
      put :reactivate
    end
  end

  #9. Groups
  resources :groups

  #10. Informational Pages
  controller :info do
    get :dashboard
    get :predictor
    get :earned_badges
    get :export_earned_badges
    get :final_grades
    get :gradebook
    get :submissions
    get :grading_status
    get :gradebook_file
    get :multiplied_gradebook
    get :multiplier_choices
    get :per_assign
    get :research_gradebook
    get :syllabus
  end

  controller :pages do
    get :brand_and_style_guidelines
    get :features
    get :our_team, to: "pages#team"
    get :press
    get :research
    get :sign_up
  end

  #11. Grade Schemes
  resources :grade_scheme_elements, only: [:index, :edit, :update] do
    collection do
      get :mass_edit
      get :export_structure
    end
  end

  #12. Teams
  resources :teams

  #13. Users
  %w{students gsis professors admins}.each do |role|
    get "users/#{role}/new" => "users#new", as: "new_#{role.singularize}",
      role: role.singularize
  end

  resources :users, except: :show do
    member do
      get :activate
      get :activate_set_password
      get :resend_activation_email
      put :manually_activate
      post :activate_set_password, action: :activated
      post :activate, action: :activated_external
      post :flag
    end
    collection do
      get :edit_profile
      put :update_profile
      get :import
      get :search
      post :upload
      get :new_external
      post :create_external
    end
  end

  namespace :users do
    resources :importers, only: :index, param: :provider_id do
      get :users
      get :download
      post "/course/:id/users/import", action: :users_import, as: :users_import
    end
  end

  resources :students, only: [:index, :show] do
    resources :badges, only: [:index, :show], module: :students
    resources :assignment_type_weights, only: [:index], module: :students
    member do
      get :recalculate
    end
  end

  resources :staff, only: [:index, :show]

  resources :observers, only: :index

  #14. User Auth
  post "auth/lti/callback", to: "user_sessions#lti_create"
  get "/auth/:provider/callback", to: "authorizations#create"
  get "auth/failure", to: "pages#auth_failure", as: :auth_failure

  # Canvas OmniAuth setup
  match "/auth/canvas/setup" => "canvas_session#new", via: [:get, :post]

  get :login, to: "user_sessions#new", as: :login
  get :logout, to: "user_sessions#destroy", as: :logout
  get :reset, to: "user_sessions#new"
  resources :user_sessions, only: [:new, :create, :destroy] do
    collection do
      get :instructors
    end
  end
  resources :passwords, except: [:new, :destroy, :index, :show]

  get "impersonate_student/:student_id", to: "user_sessions#impersonate_student", as: :student_preview
  get "exit_student_impersonation", to: "user_sessions#exit_student_impersonation"

  # SAML
  get "saml/init"
  post "saml/consume"
  get "saml/metadata"
  get "saml/logout"

  get "lti/:provider/launch", to: "lti#launch", as: :launch_lti_provider

  #15. Uploads
  resource :uploads, only: [] do
    get :remove
  end

  #16. Events
  resources :events do
    post :copy, on: :collection
  end

  resources :canvas_session, only: [:index, :new]

  resources :institutions, only: [:index, :new, :edit, :create, :update]

  #18. Attendance
  resources :attendance, only: [:index, :new, :create] do
    collection do
      get :setup
      get :mass_edit
    end
  end

  #19. API Calls
  namespace :api, defaults: { format: :json } do

    resources :assignments, only: [:index, :show, :update, :create] do
      get "analytics"
      post :sort, on: :collection
      resources :criteria, only: :index
      resources :students, only: [] do
        resources :criteria, only: [] do
          member do
            put :update_fields, to: 'criterion_grades#update_fields'
          end
        end
        resources :criterion_grades, only: :index
        get "grade", to: 'grades#show'
        put "criterion_grades", to: "criterion_grades#update"
      end
      resources :grades, only: [], module: :assignments do
        get :show, on: :collection
      end
      resource :groups, only: [], module: :assignments do
        resources :grades, only: :index, module: :groups
      end
      resources :groups, only: [] do
        resources :criteria, only: [] do
          member do
            put :update_fields, to: 'criterion_grades#group_update_fields'
          end
        end
        get 'grades', to: 'grades#group_index'
        get 'criterion_grades', to: 'criterion_grades#group_index'
      end
      resources :submissions, only: [:create, :update], module: :assignments do
        get :show, on: :collection
      end
      resources :unlock_conditions, only: :index

      namespace :grades do
        resources :importers, only: [], param: :provider_id do
          get "/course/:id", action: :show, as: :grades
        end
      end

      collection do
        resources :importers, only: [], param: :provider_id, module: :assignments do
          get "/course/:id/assignments", action: :index, as: :assignments
          post :upload
          post :import
        end
      end
    end

    resources :assignment_types, only: :index do
      resources :assignment_type_weights, only: :create
      post :sort, on: :collection
    end

    resources :badges, only: [:index, :show, :update, :create] do
      post :sort, on: :collection
      resources :unlock_conditions, only: :index
    end

    resources :challenges, only: :index

    resources :courses, only: [:index] do
      collection do
        get "analytics"
        get "one_week_analytics", to: "courses#one_week_analytics"
        resources :importers, only: [], module: :courses, param: :provider_id do
          get "courses", action: :index
        end
      end
      resources :teams, only: :index, module: :courses
    end

    get "course_creation", to: "course_creation#show"
    put "course_creation", to: "course_creation#update"

    resources :criteria, only: [:create, :update, :destroy] do
      put "levels/:level_id/set_expectations", to: "criteria#set_expectations"
      put "remove_expectations"
      put :update_order, on: :collection
    end
    get "timeline_events", to: "courses#timeline_events"
    put "course_memberships/confirm_onboarding", to: "course_memberships#confirm_onboarding"

    resources :earned_badges, only: [:create, :destroy]
    get "courses/:course_id/badges/:badge_id/earned_badges/:id/confirm_earned", to: "earned_badges#confirm_earned",
      as: :earned_badge_confirm

    # api file uploads
    post "grades/:grade_id/file_uploads", to: "file_uploads#create"
    post "assignments/:assignment_id/groups/:group_id/file_uploads", to: "file_uploads#group_create"
    delete "file_uploads/:id", to: "file_uploads#destroy"
    post "assignments/:assignment_id/file_uploads", to: "assignment_files#create"
    delete "assignment_files/:id", to: "assignment_files#destroy"
    post "badges/:badge_id/file_uploads", to: "badge_files#create"
    delete "badge_files/:id", to: "badge_files#destroy"

    resources :gradebook, only: [] do
      collection do
        get :assignments
        get :student_ids
        get :students
      end
    end

    resources :grades, only: :update do
      resources :earned_badges, only: :create, module: :grades do
        delete :delete_all, on: :collection
      end
    end

    resources :grade_scheme_elements, only: :index do
      resources :unlock_conditions, only: :index
      collection do
        put :update, as: :update
        delete :destroy_all
      end
    end

    resources :levels, only: [:create, :update, :destroy]
    resources :level_badges, only: [:create, :destroy]

    resources :predicted_earned_badges, only: [:create, :update]
    resources :predicted_earned_challenges, only: [:create, :update]
    resources :predicted_earned_grades, only: [:create, :update]

    resources :rubrics, only: [:show]
    resources :students, only: [:index]

    get "students/analytics", to: "students#analytics"
    get "students/:id/analytics", to: "students#student_analytics"


    resources :students, only: [], module: :students do
      resources :badges, only: :index
    end

    resources :unlock_conditions, only: [:create, :update, :destroy]

    resources :users, only: [] do
      collection do
        resources :importers, only: [], module: :users, param: :provider_id do
          get "/course/:id/users", action: :index, as: :users
        end
      end
    end

    resources :gradebook, only: [] do
      collection do
        get :assignments
        get :student_ids
        get :students
      end
    end

    resources :attendance, only: :create
  end

  #19. Exports
  resources :downloads, only: :index

  resources :submissions_exports, only: [:create, :destroy] do
    member do
      get :download
      get '/secure_download/:secure_token_uuid/secret_key/:secret_key',
        action: "secure_download", as: "secure_download"
    end
  end

  resources :course_analytics_exports, only: [:create, :destroy] do
    member do
      get :download
      get '/secure_download/:secure_token_uuid/secret_key/:secret_key',
        action: "secure_download", as: "secure_download"
    end
  end

  #20. Errors
  resource :errors, only: :show

  # root, bro
  root to: "pages#home"
end
