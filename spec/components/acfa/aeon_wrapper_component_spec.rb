# frozen_string_literal: true

require 'rails_helper'
require 'archive_space/parsers/archival_description_did_parser'
require 'archive_space/parsers/archival_description_dsc_parser'

describe Acfa::AeonWrapperComponent, type: :component do
  subject(:component) { described_class.new(
    repository: repository, finding_aid_title: finding_aid_title
  ) }

  let(:aeon_site_code) { 'aeon_site_code' }
  let(:arch_desc_did){ instance_double(ArchiveSpace::Parsers::ArchivalDescriptionDidParser,
    origination_creators: origination_creators, unit_dates_string: unit_dates_string,
    unit_id_bib_id: unit_id_bib_id, unit_id_call_number: unit_id_call_number,
    repository_corporate_name: repository_corporate_name
  ) }
  let(:arch_desc_dsc){ instance_double(ArchiveSpace::Parsers::ArchivalDescriptionDscParser,
    series_compound_title_array: []
  ) }
  let(:finding_aid_title) { "finding_aid_title" }
  let(:origination_creators) { [] }
  let(:repository) { instance_double(Arclight::Repository, aeon_site_code: aeon_site_code) }
  let(:repository_corporate_name) { '' }
  let(:series_compound_title_array) { [] }
  let(:unit_id_bib_id) { 'unit_id_bib_id' }
  let(:unit_id_call_number) { 'unit_id_call_number' }
  let(:unit_dates_string) { '' }

  before do
    with_controller_class(CatalogController) do
      controller.instance_variable_set(:@arch_desc_did, arch_desc_did)
      controller.instance_variable_set(:@arch_desc_dsc, arch_desc_dsc)
      render
    end
  end

  include_context "renderable view components"

  it "renders a title header" do
    expect(rendered_node).to have_selector 'h1', text: finding_aid_title
  end
end