require 'net/http'

module Asi
  class AsApi
    def get_ead_resource_description_from_fixture
      open('spec/fixtures/asi/as_ead_resource_4767_representation.xml') do |b|
        b.read
      end
    end

    def authenticate
      post_uri = URI(ASI_CONFIG[:auth_url])
      post_request = Net::HTTP::Post.new post_uri.request_uri
      post_request.set_form_data('password' => ASI_CONFIG[:password])
      result = Net::HTTP.start(post_uri.host, post_uri.port, use_ssl: true) do |http|
        http.request(post_request)
      end
      # puts result.inspect
      @token = JSON.parse(result.body)['session']
    end

    def get_resource(repo_id, resource_id)
      # move following outside later
      authenticate
      repo_url = "#{ASI_CONFIG[:repositories_url]}/#{repo_id}"
      params = ASI_CONFIG[:get_resource_params]
      # puts params
      resource_url = "#{repo_url}/resources/#{resource_id}?#{params}"
      # puts resource_url
      get_uri = URI(resource_url)
      get_request = Net::HTTP::Get.new get_uri.request_uri
      get_request['X-ArchivesSpace-Session'] = @token
      result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
        http.request(get_request)
      end
      # puts result.inspect
      # puts JSON.parse(result.body)['title']
      result.body
    end

    def get_resource_tree(repo_id, resource_id)
      # move following outside later
      authenticate
      repo_url = "#{ASI_CONFIG[:repositories_url]}/#{repo_id}"
      resource_tree_url = "#{repo_url}/resources/#{resource_id}/tree"
      # puts resource_url
      get_uri = URI(resource_tree_url)
      get_request = Net::HTTP::Get.new get_uri.request_uri
      get_request['X-ArchivesSpace-Session'] = @token
      result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
        http.request(get_request)
      end
      # puts result.inspect
      # puts JSON.parse(result.body)['title']
      result.body
    end

    def get_resource_tree_root(repo_id, resource_id)
      # move following outside later
      authenticate
      repo_url = "#{ASI_CONFIG[:repositories_url]}/#{repo_id}"
      resource_tree_url = "#{repo_url}/resources/#{resource_id}/tree/root"
      # puts resource_url
      get_uri = URI(resource_tree_url)
      get_request = Net::HTTP::Get.new get_uri.request_uri
      get_request['X-ArchivesSpace-Session'] = @token
      result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
        http.request(get_request)
      end
      # puts result.inspect
      # puts JSON.parse(result.body)['title']
      result.body
    end

    def get_ead_resource_description(repo_id, resource_id)
      # move following outside later
      authenticate
      repo_url = "#{ASI_CONFIG[:repositories_url]}/#{repo_id}"
      ead_resource_description_url = "#{repo_url}/resource_descriptions/#{resource_id}.xml"
      # puts ead_resource_description_url
      get_uri = URI(ead_resource_description_url)
      get_request = Net::HTTP::Get.new get_uri.request_uri
      get_request['X-ArchivesSpace-Session'] = @token
      result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
        http.request(get_request)
      end
      # puts result.inspect
      # puts JSON.parse(result.body)['title']
      result.body
    end
  end
end

