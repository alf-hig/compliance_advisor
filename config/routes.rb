Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root and static pages
  root "home#index"
  get "about", to: "home#about"
  get "privacy", to: "home#privacy"
  get "terms", to: "home#terms"
  
  # Assessment wizard routes
  get "assessment/start", to: "assessments#start", as: :assessment_start_new
  get "assessment/:session_id/start", to: "assessments#start", as: :assessment_start
  get "assessment/:session_id/question", to: "assessments#question", as: :assessment_question
  post "assessment/:session_id/answer", to: "assessments#answer", as: :assessment_answer
  get "assessment/:session_id/back", to: "assessments#back", as: :assessment_back
  get "assessment/:session_id/results", to: "assessments#results", as: :assessment_results
  get "assessment/:session_id/restart", to: "assessments#restart", as: :assessment_restart
  
  # Convenience routes for starting new assessment
  get "start", to: "assessments#start"
  get "begin", to: "assessments#start"
end
