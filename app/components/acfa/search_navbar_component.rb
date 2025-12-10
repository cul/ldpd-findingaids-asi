# frozen_string_literal: true

module Acfa
  class SearchNavbarComponent < Blacklight::SearchNavbarComponent
    def initialize(blacklight_config:)
      @blacklight_config = blacklight_config
    end

    # Override to add a custom id for the hero search form
    def search_bar_component
      Acfa::SearchBarComponent.new(
        url: helpers.search_action_url,
        advanced_search_url: helpers.search_action_url(action: 'advanced_search'),
        params: helpers.search_state.params_for_search.except(:qt),
        autocomplete_path: suggest_index_catalog_path,
        form_options: { html: { id: 'hero-search-form' } }
      )
    end
  end
end