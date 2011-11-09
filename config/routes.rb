RememberMe::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => 'users/registrations' } do
    get 'users/registrations/success', :to => 'users/registrations#success' 
  end

  resources :schedules, :path => '/reminders' do
    resources :logs, :only => :index
    resources :subscribers, :only => [:index, :destroy]
  end

  match :receive_at, :controller => "nuntium", :action => :receive_at
  
  resources :channel, :only => [:create, :destroy]
  get "new_channel/:step", :action => :new, :controller => :channel, :as => "new_channel"

  
  root :to => 'home#index'

  match 'tour/:page' => 'tour#show', :as => :tour
  match 'tour' => 'tour#index'
  match 'help' => 'help#faq'
  match 'community' => 'community#index'

  get  'createAccount', :to => redirect('/users/sign_up')
  get  'discuss',       :to => redirect(RememberMe::Application.config.user_group_url)
  get  'backlog',       :to => redirect(RememberMe::Application.config.backlog_url)
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
