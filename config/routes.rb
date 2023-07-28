Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  mount Arclight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end
  devise_for :users

  concern :exportable, Blacklight::Routes::Exportable.new
  concern :hierarchy, Arclight::Routes::Hierarchy.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
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
  get 'resolve/:id', to: 'finding_aids#resolve'
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
end
