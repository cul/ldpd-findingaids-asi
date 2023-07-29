# frozen_string_literal: true

# Root crumb
crumb :root do
  link t('arclight.routes.home'), root_path
end

crumb :ead_repository do |repository|
  link repository.name, repository_finding_aids_path(repository_id: repository.id)
end

crumb :ead_title do |repository, ead_id, ead_title|
  link ead_title, repository_finding_aid_path(repository_id: repository.id, finding_aid_id: ead_id)
  parent :ead_repository, repository
end

crumb :repositories do
  link t('arclight.routes.repositories'), arclight_engine.repositories_path
end

crumb :repository do |repository|
  link repository.name, arclight_engine.repository_path(repository.slug)

  parent :repositories
end

crumb :search_results do |search_state|
  if search_state.filter('level').values == ['Collection']
    link t('arclight.routes.collections')
  else
    link t('arclight.routes.search_results')
  end
end
