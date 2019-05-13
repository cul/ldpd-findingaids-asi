require 'rails_helper'
require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the FindingAidsHelper. For example:
#
# describe FindingAidsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

RSpec.describe FindingAidsHelper, type: :helper do
  describe 'API/interface' do
    context 'has' do
      it 'apply_ead_to_html_transforms taking one argument' do
        expect(helper).to respond_to(:apply_ead_to_html_transforms).with(1).arguments
      end

      it 'apply_title_render_italics method taking one argument' do
        expect(helper).to respond_to(:apply_title_render_italic).with(1).arguments
      end

      it 'apply_extref_type_simple method taking one argument' do
        expect(helper).to respond_to(:apply_extref_type_simple).with(1).arguments
      end
    end
  end

  describe 'Functionality' do
    context '#apply_title_render_italic' do
      it 'italicizes content within <title render="italic">' do
        xml_input = fixture_file_upload('asi/title_render_italic.xml').read
        # Note: bogus ead format, would never have <p> as direct child of <ead>
        # but not an issue here, just testing the italicizing functionality
        # and just want a simple xml doc for Nokogiri to parse.
        nokogiri_xml = Nokogiri::XML(xml_input).xpath('/xmlns:ead/xmlns:p')
        result = helper.apply_title_render_italic nokogiri_xml
        expect(result.to_s).to include('<i>The Decameron</i>')
      end
    end

    context '#apply_extref_type_simple' do
      it 'creates links in content with <extref xlink:type="simple" xlink:href="..."' do
        xml_input = fixture_file_upload('asi/extref_type_simple.xml').read
        # Note: bogus ead format, would never have <p> as direct child of <ead>
        # but not an issue here, just testing the italicizing functionality
        # and just want a simple xml doc for Nokogiri to parse.
        nokogiri_xml = Nokogiri::XML(xml_input).xpath('/xmlns:ead/xmlns:p')
        result = helper.apply_extref_type_simple nokogiri_xml
        expect(result.to_s).to include('<a href="http://www.columbia.edu/cu')
        expect(result.to_s).to include('">downloadable Excel spreadsheet.</a>')
      end
    end
  end
end
