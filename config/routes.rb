Rails.application.routes.draw do
  get 'pages/home'
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
