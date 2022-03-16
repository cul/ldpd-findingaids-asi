require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ComponentsHelper. For example:
#
# describe ComponentsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ComponentsHelper, type: :helper do
  context 'given unit title string with <i> and <unittitle> tags'do
    input_unit_title = '<unittitle>The <i>not so Great</i> Gatsby</unittitle>'
    expected_output_unit_title = 'The not so Great Gatsby'
    it ' .remove_tags_from_unittitle_string removes said tags' do
      expect(helper.remove_tags_from_unittitle_string(input_unit_title)).to eq expected_output_unit_title
    end
  end

  context 'given string with <unittitle> tags'do
    input_string = '<unittitle>The <i>not so Great</i> Gatsby</unittitle>'
    expected_output_string = 'The <i>not so Great</i> Gatsby'
    it ' .remove_unittitle_tags removes the <unittitle> start and end tags' do
      expect(helper.remove_unittitle_tags(input_string)).to eq expected_output_string
    end
  end
end
