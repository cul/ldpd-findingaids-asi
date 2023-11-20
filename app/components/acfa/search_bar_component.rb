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
      use_params = @params.merge(f: (@params[:f] || {}).except(:collection)).except(:repository_id)
      if @params[:repository_id]
        use_params[:repository] ||= @params[:repository_id]
      end
      use_params
    end
  end
end
