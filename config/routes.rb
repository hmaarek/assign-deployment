Rails.application.routes.draw do

  get 'search/search'
  post 'search/locationsearch'  => 'search#loc_searchprocess'
  post 'search/cablesearch'  => 'search#cbl_searchprocess'
  post 'search/cabletrace'  => 'search#cbl_traceprocess'
  post 'search/pointtrace'  => 'search#pointtrace' #was post
  post 'search/connectionsearch'  => 'search#conn_searchprocess'
  get 'locations/:id/list_free_ports' => 'locations#list_free_ports', as: :list_free_ports
  get 'locations/report_free_ports' => 'locations#report_free_ports', as: :report_free_ports
  post 'locations/batchports'  => 'locations#batchports'
  
  
  #connect backhauls through circuits
  get 'locations/:id/connectbackhauls' => 'locations#connectbackhauls', as: :connectbackhauls
  
  get 'sessions/new'

  get 'users/new'

  #get 'backhauls/new'

  #get 'connections/new'

  root 'welcome#index'
  
  #list all tables:
  get 'locations/listrack' => 'locations#listrack'
  
  #clean ports:
  #  1. Put zeros in fiber-in and/or fiber-out if they dont point to valid fiber ids
  #  2. Force a "Save" to all fiber strands to force an update to port tables
  get 'devports/cleanprts' => 'devports#cleanprts'
  get 'Location/cleanlocations' => 'locations#cleanlocations'
  post 'devports/cleanprtsproc' =>  'devports#cleanprtsproc'
  
  
  #Merge Data Items
  get 'tools/mergedataform' => 'tools#mergedataform'
  post 'tools/mergedataproc' =>  'tools#mergedataproc'
  post 'tools/mergedata' =>  'tools#mergedata'
  
  
  # Trace: start from a certain port and list all ports, devices, racks , cables,
  #  locations, and fibers up until a port with a zero fiber id (termination point)
  get 'devports/:id/tracelink' => 'devports#tracelink', as: :trace_link
  

  #importing external data files into the database.
  #used for batch upload of netwrok data (cables, racks, devices ports, cables...) into the databas
  get 'import/import'
  post 'import/impprocess' =>  'import#impproces'

#replaced by a global search command...03Oct2016
  #location search functions...
  #get 'locations/search'
  #post 'locations/searchprocess'  => 'locations#searchprocess'


  #login sessions
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :connections
  
  get '/feeders',  to: 'backhauls#feeders'
  resources :backhauls
  
  resources :rings
  
  resources :customers
  
  resources :users
  
  #add a contract to a specific customer  
  get 'contracts/:customerid/new' => 'contracts#new', as: :add_contract 
  resources :contracts
  
  resources :locations do 
    resources :net_racks , shallow: true
  end
  
    resources :net_racks do
      resources :devices , shallow: true
    end

    resources :devices do
      resources :devports , shallow: true
    end

# this is neede, not sure why, so that Ruby 
# can include "devports" not "devport" in the route path!!    
    resources :devports do
      resources :fakeresource , shallow: true 
    end
    
# Cables and fiberstrands
    resources :cables do
      resources :fiberstrands, shallow: true
    end
    
    #resources :fiberstrands, only: [:show, :edit, :update, :destroy]

    
    
    
  
# ------------------------------------------------------------------------------  
# Shallow Resources Routing:
# ````````````````````````````
#  resources :articles do
#    resources :comments, only: [:index, :new, :create]
#  end
# +
# resources :comments, only: [:show, :edit, :update, :destroy]
#
#
# This idea strikes a balance between descriptive routes and deep nesting. 
# There exists shorthand syntax to achieve just that, via the :shallow option:

#  resources :articles do
#    resources :comments, shallow: true
#  end
# ------------------------------------------------------------------------------  
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
