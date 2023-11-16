# frozen_string_literal: true

require 'rails_helper'
require 'archive_space/parsers/component_parser'
require 'archive_space/parsers/ead_helper'
require 'ead/elements/did'

describe Acfa::Ead::Components::ComponentsComponent, type: :component do
  subject(:component) { series_components.first }

  let(:aeon_enabled) { true }
  let(:component_id) { 1 }
  let(:ead_node) { Nokogiri::XML(xml_input) { |config| config.norecover } }
  let(:dsc_parser) { ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new }
  let(:delimiter) { CONFIG[:container_info_delimiter] }
  let(:repository) { double(Arclight::Repository, checkbox_per_unittitle: false, slug: 'nynycba') }
  let(:series_components) do
    @series_components = []
    series_parser.each_child_component_info(series_element, 0) do |element, component_info, nesting_level|
      @series_components << described_class.new(
        component_info: component_info, parser: series_parser, element: element, repository: repository,
        nesting_level: nesting_level, aeon_enabled: aeon_enabled, component_id: component_id
      )
    end
    @series_components
  end
  let(:series_element) { series_parser.series }
  let(:series_parser) { ArchiveSpace::Parsers::ComponentParser.new }
  let(:xml_input) { File.read(Rails.root.join('test/fixtures/files/ead/as_ead_ldpd_16607351.xml')) }

  before do
    series_parser.parse(ead_node, component_id)
  end

  include_context "renderable view components"

  it "renders a checkbox" do
    expect(rendered_node).to have_field 'checkbox_1_1', with: "1#{delimiter}#{delimiter}Box 1"
    expect(rendered_node).to have_selector 'label[for="checkbox_1_1"]', text: "Request Box 1"
  end
end