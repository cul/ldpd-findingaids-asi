Rails.application.routes.draw do
  # 2 routes below were autogenerated
  get 'asi/as_ead_from_fixture'
  get 'asi/as_ead'

  get '/asi/repo_id/:repo_id/res_id/:res_id/ead',
      to: 'asi#as_ead',
      as: 'ead'
  get '/asi/local_fixtures/repo_id/:repo_id/res_id/:res_id/ead_fixture',
      to: 'asi#as_ead_from_local_fixture',
      as: 'ead_fixture'

  get '/asi/repo_id/:repo_id/res_id/:res_id/ead/ser_id/:ser_id/series' => 'asi#as_ead_series'
  get '/asi/local_fixtures/repo_id/:repo_id/res_id/:res_id/ead_fixture/ser_id/:ser_id/series',
      to: 'asi#as_ead_series_from_local_fixture',
      as: 'series_fixture'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
