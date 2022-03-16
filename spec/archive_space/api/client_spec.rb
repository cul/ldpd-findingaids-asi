require 'rails_helper'
require 'archive_space/api/client.rb'

RSpec.describe ArchiveSpace::Api::Client do
  context "API/interface" do
    # http://archivesspace.github.io/archivesspace/api/#get-an-ead-representation-of-a-resource204
    it 'has #get_ead_resource_description method' do
      expect(subject).to respond_to(:get_ead_resource_description).with(2).arguments
    end

    # Use Search API call:
    # http://archivesspace.github.io/archivesspace/api/#search-this-repository
    it 'get_resource_id' do
      expect(subject).to respond_to(:get_resource_id).with(2).arguments
    end

    # http://archivesspace.github.io/archivesspace/api/#authentication
    it 'has #authenticate method' do
      # subject.authenticate
      expect(subject).to respond_to(:authenticate).with(0).arguments
    end

    it 'has #get_ead_resource_description with 2 parameters: repository ID and resource ID' do
      # subject.get_ead_resource_description(2, 4767)
      expect(subject).to respond_to(:get_ead_resource_description).with(2).arguments
    end
  end
end
