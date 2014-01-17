Boxen::Application.routes.draw do
  root :to => "Splash#index"
  get "/auth/github/callback" => "Auth#create"
  get "/logout" => "Auth#destroy"

  get "/script/:token.sh" => "Splash#script"
  get "/modules" => "Modules#index"

  get 'api/modules', defaults: { :format => 'json' }
  get 'api/modules/:name' => "Api#check_status", defaults: { :format => 'json' }
  get 'api/modules/:name/changes' => "Api#changes", defaults: { :format => 'json' }
end
