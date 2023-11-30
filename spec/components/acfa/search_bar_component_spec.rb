# frozen_string_literal: true

require 'rails_helper'

describe Acfa::SearchBarComponent, type: :component do
  subject(:component) { described_class.new(
    url: search_url, params: original_params
  ) }

  let(:original_params) { { q: 'q' } }
  let(:search_url) { '/search' }

  before do
    with_controller_class(CatalogController) do
      render
    end
  end

  include_context "renderable view components"

  it "renders an input" do
    expect(rendered_node).to have_field 'q', with: original_params[:q]
  end
end