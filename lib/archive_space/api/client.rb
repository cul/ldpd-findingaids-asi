require 'net/http'

module ArchiveSpace
  module Api
    class Client

      AsResourceInfo = Struct.new(:publish_flag,:modified_time)

      def initialize
        @session_key = authenticate unless CONFIG[:use_fixtures]
      end

      def get_ead_resource_description(repo_id, resource_id, include_unpublished = false)
        Rails.logger.debug("ArchiveSpace::Api::Client#get_ead_resource_description called:")
        Rails.logger.debug("repo_id: #{repo_id}, resource_id: #{resource_id}, include_unpublished: #{include_unpublished}")
        repo_url = "#{AS_CONFIG[:repositories_url]}/#{repo_id}"
        if include_unpublished
          Rails.logger.warn("API Client: using include_unpublished=true")
          url_parameters = '?include_daos=true&include_unpublished=true'
        else
          url_parameters = '?include_daos=true'
        end
        ead_resource_description_url = "#{repo_url}/resource_descriptions/#{resource_id}.xml#{url_parameters}"
        get_uri = URI(ead_resource_description_url)
        get_request = Net::HTTP::Get.new get_uri.request_uri
        get_request['X-ArchivesSpace-Session'] = @session_key
        result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
          http.request(get_request)
        end
        result.body
      end

      def get_resource_id_local_fixture(bib_id)
        LOCAL_FIXTURES[:map_bib_id_to_as_reource_id][bib_id]
      end

      def get_resource_id(repo_id, bib_id)
        Rails.logger.debug("ArchiveSpace::Api::Client#get_resource_id called:")
        Rails.logger.debug("repo_id: #{repo_id}, bib_id: #{bib_id}")
        type_filter = {
	  jsonmodel_type: 'field_query',
	  field: 'primary_type',
	  comparator: 'equal',
	  value: 'resource'
        }

        id_filter = {
	  jsonmodel_type: 'field_query',
	  comparator: 'equal',
	  field: 'identifier',
	  value: bib_id
        }

        comp_query = {
	  jsonmodel_type: 'boolean_query',
	  op: 'AND',
	  subqueries: [type_filter, id_filter]
        }

        aq = {
	  jsonmodel_type: 'advanced_query',
	  query: comp_query
        }

        params = {
	  page: 1,
	  page_size: 1,
	  aq: aq.to_json
        }

        repo_url = "#{AS_CONFIG[:repositories_url]}/#{repo_id}"
        search_url = "#{repo_url}/search"
        search_uri = URI(search_url)
        search_uri.query = URI.encode_www_form(params)
        get_request = Net::HTTP::Get.new search_uri.request_uri
        get_request['X-ArchivesSpace-Session'] = @session_key
        get_request['Content_Type'] = 'application/json'
        result = Net::HTTP.start(search_uri.host, search_uri.port, use_ssl: true) do |http|
          http.request(get_request)
        end
        result_json = JSON.parse result.body
        # Should probably add a test to check that number of hits is exactly 1
        results = result_json["results"]
        if results.empty?
          # return nil
          nil
        else
          # parse out the id
          result_json["results"][0]["id"].gsub("/repositories/#{repo_id}/resources/",'')
        end
      end

      def get_resource_info(repo_id, resource_id)
        Rails.logger.debug("ArchiveSpace::Api::Client#get_resource_info called:")
        Rails.logger.debug("repo_id: #{repo_id}, resource_id: #{resource_id}")
        repo_url = "#{AS_CONFIG[:repositories_url]}/#{repo_id}"
        resource_url = "#{repo_url}/resources/#{resource_id}"
        get_uri = URI(resource_url)
        get_request = Net::HTTP::Get.new get_uri.request_uri
        get_request['X-ArchivesSpace-Session'] = @session_key
        get_request['Content_Type'] = 'application/json'
        result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
          http.request(get_request)
        end
        result_json = JSON.parse result.body
        publish_flag = result_json['publish']
        mtime_string = result_json['system_mtime']
        mtime_time = Time.strptime(mtime_string, '%Y-%m-%dT%H:%M:%S%z')
        as_resource_info = AsResourceInfo.new
        as_resource_info.modified_time = mtime_time
        as_resource_info.publish_flag = publish_flag
        as_resource_info
      end

      def authenticate
        Rails.logger.debug("ArchiveSpace::Api::Client#authenticate called")
        post_uri = URI(AS_CONFIG[:auth_url])
        post_request = Net::HTTP::Post.new post_uri.request_uri
        post_request.set_form_data('password' => AS_CONFIG[:password])
        result = Net::HTTP.start(post_uri.host, post_uri.port, use_ssl: true) do |http|
          http.request(post_request)
        end
        JSON.parse(result.body)['session']
      end

      # fcd1, 04/15/19: Following work, but are not currently being used

      def get_resource(repo_id, resource_id)
        repo_url = "#{AS_CONFIG[:repositories_url]}/#{repo_id}"
        params = AS_CONFIG[:get_resource_params]
        resource_url = "#{repo_url}/resources/#{resource_id}?#{params}"
        get_uri = URI(resource_url)
        get_request = Net::HTTP::Get.new get_uri.request_uri
        get_request['X-ArchivesSpace-Session'] = @session_key
        result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
          http.request(get_request)
        end
        result.body
      end

      def get_resource_tree(repo_id, resource_id)
        repo_url = "#{AS_CONFIG[:repositories_url]}/#{repo_id}"
        resource_tree_url = "#{repo_url}/resources/#{resource_id}/tree"
        get_uri = URI(resource_tree_url)
        get_request = Net::HTTP::Get.new get_uri.request_uri
        get_request['X-ArchivesSpace-Session'] = @session_key
        result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
          http.request(get_request)
        end
        result.body
      end

      def get_resource_tree_root(repo_id, resource_id)
        repo_url = "#{AS_CONFIG[:repositories_url]}/#{repo_id}"
        resource_tree_url = "#{repo_url}/resources/#{resource_id}/tree/root"
        get_uri = URI(resource_tree_url)
        get_request = Net::HTTP::Get.new get_uri.request_uri
        get_request['X-ArchivesSpace-Session'] = @session_key
        result = Net::HTTP.start(get_uri.host, get_uri.port, use_ssl: true) do |http|
          http.request(get_request)
        end
        result.body
      end
    end
  end
end
