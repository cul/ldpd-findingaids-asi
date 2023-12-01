Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'
  mount Arclight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/archives', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end
  devise_for :users

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :hierarchy, Arclight::Routes::Hierarchy.new

  resources :solr_documents, only: [:show], path: '/archives', controller: 'catalog' do
  concerns :hierarchy
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  get 'pages/home'
  get 'resolve/:id', to: 'catalog#resolve'
  scope 'ead' do
    resources :repositories, only: [:index], path: '' do
      resources :finding_aids, only: [:index, :show], path: '' do
        get 'summary'
        get 'print'
        resources :components, only: [:index, :show], path: 'dsc'
      end
    end
  end
  scope 'preview' do
    scope 'ead' do
      resources :repositories, only: [:index], path: '' do
        resources :finding_aids, only: [:index, :show], path: '' do
          get 'summary'
          resources :components, only: [:index, :show], path: 'dsc'
        end
      end
    end
  end
  resource :aeon_request, only: [:create] do
    post 'login'
    get 'redirectshib'
    get 'redirectnonshib'
  end
  root 'repositories#index'
  namespace :api do
      namespace :v1, defaults: { format: :json } do
        post '/index/index_ead', to: 'index#index_ead'
      end
    end
end
