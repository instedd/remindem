# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Remindem.
#
# Remindem is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Remindem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Remindem.  If not, see <http://www.gnu.org/licenses/>.

RememberMe::Application.routes.draw do

  scope "(:locale)", :locale => /#{Locales.available.keys.join('|')}/ do

    devise_for :users, :controllers => {:registrations => 'users/registrations' }, :path_names => { :sign_in => "log_in", :sign_out => "log_out", :sign_up => "create_account" } do
      get 'users/registrations/success', :to => 'users/registrations#success'
    end

    resources :schedules, :path => '/reminders' do
      resources :logs, :only => :index
      resources :subscribers, :only => [:index, :destroy]
    end

    match :receive_at, :controller => "nuntium", :action => :receive_at

    resources :channel, :only => [:create, :destroy]

    get "new_channel/:step", :action => :new, :controller => :channel, :as => "new_channel"

    get  'bulk_uploads', :action => :index,  :controller => :bulk_uploads, :as => "bulk_uploads"
    post 'bulk_uploads', :action => :upload, :controller => :bulk_uploads, :as => "bulk_uploads"

    match 'tour/:page' => 'tour#show', :as => :tour
    match 'tour' => 'tour#index'
    match 'help' => 'help#faq'
    match 'community' => 'community#index'

    get  'createAccount', :to => redirect('/%{locale}/users/create_account'), :defaults => { :locale => 'en' }
    get  'discuss',       :to => redirect(RememberMe::Application.config.user_group_url)
    get  'backlog',       :to => redirect(RememberMe::Application.config.backlog_url)

    match '/locale/update' => 'locale#update',  :as => 'update_locale'
    match '/' => 'home#index',                  :as => 'home'

  end

  root :to => 'home#index'

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
