require 'rails_helper'

RSpec.describe CatalogHelper, type: :helper do
  include ControllerLevelHelpers

  describe '#render_search_to_page_title_filter' do
    let(:blacklight_config) { CatalogController.blacklight_config }

    before do
      initialize_controller_helpers(helper)
      allow(helper).to receive(:blacklight_config).and_return(blacklight_config)
    end

    context 'when facet key differs from Solr field name' do
      it 'uses the helper_method to render the repository name instead of the slug' do
        # The 'repository' facet key maps to Solr field 'repository_id_ssi'
        # and has helper_method: :repository_label
        result = helper.render_search_to_page_title_filter('repository', ['nnc-a'])
        expect(result).to include('Avery Drawings & Archives Collections')
        expect(result).not_to include('nnc-a')
      end
    end

    context 'when facet key matches Solr field name' do
      it 'still works normally for standard facets' do
        result = helper.render_search_to_page_title_filter('level', ['Collection'])
        expect(result).to include('Collection')
      end
    end
  end
end
