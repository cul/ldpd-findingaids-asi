require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the RepositoriesHelper. For example:
#
# describe RepositoriesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe RepositoriesHelper, type: :helper do
  describe '#repository_label' do
    let(:actual) { helper.repository_label(repo_code) }

    context "given an existing repo code" do
      let(:repo_code) { 'nnc' }
      let(:expected) { 'Columbia University Libraries' }
      it 'maps to the repo name' do
        expect(actual).to eql(expected)
      end
    end

    context "given a non-existing repo code" do
      let(:repo_code) { 'xyz' }
      let(:expected) { repo_code }
      it 'maps to the repo name' do
        expect(actual).to eql(expected)
      end
    end
  end
end
