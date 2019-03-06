require 'rails_helper'
require 'asi/as_api.rb'

RSpec.describe Asi::AsApi do
  context "API/interface" do
    # http://archivesspace.github.io/archivesspace/api/#authentication
    it 'has #get_ead_resource_description_from_fixture  method' do
      # puts subject.use_local_as_ead_file.xpath('/xmlns:ead/xmlns:archdesc/xmlns:did/xmlns:unittitle').text
      # puts subject.use_local_as_ead_file.css('ead archdesc did unittitle').first.text
      expect(subject).to respond_to(:get_ead_resource_description_from_fixture).with(0).arguments
    end

    it 'has #authenticate method' do
      # subject.authenticate
      expect(subject).to respond_to(:authenticate).with(0).arguments
    end

    it 'has #get_resource with 2 parameters: repository ID and resource ID' do
      # subject.get_resource(2, 4767)
      expect(subject).to respond_to(:get_resource).with(2).arguments
    end

    it 'has #get_resource_tree with 2 parameters: repository ID and resource ID' do
      # subject.get_resource_tree(2, 4767)
      expect(subject).to respond_to(:get_resource_tree).with(2).arguments
    end

    it 'has #get_resource_tree_root with 2 parameters: repository ID and resource ID' do
      # subject.get_resource_tree_root(2, 4767)
      expect(subject).to respond_to(:get_resource_tree_root).with(2).arguments
    end

    it 'has #get_ead_resource_description with 2 parameters: repository ID and resource ID' do
      # subject.get_ead_resource_description(2, 4767)
      expect(subject).to respond_to(:get_ead_resource_description).with(2).arguments
    end
  end
end
