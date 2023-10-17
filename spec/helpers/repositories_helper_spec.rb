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
  describe '#repository_collections_path' do
    let(:repo_code) { 'nnc' }
    let(:repo) { Arclight::Repository.new(slug: repo_code) }
    let(:actual) { helper.repository_collections_path(repo) }
    let(:expected) { "/repository=#{repo_code}"}
    before do
      # search_action_url is a delegated controller method, so just defining a singleton
      helper.define_singleton_method(:search_action_url) {|options| }

      allow(helper).to receive(:search_action_url)
      .with({ f: {repository: [repo_code], level: ['Collection']}})
      .and_return(expected)
    end
    it 'links to a repository search based on slug' do
      expect(actual).to eql(expected)
    end
  end
end
