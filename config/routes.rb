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

  get 'ead/:repository_id', to: redirect('/archives?f[repository][]=%{repository_id}&group=true&sort=title_sort+asc')
  scope 'ead' do
    resources :repositories, only: [:index], path: '' do
      resources :finding_aids, only: [:index, :show], path: '' do
        get 'summary'
        get 'print'
        resources :components, only: [:index, :show], path: 'dsc'
      end
    end
  end

  resource :aeon_request, only: [:create] do
    post 'create'
    get 'create' if Rails.env.development? # Allow GET requests to the select_account page for easier styling during development

    get 'redirectshib'
    get 'redirectnonshib'
    get 'select_account'
    get 'checkout'
  end

  root 'repositories#index'
  namespace :api do
      namespace :v1, defaults: { format: :json } do
        post '/index/index_ead', to: 'index#index_ead'
        post '/index/delete_ead', to: 'index#delete_ead'
      end
    end
end
