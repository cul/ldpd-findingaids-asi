# frozen_string_literal: true

module Acfa
  class SearchBarComponent < ::Arclight::SearchBarComponent
    def initialize(**kwargs)
      super

      (@kwargs[:form_options] ||= {})
      (@kwargs[:form_options][:html] ||=  {})[:id] = 'hero-search-form'
      (@kwargs[:classes] ||= ['search-query-form']) << 'd-flex'
    end

    def params_for_search
      use_params = @params.merge(f: (@params[:f] || {})).except(:repository_id)
      if @params[:repository_id]
        use_params[:repository] ||= @params[:repository_id]
      end
      use_params
    end

    def within_collection_options
      value = collection_name || 'none-selected'
      options_for_select(
        [
          [t('arclight.within_collection_dropdown.all_collections'), ''],
          [t('arclight.within_collection_dropdown.this_collection'), value]
        ],
        # When we're in a show view, we always want "Search all collections" to be the default dropdown option
        selected: params[:action] == 'show' ? 'none-selected' : collection_name,
        disabled: 'none-selected'
      )
    end
  end
end
